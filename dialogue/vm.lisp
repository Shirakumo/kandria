(in-package #:org.shirakumo.fraf.leaf.dialogue.vm)

(defun parse (thing)
  (cl-markless:parse thing (make-instance 'org.shirakumo.fraf.leaf.dialogue.syntax:parser)))

(defclass instruction ()
  ((index :initarg :index :accessor index)
   (label :initarg :label :accessor label)))

(defmethod initialize-instance :after ((instruction instruction) &key)
  (unless (slot-boundp instruction 'label)
    (setf (label instruction) instruction)))

(defmethod print-object ((instruction instruction) stream)
  (print-unreadable-object (instruction stream :type T)
    (format stream "~d ~a" (index instruction)
            (if (eq instruction (label instruction))
                "@self"
                (label instruction)))))

(defclass noop (instruction)
  ())

(defclass source (instruction)
  ((source :initarg :source :accessor source)))

(defclass jump (instruction)
  ((target :initarg :target :initform (error "TARGET required.") :accessor target)))

(defmethod print-object ((jump jump) stream)
  (print-unreadable-object (jump stream :type T)
    (format stream "~d ~a -> ~a"
            (index jump)
            (if (eq jump (label jump))
                "@self"
                (label jump))
            (target jump))))

(defclass conditional (instruction)
  ((clauses :initarg :clauses :accessor clauses)))

(defclass choose (instruction)
  ())

(defclass commit-choice (instruction)
  ((target :initarg :target :accessor target)))


(defclass assembly ()
  ((instructions :initform (make-array 0 :adjustable T :fill-pointer T) :reader instructions)))

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

(defmethod walk :before ((component components::blockquote) (assembly assembly))
  (emit (make-instance 'source :source (components::source component)
                               :label component)
        assembly))

(defmethod walk ((component components:jump) (assembly assembly))
  (emit (make-instance 'jump :target (components::target component)
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
      (setf (clauses conditional) clauses)
      (emit end assembly))))

(defmethod walk ((component components::unordered-list) (assembly assembly))
  (let ((choose (make-instance 'choose :label component))
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
                                                      component))
                     assembly)
               (emit (make-instance 'noop :label children) assembly)
               (loop for i from 1 below (length children)
                     do (walk (aref children i) assembly))))
    (emit choose assembly)))

(defmethod walk ((string string) (assembly assembly))
  ;; (vector-push-extend string (instructions assembly))
  )
