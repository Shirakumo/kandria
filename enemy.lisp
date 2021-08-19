(in-package #:org.shirakumo.fraf.kandria)

(define-global +health-multiplier+ 1f0)

(define-shader-entity enemy (ai-entity animatable)
  ((bsize :initform (vec 8.0 8.0))
   (cooldown :initform 0.0 :accessor cooldown)
   (ai-state :initform :normal :accessor ai-state)))

(defmethod collides-p ((enemy enemy) (moving moving) hit) T)
(defmethod collides-p ((enemy enemy) (other enemy) hit) NIL)
(defmethod collides-p ((enemy enemy) (other stopper) hit) T)

(defmethod maximum-health ((enemy enemy)) 100)

(defmethod initialize-instance :after ((enemy enemy) &key)
  (setf (health enemy) (* (health enemy) +health-multiplier+)))

(defmethod hurt ((a enemy) (b enemy)))

(defmethod draw-item ((enemy enemy)) NIL)

(defmethod die :after ((enemy enemy))
  (let ((item (draw-item enemy)))
    (when item
      (spawn (location enemy) item))))

(defmethod capable-p ((enemy enemy) (edge crawl-node)) T)
(defmethod capable-p ((enemy enemy) (edge jump-node)) T)

(defmethod collide :after ((player player) (enemy enemy) hit)
  (when (and (eql :dashing (state player))
             (interruptable-p (frame enemy)))
    (let ((dir (vunit* (velocity player))))
      (vsetf (velocity enemy)
             (* (vx dir) 3.0)
             (+ (* (vy dir) 3.0) 2)))
    (nv* (velocity player) 0.25)
    (incf (vy (velocity player)) 2.0)
    (stun player 0.1)))

(define-shader-entity dummy (enemy half-solid immovable)
  ((bsize :initform (vec 8 16)))
  (:default-initargs
   :sprite-data (asset 'kandria 'dummy)))

(defmethod idleable-p ((dummy dummy)) NIL)

(defmethod (setf health) (value (dummy dummy)) value)

(define-shader-entity sawblade (enemy solid immovable)
  ((bsize :initform (vec 16 16)))
  (:default-initargs
   :sprite-data (asset 'kandria 'sawblade)))

(defmethod state ((sawblade sawblade)) :animated)

(defmethod idleable-p ((sawblade sawblade)) NIL)

(defmethod (setf health) (value (sawblade sawblade)) value)

(define-shader-entity box (enemy solid immovable)
  ((bsize :initform (vec 8 8)))
  (:default-initargs
   :sprite-data (asset 'kandria 'box)))

(defmethod maximum-health ((box box)) 20)

(defmethod idleable-p ((box box)) NIL)

(defmethod collides-p ((movable movable) (box box) hit)
  (not (eql (state box) :dying)))

(defmethod stage :after ((box box) (area staging-area))
  (dolist (asset '(box-hit-1 box-hit-2 box-hit-3 box-break))
    (stage (// 'sound asset) area)))

(defmethod hurt :after ((box box) (by integer))
  (harmony:play (alexandria:random-elt (list (// 'sound 'box-hit-1)
                                             (// 'sound 'box-hit-2)
                                             (// 'sound 'box-hit-3)))))

(defmethod kill :after ((box box))
  (harmony:play (// 'sound 'box-break)))

(define-shader-entity ground-enemy (enemy)
  ())

(defmethod handle :after ((ev tick) (enemy ground-enemy))
  ;; Animations
  (case (state enemy)
    ((:dying :animated :stunned))
    (T
     (let ((vel (velocity enemy))
           (collisions (collisions enemy)))
       (cond ((< 0 (vx vel))
              (setf (direction enemy) +1))
             ((< (vx vel) 0)
              (setf (direction enemy) -1)))
       (cond ((< 0 (vy vel))
              (setf (animation enemy) 'jump))
             ((null (svref collisions 2))
              (setf (animation enemy) 'fall))
             ((<= 0.4 (abs (vx vel)))
              (setf (animation enemy) 'run))
             ((< 0 (abs (vx vel)))
              (setf (animation enemy) 'walk))
             (T
              (setf (animation enemy) 'stand)))))))

(define-shader-entity wolf (paletted-entity ground-enemy half-solid)
  ((jitter :initform (random* 0 +tile-size+) :accessor jitter)
   (retreat-time :initform 0.0 :accessor retreat-time)
   (acc-time :initform 0.0 :accessor acc-time)
   (palette :initform (// 'kandria 'wolf-palette))
   (palette-index :initform (random 3)))
  (:default-initargs
   :sprite-data (asset 'kandria 'wolf)))

(defmethod stage :after ((wolf wolf) (area staging-area))
  (dolist (sound '(wolf-die wolf-attack wolf-notice wolf-damage-1 wolf-damage-2))
    (stage (// 'sound sound) area)))

(defmethod movement-speed ((enemy wolf))
  (case (state enemy)
    (:crawling 0.4)
    (:normal
     (case (ai-state enemy)
       ((:approach :retreat)
        (* (/ (min (acc-time enemy) 0.3) 0.3) 2.0))
       (T 0.5)))
    (T 2.0)))

(defmethod idleable-p ((enemy wolf)) NIL)

;; FIXME: Instead of testing distance to player, we should be
;;        testing the distance to any closest attackable.
;; FIXME: Instead of only testing distance we should be raycasting
;;        first to determine whether the target would be visible
;;        at all. Would avoid annoying circumstances where the enemy
;;        starts attacking even when the player is technically
;;        obscured.

(defmethod handle-ai-states ((enemy wolf) ev)
  (let* ((player (unit 'player T))
         (ploc (location player))
         (eloc (location enemy))
         (distance (vlength (v- ploc eloc)))
         (vel (velocity enemy)))
    (flet ((distance-p (max)
             (< (+ (jitter enemy) distance) (* +tile-size+ max))))
      (when (eql :normal (state enemy))
        (ecase (ai-state enemy)
          (:normal
           (cond ((distance-p 5)
                  (harmony:play (// 'sound 'wolf-notice))
                  (setf (retreat-time enemy) 0.0)
                  (setf (acc-time enemy) 0.0)
                  (setf (ai-state enemy) :retreat))
                 ((distance-p 20)
                  (harmony:play (// 'sound 'wolf-notice))
                  (setf (ai-state enemy) :approach))))
          (:approach
           (incf (acc-time enemy) (dt ev))
           (cond ((and (distance-p 5) (<= (retreat-time enemy) 0.0))
                  (setf (path enemy) NIL)
                  (setf (acc-time enemy) 0.0)
                  (setf (ai-state enemy) :retreat))
                 ((distance-p 15)
                  (setf (retreat-time enemy) 0.0)
                  (setf (path enemy) NIL)
                  (setf (direction enemy) (float-sign (- (vx ploc) (vx eloc))))
                  (start-animation 'tackle enemy))
                 ((distance-p 22)
                  (if (path enemy)
                      (execute-path enemy ev)
                      (move-to player enemy)))
                 (T
                  (setf (path enemy) NIL)
                  (setf (ai-state enemy) :normal))))
          (:retreat
           (incf (retreat-time enemy) (dt ev))
           (cond ((or (<= 1.0 (retreat-time enemy))
                      (not (distance-p 5)))
                  (decf (acc-time enemy) (dt ev))
                  (setf (vx vel) (* (direction enemy) (movement-speed enemy)))
                  (when (<= (acc-time enemy) 0)
                    (setf (ai-state enemy) :approach)))
                 ((path enemy)
                  (incf (acc-time enemy) (dt ev))
                  (execute-path enemy ev))
                 ((<= 0 (- (vx eloc) (vx ploc)))
                  (incf (acc-time enemy) (dt ev))
                  (or (when (svref (collisions enemy) 1)
                        (move-to (vec (+ (vx ploc) (* +tile-size+ 10)) (+ (vy ploc) (* +tile-size+ 10))) enemy))
                      (setf (vx vel) (movement-speed enemy))))
                 (T
                  (incf (acc-time enemy) (dt ev))
                  (or (when (svref (collisions enemy) 3)
                        (move-to (vec (- (vx ploc) (* +tile-size+ 10)) (+ (vy ploc) (* +tile-size+ 10))) enemy))
                      (setf (vx vel) (- (movement-speed enemy))))))))))))

(defmethod draw-item ((wolf wolf))
  (draw-item 'wolf/rewards))

(define-random-draw wolf/rewards
  (NIL 1)
  (item:small-health-pack 0.2)
  (item:medium-health-pack 0.075)
  (item:large-health-pack 0.01)
  (item:dirt-clump 1.5)
  (item:pristine-pelt 0.01)
  (item:fine-pelt 0.1)
  (item:ruined-pelt 1))

(define-shader-entity zombie (paletted-entity ground-enemy half-solid)
  ((bsize :initform (vec 4 16))
   (timer :initform 0.0 :accessor timer)
   (palette :initform (// 'kandria 'zombie-palette))
   (palette-index :initform (random 5)))
  (:default-initargs
   :sprite-data (asset 'kandria 'zombie)))

(defmethod stage :after ((zombie zombie) (area staging-area))
  (dolist (sound '(notice-zombie zombie-attack zombie-damage zombie-die))
    (stage (// 'sound sound) area)))

(defmethod movement-speed ((enemy zombie))
  (case (ai-state enemy)
    (:stand 0.0)
    (:walk 0.1)
    (:approach 0.2)
    (T 1.0)))

(defmethod handle-ai-states ((enemy zombie) ev)
  (let* ((player (unit 'player T))
         (ploc (location player))
         (eloc (location enemy))
         (vel (velocity enemy)))
    (case (state enemy)
      (:normal
       (ecase (ai-state enemy)
         (:normal
          (cond ((< (vlength (v- ploc eloc)) (* +tile-size+ 11))
                 (start-animation 'notice enemy)
                 (setf (ai-state enemy) :approach))
                (T
                 (setf (ai-state enemy) (alexandria:random-elt '(:stand :stand :walk)))
                 (setf (timer enemy) (+ (ecase (ai-state enemy) (:stand 2.0) (:walk 1.0)) (random 2.0)))
                 (setf (direction enemy) (alexandria:random-elt '(-1 +1))))))
         ((:stand :walk)
          (when (< (vlength (v- ploc eloc)) (* +tile-size+ 10))
            (setf (ai-state enemy) :normal))
          (when (<= (decf (timer enemy) (dt ev)) 0)
            (setf (ai-state enemy) :normal))
          (when (eql 0 (solid (vec (+ (vx eloc) (* (direction enemy) (+ (vx (bsize enemy)) 1)))
                                   (- (vy eloc) (+ (vy (bsize enemy)) 1)))
                              (chunk enemy)))
            (setf (direction enemy) (* (direction enemy) -1)))
          (case (ai-state enemy)
            (:stand (setf (vx vel) 0))
            (:walk (setf (vx vel) (* (direction enemy) (movement-speed enemy))))))
         (:approach
          (cond ((< (* +tile-size+ 20) (vlength (v- ploc eloc)))
                 (setf (ai-state enemy) :normal))
                ((< (abs (- (vx ploc) (vx eloc))) (* +tile-size+ 1))
                 (start-animation 'attack enemy))
                (T
                 (setf (direction enemy) (signum (- (vx ploc) (vx eloc))))
                 (setf (vx vel) (* (direction enemy) (movement-speed enemy)))))))))))

(defmethod hit :after ((enemy zombie) location)
  (trigger 'spark enemy :location (v+ location (vrand (vec 0 0) 8)))
  (trigger 'hit enemy :location location))

(defmethod draw-item ((zombie zombie))
  (draw-item 'zombie/rewards))

(define-random-draw zombie/rewards
  (NIL 1)
  (item:small-health-pack 0.5)
  (item:medium-health-pack 0.1)
  (item:large-health-pack 0.01)
  (item:coolant 1)
  (item:heavy-spring 1)
  (item:simple-circuit 1)
  (item:cable 1))

(define-shader-entity drone (enemy immovable)
  ((bsize :initform (vec 8 10))
   (timer :initform 1f0 :accessor timer))
  (:default-initargs
   :sprite-data (asset 'kandria 'ruddydrone)))

(defmethod idleable-p ((drone drone)) NIL)

(defmethod stage :after ((drone drone) (area staging-area))
  (stage (// 'sound 'drone-damage) area))

(defmethod movement-speed ((enemy drone))
  (case (ai-state enemy)
    (:stand 0.0)
    (:wander 0.2)
    (:approach
     (let* ((animation (animation enemy))
            (progress (/ (- (frame-idx enemy) (start animation))
                         (- (end animation) (start animation)))))
       (case (name animation)
         (spin 1.0)
         (spin-start
          (* 1.0 progress))
         (spin-end
          (* 1.0 (- 1 progress)))
         (T 0.0))))
    (T 1.0)))

(defmethod handle-ai-states ((enemy drone) ev)
  (let* ((player (unit 'player T))
         (ploc (location player))
         (eloc (location enemy))
         (vel (velocity enemy))
         (distance (vlength (v- ploc eloc))))
    (unless (eql :approach (ai-state enemy))
      (when (< distance (* +tile-size+ 11))
        (setf (ai-state enemy) :approach)
        (start-animation 'notice enemy)
        (setf (timer enemy) (+ 3 (random 1.0)))))
    (case (ai-state enemy)
      (:normal
       (setf (ai-state enemy) (alexandria:random-elt '(:stand :stand :wander)))
       (setf (timer enemy) (+ 1.0 (random 2.0)))
       (if (eql :wander (ai-state enemy))
           (let ((dir (polar->cartesian (vec 1.0 (random (* 2 PI))))))
             (vsetf vel (vx dir) (vy dir)))
           (vsetf vel 0 0)))
      ((:stand :wander)
       (decf (timer enemy) (dt ev))
       (setf (animation enemy) 'stand))
      (:approach
       (cond ((< (* +tile-size+ 20) distance)
              (setf (ai-state enemy) :normal))
             ((and (eql :animated (state enemy))
                   (eql 'notice (name (animation enemy))))
              (vsetf vel 0 0))
             (T
              (when (< (timer enemy) 0)
                (when (eql 'stand (name (animation enemy)))
                  (setf (ai-state enemy) :normal))
                (start-animation 'spin-end enemy))
              (decf (timer enemy) (dt ev))
              (let ((dir (nv* (nvunit* (v- ploc eloc)) (movement-speed enemy))))
                (vsetf vel (vx dir) (vy dir)))))))))

(defmethod hit :after ((enemy drone) location)
  (trigger 'spark enemy :location (v+ location (vrand (vec 0 0) 8))))

(defmethod apply-transforms progn ((enemy drone))
  (translate-by 0 -12 0))

(defmethod draw-item ((drone drone))
  (draw-item 'drone/rewards))

(define-random-draw drone/rewards
  (NIL 1)
  (item:small-health-pack 0.5)
  (item:medium-health-pack 0.1)
  (item:large-health-pack 0.01)
  (item:crude-oil 1)
  (item:bolt 1)
  (item:simple-circuit 1)
  (item:connector 1))
