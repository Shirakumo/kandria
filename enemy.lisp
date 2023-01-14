(in-package #:org.shirakumo.fraf.kandria)

(define-global +health-multiplier+ 1f0)

(define-shader-entity enemy (ai-entity animatable)
  ((bsize :initform (vec 8.0 8.0))
   (cooldown :initform 0.0 :accessor cooldown)
   (ai-state :initform :normal :accessor ai-state :type symbol)))

(defmethod is-collider-for ((enemy enemy) (moving moving)) T)
(defmethod is-collider-for ((enemy enemy) (other enemy)) NIL)
(defmethod is-collider-for ((enemy enemy) (other stopper)) NIL)
(defmethod collides-p ((enemy enemy) (other enemy) hit) NIL)

(defmethod collides-p ((enemy enemy) (other stopper) hit)
  (when (chunk enemy)
    (let ((tile (tile (tv- (hit-location hit) #.(vec 0 16))
                      (chunk enemy))))
      (when tile (/= 2 (car tile))))))

(defmethod base-health ((enemy enemy)) 1000)

(defmethod initialize-instance :after ((enemy enemy) &key)
  (setf (health enemy) (* (health enemy) +health-multiplier+)))

(defmethod hurt ((a enemy) (b enemy)))

(defmethod draw-item ((enemy enemy)) NIL)

(defmethod die :after ((enemy enemy))
  (let ((item (draw-item enemy)))
    (when item
      (mark-as-spawned (spawn (location enemy) item)))))

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

(define-shader-entity sawblade (enemy solid immovable creatable)
  ((bsize :initform (vec 16 16)))
  (:default-initargs
   :sprite-data (asset 'kandria 'sawblade)))

(defmethod state ((sawblade sawblade)) :animated)

(defmethod idleable-p ((sawblade sawblade)) NIL)

(defmethod (setf health) (value (sawblade sawblade)) value)

(define-shader-entity box (enemy solid immovable creatable)
  ((bsize :initform (vec 8 8)))
  (:default-initargs
   :sprite-data (asset 'kandria 'box)))

(defmethod base-health ((box box)) 20)

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

(define-shader-entity minor-enemy (enemy)
  ((health-bar :initform NIL :accessor health-bar)))

(defmethod shared-initialize :after ((enemy minor-enemy) slots &key)
  (unless (health-bar enemy)
    (setf (health-bar enemy) (make-instance 'enemy-health-bar :value enemy))))

(defmethod hurt :after ((enemy minor-enemy) by)
  (when (setting :gameplay :display-hud)
    (show (health-bar enemy))
    (alloy:mark-for-render (health-bar enemy))))

(defmethod leave :after ((enemy minor-enemy) (container container))
  (hide (health-bar enemy)))

(defmethod handle :after ((ev tick) (enemy minor-enemy))
  (when (slot-boundp (health-bar enemy) 'alloy:layout-parent)
    (show (health-bar enemy))))

(define-shader-entity major-enemy (enemy)
  ((health-bar :initform NIL :accessor health-bar)))

(defmethod shared-initialize :after ((enemy major-enemy) slots &key)
  (unless (health-bar enemy)
    (setf (health-bar enemy) (make-instance 'boss-health-bar :value enemy))))

(defmethod update-instance-for-different-class :before ((enemy major-enemy) cur &key)
  (unless (typep cur 'major-enemy)
    (when (health-bar enemy)
      (hide (health-bar enemy)))))

(defmethod leave :after ((enemy major-enemy) (container container))
  (hide (health-bar enemy)))

(defmethod (setf health) :after (value (enemy major-enemy))
  (alloy:mark-for-render (health-bar enemy)))

(defmethod (setf ai-state) :after (state (enemy major-enemy))
  (case state
    (:active (show (health-bar enemy)))
    (:normal (hide (health-bar enemy)))))

(define-shader-entity ground-enemy (enemy)
  ())

(defmethod handle :after ((ev tick) (enemy ground-enemy))
  ;; Animations
  (case (state enemy)
    ((:dying :animated :stunned :dead))
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

(define-shader-entity dummy (minor-enemy half-solid immovable creatable)
  ((bsize :initform (vec 8 16)))
  (:default-initargs
   :sprite-data (asset 'kandria 'dummy)))

(defmethod idleable-p ((dummy dummy)) NIL)

(define-shader-entity wolf (paletted-entity ground-enemy minor-enemy half-solid creatable)
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

(defmethod die :before ((enemy wolf))
  (when (setting :gameplay :exploding-wolves)
    (trigger 'explosion enemy)))

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
                 ((if (<= 0.0 (vx vel))
                      (svref (collisions enemy) 1)
                      (svref (collisions enemy) 3))
                  (setf (ai-state enemy) :approach))
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

(define-shader-entity zombie (paletted-entity ground-enemy minor-enemy half-solid creatable)
  ((bsize :initform (vec 4 16))
   (timer :initform 0.0 :accessor timer)
   (palette :initform (// 'kandria 'zombie-palette))
   (palette-index :initform (random 5)))
  (:default-initargs
   :sprite-data (asset 'kandria 'zombie)))

(defmethod stage :after ((zombie zombie) (area staging-area))
  (dolist (sound '(zombie-notice zombie-attack zombie-damage zombie-die))
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
                ((< (vlength (v- ploc eloc)) (* +tile-size+ 1))
                 (start-animation 'attack enemy))
                (T
                 (setf (direction enemy) (signum (- (vx ploc) (vx eloc))))
                 (setf (vx vel) (* (direction enemy) (movement-speed enemy)))))))))))

(defmethod hit :after ((enemy zombie) location)
  (trigger 'spark enemy :location (v+ location (vrand (vec 0 0) 8))))

(defmethod draw-item ((zombie zombie))
  (draw-item 'zombie/rewards))

(define-random-draw zombie/rewards
  (NIL 1)
  (item:small-health-pack 0.5)
  (item:medium-health-pack 0.1)
  (item:large-health-pack 0.01)
  (item:nanomachine-salve 0.1)
  (item:combat-booster 0.1)
  (item:damage-shield 0.1)
  (item:coolant 1)
  (item:heavy-spring 1)
  (item:simple-circuit 1)
  (item:cable 1))

(define-shader-entity drone (minor-enemy enemy immovable creatable)
  ((bsize :initform (vec 8 10))
   (timer :initform 1f0 :accessor timer))
  (:default-initargs
   :sprite-data (asset 'kandria 'ruddydrone)))

(defmethod idleable-p ((drone drone)) NIL)
(defmethod collides-p ((drone drone) (other stopper) hit) NIL)
(defmethod collides-p ((drone drone) (other platform) hit) NIL)

(defmethod stage :after ((drone drone) (area staging-area))
  (dolist (sound '(drone-damage drone-attack-001 drone-attack-002 drone-die drone-notice))
    (stage (// 'sound sound) area)))

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

(defmethod (setf medium) :around (value (enemy drone))
  value)

(defmethod medium ((enemy drone))
  (load-time-value (make-instance 'vacuum)))

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
           (let ((dir (vcartesian (vec 1.0 (random (* 2 PI))))))
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
              (nv* vel (damp* 0.97 (* 100 (dt ev)))))
             (T
              (when (< (timer enemy) 0)
                (when (eql 'stand (name (animation enemy)))
                  (setf (ai-state enemy) :normal))
                (start-animation 'spin-end enemy))
              (decf (timer enemy) (dt ev))
              (let ((dir (nvunit* (v- ploc eloc))))
                (nv+ vel (nv* dir 0.02))
                (when (<= 2.0 (vlength vel))
                  (nv* (nvunit vel) 2.0)))))))))

(defmethod hit :after ((enemy drone) location)
  (trigger 'spark enemy :location (v+ location (vrand (vec 0 0) 8))))

(defmethod collide :after ((enemy drone) thing hit)
  (nvunit* (velocity enemy))
  (nv* (velocity enemy) -2.0)
  (nv+ (location enemy) (velocity enemy)))

(defmethod path ((enemy drone))
  (list T))

(defmethod apply-transforms progn ((enemy drone))
  (translate-by 0 -12 0))

(defmethod draw-item ((drone drone))
  (draw-item 'drone/rewards))

(define-random-draw drone/rewards
  (NIL 1)
  (item:small-health-pack 0.5)
  (item:medium-health-pack 0.1)
  (item:large-health-pack 0.01)
  (item:nanomachine-salve 0.1)
  (item:crude-oil 1)
  (item:bolt 1)
  (item:simple-circuit 1)
  (item:connector 1))

(define-shader-entity rogue (paletted-entity ground-enemy minor-enemy half-solid creatable)
  ((bsize :initform (vec 7 16))
   (timer :initform 0.0 :accessor timer)
   (palette :initform (// 'kandria 'rogue-palette))
   (palette-index :initform (random 4)))
  (:default-initargs
   :sprite-data (asset 'kandria 'rogue)))

(defmethod stage :after ((enemy rogue) (area staging-area))
  (dolist (asset '(human-damage-1 human-damage-2 human-damage-3 human-damage-4
                   human-die))
    (stage (// 'sound asset) area)))

(defmethod movement-speed ((enemy rogue))
  (case (ai-state enemy)
    (:stand 0.0)
    (:walk (p! slowwalk-limit))
    (T (p! walk-limit))))

(defmethod handle-ai-states ((enemy rogue) ev)
  (let* ((player (unit 'player T))
         (ploc (location player))
         (eloc (location enemy))
         (vel (velocity enemy)))
    (case (state enemy)
      (:normal
       (when (<= (cooldown-time enemy) 0.0)
         (ecase (ai-state enemy)
           (:normal
            (cond ((< (vlength (v- ploc eloc)) (* +tile-size+ 11))
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
            (case (ai-state enemy)
              (:stand (setf (vx vel) 0))
              (:walk
               (cond ((svref (collisions enemy) 1)
                      (setf (direction enemy) -1))
                     ((svref (collisions enemy) 3)
                      (setf (direction enemy) +1)))
               (setf (vx vel) (* (direction enemy) (movement-speed enemy))))))
           (:approach
            (cond ((< (* +tile-size+ 20) (vlength (v- ploc eloc)))
                   (setf (ai-state enemy) :normal))
                  ((< (vlength (v- ploc eloc)) (* +tile-size+ 2))
                   (start-animation (alexandria:random-elt '(attack attack2)) enemy))
                  ((or (svref (collisions enemy) 1)
                       (svref (collisions enemy) 3))
                   (setf (direction enemy) (signum (- (vx ploc) (vx eloc))))
                   (setf (vx vel) (* (direction enemy) (movement-speed enemy)))
                   (when (svref (collisions enemy) 2)
                     (cond ((< (vy eloc) (vy ploc))
                            (setf (vy vel) 3.0))
                           ((typep (svref (collisions enemy) 2) 'platform)
                            (decf (vy eloc) 2))
                           (T
                            (setf (vx vel) 0.0)))))
                  (T
                   (cond ((< (* +tile-size+ 2) (abs (- (vy ploc) (vy eloc))))
                          (setf (vx vel) 0))
                         ((< (* +tile-size+ 4) (abs (- (vx ploc) (vx eloc))))
                          (setf (direction enemy) (signum (- (vx ploc) (vx eloc))))
                          (setf (vx vel) (* (direction enemy) (movement-speed enemy))))
                         (T
                          (setf (vx vel) (* (direction enemy) (movement-speed enemy))))))))))))))

(defmethod hit :after ((enemy rogue) location)
  (trigger 'spark enemy :location (v+ location (vrand (vec 0 0) 8))))

(defmethod draw-item ((rogue rogue))
  (draw-item 'rogue/rewards))

(define-random-draw rogue/rewards
  (NIL 1)
  (item:small-health-pack 0.5)
  (item:medium-health-pack 0.1)
  (item:large-health-pack 0.01)
  (item:thermal-fluid 1)
  (item:heavy-spring 1)
  (item:simple-circuit 1)
  (item:cable 1)
  (item:nanomachine-salve 0.1)
  (item:combat-booster 0.1)
  (item:damage-shield 0.1))

(define-shader-entity wraw (rogue)
  ((palette :initform (// 'kandria 'wraw-npc-palette))
   (palette-index :initform (random 4)))
  (:default-initargs
   :sprite-data (asset 'kandria 'wraw-npc)))

(defmethod movement-speed ((enemy wraw))
  (case (ai-state enemy)
    (:stand 0.0)
    (T 0.5)))

(define-shader-entity zelah-enemy (ground-enemy major-enemy half-solid dialog-entity profile ephemeral)
  ((timer :initform 0f0 :accessor timer)))

(defmethod shared-initialize :after ((enemy zelah-enemy) slots &key))

(defmethod movement-speed ((enemy zelah-enemy))
  (case (ai-state enemy)
    (:stand 0.0)
    (:walk (p! slowwalk-limit))
    (T (p! walk-limit))))

(defmethod interactable-p ((enemy zelah-enemy)) NIL)
(defmethod is-collider-for ((enemy zelah-enemy) (block stopper)) NIL)
(defmethod collides-p ((enemy zelah-enemy) (block stopper) hit) NIL)
(defmethod interrupt ((enemy zelah-enemy)) NIL)

(defmethod handle-ai-states ((enemy zelah-enemy) ev)
  (case (state enemy)
    (:normal
     (when (<= (cooldown-time enemy) 0.0)
       (case (ai-state enemy)
         (:normal
          (setf (ai-state enemy) :active))
         (:active
          (let* ((player (unit 'player T))
                 (ploc (location player))
                 (eloc (location enemy))
                 (vel (velocity enemy)))
            (cond ((<= (decf (timer enemy) (dt ev)) 0.0)
                   (setf (ai-state enemy) :gloat)
                   (start-animation 'idle enemy)
                   (setf (timer enemy) (random* 3.0 1.0)))
                  ((< (abs (- (vx ploc) (vx eloc))) (* +tile-size+ 2))
                   (start-animation 'attack enemy))
                  ((or (svref (collisions enemy) 1)
                       (svref (collisions enemy) 3))
                   (setf (direction enemy) (signum (- (vx ploc) (vx eloc))))
                   (setf (vx vel) (* (direction enemy) (movement-speed enemy)))
                   (when (svref (collisions enemy) 2)
                     (setf (vy vel) 3.0)))
                  (T
                   (setf (direction enemy) (signum (- (vx ploc) (vx eloc))))
                   (setf (vx vel) (* (direction enemy) (movement-speed enemy)))))))
         (:gloat
          (when (<= (decf (timer enemy) (dt ev)) 0.0)
            (setf (ai-state enemy) :active)
            (setf (timer enemy) (random* 5.0 3.0)))))))))

(defmethod die ((enemy zelah-enemy))
  (setf (state enemy) :dead)
  (setf (ai-state enemy) :dead)
  (setf (animation enemy) 'dead)
  (transition
    :kind :black
    (show-panel 'early-end-screen :message (language-string 'zelah-early-death-ending))))

(define-shader-entity mech (ground-enemy major-enemy solid immovable creatable)
  ((bsize :initform (vec 20 42))
   (last-action :initform NIL :accessor last-action)
   (timer :initform 0.0 :accessor timer)
   (damage-input-scale :initform 0.5)
   (damage-accumulated :initform 0.0 :accessor damage-accumulated)
   (level :initform 20)
   (ai-state :initform :active))
  (:default-initargs
   :sprite-data (asset 'kandria 'mech)))

(defmethod stage :after ((enemy mech) (area staging-area))
  (dolist (sound '(mech-bash mech-die mech-jump mech-land mech-pierce mech-step-1 mech-step-2 mech-stun))
    (stage (// 'sound sound) area)))

(defmethod idleable-p ((enemy mech)) NIL)

(defmethod base-health ((enemy mech)) 5000)

(defmethod quest:activate ((enemy mech))
  (setf (ai-state enemy) :active))

(defmethod quest:deactivate ((enemy mech))
  (setf (ai-state enemy) :normal))

(defmethod handle-ai-states ((enemy mech) ev)
  (case (state enemy)
    (:normal
     (case (ai-state enemy)
       (:normal)
       (:active
        (when (<= (cooldown-time enemy) 0.0)
          (let* ((player (unit 'player +world+))
                 (direction (- (vx (location player)) (vx (location enemy))))
                 (distance (abs direction))
                 (tentative (cond ((< (* 0.25 (maximum-health enemy)) (damage-accumulated enemy)) 'stun)
                                  ((< (* +tile-size+ 12) distance) 'pierce)
                                  ((< (* +tile-size+ 6) distance) 'jump)
                                  (T 'bash))))
            (when (< (* +tile-size+ 100) distance)
              (setf (ai-state enemy) :normal))
            (flet ((select (move)
                     (setf (timer enemy) 3.0)
                     (setf (last-action enemy) move)
                     (start-animation move enemy)))
              (setf (direction enemy) (float-sign direction))
              (cond ((not (eql tentative (last-action enemy)))
                     (select tentative))
                    ((<= distance (vx (bsize enemy))) ;; Player is probably on top, bash always.
                     (select 'bash))
                    ((<= 0.0 (decf (timer enemy) (dt ev))))
                    ((< distance (* +tile-size+ 6)) ;; Jump over
                     (select 'jump))
                    (T
                     (select 'walk)))))))))))

(defmethod handle :before ((ev tick) (enemy mech))
  (case (state enemy)
    (:dying
     (when (<= (decf (timer enemy) (dt ev)) 0.0)
       (setf (timer enemy) (+ 0.1 (random 0.1)))
       (trigger 'explosion enemy :location (nv+ (vrand (location enemy) (vec 96 48)) (vec (* (direction enemy) -16) -30)))))))

(defmethod switch-animation :before ((enemy mech) next)
  (when (eql (name (animation enemy)) 'stun)
    (setf (damage-accumulated enemy) 0)))

(defmethod collide :before ((moving mech) (player player) hit)
  (when (< 0 (vy (hit-normal hit)))
    (let* ((bsize (bsize player))
           (dir (float-sign (- (vx (location player)) (vx (location moving)))))
           (xd (* dir (+ (vx (bsize moving)) (vx bsize)))))
      (setf (direction player) (- dir))
      (cond ((null (scan-collision-for player +world+ (tvec (+ (vx (location moving)) xd) (vy (location player)) (vx bsize) (vy bsize))))
             (setf (vx (location player)) (+ (vx (location moving)) xd)))
            ((null (scan-collision-for player +world+ (tvec (- (vx (location moving)) xd) (vy (location player)) (vx bsize) (vy bsize))))
             (setf (vx (location player)) (- (vx (location moving)) xd)))
            (T
             (setf (vy (location player)) (+ (vy (location moving)) (vy (bsize moving)) (vy bsize))))))))

(defmethod kill :after ((animatable mech))
  (setf (timer animatable) 0.5))

(defmethod hurt ((animatable mech) (damage integer))
  (setf (ai-state animatable) :active)
  (let* ((damage (* (damage-input-scale animatable) damage))
         (hard-hit-p (<= (* +hard-hit+ (maximum-health animatable)) damage)))
    (cond ((invincible-p animatable)
           (setf damage 0))
          (hard-hit-p
           (setf (pause-timer +world+) 0.08)))
    (trigger (make-instance 'text-effect) animatable
             :text (princ-to-string (truncate damage))
             :location (vec (+ (vx (location animatable)))
                            (+ (vy (location animatable)) 8 (vy (bsize animatable)))))
    (incf (damage-accumulated animatable) damage)
    (decf (health animatable) damage)))

(defmethod interrupt ((animatable mech))
  (when (interruptable-p (frame animatable))
    (unless (eql :stunned (state animatable))
      (setf (state animatable) :animated))))
