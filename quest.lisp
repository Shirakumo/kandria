(in-package #:org.shirakumo.fraf.kandria)

(defclass place-marker (sized-entity resizable ephemeral dialog-entity)
  ((name :accessor name)))

(defmethod description ((marker place-marker))
  (language-string 'examine))

(defmethod compile-to-pass (pass (marker place-marker)))
(defmethod register-object-for-pass (pass (marker place-marker)))

(defmethod (setf location) ((marker located-entity) (entity located-entity))
  (setf (location entity) (location marker)))

(defmethod (setf location) ((name symbol) (entity located-entity))
  (setf (location entity) (location (unit name +world+))))

(defclass quest (quest:quest alloy:observable)
  ((clock :initarg :clock :initform 0f0 :accessor clock)
   (visible-p :initarg :visible :initform T :accessor visible-p)))

(alloy:make-observable '(setf clock) '(value alloy:observable))
(alloy:make-observable '(setf quest:status) '(value alloy:observable))

(defmethod quest:class-for ((storyline (eql 'quest:quest))) 'quest)

(defmethod quest:activate :before ((quest quest))
  (when (and (not (eql :active (status quest)))
             (visible-p quest))
    (status :important "New quest: ~a" (quest:title quest)))
  (setf (clock quest) 0f0))

(defmethod quest:complete :before ((quest quest))
  (when (and (not (eql :complete (status quest)))
             (visible-p quest))
    (status :important "Quest completed: ~a" (quest:title quest))))

(defmethod quest:fail :before ((quest quest))
  (when (and (not (eql :failed (status quest)))
             (visible-p quest))
    (status :important "Quest failed: ~a" (quest:title quest))))

(defmethod quest:make-assembly ((_ quest))
  (make-instance 'assembly))

(defclass task (quest:task)
  ((visible-p :initarg :visible :initform T :accessor visible-p)
   (progress-fun :initarg :progress-fun :initform NIL :accessor progress-fun)
   (full-progress :initarg :full-progress :initform 0 :accessor full-progress)
   (last-progress :initform 0 :accessor last-progress)))

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

(defclass interaction (quest:interaction)
  ((repeatable :initform NIL :initarg :repeatable :accessor repeatable-p)
   (auto-trigger :initform NIL :initarg :auto-trigger :accessor auto-trigger)))

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

(defclass stub-interaction (interaction)
  ((quest:dialogue :initform NIL :accessor quest:dialogue)
   (quest:task :initform NIL)
   (quest:name :initform 'stub)))

(defmethod initialize-instance :after ((interaction stub-interaction) &key dialogue)
  (with-trial-io-syntax ()
    (setf (quest:dialogue interaction) (dialogue:compile* dialogue))))

(defmethod quest:complete ((stub-interaction stub-interaction)))

(defmethod quest:make-assembly ((stub-interaction stub-interaction))
  (make-instance 'assembly :interaction stub-interaction))

(defclass assembly (dialogue:assembly)
  ((interaction :initform NIL :initarg :interaction :accessor interaction)))

(defmacro flet* (bindings &body body)
  `(flet ,bindings
     (declare (ignorable ,@(loop for binding in bindings collect `#',(first binding))))
     ,@body))

(trivial-indent:define-indentation flet* ((&whole 4 &rest (&whole 1 4 &lambda &body)) &body))

(defun global-wrap-lexenv (form)
  `(let* ((world +world+)
          (player (unit 'player world))
          (region (unit 'region world))
          (clock (clock world)))
     (declare (ignorable world player region clock))
     (flet* ((have (thing &optional (count 1) (inventory player))
               (<= count (item-count thing inventory)))
             (item-count (thing &optional (inventory player))
               (item-count thing inventory))
             (store (item &optional (count 1) (inventory player))
               (store item inventory count))
             (retrieve (item &optional (count 1) (inventory player))
               (retrieve item inventory count))
             (unit (name &optional (container +world+))
               (unit name container))
             (move-to (target &optional (unit player))
               (move-to target unit)
               (when (typep unit 'ai-entity)
                 (setf (ai-state unit) :move-to)))
             (location (thing)
               (location (unit thing +world+)))
             ((setf location) (loc thing)
               (setf (location (unit thing +world+)) loc))
             (interaction (storyline quest task interaction)
               (interaction
                (uiop:nest
                 (quest:find-trigger interaction)
                 (quest:find-task task)
                 (quest:find-quest quest)
                 (quest:storyline storyline))
                T)))
       ,form)))

(defun task-wrap-lexenv (form task)
  `(flet ((thing (thing)
            (if (and (symbolp thing) (not (null thing)))
                (quest:find-named thing ,task)
                thing)))
     (flet* ((var (name &optional default)
               (quest:var name ,task default))
             ((setf var) (value name)
               (setf (quest:var name ,task) value))
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
             (active-p (&rest things)
               (loop for thing in things always (quest:active-p (thing thing))))
             (complete-p (&rest things)
               (loop for thing in things always (eql :complete (quest:status (thing thing)))))
             (failed-p (&rest things)
               (loop for thing in things always (eql :failed (quest:status (thing thing)))))
             (walk-n-talk (thing)
               (walk-n-talk (if (stringp thing) thing (quest:find-named thing ,task))))
             (interrupt-walk-n-talk (thing)
               (interrupt-walk-n-talk (quest:find-named thing ,task))))
       (symbol-macrolet ,(loop for variable in (quest:list-variables task)
                               collect `(,variable (var ',variable)))
         ,(global-wrap-lexenv form)))))

(defmethod quest:compile-form ((task task) form)
  (compile NIL `(lambda ()
                  (let* ((task ,task)
                         (quest (quest:quest task))
                         (all-complete (loop for trigger being the hash-values of (quest:triggers task)
                                             always (eql :complete (quest:status trigger)))))
                    (declare (ignorable task quest all-complete))
                    ,(task-wrap-lexenv form task)))))

(defmethod dialogue:wrap-lexenv ((assembly assembly) form)
  `(let* ((interaction ,(or (interaction assembly)
                            (error "What the fuck?")))
          (task (quest:task interaction))
          (quest (quest:quest task))
          (has-more-dialogue (rest (interactions (find-panel 'textbox))))
          (all-complete (loop for trigger being the hash-values of (quest:triggers task)
                              always (eql :complete (quest:status trigger)))))
     (declare (ignorable interaction task quest all-complete has-more-dialogue))
     ,(task-wrap-lexenv form (interaction assembly))))

(defun load-quests (&optional (language (setting :language)))
  (let ((dir (language-dir language)))
    (cl:load (merge-pathnames "storyline.lisp" dir))
    (dolist (file (directory (merge-pathnames "quests/**/*.lisp" dir)))
      (handler-bind (((or error warning)
                       (lambda (e)
                         (v:severe :kandria.quest "Failure loading ~a:~%~a" file e)))
                     (sb-ext:code-deletion-note #'muffle-warning)
                     (sb-kernel:redefinition-warning #'muffle-warning))
        (cl:load file)))))

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
                 (:animate ((character animation &optional (end-state 'stand)))
                           `((,name
                              :title ,(format NIL "Wait for ~a to ~a." character animation)
                              :visible NIL
                              :condition (eql ',end-state (name (animation (unit ',character +world+))))
                              :on-activate (action)
                              :on-complete ,next
                              (:action action (start-animation ',animation (unit ',character +world+))))))
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
                              (:action action
                                       ,@(if with `((move-to ',place ',with)))
                                       ,@(if lead `((lead 'player ',place ',lead)))
                                       ,@(if follow `((follow 'player ',follow)))
                                       ,@(if body `((walk-n-talk (progn ,@body)))))))))
                 (:interact ((with &key now) . body)
                            (form-fiddle:with-body-options (body initargs) body
                              `((,name
                                 ,@initargs
                                 :title ,(format NIL "Listen to ~a" with)
                                 :condition (complete-p 'interaction)
                                 :on-activate (interaction)
                                 :on-complete ,next
                                 (:interaction interaction
                                  :interactable ,with
                                  :auto-trigger ,now
                                               ,@body)))))
                 (:complete ((thing) . body)
                            (form-fiddle:with-body-options (body initargs) body
                              `((,name
                                 ,@initargs
                                 :title ,(format NIL "Complete ~a" thing)
                                 :condition (complete-p (or (unit ',thing) ',thing))
                                 :on-activate (action)
                                 :on-complete ,next
                                 (:action action
                                          (activate (or (unit ',thing) ',thing))
                                          ,@(if body `((walk-n-talk (progn ,@body)))))))))))
             (sequence-form-name (form)
               (trial::mksym *package* (incf counter) :- (first form) :- (unlist (second form))))
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

(defmethod load-language :after (&optional (language (setting :language)))
  (load-quests language))
