(in-package #:org.shirakumo.fraf.kandria)

(defconstant SHADOW-MAP-SCALE #-nx 1 #+nx 2)
(defvar *gi-info* (make-hash-table :test 'eq))

(defmethod gi ((name symbol))
  (or (gethash name *gi-info*)
      (error "No GI with name ~s found." name)))

(defmethod gi ((null null))
  (gi 'null))

(defmethod (setf gi) (value (name symbol))
  (when *context*
    (update-lighting (node 'lighting-pass T)))
  (if value
      (setf (gethash name *gi-info*) value)
      (remhash name *gi-info*))
  value)

(defun list-gis ()
  (loop for v being the hash-values of *gi-info*
        collect v))

(defmacro define-gi (name &body initargs)
  (let ((existing (gensym "EXISTING")))
    `(let ((,existing (ignore-errors (gi ',name))))
       (setf (gi ',name) (trial::ensure-instance ,existing 'gi-info :name ',name ,@initargs)))))

(define-gl-struct gi
  (activep :int :accessor active-p)
  (location :vec2 :accessor location)
  (light :vec3 :accessor light)
  (ambient :vec3 :accessor ambient)
  (attenuation :float :accessor attenuation))

(define-asset (kandria gi) uniform-block
    'gi)

(defclass gi-info ()
  ((name :initform NIL :initarg :name :accessor name)
   (location :initform NIL :initarg :location :accessor location)
   (light :initform NIL :initarg :light :accessor light)
   (ambient :initform 1 :initarg :ambient :accessor ambient)
   (attenuation :initform 0.0 :initarg :attenuation :accessor attenuation)))

(defmethod shared-initialize :after ((info gi-info) slots &key (light-multiplier 1.0) (ambient-multiplier 1.0))
  (flet ((normalize-light (light mult)
           (etypecase light
             (null (vec 0 0 0))
             (real (v* (vec light light light) mult))
             (vec3 (v* light mult))
             (cons (multiply-gradient (make-gradient light) mult))
             (gradient (multiply-gradient light mult)))))
    (setf (light info) (normalize-light (slot-value info 'light) light-multiplier))
    (setf (ambient info) (normalize-light (slot-value info 'ambient) ambient-multiplier))))

(defmethod print-object ((info gi-info) stream)
  (print-unreadable-object (info stream :type T)
    (format stream "~s" (name info))))

(defmethod location ((info gi-info))
  (let ((loc (slot-value info 'location)))
    (flet ((time-position (hour)
             (let ((tt (* (/ hour 24) 2 PI)))
               (nv+ (vec2 (* 10000000 (sin tt)) (* -10000000 (cos tt)))
                    (location (camera +world+))))))
      (etypecase loc
        (vec2
         loc)
        (located-entity
         (location loc))
        (real
         (time-position loc))
        ((eql :sun)
         (time-position (hour +world+)))
        (null
         NIL)
        (symbol
         (let ((unit (node loc +world+)))
           (if unit
               (location unit)
               (vec 0 0))))))))

(flet ((evaluate-light (light)
         (etypecase light
           (vec3
            light)
           (gradient
            (gradient-value (float (hour +world+) 0f0) light)))))
  (defmethod light ((info gi-info))
    (evaluate-light (slot-value info 'light)))

  (defmethod ambient ((info gi-info))
    (evaluate-light (slot-value info 'ambient))))

(define-shader-pass lighting-pass (per-object-pass)
  ((color :port-type output :texspec (:internal-format :rgba16f))
   (gi-a :initform (make-instance 'gi-info) :accessor gi-a)
   (gi-b :initform (make-instance 'gi-info) :accessor gi-b)
   (mix :initform 1.0 :accessor mix)
   (name :initform 'lighting-pass)))

(defmethod render :before ((pass lighting-pass) target)
  (gl:clear-color 0 0 0 0))

(defun update-lighting (pass)
  (let* ((b (gi-b pass))
         (location (location b))
         (light (light b))
         (ambient (ambient b))
         (attenuation (attenuation b))
         (mix (mix pass)))
    (when (< mix 1)
      (let* ((a (gi-a pass))
             (loc (location a)))
        (setf light (vlerp (light a) light mix))
        (setf ambient (vlerp (ambient a) ambient mix))
        (setf attenuation (lerp (attenuation a) attenuation mix))
        (when loc
          (if location
              (setf location (vlerp loc location mix))
              (setf location loc)))))
    (with-buffer-tx (gi (// 'kandria 'gi))
      (setf (active-p gi) (if location 1 0))
      (setf (location gi) (or location (vec 0 0)))
      (setf (light gi) light)
      (setf (ambient gi) ambient)
      (setf (attenuation gi) attenuation))))

(defmethod (setf lighting) ((value gi-info) (pass lighting-pass))
  (unless (eql (gi-b pass) value)
    (setf (mix pass) (- 1.0 (min 1.0 (mix pass))))
    (setf (gi-a pass) (gi-b pass))
    (setf (gi-b pass) value)
    (update-lighting pass))
  value)

(defmethod lighting ((pass lighting-pass))
  (gi-b pass))

(defmethod force-lighting ((pass lighting-pass))
  (setf (mix pass) 1.0)
  (update-lighting pass))

(defmethod handle ((ev force-lighting) (pass lighting-pass))
  (force-lighting pass))

(defmethod handle ((ev switch-chunk) (pass lighting-pass))
  (setf (lighting pass) (gi (chunk ev))))

(defmethod handle ((ev tick) (pass lighting-pass))
  (when (< (mix pass) 1)
    (incf (mix pass) (dt ev)))
  (update-lighting pass))

(defmethod reset ((pass lighting-pass))
  (setf (lighting pass) (gi 'none))
  (force-lighting pass))

(define-shader-entity light (ephemeral vertex-entity sized-entity)
  ((name :initform NIL)))

(defmethod object-renderable-p ((light light) (pass lighting-pass)) T)
(defmethod object-renderable-p ((light light) (pass render-pass)) NIL)
(defmethod object-renderable-p ((renderable renderable) (pass lighting-pass)) NIL)

(define-shader-pass rendering-pass (render-pass)
  ((lighting :port-type input :texspec (:internal-format :rgba16f))
   (local-shade :initform 0.15 :accessor local-shade)
   (shadow-map :port-type input)
   (exposure :initform 0.5 :accessor exposure)
   (gamma :initform 2.2 :accessor gamma)
   (monitor-gamma :initform (setting :display :gamma) :accessor monitor-gamma)
   (name :initform 'render)
   #++(color :port-type output :attachment :color-attachment0
          :texspec (:width 640 :height 416))
   #++(depth :port-type output :attachment :depth-stencil-attachment
             :texspec (:width 640 :height 416))))

(defmethod object-renderable-p ((controller controller) (pass rendering-pass)) NIL)

(defmethod sort-frame ((pass rendering-pass) frame)
  (stable-sort frame #'< :key (lambda (c)
                                (let* ((object (car c))
                                       (idx (layer-index object)))
                                  (etypecase object
                                    (layer (if (<= 2 idx) (+ idx 0.2) (- idx 0.1)))
                                    (water (+ 0.1 idx))
                                    (T idx))))))

(defmethod prepare-pass-program :after ((pass rendering-pass) (program shader-program))
  (setf (uniform program "exposure") (exposure pass))
  (setf (uniform program "gamma") (* (gamma pass) (/ (monitor-gamma pass) 2.2))))

(defun light-intensity (gi shade)
  (let ((color (vlerp (v+ (ambient gi) (light gi)) (ambient gi) (clamp 0 shade 1))))
    (clamp 0 (* (expt (vlength color) 1/3) 1.5) 2.75)))

(defmethod handle ((ev tick) (pass rendering-pass))
  (when (= 0 (mod (fc ev) 2))
    (let ((gi (buffer-data (// 'kandria 'gi))))
      (if (= 1 (active-p gi))
          (let* ((shade (local-shade (flow:other-node pass (first (flow:connections (flow:port pass 'shadow-map))))))
                 (current (local-shade pass)))
            (let ((intensity (light-intensity gi current)))
              (setf (exposure pass) (clamp 0.5 (- 3.5 intensity) 10.0)
                    (gamma pass) (clamp 0.5 (- 3.75 intensity) 3.0)))
            (setf (local-shade pass) (cond ((< (abs (- current shade)) 0.05)
                                            shade)
                                           ((< current shade)
                                            (+ current 0.02))
                                           (T
                                            (- current 0.02)))))
          (setf (exposure pass) 0.5
                (gamma pass) 2.2)))))

(define-class-shader (rendering-pass :fragment-shader -100)
  "out vec4 color;
uniform float gamma = 2.2;
uniform float exposure = 0.5;

void main(){
  maybe_call_next_method();
  vec3 mapped = vec3(1.0) - exp((-color.rgb) * exposure);
  color.rgb = pow(mapped, vec3(1.0 / gamma));
}")

(define-shader-entity lit-entity (renderable)
  ()
  (:buffers (kandria gi)))

;; FIXME: We might want the incidence computation to smoothen when
;;        facing away from the light source to avoid extremely hard
;;        shadows appearing on cylindrical shapes.
;; FIXME: If light is on player layers in front of the player
;;        get lit even when the player is behind them, which is not
;;        correct. No idea how to fix that, though.
(define-class-shader (lit-entity :fragment-shader 100)
  (format NIL "#define SHADOW_MAP_SCALE ~d" SHADOW-MAP-SCALE)
  "uniform sampler2D lighting;
uniform sampler2D shadow_map;

#define PI 3.1415926538

vec4 apply_lighting_flat(vec4 color, vec2 offset, float absorption, vec2 world_pos){
  vec3 truecolor = pow(color.rgb, vec3(2.2));
  ivec2 pos = ivec2(gl_FragCoord.xy-vec2(0.5)+offset);
  vec4 light = texelFetch(lighting, pos, 0);

  absorption = pow(absorption, 1.0/2.2);

  truecolor *= gi.ambient;
  truecolor += light.rgb*max(0, light.a-absorption)*color.rgb;
  
  if(gi.activep != 0){
    vec2 dir = gi.location - world_pos;
    float dirl = (length(dir)-10)/10;
    float attenuation = 1.0/max(1.0, pow(dirl, gi.attenuation));
    float shade = clamp(2-3*texelFetch(shadow_map, pos/SHADOW_MAP_SCALE, 0).r, 0, 1);
    truecolor += gi.light*clamp(shade*(1-absorption)*attenuation, 0, 1)*color.rgb;
  }

  return vec4(truecolor, color.a);
}

vec4 apply_lighting(vec4 color, vec2 offset, float absorption, vec2 normal, vec2 world_pos){
  vec3 truecolor = pow(color.rgb, vec3(2.2));
  ivec2 pos = ivec2(gl_FragCoord.xy-vec2(0.5)+offset);
  vec4 light = texelFetch(lighting, pos, 0);

  absorption = pow(absorption, 1.0/2.2);

  truecolor *= gi.ambient;
  truecolor += light.rgb*max(0, light.a-absorption)*color.rgb;
  
  if(gi.activep != 0){
    vec2 dir = gi.location - world_pos;
    float dirl = (length(dir)-10)/10;
    float incidence = clamp(dot(normalize(dir), normal), 0, 1);
    float attenuation = 1.0/max(1.0, pow(dirl, gi.attenuation));
    float shade = clamp(2-3*texelFetch(shadow_map, pos/SHADOW_MAP_SCALE, 0).r, 0, 1);
    incidence = mix(1.0, incidence, clamp((dirl-1)/3, 0, 1));
    truecolor += gi.light*clamp(shade*(1-absorption)*incidence*attenuation, 0, 1)*color.rgb;
  }

  return vec4(truecolor, color.a);
}")

(define-shader-entity lit-vertex-entity (lit-entity vertex-entity)
  ())

(define-class-shader (lit-vertex-entity :vertex-shader)
  "layout (location = TRIAL_V_LOCATION) in vec3 position;

uniform mat4 model_matrix;
out vec2 world_pos;

void main(){
  maybe_call_next_method();
  world_pos = (model_matrix*vec4(position, 1)).xy;
}")

(define-class-shader (lit-vertex-entity :fragment-shader -10)
  "out vec4 color;
in vec2 world_pos;

void main(){
  maybe_call_next_method();
  color = apply_lighting_flat(color, vec2(0, -5), 0, world_pos);
}")

(define-shader-entity lit-sprite (lit-vertex-entity sprite-entity)
  ())

(define-shader-entity lit-animated-sprite (lit-vertex-entity trial:animated-sprite facing-entity sized-entity)
  ((layer-index :initarg :layer-index :initform 0 :accessor layer-index)))

(defmethod apply-transforms progn ((subject animated-sprite))
  (translate-by 0 (- (vy (bsize subject))) 0))

(define-shader-entity basic-light (light colored-entity creatable)
  ((color :initarg :color :initform (vec4 0.3 0.25 0.1 1.0)
          :type vec4 :documentation "The color of the light")))

(defmethod initialize-instance :after ((light basic-light) &key data)
  (unless (slot-boundp light 'vertex-array)
    (let* ((data (make-array (length data) :adjustable T :fill-pointer T :element-type 'single-float
                                           :initial-contents data))
           (vbo (make-instance 'vertex-buffer :data-usage :dynamic-draw :buffer-data data))
           (vao (make-instance 'vertex-array :vertex-form :triangle-fan
                                             :bindings `((,vbo :size 2 :offset 0 :stride 8))
                                             :size (/ (length data) 2))))
      (setf (vertex-array light) vao))
    (update-bounding-box light)))

(defmethod initargs append ((light basic-light))
  '(:color :vertex-array))

(defmethod update-bounding-box ((light basic-light))
  (let* ((data (buffer-data (caar (bindings (vertex-array light)))))
         (loc (location light))
         (x+ (vx loc)) (x- (vx loc))
         (y+ (vy loc)) (y- (vy loc)))
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
         (loc (v- (vfloor location) (location light))))
    (loop for i from 0 below (length data) by 2
          do (when (and (= (vx loc) (aref data (+ i 0)))
                        (= (vy loc) (aref data (+ i 1))))
               (array-utils:array-shift data :n -2 :from (+ 2 i))
               (return))
          finally (vector-push-extend (vx loc) data)
                  (vector-push-extend (vy loc) data))
    (update-bounding-box light)
    (resize-buffer-data vbo (* (length data) 4) :data data)
    (setf (size vao) (if (<= 6 (length data))
                         (/ (length data) 2)
                         0))))

(defmethod clear ((light basic-light))
  (let* ((vao (vertex-array light))
         (vbo (caar (bindings vao)))
         (data (buffer-data vbo)))
    (setf (fill-pointer data) 0)
    (update-bounding-box light)
    (resize-buffer-data vbo (* (length data) 4) :data data)
    (setf (size vao) (if (<= 6 (length data))
                         (/ (length data) 2)
                         0))))

(define-shader-entity per-vertex-light (light vertex-colored-entity)
  ())

(define-shader-entity textured-light (light sprite-entity resizable creatable)
  ((multiplier :initform 1.0f0 :initarg :multiplier :accessor multiplier
               :type single-float :documentation "Light intensity multiplier")
   (texture :initform (locally (declare (notinline asset))
                        (resource (asset 'kandria 'lights) T)))))

(defmethod initargs append ((light textured-light))
  '(:multiplier))

(defmethod render :before ((light textured-light) (program shader-program))
  (setf (uniform program "multiplier") (multiplier light)))

(defmethod resize ((sprite sprite-entity) width height)
  (vsetf (bsize sprite) (/ width 2) (/ height 2)))

(define-class-shader (textured-light :fragment-shader)
  "uniform float multiplier = 1.0;
out vec4 color;

void main(){
  maybe_call_next_method();
  color *= multiplier;
}")

(define-shader-entity flash (textured-light listener)
  ((time-scale :initform 1.0 :initarg :time-scale :accessor time-scale)))

(defmethod handle ((ev tick) (flash flash))
  (cond ((<= (multiplier flash) 0.0)
         (leave flash T))
        (T
         (decf (multiplier flash) (* (time-scale flash) (dt ev))))))
