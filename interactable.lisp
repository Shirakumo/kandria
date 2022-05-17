(in-package #:org.shirakumo.fraf.kandria)

(defvar *default-interactions* (make-hash-table :test 'eq))

(defclass interactable (entity collider)
  ())

(defmethod action ((interactable interactable)) 'interact)

(defgeneric interact (with from))
(defgeneric interactable-p (entity))

(defmethod description ((interactable interactable)) "")
(defmethod interactable-p ((entity entity)) NIL)
(defmethod interactable-p ((block block)) NIL)

(defclass dialog-entity (interactable)
  ((interactions :initform () :accessor interactions)
   (default-interaction :initform NIL :initarg :default-interaction :accessor default-interaction)))

(defmethod initialize-instance :after ((entity dialog-entity) &key)
  (unless (default-interaction entity)
    (setf (default-interaction entity) (gethash (name entity) *default-interactions*))))

(defmethod interactable-p ((entity dialog-entity))
  (or (interactions entity)
      (default-interaction entity)))

(defmethod interact ((entity dialog-entity) from)
  (when (interactable-p entity)
    (show (make-instance 'dialog :interactions (or (interactions entity)
                                                   (list (default-interaction entity)))))))

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

(defmethod description ((leak leak))
  (language-string 'leak))

(defmethod active-p ((leak leak))
  (not (eq 'normal (name (animation leak)))))

(defclass profile ()
  ((profile-sprite-data :initform (error "PROFILE-SPRITE-DATA not set.") :accessor profile-sprite-data)
   (nametag :initform (error "NAMETAG not set.") :accessor nametag)
   (pitch :initform 1.0 :initarg :pitch :accessor pitch)))

(defmethod stage :after ((profile profile) (area staging-area))
  (stage (resource (profile-sprite-data profile) 'texture) area)
  (stage (resource (profile-sprite-data profile) 'vertex-array) area))

(define-shader-entity door (lit-animated-sprite interactable ephemeral creatable)
  ((target :initform NIL :initarg :target :accessor target)
   (bsize :initform (vec 11 20))
   (primary :initform T :initarg :primary :accessor primary)
   (facing-towards-screen-p :initform T :initarg :facing-towards-screen-p :accessor facing-towards-screen-p :type boolean)))

(defmethod description ((door door))
  (if (< (vy (location door)) (vy (location (target door))))
      (language-string 'door-up)
      (language-string 'door-down)))

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

(define-shader-entity basic-door (door creatable)
  ()
  (:default-initargs :sprite-data (asset 'kandria 'door)))

(defmethod stage :after ((door basic-door) (area staging-area))
  (stage (// 'sound 'door-open) area))

(defmethod interact :before ((door basic-door) (entity game-entity))
  (harmony:play (// 'sound 'door-open) :reset T))

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

(defmethod layer-index ((station station))
  (1- +base-layer+))

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
  (sort (for:for ((entity over region)
                  (status when (typep entity 'station)
                          collect entity)))
        #'> :key (lambda (station) (vy (location station)))))

(defmethod interactable-p ((station station)) T)

(defmethod trigger ((target station) (source station) &key)
  (move :freeze (unit 'player +world+))
  (hide (prompt (unit 'player +world+)))
  (setf (move-time (train source)) 0.0)
  (setf (state (train source)) :depart)
  (setf (move-time (train target)) 0.0)
  (setf (state (train target)) :arrive))

(defmethod handle :after ((ev tick) (station station))
  (handle ev (train station)))

(define-shader-entity train (lit-sprite ephemeral)
  ((name :initform NIL)
   (texture :initform (// 'kandria 'train))
   (move-time :initform 0.0 :accessor move-time)
   (visibility :initform 0.5 :accessor visibility)
   (original-location :initform (vec 0 0) :accessor original-location)
   (size :initform (vec 1094 109))
   (state :initform :normal :accessor state)))

(defmethod layer-index ((train train))
  (1+ +base-layer+))

(defmethod render :before ((train train) (program shader-program))
  (setf (uniform program "visibility") (visibility train)))

(defmethod handle ((ev tick) (train train))
  (let ((acc 5.0)
        (arrive-time 2.0)
        (loc (location train)))
    (ecase (state train)
      (:normal
       (if (contained-p (location (unit 'player +world+))
                        (tvec (vx loc) (vy loc) (/ (vx (size train)) 2.0) (/ (vy (size train)) 2.0)))
           (when (< 0.5 (visibility train))
             (decf (visibility train) (dt ev)))
           (when (< (visibility train) 1.0)
             (incf (visibility train) (dt ev)))))
      (:depart
       (when (<= 1.0 (incf (visibility train) (dt ev)))
         (setf (move-time train) 0.0)
         (v<- (original-location train) loc)
         (setf (state train) :departing)))
      (:departing
       (decf (vx loc) (* (move-time train) acc))
       (when (<= 2.5 (incf (move-time train) (dt ev)))
         (v<- loc (original-location train))
         (setf (state train) :normal)))
      (:arrive
       (when (<= 2.0 (incf (move-time train) (dt ev)))
         (transition
           :kind :black
           (v<- (original-location train) loc)
           (snap-to-target (camera +world+) train)
           (incf (vx loc) (* 0.5 acc (expt arrive-time 2.0) 100.0))
           (setf (move-time train) 0.0)
           (setf (state train) :arriving))))
      (:arriving
       (decf (vx loc) (* (- arrive-time (move-time train)) acc))
       (when (<= arrive-time (incf (move-time train) (dt ev)))
         (let ((player (unit 'player +world+)))
           (v<- loc (original-location train))
           (v<- (location player) loc)
           (place-on-ground player (location player))
           (stop player)
           (setf (target (camera +world+)) player)
           (setf (state train) :normal)))))))

(define-class-shader (train :fragment-shader)
  "uniform float visibility = 0.5;
out vec4 color;

void main(){
  color.a *= visibility;
}")
