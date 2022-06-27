(in-package #:org.shirakumo.fraf.kandria)

(define-shader-entity critter (lit-animated-sprite game-entity interactable)
  ((idle-timer :initform (random* 10.0 5.0) :accessor idle-timer)
   (direction :initform (alexandria:random-elt #(-1 +1)))
   (alert-distance :initform (* +tile-size+ (random* 8 6)) :accessor alert-distance)
   (acceleration :initform (vec 0 0) :accessor acceleration)))

(defmethod interactable-p ((critter critter))
  (eql :normal (state critter)))

(defmethod description ((critter critter))
  (language-string 'critter))

(defmethod interact ((critter critter) (player player))
  (start-animation 'pet player))

(defmethod handle :before ((ev tick) (critter critter))
  (let ((dt (dt ev)))
    (ecase (state critter)
      (:normal
       (when (in-view-p (location critter) (bsize critter))
         (cond ((<= (decf (idle-timer critter) dt) 0.0)
                (setf (animation critter) 'idle))
               ((not (eq 'stand (name (animation critter))))
                (setf (animation critter) 'stand)
                (setf (clock critter) (random* 1.0 1.0))))
         (let ((player (unit 'player +world+)))
           (when (and (within-dist-p (location critter) (location player) (alert-distance critter))
                      (< (p! slowwalk-limit) (vx (velocity player))))
             (setf (animation critter) 'run)
             (setf (direction critter) (float-sign (- (vx (location critter)) (vx (location player)))))
             (setf (state critter) :fleeing)))))
      (:fleeing
       (let ((vel (velocity critter)))
         (incf (vx vel) (* dt (vx (acceleration critter)) (direction critter)))
         (incf (vy vel) (* dt (vy (acceleration critter))))
         (nv+ (frame-velocity critter) vel)
         (unless (find-chunk critter)
           (oob critter NIL)))))))

(defmethod oob :after ((critter critter) next)
  (when (and (eql :fleeing (state critter))
             (slot-boundp critter 'container))
    (leave* critter T)))

(defmethod switch-animation :after ((critter critter) new)
  (case (name (animation critter))
    (stand
     (setf (idle-timer critter) (random* 10.0 5.0)))))

(define-shader-entity white-bird (critter)
  ((acceleration :initform (vec (random* 3.0 0.7) (random* 1.5 0.2))))
  (:default-initargs :sprite-data (asset 'kandria 'critter-white-bird)))

(defmethod stage :after ((bird white-bird) (area staging-area))
  (dolist (sound '(ambience-birds-fluttering ambience-birds-chirp-1))
    (stage (// 'sound sound) area)))

(defmethod (setf state) :before (state (subject white-bird))
  (when (and (eql state :fleeing) (not (eq state (state subject))))
    (harmony:play (// 'sound 'ambience-birds-fluttering))))

(defmethod apply-transforms progn ((subject white-bird))
  (translate-by 0 -9 0))

(define-shader-entity red-bird (critter)
  ((acceleration :initform (vec (random* 2.0 0.5) (random* 2.5 0.5))))
  (:default-initargs :sprite-data (asset 'kandria 'critter-red-bird)))

(defmethod stage :after ((bird red-bird) (area staging-area))
  (dolist (sound '(ambience-birds-fluttering ambience-birds-chirp-2))
    (stage (// 'sound sound) area)))

(defmethod (setf state) :before (state (subject red-bird))
  (when (and (eql state :fleeing) (not (eq state (state subject))))
    (harmony:play (// 'sound 'ambience-birds-fluttering))))

(defmethod apply-transforms progn ((subject red-bird))
  (translate-by 0 -9 0))

(define-shader-entity rat (critter)
  ((acceleration :initform (vec (random* 3.0 0.5) 0)))
  (:default-initargs :sprite-data (asset 'kandria 'critter-rat)))

(defmethod layer-index ((rat rat)) (1- +base-layer+))

(defmethod interactable-p ((rat rat)) NIL)

(define-shader-entity mole (critter)
  ((acceleration :initform (vec 0 0)))
  (:default-initargs :sprite-data (asset 'kandria 'critter-mole)))

(defmethod layer-index ((mole mole)) (1- +base-layer+))

(defmethod switch-animation :before ((mole mole) animation)
  (when (eql (name (animation mole)) 'run)
    (leave* mole T)))

(define-shader-entity bat (critter)
  ((acceleration :initform (vec (random* 2.0 0.7) (random* 1.5 0.2)))
   (alert-distance :initform (* +tile-size+ (random* 12 6)) :accessor alert-distance))
  (:default-initargs :sprite-data (asset 'kandria 'critter-bat)))

(defmethod layer-index ((bat bat)) (1- +base-layer+))

(defmethod (setf state) :after ((state (eql :fleeing)) (bat bat))
  (vsetf (velocity bat) 0 (random* -1.0 0.5)))

(defmethod apply-transforms progn ((subject bat))
  (translate-by 0 -6 0))

(defmethod interactable-p ((bat bat)) NIL)

(define-shader-entity pet (roaming-npc)
  ((profile-sprite-data :initform (asset 'kandria 'player-profile))
   (nametag :initform (@ player-nametag))
   (timer :initform 0.0 :accessor timer)))

(defmethod interactable-p ((npc pet))
  (eql 'wake (name (animation npc))))

(defmethod interact ((npc pet) (player player))
  (setf (animation npc) 'pet)
  (start-animation 'pet player))

(defmethod description ((pet pet))
  (language-string 'critter))

(define-shader-entity tame-wolf (paletted-entity pet creatable)
  ((palette :initform (// 'kandria 'wolf-palette))
   (palette-index :initform 3)
   (nametag-element :initform NIL))
  (:default-initargs
   :sprite-data (asset 'kandria 'wolf)))

;; KLUDGE: add proper idle at some point.
(defmethod base-health ((npc tame-wolf)) 1000)

(defmethod interactable-p ((npc pet))
  (or (eql 'stand (name (animation npc)))
      (eql 'sit (name (animation npc)))))

(defmethod idleable-p ((npc pet))
  (find (name (animation npc)) '(stand walk run)))

(defmethod interact :around ((npc tame-wolf) (player player))
  (start-animation 'pet npc)
  (setf (vx (location player)) (vx (location npc)))
  (setf (direction player) (direction npc))
  (start-animation 'pet player))
