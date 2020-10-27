(in-package #:org.shirakumo.fraf.kandria)

(defvar *effects* (make-hash-table :test 'eq))

(defmethod effect ((name symbol))
  (or (gethash name *effects*)
      (error "No effect named ~s found." name)))

(defmethod (setf effect) (value (name symbol))
  (if value
      (setf (gethash name *effects*) value)
      (remhash name *effects*))
  value)

(defmacro define-effect (name type &body initargs)
  `(setf (effect ',name) (list ',type ,@initargs)))

(defclass effect () ())

(defgeneric trigger (effect source &key))

(defmethod trigger ((effect symbol) source &rest args)
  (apply #'trigger (apply #'make-instance (effect effect)) source args))

(defclass per-world-effect (effect) ())

(defmethod trigger :around ((effect per-world-effect) source &key)
  )

(defclass per-entity-effect (effect) ())

(defmethod trigger :around ((effect per-entity-effect) source &key)
  )

(defclass sound-effect (effect)
  ((voice :accessor voice)))

(defmethod initialize-instance :after ((effect sound-effect) &key voice)
  (when voice
    (setf (voice effect) (if (typep voice 'sequence)
                             (alexandria:random-elt voice)
                             voice))))

(defmethod state ((effect sound-effect))
  (if (mixed:done-p (voice effect))
      :inactive
      :active))

(defmethod trigger ((effect sound-effect) source &key)
  (harmony:play (voice effect)))

(defclass camera-effect (effect)
  ((duration :initarg :duration :initform 20 :accessor duration)
   (intensity :initarg :intensity :initform 3 :accessor intensity)))

(defmethod trigger ((effect camera-effect) source &key)
  (shake-camera :duration (duration effect) :intensity (intensity effect)))

(define-shader-entity sprite-effect (lit-animated-sprite)
  ((offset :initarg :offset :initform (vec 0 0) :accessor offset))
  (:default-initargs :sprite-data (asset 'kandria 'effects)))

(defmethod initialize-instance :after ((effect sprite-effect) &key animation)
  (when animation
    (setf (animation effect) (if (typep animation 'sequence)
                                 (alexandria:random-elt animation)
                                 animation))))

(defmethod (setf frame-idx) :after (idx (effect sprite-effect))
  (when (= idx (1- (end (animation effect))))
    (leave effect T)
    (remove-from-pass effect +world+)))

(defmethod trigger :after ((effect sprite-effect) (source located-entity) &key location)
  (setf (location effect) (v+ (or location (location source)) (offset effect))))

(defmethod trigger :after ((effect sprite-effect) (source facing-entity) &key direction)
  (setf (direction effect) (or direction (direction source))))

(defmethod trigger ((effect sprite-effect) source &key)
  (let ((region (region +world+)))
    (enter effect region)
    (compile-into-pass effect region +world+)))

(define-shader-entity step-effect (sprite-effect sound-effect)
  ((offset :initform (vec 0 -7))))

(defmethod layer-index ((effect step-effect)) 1)

(defmethod trigger :after ((effect step-effect) source &key)
  (harmony:play (voice effect) :reset T)
  (let ((pitcher (harmony:segment 'pitch (voice effect) NIL)))
    (when pitcher
      ;; FIXME: This causes really bad distortion of the step sound. Possibly the pitch segment
      ;;        is not configured to be high-quality enough?
      (setf (mixed:pitch pitcher) (+ 0.75 (random 0.5))))))

(define-effect step step-effect
  :voice (// 'kandria 'step)
  :animation 'step)

(define-effect jump step-effect
  :voice (// 'kandria 'jump)
  :animation 'jump)

(define-effect dash step-effect
  :voice (// 'kandria 'dash)
  :animation 'dash)
