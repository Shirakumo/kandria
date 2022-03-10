(in-package #:org.shirakumo.fraf.kandria)

(define-shader-entity shadow-geometry (vertex-entity)
  ((caster :initarg :caster :initform (error "CASTER required"))))

(defmethod initialize-instance :after ((caster shadow-geometry) &key data)
  (let* ((data (make-array (length data) :adjustable T :fill-pointer T :element-type 'single-float
                                         :initial-contents data))
         (vbo (make-instance 'vertex-buffer :data-usage :dynamic-draw :buffer-data data))
         (vao (make-instance 'vertex-array :vertex-form :triangles
                                           :bindings `((,vbo :size 2 :offset 0 :stride 8))
                                           :size (/ (length data) 2))))
    (setf (vertex-array caster) vao)))

(defmethod add-shadow-line ((vbo vertex-buffer) a b)
  (let* ((data (buffer-data vbo)))
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
    (vector-push-extend (vy a) data)))

(defmethod render :around ((caster shadow-geometry) (program shader-program))
  (let* ((caster (slot-value caster 'caster))
         (bsize (bsize caster)))
    ;; We increase the size of the caster and then fade it a bit in order to ensure shadows can cast onto other chunks.
    (cond ((not (typep caster 'chunk))
           (call-next-method))
          ((in-view-p (location caster) (tvec (* 4 (vx bsize)) (* 4 (vy bsize))))
           (let ((camera (camera +world+)))
             (setf (uniform program "strength") (clamp 0.0 (- 4 (/ (abs (- (vx (location camera)) (vx (location caster)))) (vx bsize))) 1.0))
             (call-next-method))))))

(defclass shadow-caster ()
  ((shadow-geometry :accessor shadow-geometry)))

(defmethod initialize-instance ((caster shadow-caster) &key)
  (call-next-method)
  (setf (shadow-geometry caster) (make-instance 'shadow-geometry :caster caster)))

(defmethod stage :after ((caster shadow-caster) (area staging-area))
  (stage (shadow-geometry caster) area))

(defgeneric compute-shadow-geometry (caster geometry))

(defmethod compute-shadow-geometry ((caster shadow-caster) (_ (eql T)))
  (compute-shadow-geometry caster (shadow-geometry caster)))

(defmethod compute-shadow-geometry ((caster shadow-caster) (geometry shadow-geometry))
  (compute-shadow-geometry caster (caar (bindings (vertex-array geometry)))))

(defmethod compute-shadow-geometry :after (caster (vbo vertex-buffer))
  (when (allocated-p vbo)
    (resize-buffer vbo (* 4 (length (buffer-data vbo))) :data (buffer-data vbo))))

(defmethod compute-shadow-geometry :after (caster (geometry shadow-geometry))
  (setf (size (vertex-array geometry))
        (/ (length (buffer-data (caar (bindings (vertex-array geometry))))) 2)))

(define-shader-pass shadow-map-pass (single-shader-scene-pass)
  ((name :initform 'shadow-map-pass)
   (shadow-map :port-type output :texspec (:internal-format :r8))
   (local-shade :initform 0.0 :accessor local-shade)
   (fc :initform 0 :accessor fc))
  (:buffers (kandria gi)))

(defmethod object-renderable-p ((object renderable) (pass shadow-map-pass)) NIL)
(defmethod object-renderable-p ((object shadow-caster) (pass shadow-map-pass)) T)
(defmethod object-renderable-p ((object shadow-geometry) (pass shadow-map-pass)) T)

(defmethod compile-to-pass ((caster shadow-caster) (pass shadow-map-pass))
  (compile-to-pass (shadow-geometry caster) pass))

(defmethod render ((pass shadow-map-pass) target)
  (when (setting :display :shadows)
    (call-next-method)))

(defmethod render :before ((pass shadow-map-pass) target)
  (gl:blend-func :src-alpha :one)
  (gl:clear-color 0 0 0 0))

(defmethod render :after ((pass shadow-map-pass) target)
  (gl:blend-func :src-alpha :one-minus-src-alpha)
  (let ((player (unit 'player T)))
    (setf (fc pass) (mod (+ (fc pass) 1) 60))
    (when (and player (= 0 (fc pass)))
      (let* ((pos (m* (projection-matrix) (view-matrix) (vec (vx (location player)) (+ (vy (location player)) 8) 0 1)))
             (px (nv/ (nv+ pos 1) 2)))
        (cffi:with-foreign-object (pixel :uint8)
          (%gl:read-pixels (floor (clamp 0 (* (vx px) (width pass)) (1- (width pass))))
                           (floor (clamp 0 (* (vy px) (height pass)) (1- (height pass))))
                           1 1 :red :unsigned-byte pixel)
          (setf (local-shade pass) (/ (cffi:mem-ref pixel :uint8) 256.0)))))))

(defmethod force-lighting ((pass shadow-map-pass))
  (setf (fc pass) 59))

(defmethod handle ((ev force-lighting) (pass shadow-map-pass))
  (force-lighting pass))

(define-class-shader (shadow-map-pass :vertex-shader)
  (gl-source (asset 'kandria 'gi))
  "layout(location = 0) in vec2 vertex_position;

uniform mat4 model_matrix;
uniform mat4 view_matrix;
uniform mat4 projection_matrix;

void main(){
  vec2 vertex = (model_matrix * vec4(vertex_position, 0, 1)).xy;
  if(gl_VertexID % 2 != 0){
    vec2 direction = normalize(gi.location - vertex);
    vertex = vertex - direction*100000;
  }
  gl_Position = projection_matrix * view_matrix * vec4(vertex, 0, 1);
}")

(define-class-shader (shadow-map-pass :fragment-shader)
  "out vec4 color;
uniform float strength = 1.0;

void main(){
  color = vec4(0.5*strength,0.0,0.0,1.0);
}")
