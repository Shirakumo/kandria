(in-package #:org.shirakumo.fraf.leaf)

(sb-ext:defglobal +level+ NIL)

(defun maybe-finalize-inheritance (class)
  (unless (c2mop:class-finalized-p class)
    (c2mop:finalize-inheritance class))
  class)

(defmethod unit (thing (target (eql T)))
  (when +level+
    (unit thing +level+)))

(defun vrand (min max)
  (vec (+ min (random (- max min)))
       (+ min (random (- max min)))))

(defun closer (a b dir)
  (< (abs (v. a dir)) (abs (v. b dir))))

(defun update-instance-initforms (class)
  (flet ((update (instance)
           (loop for slot in (c2mop:class-direct-slots class)
                 for name = (c2mop:slot-definition-name slot)
                 for init = (c2mop:slot-definition-initform slot)
                 when init do (setf (slot-value instance name) (eval init)))))
    (when (window :main NIL)
      (for:for ((entity over (scene (window :main))))
               (when (typep entity class)
                 (update entity))))))

(define-pool leaf
  :base :leaf)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defclass located-entity (entity)
    ((location :initarg :location :initform (vec 0 0) :accessor location))))

(defmethod paint :around ((obj located-entity) target)
  (with-pushed-matrix ()
    (translate-by (round (vx (location obj))) (round (vy (location obj))) 0)
    (call-next-method)))

(defclass facing-entity (entity)
  ((direction :initarg :direction :initform -1 :accessor direction)))

(defmethod paint :around ((obj facing-entity) target)
  (with-pushed-matrix ()
    (scale-by (direction obj) 1 1)
    (call-next-method)))

(define-subject game-entity (located-entity)
  ((velocity :initarg :velocity :accessor velocity)
   (bsize :initarg :bsize :accessor bsize))
  (:default-initargs :velocity (vec 0 0)
                     :bsize (nv/ (vec *default-tile-size* *default-tile-size*) 2)))

(define-generic-handler (game-entity tick trial:tick))
