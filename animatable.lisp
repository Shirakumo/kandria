(in-package #:org.shirakumo.fraf.leaf)

(define-global +max-stun+ 3d0)
(define-global +hard-hit+ 20)

(define-shader-entity animatable (movable lit-animated-sprite)
  ((health :initarg :health :initform 1000 :accessor health)
   (stun-time :initform 0d0 :accessor stun-time)))

(defgeneric die (animatable))
(defgeneric interrupt (animatable))
(defgeneric hurt (animatable damage))
(defgeneric stun (animatable stun))
(defgeneric start-animation (name animatable))
(defgeneric in-danger-p (animatable))

(defmethod in-danger-p ((animatable animatable))
  (for:for ((entity over +world+))
    (when (and (typep entity 'animatable)
               (not (eql animatable entity))
               (/= 0 (vw (hurtbox entity)))
               ;; KLUDGE: this sucks
               (< (vdistance (location entity) (location animatable)) (* 2 +tile-size+)))
      (return T))))

(defmethod hurt ((animatable animatable) damage)
  (when (and (< 0 damage)
             (< 0 (health animatable))
             (not (invincible-p (frame animatable))))
    (when (interrupt animatable)
      (when (<= +hard-hit+ damage)
        (setf (animation animatable) 'hard-hit)))
    (decf (health animatable) damage)
    (when (<= (health animatable) 0)
      (die animatable))))

(defmethod die ((animatable animatable))
  (setf (health animatable) 0)
  (setf (state animatable) :dying)
  (setf (animation animatable) 'die))

(defmethod switch-animation :before ((animatable animatable) next)
  ;; Remove selves when death animation completes
  (when (eql (name (animation animatable)) 'die)
    (leave animatable (container animatable))))

(defmethod interrupt ((animatable animatable))
  (when (interruptable-p (frame animatable))
    (unless (eql :stunned (state animatable))
      (setf (animation animatable) 'light-hit)
      (setf (state animatable) :animated))))

(defmethod stun ((animatable animatable) stun)
  (when (and (< 0 stun)
             (interruptable-p (frame animatable)))
    (setf (stun-time animatable) (min +max-stun+ (+ (stun-time animatable) stun)))
    (setf (animation animatable) 'light-hit)
    (setf (state animatable) :stunned)))

(defmethod start-animation (name (animatable animatable))
  (when (or (not (eql :animating (state animatable)))
            (cancelable-p (frame animatable)))
    (setf (animation animatable) name)
    (setf (state animatable) :animated)))

(defmethod handle-animation-states ((animatable animatable) ev)
  (let ((vel (frame-velocity animatable))
        (frame (frame animatable)))
    (case (state animatable)
      (:animated
       (let ((hurtbox (hurtbox animatable)))
         (for:for ((entity over (region +world+)))
           (when (and (typep entity 'animatable)
                      (not (eql animatable entity))
                      (contained-p hurtbox entity))
             (when (interruptable-p (frame entity))
               (setf (direction entity) (float-sign (- (vx (location animatable)) (vx (location entity)))))
               (incf (vx (velocity entity)) (* (direction animatable) (vx (knockback frame))))
               (incf (vy (velocity entity)) (vy (knockback frame)))
               (stun entity (stun-time frame)))
             (hurt entity (damage frame)))))
       (when (eql 'stand (name (animation animatable)))
         (setf (state animatable) :normal)))
      (:stunned
       (nv* vel 0)
       (decf (stun-time animatable) (dt ev))
       (when (<= (stun-time animatable) 0)
         (setf (state animatable) :normal)))
      (:dying))
    (incf (vx vel) (* (direction animatable) (vx (velocity frame))))
    (incf (vy vel) (vy (velocity frame)))))
