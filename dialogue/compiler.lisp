(in-package #:org.shirakumo.fraf.leaf.dialogue.vm)

(defvar *root*)

(defun parse (thing)
  (cl-markless:parse thing (make-instance 'org.shirakumo.fraf.leaf.dialogue.syntax:parser)))

(defmethod compile ((thing components::component))
  (walk thing T))

(defmethod compile ((thing string))
  (compile (parse thing)))

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

(defmethod walk ((component components::blockquote-header) (assembly assembly)))

(defmethod walk :before ((component components::blockquote) (assembly assembly))
  (emit (make-instance 'source :source (components::source component)
                               :label component)
        assembly))

(defmethod walk :after ((component components::blockquote) (assembly assembly))
  (emit (make-instance 'confirm) assembly))

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
  (emit (make-instance 'confirm :label component) assembly))

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

(defmethod walk ((component components:eval) (assembly assembly))
  (emit (make-instance 'eval :form (components:form component)
                             :label component)
        assembly))

(defmethod walk ((component components:setf) (assembly assembly))
  (emit (make-instance 'eval :form `(setf ,(components:place component)
                                          ,(components:form component))
                             :label component)
        assembly))

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
