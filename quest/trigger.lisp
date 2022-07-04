(in-package #:org.shirakumo.fraf.kandria.quest)

(defclass trigger ()
  ((name :initarg :name :initform (error "NAME required.") :reader name)
   (task :initarg :task :initform (error "TASK required.") :reader task)
   (title :initarg :title :initform "<unknown>" :accessor title)
   (status :initarg :status :initform :inactive :accessor status)))

(defmethod shared-initialize :before ((trigger trigger) slots &key name)
  (unless (symbolp name)
    (error "NAME must be a symbol, not ~s" name)))

(defmethod print-object ((trigger trigger) stream)
  (print-unreadable-object (trigger stream :type T)
    (format stream "~s ~a" (name trigger) (status trigger))))

(defmethod find-named (name (trigger trigger) &optional (error T))
  (find-named name (task trigger) error))

(defmethod reset progn ((trigger trigger) &key reset-vars)
  (declare (ignore reset-vars))
  (if (active-p trigger)
      (deactivate trigger)
      (setf (status trigger) :inactive)))

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

(defmethod shared-initialize :after ((action action) slots &key on-activate on-deactivate)
  (when on-activate
    (setf (on-activate action) (compile-form (task action) on-activate)))
  (when on-deactivate
    (setf (on-deactivate action) (compile-form (task action) on-deactivate))))

(defmethod class-for ((storyline (eql 'action))) 'action)

(defmethod activate ((action action))
  (funcall (on-activate action)))

(defmethod activate :after ((action action))
  (complete action))

(defmethod complete ((action action)))

(defmethod deactivate ((action action))
  (funcall (on-deactivate action)))

(defmethod try ((action action)))

(defmacro define-action ((storyline quest task name) &body initargs)
  (form-fiddle:with-body-options (body initargs on-activate on-deactivate (class (class-for 'action))) initargs
    `(let* ((task (find-task ',task (find-quest ',quest (or (storyline ',storyline)
                                                            (error "No such storyline ~s" ',storyline)))))
            (action (or (find-trigger ',name task NIL)
                        (setf (find-trigger ',name task) (make-instance ',class :name ',name :task task ,@initargs)))))
       (reinitialize-instance action :on-activate ',(or on-activate (when body `(progn ,@body)) T)
                                     :on-deactivate ',(or on-deactivate T)
                                     ,@initargs)
       ',name)))

(defclass interaction (trigger scope)
  ((interactable :initarg :interactable :reader interactable)
   (dialogue :reader dialogue)))

(defmethod shared-initialize :after ((interaction interaction) slots &key dialogue)
  (when dialogue (setf (dialogue interaction) dialogue)))

(defmethod (setf dialogue) ((dialogue dialogue:assembly) (interaction interaction))
  (setf (slot-value interaction 'dialogue) dialogue))

(defmethod (setf dialogue) ((dialogue string) (interaction interaction))
  (setf (dialogue interaction) (dialogue:compile* dialogue (make-assembly interaction))))

(defmethod (setf dialogue) ((dialogue pathname) (interaction interaction))
  (setf (dialogue interaction) (alexandria:read-file-into-string dialogue)))

(defmethod (setf dialogue) ((dialogue cons) (interaction interaction))
  (destructuring-bind (source &optional tag) dialogue
    (let* ((source (etypecase source
                     (string source)
                     (pathname (alexandria:read-file-into-string source))))
           (dialogue (if tag
                         (format NIL "< ~a~%~%~a" tag source)
                         source)))
      (setf (dialogue interaction) dialogue))))

(defmethod class-for ((storyline (eql 'interaction))) 'interaction)

(defmethod make-assembly ((interaction interaction))
  (make-assembly (task interaction)))

(defmethod parent ((interaction interaction))
  (task interaction))

(defmethod try ((interaction interaction)))
(defmethod activate ((interaction interaction)))
(defmethod deactivate ((interaction interaction)))
(defmethod complete ((interaction interaction)))

(defmacro define-interaction ((storyline quest task name) &body initargs)
  (form-fiddle:with-body-options (body initargs interactable dialogue variables (class (class-for 'interaction))) initargs
    `(let* ((task (find-task ',task (find-quest ',quest (or (storyline ',storyline)
                                                            (error "No such storyline ~s" ',storyline)))))
            (action (or (find-trigger ',name task NIL)
                        (setf (find-trigger ',name task) (make-instance ',class :name ',name :task task ,@initargs)))))
       (reinitialize-instance action
                              :dialogue ,(or dialogue `(progn ,@body))
                              :interactable ',interactable
                              :variables ',variables
                              ,@initargs)
       ',name)))
