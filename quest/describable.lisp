(in-package #:org.shirakumo.fraf.kandria.quest)

(defclass describable ()
  ((name :initarg :name :accessor name)
   (title :initarg :title :accessor title)
   (description :initarg :description :accessor description))
  (:default-initargs
   :name (error "NAME required")
   :title (error "TITLE required")
   :description ""))

(defmethod print-object ((describable describable) stream)
  (print-unreadable-object (describable stream :type T)
    (format stream "~s" (title describable))))

(defgeneric active-p (thing))
(defgeneric activate (thing))
(defgeneric complete (thing))
(defgeneric fail (thing))
(defgeneric try (task))
(defgeneric find-named (name thing &optional error))
