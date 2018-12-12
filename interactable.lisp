(in-package #:org.shirakumo.fraf.leaf)

(defclass interaction (event)
  ((with :initarg :with :accessor with)))

(define-asset (leaf 16x) mesh
    (make-rectangle 16 16 :align :bottomleft))

(define-shader-subject interactable (sprite-entity)
  ((bsize :initform (vec 8 8))
   (vertex-array :initform (asset 'leaf '16x))))
