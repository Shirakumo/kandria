(in-package #:org.shirakumo.fraf.kandria)

(defgeneric extract-language (thing))
(defgeneric refresh-language (thing))
(defun useful-language-string-p (thing)
  (and thing (string/= "" thing) (string/= "-" thing) (string/= "<unknown>" thing)))

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

(defmethod extract-language ((storyline quest:storyline))
  (reduce #'append (sort (loop for quest being the hash-values of (quest:quests storyline)
                               append (extract-language quest))
                         #'string< :key #'car)))

(defmethod refresh-language ((storyline quest:storyline))
  (loop for quest being the hash-values of (quest:quests storyline)
        do (refresh-language quest)))

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

(defun %langname (thing &rest subset)
  (intern (format NIL "~a~{/~a~}" (string thing) subset)
          (symbol-package thing)))

(defmethod extract-language ((quest quest:quest))
  (list*
   (when (useful-language-string-p (quest:title quest))
     (list (%langname (quest:name quest) 'title) (quest:title quest)))
   (when (useful-language-string-p (quest:description quest))
     (list (%langname (quest:name quest) 'description) (quest:description quest)))
   (loop for task being the hash-values of (quest:tasks quest)
         append (extract-language task))))

(defmethod refresh-language ((quest quest:quest))
  (let ((title (language-string* (quest:name quest) 'title)))
    (when title (setf (quest:title quest) title)))
  (let ((description (language-string* (quest:name quest) 'description)))
    (when description (setf (quest:description quest) description)))
  (loop for task being the hash-values of (quest:tasks quest)
        do (refresh-language task)))

(defclass task (quest:task)
  ((visible-p :initarg :visible :initform T :accessor visible-p)
   (progress-fun :initarg :progress-fun :initform NIL :accessor progress-fun)
   (full-progress :initarg :full-progress :initform 0 :accessor full-progress)
   (last-progress :initform 0 :accessor last-progress)
   (marker :initarg :marker :initform NIL :accessor marker)))

(defmethod quest:try :before ((task task))
  (let ((fun (progress-fun task)))
    (when fun
      (let ((res (funcall fun)))
        (when (< (last-progress task) res)
          (setf (last-progress task) res)
          (when (< res (full-progress task))
            (status :note "~a (~a/~a)" (title task) res (full-progress task))))))))

(defmethod quest:class-for ((storyline (eql 'quest:task))) 'task)

(defmethod quest:make-assembly ((task task))
  (make-instance 'assembly))

(defmethod quest:activate :after ((task task))
  (when (and (marker task) (setting :gameplay :display-hud))
    (show (make-instance 'quest-indicator :target (unlist (marker task))))))

(defmethod extract-language ((task quest:task))
  (list*
   (when (useful-language-string-p (quest:title task))
     (list (%langname (quest:name (quest:quest task)) (quest:name task) 'title) (quest:title task)))
   (when (useful-language-string-p (quest:description task))
     (list (%langname (quest:name (quest:quest task)) (quest:name task) 'description) (quest:description task)))
   (loop for task being the hash-values of (quest:triggers task)
         append (extract-language task))))

(defmethod refresh-language ((task quest:task))
  (let ((title (language-string* (quest:name (quest:quest task)) (quest:name task) 'title)))
    (when title (setf (quest:title task) title)))
  (let ((description (language-string* (quest:name (quest:quest task)) (quest:name task) 'description)))
    (when description (setf (quest:description task) description)))
  (loop for trigger being the hash-values of (quest:triggers task)
        do (refresh-language trigger)))

(defun find-mess (name &optional chapter)
  (let ((file (merge-pathnames (string-downcase name)
                               (merge-pathnames "quests/a.spess" (language-dir (setting :language))))))
    (if chapter
        (list file chapter)
        file)))

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
  (make-instance 'assembly :interaction interaction))

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

(defmethod extract-language ((trigger quest:trigger))
  (when (useful-language-string-p (quest:title trigger))
    (list (list (%langname (quest:name (quest:quest (quest:task trigger)))
                           (quest:name (quest:task trigger))
                           (quest:name trigger))
                (quest:title trigger)))))

(defmethod refresh-language ((trigger quest:trigger))
  (let ((title (language-string* (quest:name (quest:quest (quest:task trigger)))
                                 (quest:name (quest:task trigger))
                                 (quest:name trigger))))
    (when title (setf (quest:title trigger) title))))

(defmethod refresh-language :after ((interaction interaction))
  (reinitialize-instance interaction :source (source interaction)))

(defclass stub-interaction (interaction)
  ((quest:dialogue :initform NIL :accessor quest:dialogue)
   (quest:task :initform (quest:find-named 'task-world-all (quest:find-named 'world (quest:storyline T))))
   (quest:name :initform 'stub)))

(defmethod quest:complete ((stub-interaction stub-interaction)))

(defmethod quest:make-assembly ((stub-interaction stub-interaction))
  (make-instance 'assembly :interaction stub-interaction))

(defclass assembly (dialogue:assembly)
  ((interaction :initform NIL :initarg :interaction :accessor interaction)))

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
            (unit (name &optional (container +world+))
              (unit name container))
            (clear-pending-interactions ()
              (setf (interactions (find-panel 'dialog)) ()))
            (override-music (track)
              (setf (override (unit 'environment +world+)) (when track (// 'music track))))
            (find-task (quest task)
              (uiop:nest
               (quest:find-task task)
               (quest:find-quest quest)
               (storyline +world+))))
       (declare (ignorable #'have #'item-count #'store #'retrieve #'unit #'clear-pending-interactions #'override-music #'find-task))
       ,form)))

(defun task-wrap-lexenv (form task)
  `(let* ((task ,task)
          (quest (quest:quest task))
          (all-complete (loop for trigger being the hash-values of (quest:triggers task)
                              always (eql :complete (quest:status trigger)))))
     (flet ((thing (thing)
              (if (and (symbolp thing) (not (null thing)))
                  (quest:find-named thing ,task)
                  thing)))
       (flet ((var (name &optional default)
                (quest:var name task default))
              ((setf var) (value name)
                (setf (quest:var name task) value))
              (var-of (thing name &optional default)
                (quest:var name (thing thing) default))
              (activate (&rest things)
                (loop for thing in things do (quest:activate (thing thing))))
              (deactivate (&rest things)
                (loop for thing in things do (quest:deactivate (thing thing))))
              (complete (&rest things)
                (loop for thing in things do (quest:complete (thing thing))))
              (fail (&rest things)
                (loop for thing in things do (quest:fail (thing thing))))
              (reset (&rest things)
                (loop for thing in things do (quest:reset (thing thing) :reset-vars NIL)))
              (active-p (&rest things)
                (loop for thing in things always (quest:active-p (thing thing))))
              (complete-p (&rest things)
                (loop for thing in things always (eql :complete (quest:status (thing thing)))))
              (failed-p (&rest things)
                (loop for thing in things always (eql :failed (quest:status (thing thing))))))
         (declare (ignorable #'var #'(setf var) #'var-of #'activate #'deactivate #'complete #'fail #'reset #'reset* #'active-p #'complete-p #'failed-p))
         (symbol-macrolet ,(loop for variable in (quest:list-variables task)
                                 collect `(,variable (var ',variable)))
           ,(global-wrap-lexenv form))))))

(defmethod quest:compile-form ((task task) form)
  (compile NIL `(lambda () ,(task-wrap-lexenv form task))))

(defmethod dialogue:wrap-lexenv ((assembly assembly) form)
  `(let ((interaction ,(interaction assembly)))
     ,(task-wrap-lexenv form (quest:task (interaction assembly)))))

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

(define-language-change-hook refresh-quests (language)
  (declare (ignore language))
  (when (and +world+ (storyline +world+))
    (refresh-language (storyline +world+))
    (load-default-interactions)))
