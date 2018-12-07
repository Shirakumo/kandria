(in-package #:org.shirakumo.fraf.leaf)

(defvar *dialog-function-table* (make-hash-table :test 'eql))

(defun dialog-function (name)
  (or (gethash name *dialog-function-table*)
      (error "No dialog function named ~s exists." name)))

(defun (setf dialog-function) (fun name)
  (setf (gethash name *dialog-function-table*) fun))

(defun remove-dialog-function (name)
  (remhash name *dialog-function-table*))

(defmacro define-dialog-function (name (box &rest args) &body body)
  `(setf (dialog-function ',name)
         (lambda (,box ,@args)
           (declare (ignorable ,box))
           ,@body)))

(define-dialog-function :character (box name)
  (setf (target box) (unit name T)))

(define-dialog-function :emote (box emote)
  (setf (vx (trial:tile box))
        (position emote (emotes (target box)))))

(define-dialog-function :shake (box)
  (setf (shake-counter (unit :camera T)) 30))

(define-dialog-function :text (box text)
  (setf (text box) text))

(define-dialog-function :append (box text)
  (setf (text box) (format NIL "~a~a" (text box) text))
  (setf (cursor box) (- (length (text box)) (length text))))

(define-dialog-function :pause (box duration)
  (setf (clock box) (- duration)))

(define-dialog-function :eval (box form)
  (eval form))

(define-dialog-function :stop (box)
  (throw 'stop NIL))

(define-dialog-function :end (box)
  (let ((diag (current-dialog box)))
    (setf (state (name diag) (storyline diag)) T)
    (funcall (state-change diag) (storyline diag)))
  (setf (current-dialog box) NIL)
  (throw 'stop NIL))

(defclass dialog-entity (entity)
  ((emotes :initarg :emotes :accessor emotes)
   (profile :initarg :profile :accessor profile))
  (:default-initargs
   :emotes '(:default)
   :profile (error "PROFILE required.")))

(defvar *storyline-table* (make-hash-table :test 'eql))

(defclass storyline () ())
(defclass dialog () ())

(defmethod storyline ((name symbol))
  (or (gethash name *storyline-table*)
      (error "No storyline named ~s exists." name)))

(defmethod (setf storyline) ((storyline storyline) (name symbol))
  (setf (gethash name *storyline-table*) storyline))

(defun remove-storyline (name)
  (remhash name *storyline-table*))

(defun list-storylines ()
  (loop for storyline being the hash-values of *storyline-table*
        collect storyline))

(defclass storyline ()
  ((name :initarg :name :accessor name)
   (title :initarg :title :accessor title)
   (description :initarg :description :accessor description)
   (initial-state :initarg :initial-state :accessor initial-state)
   (state-table :initform (make-hash-table :test 'eq) :accessor state-table)
   (dialogs :initform (make-hash-table :test 'eq) :accessor dialogs)
   (active-p :initarg :active-p :accessor active-p))
  (:default-initargs
   :name (error "NAME required.")
   :title (error "TITLE required.")
   :description ""
   :initial-state '()
   :active-p NIL))

(defmethod initialize-instance :after ((storyline storyline) &key)
  (check-type (title storyline) string)
  (reset storyline))

(defmethod print-object ((storyline storyline) stream)
  (print-unreadable-object (storyline stream :type T)
    (format stream "~s ~:[INACTIVE~;ACTIVE~]" (name storyline) (active-p storyline))))

(defmacro define-storyline (name &body body)
  (form-fiddle:with-body-options (dialogs options title description initial-state) body
    (assert (null options))
    `(progn
       (setf (storyline ',name)
             (make-instance 'storyline
                            :name ',name
                            :title ,title
                            :description ,(or description "")
                            :initial-state ',initial-state))
       ,@(loop for (dialog . body) in dialogs
               collect `(define-dialog (,name ,dialog)
                          ,@body)))))

(defmethod state (key (storyline storyline))
  (gethash key (state-table storyline)))

(defmethod (setf state) (value key (storyline storyline))
  (setf (gethash key (state-table storyline)) value))

(defmethod reset ((storyline storyline))
  (setf (active-p storyline) NIL)
  (clrhash (state-table storyline))
  (loop for (k v) on (initial-state storyline) by #'cddr
        do (setf (state k storyline) v)))

(defmethod compute-applicable-dialogs (event (all (eql T)))
  (loop for storyline in (list-storylines)
        append (when (active-p storyline)
                 (compute-applicable-dialogs event storyline))))

(defmethod compute-applicable-dialogs (event (storyline storyline))
  (loop for dialog being the hash-values of (dialogs storyline)
        when (dialog-applicable-p dialog event)
        collect dialog))

(defmethod dialog (name (storyline symbol))
  (dialog name (storyline storyline)))

(defmethod dialog (name (storyline storyline))
  (or (gethash name (dialogs storyline))
      (error "No dialog named ~s found in ~a." name storyline)))

(defmethod (setf dialog) (value name (storyline symbol))
  (setf (dialog name (storyline storyline)) value))

(defmethod (setf dialog) ((dialog dialog) name (storyline storyline))
  (setf (gethash name (dialogs storyline)) dialog))

(defmethod remove-dialog (name (storyline symbol))
  (remove-dialog name (storyline storyline)))

(defmethod remove-dialog (name (storyline storyline))
  (remhash name (dialogs storyline)))

(defclass dialog ()
  ((name :initarg :name :accessor name)
   (predicate :initarg :predicate :accessor predicate)
   (state-change :initarg :state-change :accessor state-change)
   (title :initarg :title :accessor title)
   (storyline :initarg :storyline :accessor storyline)
   (dialog-sequence :initarg :dialog-sequence :accessor dialog-sequence))
  (:default-initargs
   :name (error "NAME required.")
   :predicate (error "PREDICATE required.")
   :state-change (constantly NIL)
   :title NIL
   :storyline (error "STORYLINE required")
   :dialog-sequence (error "DIALOG-SEQUENCE required.")))

(defmethod initialize-instance :after ((dialog dialog) &key)
  (check-type (predicate dialog) function)
  (check-type (state-change dialog) function)
  (check-type (storyline dialog) storyline)
  (check-type (dialog-sequence dialog) vector))

(defmethod print-object ((dialog dialog) stream)
  (print-unreadable-object (dialog stream :type T)
    (format stream "~s" (name dialog))))

(defmethod title :around ((dialog dialog))
  (or (call-next-method)
      (title (storyline dialog))))

(defmethod dialog ((n integer) (dialog dialog))
  (when (< n (length (dialog-sequence dialog)))
    (aref (dialog-sequence dialog) n)))

(defmethod dialog-applicable-p ((dialog dialog) event)
  (when (funcall (predicate dialog) event (storyline dialog))
    dialog))

(defun compile-dialog-sequence (dialog)
  (let ((sequence ()))
    (loop while dialog
          for (thing . rest) = dialog
          do (etypecase thing
               (symbol
                (push `(,thing ,@(loop for arg in (rest
                                                   (lambda-fiddle:extract-lambda-vars
                                                    (arg:arglist (dialog-function (pop dialog)))))
                                       collect (pop dialog)))
                      sequence))
               (string
                (push `(:text ,(pop dialog)) sequence)
                (push '(:stop) sequence))))
    (push '(:end) sequence)
    (coerce (nreverse sequence) 'simple-vector)))

(defun compile-dialog-state-change (form)
  (let ((storyline (gensym "STORYLINE")))
    (labels ((compile-form (form)
               (typecase form
                 (cons
                  (case (first form)
                    (quote form)
                    (T (list* (first form)
                              (loop for sub in (cdr form)
                                    collect (compile-form sub))))))
                 ((and symbol (not keyword) (not (member NIL T)))
                  `(state ',form ,storyline))
                 (atom form))))
      `(lambda (,storyline)
         (declare (ignorable ,storyline))
         ,(compile-form form)))))

(defun compile-dialog-predicate (form)
  (let ((storyline (gensym "STORYLINE")))
    (labels ((compile-form (form)
               (typecase form
                 (cons
                  (case (first form)
                    (quote form)
                    (T (list* (first form)
                              (loop for sub in (cdr form)
                                    collect (compile-form sub))))))
                 ((and symbol (not keyword) (not (member ev NIL T)))
                  `(state ',form ,storyline))
                 (atom form))))
      `(lambda (ev ,storyline)
         (declare (ignorable ev ,storyline))
         ,(compile-form form)))))

(defmacro define-dialog ((storyline name) &body body)
  (form-fiddle:with-body-options (body other predicate state-change title) body
    `(setf (dialog ',name ',storyline)
           (make-instance 'dialog
                          :name ',name
                          :storyline (storyline ',storyline)
                          :predicate ,(compile-dialog-predicate predicate)
                          :state-change ,(compile-dialog-state-change state-change)
                          :title ,title
                          :dialog-sequence ,(compile-dialog-sequence (append other body))))))
