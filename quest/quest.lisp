(in-package #:org.shirakumo.fraf.leaf.quest)

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
      (let ((quest (make-instance quest-type :quest quest :storyline storyline)))
        (setf (find-quest (graph:name quest) storyline) quest)))))

(defclass quest (describable)
  ((status :initarg :status :accessor status)
   (storyline :initarg :storyline :reader storyline)
   (effects :reader effects)
   (tasks :initform () :reader tasks)
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

(defun sort-quests (quests)
  (sort quests (lambda (a b)
                 (if (eql (status a) (status b))
                     (string< (title a) (title b))
                     (eql :active (status a))))))

(defmethod active-p ((quest quest))
  (eql :active (status quest)))

(defmethod (setf status) :before (status (quest quest))
  (ecase status
    (:active (assert (eql :inactive (status quest))))
    (:complete (assert (eql :active (status quest))))
    (:failed (assert (eql :active (status quest))))))

(defmethod (setf status) :after (status (quest quest))
  (setf (known-quests (storyline quest))
        (sort-quests
         (if (eql :active status)
             (list* quest (known-quests (storyline quest)))
             (known-quests (storyline quest))))))

(defmethod activate ((quest quest))
  (setf (status quest) :active)
  (mapcar #'activate (effects quest))
  quest)

(defmethod complete ((quest quest))
  (setf (status quest) :complete)
  (setf (active-tasks quest) ())
  quest)

(defmethod try ((quest quest))
  (dolist (task (active-tasks quest))
    (try task)))

(defclass end ()
  ((quest :initarg :quest :reader quest)))

(defmethod activate ((end end))
  (complete (quest end)))

(defclass task (describable)
  ((status :initarg :status :accessor status)
   (quest :initarg :quest :reader quest)
   (causes :initarg :causes :reader causes)
   (effects :initarg :effects :reader effects)
   (triggers :initarg :triggers :reader triggers)
   (invariant :initarg :invariant :reader invariant)
   (condition :initarg :condition :reader condition))
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

(defun required-for-completion (task cause)
  ;; TODO: implement this
  T)

(defmethod activate ((task task))
  (when (eql (status task) :inactive)
    (setf (status task) :unresolved)
    (dolist (cause (causes task))
      (when (and (active-p cause)
                 (required-for-completion task cause))
        (setf (status task) :obsolete)))
    (dolist (trigger (triggers task))
      (activate trigger)))
  task)

(defmethod complete ((task task))
  (unless (active-p task)
    (error "Cannot complete done task."))
  (setf (status task) :complete)
  (dolist (effect (effects task))
    (activate effect))
  task)

(defmethod try ((task task))
  (cond ((not (funcall (invariant task)))
         (setf (status task) :failed))
        ((funcall (condition task))
         (complete task))))

(defclass trigger ()
  ())

(defclass interaction (trigger)
  ((interactable :initarg :interactable :reader interactable)
   (dialogue :initarg :dialogue :reader dialogue)))

(defmethod transform ((node graph:quest) quest)
  (let ((cache (make-hash-table :test 'eq)))
    (%transform node cache quest)
    (values (loop for effect in (graph:effects node)
                  collect (gethash effect cache))
            (loop for task being the hash-values of cache
                  collect task))))

(defmethod %transform :around (thing cache _)
  (or (gethash thing cache)
      (setf (gethash thing cache)
            (call-next-method))))

(defmethod %transform ((node graph:quest) cache quest)
  (setf (gethash node cache) quest)
  (setf (description quest) (description node))
  (setf (title quest) (title node))
  (loop for task in (graph:effects node)
        do (%transform task cache quest)))

(defmethod %transform ((task graph:task) _ quest)
  (flet ((%transform (thing)
           (%transform thing _ quest)))
    (make-instance 'task
                   :quest quest
                   :title (graph:title task)
                   :description (graph:description task)
                   :causes (loop for cause in (graph:causes task)
                                 when (typep cause 'graph:task)
                                 collect (%transform cause))
                   :effects (mapcar #'%transform (graph:effects task))
                   :triggers (mapcar #'%transform (graph:triggers task))
                   :invariant (dialogue::compile-form (make-assembly quest)
                                                      (graph:invariant task))
                   :condition (dialogue::compile-form (make-assembly quest)
                                                      (graph:condition task)))))

(defmethod %transform ((interaction graph:interaction) _ quest)
  (make-instance 'interaction
                 :interactable (graph:interactable interaction)
                 :dialogue (dialogue:compile* (graph:dialogue interaction)
                                              (make-assembly quest))))

(defmethod %transform ((end graph:end) _ quest)
  (make-instance 'end
                 :quest quest))
