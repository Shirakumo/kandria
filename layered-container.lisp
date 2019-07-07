(in-package #:org.shirakumo.fraf.leaf)

(defvar *current-layer*)

(defclass layered-container (container-unit)
  ((objects :initform NIL))
  (:default-initargs :layers +layer-count+))

(defmethod initialize-instance :after ((container layered-container) &key layers)
  (let ((objects (make-array layers)))
    (dotimes (i layers)
      (setf (aref objects i) (make-array 0 :adjustable T :fill-pointer T)))
    (setf (objects container) objects)))

(defgeneric layer-index (unit))

(defmethod layer-index ((unit unit)) 0)

(defmethod enter ((unit unit) (container layered-container))
  (let ((layer (+ (layer-index unit)
                  (floor (length (objects container)) 2))))
    (vector-push-extend unit (aref (objects container) layer))))

(defmethod leave ((unit unit) (container layered-container))
  (let ((layer (+ (layer-index unit)
                  (floor (length (objects container)) 2))))
    (array-utils:vector-pop-position*
     (aref (objects container) layer)
     (position unit (aref (objects container) layer)))))

(defmethod paint ((container layered-container) target)
  (let ((layers (objects container)))
    (dotimes (i (length layers))
      (let ((*current-layer* i))
        (loop for unit across (aref layers i)
              do (paint unit target))))))

(defmethod layer-count ((container layered-container))
  (length (objects container)))

(defmacro do-layered-container ((entity container &optional result) &body body)
  (let ((layer (gensym "LAYER")))
    `(loop for ,layer across (objects ,container)
           do (loop for ,entity across ,layer
                    do (progn ,@body))
           finally (return ,result))))

(defclass layered-container-iterator (for:iterator)
  ((layer :initarg :layer :accessor layer)
   (start :initform 0 :accessor start)))

(defmethod for:has-more ((iterator layered-container-iterator))
  (< (layer iterator) (length (for:object iterator))))

(defmethod for:next ((iterator layered-container-iterator))
  (let ((layer (aref (for:object iterator) (layer iterator))))
    (prog1 (aref layer (start iterator))
      (incf (start iterator))
      (when (<= (length layer) (start iterator))
        (setf (start iterator) 0)
        (loop for i from (1+ (layer iterator)) below (length (for:object iterator))
              while (= 0 (length (aref (for:object iterator) i)))
              finally (setf (layer iterator) i))))))

(defmethod (setf for:current) ((unit unit) (iterator layered-container-iterator))
  (setf (aref (aref (for:object iterator) (layer iterator))
              (start iterator))
        unit))

(defmethod for:make-iterator ((container layered-container) &key)
  (make-instance 'layered-container-iterator
                 :object (objects container)
                 :layer (or (position 0 (objects container) :key #'length :test-not #'=)
                            MOST-POSITIVE-FIXNUM)))
