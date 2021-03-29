(in-package #:org.shirakumo.fraf.kandria.quest)

(defclass scope ()
  ((initial-bindings :initform () :initarg :bindings :accessor initial-bindings)
   (bindings :initform () :accessor bindings)))

(defmethod initialize-instance :after ((scope scope) &key)
  (reset scope))

(defgeneric reset (scope)
  (:method-combination progn))
(defgeneric parent (scope))
(defgeneric binding (name scope))
(defgeneric var (name scope &optional default))
(defgeneric (setf var) (value name scope))

(defmethod reset progn ((scope scope))
  (setf (bindings scope) (loop for binding in (initial-bindings scope)
                               collect (etypecase binding
                                         (cons (cons (first binding) (second binding)))
                                         (symbol (cons binding NIL))))))

(defmethod parent ((scope scope)) NIL)

(defmethod merge-bindings ((scope scope) bindings)
  (let ((existing (bindings scope)))
    (loop for (name . value) in bindings
          for prev = (assoc name (bindings scope))
          do (if prev
                 (setf (cdr prev) value)
                 (push (cons name value) existing)))
    (setf (bindings scope) existing)))

(defmethod binding (name (scope scope))
  (or (assoc name (bindings scope))
      (when (parent scope)
        (binding name (parent scope)))))

(defmethod var (name (scope scope) &optional default)
  (let ((binding (binding name scope)))
    (if binding
        (values (cdr binding) T)
        (values default NIL))))

(defmethod (setf var) (value name (scope scope))
  (let ((binding (binding name scope)))
    (cond (binding
           (setf (cdr binding) value))
          (T
           (v:warn :kandria.quest "Creating new binding for variable~%  ~s~%in~%  ~s" name scope)
           (push (cons name value) (bindings scope))
           value))))

(defmethod list-variables ((scope scope))
  (let ((vars (when (parent scope) (list-variables (parent scope)))))
    (dolist (binding (bindings scope) vars)
      (pushnew (car binding) vars))))

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

(defclass storyline (scope)
  ((quests :initform (make-hash-table :test 'eql) :reader quests)
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

(defclass quest (describable scope)
  ((status :initarg :status :initform :inactive :accessor status)
   (author :initarg :author :accessor author)
   (storyline :initarg :storyline :reader storyline)
   (tasks :initform (make-hash-table :test 'eq) :reader tasks)
   (on-activate :initarg :on-activate :accessor on-activate)
   (active-tasks :initform () :accessor active-tasks)))

(defmethod initialize-instance :after ((quest quest) &key storyline name)
  (setf (find-quest name storyline) quest))

(defmethod print-object ((quest quest) stream)
  (print-unreadable-object (quest stream :type T)
    (format stream "~s ~s" (title quest) (status quest))))

(defmethod reset progn ((quest quest))
  (setf (status quest) :inactive))

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
         (if (eql :active status)
             (list* quest (known-quests (storyline quest)))
             (known-quests (storyline quest))))))

(defmethod activate ((quest quest))
  (case (status quest)
    ((:inactive :active)
     (v:info :kandria.quest "Activating ~a" quest)
     (setf (status quest) :active)
     (loop for thing in (on-activate quest)
           do (activate (find-named thing quest)))))
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

(defclass task (describable scope)
  ((status :initarg :status :initform :inactive :accessor status)
   (quest :initarg :quest :accessor quest)
   (causes :initarg :causes :initform () :accessor causes)
   (triggers :initform (make-hash-table :test 'eq) :accessor triggers)
   (on-complete :initarg :on-complete :initform () :accessor on-complete)
   (on-activate :initarg :on-activate :initform () :accessor on-activate)
   (invariant :accessor invariant)
   (condition :accessor condition))
  (:default-initargs :status :inactive))

(defmethod initialize-instance :after ((task task) &key quest name invariant condition)
  (setf (invariant task) (compile-form task invariant))
  (setf (condition task) (compile-form task condition))
  (setf (find-task name quest) task))

(defmethod print-object ((task task) stream)
  (print-unreadable-object (task stream :type T)
    (format stream "~s ~s" (title task) (status task))))

(defmethod reset progn ((task task))
  (setf (status task) :inactive))

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
  (sort tasks #'string< :key #'title))

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
  (setf (active-tasks (quest task))
        (if (eql status :unresolved)
            (sort-tasks (list* task (active-tasks (quest task))))
            (remove task (active-tasks (quest task))))))

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
     (dolist (thing (on-activate task))
       (activate (find-named thing task)))))
  task)

(defmethod deactivate ((task task))
  (unless (eql (status task) :inactive)
    (v:info :kandria.quest "Deactivating ~a" task)
    (setf (status task) :unresolved)
    (loop for thing being the hash-values of (triggers task)
          do (deactivate thing))
    (try (quest task)))
  task)

(defmethod complete ((task task))
  (unless (active-p task)
    (error "Cannot complete done task."))
  (v:info :kandria.quest "Completing ~a" task)
  (setf (status task) :complete)
  (loop for thing being the hash-values of (triggers task)
        do (deactivate thing))
  (dolist (effect (on-complete task))
    (activate (find-named effect task)))
  (when (null (active-tasks (quest task)))
    (complete (quest task)))
  task)

(defmethod fail ((task task))
  (unless (active-p task)
    (error "Cannot fail done task."))
  (v:info :kandria.quest "Failing ~a" task)
  (setf (status task) :failed)
  (loop for thing being the hash-values of (triggers task)
        do (deactivate thing))
  (when (null (active-tasks (quest task)))
    (fail (quest task)))
  task)

(defmethod try ((task task))
  (loop for trigger being the hash-values of (triggers task)
        do (when (active-p trigger) (try trigger)))
  (cond ((not (funcall (invariant task)))
         (fail task))
        ((funcall (condition task))
         (unless (eql :complete (status task))
           (complete task)))))

(defclass trigger ()
  ((name :initarg :name :initform (error "NAME required.") :reader name)
   (task :initarg :task :initform (error "TASK required.") :reader task)
   (status :initarg :status :initform :inactive :accessor status)))

(defmethod print-object ((trigger trigger) stream)
  (print-unreadable-object (trigger stream :type T)
    (format stream "~s ~a" (name trigger) (status trigger))))

(defmethod initialize-instance :after ((trigger trigger) &key task name)
  (when task
    (setf (find-trigger name task) trigger)))

(defmethod find-named (name (trigger trigger) &optional (error T))
  (find-named name (task trigger) error))

(defmethod reset progn ((trigger trigger))
  (setf (status trigger) :inactive))

(defmethod active-p ((trigger trigger))
  (eql :active (status trigger)))

(defmethod activate :around ((trigger trigger))
  (case (status trigger)
    (:inactive
     (v:info :kandria.quest "Activating ~a" trigger)
     (call-next-method))))

(defmethod activate :after ((trigger trigger))
  (setf (status trigger) :active))

(defmethod deactivate :around ((trigger trigger))
  (case (status trigger)
    (:active
     (v:info :kandria.quest "Deactivating ~a" trigger)
     (call-next-method))))

(defmethod deactivate :after ((trigger trigger))
  (setf (status trigger) :inactive))

(defmethod complete :before ((trigger trigger))
  (v:info :kandria.quest "Completing ~a" trigger))

(defmethod complete :after ((trigger trigger))
  (setf (status trigger) :complete))

(defclass action (trigger)
  ((on-activate :initform (constantly T) :accessor on-activate)
   (on-deactivate :initform (constantly T) :accessor on-deactivate)))

(defmethod initialize-instance :after ((action action) &key task on-activate on-deactivate)
  (when on-activate
    (setf (on-activate action) (compile-form task on-activate)))
  (when on-deactivate
    (setf (on-deactivate action) (compile-form task on-deactivate))))

(defmethod activate ((action action))
  (funcall (on-activate action))
  (setf (status action) :complete))

(defmethod deactivate ((action action))
  (funcall (on-deactivate action)))

(defmethod try ((action action)))

(defclass interaction (trigger scope)
  ((interactable :initarg :interactable :reader interactable)
   (title :initarg :title :initform "<unknown>" :accessor title)
   (dialogue :accessor dialogue)))

(defmethod initialize-instance :after ((interaction interaction) &key dialogue)
  (setf (dialogue interaction) (dialogue:compile* dialogue (make-assembly interaction))))

(defmethod make-assembly ((interaction interaction))
  (make-assembly (task interaction)))

(defmethod parent ((interaction interaction))
  (task interaction))

(defmethod try ((interaction interaction)))
(defmethod activate ((interaction interaction)))
(defmethod deactivate ((interaction interaction)))
(defmethod complete ((interaction interaction)))
