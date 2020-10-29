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
  (let ((interactions (interactions entity)))
    (when interactions
      (let ((new (loop for interaction in interactions
                       when (eql :active (quest:status interaction))
                       collect interaction)))
        (cond (new
               (show (make-instance 'dialog :interactions new)))
              (T
               ;; Nothing new, cycle old interactions.
               ;; FIXME: should show a menu here instead.
               (show (make-instance 'dialog :interactions interactions))
               (setf (interactions entity) (cycle-list interactions))))))))

(define-shader-entity interactable-sprite (ephemeral lit-sprite dialog-entity)
  ())

(defclass profile ()
  ((profile-sprite-data :initform (error "PROFILE-SPRITE-DATA not set.") :accessor profile-sprite-data)
   (nametag :initform (error "NAMETAG not set.") :accessor nametag)))

(defmethod stage :after ((profile profile) (area staging-area))
  (stage (resource (profile-sprite-data profile) 'texture) area)
  (stage (resource (profile-sprite-data profile) 'vertex-array) area))

(defmethod quest:activate ((trigger quest:interaction))
  (with-simple-restart (abort "Don't activate the interaction.")
    (let ((interactable (unit (quest:interactable trigger) +world+)))
      (when (typep interactable 'interactable)
        (pushnew trigger (interactions interactable))))))

(defmethod quest:deactivate ((trigger quest:interaction))
  (let ((interactable (unit (quest:interactable trigger) +world+)))
    (when (typep interactable 'interactable)
      (setf (interactions interactable) (remove interactable (interactions interactable))))))

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
