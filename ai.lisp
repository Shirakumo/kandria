(in-package #:org.shirakumo.fraf.kandria)

(defclass ai-entity (movable)
  ((ai-state :initform :normal :accessor ai-state)))

(defmethod handle :before ((ev tick) (entity ai-entity))
  (unless (path entity)
    (let ((collisions (collisions entity))
          (vel (velocity entity)))
      (when (svref collisions 0) (setf (vy vel) (min 0 (vy vel))))
      (when (svref collisions 1) (setf (vx vel) (min 0 (vx vel))))
      (when (svref collisions 3) (setf (vx vel) (max 0 (vx vel))))
      (handle-ai-states entity ev)
      (case (state entity)
        ((:dying :animated :stunned)
         (handle-animation-states entity ev))
        (T
         (let ((dt (* 100 (dt ev)))
               (ground (svref collisions 2)))
           (when ground
             (incf (vy vel) (min 0 (vy (velocity ground))))
             (setf (vx vel) 0))
           (nv+ vel (v* (gravity (medium entity)) dt))
           (nvclamp (v- (p! velocity-limit)) vel (p! velocity-limit))
           (nv+ (frame-velocity entity) vel))))
      (nvclamp (v- (p! velocity-limit)) vel (p! velocity-limit))
      (nv+ (frame-velocity entity) vel))))

(defgeneric handle-ai-states (entity ev))

(defmethod handle-ai-states ((immovable immovable) ev))
