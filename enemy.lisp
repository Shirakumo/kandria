(in-package #:org.shirakumo.fraf.kandria)

(define-global +health-multiplier+ 1f0)

(define-shader-entity enemy (ai-entity animatable)
  ((bsize :initform (vec 8.0 8.0))
   (cooldown :initform 0.0 :accessor cooldown)
   (ai-state :initform :normal :accessor ai-state)))

(defmethod maximum-health ((enemy enemy)) 100)

(defmethod initialize-instance :after ((enemy enemy) &key)
  (setf (health enemy) (* (health enemy) +health-multiplier+)))

(defmethod capable-p ((enemy enemy) (edge crawl-node)) T)
(defmethod capable-p ((enemy enemy) (edge jump-node)) T)

(defmethod collide :after ((player player) (enemy enemy) hit)
  (when (eql :dashing (state player))
    (nv+ (velocity enemy) (v* (velocity player) 0.8))
    (incf (vy (velocity enemy)) 3.0)
    (nv* (velocity player) -0.25)
    (incf (vy (velocity player)) 2.0)
    (stun player 0.27)))

(define-shader-entity dummy (enemy immovable)
  ((bsize :initform (vec 8 16)))
  (:default-initargs
   :sprite-data (asset 'kandria 'dummy)))

(defmethod idleable-p ((dummy dummy)) NIL)

(define-shader-entity box (enemy solid immovable)
  ((bsize :initform (vec 8 8)))
  (:default-initargs
   :sprite-data (asset 'kandria 'box)))

(defmethod maximum-health ((box box)) 20)

(defmethod idleable-p ((box box)) NIL)

(defmethod collides-p ((movable movable) (box box) hit)
  (not (eql (state box) :dying)))

(defmethod stage :after ((box box) (area staging-area))
  (stage (// 'kandria 'box-damage) area)
  (stage (// 'kandria 'box-break) area))

(defmethod hurt :after ((box box) (by integer))
  (harmony:play (// 'kandria 'box-damage)))

(defmethod kill :after ((box box))
  (harmony:play (// 'kandria 'box-break)))

(define-shader-entity ground-enemy (enemy)
  ())

(defmethod handle :before ((ev tick) (enemy ground-enemy))
  (nv+ (velocity enemy) (v* (gravity (medium enemy)) (* 100 (dt ev)))))

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
             ((<= 0.75 (abs (vx vel)))
              (setf (animation enemy) 'run))
             ((< 0 (abs (vx vel)))
              (setf (animation enemy) 'walk))
             (T
              (setf (animation enemy) 'stand)))))))

(define-shader-entity wolf (ground-enemy)
  ()
  (:default-initargs
   :sprite-data (asset 'kandria 'wolf)))

(defmethod movement-speed ((enemy wolf))
  (case (state enemy)
    (:crawling 0.4)
    (:normal 0.5)
    (T 2.0)))

(defmethod handle-ai-states ((enemy wolf) ev)
  (let* ((player (unit 'player T))
         (ploc (location player))
         (eloc (location enemy))
         (distance (vlength (v- ploc eloc)))
         (col (collisions enemy))
         (vel (velocity enemy)))
    (ecase (ai-state enemy)
      ((:normal :crawling)
       (cond ;; ((< distance 400)
             ;;  (setf (state enemy) :approach))
         ((and (null (path enemy)) (<= (cooldown enemy) 0))
          (if (ignore-errors (move-to (vec (+ (vx (location enemy)) (- (random 200) 50)) (+ (vy (location enemy)) 64)) enemy))
              (setf (cooldown enemy) (+ 0.5 (expt (random 1.5) 2)))
              (setf (cooldown enemy) 0.1)))
         ((null (path enemy))
          (decf (cooldown enemy) (dt ev)))))
      (:approach (setf (state enemy) :normal))
      ;; (:approach
      ;;  ;; FIXME: This should be reached even when there is a path being executed right now.
      ;;  (cond ((< distance 200)
      ;;         (setf (path enemy) ())
      ;;         (setf (state enemy) :attack))
      ;;        ((null (path enemy))
      ;;         (ignore-errors (move-to (location player) enemy)))))
      ;; (:evade
      ;;  (if (< 100 distance)
      ;;      (setf (state enemy) :attack)
      ;;      (let ((dir (signum (- (vx eloc) (vx ploc)))))
      ;;        (when (and (svref col 2) (svref col (if (< 0 dir) 1 3)))
      ;;          (setf (vy vel) 3.2))
      ;;        (setf (vx vel) (* dir 2.0)))))
      ;; (:attack
      ;;  (cond ((< 500 distance)
      ;;         (setf (state enemy) :normal))
      ;;        ((< distance 80)
      ;;         (setf (state enemy) :evade))
      ;;        (T
      ;;         (setf (direction enemy) (signum (- (vx (location player)) (vx (location enemy)))))
      ;;         (cond ((svref col (if (< 0 (direction enemy)) 1 3))
      ;;                (setf (vy vel) 2.0)
      ;;                (setf (vx vel) (* (direction enemy) 2.0)))
      ;;               ((svref col 2)
      ;;                (setf (vy vel) 0.0)
      ;;                ;; Check that tackle would even be possible to hit (no obstacles)
      ;;                (start-animation 'tackle enemy))))))
      )))

(define-shader-entity zombie (ground-enemy half-solid)
  ((bsize :initform (vec 4 16))
   (timer :initform 0.0 :accessor timer))
  (:default-initargs
   :sprite-data (asset 'kandria 'zombie)))

(defmethod stage :after ((enemy zombie) (area staging-area))
  (stage (// 'kandria 'stab) area)
  (stage (// 'kandria 'zombie-notice) area)
  (stage (// 'kandria 'explosion) area))

(defmethod movement-speed ((enemy zombie))
  (case (state enemy)
    (:stand 0.0)
    (:walk 0.1)
    (:approach 0.2)
    (T 1.0)))

(defmethod handle-ai-states ((enemy zombie) ev)
  (let* ((player (unit 'player T))
         (ploc (location player))
         (eloc (location enemy))
         (vel (velocity enemy)))
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
         (start-animation 'notice enemy))
       (when (<= (decf (timer enemy) (dt ev)) 0)
         (setf (ai-state enemy) :normal))
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
              (setf (vx vel) (* (direction enemy) (movement-speed enemy)))))))))

(defmethod hit ((enemy zombie) location)
  (trigger 'spark enemy :location (v+ location (vrand -4 +4))))

(define-shader-entity drone (enemy immovable)
  ((bsize :initform (vec 8 10))
   (timer :initform 1f0 :accessor timer))
  (:default-initargs
   :sprite-data (asset 'kandria 'ruddydrone)))

(defmethod stage :after ((drone drone) (area staging-area))
  (stage (// 'kandria 'explosion) area))

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

(defmethod hit ((enemy drone) location)
  (trigger 'spark enemy :location (v+ location (vrand -4 +4))))

(defmethod apply-transforms progn ((enemy drone))
  (translate-by 0 -12 0))
