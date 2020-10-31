(in-package #:org.shirakumo.fraf.kandria)

(define-shader-entity npc (animatable dialog-entity profile)
  ())

(define-shader-entity fi (npc)
  ((name :initform 'fi)
   (bsize :initform (vec 8 16))
   (profile-sprite-data :initform (asset 'kandria 'fi-profile))
   (nametag :initform "Fi"))
  (:default-initargs
   :sprite-data (asset 'kandria 'fi)))

(defmethod hurt ((fi fi) damage))
