(in-package #:org.shirakumo.fraf.kandria)

(defvar *current-task*)
(defvar *current-interaction*)

(defclass place-marker (sized-entity resizable ephemeral dialog-entity creatable)
  ((name :accessor name)))

(defmethod interactable-p ((marker place-marker))
  (interactions marker))

(defmethod description ((marker place-marker))
  (if (eql :complete (quest:status (first (interactions marker))))
      (language-string 'examine-again)
      (language-string 'examine)))

(defmethod compile-to-pass (pass (marker place-marker)))
(defmethod register-object-for-pass (pass (marker place-marker)))

(defmethod (setf location) ((marker located-entity) (entity located-entity))
  (setf (location entity) (location marker)))

(defmethod (setf location) ((name symbol) (entity located-entity))
  (setf (location entity) (location (unit name +world+))))

(defclass storyline (quest:storyline)
  ((default-interactions :initform (make-hash-table :test 'eql) :reader default-interactions)))

(defclass quest (quest:quest alloy:observable)
  ((clock :initarg :clock :initform 0f0 :accessor clock)
   (start-time :initarg :start-time :initform 0f0 :accessor start-time)
   (visible-p :initarg :visible :initform T :accessor visible-p)
   (experience-reward :initarg :experience-reward :initform 500 :accessor experience-reward)))

(defclass quest-started (event)
  ((quest :initarg :quest :reader quest)))

(defclass quest-completed (event)
  ((quest :initarg :quest :reader quest)))

(defclass quest-failed (event)
  ((quest :initarg :quest :reader quest)))

(alloy:make-observable '(setf clock) '(value alloy:observable))
(alloy:make-observable '(setf quest:status) '(value alloy:observable))

(defmethod quest:class-for ((storyline (eql 'quest:quest))) 'quest)

(defmethod quest:activate :before ((quest quest))
  (when (and (not (eql :active (quest:status quest)))
             (visible-p quest))
    (harmony:play (// 'sound 'ui-quest-start))
    (status :important (@formats 'new-quest-started (quest:title quest)))
    (setf (start-time quest) (clock +world+))
    (issue +world+ 'quest-started :quest quest))
  (setf (clock quest) 0f0))

(defmethod quest:complete :before ((quest quest))
  (when (and (not (eql :complete (quest:status quest)))
             (visible-p quest))
    (award-experience (unit 'player T) (experience-reward quest))
    (harmony:play (// 'sound 'ui-quest-complete))
    (status :important (@formats 'quest-successfully-completed (quest:title quest)))
    (issue +world+ 'quest-completed :quest quest)))

(defmethod quest:fail :before ((quest quest))
  (when (and (not (eql :failed (quest:status quest)))
             (visible-p quest))
    (harmony:play (// 'sound 'ui-quest-fail))
    (status :important (@formats 'quest-completion-failed (quest:title quest)))
    (issue +world+ 'quest-failed :quest quest)))

(defmethod quest:make-assembly ((_ quest))
  (make-instance 'assembly))

(defclass task (quest:task)
  ((visible-p :initarg :visible :initform T :accessor visible-p)
   (progress-fun :initarg :progress-fun :initform NIL :accessor progress-fun)
   (full-progress :initarg :full-progress :initform 0 :accessor full-progress)
   (last-progress :initform 0 :accessor last-progress)
   (marker :initarg :marker :initform NIL :accessor marker)))

(defmethod quest:try :around ((task task))
  (let ((fun (progress-fun task))
        (*current-task* task))
    (when fun
      (let ((res (funcall fun)))
        (when (< (last-progress task) res)
          (setf (last-progress task) res)
          (when (< res (full-progress task))
            (status :note "~a (~a/~a)" (title task) res (full-progress task))))))
    (call-next-method)))

(defmethod quest:class-for ((storyline (eql 'quest:task))) 'task)

(defmethod quest:make-assembly ((task task))
  (make-instance 'assembly))

(defmethod quest:activate :around ((task task))
  (let ((*current-task* task))
    (call-next-method))
  (when (and (marker task) (setting :gameplay :display-hud))
    (show (make-instance 'quest-indicator :target (unlist (marker task))))))

(defclass interaction (quest:interaction)
  ((source :initform NIL :initarg :source :accessor source)
   (repeatable :initform NIL :initarg :repeatable :accessor repeatable-p)
   (auto-trigger :initform NIL :initarg :auto-trigger :accessor auto-trigger)))

(defmethod shared-initialize :around ((interaction interaction) slots &rest args &key source dialogue task name)
  (cond (source
         (let ((dialogue (apply #'find-mess (enlist source))))
           (apply #'call-next-method interaction slots :dialogue dialogue args)))
        ((or dialogue (slot-boundp interaction 'source))
         (call-next-method))
        (T
         (let* ((source (list (quest:name (quest:quest task)) (format NIL "~(~a/~a~)" (quest:name task) name)))
                (dialogue (apply #'find-mess source)))
           (setf (source interaction) source)
           (apply #'call-next-method interaction slots :dialogue dialogue args)))))

(defmethod quest:class-for ((storyline (eql 'quest:interaction))) 'interaction)

(defmethod quest:make-assembly ((interaction interaction))
  (make-instance 'assembly))

(defmethod quest:activate ((trigger interaction))
  (with-simple-restart (abort "Don't activate the interaction.")
    (when (and +world+ (not (auto-trigger trigger)))
      (let ((interactable (unit (quest:interactable trigger) +world+)))
        (if (typep interactable 'interactable)
            (pushnew trigger (interactions interactable))
            (v:severe :kandria.quest "What the fuck? Can't find interaction target ~s, got ~a"
                      (quest:interactable trigger) interactable))))))

(defmethod quest:deactivate :around ((trigger interaction))
  (call-next-method)
  (when +world+
    (let ((interactable (unit (quest:interactable trigger) +world+)))
      (when (typep interactable 'interactable)
        (setf (interactions interactable) (remove trigger (interactions interactable)))))))

(defmethod quest:complete ((trigger interaction))
  (when +world+
    (let ((interactable (unit (quest:interactable trigger) +world+)))
      (when (and (typep interactable 'interactable)
                 (not (repeatable-p trigger)))
        (setf (interactions interactable) (remove trigger (interactions interactable)))))))

(defmethod quest:try ((trigger interaction))
  (when (and (auto-trigger trigger)
             (pausing-possible-p))
    (interact trigger T)))

(defmethod quest:title ((interaction interaction))
  (or (call-next-method)
      (language-string* (quest:name (quest:quest (quest:task interaction)))
                        (quest:name (quest:task interaction))
                        (quest:name interaction))))

(defclass stub-interaction (interaction)
  ((quest:dialogue :initform NIL :accessor quest:dialogue)
   (quest:task :initform (quest:find-named 'task-world-all (quest:find-named 'world (quest:storyline T))))
   (quest:name :initform 'stub)))

(defmethod quest:complete ((stub-interaction stub-interaction)))

(defclass assembly (dialogue:assembly)
  ())

(defmethod clone ((assembly assembly) &key)
  (let ((clone (make-instance (class-of assembly))))
    (loop for instruction across (dialogue:instructions assembly)
          do (vector-push-extend instruction (dialogue:instructions clone)))
    clone))

(defun find-task (quest task)
  (uiop:nest
   (quest:find-task task)
   (quest:find-quest quest)
   (storyline +world+)))

(flet ((thing (thing)
         (if (and (symbolp thing) (not (null thing)))
             (quest:find-named thing *current-task*)
             thing)))
  (defun activate (&rest things)
    (loop for thing in things do (quest:activate (thing thing))))

  (defun deactivate (&rest things)
    (loop for thing in things do (quest:deactivate (thing thing))))

  (defun complete (&rest things)
    (loop for thing in things do (quest:complete (thing thing))))

  (defun fail (&rest things)
    (loop for thing in things do (quest:fail (thing thing))))

  (defun complete-p (&rest things)
    (loop for thing in things always (eql :complete (quest:status (thing thing)))))
  
  (defun failed-p (&rest things)
    (loop for thing in things always (eql :failed (quest:status (thing thing)))))

  (defun var-of (thing name &optional default)
    (quest:var name (thing thing) default)))

(defun var (name &optional default)
  (quest:var name *current-task* default))

(defun (setf var) (value name)
  (setf (quest:var name *current-task*) value))

(defun global-wrap-lexenv (form)
  `(let* ((player (unit 'player +world+))
          (clock (clock +world+)))
     (declare (ignorable player clock))
     (flet ((have (thing &optional (count 1) (inventory player))
              (<= count (item-count thing inventory)))
            (item-count (thing &optional (inventory player))
              (item-count thing inventory))
            (store (item &optional (count 1) (inventory player))
              (store item inventory count))
            (retrieve (item &optional (count 1) (inventory player))
              (retrieve item inventory count))
            (move-to (target unit)
              (move-to target unit)
              (when (typep unit 'ai-entity)
                (setf (ai-state unit) :move-to)))
            (unit (name &optional (container +world+))
              (unit name container)))
       (declare (ignorable #'have #'item-count #'store #'retrieve #'move-to #'unit))
       ,form)))

(defun find-all-variables ()
  (let ((vars ()))
    (flet ((handle-scope (thing)
             (loop for binding in (quest:bindings thing)
                   do (pushnew (car binding) vars))))
      (dolist (storyline quest::*storylines* vars)
        (handle-scope storyline)
        (loop for quest being the hash-values of (quest:quests storyline)
              do (handle-scope quest)
                 (loop for task being the hash-values of (quest:tasks quest)
                       do (handle-scope task)))))))

(defun task-wrap-lexenv (form)
  `(let* ((task *current-task*)
          (quest (quest:quest task))
          (all-complete (loop for trigger being the hash-values of (quest:triggers task)
                              always (eql :complete (quest:status trigger)))))
     (declare (ignorable quest all-complete))
     (flet ((thing (thing)
              (if (and (symbolp thing) (not (null thing)))
                  (quest:find-named thing task)
                  thing)))
       (flet ((reset (&rest things)
                (loop for thing in things do (quest:reset (thing thing) :reset-vars NIL)))
              (active-p (&rest things)
                (loop for thing in things always (quest:active-p (thing thing)))))
         (declare (ignorable #'reset #'active-p))
         ;; KLUDGE: this sucks, lmao
         (symbol-macrolet ,(loop for var in (find-all-variables)
                                 collect `(,var (var ',var)))
           ,(global-wrap-lexenv form))))))

(defmethod quest:compile-form ((task task) form)
  (compile NIL `(lambda () ,(task-wrap-lexenv form))))

(defmethod dialogue:wrap-lexenv ((assembly assembly) form)
  `(let* ((interaction *current-interaction*)
          (*current-task* (quest:task interaction)))
     ,(task-wrap-lexenv form)))

(defun load-default-interactions (&optional (storyline (quest:storyline T)) (file (merge-pathnames "quests/default-interactions.spess" (language-dir))))
  (let ((*package* #.*package*)
        (interactions (default-interactions storyline))
        (root (dialogue:parse file))
        (section NIL))
    (flet ((start-new (name)
             (let ((root (make-instance 'components:root-component)))
               (setf (gethash name interactions) root)
               (setf section root))))
      (loop for component across (components:children root)
            do (if (typep component 'components:header)
                   (start-new (read-from-string (aref (components:children component) 0)))
                   (vector-push-extend component (components:children section))))
      (loop for name being the hash-keys of interactions
            for root being the hash-values of interactions
            do (when (typep root 'components:root-component)
                 (setf (gethash name interactions) (make-instance 'stub-interaction :dialogue root)))))))

(defmacro define-sequence-quest ((storyline name) &body body)
  (let ((counter 0))
    (labels ((parse-sequence-form (form name next)
               (match1 form
                 (:eval (&rest body)
                        (form-fiddle:with-body-options (body initargs) body
                          `((,name
                             ,@initargs
                             :title "-"
                             :visible NIL
                             :condition T
                             :on-activate (action)
                             :on-complete ,next
                             (:action action
                                      ,@body)))))
                 (:animate ((character animation) . body)
                           (form-fiddle:with-body-options (body initargs) body
                             `((,name
                                ,@initargs
                                :title ,(format NIL "Wait for ~a to ~a." character animation)
                                :visible NIL
                                :condition (not (eql ',animation (name (animation (unit ',character +world+)))))
                                :on-activate (action)
                                :on-complete ,next
                                (:action action
                                         (start-animation ',animation (unit ',character +world+))
                                         ,@body)))))
                 (:nearby ((place character) . body)
                          (form-fiddle:with-body-options (body initargs) body
                            `((,name
                               ,@initargs
                               :title ,(format NIL "Wait for ~a to arrive." character)
                               :condition (nearby-p ',place ',character)
                               :on-complete (action ,@next)
                               (:action action
                                        ,@body)))))
                 (:wait (for . initargs)
                        `((,name
                           ,@initargs
                           :title ,(format NIL "Wait for ~d second~:p" for)
                           :visible NIL
                           :condition (<= ,for (- clock timer))
                           :variables ((timer 0.0))
                           :on-activate (action)
                           :on-complete ,next
                           (:action action (setf timer clock)))))
                 (:have ((item &optional (count 1)) . initargs)
                        `((,name
                           ,@initargs
                           :title ,(format NIL "Collect ~d ~a~:p" count item)
                           :condition (have ',item ,count)
                           :on-complete ,next
                           ,@(when (< 1 count)
                               `(:full-progress ,count
                                 :progress-fun (item-count ',item))))))
                 (:go-to ((place &key lead follow with) . body)
                         (form-fiddle:with-body-options (body initargs) body
                           `((,name
                              ,@initargs
                              :title ,(cond (lead (format NIL "Follow ~a to ~a" lead place))
                                            (follow (format NIL "Lead ~a to ~a" follow place))
                                            (T (format NIL "Go to ~a" place)))
                              :condition (nearby-p ',place 'player)
                              :on-activate (action)
                              :on-complete ,next
                              :marker ',place
                              (:action action
                                       ,@(if with `((stop-following ',with)
                                                    (move-to ',place ',with)))
                                       ,@(if lead `((lead 'player ',place ',lead)))
                                       ,@(if follow `((follow 'player ',follow)))
                                       ,@(if body `((walk-n-talk (progn ,@body)))))))))
                 (:interact ((with &key now repeatable) . body)
                            (form-fiddle:with-body-options (body initargs) body
                              (let ((repeatable (or repeatable (popf initargs :repeatable)))
                                    (source (popf initargs :source)))
                                `((,name
                                   ,@initargs
                                   :title ,(format NIL "Listen to ~a" with)
                                   :condition (complete-p 'interaction)
                                   :on-activate (interaction)
                                   :on-complete ,next
                                   :marker ',(if now NIL with)
                                   (:interaction interaction
                                    :interactable ,with
                                    :auto-trigger ,now
                                    :repeatable ,repeatable
                                    :source ,source
                                                 ,@body))))))
                 (:complete ((&rest things) . body)
                            (form-fiddle:with-body-options (body initargs (activate T)) body
                              `((,name
                                 ,@initargs
                                 :title ,(format NIL "Complete ~{~a~^, ~}" things)
                                 :condition (complete-p ,@(loop for thing in things
                                                                collect (if (symbolp thing)
                                                                            `(or (unit ',thing) ',thing)
                                                                            (destructuring-bind (quest task) thing
                                                                              `(find-task ',quest ',task)))))
                                 :on-activate (action)
                                 :on-complete ,next
                                 (:action action
                                          ,@(when activate
                                              (loop for thing in things
                                                    collect `(activate (or (unit ',thing) ',thing))))
                                          ,@(if body `((walk-n-talk (progn ,@body)))))))))))
             (sequence-form-name (form)
               (apply #'trial::mksym *package* (incf counter) :- (first form) :- (enlist (unlist (second form)))))
             (parse-sequence-to-tasks (forms)
               (let ((forms (loop for form in forms
                                  collect (list (sequence-form-name form) form))))
                 (loop for (form next) on forms
                       append (parse-sequence-form (second form) (first form) (enlist (first next)))))))
      (form-fiddle:with-body-options (body initargs) body
        (let ((tasks (parse-sequence-to-tasks body)))
          `(quest:define-quest (,storyline ,name)
             ,@initargs
             :on-activate (,(caar tasks))
             ,@tasks))))))


