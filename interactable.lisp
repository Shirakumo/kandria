(in-package #:org.shirakumo.fraf.leaf)

(defclass interaction (event)
  ((with :initarg :with :accessor with)))

(defclass interactable ()
  ((interactions :initform () :accessor interactions)))

(defclass profile ()
  ((profile-sprite-data :initform (error "PROFILE-SPRITE-DATA not set.") :accessor profile-sprite-data)
   (nametag :initform (error "NAMETAG not set.") :accessor nametag)))

(defmethod stage :after ((profile profile) (area staging-area))
  (stage (profile-sprite-data profile) area))

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
   (primary :initform T :accessor primary))
  (:default-initargs :sprite-data (asset 'leaf 'debug-door)))

(defmethod (setf animations) :after (animations (door door))
  (setf (next-animation (find 'open (animations door) :key #'name)) 'idle))

(defmethod enter :after ((door door) (region region))
  (when (typep (target door) 'vec)
    (let ((other (clone door)))
      (setf (location other) (target door))
      (setf (primary other) NIL)
      (setf (target other) door)
      (setf (target door) other)
      (setf (primary door) T)
      (enter other region))))

(defmethod layer-index ((door door))
  (1- +base-layer+))
