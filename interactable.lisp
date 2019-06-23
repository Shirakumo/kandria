(in-package #:org.shirakumo.fraf.leaf)

(defclass interaction (event)
  ((with :initarg :with :accessor with)))

(define-shader-subject interactable (sprite-entity)
  ((bsize :initform (vec +tile-size+ +tile-size+))))
