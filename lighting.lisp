(in-package #:org.shirakumo.fraf.leaf)

(define-shader-pass lighting-pass (per-object-pass hdr-output-pass)
  ())

(define-shader-entity light (vertex-entity sized-entity)
  ())

(defmethod register-object-for-pass ((pass lighting-pass) (entity shader-entity))
  (when (typep entity 'light)
    (call-next-method)))

(defmethod paint-with ((pass lighting-pass) (entity shader-entity))
  (when (typep entity 'light)
    (call-next-method)))

(defmethod paint :around ((entity shader-entity) (pass lighting-pass))
  (when (typep entity 'light)
    (call-next-method)))

(define-shader-pass rendering-pass (render-pass shadow-render-pass)
  ((lighting :port-type input :texspec (:target :texture-2D :internal-format :rgba16f))))

(defmethod register-object-for-pass ((pass rendering-pass) (light light)))
(defmethod paint-with ((pass rendering-pass) (light light)))

(define-class-shader (rendering-pass :fragment-shader -100)
  "out vec4 color;
uniform float gamma = 2.2;
uniform float exposure = 1.0;

void main(){
  vec3 mapped = vec3(1.0) - exp((-color.rgb) * exposure);
  color.rgb = pow(mapped, vec3(1.0 / gamma));
}")

(define-shader-entity lit-entity ()
  ())

(define-class-shader (lit-entity :fragment-shader 100)
  "uniform sampler2D lighting;

vec4 apply_lighting(vec4 color, vec2 offset){
  ivec2 pos = ivec2(gl_FragCoord.xy-vec2(0.5)+offset);
  vec4 light = texelFetch(lighting, pos, 0);
  color.rgb += light.rgb*light.a;
  return color;
}")

(define-shader-subject lit-animated-sprite (lit-entity animated-sprite-subject)
  ())

(define-class-shader (lit-animated-sprite :fragment-shader)
  "out vec4 color;

void main(){
  color = apply_lighting(color, vec2(0, -5));
}")

(define-shader-entity basic-light (light colored-entity)
  ((color :initform (vec4 0.3 0.25 0.1 1.0))))

(defmethod initialize-instance :after ((light basic-light) &key data)
  (unless (slot-boundp light 'vertex-array)
    (let* ((data (make-array (length data) :adjustable T :fill-pointer T :element-type 'single-float
                                           :initial-contents data))
           (vbo (make-instance 'vertex-buffer :data-usage :dynamic-draw :buffer-data data))
           (vao (make-instance 'vertex-array :vertex-form :triangle-fan
                                             :bindings `((,vbo :size 2 :offset 0 :stride 8))
                                             :size (/ (length data) 2))))
      (allocate vbo)
      (allocate vao)
      (setf (vertex-array light) vao))))

(defmethod update-bounding-box ((light basic-light))
  (let ((data (buffer-data (caar (bindings (vertex-array light)))))
        (loc (location light))
        x+ x- y+ y-)
    ;; Determine bounds
    (loop for i from 0 below (length data) by 2
          for x = (+ (vx loc) (aref data (+ i 0)))
          for y = (+ (vy loc) (aref data (+ i 1)))
          do (when (or (null x+) (< x+ x)) (setf x+ x))
             (when (or (null x-) (< x x-)) (setf x- x))
             (when (or (null y+) (< y+ y)) (setf y+ y))
             (when (or (null y-) (< y y-)) (setf y- y)))
    ;; Update coordinates
    (vsetf (bsize light) (/ (- x+ x-) 2) (/ (- y+ y-) 2))
    (let ((newloc (vec (+ x- (vx (bsize light)))
                       (+ y- (vy (bsize light))))))
      (loop for i from 0 below (length data) by 2
            do (incf (aref data (+ i 0)) (- (vx loc) (vx newloc)))
               (incf (aref data (+ i 1)) (- (vy loc) (vy newloc))))
      (setf (location light) newloc))))

(defmethod add-vertex ((light basic-light) &key location)
  (let* ((vao (vertex-array light))
         (vbo (caar (bindings vao)))
         (data (buffer-data vbo))
         (loc (v- location (location light))))
    (loop for i from 0 below (length data) by 2
          do (when (and (= (vx loc) (aref data (+ i 0)))
                        (= (vy loc) (aref data (+ i 1))))
               (array-utils:array-shift data :n -2 :from (+ 2 i))
               (return))
          finally (vector-push-extend (vx loc) data)
                  (vector-push-extend (vy loc) data))
    (update-bounding-box light)
    (resize-buffer vbo (* (length data) 4) :data data)
    (setf (size vao) (if (<= 6 (length data))
                         (/ (length data) 2)
                         0))))

(define-shader-entity per-vertex-light (light vertex-colored-entity)
  ())

(define-shader-entity textured-light (light textured-entity)
  ())
