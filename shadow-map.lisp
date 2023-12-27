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

(defmethod apply-transforms progn ((caster shadow-geometry))
  (apply-transforms (slot-value caster 'caster)))

(defmethod render :around ((caster shadow-geometry) (program shader-program))
  (let* ((caster (slot-value caster 'caster))
         (bsize (bsize caster)))
    ;; We fade the caster a bit in order to ensure shadows can cast onto other chunks.
    (let* ((camera (camera +world+))
           (view (in-view-tester camera))
           (diff (* 0.5 (+ 600 (- (vz view) (vx view))))))
      (setf (uniform program "strength") (- 1.0 (clamp 0.0 (/ (- (abs (- (vx (location camera)) (vx (location caster)))) (vx bsize)) diff) 1.0)))
      (call-next-method))))

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
    (with-eval-in-render-loop (+world+)
      (resize-buffer vbo (* 4 (length (buffer-data vbo))) :data (buffer-data vbo)))))

(defmethod compute-shadow-geometry :after (caster (geometry shadow-geometry))
  (setf (size (vertex-array geometry))
        (/ (length (buffer-data (caar (bindings (vertex-array geometry))))) 2)))

(define-shader-pass shadow-map-pass (per-object-pass single-shader-pass)
  ((name :initform 'shadow-map-pass)
   (shadow-map :port-type output :texspec (:internal-format :r8))
   (local-shade :initform 0.0 :accessor local-shade)
   (fc :initform 0 :accessor fc))
  (:buffers (kandria gi)))

(defmethod object-renderable-p ((object renderable) (pass shadow-map-pass)) NIL)
(defmethod object-renderable-p ((object shadow-caster) (pass shadow-map-pass)) T)
(defmethod object-renderable-p ((object shadow-geometry) (pass shadow-map-pass)) T)

(defmethod construct-frame ((pass shadow-map-pass))
  (let* ((frame (frame pass))
         (index 0)
         (total (array-total-size frame))
         (renderable-table (trial::renderable-table pass)))
    (flet ((store (object program)
             (when (<= total (incf index))
               (adjust-array frame (* 2 total))
               (loop for i from total below (* 2 total)
                     do (setf (aref frame i) (cons NIL NIL)))
               (setf total (* 2 total)))
             (let ((entry (aref frame (1- index))))
               (setf (car entry) object)
               (setf (cdr entry) program))))
      (when (region +world+)
        (let ((container (tvec 0 0 0 0)))
          (v<- container (in-view-tester (camera +world+)))
          (decf (vx container) 300)
          (decf (vy container) 300)
          (incf (vz container) 300)
          (incf (vw container) 300)
          (do-fitting (object (bvh (region +world+)) container)
            (let* ((object (when (typep object 'shadow-caster)
                             (shadow-geometry object)))
                   (program (gethash object renderable-table)))
              (when program
                (store object program)))))))
    (setf (fill-pointer frame) index)
    frame))

(defmethod enter ((caster shadow-caster) (pass shadow-map-pass))
  (enter (shadow-geometry caster) pass))

(defmethod leave ((caster shadow-caster) (pass shadow-map-pass))
  (leave (shadow-geometry caster) pass))

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
        (gl:bind-framebuffer :read-framebuffer (gl-name (framebuffer pass)))
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
  "layout(location = 0) in vec2 vertex_position;

uniform mat4 model_matrix;
uniform mat4 view_matrix;
uniform mat4 projection_matrix;

void main(){
  maybe_call_next_method();
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
  maybe_call_next_method();
  color = vec4(0.5*strength,0.0,0.0,1.0);
}")
