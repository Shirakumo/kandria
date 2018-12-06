(in-package #:org.shirakumo.fraf.leaf)

(defparameter *default-tile-size* 8)

(sb-ext:defglobal +level+ NIL)

(defun format-absolute-time (time)
  (multiple-value-bind (s m h dd mm yy) (decode-universal-time time 0)
    (format NIL "~4,'0d.~2,'0d.~2,'0d ~2,'0d:~2,'0d:~2,'0d" yy mm dd h m s)))

(defun maybe-finalize-inheritance (class)
  (unless (c2mop:class-finalized-p class)
    (c2mop:finalize-inheritance class))
  class)

(defun kw (thing)
  (intern (string-upcase thing) "KEYWORD"))

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

(defun vfloor (vec)
  (vapply vec floor))

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

(defun query (message on-yes &key default parse)
  (flet ((parse (string)
           (cond ((not string))
                 ((string= "" string)
                  default)
                 (T
                  (if parse (funcall parse string) string)))))
    (let ((message (format NIL "~a~@[ [~a]~]:" message default)))
      (cond (*context*
             (with-context (*context*)
               (flet ((callback (string) (funcall on-yes (parse string))))
                 (let ((input (make-instance 'text-input :title message :callback #'callback)))
                   (transition input +level+)
                   (enter input +level+)))))
            (T
             (format *query-io* "~&~a~%> " message)
             (parse (read-line *query-io* NIL)))))))

(defmacro with-query ((value message &key default parse) &body body)
  `(query ,message
          (lambda (,value) ,@body)
          :default ,default :parse ,parse))

(defun entity-at-point (point level)
  (for:for ((result as NIL)
            (entity over level))
    (when (and (typep entity 'base-entity)
               (contained-p point entity)
               (or (null result)
                   (< (vlength (bsize entity))
                      (vlength (bsize result)))))
      (setf result entity))))

(defmethod contained-p ((target vec2) thing)
  NIL)

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

(defclass sized-entity (located-entity)
  ((bsize :initarg :bsize :accessor bsize))
  (:default-initargs :bsize (nv/ (vec *default-tile-size* *default-tile-size*) 2)))

(defmethod scan ((entity sized-entity) (target vec2))
  (let ((w (vx (bsize entity)))
        (h (vy (bsize entity)))
        (loc (location entity)))
    (when (and (<= (- (vx loc) w) (vx target) (+ (vx loc) w))
               (<= (- (vy loc) h) (vy target) (+ (vy loc) h)))
      entity)))

(defmethod contained-p ((target vec2) (entity sized-entity))
  (scan entity target))

(define-subject game-entity (sized-entity)
  ((velocity :initarg :velocity :accessor velocity))
  (:default-initargs :velocity (vec2 0 0)))

(define-generic-handler (game-entity tick trial:tick))

(defmethod scan ((entity sized-entity) (target game-entity))
  (let ((hit (aabb (location target) (velocity target)
                   (location entity) (v+ (bsize entity) (bsize target)))))
    (when hit
      (setf (hit-object hit) entity)
      (collide target entity hit))))

(defclass trigger (sized-entity)
  ((event-type :initarg :event-type :accessor event-type)
   (event-initargs :initarg :event-initargs :accessor event-initargs)
   (active-p :initarg :active-p :accessor active-p))
  (:default-initargs :event-type (error "EVENT-TYPE required.")
                     :event-initargs ()
                     :active-p T
                     :bsize (vec2 16 16)))

(defmethod fire ((trigger trigger))
  (apply #'issue +level+ (event-type trigger) (event-initargs trigger))
  (setf (active-p trigger) NIL))

(defclass enter-area (event)
  ((area :initarg :area :reader area)))

(stealth-mixin:define-stealth-mixin unpausable () controller ())
