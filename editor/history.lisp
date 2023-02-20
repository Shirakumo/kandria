(in-package #:org.shirakumo.fraf.kandria)

(defclass history ()
  ())

(defgeneric commit (action history))
(defgeneric actions (history))

(defclass action ()
  ((description :initarg :description :initform "<unknown change>" :accessor description)
   (index :initform 0 :accessor index)))

(defmethod print-object ((action action) stream)
  (print-unreadable-object (action stream :type T)
    (format stream "~a ~a" (index action) (description action))))

(defgeneric redo (action region))
(defgeneric undo (action region))

(defclass linear-history (history)
  ((actions :initform (make-array 0 :adjustable T :fill-pointer T) :accessor actions)
   (history-pointer :initform 0 :accessor history-pointer)))

(defmethod commit ((action action) (history linear-history))
  (setf (index action) (history-pointer history))
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

(defmethod undo ((action action) (history linear-history))
  (loop until (or (= 0 (history-pointer history))
                  (<= (history-pointer history) (index action)))
        do (decf (history-pointer history))
           (undo (aref (actions history) (history-pointer history)) T)))

(defmethod redo ((action action) (history linear-history))
  (loop until (or (< (index action) (history-pointer history))
                  (null (aref (actions history) (history-pointer history))))
        do (redo (aref (actions history) (history-pointer history)) T)
           (incf (history-pointer history))))

(defmethod clear ((history linear-history))
  (loop for i from 0 below (length (actions history))
        do (setf (aref (actions history) i) NIL))
  (setf (fill-pointer (actions history)) 0)
  (setf (history-pointer history) 0))

(defclass closure-action (action)
  ((redo :initarg :redo)
   (undo :initarg :undo)))

(defmethod redo ((action closure-action) (region (eql T)))
  (funcall (slot-value action 'redo)))

(defmethod undo ((action closure-action) (region (eql T)))
  (funcall (slot-value action 'undo)))

(defmacro make-action (redo undo &rest initargs)
  (let ((redog (gensym "REDO"))
        (undog (gensym "UNDO")))
    `(flet ((,redog ()
              ,redo)
            (,undog ()
              ,undo))
       (make-instance 'closure-action :redo #',redog :undo #',undog ,@initargs))))

(defmacro capture-action (place value &rest initargs)
  (let ((previous (gensym "PREVIOUS-VALUE")))
    `(let ((,previous ,place))
       (make-action
        (setf ,place ,value)
        (setf ,place ,previous)
        ,@initargs))))

(defmacro with-commit ((tool &optional description &rest format-args) (&body redo) (&body undo))
  `(commit (make-action (progn ,@redo) (progn ,@undo)
                        :description ,(if description
                                          `(format NIL ,description ,@format-args)
                                          "<unknown change>"))
           ,tool))

(defclass history-button (alloy:direct-value-component alloy:button)
  ((history :initarg :history :accessor history)))

(presentations:define-realization (ui history-button)
  ((:number simple:text)
   (alloy:extent 0 0 30 (alloy:ph))
   (princ-to-string (index alloy:value))
   :size (alloy:un 12)
   :pattern colors:white
   :halign :start
   :valign :middle)
  ((:label simple:text)
   (alloy:margins 30 0 0 0)
   (description alloy:value)
   :size (alloy:un 12)
   :pattern colors:white
   :halign :start))

(presentations:define-update (ui history-button)
  (:number)
  (:label
   :text (description alloy:value)
   :pattern (if (<= (history-pointer (history alloy:renderable))
                    (index alloy:value))
                colors:gray
                colors:white)))

(defmethod alloy:activate ((button history-button))
  (if (<= (history-pointer (history button)) (index (alloy:value button)))
      (redo (alloy:value button) (history button))
      (undo (alloy:value button) (history button)))
  (create-marker (find-panel 'editor)))

(defclass history-dialog (alloy:dialog)
  ()
  (:default-initargs
   :title "History"
   :extent (alloy:size 400 500)))

(defmethod alloy:reject ((dialog history-dialog)))
(defmethod alloy:accept ((dialog history-dialog)))

(defmethod initialize-instance :after ((panel history-dialog) &key history)
  (let* ((layout (make-instance 'alloy:grid-layout :col-sizes '(T) :row-sizes '(T 30) :layout-parent panel))
         (focus (make-instance 'alloy:focus-list :focus-parent panel))
         (entitylist (make-instance 'entitylist)))
    (loop for action across (actions history)
          do (alloy:enter (make-instance 'history-button :history history :value action) entitylist))
    (make-instance 'alloy:scroll-view :scroll :y :focus entitylist :layout entitylist
                                      :layout-parent layout :focus-parent focus)))
