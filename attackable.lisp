(in-package #:org.shirakumo.fraf.leaf)

(define-shader-subject attackable (movable lit-animated-sprite)
  ((health :initarg :health :accessor health)
   (stun-time :initform 0d0 :accessor stun-time)))

(defgeneric die (attackable))
(defgeneric interrupt (attackable))
(defgeneric damage (attackable damage))
(defgeneric stun (attackable stun))

(defmethod damage ((attackable attackable) damage)
  (when (and (not (invincible-p (frame-data attackble)))
             (< 0 (health attackable)))
    (interrupt attackable)
    (decf (health attackable) damage)
    (when (<= (health attackable) 0)
      (die attackable))))

(defmethod die ((attackable attackable))
  (setf (health attackable) 0)
  (setf (state attackable) :dying)
  (setf (animation attackable) 'die))

(defmethod switch-animation :before ((attackable attackable) next)
  ;; Remove selves when death animation completes
  (when (eql (sprite-animation-name (animation attackable)) 'die)
    (leave attackable (surface attackable))))

(defmethod interrupt ((attackable attackable))
  (when (interruptable-p (frame-data attackable))
    (setf (animation attackable) 'hurt)
    (setf (state attackable :normal))))

(defmethod stun ((attackable attackable) stun)
  (when (and (interruptable-p (frame-data attackable))
             (< 0 stun))
    (incf (stun-time attackable) stun)
    (setf (state attackable) :stunned)))

(defmethod handle-attack-states ((attackable attackable))
  (case (state attackable)
    (:attacking
     (nv* acc 0)
     (let ((frame (frame-data attackable))
           (hurtbox (hurtbox attackable)))
       (nv+ acc (v* (frame-velocity frame) (direction attackable)))
       (let ((other (scan (surface attackable) hurtbox)))
         (when (typep other 'enemy)
           (nv+ (acceleration other) (v* (frame-knockback frame) (direction attackable)))
           (stun other (frame-stun frame))
           (damage other (frame-damage frame)))))
     (when (eql 'stand (sprite-animation-name (animation attackable)))
       (setf (state attackable) :normal)))
    (:stunned
     (decf (stun-time attackable) (dt ev))
     (when (<= (stun-time attackable) 0)
       (setf (state attackable) :normal)))
    (:dying)))

