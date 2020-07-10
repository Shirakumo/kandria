(in-package #:org.shirakumo.fraf.leaf)

(define-shader-entity moving-platform (game-entity resizable solid ephemeral)
  ()
  (:default-initargs
   :bsize (vec2 32 32)))

(defmethod collides-p ((platform moving-platform) thing hit) NIL)
(defmethod collides-p ((platform moving-platform) (block block) hit) T)
(defmethod collides-p ((platform moving-platform) (solid solid) hit) T)

(define-shader-entity falling-platform (lit-sprite moving-platform)
  ((gravity :initform +vgrav+ :initarg :gravity :accessor gravity)))

(defmethod (setf location) :after (location (platform falling-platform))
  (setf (state platform) :normal))

(defmethod handle ((ev tick) (platform falling-platform))
  (ecase (state platform)
    (:blocked)
    (:normal
     (loop repeat 10 while (handle-collisions +world+ platform)))
    (:falling
     (nv+ (velocity platform) (v* (gravity platform) (dt ev)))
     (nv+ (frame-velocity platform) (velocity platform))
     (loop repeat 10 while (handle-collisions +world+ platform)))))

(defmethod collide :before ((player player) (platform falling-platform) hit)
  (when (< 0 (vy (hit-normal hit)))
    (nv+ (frame-velocity platform) (velocity platform))
    (if (scan-collision +world+ platform)
        (vsetf (velocity platform) 0 0)
        (setf (state platform) :falling))))

(defmethod collide ((platform falling-platform) (other falling-platform) hit)
  (when (and (eq :falling (state platform))
             (< 0 (vy (hit-normal hit))))
    (let ((vel (frame-velocity platform)))
      (shake-camera)
      (nv+ (location platform) (v* vel (hit-time hit)))
      (vsetf vel (vx (velocity other)) (vy (velocity other)))
      (if (eq :blocked (state other))
          (setf (state platform) :blocked)
          (setf (state other) :falling)))))

(defmethod collide ((platform falling-platform) (solid solid) hit)
  (when (eq :falling (state platform))
    (let ((vel (frame-velocity platform)))
      (shake-camera)
      (setf (state platform) :blocked)
      (nv+ (location platform) (v* vel (hit-time hit)))
      (vsetf vel 0 0))))

(defmethod collide ((platform falling-platform) (block block) hit)
  (when (eq :falling (state platform))
    (let ((vel (frame-velocity platform)))
      (shake-camera)
      (setf (state platform) :blocked)
      (nv+ (location platform) (v* vel (hit-time hit)))
      (vsetf vel 0 0))))

(define-shader-entity elevator (lit-sprite moving-platform)
  ()
  (:default-initargs :bsize (nv/ (vec 32 16) 2)))

(defmethod handle ((ev tick) (elevator elevator))
  (ecase (state elevator)
    (:normal)
    (:going-up
     (vsetf (velocity elevator) 0 +10))
    (:going-down
     (vsetf (velocity elevator) 0 -10))
    (:broken))
  (nv+ (frame-velocity elevator) (velocity elevator))
  (loop repeat 10 while (handle-collisions +world+ elevator)))

(defmethod collide :before ((player player) (elevator elevator) hit)
  (setf (interactable player) elevator))

(defmethod collide ((elevator elevator) (block block) hit)
  (let ((vel (frame-velocity elevator)))
    (setf (state elevator) :normal)
    (nv+ (location elevator) (v* vel (hit-time hit)))
    (vsetf vel 0 0)))

(defmethod handle ((ev interaction) (elevator elevator))
  (when (and (eq elevator (slot-value ev 'with))
             (eql :normal (state elevator)))
    (cond ((null (scan-collisions +world+ (v+ (location elevator)
                                              (v_y (bsize elevator))
                                              1)))
           (setf (state elevator) :going-up))
          ((null (scan-collisions +world+ (v- (location elevator)
                                              (v_y (bsize elevator))
                                              1)))
           (setf (state elevator) :going-down)))))
