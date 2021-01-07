(in-package #:org.shirakumo.fraf.kandria)

(defun r-around (x var)
  (+ x (- (random var) (/ var 2))))

(define-global +particle-vbo+
  (make-instance 'vertex-buffer :buffer-data
                 (make-array 24 :element-type 'single-float :initial-contents
                             '(+1.0 +1.0 1.0 1.0
                               +1.0 -1.0 1.0 0.0
                               -1.0 -1.0 0.0 0.0
                               -1.0 -1.0 0.0 0.0
                               -1.0 +1.0 0.0 1.0
                               +1.0 +1.0 1.0 1.0))))

(defun make-particle-data (tiles &key (scale 4) (scale-var 2)
                                      (dir 90) (dir-var 180)
                                      (speed 70) (speed-var 100)
                                      (life 1.0) (life-var 0.5)
                                      (origin (vec 0 0)) (count 100))
  (let ((elt (make-array (* 11 count) :element-type 'single-float)))
    (macrolet ((insert (arr i &rest args)
                 `(let ((off (* ,(length args) ,i)))
                    ,@(loop for arg in args
                            for j from 0cond
                            collect `(setf (aref ,arr (+ ,j off)) (float ,arg 0f0))))))
      (dotimes (i count elt)
        (let ((s (r-around scale scale-var))
              (d (deg->rad (r-around dir dir-var)))
              (sp (r-around speed speed-var))
              (li (r-around life life-var)))
          (destructuring-bind (u- v- us vs) (alexandria:random-elt tiles)
            (insert elt i
                    (vx origin) (vy origin) s
                    u- v- us vs 1.0
                    (* sp (cos d)) (* sp (sin d))
                    li)))))))

(defun update-particle-data (array dt g)
  (macrolet ((f (x)
               `(aref array (+ i ,(position x '(x y s u- v- us vs a vx vy li)))))
             (sf (x v)
               `(setf (aref array (+ i ,(position x '(x y s u- v- us vs a vx vy li)))) ,v)))
    (let ((count 0))
      (loop for i from 0 below (length array) by 11
            for vx = (f vx)
            for vy = (f vy)
            for li = (f li)
            do (sf li (- li dt))
               (sf vy (- vy (* g dt)))
               (sf x (+ (f x) (* vx dt)))
               (sf y (+ (f y) (* vy dt)))
               (when (< li 0.0)
                 (sf a (decf (f a) (* 2 dt)))
                 (incf count 4)))
      ;; All done?
      (= count (length array)))))

(define-shader-entity emitter (lit-entity renderable listener)
  ((vio :accessor vio)
   (vertex-array :accessor vertex-array)
   (texture :initform (// 'kandria 'particles) :accessor texture)
   (amount :initarg :amount :initform 16 :accessor amount)))

(defmethod initialize-instance :after ((emitter emitter) &key tiles location)
  (let* ((inst (make-particle-data tiles :count (amount emitter) :origin location))
         (vbo +particle-vbo+)
         (vio (make-instance 'vertex-buffer :buffer-data inst :data-usage :stream-draw))
         (vao (make-instance 'vertex-array :bindings `((,vbo :size 2 :stride ,(* 4 4) :offset 0)
                                                       (,vbo :size 2 :stride ,(* 4 4) :offset 8)
                                                       (,vio :size 2 :stride ,(* 11 4) :offset  0 :instancing 1)
                                                       (,vio :size 1 :stride ,(* 11 4) :offset  8 :instancing 1)
                                                       (,vio :size 4 :stride ,(* 11 4) :offset 12 :instancing 1)
                                                       (,vio :size 1 :stride ,(* 11 4) :offset 28 :instancing 1)))))
    (setf (vio emitter) vio)
    (setf (vertex-array emitter) vao)))

(defmethod layer-index ((emitter emitter)) (1- +base-layer+))

(defmethod stage :after ((emitter emitter) (area staging-area))
  (stage (vertex-array emitter) area)
  (stage (texture emitter) area))

(defmethod handle ((ev tick) (emitter emitter))
  (let ((vio (vio emitter)))
    (cond ((update-particle-data (buffer-data vio) (* 2 (dt ev)) 100.0)
           (leave emitter T)
           (remove-from-pass emitter +world+))
          (T
           (update-buffer-data vio T)))))

(defmethod render ((emitter emitter) (program shader-program))
  (setf (uniform program "view_matrix") (view-matrix))
  (setf (uniform program "projection_matrix") (projection-matrix))
  (gl:active-texture :texture0)
  (gl:bind-texture :texture-2d (gl-name (texture emitter)))
  (gl:bind-vertex-array (gl-name (vertex-array emitter)))
  (%gl:draw-arrays-instanced :triangles 0 6 (amount emitter))
  (gl:bind-vertex-array 0))

(define-class-shader (emitter :vertex-shader)
  "layout (location = 0) in vec2 position;
layout (location = 1) in vec2 uv;
layout (location = 2) in vec2 off;
layout (location = 3) in float scale;
layout (location = 4) in vec4 uv_off;
layout (location = 5) in float a;
uniform mat4 view_matrix;
uniform mat4 projection_matrix;

out vec2 world_pos;
out vec2 tex_coord;
out float alpha;

void main(){
  world_pos = (position*scale) + off;
  tex_coord = (uv*uv_off.zw)+uv_off.xy;
  alpha = a;
  gl_Position = projection_matrix * view_matrix * vec4(world_pos, 0, 1);
}")

(define-class-shader (emitter :fragment-shader)
  "in vec2 world_pos;
in vec2 tex_coord;
in float alpha;
uniform sampler2D texture_image;

out vec4 color;

void main(){
  color = apply_lighting(texture(texture_image, tex_coord)*alpha, vec2(0), 0, vec2(0), world_pos);
}")

(defun make-tile-uvs (grid count width height)
  (loop for i from 0 below count
        for x = (mod (* i grid) width)
        for y = (floor (* i grid) width)
        collect (list (/ x width)
                      (/ y width)
                      (/ grid width)
                      (/ grid height))))

(defun spawn-particles (location &key (tiles (load-time-value (make-tile-uvs 8 18 128 128))))
  (enter-and-load (make-instance 'emitter :location location :tiles tiles)
                  (region +world+)
                  (handler *context*)))
