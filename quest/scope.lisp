(in-package #:org.shirakumo.fraf.kandria.quest)

(defclass scope ()
  ((initial-bindings :initform () :initarg :variables :accessor initial-bindings)
   (bindings :initform () :accessor bindings)))

(defmethod initialize-instance :after ((scope scope) &key)
  (reset scope))

(defgeneric reset (scope)
  (:method-combination progn))
(defgeneric parent (scope))
(defgeneric binding (name scope))
(defgeneric var (name scope &optional default))
(defgeneric (setf var) (value name scope))

(defmethod reset progn ((scope scope))
  (setf (bindings scope) (loop for binding in (initial-bindings scope)
                               collect (etypecase binding
                                         (cons (cons (first binding) (second binding)))
                                         (symbol (cons binding NIL))))))

(defmethod parent ((scope scope)) NIL)

(defmethod merge-bindings ((scope scope) bindings)
  (let ((existing (bindings scope)))
    (loop for (name . value) in bindings
          for prev = (assoc name (bindings scope))
          do (if prev
                 (setf (cdr prev) value)
                 (push (cons name value) existing)))
    (setf (bindings scope) existing)))

(defmethod binding (name (scope scope))
  (or (assoc name (bindings scope))
      (when (parent scope)
        (binding name (parent scope)))))

(defmethod var (name (scope scope) &optional default)
  (let ((binding (binding name scope)))
    (if binding
        (values (cdr binding) T)
        (values default NIL))))

(defmethod (setf var) (value name (scope scope))
  (let ((binding (binding name scope)))
    (cond (binding
           (setf (cdr binding) value))
          (T
           (v:warn :kandria.quest "Creating new binding for variable~%  ~s~%in~%  ~s" name scope)
           (push (cons name value) (bindings scope))
           value))))

(defmethod list-variables ((scope scope))
  (let ((vars (when (parent scope) (list-variables (parent scope)))))
    (dolist (binding (bindings scope) vars)
      (pushnew (car binding) vars))))
