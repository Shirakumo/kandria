(in-package #:org.shirakumo.fraf.kandria)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defclass medium ()
    ())

  (defgeneric gravity (medium))
  (defgeneric drag (medium))
  (defgeneric submerged (thing medium))

  (defmethod (setf medium) :around (new object)
    (let ((old (medium object)))
      (unless (eq new old)
        (leave object old)
        (call-next-method)
        (enter object new))
      new))

  (defmethod submerged ((entity entity) (medium medium)))
  (defmethod enter (object (medium medium)))
  (defmethod leave (object (medium medium)))

  (defclass air (medium)
    ())

  (defmethod drag ((air air))
    1.0)

  (defmethod gravity ((air air))
    (vec 0 -15))

  (defclass vacuum (air)
    ())

  (defmethod gravity ((vacuum vacuum))
    (vec 0 0)))

(define-global +default-medium+ (make-instance 'air))
