(in-package #:org.shirakumo.fraf.kandria.quest)

(defclass task (describable scope)
  ((status :initarg :status :initform :inactive :accessor status)
   (quest :initarg :quest :accessor quest)
   (causes :initarg :causes :initform () :accessor causes)
   (triggers :initform (make-hash-table :test 'eql) :accessor triggers)
   (on-complete :initarg :on-complete :initform () :accessor on-complete)
   (on-activate :initarg :on-activate :initform () :accessor on-activate)
   (invariant :initform (constantly T) :accessor invariant)
   (condition :initform (constantly NIL) :accessor condition))
  (:default-initargs :status :inactive))

(defmethod shared-initialize :after ((task task) slots &key invariant condition)
  (when invariant
    (setf (invariant task) (compile-form task invariant)))
  (when condition
    (setf (condition task) (compile-form task condition))))

(defmethod print-object ((task task) stream)
  (print-unreadable-object (task stream :type T)
    (format stream "~s ~s" (title task) (status task))))

(defmethod class-for ((storyline (eql 'task))) 'task)

(defmethod reset progn ((task task) &key (reset-vars T))
  (setf (status task) :inactive)
  (loop for trigger being the hash-values of (triggers task)
        do (reset trigger :reset-vars reset-vars)))

(defmethod parent ((task task))
  (quest task))

(defmethod find-trigger (name (task task) &optional (error T))
  (or (gethash name (triggers task))
      (when error (error "No trigger named ~s found." name))))

(defmethod (setf find-trigger) (trigger name (task task))
  (setf (gethash name (triggers task)) trigger))

(defmethod find-named (name (task task) &optional (error T))
  (or (find-trigger name task NIL)
      (find-task name (quest task) NIL)
      (find-quest name (storyline (quest task)) error)))

(defun sort-tasks (tasks)
  (sort tasks #'text< :key #'title))

(defmethod active-p ((task task))
  (eql (status task) :unresolved))

(defmethod (setf status) :before (status (task task))
  (ecase status
    (:inactive)
    (:unresolved)
    (:failed)
    (:complete)
    (:obsolete)))

(defmethod (setf status) :after (status (task task))
  (let ((active (active-tasks (quest task))))
    (setf (active-tasks (quest task))
          (cond ((not (eql status :unresolved))
                 (remove task active))
                ((find task active)
                 active)
                (T
                 (sort-tasks (list* task active)))))))

(defmethod make-assembly ((task task))
  (make-assembly (quest task)))

(defmethod compile-form ((task task) form)
  (compile NIL `(lambda ()
                  (let* ((task ,task)
                         (quest (quest task))
                         (triggers (triggers task))
                         (all-complete (loop for trigger being the hash-values of triggers
                                             always (eql :complete (status trigger)))))
                    (declare (ignorable quest all-complete))
                    ,form))))

(defun required-for-completion (task cause)
  ;; TODO: implement this
  T)

(defmethod activate ((task task))
  (case (status task)
    ((:inactive :unresolved)
     (v:info :kandria.quest "Activating ~a" task)
     (setf (status task) :unresolved)
     (dolist (cause (causes task))
       (let ((cause (find-task cause (quest task))))
         (when (and (active-p cause)
                    (required-for-completion task cause))
           (setf (status task) :obsolete))))
     (etypecase (on-activate task)
       (list
        (dolist (thing (on-activate task))
          (activate (find-named thing task))))
       (T
        (loop for thing being the hash-values of (triggers task)
              do (activate thing))))))
  task)

(defmethod deactivate ((task task))
  (case (status task)
    ((:inactive :complete :obsolete :failed))
    (:unresolved
     (v:info :kandria.quest "Deactivating ~a" task)
     (setf (status task) :inactive)
     (loop for thing being the hash-values of (triggers task)
           do (deactivate thing))
     (try (quest task))))
  task)

(defmethod complete ((task task))
  (ecase (status task)
    (:inactive
     (error "Cannot complete inactive task."))
    ((:complete :obsolete))
    (:failed
     (error "Cannot complete failed task."))
    (:unresolved
     (v:info :kandria.quest "Completing ~a" task)
     (setf (status task) :complete)
     (loop for thing being the hash-values of (triggers task)
           do (deactivate thing))
     (dolist (effect (on-complete task))
       (activate (find-named effect task)))
     (when (null (active-tasks (quest task)))
       (complete (quest task)))))
  task)

(defmethod fail ((task task))
  (ecase (status task)
    (:inactive
     (setf (status task) :failed))
    ((:complete :obsolete)
     (error "Cannot fail completed/obsolete task."))
    (:failed)
    (:unresolved
     (v:info :kandria.quest "Failing ~a" task)
     (setf (status task) :failed)
     (loop for thing being the hash-values of (triggers task)
           do (deactivate thing))
     (when (null (active-tasks (quest task)))
       (fail (quest task)))))
  task)

(defmethod try ((task task))
  (loop for trigger being the hash-values of (triggers task)
        do (when (active-p trigger) (try trigger)))
  (cond ((not (funcall (invariant task)))
         (fail task))
        ((funcall (condition task))
         (complete task))))

(defmacro define-task ((storyline quest name) &body initargs)
  (form-fiddle:with-body-options (body initargs (class (class-for 'task)) variables condition invariant on-activate on-complete) initargs
    `(let* ((quest (or (find-quest ',quest (or (storyline ',storyline)
                                               (error "No such storyline ~s" ',storyline)))))
            (task (or (find-task ',name quest NIL)
                      (setf (find-task ',name quest) (make-instance ',class :name ',name :quest quest ,@initargs)))))
       (reinitialize-instance task :condition ',(or condition 'NIL)
                                   :invariant ',(or invariant 'T)
                                   :on-activate ',on-activate
                                   :on-complete ',on-complete
                                   :variables ',variables
                                   ,@initargs)
       ,@(loop for (type trigger . options) in body
               collect (ecase type
                         (:action
                          `(define-action (,storyline ,quest ,name ,trigger)
                             ,@options))
                         (:interaction
                          `(define-interaction (,storyline ,quest ,name ,trigger)
                             ,@options))))
       ',name)))
