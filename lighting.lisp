(in-package #:org.shirakumo.fraf.leaf)

(define-shader-pass lighting-pass (per-object-pass hdr-output-pass)
  ())

(define-handler (lighting-pass trial:tick) (ev)
  (let ((tt (- (/ (clock +world+) 2) (/ PI 2))))
    (with-buffer-tx (light (asset 'leaf 'light-info))
      (setf (sun-position light) (vec2 (* 10000 (sin tt)) (* 10000 (cos tt))))
      (setf (sun-light light)
            (v* (temperature-color (+ 2500 (* 10000 (max 0 (cos tt)))))
                (if (< 0 (cos tt)) 1 (expt (+ 1 (cos tt)) 4))))
      (setf (ambient-light light)
            (v* (vec3 1 1 1) (/ (+ (cos tt) 1.2) 4))))))

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

(define-shader-pass rendering-pass (render-pass)
  ((lighting :port-type input :texspec (:internal-format :rgba16f))
   (shadow-map :port-type input)))

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
  ()
  (:buffers (leaf light-info)))

(define-class-shader (lit-entity :fragment-shader 100)
  (gl-source (asset 'leaf 'light-info))
  "uniform sampler2D lighting;
uniform sampler2D shadow_map;

vec4 apply_lighting(vec4 color, vec2 offset, float absorption){
  ivec2 pos = ivec2(gl_FragCoord.xy-vec2(0.5)+offset);
  float shade = (0.4 < texelFetch(shadow_map, pos, 0).r)? 0 : 1;
  vec4 light = texelFetch(lighting, pos, 0);

  vec3 truecolor = vec3(0);
  truecolor += light_info.ambient_light*color.rgb;
  truecolor += light_info.sun_light*max(0, shade-absorption)*color.rgb;
  truecolor += light.rgb*max(0, light.a-absorption)*color.rgb;
  return vec4(truecolor, color.a);
}")

(define-shader-subject lit-animated-sprite (lit-entity animated-sprite-subject)
  ())

(define-class-shader (lit-animated-sprite :fragment-shader)
  "out vec4 color;

void main(){
  color = apply_lighting(color, vec2(0, -5), 0);
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
