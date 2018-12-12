(in-package #:org.shirakumo.fraf.leaf)

(defclass interaction (event)
  ((with :initarg :with :accessor with)))

(define-shader-subject interactable (sprite-entity)
  ((bsize :initform (vec 8 8))))
