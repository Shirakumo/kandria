(in-package #:org.shirakumo.fraf.leaf)

(define-gl-struct light-info
  (activep :int :accessor active-p)
  (sun-position :vec2 :accessor sun-position)
  (sun-light :vec3 :accessor sun-light)
  (ambient-light :vec3 :accessor ambient-light))

(define-asset (leaf light-info) uniform-buffer
    'light-info)

(define-shader-entity shadow-caster (located-entity)
  ((shadow-geometry :accessor shadow-geometry)))

(defmethod initialize-instance :after ((caster shadow-caster) &key data)
  (let* ((data (make-array (length data) :adjustable T :fill-pointer T :element-type 'single-float
                                         :initial-contents data))
         (vbo (make-instance 'vertex-buffer :data-usage :dynamic-draw :buffer-data data))
         (vao (make-instance 'vertex-array :vertex-form :triangles
                                           :bindings `((,vbo :size 2 :offset 0 :stride 8))
                                           :size (/ (length data) 2))))
    (setf (shadow-geometry caster) vao)))

(defmethod add-shadow-line ((caster shadow-caster) a b)
  (let* ((vao (shadow-geometry caster))
         (vbo (caar (bindings vao)))
         (data (buffer-data vbo)))
    ;; Vertices arranged in the following manner, such that
    ;; bottom vertices that should be moved are always at an
    ;; even modulus, for easy testing in the vertex shader.
    ;; 0  _1 2
    ;; _3 4 _5
    (vector-push-extend (vx a) data)
    (vector-push-extend (vy a) data)
    (vector-push-extend (vx a) data)
    (vector-push-extend (vy a) data)
    (vector-push-extend (vx b) data)
    (vector-push-extend (vy b) data)
    (vector-push-extend (vx b) data)
    (vector-push-extend (vy b) data)
    (vector-push-extend (vx b) data)
    (vector-push-extend (vy b) data)
    (vector-push-extend (vx a) data)
    (vector-push-extend (vy a) data)
    (setf (size vao) (/ (length data) 2))))

(define-shader-pass shadow-map-pass (single-shader-pass)
  ((shadow-map :port-type output :texspec (:internal-format :r8))
   (local-shade :initform 0.0 :accessor local-shade))
  (:buffers (leaf light-info)))

(defmethod paint-with :after ((pass shadow-map-pass) (world scene))
  (let ((player (unit 'player world)))
    (when player
      (let* ((pos (m* (projection-matrix) (view-matrix) (vec (vx (location player)) (+ (vy (location player)) 8) 0 1)))
             (px (nv/ (nv+ pos 1) 2)))
        (cffi:with-foreign-object (pixel :uint8)
          (%gl:read-pixels (floor (clamp 0 (* (vx px) (width pass)) (1- (width pass))))
                           (floor (clamp 0 (* (vy px) (height pass)) (1- (height pass))))
                           1 1 :red :unsigned-byte pixel)
          (setf (local-shade pass) (/ (cffi:mem-ref pixel :uint8) 128.0)))))))

;; KLUDGE: This sucks man.
(defmethod paint :around ((thing shader-entity) (target shadow-map-pass)))

(defmethod paint :around ((subject shadow-caster) (pass shadow-map-pass))
  (let ((program (shader-program-for-pass pass subject))
        (vao (shadow-geometry subject)))
    (with-pushed-matrix (model-matrix)
      (translate-by (vx (location subject)) (vy (location subject)) 0)
      (setf (uniform program "model_matrix") (model-matrix))
      (setf (uniform program "view_matrix") (view-matrix))
      (setf (uniform program "projection_matrix") (projection-matrix))
      (gl:bind-vertex-array (gl-name vao))
      (unwind-protect
           (gl:draw-arrays (vertex-form vao) 0 (size vao))
        (gl:bind-vertex-array 0)))))

(define-class-shader (shadow-map-pass :vertex-shader)
  (gl-source (asset 'leaf 'light-info))
  "layout(location = 0) in vec2 vertex_position;

uniform mat4 model_matrix;
uniform mat4 view_matrix;
uniform mat4 projection_matrix;

void main(){
  vec2 vertex = vertex_position;
  if(gl_VertexID % 2 != 0){
    vec2 direction = light_info.sun_position - vertex;
    vertex = vertex - direction * 100;
  }
  gl_Position = projection_matrix * view_matrix * model_matrix * vec4(vertex, 0, 1);
}")

(define-class-shader (shadow-map-pass :fragment-shader)
  "out vec4 color;

void main(){
  color = vec4(0.5);
}")
