(in-package #:org.shirakumo.fraf.leaf)

(define-shader-entity shadow-caster (located-entity)
  ((shadow-geometry :accessor shadow-geometry)))

(defmethod initialize-instance :after ((caster shadow-caster) &key data)
  (let* ((data (make-array (length data) :adjustable T :fill-pointer T :element-type 'single-float
                                         :initial-contents data))
         (vbo (make-instance 'vertex-buffer :data-usage :dynamic-draw :buffer-data data))
         (vao (make-instance 'vertex-array :vertex-form :triangle-strip
                                           :bindings `((,vbo :size 2 :offset 0 :stride 8))
                                           :size (/ (length data) 2))))
    (setf (shadow-geometry caster) vao)
    (add-vertex caster :location (vec2 0 0))
    (add-vertex caster :location (vec2 32 0))))

(defmethod add-vertex ((caster shadow-caster) &key location)
  (let* ((vao (shadow-geometry caster))
         (vbo (caar (bindings vao)))
         (data (buffer-data vbo))
         (loc (v- location (location caster))))
    ;; Add twice to produce triangle.
    (vector-push-extend (vx loc) data)
    (vector-push-extend (vy loc) data)
    (vector-push-extend (vx loc) data)
    (vector-push-extend (vy loc) data)
    (when (allocated-p vbo)
      (resize-buffer vbo (* (length data) 4) :data data))
    (setf (size vao) (if (<= 6 (length data))
                         (/ (length data) 2)
                         0))))

(define-shader-pass shadow-map-pass (single-shader-pass)
  ((shadow-map :port-type output :texspec (:internal-format :r8))))

(defmethod paint ((container layered-container) (target shadow-map-pass))
  ;; KLUDGE: Bypass layering, only render chunks at layer 0.
  (let ((*current-layer* (floor +layer-count+ 2))
        (layers (objects container)))
    (loop for unit across (aref layers (1- (length layers)))
          do (paint unit target))))

(defmethod paint :around ((thing shader-entity) (target shadow-map-pass)))

(defmethod paint :around ((subject shadow-caster) (pass shadow-map-pass))
  (let ((program (shader-program-for-pass pass subject))
        (vao (shadow-geometry subject)))
    (setf (uniform program "model_matrix") (model-matrix))
    (setf (uniform program "view_matrix") (view-matrix))
    (setf (uniform program "projection_matrix") (projection-matrix))
    (gl:bind-vertex-array (gl-name vao))
    (gl:draw-arrays (vertex-form vao) 0 (size vao))))

(define-class-shader (shadow-map-pass :vertex-shader)
  "layout(location = 0) in vec2 vertex_position;

uniform vec2 light_position = vec2(1000000,1000000);
uniform mat4 model_matrix;
uniform mat4 view_matrix;
uniform mat4 projection_matrix;

void main(){
  vec2 vertex = vertex_position;
  if(gl_VertexID % 2 != 0){
    vec2 direction = light_position - vertex;
    vertex = vertex - direction * 100;
  }
  gl_Position = projection_matrix * view_matrix * model_matrix * vec4(vertex, 0, 1);
}")

(define-class-shader (shadow-map-pass :fragment-shader)
  "out vec4 color;

void main(){
  color = vec4(1);
}")
