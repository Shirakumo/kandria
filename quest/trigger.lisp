(in-package #:org.shirakumo.fraf.kandria.quest)

(defclass trigger ()
  ((name :initarg :name :initform (error "NAME required.") :reader name)
   (task :initarg :task :initform (error "TASK required.") :reader task)
   (status :initarg :status :initform :inactive :accessor status)))

(defmethod print-object ((trigger trigger) stream)
  (print-unreadable-object (trigger stream :type T)
    (format stream "~s ~a" (name trigger) (status trigger))))

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

(defmethod shared-initialize :after ((action action) slots &key task on-activate on-deactivate)
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

(defmacro define-action ((storyline quest task name) &body initargs)
  (form-fiddle:with-body-options (body initargs on-activate on-deactivate class) initargs
    `(let* ((task (find-task ',task (find-quest ',quest (storyline ',storyline))))
            (action (or (find-trigger ',name task NIL)
                        (setf (find-trigger ',name task) (make-instance ',(or class 'action) :name ',name :task task)))))
       (reinitialize-instance action :on-activate ',(or on-activate (when body `(progn ,@body)) T)
                                     :on-deactivate '(or on-deactivate T)
                                     ,@initargs)
       ',name)))

(defclass interaction (trigger scope)
  ((interactable :initarg :interactable :reader interactable)
   (title :initarg :title :initform "<unknown>" :accessor title)
   (dialogue :accessor dialogue)))

(defmethod shared-initialize :after ((interaction interaction) slots &key dialogue)
  (when dialogue
    (setf (dialogue interaction) (dialogue:compile* dialogue (make-assembly interaction)))))

(defmethod make-assembly ((interaction interaction))
  (make-assembly (task interaction)))

(defmethod parent ((interaction interaction))
  (task interaction))

(defmethod try ((interaction interaction)))
(defmethod activate ((interaction interaction)))
(defmethod deactivate ((interaction interaction)))
(defmethod complete ((interaction interaction)))

(defmacro define-interaction ((storyline quest task name) &body initargs)
  (form-fiddle:with-body-options (body initargs class) initargs
    `(let* ((task (find-task ',task (find-quest ',quest (storyline ',storyline))))
            (action (or (find-trigger ',name task NIL)
                        (setf (find-trigger ',name task) (make-instance ',(or class 'interaction) :name ',name :task task)))))
       (reinitialize-instance action :dialogue (progn ,@body)
                              ,@initargs)
       ',name)))
