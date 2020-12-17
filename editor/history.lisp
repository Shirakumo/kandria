(in-package #:org.shirakumo.fraf.kandria)

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

(defmacro make-action (redo undo)
  (let ((redog (gensym "REDO"))
        (undog (gensym "UNDO")))
    `(flet ((,redog (_)
              (declare (ignore _))
              ,redo)
            (,undog (_)
              (declare (ignore _))
              ,undo))
       (make-instance 'closure-action :redo #',redog :undo #',undog))))

(defmacro capture-action (place value)
  (let ((previous (gensym "PREVIOUS-VALUE")))
    `(let ((,previous ,place))
       (make-action
        (setf ,place ,value)
        (setf ,place ,previous)))))

(defmacro with-commit ((tool) (&body redo) (&body undo))
  `(commit (make-action (progn ,@redo) (progn ,@undo)) ,tool))
