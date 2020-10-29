(in-package #:org.shirakumo.fraf.kandria)

(define-shader-entity npc (animatable dialog-entity profile)
  ((idle-time :initform (random 15.0) :accessor idle-time)))

(defmethod handle :after ((ev tick) (npc npc))
  (case (state npc)
    (:normal
     (decf (idle-time npc) (dt ev))
     (when (<= (idle-time npc) 0.0)
       (setf (idle-time npc) (+ 7.0 (random 8.0)))
       (setf (animation npc) 'idle)))))

(define-shader-entity fi (npc)
  ((name :initform 'fi)
   (bsize :initform (vec 8 16))
   (profile-sprite-data :initform (asset 'kandria 'fi-profile))
   (nametag :initform "Fi"))
  (:default-initargs
   :sprite-data (asset 'kandria 'fi)))

(defmethod hurt ((fi fi) damage))
