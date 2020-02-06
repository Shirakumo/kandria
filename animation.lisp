(in-package #:org.shirakumo.fraf.leaf)

(define-shader-subject animated-sprite (animated-sprite-subject)
  ())

(defstruct (frame (:constructor make-frame (velocity hurtbox damage flags)))
  (velocity (vec 0 0) :type vec2)
  (hurtbox (vec 0 0 0 0) :type vec4)
  (damage 0 :type (unsigned-byte 16))
  (flags #b001 :type (unsigned-byte 8)))

(defun frame-from-sexp (sexp)
  (destructuring-bind (&key (velocity '(0 0)) (hurtbox '(0 0 0 0)) (damage 0) (flags 1)) sexp
    (destructuring-bind (vx vy) velocity
      (destructuring-bind (x y w h) hurtbox
        (make-frame (vec2 vx vy) (vec4 x y w h) damage flags)))))

(defmacro define-frame-flag (id name)
  `(progn
     (defun ,name (frame)
       (logbitp ,id (frame-flags frame)))
     (defun (setf ,name) (value frame)
       (setf (ldb (byte 1 ,id) (frame-flags frame)) (if value 1 0)))))

;; Whether an attack will interrupt this frame
(define-frame-flag 0 interruptable-p)
;; Whether the entity is invincible
(define-frame-flag 1 invincible-p)
;; Whether the frame can be cancelled
(define-frame-flag 2 cancelable-p)

(defstruct (attack-animation (:include trial::sprite-animation)
                             (:constructor make-attack-animation (name start end step next loop frame-data)))
  (frame-data #() :type simple-vector))

(defmethod print-object ((animation attack-animation) stream)
  (print-unreadable-object (animation stream :type T)
    (format stream "~s :start ~a :end ~a"
            (trial::sprite-animation-name animation)
            (trial::sprite-animation-start animation)
            (trial::sprite-animation-end animation))))

(defmethod frame-idx ((subject animated-sprite))
  (- (truncate (frame subject)) (trial::sprite-animation-start (animation subject))))

(defmethod frame-data ((subject animated-sprite))
  (svref (attack-animation-frame-data (animation subject))
         (frame-idx subject)))

(defmethod hurtbox ((subject animated-sprite))
  (let* ((location (location subject))
         (direction (direction subject))
         (frame (frame-data subject))
         (hurtbox (frame-hurtbox frame)))
    (vec4 (+ (vx location) (* (vx hurtbox) direction))
          (+ (vy location) (vy hurtbox))
          (vz hurtbox)
          (vw hurtbox))))

(defmethod (setf animations) ((value string) (subject animated-sprite))
  (let ((file (if +world+
                  (entry-path (format NIL "data/~a" value) (packet +world+))
                  (asdf:system-relative-pathname :leaf (format NIL "world/data/~a" value))))
        (*package* #.*package*))
    (with-open-file (stream file :direction :input)
      (setf (animations subject) (loop for expr = (read stream NIL NIL)
                                       while expr
                                       collect expr)))))

(defmethod (setf animations) (value (subject animated-sprite))
  (setf (slot-value subject 'animations)
        (coerce
         (loop for spec in value
               for i from 0
               collect (destructuring-bind (name &key start end duration step (next i) loop-to frame-data)
                           spec
                         (assert (< start end))
                         (let ((step (coerce (cond (step step)
                                                   (duration (/ duration (- end start)))
                                                   (T 0.1))
                                             'single-float))
                               (next (etypecase next
                                       ((integer 0) next)
                                       (symbol (position next value :key #'first))))
                               (loop (or loop-to start)))
                           (unless frame-data (setf frame-data (make-list (- end start))))
                           (setf frame-data (coerce (loop for data in frame-data
                                                          collect (frame-from-sexp data))
                                                    'vector))
                           (make-attack-animation name start end step next loop frame-data))))
         'simple-vector))
  (setf (animation subject) 0))

(defmethod write-animation ((sprite animated-sprite) &optional (stream T))
  (loop for animation across (animations sprite)
        do (write-animation animation stream)))

(defmethod write-animation ((animation attack-animation) &optional (stream T))
  (format stream "~&(~20a :start ~3a :end ~3a :step ~5f :loop-to ~3a :next ~a :frame-data ("
          (trial::sprite-animation-name animation)
          (trial::sprite-animation-start animation)
          (trial::sprite-animation-end animation)
          (trial::sprite-animation-step animation)
          (trial::sprite-animation-loop animation)
          (trial::sprite-animation-next animation))
  (loop for frame across (attack-animation-frame-data animation)
        do (write-animation frame stream))
  (format stream ")~%"))

(defmethod write-animation ((frame frame) &optional (stream T))
  (format stream "~& (:damage ~3a :flags #b~4,'0b :velocity (~a ~a) :hurtbox (~a ~a ~a ~a))"
          (frame-damage frame)
          (frame-flags frame)
          (vx (frame-velocity frame)) (vy (frame-velocity frame))
          (vx (frame-hurtbox frame)) (vy (frame-hurtbox frame)) (vz (frame-hurtbox frame)) (vw (frame-hurtbox frame))))
