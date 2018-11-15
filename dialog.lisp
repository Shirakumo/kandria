(in-package #:org.shirakumo.fraf.leaf)

(defclass dialog-entity ()
  ((emotes :initarg :emotes :accessor emotes)
   (profile :initarg :profile :accessor profile))
  (:default-initargs
   :emotes '(:default)
   :profile (error "PROFILE required.")))

(defvar *storyline-table* (make-hash-table :test 'eql))

(defclass storyline () ())
(defclass dialog () ())

(defmethod storyline ((name symbol))
  (gethash name *storyline-table*))

(defmethod (setf storyline) ((storyline storyline) (name symbol))
  (setf (gethash name *storyline-table*) value))

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
   (state-table :initform '() :accessor state-table)
   (dialogs :initform (make-hash-table :test 'eq) :accessor dialogs)
   (active-p :initform NIL :accessor active-p))
  (:default-initargs
   :name (error "NAME required.")
   :title (error "TITLE required.")
   :description ""
   :initial-state '()))

(defmethod initialize-instance :after ((storyline storyline) &key initial-state)
  (reset storyline))

(defmethod print-object ((storyline storyline) stream)
  (print-unreadable-object (storyline stream :type T)
    (format stream "~s ~:[INACTIVE~;ACTIVE~]" (name storyline) (active-p storyline))))

(defmethod state (key (storyline storyline))
  (gethash key (state-table storyline)))

(defmethod (setf state) (value key (storyline storyline))
  (setf (gethash key (state-table storyline)) value))

(defmethod reset ((storyline storyline))
  (setf (active-p storyline) NIL)
  (clrhash (state-table storyline))
  (loop for (k v) on initial-state by #'cddr
        do (setf (state k storyline) v)))

(defmethod compute-applicable-dialogs (event (all (eql T)))
  (loop for storyline in (list-storylines)
        append (compute-applicable-dialogs event storyline)))

(defmethod compute-applicable-dialogs (event (storyline storyline))
  (when (active-p storyline)
    (loop for dialog being the hash-values of (dialogs storyline)
          when (dialog-applicable-p dialog event)
          collect dialog)))

(defmethod dialog (name (storyline symbol))
  (dialog name (storyline storyline)))

(defmethod dialog (name (storyline storyline))
  (gethash name (dialogs storyline)))

(defmethod (setf dialog) (value name (storyline symbol))
  (setf (dialog name (storyline storyline)) value))

(defmethod (setf dialog) ((dialog dialog) name (storyline storyline))
  (setf (gethash name (dialogs storyline)) dialog))

(defmethod remove-dialog (name (storyline symbol))
  (remove-dialog name (storyline storyline)))

(defmethod remove-dialog (name (storyline storyline))
  (remhash name (dialogs storyline)))

(defvar *dialog-function-table* (make-hash-table :test 'eql))

(defun dialog-function (name)
  (or (gethash name *dialog-function-table*)
      (error "No dialog function named ~s" name)))

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
  (setf (shake-counter (unit :camera T)) 20))

(define-dialog-function :text (box text)
  (setf (text box) text))

(define-dialog-function :append (box text)
  ;; FIXME
  )

(define-dialog-function :pause (box duration)
  ;; FIXME
  )

(define-dialog-function :stop (box)
  (throw 'stop NIL))

(define-dialog-function :end (box)
  (funcall (state-change (current-dialog box))
           (storyline (current-dialog box)))
  (setf (current-dialog box) NIL))

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
    (nreverse sequence)))

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
                          :dialog-sequence ',(compile-dialog-sequence (append other body))))))
