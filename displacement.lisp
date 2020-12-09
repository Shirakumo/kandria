(in-package #:org.shirakumo.fraf.kandria)

(define-asset (kandria displacement) image
    #p"shockwave-2.png")

(define-shader-entity displacer (located-entity listener)
  ((texture :initform (// 'kandria 'displacement) :reader texture)
   (clock :initform 0f0 :accessor clock)
   (lifetime :initform 1f0 :initarg :lifetime :accessor lifetime)
   (strength :initform 1f0 :initarg :strength :accessor strength)))

(defmethod object-renderable-p ((displacer displacer) (pass shader-pass)) NIL)

(defmethod handle ((ev tick) (displacer displacer))
  (incf (clock displacer) (dt ev))
  (when (< (lifetime displacer) (clock displacer))
    (leave displacer T)
    (remove-from-pass displacer (unit 'displacement-render-pass T))))

(defmethod apply-transforms progn ((displacer displacer))
  (let ((tt (1+ (* 10 (clock displacer)
                   (/ (1+ (strength displacer)) 2)
                   (/ (lifetime displacer))))))
    (scale-by tt tt 1)))

(defmethod render ((displacer displacer) (program shader-program))
  (setf (uniform program "model_matrix") (model-matrix))
  (setf (uniform program "effect_strength") (* (/ (strength displacer) 10f0)
                                               (- 1 (/ (clock displacer) (lifetime displacer)))))
  (let ((vao (// 'kandria '16x)))
    (gl:active-texture :texture0)
    (gl:bind-texture :texture-2d (gl-name (texture displacer)))
    (gl:bind-vertex-array (gl-name vao))
    ;; KLUDGE: Bad for performance!
    (if (find 'vertex-buffer (bindings vao) :key #'type-of)
        (%gl:draw-elements (vertex-form vao) (size vao) :unsigned-int 0)
        (%gl:draw-arrays (vertex-form vao) 0 (size vao)))
    (gl:bind-vertex-array 0)))

(define-shader-pass displacement-render-pass (single-shader-scene-pass)
  ((displacement-map :port-type output :attachment :color-attachment0
                     :texspec (:internal-format :rgb8))
   (name :initform 'displacement-render-pass)))

(defmethod stage :after ((pass displacement-render-pass) (area staging-area))
  (stage (// 'kandria '16x) area)
  (stage (// 'kandria 'displacement) area))

(defmethod object-renderable-p ((renderable renderable) (pass displacement-render-pass)) NIL)
(defmethod object-renderable-p ((displacer displacer) (pass displacement-render-pass)) T)

(defmethod prepare-pass-program :after ((pass displacement-render-pass) (program shader-program))
  (setf (uniform program "view_matrix") (view-matrix))
  (setf (uniform program "projection_matrix") (projection-matrix)))

(defmethod render ((pass displacement-render-pass) target)
  (gl:clear-color 127/255 127/255 0 1)
  (gl:clear :color-buffer)
  (call-next-method))

(define-class-shader (displacement-render-pass :vertex-shader)
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

(define-class-shader (displacement-render-pass :fragment-shader)
  "uniform sampler2D texture_image;
uniform float effect_strength = 1.0;
in vec2 tex_coord;
out vec4 color;

void main(){
  color = vec4(texture(texture_image, tex_coord).rg, effect_strength, 1);
}")

(define-shader-pass displacement-pass (simple-post-effect-pass)
  ((displacement-map :port-type input)))

(define-class-shader (displacement-pass :fragment-shader)
  "uniform sampler2D previous_pass;
uniform sampler2D displacement_map;
in vec2 tex_coord;
out vec4 color;

void main(){
  vec3 data = texture(displacement_map, tex_coord).rgb;
  vec2 displacement = (data.xy - 0.5)/10.0;
  vec3 previous = texture(previous_pass, tex_coord+displacement*data.z*10).rgb;
  color = vec4(previous, 1);
}")
