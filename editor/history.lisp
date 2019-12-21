(in-package #:org.shirakumo.fraf.leaf)

(defclass history ()
  ())

(defgeneric commit (action history))
(defgeneric actions (history))

(defclass action ()
  ((description :initarg :description :initform "<unknown change>" :accessor description)))

(defgeneric redo (action region))
(defgeneric undo (action region))

(defclass linear-history (history)
  ((actions :initform (make-array 0 :adjustable T :fill-pointer T) :accessor actions)
   (history-pointer :initform 0 :accessor history-pointer)))

(defmethod commit ((action action) (history linear-history))
  (setf (fill-pointer (actions history)) (history-pointer history))
  (vector-push-extend action (actions history))
  (incf (history-pointer history)))

(defmethod redo ((history linear-history) region)
  (when (< (history-pointer history) (fill-pointer (actions history)))
    (redo (aref (actions history) (history-pointer history)) region)
    (incf (history-pointer history))))

(defmethod undo ((history linear-history) region)
  (when (< 0 (history-pointer history))
    (decf (history-pointer history))
    (undo (aref (actions history) (history-pointer history)) region)))

(defmethod clear ((history linear-history))
  (loop for i from 0 below (length (actions history))
        do (setf (aref (actions history) i) NIL))
  (setf (fill-pointer (actions history)) 0)
  (setf (history-pointer history) 0))

(defclass closure-action (action)
  ((redo :initarg :redo)
   (undo :initarg :undo)))

(defmethod redo ((action closure-action) region)
  (funcall (slot-value action 'redo) region))

(defmethod undo ((action closure-action) region)
  (funcall (slot-value action 'undo) region))

(defmacro capture-action (place value)
  (let ((previous (gensym "PREVIOUS-VALUE"))
        (ignore (gensym "IGNORED")))
    `(let ((,previous ,place))
       (make-instance 'closure-action
                      :redo (lambda (,ignore)
                              (declare (ignore ,ignore))
                              (setf ,place ,value))
                      :undo (lambda (,ignore)
                              (declare (ignore ,ignore))
                              (setf ,place ,previous))))))
