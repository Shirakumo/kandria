(in-package #:org.shirakumo.fraf.kandria.quest)

(defclass quest (describable scope)
  ((status :initarg :status :initform :inactive :accessor status)
   (author :initarg :author :accessor author)
   (storyline :initarg :storyline :reader storyline)
   (tasks :initform (make-hash-table :test 'eql) :reader tasks)
   (on-activate :initarg :on-activate :accessor on-activate)
   (active-tasks :initform () :accessor active-tasks)))

(defmethod print-object ((quest quest) stream)
  (print-unreadable-object (quest stream :type T)
    (format stream "~s ~s" (title quest) (status quest))))

(defmethod class-for ((storyline (eql 'quest))) 'quest)

(defmethod reset progn ((quest quest) &key (reset-vars T))
  (setf (status quest) :inactive)
  (loop for task being the hash-values of (tasks quest)
        do (reset task :reset-vars reset-vars)))

(defmethod parent ((quest quest))
  (storyline quest))

(defmethod make-assembly ((quest quest))
  (make-instance 'dialogue:assembly))

(defmethod compile-form ((quest quest) form)
  (dialogue::compile-form (make-assembly quest) form))

(defmethod find-task (name (quest quest) &optional (error T))
  (or (gethash name (tasks quest))
      (when error (error "No task named ~s found." name))))

(defmethod (setf find-task) (task name (quest quest))
  (setf (gethash name (tasks quest)) task))

(defmethod find-named (name (quest quest) &optional (error T))
  (or (find-task name quest NIL)
      (find-quest name (storyline quest) error)))

(defmethod find-trigger (name (quest quest) &optional (error T))
  (or (loop for task in (active-tasks quest)
            thereis (find-trigger name task NIL))
      (when error (error "No trigger named ~s found." name))))

(defun sort-quests (quests)
  (sort quests (lambda (a b)
                 (if (eql (status a) (status b))
                     (string< (title a) (title b))
                     (eql :active (status a))))))

(defmethod active-p ((quest quest))
  (eql :active (status quest)))

(defmethod (setf status) :before (status (quest quest))
  (ecase status
    (:inactive)
    (:active)
    (:complete)
    (:failed)))

(defmethod (setf status) :after (status (quest quest))
  (setf (known-quests (storyline quest))
        (sort-quests
         (if (and (eql :active status) (not (find quest (known-quests (storyline quest)))))
             (list* quest (known-quests (storyline quest)))
             (known-quests (storyline quest))))))

(defmethod activate ((quest quest))
  (case (status quest)
    ((:inactive :active)
     (v:info :kandria.quest "Activating ~a" quest)
     (setf (status quest) :active)
     (etypecase (on-activate quest)
       (list
        (dolist (thing (on-activate quest))
          (activate (find-named thing quest))))
       (T
        (loop for thing being the hash-values of (tasks quest)
              do (activate thing))))))
  quest)

(defmethod complete ((quest quest))
  (v:info :kandria.quest "Completing ~a" quest)
  (dolist (task (active-tasks quest))
    (when (eql :unresolved (status task))
      (complete task)))
  (setf (status quest) :complete)
  (setf (active-tasks quest) ())
  quest)

(defmethod fail ((quest quest))
  (v:info :kandria.quest "Failing ~a" quest)
  (dolist (task (active-tasks quest))
    (when (eql :unresolved (status task))
      (fail task)))
  (setf (status quest) :failed)
  (setf (active-tasks quest) ())
  quest)

(defmethod try ((quest quest))
  (dolist (task (active-tasks quest))
    (try task)))

(defmacro define-quest ((storyline name) &body initargs)
  (form-fiddle:with-body-options (body initargs on-activate variables (class (class-for 'quest))) initargs
    `(let* ((story (or (storyline ',storyline)
                       (error "No such storyline ~s" ',storyline)))
            (quest (or (find-quest ',name story NIL)
                       (setf (find-quest ',name story) (make-instance ',class :name ',name :storyline story ,@initargs))))
            (*default-pathname-defaults* ,(or *compile-file-pathname* *load-pathname* *default-pathname-defaults*)))
       (reinitialize-instance quest :on-activate ',on-activate
                                    :variables ',variables
                                    ,@initargs)
       ,@(loop for (task . options) in body
               collect `(define-task (,storyline ,name ,task)
                          ,@options))
       ',name)))
