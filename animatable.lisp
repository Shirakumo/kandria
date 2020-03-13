(in-package #:org.shirakumo.fraf.leaf)

(define-global +max-stun+ 1d0)

(define-shader-subject animatable (movable lit-animated-sprite)
  ((health :initarg :health :initform 100 :accessor health)
   (stun-time :initform 0d0 :accessor stun-time)))

(defgeneric die (animatable))
(defgeneric interrupt (animatable))
(defgeneric damage (animatable damage))
(defgeneric stun (animatable stun))
(defgeneric start-animation (name animatable))
(defgeneric in-danger-p (animatable))

(defmethod in-danger-p ((animatable animatable))
  ;; TODO: implement in-danger-p based on projected hurtbox?
  NIL)

(defmethod damage ((animatable animatable) damage)
  (when (and (not (invincible-p (frame-data animatable)))
             (< 0 (health animatable)))
    (interrupt animatable)
    (decf (health animatable) damage)
    (when (<= (health animatable) 0)
      (die animatable))))

(defmethod die ((animatable animatable))
  (setf (health animatable) 0)
  (setf (state animatable) :dying)
  (setf (animation animatable) 'die))

(defmethod switch-animation :before ((animatable animatable) next)
  ;; Remove selves when death animation completes
  (when (eql (sprite-animation-name (animation animatable)) 'die)
    (leave animatable (surface animatable))))

(defmethod interrupt ((animatable animatable))
  (when (interruptable-p (frame-data animatable))
    (setf (animation animatable) 'hurt)
    (setf (state animatable) :normal)))

(defmethod stun ((animatable animatable) stun)
  (when (and (interruptable-p (frame-data animatable))
             (< 0 stun))
    (setf (stun-time animatable) (max +max-stun+ (+ (stun-time animatable) stun)))
    (setf (animation animatable) 'hurt)
    (setf (state animatable) :stunned)))

(defmethod start-animation (name (animatable animatable))
  (when (or (not (eql :animating (state animatable)))
            (cancelable-p (frame-data animatable)))
    (setf (animation animatable) name)
    (setf (state animatable) :animated)))

(defmethod handle-animation-states ((animatable animatable) ev)
  (case (state animatable)
    (:animated
     (let ((acc (acceleration animatable)))
       (nv* acc 0)
       (let ((frame (frame-data animatable))
             (hurtbox (hurtbox animatable)))
         (incf (vx acc) (* (direction animatable) (vx (frame-velocity frame))))
         (incf (vy acc) (vy (frame-velocity frame)))
         (do-layered-container (entity (surface animatable))
           (when (and (typep entity 'animatable)
                      (scan entity hurtbox))
             (incf (vx (acceleration entity)) (* (direction animatable) (vx (frame-knockback frame))))
             (incf (vy (acceleration entity)) (vy (frame-knockback frame)))
             (stun entity (frame-stun frame))
             (damage entity (frame-damage frame)))))
       (when (eql 'stand (sprite-animation-name (animation animatable)))
         (setf (state animatable) :normal))))
    (:stunned
     (decf (stun-time animatable) (dt ev))
     (when (<= (stun-time animatable) 0)
       (setf (state animatable) :normal)))
    (:dying)))
