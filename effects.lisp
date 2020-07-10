(in-package #:org.shirakumo.fraf.leaf)

(define-shader-entity effect (trial:animated-sprite facing-entity sized-entity)
  ()
  (:default-initargs :sprite-data (asset 'leaf 'effects)))

(defmethod switch-animation ((effect effect) _)
  (let ((region (container effect)))
    (leave effect region)
    (loop for pass across (passes +world+)
          do (remove-from-pass effect pass))))

(defun make-effect (name)
  (let ((effect (make-instance 'effect))
        (region (region +world+)))
    (setf (animation effect) name)
    (enter effect region)
    (loop for pass across (passes +world+)
          do (compile-into-pass effect region pass))))
