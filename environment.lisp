(in-package #:org.shirakumo.fraf.kandria)

(defvar *environments* (make-hash-table :test 'eql))

(defclass switch-music-state (event)
  ((area :initarg :area :initform NIL :reader area)
   (state :initarg :state :initform NIL :reader state)))

(defclass environment-controller (unit listener)
  ((name :initform 'environment)
   (environment :initarg :environment :initform NIL :accessor environment)
   (area-states :initarg :area-states :initform NIL :accessor area-states)
   (override :initarg :override :initform NIL :accessor override)))

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
    (when (and (eql area (area env))
               (null (override controller)))
      (when (music env)
        (harmony:transition (music env) state :in 5.0))
      (when (ambience env)
        (harmony:transition (ambience env) state :in 3.0)))))

(defmethod switch-environment ((controller environment-controller) environment)
  (unless (override controller)
    (switch-environment (environment controller) environment))
  (setf (environment controller) environment))

(defmethod (setf override) :before ((override null) (controller environment-controller))
  (when (override controller)
    (harmony:transition (override controller) 0.0 :in 3.0))
  (switch-environment NIL (environment controller)))

(defmethod (setf override) :before ((override (eql null)) (controller environment-controller))
  (when (override controller)
    (harmony:transition (override controller) 0.0 :in 3.0))
  (switch-environment (environment controller) NIL))

(defmethod (setf override) :before (override (controller environment-controller))
  (when (override controller)
    (harmony:transition (override controller) 0.0 :in 3.0))
  (harmony:transition override 1.0 :in 3.0))

(defclass environment ()
  ((name :initarg :name :initform NIL :accessor name)
   (music :initarg :music :initform NIL :accessor music)
   (ambience :initarg :ambience :initform NIL :accessor ambience)
   (area :initarg :area :initform NIL :accessor area)))

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

(defmethod switch-environment ((controller environment-controller) (environment environment))
  (switch-environment (environment controller) environment)
  (setf (environment controller) environment))

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
    (flet ((tx (a b in)
             (unless (eq a b)
               (when a
                 (harmony:transition a NIL :in in)))
             (when b
               (harmony:transition b state :in in :error NIL))))
      (tx (music from) (music to) 5.0)
      (tx (ambience from) (ambience to) 3.0))))

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

(define-environment (grave hall)
  :music NIL
  :ambience 'ambience/large-underground-hall)

(define-environment (grave tutorial)
  :music NIL
  :ambience 'ambience/underground-building)

(define-environment (desert surface)
  :music NIL
  :ambience 'ambience/desert)

(define-environment (desert camp)
  :area 'desert
  :music NIL
  :ambience 'ambience/camp)

(define-environment (desert building)
  :area 'desert
  :music NIL
  :ambience 'ambience/desolate-building)

(define-environment (region1 cave)
  :area 'region1
  :music 'music/region1
  :ambience 'ambience/cave)

(define-environment (region1 hall)
  :area 'region1
  :music 'music/region1
  :ambience 'ambience/large-underground-hall)

(define-environment (region1 building)
  :area 'region1
  :music 'music/region1
  :ambience 'ambience/underground-building)
