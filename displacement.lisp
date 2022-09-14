(in-package #:org.shirakumo.fraf.kandria)

(define-shader-entity displacer ()
  ((texture :initarg :texture :reader texture)
   (strength :initform 1f0 :initarg :strength :accessor strength)))

(defmethod object-renderable-p ((displacer displacer) (pass shader-pass)) NIL)

(defmethod stage :after ((displacer displacer) (area staging-area))
  (stage (texture displacer) area))

(defmethod render ((displacer displacer) (program shader-program))
  (setf (uniform program "model_matrix") (model-matrix))
  (setf (uniform program "effect_strength") (strength displacer))
  (let ((vao (// 'kandria '16x)))
    (gl:active-texture :texture0)
    (gl:bind-texture :texture-2d (gl-name (texture displacer)))
    (gl:bind-vertex-array (gl-name vao))
    (%gl:draw-elements (vertex-form vao) (size vao) :unsigned-int 0)
    (gl:bind-vertex-array 0)))

(define-class-shader (displacer :vertex-shader)
  "layout (location = 0) in vec3 position;
layout (location = 1) in vec2 in_tex_coord;
out vec2 tex_coord;

uniform mat4 model_matrix;
uniform mat4 view_matrix;
uniform mat4 projection_matrix;

void main(){
  gl_Position = projection_matrix * view_matrix * model_matrix * vec4(position, 1.0f);
  tex_coord = in_tex_coord;
}")

(define-class-shader (displacer :fragment-shader)
  "uniform sampler2D texture_image;
uniform float effect_strength = 1.0;
in vec2 tex_coord;
out vec4 color;

void main(){
  vec2 strength = texture(texture_image, tex_coord).rg*2-1;
  color = vec4(strength*effect_strength, 0, 1);
}")

(define-shader-entity shockwave (displacer facing-entity located-entity listener)
  ((texture :initform (// 'kandria 'shockwave))
   (clock :initform 0f0 :accessor clock)
   (lifetime :initform 0.3 :initarg :lifetime :accessor lifetime)
   (initial-strength :initform 1f0 :initarg :strength :accessor initial-strength)))

(defmethod handle ((ev tick) (displacer shockwave))
  (incf (clock displacer) (dt ev))
  (setf (strength displacer)
        (* (initial-strength displacer)
           (- 1 (/ (clock displacer) (lifetime displacer)))))
  (when (< (lifetime displacer) (clock displacer))
    (leave displacer T)))

(defmethod apply-transforms progn ((displacer shockwave))
  (let* ((s (- 11.0 (min 11.0 (/ 1.0 (+ 0.01 (expt (clock displacer) 1.001)))))))
    (scale-by s s 1)))

(define-shader-entity heatwave (displacer sized-entity resizable listener ephemeral creatable)
  ((texture :initform (// 'kandria 'heatwave))
   (strength :initform 0.02)
   (offset :initform 0.0 :accessor offset))
  (:inhibit-shaders (displacer :fragment-shader)))

(defmethod handle ((ev tick) (heatwave heatwave))
  (incf (offset heatwave) (* (dt ev) -0.2)))

(defmethod handle ((ev change-time) (heatwave heatwave))
  ;; Scale strength based on time of day (8 day hours)
  (setf (strength heatwave)
        (* (float (max 0 (/ (- 4 (abs (- (hour +world+) 12))) 4.0)) 0f0)
           0.0075)))

(defmethod render :before ((heatwave heatwave) (program shader-program))
  (setf (uniform program "offset") (offset heatwave)))

(defmethod apply-transforms progn ((heatwave heatwave))
  (scale-by (/ (vx (bsize heatwave)) 8) (/ (vy (bsize heatwave)) 8) 1))

(define-class-shader (heatwave :fragment-shader)
  "uniform sampler2D texture_image;
uniform float effect_strength = 1.0;
uniform float offset = 0.0;
in vec2 tex_coord;
out vec4 color;

void main(){
  vec2 strength = texture(texture_image, vec2(tex_coord.x, tex_coord.y*2+offset)).rg*2-1;
  color = vec4(strength*effect_strength*(1-tex_coord.y), 0, 1);
}")

(define-shader-entity scanline (displacer transformed)
  ((texture :initform (// 'kandria 'scanline))
   (strength :initform 1.0)))

(defmethod apply-transforms progn ((displacer scanline))
  (translate (vxy_ (location (camera +world+))))
  (scale-by 40 25 1))

(define-shader-pass displacement-render-pass (per-object-pass)
  ((displacement-map :port-type output :attachment :color-attachment0
                     :texspec (:internal-format :rg16f))
   (name :initform 'displacement-render-pass)))

(defmethod stage :after ((pass displacement-render-pass) (area staging-area))
  (stage (// 'kandria '16x) area)
  (stage (// 'kandria 'scanline) area)
  (stage (// 'kandria 'shockwave) area)
  (stage (// 'kandria 'dashwave) area))

(defmethod object-renderable-p ((renderable renderable) (pass displacement-render-pass)) NIL)
(defmethod object-renderable-p ((displacer displacer) (pass displacement-render-pass)) T)

(defmethod prepare-pass-program :after ((pass displacement-render-pass) (program shader-program))
  (setf (uniform program "view_matrix") (view-matrix))
  (setf (uniform program "projection_matrix") (projection-matrix)))

(defmethod render ((pass displacement-render-pass) target)
  (gl:clear-color 0 0 0 1)
  (gl:clear :color-buffer)
  (gl:blend-func :one :one)
  (call-next-method)
  (gl:blend-func :src-alpha :one-minus-src-alpha))

(define-shader-pass displacement-pass (simple-post-effect-pass)
  ((name :initform 'displacement-pass)
   (displacement-map :port-type input)))

(define-class-shader (displacement-pass :fragment-shader)
  "uniform sampler2D previous_pass;
uniform sampler2D displacement_map;
in vec2 tex_coord;
out vec4 color;

void main(){
  vec2 displacement = texture(displacement_map, tex_coord).rg;
  vec3 previous = texture(previous_pass, tex_coord+displacement).rgb;
  color = vec4(previous, 1);
}")

