(in-package #:org.shirakumo.fraf.leaf)

(defclass interaction (event)
  ((with :initarg :with :accessor with)))

(define-shader-subject interactable (sprite-entity game-entity)
  ((in-vicinity-p :initform NIL :accessor in-vicinity-p))
  (:default-initargs
   :texture (asset 'leaf 'facility-items)
   :bsize (vec 16 16)
   :size (vec 16 16)))

(define-handler (interactable trial:tick) (ev)
  (when (< (vsqrdist2 (location interactable)
                      (location (unit :player T)))
           (expt 8 2))
    (setf (in-vicinity-p interactable) T)))

(define-handler (interactable interact) (ev)
  (when (in-vicinity-p interactable)
    (issue +level+ 'interaction :with (name interactable))))

(defmethod paint :after ((interactable interactable) target)
  (when (in-vicinity-p interactable)
    (with-pushed-matrix ()
      (translate-by 0 (vx (size interactable)) 0)
      (paint prompt target))))
