(in-package #:org.shirakumo.fraf.kandria.dialogue)

(defvar *root*)

(defun parse (thing)
  (cl-markless:parse thing (make-instance 'org.shirakumo.fraf.kandria.dialogue.syntax:parser)))

(defmethod compile ((thing mcomponents:component) assembly)
  (walk thing assembly))

(defmethod compile ((thing string) assembly)
  (compile (parse thing) assembly))

(defmethod compile (thing (assembly (eql T)))
  (compile thing (make-instance 'assembly)))

(defgeneric wrap-lexenv (assembly form)
  (:method (_ form)
    `(progn ,form)))

(defun compile-form (assembly form)
  (cl:compile NIL `(lambda () ,(wrap-lexenv assembly form))))

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

(defmacro define-simple-walker (component instruction &rest initargs)
  `(defmethod walk ((component ,component) (assembly assembly))
     (emit (make-instance ',instruction
                          :label component
                          ,@initargs)
           assembly)))

(defmacro define-markup-walker (component &body markup)
  `(progn (defmethod walk :before ((component ,component) (assembly assembly))
            (emit (make-instance 'begin-mark :label component
                                             :markup (progn ,@markup))
                  assembly))
          (defmethod walk :after ((component ,component) (assembly assembly))
            (emit (make-instance 'end-mark) assembly))))

(defmethod walk ((component mcomponents:parent-component) (assembly assembly))
  (loop for child across (mcomponents:children component)
        do (walk child assembly)))

(defun resolved-target (component)
  (or (mcomponents:label (mcomponents:target component) *root*)
      (error "Label ~s cannot be resolved to any target component."
             (mcomponents:target component))))

(defmethod walk ((component mcomponents:root-component) (assembly assembly))
  (let ((*root* component))
    (call-next-method)))

(defmethod walk ((component mcomponents:blockquote-header) (assembly assembly)))

(defmethod walk :before ((component mcomponents:blockquote) (assembly assembly))
  (when (mcomponents:source component)
    (emit (make-instance 'source :label component
                                 :name (components:name (mcomponents:source component)))
          assembly)))

(defmethod walk :after ((component mcomponents:blockquote) (assembly assembly))
  (emit (make-instance 'confirm) assembly))

(defmethod walk ((component components:conditional) (assembly assembly))
  (let ((conditional (make-instance 'conditional :label component)))
    (emit conditional assembly)
    (let* ((end (make-instance 'noop))
           (clauses (loop for (predicate . children) across (components:clauses component)
                          for index = (next-index assembly)
                          do (loop for child across children
                                   do (walk child assembly))
                             (emit (make-instance 'jump :target end) assembly)
                          collect (cons (compile-form assembly predicate) index))))
      (setf (clauses conditional) (append clauses (list (cons T (next-index assembly)))))
      (emit end assembly))))

(defmethod walk ((component mcomponents:unordered-list) (assembly assembly))
  (let ((choose (make-instance 'choose))
        (end (make-instance 'noop))
        (items (mcomponents:children component)))
    (loop for i from 0 below (length items)
          for item = (aref items i)
          for children = (mcomponents:children item)
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
                     do (walk (aref children i) assembly))
               (emit (make-instance 'jump :target end) assembly)))
    (emit choose assembly)
    (emit end assembly)))

(defmethod walk ((string string) (assembly assembly))
  (emit (make-instance 'text :text string) assembly))

(defmethod walk ((component components:conditional-part) (assembly assembly))
  (let ((dispatch (make-instance 'dispatch :func (compile-form assembly (components:form component)) 
                                           :label component)))
    (emit dispatch assembly)
    (let* ((end (make-instance 'noop))
           (targets (loop for choice across (components:choices component)
                          for index = (next-index assembly)
                          do (loop for i from 0 below (length choice)
                                   for child = (aref choice i)
                                   do (unless (and (= i 0)
                                                   (typep child 'mcomponents:newline))
                                        (walk child assembly)))
                             (emit (make-instance 'jump :target end) assembly)
                          collect index)))
      (setf (targets dispatch) targets)
      (emit end assembly))))

(define-markup-walker components:clue
  (list :clue (components:clue component)))

(define-markup-walker mcomponents:bold
  (list :bold T))

(define-markup-walker mcomponents:italic
  (list :italic T))

(define-markup-walker mcomponents:strikethrough
  (list :strikethrough T))

(define-markup-walker mcomponents:supertext
  (list :supertext T))

(define-markup-walker mcomponents:subtext
  (list :subtext T))

(define-markup-walker mcomponents:compound
  (loop for option in (mcomponents:options component)
        append (etypecase option
                 (mcomponents:bold-option '(:bold T))
                 (mcomponents:italic-option '(:italic T))
                 (mcomponents:underline-option '(:underline T))
                 (mcomponents:strikethrough-option '(:strikethrough T))
                 (mcomponents:spoiler-option '(:spoiler T))
                 (mcomponents:font-option (list :font (mcomponents:font-family option)))
                 (mcomponents:color-option (list :color (3d-vectors:vec3
                                                         (mcomponents:red option)
                                                         (mcomponents:green option)
                                                         (mcomponents:blue option))))
                 (mcomponents:size-option (list :size (mcomponents:size option))))))

(define-simple-walker components:jump jump
  :target (resolved-target component))

(define-simple-walker mcomponents:label noop)

(define-simple-walker mcomponents:footnote noop)

(define-simple-walker components:go jump
  :target (resolved-target component))

(define-simple-walker mcomponents:newline confirm)

(define-simple-walker components:eval eval
  :func (compile-form assembly (components:form component)))

(define-simple-walker components:setf eval
  :func (compile-form assembly `(setf ,(components:place component)
                                      ,(components:form component))))

(define-simple-walker components:emote emote
  :emote (components:emote component))

(define-simple-walker mcomponents:en-dash pause
  :duration 0.5)

(define-simple-walker mcomponents:em-dash pause
  :duration 1.0)

(define-simple-walker components:placeholder placeholder
  :func (compile-form assembly (components:form component)))

;; TODO: implement the following
;; speed
;; move
;; zoom
;; roll
;; show
