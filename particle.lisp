(in-package #:org.shirakumo.fraf.kandria)

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
                                      (spread #.(vec 0 0))
                                      (origin #.(vec 0 0)) (count 100)
                                      (elt (make-array (* 11 count) :element-type 'single-float))
                                      (start 0))
  (macrolet ((insert (arr i &rest args)
               `(let ((off (* ,(length args) (+ start ,i))))
                  ,@(loop for arg in args
                          for j from 0
                          collect `(setf (aref ,arr (+ ,j off)) (float ,arg 0f0))))))
    (dotimes (i count elt)
      (let ((s (random* scale scale-var))
            (d (deg->rad (random* dir dir-var)))
            (sp (random* speed speed-var))
            (li (random* life life-var))
            (x (random* (vx origin) (vx spread)))
            (y (random* (vy origin) (vy spread))))
        (destructuring-bind (u- v- us vs) (alexandria:random-elt tiles)
          (insert elt i
                  x y s
                  u- v- us vs 1.0
                  (* sp (cos d)) (* sp (sin d))
                  li))))))

(defun update-particle-data (array dt g)
  (declare (type (simple-array single-float (*)) array))
  (declare (type single-float dt))
  (declare (optimize speed))
  (macrolet ((f (x)
               `(aref array (+ i ,(position x '(x y s u- v- us vs a vx vy li)))))
             (sf (x v)
               `(setf (aref array (+ si ,(position x '(x y s u- v- us vs a vx vy li)))) ,v)))
    (let ((si 0)
          (gx (* dt (vx2 g)))
          (gy (* dt (vy2 g))))
      (declare (type (unsigned-byte 32) si))
      (loop for i from 0 below (length array) by 11
            for vx = (f vx)
            for vy = (f vy)
            for li = (f li)
            do (sf li (- li dt))
               (sf vx (+ vx gx))
               (sf vy (+ vy gy))
               (sf x (+ (f x) (* vx dt)))
               (sf y (+ (f y) (* vy dt)))
               (sf a (clamp 0.0 (* 2 li) 1.0))
               (when (< 0.0 li)
                 (incf si 11)))
      (loop for i from si below (length array)
            do (setf (aref array i) 0.0))
      (/ si 11))))

(define-shader-entity emitter (renderable listener)
  ((vio :accessor vio)
   (vertex-array :accessor vertex-array)
   (texture :initform (// 'kandria 'particles) :accessor texture)
   (amount :initarg :amount :initform 16 :accessor amount)
   (gravity :initarg :gravity :initform (vec 0 -100.0) :accessor gravity)))

(defmethod initialize-instance :after ((emitter emitter) &key tiles (location #.(vec 0 0)) (scale 8) (scale-var 2)
                                                              (dir 90) (dir-var 180) (speed 70) (speed-var 100)
                                                              (life 1.0) (life-var 0.5) (spread #.(vec 0 0)))
  (let* ((inst (make-particle-data tiles :count (amount emitter) :origin location :spread spread
                                         :scale scale :scale-var scale-var :dir dir :dir-var dir-var
                                         :speed speed :speed-var speed-var :life life :life-var life-var))
         (vbo +particle-vbo+)
         (vio (make-instance 'vertex-buffer :buffer-data inst :data-usage :stream-draw))
         (vao (make-instance 'vertex-array :bindings `((,vbo :size 2 :stride ,(* 4 4) :offset 0)
                                                       (,vbo :size 2 :stride ,(* 4 4) :offset 8)
                                                       (,vio :size 2 :stride ,(* 11 4) :offset  0 :instancing 1)
                                                       (,vio :size 1 :stride ,(* 11 4) :offset  8 :instancing 1)
                                                       (,vio :size 4 :stride ,(* 11 4) :offset 12 :instancing 1)
                                                       (,vio :size 1 :stride ,(* 11 4) :offset 28 :instancing 1))
                                           :size 6)))
    (setf (vio emitter) vio)
    (setf (vertex-array emitter) vao)))

(defmethod layer-index ((emitter emitter)) (1- +base-layer+))

(defmethod stage :after ((emitter emitter) (area staging-area))
  (stage (vertex-array emitter) area)
  (stage (texture emitter) area))

(defmethod handle ((ev tick) (emitter emitter))
  (let ((vio (vio emitter)))
    (cond ((= 0 (update-particle-data (buffer-data vio) (* 2 (dt ev)) (gravity emitter)))
           (leave emitter T))
          (T
           (update-buffer-data vio T)))))

(defmethod render ((emitter emitter) (program shader-program))
  (setf (uniform program "view_matrix") (view-matrix))
  (setf (uniform program "projection_matrix") (projection-matrix))
  (bind (texture emitter) :texture0)
  (render-array (vertex-array emitter) :instances (amount emitter)))

(define-class-shader (emitter :vertex-shader)
  "layout (location = 0) in vec2 position;
layout (location = 1) in vec2 in_uv;
layout (location = 2) in vec2 off;
layout (location = 3) in float scale;
layout (location = 4) in vec4 uv_off;
layout (location = 5) in float a;
uniform mat4 view_matrix;
uniform mat4 projection_matrix;

out vec2 world_pos;
out vec2 uv;
out float alpha;

void main(){
  maybe_call_next_method();
  world_pos = (position*scale) + off;
  uv = (in_uv*uv_off.zw)+uv_off.xy;
  alpha = a;
  gl_Position = projection_matrix * view_matrix * vec4(world_pos, 0, 1);
}")

(define-shader-entity thing-emitter (lit-entity emitter)
  ())

(define-class-shader (thing-emitter :fragment-shader)
  "in vec2 world_pos;
in vec2 uv;
in float alpha;
uniform sampler2D texture_image;

out vec4 color;

void main(){
  maybe_call_next_method();
  color = apply_lighting_flat(texture(texture_image, uv)*alpha, vec2(0), 0, world_pos);
}")

(defun make-tile-uvs (grid count width height &optional (offset 0))
  (loop for i from offset below (+ offset count)
        for x = (mod (* i grid) width)
        for y = (* grid (floor (* i grid) width))
        collect (list (/ x width)
                      (/ y height)
                      (/ grid width)
                      (/ grid height))))

(defun spawn-particles (location tiles &rest initargs)
  (enter-and-load (apply #'make-instance 'thing-emitter :location location :tiles tiles initargs)
                  (region +world+)
                  +main+))

(define-shader-entity light-emitter (emitter light)
  ((multiplier :initform 1.0 :initarg :multiplier :accessor multiplier))
  (:inhibit-shaders (vertex-entity :vertex-shader)))

(defmethod render :before ((emitter light-emitter) (program shader-program))
  (setf (uniform program "multiplier") (multiplier emitter)))

(define-class-shader (light-emitter :fragment-shader)
  "in vec2 world_pos;
in vec2 uv;
in float alpha;
uniform sampler2D texture_image;
uniform float multiplier;

out vec4 color;

void main(){
  maybe_call_next_method();
  color = texture(texture_image, uv)*alpha*multiplier;
}")

(defun spawn-lights (location tiles &rest initargs)
  (enter-and-load (apply #'make-instance 'light-emitter :location location :tiles tiles initargs)
                  (region +world+)
                  +main+))
