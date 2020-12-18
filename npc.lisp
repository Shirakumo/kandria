(in-package #:org.shirakumo.fraf.kandria)

(define-shader-entity npc (animatable ephemeral dialog-entity profile)
  ())

(defmethod handle :before ((ev tick) (npc npc))
  (case (state npc)
    ((:dying :animated :stunned)
     (handle-animation-states npc ev))
    (T
     (handle-ai-states npc ev))))

(defmethod handle-ai-states ((npc npc) ev))

(define-shader-entity fi (npc)
  ((name :initform 'fi)
   (bsize :initform (vec 8 16))
   (profile-sprite-data :initform (asset 'kandria 'fi-profile))
   (nametag :initform (@ fi-nametag)))
  (:default-initargs
   :sprite-data (asset 'kandria 'fi)))

(defmethod hurt ((fi fi) damage))

(define-shader-entity pet (animatable ephemeral interactable)
  ())

(defmethod handle :before ((ev tick) (npc pet))
  (let ((vel (velocity npc))
        (dt (* 100 (dt ev))))
    (case (state npc)
      ((:dying :animated :stunned)
       (handle-animation-states npc ev))
      (T
       (nv+ vel (v* (gravity (medium npc)) dt))))
    (nv+ (frame-velocity npc) vel)))

(defmethod handle :after ((ev tick) (npc pet))
  (case (state npc)
    (:normal
     (let ((player (unit 'player T)))
       (case (name (animation npc))
         (sleep
          (when (< (vsqrdist2 (location player) (location npc))
                   (expt (* 3 +tile-size+) 2))
            (setf (animation npc) 'wake)))
         (pet)
         (wake
          (when (< (expt (* 4 +tile-size+) 2)
                   (vsqrdist2 (location player) (location npc)))
            (setf (animation npc) 'lay))))))))

(defmethod interactable-p ((npc pet))
  (eql 'wake (name (animation npc))))

(defmethod interact ((npc pet) (player player))
  (setf (animation npc) 'pet)
  (start-animation 'pet player))

(define-shader-entity tame-wolf (pet)
  ()
  (:default-initargs
   :sprite-data (asset 'kandria 'wolf)))

;; KLUDGE: add proper idle at some point.
(defmethod idleable-p ((npc tame-wolf)) NIL)
