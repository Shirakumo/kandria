(in-package #:org.shirakumo.fraf.leaf)

(defclass interaction (event)
  ((with :initarg :with :accessor with)))

(define-asset (leaf 16x) mesh
    (make-rectangle 16 16 :align :bottomleft))

(define-shader-subject interactable (sprite-entity sized-entity)
  ((vertex-array :initform (asset 'leaf '16x)))
  (:default-initargs
   :texture (asset 'leaf 'facility-items)
   :bsize (vec 16 16)
   :size (vec 16 16)))
