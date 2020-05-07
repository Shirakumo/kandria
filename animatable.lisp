(in-package #:org.shirakumo.fraf.leaf)

(define-global +max-stun+ 3d0)
(define-global +hard-hit+ 20)

(define-shader-subject animatable (movable lit-animated-sprite)
  ((health :initarg :health :initform 1000 :accessor health)
   (start-acc :initform (vec2 0 0) :accessor start-acc)
   (stun-time :initform 0d0 :accessor stun-time)))

(defgeneric die (animatable))
(defgeneric interrupt (animatable))
(defgeneric damage (animatable damage))
(defgeneric stun (animatable stun))
(defgeneric start-animation (name animatable))
(defgeneric in-danger-p (animatable))

(defmethod in-danger-p ((animatable animatable))
  (do-layered-container (entity (surface animatable))
    (when (and (typep entity 'animatable)
               (not (eql animatable entity))
               (/= 0 (vw (hurtbox entity)))
               ;; KLUDGE: this sucks
               (< (vdistance (location entity) (location animatable)) (* 2 +tile-size+)))
      (return T))))

(defmethod damage ((animatable animatable) damage)
  (when (and (< 0 damage)
             (< 0 (health animatable))
             (not (invincible-p (frame-data animatable))))
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
  (when (eql (sprite-animation-name (animation animatable)) 'die)
    (leave animatable (surface animatable))))

(defmethod interrupt ((animatable animatable))
  (when (interruptable-p (frame-data animatable))
    (unless (eql :stunned (state animatable))
      (setf (animation animatable) 'light-hit)
      (setf (state animatable) :animated))))

(defmethod stun ((animatable animatable) stun)
  (when (and (< 0 stun)
             (interruptable-p (frame-data animatable)))
    (setf (stun-time animatable) (min +max-stun+ (+ (stun-time animatable) stun)))
    (setf (animation animatable) 'light-hit)
    (setf (state animatable) :stunned)))

(defmethod start-animation (name (animatable animatable))
  (when (or (not (eql :animating (state animatable)))
            (cancelable-p (frame-data animatable)))
    (setf (animation animatable) name)
    (setf (state animatable) :animated)
    (vsetf (start-acc animatable)
           (vx (acceleration animatable))
           (vy (acceleration animatable)))))

(defmethod handle-animation-states ((animatable animatable) ev)
  (let ((acc (acceleration animatable))
        (sacc (start-acc animatable))
        (frame (frame-data animatable)))
    (case (state animatable)
      (:animated
       (setf (vx sacc) (* (vx sacc) (damp* -5 (dt ev))))
       (vsetf acc (vx sacc) (vy sacc))
       (let ((hurtbox (hurtbox animatable)))
         (do-layered-container (entity (surface animatable))
           (when (and (typep entity 'animatable)
                      (not (eql animatable entity))
                      (scan entity hurtbox))
             (when (interruptable-p (frame-data entity))
               (setf (direction entity) (float-sign (- (vx (location animatable)) (vx (location entity)))))
               (incf (vx (acceleration entity)) (* (direction animatable) (vx (frame-knockback frame))))
               (incf (vy (acceleration entity)) (vy (frame-knockback frame)))
               (stun entity (frame-stun frame)))
             (damage entity (frame-damage frame)))))
       (when (eql 'stand (sprite-animation-name (animation animatable)))
         (setf (state animatable) :normal)))
      (:stunned
       (nv* acc 0)
       (decf (stun-time animatable) (dt ev))
       (when (<= (stun-time animatable) 0)
         (setf (state animatable) :normal)))
      (:dying))
    (incf (vx acc) (* (direction animatable) (vx (frame-velocity frame))))
    (incf (vy acc) (vy (frame-velocity frame)))))
