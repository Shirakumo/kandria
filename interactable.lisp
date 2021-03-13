(in-package #:org.shirakumo.fraf.kandria)

(defclass interactable (entity)
  ())

(defgeneric interact (with from))
(defgeneric interactable-p (entity))

(defclass dialog-entity (interactable)
  ((interactions :initform () :accessor interactions)))

(defmethod interactable-p ((entity dialog-entity))
  (interactions entity))

(defmethod interact ((entity dialog-entity) from)
  (when (interactable-p entity)
    (show (make-instance 'dialog :interactions (or (loop for interaction in (interactions entity)
                                                         when (eql :active (quest:status interaction))
                                                         collect interaction)
                                                   (interactions entity))))))

(define-shader-entity interactable-sprite (ephemeral lit-sprite dialog-entity resizable)
  ((name :initform (generate-name "INTERACTABLE"))))

(defclass profile ()
  ((profile-sprite-data :initform (error "PROFILE-SPRITE-DATA not set.") :accessor profile-sprite-data)
   (nametag :initform (error "NAMETAG not set.") :accessor nametag)))

(defmethod stage :after ((profile profile) (area staging-area))
  (stage (resource (profile-sprite-data profile) 'texture) area)
  (stage (resource (profile-sprite-data profile) 'vertex-array) area))

(define-shader-entity door (lit-animated-sprite interactable ephemeral)
  ((target :initform NIL :initarg :target :accessor target)
   (bsize :initform (vec 11 20))
   (primary :initform T :initarg :primary :accessor primary))
  (:default-initargs :sprite-data (asset 'kandria 'debug-door)))

(defmethod interactable-p ((door door)) T)

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
  (:default-initargs :sprite-data (asset 'kandria 'passage)))
