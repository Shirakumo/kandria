(in-package #:org.shirakumo.fraf.leaf)

(define-shader-subject animated-sprite (animated-sprite-subject sized-entity)
  ((size :initform (vec 32 32))
   (vertex-array :initform (asset 'leaf '1x))))

(defmethod paint ((sprite animated-sprite) target)
  (scale-by (vx (size sprite)) (vy (size sprite)) 1)
  (translate-by -0.5 -0.5 0)
  (call-next-method))

(defstruct (frame (:constructor make-frame (hurtbox velocity knockback damage stun flags)))
  (hurtbox (vec 0 0 0 0) :type vec4)
  (velocity (vec 0 0) :type vec2)
  (knockback (vec 0 0) :type vec2)
  (damage 0 :type (unsigned-byte 16))
  (stun 0f0 :type single-float)
  (flags #b001 :type (unsigned-byte 8)))

(defun frame-from-sexp (sexp)
  (destructuring-bind (&key (hurtbox '(0 0 0 0)) (velocity '(0 0)) (knockback '(0 0)) (damage 0) (stun 0) (flags 1)) sexp
    (destructuring-bind (vx vy) velocity
      (destructuring-bind (kx ky) knockback
        (destructuring-bind (x y w h) hurtbox
          (make-frame (vec4 x y w h) (vec2 vx vy) (vec2 kx ky) damage (float stun) flags))))))

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

(defun transfer-frame (target source)
  (setf (frame-hurtbox target) (vcopy (frame-hurtbox source)))
  (setf (frame-velocity target) (vcopy (frame-velocity source)))
  (setf (frame-knockback target) (vcopy (frame-knockback source)))
  (setf (frame-damage target) (frame-damage source))
  (setf (frame-stun target) (frame-stun source))
  (setf (frame-flags target) (frame-flags source))
  target)

(defmethod clear ((target frame))
  (setf (frame-hurtbox target) (vec 0 0 0 0))
  (setf (frame-velocity target) (vec 0 0))
  (setf (frame-knockback target) (vec 0 0))
  (setf (frame-damage target) 0)
  (setf (frame-stun target) 0f0)
  (setf (frame-flags target) #b001)
  target)

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
      (destructuring-bind (pool name) (read stream)
        (setf (texture subject) (asset pool name)))
      (destructuring-bind (w h) (read stream)
        (setf (bsize subject) (vec w h)))
      (destructuring-bind (w h) (read stream)
        (setf (size subject) (vec w h)))
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
  (let ((*package* #.*package*))
    (format stream "(~s ~s)~%(~f ~f) (~f ~f)~%"
            (name (pool (texture sprite)))
            (name (texture sprite))
            (vx (bsize sprite))
            (vy (bsize sprite))
            (vx (size sprite))
            (vy (size sprite)))
    (loop for animation across (animations sprite)
          do (write-animation animation stream))))

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
  (format stream "))~%"))

(defmethod write-animation ((frame frame) &optional (stream T))
  (format stream "~& (:damage ~3a :stun ~3f :flags #b~4,'0b :velocity (~4f ~4f) :knockback (~4f ~4f) :hurtbox (~4f ~4f ~4f ~4f))"
          (frame-damage frame)
          (frame-stun frame)
          (frame-flags frame)
          (vx (frame-velocity frame)) (vy (frame-velocity frame))
          (vx (frame-knockback frame)) (vy (frame-knockback frame))
          (vx (frame-hurtbox frame)) (vy (frame-hurtbox frame)) (vz (frame-hurtbox frame)) (vw (frame-hurtbox frame))))
