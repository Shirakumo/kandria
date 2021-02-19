(in-package #:org.shirakumo.fraf.kandria)

(defclass place-marker (sized-entity resizable ephemeral)
  ((name :accessor name)))

(defmethod compile-to-pass (pass (marker place-marker)))
(defmethod register-object-for-pass (pass (marker place-marker)))

(defmethod (setf location) ((marker located-entity) (entity located-entity))
  (setf (location entity) (location marker)))

(defmethod (setf location) ((name symbol) (entity located-entity))
  (setf (location entity) (location (unit name +world+))))

(defmethod spawn ((location vec2) type &rest initargs &key (count 1) &allow-other-keys)
  (remf initargs :count)
  (dotimes (i count)
    (enter* (apply #'make-instance type :location (vcopy location) initargs)
            (region +world+))))

(defmethod spawn ((marker located-entity) type &rest initargs)
  (apply #'spawn (location marker) type initargs))

(defmethod spawn ((name symbol) type &rest initargs)
  (apply #'spawn (location (unit name +world+)) type initargs))

(defclass quest (quest:quest alloy:observable)
  ((clock :initarg :clock :initform 0f0 :accessor clock)))

(alloy:make-observable '(setf clock) '(value alloy:observable))
(alloy:make-observable '(setf quest:status) '(value alloy:observable))

(defmethod quest:activate :after ((quest quest))
  (status :important "New quest: ~a" (quest:title quest))
  (setf (clock quest) 0f0))

(defmethod quest:complete :after ((quest quest))
  (status :important "Quest completed: ~a" (quest:title quest)))

(defmethod quest:fail :after ((quest quest))
  (status :important "Quest failed: ~a" (quest:title quest)))

(defmethod quest:make-assembly ((_ quest))
  (make-instance 'assembly))

(defclass task (quest:task)
  ())

(defmethod quest:make-assembly ((task task))
  (make-instance 'assembly))

(defclass interaction (quest:interaction)
  ((repeatable :initform NIL :initarg :repeatable :accessor repeatable-p)))

(defmethod quest:make-assembly ((interaction interaction))
  (make-instance 'assembly :interaction interaction))

(defmethod quest:activate ((trigger interaction))
  (with-simple-restart (abort "Don't activate the interaction.")
    (let ((interactable (unit (quest:interactable trigger) +world+)))
      (when (typep interactable 'interactable)
        (pushnew trigger (interactions interactable))))))

(defmethod quest:deactivate :around ((trigger interaction))
  (call-next-method)
  (let ((interactable (unit (quest:interactable trigger) +world+)))
    (when (typep interactable 'interactable)
      (setf (interactions interactable) (remove trigger (interactions interactable))))))

(defmethod quest:complete ((trigger interaction))
  (let ((interactable (unit (quest:interactable trigger) +world+)))
    (when (and (typep interactable 'interactable)
               (not (repeatable-p trigger)))
      (setf (interactions interactable) (remove trigger (interactions interactable))))))

(defclass stub-interaction (interaction)
  ((quest:dialogue :initform NIL :accessor quest:dialogue)
   (quest:task :initform NIL)
   (quest:name :initform 'stub)))

(defmethod initialize-instance :after ((interaction stub-interaction) &key dialogue)
  ;; FIXME: use real lexinv...
  (with-kandria-io-syntax
    (setf (quest:dialogue interaction) (dialogue:compile* dialogue))))

(defmethod quest:complete ((stub-interaction stub-interaction)))

(defmethod quest:make-assembly ((stub-interaction stub-interaction))
  (make-instance 'assembly :interaction stub-interaction))

(defclass assembly (dialogue:assembly)
  ((interaction :initform NIL :initarg :interaction :accessor interaction)))

(defun global-wrap-lexenv (form)
  `(let* ((world +world+)
          (player (unit 'player world))
          (region (unit 'region world)))
     (declare (ignorable world player region))
     (flet ((have (thing &optional (inventory player))
              (have thing inventory))
            (store (item &optional (count 1) (inventory player))
              (store item inventory))
            (retrieve (item &optional (inventory player))
              (retrieve item inventory))
            (unit (name &optional (container +world+))
              (unit name container))
            (move-to (target &optional (unit player))
              (move-to target unit)
              (when (typep unit 'ai-entity)
                (setf (ai-state unit) :move-to)))
            ((setf location) (loc thing)
              (setf (location (unit thing +world+)) loc)))
       (declare (ignorable #'have #'store #'retrieve #'unit #'move-to #'(setf location)))
       ,form)))

(defun task-wrap-lexenv (form)
  `(flet ((thing (thing)
            (if (and thing (symbolp thing)) (quest:find-named thing task) thing)))
     (flet ((activate (&rest things)
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
              (walk-n-talk (thing thing)))
            (interrupt-walk-n-talk (thing)
              (interrupt-walk-n-talk (thing thing))))
       (declare (ignorable #'activate #'deactivate #'complete #'fail #'active-p #'complete-p #'failed-p #'walk-n-talk #'interrupt-walk-n-talk))
       ,(global-wrap-lexenv form))))

(defmethod quest:compile-form ((task task) form)
  (compile NIL `(lambda ()
                  (let* ((task ,task)
                         (quest (quest:quest task))
                         (all-complete (loop for trigger being the hash-values of (quest:triggers task)
                                             always (eql :complete (quest:status trigger)))))
                    (declare (ignorable task quest all-complete))
                    (flet ((var (name &optional thing)
                             (quest:var name (thing thing)))
                           ((setf var) (value name &optional thing)
                             (setf (quest:var name (thing thing)) value)))
                      (declare (ignorable #'var #'(setf var)))
                      ,(task-wrap-lexenv form))))))

(defmethod dialogue:wrap-lexenv ((assembly assembly) form)
  `(let* ((interaction ,(or (interaction assembly)
                            `(interaction (find-panel 'textbox))))
          (task (quest:task interaction))
          (quest (quest:quest task))
          (has-more-dialogue (rest (interactions (find-panel 'dialog))))
          (all-complete (loop for trigger being the hash-values of (quest:triggers task)
                              always (eql :complete (quest:status trigger)))))
     (declare (ignorable interaction task quest all-complete has-more-dialogue))
     (flet ((var (name &optional default thing)
              (quest:var name (thing thing) default))
            ((setf var) (value name &optional thing)
              (setf (quest:var name (thing thing)) value)))
       (declare (ignorable #'var #'(setf var)))
       ,(task-wrap-lexenv form))))

(defmethod load-quest ((packet packet) (storyline quest:storyline))
  (with-kandria-io-syntax
    (destructuring-bind (header info) (parse-sexps (packet-entry "meta.lisp" packet :element-type 'character))
      (let ((quest (decode-payload
                    (list* :storyline storyline info) (type-prototype 'quest) packet
                    (destructuring-bind (&key identifier version) header
                      (assert (eql 'quest identifier))
                      (coerce-version version)))))
        (setf (quest:find-quest (quest:name quest) storyline) quest)))))
