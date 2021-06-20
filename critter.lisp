(in-package #:org.shirakumo.fraf.kandria)

(define-shader-entity critter (lit-animated-sprite game-entity)
  ((idle-timer :initform (random* 10.0 5.0) :accessor idle-timer)
   (direction :initform (alexandria:random-elt #(-1 +1)))
   (alert-distance :initform (* +tile-size+ (random* 10 5)) :accessor alert-distance)
   (acceleration :initform (vec 0 0) :accessor acceleration)))

(defmethod handle :before ((ev tick) (critter critter))
  (let ((dt (dt ev)))
    (ecase (state critter)
      (:normal
       (when (in-view-p (location critter) (bsize critter))
         (cond ((<= (decf (idle-timer critter) dt) 0.0)
                (setf (animation critter) 'idle))
               ((not (eq 'stand (name (animation critter))))
                (setf (animation critter) 'stand)
                (setf (clock critter) (random* 1.0 1.0))))
         (when (within-dist-p (location critter) (location (unit 'player +world+)) (alert-distance critter))
           (setf (animation critter) 'run)
           (setf (direction critter) (float-sign (- (vx (location critter)) (vx (location (unit 'player +world+))))))
           (setf (state critter) :fleeing))))
      (:fleeing
       (let ((vel (velocity critter)))
         (incf (vx vel) (* dt (vx (acceleration critter)) (direction critter)))
         (incf (vy vel) (* dt (vy (acceleration critter))))
         (nv+ (frame-velocity critter) vel))))))

(defmethod oob :after ((critter critter) next)
  (when (and (eql :fleeing (state critter))
             (slot-boundp critter 'container))
    (leave* critter T)))

(defmethod switch-animation :after ((critter critter) new)
  (case (name (animation critter))
    (stand
     (setf (idle-timer critter) (random* 10.0 5.0)))))

(define-shader-entity white-bird (critter)
  ((acceleration :initform (vec (random* 3.0 0.7) (random* 1.5 0.2))))
  (:default-initargs :sprite-data (asset 'kandria 'critter-white-bird)))

(defmethod apply-transforms progn ((subject white-bird))
  (translate-by 0 -9 0))

(define-shader-entity red-bird (critter)
  ((acceleration :initform (vec (random* 2.0 0.5) (random* 2.5 0.5))))
  (:default-initargs :sprite-data (asset 'kandria 'critter-red-bird)))

(defmethod apply-transforms progn ((subject red-bird))
  (translate-by 0 -9 0))

(define-shader-entity rat (critter)
  ((acceleration :initform (vec (random* 3.0 0.5) 0)))
  (:default-initargs :sprite-data (asset 'kandria 'critter-rat)))

(defmethod layer-index ((rat rat)) (1- +base-layer+))
