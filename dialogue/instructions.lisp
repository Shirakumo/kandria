(in-package #:org.shirakumo.fraf.kandria.dialogue)

(defclass instruction ()
  ((index :initarg :index :accessor index)
   (label :initarg :label :accessor label)))

(defmethod initialize-instance :after ((instruction instruction) &key)
  (unless (slot-boundp instruction 'label)
    (setf (label instruction) instruction)))

(defmethod print-object ((instruction instruction) stream)
  (print-unreadable-object (instruction stream)
    (format stream "~3d ~s~@[ ~a~]"
            (index instruction)
            (type-of instruction)
            (unless (eq instruction (label instruction))
              (label instruction)))))

(defclass noop (instruction)
  ())

(defclass source (instruction)
  ((name :initarg :name :accessor name)))

(defmethod print-object ((source source) stream)
  (print-unreadable-object (source stream)
    (format stream "~3d ~s ~s"
            (index source)
            (type-of source)
            (name source))))

(defclass jump (instruction)
  ((target :initarg :target :initform (error "TARGET required.") :accessor target)))

(defmethod print-object ((jump jump) stream)
  (print-unreadable-object (jump stream)
    (format stream "~3d ~s~@[ ~a~] -> ~a"
            (index jump)
            (type-of jump)
            (unless (eq jump (label jump))
              (label jump))
            (target jump))))

(defclass conditional (instruction)
  ((clauses :initarg :clauses :accessor clauses)))

(defmethod print-object ((conditional conditional) stream)
  (print-unreadable-object (conditional stream)
    (format stream "~3d ~s~@[ ~a~] -> ~{~a~^, ~}"
            (index conditional)
            (type-of conditional)
            (unless (eq conditional (label conditional))
              (label conditional))
            (mapcar #'cdr (clauses conditional)))))

(defclass dispatch (instruction)
  ((func :initarg :func :accessor func)
   (targets :initarg :targets :accessor targets)))

(defmethod print-object ((dispatch dispatch) stream)
  (print-unreadable-object (dispatch stream)
    (format stream "~3d ~s~@[ ~a~] ~s -> ~{~a~^, ~}"
            (index dispatch)
            (type-of dispatch)
            (unless (eq dispatch (label dispatch))
              (label dispatch))
            (func dispatch)
            (targets dispatch))))

(defclass emote (instruction)
  ((emote :initarg :emote :accessor emote)))

(defclass pause (instruction)
  ((duration :initarg :duration :accessor duration)))

(defclass placeholder (instruction)
  ((func :initarg :func :accessor func)))

(defclass choose (instruction)
  ())

(defclass commit-choice (jump)
  ())

(defclass confirm (instruction)
  ())

(defclass begin-mark (instruction)
  ((markup :initarg :markup :accessor markup)))

(defclass end-mark (instruction)
  ())

(defclass clear (instruction)
  ())

(defclass text (instruction)
  ((text :initarg :text :accessor text)))

(defmethod print-object ((text text) stream)
  (print-unreadable-object (text stream)
    (format stream "~3d ~s ~s"
            (index text)
            (type-of text)
            (text text))))

(defclass eval (instruction)
  ((func :initarg :func :accessor func)))

(defmethod print-object ((eval eval) stream)
  (print-unreadable-object (eval stream)
    (format stream "~3d ~s ~s"
            (index eval)
            (type-of eval)
            (form eval))))
