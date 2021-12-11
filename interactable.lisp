(in-package #:org.shirakumo.fraf.kandria)

(defclass interactable (entity collider)
  ())

(defmethod action ((interactable interactable)) 'interact)

(defgeneric interact (with from))
(defgeneric interactable-p (entity))

(defmethod description ((interactable interactable)) "")
(defmethod interactable-p ((entity entity)) NIL)
(defmethod interactable-p ((block block)) NIL)

(defclass dialog-entity (interactable)
  ((interactions :initform () :accessor interactions)))

(defmethod interactable-p ((entity dialog-entity))
  (interactions entity))

(defmethod interact ((entity dialog-entity) from)
  (when (interactable-p entity)
    (show (make-instance 'dialog :interactions (interactions entity)))))

(define-shader-entity interactable-sprite (ephemeral lit-sprite dialog-entity resizable creatable)
  ((name :initform (generate-name "INTERACTABLE"))))

(defmethod description ((sprite interactable-sprite))
  (language-string 'examine))

(define-shader-entity interactable-animated-sprite (ephemeral lit-animated-sprite dialog-entity resizable creatable)
  ((name :initform (generate-name "INTERACTABLE"))
   (trial:sprite-data :initform (asset 'kandria 'dummy) :type asset)
   (layer-index :initarg :layer-index :initform +base-layer+ :accessor layer-index :type integer)
   (pending-animation :initarg :animation :initform NIL :accessor pending-animation :type symbol)))

(defmethod (setf animations) :after (value (sprite interactable-animated-sprite))
  (when (pending-animation sprite)
    (setf (animation sprite) (pending-animation sprite))))

(define-shader-entity leak (interactable-animated-sprite audible-entity)
  ((voice :initform (// 'sound 'ambience-water-pipe-leak))))

(defmethod (setf animation) :after (animation (leak leak))
  (unless (active-p leak)
    (when (allocated-p (voice leak))
      (harmony:stop (voice leak)))))

(defmethod active-p ((leak leak))
  (not (eq 'normal (name (animation leak)))))

(defclass profile ()
  ((profile-sprite-data :initform (error "PROFILE-SPRITE-DATA not set.") :accessor profile-sprite-data)
   (nametag :initform (error "NAMETAG not set.") :accessor nametag)))

(defmethod stage :after ((profile profile) (area staging-area))
  (stage (resource (profile-sprite-data profile) 'texture) area)
  (stage (resource (profile-sprite-data profile) 'vertex-array) area))

(define-shader-entity door (lit-animated-sprite interactable ephemeral creatable)
  ((target :initform NIL :initarg :target :accessor target)
   (bsize :initform (vec 11 20))
   (primary :initform T :initarg :primary :accessor primary)
   (facing-towards-screen-p :initform T :initarg :facing-towards-screen-p :accessor facing-towards-screen-p :type boolean))
  (:default-initargs :sprite-data (asset 'kandria 'debug-door)))

(defmethod description ((door door))
  (language-string 'door))

(defmethod interactable-p ((door door)) T)

(defmethod default-tool ((door door)) (find-class 'freeform))

(defmethod enter :after ((door door) (region region))
  (when (primary door)
    (let ((other (etypecase (target door)
                   (vec2 (clone door :target door :primary NIL :location (target door)))
                   (null (clone door :target door :primary NIL :location (vec (+ (vx (location door)) (* 2 (vx (bsize door))))
                                                                              (vy (location door)))))
                   (list (apply #'clone door :target door :primary NIL (target door))))))
      (setf (target door) other)
      (enter other region))))

(defmethod layer-index ((door door))
  (1- +base-layer+))

(defmethod leave* :after ((door door) thing)
  (when (slot-boundp (target door) 'container)
    (leave* (target door) T)))

(define-shader-entity passage (door creatable)
  ()
  (:default-initargs :sprite-data (asset 'kandria 'passage)))

(defmethod object-renderable-p ((passage passage) (pass shader-pass)) NIL)

(define-shader-entity locked-door (door creatable)
  ((name :initform (generate-name "LOCKED-DOOR"))
   (key :initarg :key :initform NIL :accessor key :type symbol)
   (unlocked-p :initarg :unlocked-p :initform NIL :accessor unlocked-p :type boolean))
  (:default-initargs :sprite-data (asset 'kandria 'electronic-door)))

(defmethod stage :after ((door locked-door) (area staging-area))
  (dolist (sound '(door-access-denied door-unlock door-open-sliding-inside door-shut-sliding-inside))
    (stage (// 'sound sound) area)))

(defmethod initargs append ((door locked-door)) '(:key :unlocked-p))

(defmethod interactable-p ((door locked-door)) T)

(defmethod (setf unlocked-p) :around (value (door locked-door))
  (unless (eql value (unlocked-p door))
    (call-next-method)
    (setf (unlocked-p (target door)) value)
    (when (/= 0 (length (animations door)))
      (setf (animation door) (if value 'granted 'denied))))
  value)

(defmethod interact ((door locked-door) (player player))
  (cond ((unlocked-p door)
         (harmony:play (// 'sound 'door-open-sliding-inside))
         (call-next-method))
        ((have (key door) player)
         (setf (unlocked-p door) T)
         (harmony:play (// 'sound 'door-unlock)))
        (T
         (harmony:play (// 'sound 'door-access-denied))
         (setf (animation door) 'denied))))

(define-shader-entity save-point (lit-animated-sprite interactable ephemeral creatable)
  ((bsize :initform (vec 8 18)))
  (:default-initargs :sprite-data (asset 'kandria 'telephone)))

(defmethod stage :after ((point save-point) (area staging-area))
  (stage (// 'sound 'telephone-save) area))

(defmethod interact :after ((save-point save-point) thing)
  (harmony:play (// 'sound 'telephone-save)))

(defmethod (setf animations) :after (animations (save-point save-point))
  (setf (next-animation (find 'call (animations save-point) :key #'name)) 'normal))

(defmethod description ((save-point save-point))
  (language-string 'save-game))

(defmethod interactable-p ((save-point save-point)) (saving-possible-p))

(defmethod layer-index ((save-point save-point))
  (1- +base-layer+))

(define-shader-entity station (lit-animated-sprite interactable ephemeral creatable)
  ((name :initform (generate-name "STATION"))
   (bsize :initform (vec 24 16))
   (train :initform (make-instance 'train) :accessor train)
   (unlocked-p :initform NIL :initarg :unlocked-p :accessor unlocked-p
               :type boolean))
  (:default-initargs :sprite-data (asset 'kandria 'station)))

(defmethod initialize-instance :after ((station station) &key train-location)
  (v<- (location (train station)) (or train-location (location station))))

(defmethod enter :after ((station station) container)
  (enter (train station) container))

(defmethod leave :after ((station station) container)
  (leave (train station) container))

(defmethod description ((station station))
  (language-string 'station))

(defmethod interact ((station station) (player player))
  (unless (unlocked-p station)
    (status :important "~a" (@formats 'new-station-unlocked (language-string (name station)))))
  (setf (unlocked-p station) T)
  (show-panel 'fast-travel-menu :current-station station))

(defun list-stations (&optional (region (region +world+)))
  (for:for ((entity over region)
            (status when (and (typep entity 'station) (unlocked-p entity))
                    collect entity))))

(defmethod interactable-p ((station station)) T)

(define-shader-entity train (lit-sprite ephemeral)
  ((name :initform NIL)
   (texture :initform (// 'kandria 'train))
   (size :initform (vec 1094 109))))

(defmethod layer-index ((train train))
  (1+ +base-layer+))

(define-class-shader (train :fragment-shader)
  "uniform float visibility = 0.5;
out vec4 color;

void main(){
  color.a *= visibility;
}")
