(in-package #:org.shirakumo.fraf.leaf)

(defvar *current-layer*)

(defclass layered-container (container-unit)
  ((objects :initform NIL)
   (layer-count :initarg :layer-count :reader layer-count))
  (:default-initargs :layer-count +layer-count+))

(defmethod initialize-instance :after ((container layered-container) &key layer-count)
  (let ((objects (make-array (1+ layer-count))))
    (dotimes (i (length objects))
      (setf (aref objects i) (make-array 0 :adjustable T :fill-pointer T)))
    (setf (objects container) objects)))

(defgeneric layer-index (unit))

(defmethod layer-index ((_ unit)) 0)

(defmethod layer-index ((_ layered-container)) T)

(defmethod enter ((unit unit) (container layered-container))
  (let ((layer (if (eql T (layer-index unit))
                   (layer-count container)
                   (+ (layer-index unit)
                      (floor (layer-count container) 2)))))
    (vector-push-extend unit (aref (objects container) layer))))

(defmethod leave ((unit unit) (container layered-container))
  (let ((layer (if (eql T (layer-index unit))
                   (layer-count container)
                   (+ (layer-index unit)
                      (floor (layer-count container) 2)))))
    (array-utils:vector-pop-position*
     (aref (objects container) layer)
     (position unit (aref (objects container) layer)))))

(defmethod paint ((container layered-container) target)
  (let ((layers (objects container)))
    (dotimes (i (1- (length layers)))
      (let ((*current-layer* i))
        (loop for unit across (aref layers i)
              do (paint unit target))
        (loop for unit across (aref layers (1- (length layers)))
              do (paint unit target))))))

(defmacro do-layered-container ((entity container &optional result) &body body)
  (let ((layer (gensym "LAYER"))
        (loop (gensym "LOOP"))
        (finish (gensym "FINISH"))
        (idx (gensym "IDX")))
    ;; NOTE: We manually do a LOOP ACROSS to avoid the implicit block generation.
    `(loop with ,idx = 0
           with ,entity = NIL
           for ,layer across (objects ,container)
           do (tagbody
                 ,loop
                 (when (<= (length ,layer) ,idx)
                   (go ,finish))
                 (setf ,entity (aref ,layer ,idx))
                 (progn ,@body)
                 (incf ,idx)
                 (go ,loop)
                 ,finish
                 (setf ,idx 0))
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
