(in-package #:org.shirakumo.fraf.leaf)

(define-shader-entity enemy (animatable)
  ((bsize :initform (vec 12.0 8.0))
   (cooldown :initform 0.0 :accessor cooldown))
  (:default-initargs
   :sprite-data (asset 'leaf 'wolf)))

(defmethod capable-p ((enemy enemy) (edge jump-edge)) T)

(defmethod handle :before ((ev tick) (enemy enemy))
  (when (path enemy)
    (return-from handle))
  (let ((collisions (collisions enemy))
        (acc (acceleration enemy))
        (dt (* 100 (dt ev))))
    (setf (vx acc) (* (vx acc) (damp* (vy +vmove+) dt)))
    (nv+ acc (v* +vgrav+ dt))
    (cond ((svref collisions 2)
           (when (<= -0.1 (vx acc) 0.1)
             (setf (vx acc) 0)))
          (T
           (when (<= 2 (vx acc))
             (setf (vx acc) (* (vx acc) (damp* 0.90 dt))))))
    (when (svref collisions 0) (setf (vy acc) (min 0 (vy acc))))
    (when (svref collisions 1) (setf (vx acc) (min 0 (vx acc))))
    (when (svref collisions 3) (setf (vx acc) (max 0 (vx acc))))
    (case (state enemy)
      ((:dying :animated :stunned)
       (handle-animation-states enemy ev))
      (T
       (handle-ai-states enemy ev)))
    (nvclamp (v- +vlim+) acc +vlim+)
    (nv+ (velocity enemy) acc)))

(defmethod handle :after ((ev tick) (enemy enemy))
  ;; Animations
  (let ((acc (acceleration enemy))
        (collisions (collisions enemy)))
    (case (state enemy)
      (:dying :animated :stunned)
      (T
       (cond ((< 0 (vx acc))
              (setf (direction enemy) +1))
             ((< (vx acc) 0)
              (setf (direction enemy) -1)))
       (cond ((< 0 (vy acc))
              (setf (animation enemy) 'jump))
             ((null (svref collisions 2))
              (setf (animation enemy) 'fall))
             ((< 0 (abs (vx acc)) 1.0)
              (setf (animation enemy) 'walk))
             ((<= 1.0 (abs (vx acc)))
              (setf (animation enemy) 'run))
             (T
              (setf (animation enemy) 'stand)))))))

(define-shader-entity wolf (enemy)
  ())

(defmethod handle-ai-states ((enemy wolf) ev)
  (let ((player (unit 'player T)))
    (ecase (state enemy)
      (:chasing
       (cond ((<= (vsqrdist2 (location enemy) (location player)) 2000)
              (cond ((<= (cooldown enemy) 0)
                     (setf (direction enemy) (signum (- (vx (location player)) (vx (location enemy)))))
                     (start-animation 'tackle enemy))
                    (T
                     (decf (cooldown enemy) (dt ev)))))
             ((null (path enemy))
              (handler-case (move-to player enemy)
                (error ()
                  (setf (state enemy) :normal))))))
      (:normal
       ;; (when (and (<= (vsqrdist2 (location enemy) (location player)) 30000)
       ;;            (path-available-p player enemy))
       ;;   (setf (state enemy) :chasing)
       ;;   (setf (cooldown enemy) (+ 0.5 (random 1))))
       ;; (when (null (path enemy))
       ;;   (cond ((<= (cooldown enemy) 0)
       ;;          (ignore-errors
       ;;           (move-to (v+ (location enemy) (vrand -128 +128)) enemy))
       ;;          (setf (cooldown enemy) (+ 1 (random 3))))
       ;;         (T
       ;;          (decf (cooldown enemy) (dt ev)))))
       ))))
