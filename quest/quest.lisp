(in-package #:org.shirakumo.fraf.kandria.quest)

(defgeneric active-p (thing))
(defgeneric activate (thing))
(defgeneric complete (thing))
(defgeneric try (task))

(defclass storyline ()
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

(defun make-storyline (quests &key (quest-type 'quest))
  (let ((storyline (make-instance 'storyline)))
    (dolist (quest quests storyline)
      (let ((quest (make-instance quest-type
                                  :name (graph:name quest)
                                  :quest quest
                                  :storyline storyline)))
        (setf (find-quest (name quest) storyline) quest)))))

(defclass quest (describable)
  ((status :initarg :status :accessor status)
   (storyline :initarg :storyline :reader storyline)
   (effects :reader effects)
   (tasks :initform (make-hash-table :test 'eq) :reader tasks)
   (active-tasks :initform () :accessor active-tasks))
  (:default-initargs :status :inactive
                     :title NIL))

(defmethod initialize-instance :after ((self quest) &key quest storyline)
  (check-type storyline storyline)
  (multiple-value-bind (effects tasks) (transform quest self)
    (setf (slot-value self 'effects) effects)
    (setf (slot-value self 'tasks) tasks)))

(defmethod print-object ((quest quest) stream)
  (print-unreadable-object (quest stream :type T)
    (format stream "~s ~s" (title quest) (status quest))))

(defmethod make-assembly ((quest quest))
  (make-instance 'dialogue:assembly))

(defmethod class-for ((quest quest) class)
  class)

(defmethod compile-form ((quest quest) form)
  (dialogue::compile-form (make-assembly quest) form))

(defmethod find-task (name (quest quest) &optional (error T))
  (or (gethash name (tasks quest))
      (when error (error "No task named ~s found." name))))

(defmethod (setf find-task) (task name (quest quest))
  (setf (gethash name (tasks quest)) task))

(defun sort-quests (quests)
  (sort quests (lambda (a b)
                 (if (eql (status a) (status b))
                     (string< (title a) (title b))
                     (eql :active (status a))))))

(defmethod active-p ((quest quest))
  (eql :active (status quest)))

(defmethod (setf status) :before (status (quest quest))
  (ecase status
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
     (mapcar #'activate (effects quest))))
  quest)

(defmethod complete ((quest quest))
  (v:info :kandria.quest "Completing ~a" quest)
  (setf (status quest) :complete)
  (setf (active-tasks quest) ())
  quest)

(defmethod try ((quest quest))
  (dolist (task (active-tasks quest))
    (try task)))

(defclass end ()
  ((quest :initarg :quest :accessor quest)))

(defmethod activate ((end end))
  (complete (quest end)))

(defclass task (describable)
  ((status :initarg :status :accessor status)
   (quest :initarg :quest :accessor quest)
   (causes :initarg :causes :accessor causes)
   (effects :initarg :effects :accessor effects)
   (triggers :initarg :triggers :accessor triggers)
   (invariant :initarg :invariant :accessor invariant)
   (condition :initarg :condition :accessor condition))
  (:default-initargs :status :inactive))

(defmethod print-object ((task task) stream)
  (print-unreadable-object (task stream :type T)
    (format stream "~s ~s" (title task) (status task))))

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

(defmethod class-for ((task task) class) class)

(defmethod compile-form ((task task) form)
  (compile NIL `(lambda ()
                  (let* ((task ,task)
                         (quest (quest task))
                         (triggers (triggers task))
                         (all-complete (every (lambda (trig) (eql :complete (status trig)))
                                              triggers)))
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
       (when (and (active-p cause)
                  (required-for-completion task cause))
         (setf (status task) :obsolete)))
     (dolist (trigger (triggers task))
       (activate trigger))))
  task)

(defmethod deactivate ((task task))
  (unless (eql (status task) :inactive)
    (v:info :kandria.quest "Deactivating ~a" task)
    (setf (status task) :unresolved)
    (dolist (trigger (triggers task))
      (deactivate trigger)))
  task)

(defmethod complete ((task task))
  (unless (active-p task)
    (error "Cannot complete done task."))
  (v:info :kandria.quest "Completing ~a" task)
  (setf (status task) :complete)
  (dolist (trigger (triggers task))
    (deactivate trigger))
  (dolist (effect (effects task))
    (activate effect))
  task)

(defmethod fail ((task task))
  (unless (active-p task)
    (error "Cannot fail done task."))
  (v:info :kandria.quest "Failing ~a" task)
  (setf (status task) :failed)
  (dolist (trigger (triggers task))
    (deactivate trigger))
  task)

(defmethod try ((task task))
  (cond ((not (funcall (invariant task)))
         (fail task))
        ((funcall (condition task))
         (complete task))))

(defclass trigger ()
  ((status :initarg :status :initform :inactive :accessor status)))

(defmethod activate :after ((trigger trigger))
  (setf (status trigger) :active))

(defmethod deactivate :after ((trigger trigger))
  (setf (status trigger) :inactive))

(defclass action (trigger)
  ((on-activate :initarg :on-activate :reader on-activate)
   (on-deactivate :initarg :on-deactivate :reader on-deactivate)))

(defmethod activate ((trigger trigger))
  (funcall (on-activate trigger))
  (setf (status trigger) :complete))

(defmethod deactivate ((trigger trigger))
  (funcall (on-deactivate trigger)))

(defclass interaction (trigger)
  ((interactable :initarg :interactable :reader interactable)
   (dialogue :initarg :dialogue :initform :inactive :reader dialogue)))

(defmethod transform ((node graph:quest) quest)
  (let ((cache (make-hash-table :test 'eq)))
    (%transform node cache quest)
    (values (loop for effect in (graph:effects node)
                  collect (gethash effect cache))
            (loop with tasks = (make-hash-table :test 'eq)
                  for task being the hash-values of cache
                  when (typep task 'task)
                  do (setf (gethash (name task) tasks) task)
                  finally (return tasks)))))

(defmethod %transform :around (thing cache parent)
  (or (gethash thing cache)
      (setf (gethash thing cache)
            (call-next-method))))

(defmethod %transform ((node graph:quest) cache (quest quest))
  (setf (gethash node cache) quest)
  (setf (description quest) (description node))
  (setf (title quest) (title node))
  (loop for task in (graph:effects node)
        do (%transform task cache quest))
  quest)

(defmethod %transform ((task graph:task) cache (quest quest))
  (let ((instance (make-instance (class-for quest 'task)
                                 :quest quest
                                 :name (name task)
                                 :title (graph:title task)
                                 :description (graph:description task)
                                 :causes (loop for cause in (graph:causes task)
                                               when (typep cause 'graph:task)
                                               collect (%transform cause cache quest)))))
    (flet ((%transform (thing)
             (%transform thing cache instance)))
      (setf (effects instance) (mapcar #'%transform (graph:effects task)))
      (setf (triggers instance) (mapcar #'%transform (graph:triggers task)))
      (setf (invariant instance) (compile-form instance (graph:invariant task)))
      (setf (condition instance) (compile-form instance (graph:condition task)))
      instance)))

(defmethod %transform ((interaction graph:interaction) cache (task task))
  (make-instance (class-for (quest task) 'interaction)
                 :interactable (graph:interactable interaction)
                 :dialogue (dialogue:compile* (graph:dialogue interaction)
                                              (make-assembly task))))

(defmethod %transform ((action graph:action) cache (task task))
  (make-instance (class-for (quest task) 'action)
                 :on-activate (compile-form task (graph:on-activate action))
                 :on-deactivate (compile-form task (graph:on-deactivate action))))

(defmethod %transform ((end graph:end) cache (quest quest))
  (make-instance (class-for quest 'end)
                 :quest quest))
