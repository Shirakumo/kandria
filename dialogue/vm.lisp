(in-package #:org.shirakumo.fraf.leaf.dialogue.vm)
(defvar *root*)

(defun parse (thing)
  (cl-markless:parse thing (make-instance 'org.shirakumo.fraf.leaf.dialogue.syntax:parser)))

(defmethod compile ((thing components::component))
  (walk thing T))

(defmethod compile ((thing string))
  (compile (parse thing)))

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

(defclass wait (instruction)
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

(defclass assembly ()
  ((instructions :initform (make-array 0 :adjustable T :fill-pointer T) :accessor instructions)))

(defmethod next-index ((assembly assembly))
  (length (instructions assembly)))

(defmethod emit ((instruction instruction) (assembly assembly))
  (setf (index instruction) (next-index assembly))
  (vector-push-extend instruction (instructions assembly)))

(defgeneric walk (ast assembly))

(defmethod walk (thing assembly))

(defmethod walk :around (thing (assembly (eql T)))
  (walk thing (make-instance 'assembly)))

(defmethod walk :around (thing assembly)
  (call-next-method)
  assembly)

(defmethod walk ((component components::parent-component) (assembly assembly))
  (loop for child across (components::children component)
        do (walk child assembly)))

(defun resolved-target (component)
  (or (components::label (components::target component) *root*)
      (error "Label ~s cannot be resolved to any target component."
             (components::target component))))

(defmethod walk ((component components::root-component) (assembly assembly))
  (let ((*root* component))
    (call-next-method)))

(defmethod walk :before ((component components::blockquote) (assembly assembly))
  (emit (make-instance 'source :source (components::source component)
                               :label component)
        assembly))

(defmethod walk :after ((component components::blockquote) (assembly assembly))
  (emit (make-instance 'wait) assembly))

(defmethod walk ((component components:jump) (assembly assembly))
  (emit (make-instance 'jump :target (resolved-target component)
                             :label component)
        assembly))

(defmethod walk ((component components:conditional) (assembly assembly))
  (let ((conditional (make-instance 'conditional :label component)))
    (emit conditional assembly)
    (let* ((end (make-instance 'noop))
           (clauses (loop for (predicate . children) across (components:clauses component)
                          for index = (next-index assembly)
                          do (loop for child across children
                                   do (walk child assembly)
                                      (emit (make-instance 'jump :target end) assembly))
                          collect (cons predicate index))))
      (setf (clauses conditional) (append clauses (list (cons T (next-index assembly)))))
      (emit end assembly))))

(defmethod walk ((component components::unordered-list) (assembly assembly))
  (let ((choose (make-instance 'choose))
        (items (components::children component)))
    (loop for i from 0 below (length items)
          for item = (aref items i)
          for children = (components::children item)
          do (when (/= 0 (length children))
               (emit (make-instance 'noop :label item) assembly)
               (walk (aref children 0) assembly)
               (emit (make-instance 'commit-choice :target children) assembly)
               (emit (make-instance 'jump :target (if (< i (1- (length items)))
                                                      (aref items (1+ i))
                                                      choose))
                     assembly)
               (emit (make-instance 'noop :label children) assembly)
               (loop for i from 1 below (length children)
                     do (walk (aref children i) assembly))))
    (emit choose assembly)))

(defmethod walk ((component components::label) (assembly assembly))
  (emit (make-instance 'noop :label component) assembly))

(defmethod walk :before ((component components::footnote) (assembly assembly))
  (emit (make-instance 'noop :label component) assembly))

(defmethod walk ((component components:go) (assembly assembly))
  (emit (make-instance 'jump :target (resolved-target component)
                             :label component)
        assembly))

(defmethod walk ((string string) (assembly assembly))
  (emit (make-instance 'text :text string) assembly))

(defmethod walk ((component components::newline) (assembly assembly))
  (emit (make-instance 'wait :label component) assembly))

(defmethod walk ((component components:conditional-part) (assembly assembly))
  (let ((dispatch (make-instance 'dispatch :form (components:form component)
                                           :label component)))
    (emit dispatch assembly)
    (let* ((end (make-instance 'noop))
           (targets (loop for choice across (components:choices component)
                          for index = (next-index assembly)
                          do (loop for child across choice
                                   do (walk child assembly)
                                      (emit (make-instance 'jump :target end) assembly))
                          collect index)))
      (setf (targets dispatch) targets)
      (emit end assembly))))

;; placeholder
;; emote
;; clue
;; speed
;; move
;; zoom
;; roll
;; show
;; setf
;; eval
;; en-dash
;; em-dash

(defclass pass () ())

(defmethod run-pass ((pass symbol) thing)
  (run-pass (make-instance pass) thing))

(defmethod run-pass ((pass pass) (assembly assembly))
  (let ((*root* assembly))
    (loop for instruction across (instructions assembly)
          do (run-pass pass instruction)))
  assembly)

(defmethod run-pass ((pass pass) (instruction instruction)))

(defun optimize-instructions (assembly)
  (loop for pass in '(jump-resolution-pass noop-elimination-pass)
        do (run-pass pass assembly))
  assembly)

(defclass jump-resolution-pass (pass)
  ((label-map :initform (make-hash-table :test 'eq) :reader label-map)))

(defmethod run-pass :before ((pass jump-resolution-pass) (assembly assembly))
  ;; Gather all labels into a table
  (loop for instruction across (instructions assembly)
        do (setf (gethash (label instruction) (label-map pass)) (index instruction))
           (setf (label instruction) instruction)))

;; Resolve jump targets
(defmethod run-pass ((pass jump-resolution-pass) (instruction jump))
  (setf (target instruction) (or (gethash (target instruction) (label-map pass))
                                 (error "Jump to unknown target: ~s" (target instruction)))))

(defclass noop-elimination-pass (pass)
  ((label-map :initform (make-hash-table :test 'eq) :reader label-map)))

(defun find-new-index (target)
  (loop with instructions = (instructions *root*)
        for i from target below (length instructions)
        for other = (aref instructions i)
        while (typep other 'noop)
        finally (return (index other))))

(defmethod run-pass :before ((pass noop-elimination-pass) (assembly assembly))
  ;; Map all instruction indices to ones as if noops did not exist.
  (loop with i = 0
        for instruction across (instructions assembly)
        do (unless (typep instruction 'noop)
             (setf (index instruction) i)
             (incf i))))

;; Rewrite jumps to such that they point to the index after any noops
(defmethod run-pass ((pass noop-elimination-pass) (instruction jump))
  (setf (target instruction) (find-new-index (target instruction))))

(defmethod run-pass ((pass noop-elimination-pass) (instruction conditional))
  (loop for clause in (clauses instruction)
        do (setf (cdr clause) (find-new-index (cdr clause)))))

(defmethod run-pass ((pass noop-elimination-pass) (instruction dispatch))
  (map-into (targets instruction) #'find-new-index (targets instruction)))

(defmethod run-pass :after ((pass noop-elimination-pass) (assembly assembly))
  ;; Remove any noops from the instructions
  (setf (instructions assembly)
        (delete-if (lambda (instruction)
                     (typep instruction 'noop))
                   (instructions assembly))))

;; TODO: dead code elimination
;; TODO: ensure all jump targets are in-bounds
