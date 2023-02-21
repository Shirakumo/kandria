(in-package #:org.shirakumo.fraf.kandria)

(defclass ai-entity (movable)
  ((ai-state :initform :normal :accessor ai-state :type symbol
             :documentation "The current AI state-machine identifier")))

(defmethod is-collider-for ((platform moving-platform) (entity ai-entity)) NIL)

(defmethod handle :before ((ev tick) (entity ai-entity))
  (let ((collisions (collisions entity))
        (vel (velocity entity)))
    (case (state entity)
      ((:dying :animated :stunned :dead)
       (handle-animation-states entity ev))
      (T
       (unless (path entity)
         (let ((ground (svref collisions 2))
               (g (gravity (medium entity))))
           (when (and ground (<= (vy vel) 0))
             (incf (vy vel) (min 0 (vy (velocity ground))))
             (setf (vx vel) 0))
           (incf (vx vel) (* (vx g) (dt ev)))
           (incf (vy vel) (* (vy g) (dt ev)))
           (nvclamp (v- (p! velocity-limit)) vel (p! velocity-limit))))))
    (case (state entity)
      ((:dying :stunned :dead))
      (T (handle-ai-states entity ev)))
    (nvclamp (v- (p! velocity-limit)) vel (p! velocity-limit))
    (nv+ (frame-velocity entity) vel)))

(defgeneric handle-ai-states (entity ev))

(defmethod handle-ai-states ((immovable immovable) ev))

(defmethod spawn :before (thing (entity ai-entity) &key)
  (place-on-ground entity (location entity)))
