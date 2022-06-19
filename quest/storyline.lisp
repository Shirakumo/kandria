(in-package #:org.shirakumo.fraf.kandria.quest)

(defvar *storylines* ())

(defclass storyline (describable scope)
  ((name :initform 'storyline)
   (title :initform "storyline")
   (quests :initform (make-hash-table :test 'eql) :reader quests)
   (known-quests :initform () :accessor known-quests)
   (on-activate :initarg :on-activate :initform () :accessor on-activate)))

(defmethod class-for ((storyline (eql 'storyline))) 'storyline)

(defmethod reset progn ((storyline storyline) &key (reset-vars T))
  (setf (known-quests storyline) ())
  (loop for quest being the hash-values of (quests storyline)
        do (reset quest :reset-vars reset-vars)))

(defmethod activate ((storyline storyline))
  (etypecase (on-activate storyline)
    (list
     (dolist (thing (on-activate storyline))
       (activate (find-named thing storyline))))
    (T
     (loop for thing being the hash-values of (tasks storyline)
           do (activate thing)))))

(defmethod try ((storyline storyline))
  (loop for quest in (known-quests storyline)
        do (when (active-p quest)
             (try quest))))

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

(defmethod find-named (name (any (eql T)) &optional (error T))
  (or (storyline name)
      (when error (error "No storyline named ~s found." name))))

(defmethod storyline ((name (eql T)))
  (first *storylines*))

(defmethod storyline ((name symbol))
  (find name *storylines* :key #'name))

(defmethod (setf storyline) ((storyline storyline) (name symbol))
  (setf *storylines* (list* storyline (remove name *storylines* :key #'name)))
  storyline)

(defmacro define-storyline (name &body initargs)
  (form-fiddle:with-body-options (body initargs variables on-activate (class (class-for 'storyline))) initargs
    `(let ((storyline (or (storyline ',name)
                          (setf (storyline ',name) (make-instance ',class :name ',name ,@initargs)))))
       (reinitialize-instance storyline :variables ',variables
                                        :on-activate ',on-activate
                              ,@initargs)
       ,@(loop for (quest . options) in body
               collect `(define-quest (,name ,quest)
                          ,@options))
       ',name)))

(defun print-storyline (storyline &key (stream *standard-output*) (status T) (active-only NIL))
  (let ((storyline (etypecase storyline
                     (symbol (storyline storyline))
                     (storyline storyline))))
    (labels ((out (f &rest a) (format stream "~&~?~%" f a))
             (check (thing) (and (or (eql status T) (eql status (status thing)))
                                 (or (not active-only) (active-p thing))))
             (line (spaces prefix thing)
               (out "~a~a ~a ~a~50t[~a]~{~%~{~a   ~a~}~}" spaces prefix (type-of thing) (name thing) (status thing)
                    (when (typep thing 'scope) (loop for binding in (bindings thing)
                                                     collect (list spaces binding))))))
      (out "STORYLINE ~a" (name storyline))
      (loop for quest being the hash-values of (quests storyline)
            do (when (check quest)
                 (line " " "=>" quest)
                 (loop for task being the hash-values of (tasks quest)
                       do (when (check task)
                            (line "  " "->" task)
                            (loop for trigger being the hash-values of (triggers task)
                                  do (when (check trigger)
                                       (line "    " ">" trigger))))))))))

(defun %update (&rest changes)
  (loop for (thing state) on changes by #'cddr
        for object = (etypecase thing
                       ((eql T) (storyline T))
                       (symbol (find-quest thing (storyline T)))
                       (list
                        (loop for name in thing
                              for object = (find-named name T) then (find-named name object T)
                              finally (return object))))
        do (ecase state
             (:active (activate object))
             (:inactive (deactivate object))
             (:complete (complete object))
             (:failed (fail object))
             (:reset (reset object))))
  (print-storyline T :active-only T))

(defmacro update (&rest changes)
  `(%update ,@(loop for change in changes collect `',change)))
