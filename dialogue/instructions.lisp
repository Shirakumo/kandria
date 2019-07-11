(in-package #:org.shirakumo.fraf.leaf.dialogue.vm)

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
  ((source :initarg :source :accessor source)))

(defmethod print-object ((source source) stream)
  (print-unreadable-object (source stream)
    (format stream "~3d ~s ~s"
            (index source)
            (type-of source)
            (source source))))

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
            (clauses conditional))))

(defclass dispatch (instruction)
  ((form :initarg :form :accessor form)
   (targets :initarg :targets :accessor targets)))

(defmethod print-object ((dispatch dispatch) stream)
  (print-unreadable-object (dispatch stream)
    (format stream "~3d ~s~@[ ~a~] ~s -> ~{~a~^, ~}"
            (index dispatch)
            (type-of dispatch)
            (unless (eq dispatch (label dispatch))
              (label dispatch))
            (form dispatch)
            (targets dispatch))))

(defclass choose (instruction)
  ())

(defclass commit-choice (jump)
  ())

(defclass confirm (instruction)
  ())

(defclass begin-mark (instruction)
  ((markup :initarg :markup :accessor markup)))

(defclass end-mark (instruction)
  ((markup :initarg :markup :accessor markup)))

(defclass text (instruction)
  ((text :initarg :text :accessor text)))

(defmethod print-object ((text text) stream)
  (print-unreadable-object (text stream)
    (format stream "~3d ~s ~s"
            (index text)
            (type-of text)
            (text text))))

(defclass eval (instruction)
  ((form :initarg :form :accessor form)))

(defmethod print-object ((eval eval) stream)
  (print-unreadable-object (eval stream)
    (format stream "~3d ~s ~s"
            (index eval)
            (type-of eval)
            (form eval))))
