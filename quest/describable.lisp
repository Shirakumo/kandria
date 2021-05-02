(in-package #:org.shirakumo.fraf.kandria.quest)

(defclass describable ()
  ((name :initarg :name :initform (error "NAME required") :accessor name)
   (title :initarg :title :initform (error "TITLE required") :accessor title)
   (description :initarg :description :initform "" :accessor description)))

(defmethod print-object ((describable describable) stream)
  (print-unreadable-object (describable stream :type T)
    (format stream "~s" (title describable))))

(defgeneric active-p (thing))
(defgeneric activate (thing))
(defgeneric complete (thing))
(defgeneric fail (thing))
(defgeneric try (task))
(defgeneric find-named (name thing &optional error))
