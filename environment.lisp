(in-package #:org.shirakumo.fraf.kandria)

(defvar *environments* (make-hash-table :test 'eql))

(defclass audible-entity (entity)
  ((voice :initarg :voice :accessor voice)))

(defmethod stage :after ((entity audible-entity) (area staging-area))
  (when (typep (voice entity) 'placeholder-resource)
    (let ((generator (generator (voice entity))))
      (setf (voice entity) (apply #'generate-resources generator (input* generator) :resource NIL (trial::generation-arguments generator)))))
  (stage (voice entity) area))

(defmethod active-p ((entity audible-entity)) T)

(defmethod handle :after ((ev tick) (entity audible-entity))
  (when (active-p entity)
    (let* ((voice (voice entity))
           (max (expt (mixed:max-distance voice) 2))
           (dist (vsqrdistance (location entity) (location (unit 'player +world+)))))
      (cond ((< dist (+ max 32)) ; Start a bit before the entrance to ensure we have a smooth ramp up.
             (harmony:play voice :location (location entity)))
            ((< (+ max 128) dist) ; Stop even farther out to ensure we don't accidentally flip-flop and overburden the sound server.
             (harmony:stop voice))))))

(defclass switch-music-state (event)
  ((area :initarg :area :initform NIL :reader area)
   (state :initarg :state :initform NIL :reader state)))

(defun (setf music-state) (state area)
  (issue +world+ 'switch-music-state :area area :state state))

(defclass environment () ()) ; Early def
(defclass environment-controller (unit listener)
  ((name :initform 'environment)
   (environment :initarg :environment :initform NIL :accessor environment)
   (area-states :initarg :area-states :initform NIL :accessor area-states)
   (override :initarg :override :initform NIL :accessor override)))

(defmethod stage :after ((controller environment-controller) (area staging-area))
  (when (environment controller) (stage (environment controller) area))
  (when (override controller) (stage (override controller) area)))

(defmethod reset ((controller environment-controller))
  (setf (area-states controller) ())
  (when (override controller)
    (harmony:transition (override controller) 0.0 :in 0.1)
    (setf (slot-value controller 'override) NIL))
  (let ((env (environment controller)))
    (when env
      (when (music env)
        (harmony:transition (music env) 0.0 :in 0.1))
      (when (ambience env)
        (harmony:transition (ambience env) 0.0 :in 0.1))
      (setf (environment controller) NIL))))

(defmethod handle ((ev switch-chunk) (controller environment-controller))
  (switch-environment controller (environment (chunk ev))))

(defmethod handle ((ev switch-music-state) (controller environment-controller))
  (let* ((env (environment controller))
         (area (or (area ev) (area env)))
         (state (state ev))
         (cons (assoc area (area-states controller))))
    (if cons
        (setf (cdr cons) state)
        (push (cons area state) (area-states controller)))
    (when (and env
               (eql area (area env))
               (null (override controller)))
      (when (music env)
        (harmony:transition (music env) state :in 5.0))
      (when (ambience env)
        (harmony:transition (ambience env) state :in 3.0)))))

(defmethod switch-environment ((controller environment-controller) (name symbol))
  (cond (name
         (switch-environment controller (environment name)))
        (T
         (switch-environment (environment controller) NIL)
         (setf (environment controller) NIL))))

(defmethod switch-environment ((controller environment-controller) (environment environment))
  (unless (override controller)
    (when (allocated-p environment)
      (switch-environment (environment controller) environment)))
  (setf (environment controller) environment))

(defmethod (setf override) :before ((override null) (controller environment-controller))
  (when (override controller)
    (harmony:transition (override controller) 0.0 :in 5.0))
  (switch-environment NIL (environment controller)))

(defmethod (setf override) :before ((override (eql 'null)) (controller environment-controller))
  (when (override controller)
    (harmony:transition (override controller) 0.0 :in 5.0))
  (switch-environment (environment controller) NIL))

(defmethod (setf override) :before ((override resource) (controller environment-controller))
  (when (allocated-p override)
    (unless (eq override (override controller))
      (if (override controller)
          (harmony:transition (override controller) 0.0 :in 3.0)
          (switch-environment (environment controller) NIL))
      (harmony:transition override 1.0 :in 3.0))))

(defmethod harmony:transition ((controller environment-controller) (to real) &key (in 1.0))
  (cond ((override controller)
         (harmony:transition (override controller) to :in in))
        ((environment controller)
         (harmony:transition (environment controller) to :in in))))

(defmethod handle ((event load-complete) (controller environment-controller))
  (let ((override (override controller))
        (environment (environment controller)))
    (setf (override controller) NIL)
    (setf (environment controller) NIL)
    (setf (override controller) override)
    (switch-environment controller environment)))

(defmethod harmony:transition ((nothing (eql 'null)) to &key in)
  (declare (ignore nothing to in)))

(defclass environment ()
  ((name :initarg :name :initform NIL :accessor name)
   (music :initarg :music :initform NIL :accessor music)
   (ambience :initarg :ambience :initform NIL :accessor ambience)
   (area :initarg :area :initform NIL :accessor area)))

(defmethod allocated-p ((environment environment))
  (let ((music (music environment))
        (ambience (ambience environment)))
    (and (or (null ambience) (allocated-p ambience))
         (or (null music) (allocated-p music)))))

(defmethod stage ((environment environment) (area staging-area))
  (when (music environment) (stage (music environment) area))
  (when (ambience environment) (stage (ambience environment) area)))

(defmethod state ((environment environment))
  (let* ((controller (unit 'environment +world+))
         (cons (assoc (area environment) (area-states controller))))
    (if cons
        (cdr cons)
        :normal)))

(defmethod (setf state) (state (environment environment))
  (issue +world+ 'switch-area-state :area (area environment) :state state))

(defmethod quest:activate ((environment environment))
  (let ((controller (unit 'environment +world+)))
    (when (not (eq environment (environment controller)))
      (switch-environment (environment controller) environment))))

(defmethod switch-environment ((a null) (b null)))

(defmethod switch-environment ((none null) (environment environment))
  (let ((state (state environment)))
    (when (music environment)
      (harmony:transition (music environment) state :in 5.0 :error NIL))
    (when (ambience environment)
      (harmony:transition (ambience environment) state :in 3.0 :error NIL))))

(defmethod switch-environment ((environment environment) (none null))
  (when (music environment)
    (harmony:transition (music environment) NIL :in 3.0))
  (when (ambience environment)
    (harmony:transition (ambience environment) NIL :in 5.0)))

(defmethod switch-environment ((from environment) (to environment))
  (let ((state (state to)))
    (flet ((tx (a b in &optional (state state))
             (unless (eq a b)
               (when a
                 (harmony:transition a NIL :in in)))
             (when b
               (harmony:transition b state :in in :error NIL))))
      (tx (music from) (music to) 5.0)
      (tx (ambience from) (ambience to) 3.0 :normal))))

(defmethod harmony:transition ((environment environment) (to real) &key (in 1.0))
  (when (music environment)
    (harmony:transition (music environment) to :in in))
  (when (ambience environment)
    (harmony:transition (ambience environment) to :in in)))

(defmethod environment ((name symbol))
  (gethash name *environments*))

(defmethod (setf environment) (value (name symbol))
  (setf (gethash name *environments*) value))

(defun list-environments ()
  (loop for env being the hash-values of *environments*
        collect env))

(defmacro define-environment ((area name) &body initargs)
  (let ((music (getf initargs :music))
        (ambience (getf initargs :ambience))
        (initargs (remf* initargs :music :ambience))
        (name (trial::mksym *package* area '/ name)))
    `(setf (environment ',name)
           (ensure-instance (environment ',name) 'environment
                            :area ',area
                            :name ',name
                            :music ,(when music `(// 'music ,music))
                            :ambience ,(when ambience `(// 'music ,ambience))
                            ,@initargs))))

(trial-alloy:define-set-representation environment/combo
  :represents environment
  :item-text (string (when alloy:value (name alloy:value)))
  (list-environments))
