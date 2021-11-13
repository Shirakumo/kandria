(in-package #:org.shirakumo.fraf.kandria)

(define-shader-entity ball (axis-rotated-entity moving vertex-entity textured-entity)
  ((vertex-array :initform (// 'kandria '1x))
   (texture :initform (// 'kandria 'ball))
   (bsize :initform (vec 6 6))
   (axis :initform (vec 0 0 1))))

(defmethod apply-transforms progn ((ball ball))
  (let ((size (v* 2 (bsize ball))))
    (translate-by (/ (vx size) -2) (/ (vy size) -2) 0)
    (scale (vxy_ size))))

(defmethod collides-p ((player player) (ball ball) hit)
  (eql :dashing (state player)))

(defmethod collide ((player player) (ball ball) hit)
  (nv+ (velocity ball) (v* (velocity player) 0.8))
  (incf (vy (velocity ball)) 2.0)
  (vsetf (frame-velocity player) 0 0)
  (nv* (velocity player) 0.8))

(defmethod handle :before ((ev tick) (ball ball))
  (let* ((vel (velocity ball))
         (vlen (vlength vel)))
    (when (< 0 vlen)
      (decf (angle ball) (* 0.1 (vx vel)))
      (nv* vel (* (min vlen 10) (/ 0.99 vlen))))
    (nv+ vel (v* (gravity (medium ball)) (dt ev)))
    (nv+ (frame-velocity ball) vel)))

(defmethod collide ((ball ball) (block block) hit)
  (nv+ (location ball) (v* (frame-velocity ball) (hit-time hit)))
  (vsetf (frame-velocity ball) 0 0)
  (let ((vel (velocity ball))
        (normal (hit-normal hit))
        (loc (location ball)))
    (let ((ref (nv+ (v* 2 normal (v. normal (v- vel))) vel)))
      (vsetf vel
             (if (< (abs (vx ref)) 0.2) 0 (vx ref))
             (if (< (abs (vy ref)) 0.2) 0 (* 0.8 (vy ref)))))
    (nv+ loc (v* 0.1 normal))))

(defmethod collide :after ((ball ball) (block slope) hit)
  (let* ((loc (location ball))
         (normal (hit-normal hit))
         (xrel (/ (- (vx loc) (vx (hit-location hit))) +tile-size+)))
    (when (< (vx normal) 0) (incf xrel))
    ;; KLUDGE: we add a bias of 0.1 here to ensure we stop colliding with the slope.
    (let ((yrel (lerp (vy (slope-l block)) (vy (slope-r block)) (clamp 0f0 xrel 1f0))))
      (setf (vy loc) (+ 0.05 yrel (vy (bsize ball)) (vy (hit-location hit)))))))

(define-shader-entity balloon (game-entity lit-animated-sprite ephemeral)
  ()
  (:default-initargs
   :sprite-data (asset 'kandria 'balloon)))

(defmethod (setf animations) :after (animations (balloon balloon))
  (setf (next-animation (find 'die (animations balloon) :key #'name)) 'revive)
  (setf (next-animation (find 'revive (animations balloon) :key #'name)) 'stand))

(defmethod collides-p ((player player) (balloon balloon) hit)
  (eql 'stand (name (animation balloon))))

(defmethod collide ((player player) (balloon balloon) hit)
  (kill balloon)
  (setf (vy (velocity player)) 4.0)
  (case (state player)
    (:dashing
     (setf (vx (velocity player)) (* 1.1 (vx (velocity player)))))))

(defmethod kill ((balloon balloon))
  (setf (animation balloon) 'die))

(defmethod apply-transforms progn ((baloon balloon))
  (translate-by 0 -16 0))

(define-shader-entity lantern (lit-animated-sprite collider ephemeral)
  ((size :initform (vec 32 32))
   (bsize :initform (vec 16 16))
   (state :initform :active :accessor state :type symbol)
   (respawn-time :initform 0.0 :accessor respawn-time)
   (light :initform (make-instance 'textured-light :bsize (vec 48 48) :size (vec 96 96) :offset (vec 0 48)) :accessor light))
  (:default-initargs
   :sprite-data (asset 'kandria 'lantern)))

(defmethod collides-p ((lantern lantern) thing hit) NIL)
(defmethod collides-p ((player player) (lantern lantern) hit)
  (and (< 0.0 (dash-time player))
       (eq :active (state lantern))))

(defmethod collide ((player player) (lantern lantern) hit)
  (setf (climb-strength player) (p! climb-strength))
  (setf (direction lantern) (direction player))
  (setf (dash-pending player) T)
  (setf (state lantern) :inactive)
  (setf (respawn-time lantern) 5.0)
  (setf (animation lantern) 'crash))

(defmethod enter* :after ((lantern lantern) container)
  (setf (slot-value (light lantern) 'location) (location lantern))
  (setf (container (light lantern)) +world+)
  (compile-into-pass (light lantern) NIL (unit 'lighting-pass +world+)))

(defmethod leave* :after ((lantern lantern) (container container))
  (remove-from-pass (light lantern) (unit 'lighting-pass +world+)))

(defmethod (setf location) :after (loc (lantern lantern))
  (setf (slot-value (light lantern) 'location) (location lantern)))

(defmethod handle ((ev switch-chunk) (lantern lantern))
  (setf (state lantern) :active)
  (setf (animation lantern) 'active))

(defmethod handle :before ((ev tick) (lantern lantern))
  (case (state lantern)
    (:active
     (setf (multiplier (light lantern)) 1.0))
    (:inactive
     (setf (multiplier (light lantern)) 0.0)
     (when (<= (decf (respawn-time lantern) (dt ev)) 0.0)
       (setf (state lantern) :active)
       (setf (animation lantern) 'respawn)))))

(define-shader-entity spring (lit-animated-sprite collider ephemeral)
  ((size :initform (vec 16 16))
   (bsize :initform (vec 8 8))
   (iframes :initform 0.0 :accessor iframes)
   (strength :initform (vec 0 7) :initarg :strength :accessor strength :type vec2))
  (:default-initargs
   :sprite-data (asset 'kandria 'spring)))

(defmethod initargs append ((spring spring))
  '(:strength))

(defmethod collides-p (thing (spring spring) hit) NIL)
(defmethod collides-p ((moving moving) (spring spring) hit)
  (< 0.5 (iframes spring)))

(defmethod collide ((moving moving) (spring spring) hit)
  (let ((strength (strength spring)))
    (setf (iframes spring) 0.0)
    (setf (animation spring) 'spring)
    (v<- (velocity moving) strength)))

(defmethod collide :after ((player player) (spring spring) hit)
  (setf (climb-strength player) (p! climb-strength))
  (setf (dash-time player) 0.0)
  (setf (state player) :normal))

(defmethod handle :after ((ev tick) (spring spring))
  (incf (iframes spring) (dt ev)))

(defmethod bsize ((spring spring))
  (let ((strength (strength spring)))
    (if (/= 0 (vx strength))
        #.(vec 2 8)
        #.(vec 8 2))))

(defmethod apply-transforms progn ((spring spring))
  (let ((strength (strength spring)))
    (cond ((< 0 (vx2 strength))
           (rotate-by 0 0 1 (/ PI -2))
           (translate-by -8 -2 0))
          ((> 0 (vx2 strength))
           (rotate-by 0 0 1 (/ PI +2))
           (translate-by +8 -2 0))
          ((< 0 (vy2 strength)))
          ((> 0 (vy2 strength))
           (rotate-by 0 0 1 PI)
           (translate-by 0 -4 0)))))
