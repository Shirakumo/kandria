(in-package #:org.shirakumo.fraf.leaf)

(defclass interaction (event)
  ((with :initarg :with :accessor with)))

(defclass interactable (entity)
  ())

(defclass dialog-entity (interactable)
  ((interactions :initform () :accessor interactions)))

(define-shader-entity interactable-sprite (lit-entity sprite-entity dialog-entity)
  ())

(define-class-shader (interactable-sprite :fragment-shader)
  "
out vec4 color;
void main(){
  color = apply_lighting(color, vec2(0,0), 0.0);
}")

(defclass profile ()
  ((profile-sprite-data :initform (error "PROFILE-SPRITE-DATA not set.") :accessor profile-sprite-data)
   (nametag :initform (error "NAMETAG not set.") :accessor nametag)))

(defmethod stage :after ((profile profile) (area staging-area))
  (stage (resource (profile-sprite-data profile) 'texture) area)
  (stage (resource (profile-sprite-data profile) 'vertex-array) area))

(defmethod quest:activate ((trigger quest:interaction))
  (with-simple-restart (abort "Don't activate the interaction.")
    (let ((interactable (unit (quest:interactable trigger) +world+)))
      (with-new-value-restart (interactable) (new-value "Supply a new interactable to use.")
        (unless (typep interactable 'interactable)
          (error "Failed to find interactable for trigger: ~s"
                 (quest:interactable trigger))))
      (pushnew trigger (interactions interactable)))))

(define-shader-entity door (lit-animated-sprite interactable ephemeral)
  ((target :initform NIL :initarg :target :accessor target)
   (bsize :initform (vec 11 20))
   (primary :initform T :initarg :primary :accessor primary))
  (:default-initargs :sprite-data (asset 'leaf 'debug-door)))

(defmethod (setf animations) :after (animations (door door))
  (setf (next-animation (find 'open (animations door) :key #'name)) 'idle))

(defmethod default-tool ((door door)) (find-class 'freeform))

(defmethod enter :after ((door door) (region region))
  (when (primary door)
    (let* ((location (etypecase (target door)
                       (vec2 (target door))
                       (null (vec (+ (vx (location door)) (* 2 (vx (bsize door))))
                                  (vy (location door))))))
           (other (clone door :location location :target door :primary NIL)))
      (setf (target door) other)
      (enter other region))))

(defmethod layer-index ((door door))
  (1- +base-layer+))

(define-shader-entity passage (door)
  ()
  (:default-initargs :sprite-data (asset 'leaf 'passage)))
