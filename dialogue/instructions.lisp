(in-package #:org.shirakumo.fraf.kandria.dialogue)

(defun print-instruction-type (instruction)
  (let ((type (string (type-of instruction))))
    (if (<= (length type) 6)
        (format T "~6a " type)
        (format T "~a " (subseq type 0 6)))))

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

(defmethod disassemble ((instruction instruction))
  (print-instruction-type instruction))

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

(defmethod disassemble :after ((instruction source))
  (format T "~a" (name instruction)))

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

(defmethod disassemble ((instruction jump))
  (print-instruction-type instruction)
  (format T "~a" (target instruction)))

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

(defmethod disassemble ((instruction conditional))
  (print-instruction-type instruction)
  (loop for (func . target) in (clauses instruction)
        do (format T "~&      ~2d  ~a" target func)))

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

(defmethod disassemble ((instruction emote))
  (print-instruction-type instruction)
  (format T "~a" (emote instruction)))

(defclass pause (instruction)
  ((duration :initarg :duration :accessor duration)))

(defmethod disassemble ((instruction pause))
  (print-instruction-type instruction)
  (format T "~a" (duration instruction)))

(defclass placeholder (instruction)
  ((func :initarg :func :accessor func)))

(defclass choose (instruction)
  ())

(defclass commit-choice (jump)
  ())

(defmethod disassemble ((instruction commit-choice))
  (print-instruction-type instruction)
  (format T "~a" (target instruction)))

(defclass confirm (instruction)
  ())

(defclass begin-mark (instruction)
  ((markup :initarg :markup :accessor markup)))

(defmethod disassemble ((instruction begin-mark))
  (print-instruction-type instruction)
  (format T "~s" (markup instruction)))

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

(defmethod disassemble ((instruction text))
  (print-instruction-type instruction)
  (format T "~s" (text instruction)))

(defclass eval (instruction)
  ((func :initarg :func :accessor func)))

(defmethod print-object ((eval eval) stream)
  (print-unreadable-object (eval stream)
    (format stream "~3d ~s ~s"
            (index eval)
            (type-of eval)
            (form eval))))

(defmethod disassemble ((instruction eval))
  (print-instruction-type instruction)
  (format T "~s" (func instruction)))
