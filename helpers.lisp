(in-package #:org.shirakumo.fraf.leaf)

(defparameter *default-tile-size* 8)

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

(defun nvalign (vec grid)
  (vsetf vec
         (* grid (floor (vx vec) grid))
         (* grid (floor (vy vec) grid))))

(defun vsqrdist2 (a b)
  (declare (type vec2 a b))
  (declare (optimize speed))
  (+ (expt (- (vx2 a) (vx2 b)) 2)
     (expt (- (vy2 a) (vy2 b)) 2)))

(defun closer (a b dir)
  (< (abs (v. a dir)) (abs (v. b dir))))

(defun clamp (low mid high)
  (max low (min mid high)))

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

(defun query (message &key default parse)
  (format *query-io* "~&~a~@[ [~a]~]:~%> " message default)
  (let ((read (read-line *query-io* NIL)))
    (cond ((not read))
          ((string= "" read)
           default)
          (T
           (if parse (funcall parse read) read)))))

(defmacro with-query ((value message &key default parse) &body body)
  `(let ((,value (query ,message :default ,default :parse ,parse)))
     (when ,value
       ,@body)))

(defun entity-at-point (point level)
  (for:for ((result as NIL)
            (entity over level))
    (when (and (typep entity 'base-entity)
               (print (contained-p point entity))
               (or (null result)
                   (< (vlength (bsize entity))
                      (vlength (bsize result)))))
      (setf result entity))))

(define-pool leaf
  :base :leaf)

(defclass post-tick (event)
  ())

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defclass base-entity (entity)
    ())
  
  (defclass located-entity (base-entity)
    ((location :initarg :location :initform (vec 0 0) :accessor location))))

(defmethod paint :around ((obj located-entity) target)
  (with-pushed-matrix ()
    (translate-by (round (vx (location obj))) (round (vy (location obj))) 0)
    (call-next-method)))

(defclass facing-entity (base-entity)
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

(defmethod scan ((entity game-entity) (target vec2))
  (let ((w (vx (bsize entity)))
        (h (vy (bsize entity)))
        (loc (location entity)))
    (when (and (<= (- (vx loc) w) (vx target) (+ (vx loc) w))
               (<= (- (vy loc) h) (vy target) (+ (vy loc) h)))
      entity)))

(defmethod contained-p ((target vec2) (entity game-entity))
  (scan entity target))

(defmethod contained-p ((target vec2) thing)
  NIL)
