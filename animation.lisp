(in-package #:org.shirakumo.fraf.leaf)

(define-shader-entity animated-sprite (trial:animated-sprite sized-entity facing-entity)
  ())

(defclass frame (sprite-frame)
  ((hurtbox :initform (vec 0 0 0 0) :accessor hurtbox)
   (velocity :initform (vec 0 0) :accessor velocity)
   (knockback :initform (vec 0 0) :accessor knockback)
   (damage :initform 0 :accessor damage)
   (stun-time :initform 0f0 :accessor stun-time)
   (flags :initform #b001 :accessor flags)))

(defmethod shared-initialize :after ((frame frame) slots &key sexp)
  (when sexp
    (destructuring-bind (&key (hurtbox '(0 0 0 0)) (velocity '(0 0)) (knockback '(0 0)) (damage 0) (stun-time 0) (flags 1)) sexp
      (destructuring-bind (vx vy) velocity
        (setf (velocity frame) (vec vx vy)))
      (destructuring-bind (kx ky) knockback
        (setf (knockback frame) (vec kx ky)))
      (destructuring-bind (x y w h) hurtbox
        (setf (hurtbox frame) (vec x y w h)))
      (setf (damage frame) damage)
      (setf (stun-time frame) (float stun-time))
      (setf (flags frame) flags))))

(defmacro define-frame-flag (id name)
  `(progn
     (defun ,name (frame)
       (logbitp ,id (flags frame)))
     (defun (setf ,name) (value frame)
       (setf (ldb (byte 1 ,id) (flags frame)) (if value 1 0)))))

;; Whether an attack will interrupt this frame
(define-frame-flag 0 interruptable-p)
;; Whether the entity is invincible
(define-frame-flag 1 invincible-p)
;; Whether the frame can be cancelled
(define-frame-flag 2 cancelable-p)

(defun transfer-frame (target source)
  (setf (hurtbox target) (vcopy (hurtbox source)))
  (setf (velocity target) (vcopy (velocity source)))
  (setf (knockback target) (vcopy (knockback source)))
  (setf (damage target) (damage source))
  (setf (stun-time target) (stun-time source))
  (setf (flags target) (flags source))
  target)

(defmethod clear ((target frame))
  (setf (hurtbox target) (vec 0 0 0 0))
  (setf (velocity target) (vec 0 0))
  (setf (knockback target) (vec 0 0))
  (setf (damage target) 0)
  (setf (stun-time target) 0f0)
  (setf (flags target) #b001)
  target)

(defmethod hurtbox ((subject animated-sprite))
  (let* ((location (location subject))
         (direction (direction subject))
         (frame (frame subject))
         (hurtbox (hurtbox frame)))
    (vec4 (+ (vx location) (* (vx hurtbox) direction))
          (+ (vy location) (vy hurtbox))
          (vz hurtbox)
          (vw hurtbox))))

(defclass sprite-data (trial:sprite-data)
  ((json-file :initform NIL :accessor json-file)))

(defmethod write-animation ((sprite sprite-data) &optional (stream T))
  (let ((*package* #.*package*))
    (format stream "~s~%" (json-file sprite))
    (loop for animation across (animations sprite)
          do (write-animation animation stream))))

(defmethod write-animation ((animation sprite-animation) &optional (stream T))
  (format stream "~&(~20a :loop-to ~3a :next ~s :frame-data ("
          (name animation)
          (loop-to animation)
          (next-animation animation))
  (loop for i from (start animation) below (end animation)
        for frame = (aref (frames sprite) i)
        do (write-animation frame stream))
  (format stream "))~%"))

(defmethod write-animation ((frame frame) &optional (stream T))
  (format stream "~& (:damage ~3a :stun-time ~3f :flags #b~4,'0b :velocity (~4f ~4f) :knockback (~4f ~4f) :hurtbox (~4f ~4f ~4f ~4f))"
          (damage frame)
          (stun-time frame)
          (flags frame)
          (vx (velocity frame)) (vy (velocity frame))
          (vx (knockback frame)) (vy (knockback frame))
          (vx (hurtbox frame)) (vy (hurtbox frame)) (vz (hurtbox frame)) (vw (hurtbox frame))))

(defmethod generate-resources ((sprite sprite-data) (path pathname) &key)
  (with-open-file (stream path :direction :input)
    (setf (json-file sprite) (read stream))
    (call-next-method sprite (merge-pathnames (json-file sprite) path))
    (loop for expr = (read stream NIL NIL)
          while expr
          do (destructuring-bind (name &key loop-to next frame-data) expr
               (let ((animation (find name (animations sprite) :key #'name)))
                 (setf (loop-to animation) loop-to)
                 (setf (next-animation animation) next)
                 (loop for i from (start animation) below (end animation)
                       for data in frame-data
                       for frame = (aref (frames sprite) i)
                       do (change-class frame 'frame :sexp data)))))))
