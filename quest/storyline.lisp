(in-package #:org.shirakumo.fraf.kandria.quest)

(defvar *storylines* ())

(defclass storyline (describable scope)
  ((name :initform 'storyline)
   (title :initform "storyline")
   (quests :initform (make-hash-table :test 'eql) :reader quests)
   (known-quests :initform () :accessor known-quests)
   (on-activate :initarg :on-activate :initform () :accessor on-activate)))

(defmethod class-for ((storyline (eql 'storyline))) 'storyline)

(defmethod reset progn ((storyline storyline))
  (loop for quest being the hash-values of (quests storyline)
        do (reset quest)))

(defmethod activate ((storyline storyline))
  (etypecase (on-activate storyline)
    (list
     (dolist (thing (on-activate storyline))
       (activate (find-named thing storyline))))
    (T
     (loop for thing being the hash-values of (tasks storyline)
           do (activate thing)))))

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
  (form-fiddle:with-body-options (body initargs variables on-activate (class (class-for 'storyline))) initargs
    `(let ((storyline (or (storyline ',name)
                          (setf (storyline ',name) (make-instance ',class :name ',name ,@initargs)))))
       (reinitialize-instance storyline :variables ',variables
                                        :on-activate ',on-activate
                              ,@initargs)
       ,@(loop for (quest . options) in body
               collect `(define-quest (,name ,quest)
                          ,@options))
       ',name)))

(defun print-storyline (storyline &optional (stream *standard-output*))
  (let ((storyline (etypecase storyline
                     (symbol (storyline storyline))
                     (storyline storyline))))
    (flet ((out (f &rest a) (format stream "~&~?~%" f a)))
      (out "STORYLINE ~a" (name storyline))
      (loop for quest being the hash-values of (quests storyline)
            do (out " => QUEST ~a~50t[~a]" (name quest) (status quest))
               (loop for task being the hash-values of (tasks quest)
                     do (out "  -> TASK ~a~50t[~a]" (name task) (status task))
                        (loop for trigger being the hash-values of (triggers task)
                              do (out "    > ~a ~a~50t[~a]" (type-of trigger) (name trigger) (status trigger))))))))
