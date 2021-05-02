(in-package #:org.shirakumo.fraf.kandria.quest)

(defvar *storylines* ())

(defclass storyline (describable scope)
  ((quests :initform (make-hash-table :test 'eql) :reader quests)
   (name :initform 'storyline)
   (title :initform "storyline")
   (known-quests :initform () :accessor known-quests)))

(defmethod try ((storyline storyline))
  (loop for quest in (known-quests storyline)
        while (active-p quest)
        do (try quest)))

(defmethod find-quest (name (storyline storyline) &optional (error T))
  (or (gethash name (quests storyline))
      (when error (error "No quest named ~s found." name))))

(defmethod (setf find-quest) (quest name (storyline storyline))
  (setf (gethash name (quests storyline)) quest))

(defmethod find-named (name (storyline storyline) &optional (error T))
  (find-quest name storyline error))

(defmethod find-trigger (name (storyline storyline) &optional (error T))
  (or (loop for quest in (known-quests storyline)
            thereis (find-trigger name quest NIL))
      (when error (error "No trigger named ~s found." name))))

(defmethod find-task (name (storyline storyline) &optional (error T))
  (or (loop for quest in (known-quests storyline)
            thereis (find-task name quest NIL))
      (when error (error "No task named ~s found." name))))

(defmethod storyline ((name symbol))
  (find name *storylines* :key #'name))

(defmethod (setf storyline) ((storyline storyline) (name symbol))
  (setf *storylines* (list* storyline (remove name *storylines* :key #'name)))
  storyline)

(defmacro define-storyline (name &body initargs)
  (form-fiddle:with-body-options (body initargs bindings class) initargs
    `(let ((storyline (or (storyline ',name)
                          (setf (storyline ',name) (make-instance ',(or class 'storyline) :name ',name)))))
       (reinitialize-instance storyline :bindings ',bindings
                              ,@initargs)
       ,@(loop for (quest . options) in body
               collect `(define-quest (,name ,quest)
                          ,@options))
       ',name)))
