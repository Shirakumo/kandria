(in-package #:org.shirakumo.fraf.kandria)

(define-shader-entity moving-platform (game-entity resizable solid ephemeral)
  ((layer-index :initform (1+ +base-layer+))))

(defmethod collides-p ((platform moving-platform) thing hit) NIL)
(defmethod collides-p ((platform moving-platform) (block block) hit) T)
(defmethod collides-p ((platform moving-platform) (solid solid) hit) T)
(defmethod collides-p ((platform moving-platform) (entity ai-entity) hit) NIL)

(define-shader-entity falling-platform (lit-sprite moving-platform)
  ())

(defmethod (setf location) :after (location (platform falling-platform))
  (setf (state platform) :normal))

(defmethod handle ((ev tick) (platform falling-platform))
  (ecase (state platform)
    (:blocked
     (vsetf (velocity platform) 0 0))
    (:normal
     (loop repeat 10 while (handle-collisions +world+ platform)))
    (:falling
     (nv+ (velocity platform) (nv* (vec 0 -10) (dt ev)))
     (nv+ (frame-velocity platform) (velocity platform))
     (loop repeat 10 while (handle-collisions +world+ platform)))))

(defmethod collide :before ((player player) (platform falling-platform) hit)
  (when (< 0 (vy (hit-normal hit)))
    (case (state platform)
      (:normal
       (setf (state platform) :falling)))))

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
      (shake-camera :intensity 5)
      (setf (state platform) :blocked)
      (nv+ (location platform) (v* vel (hit-time hit)))
      (vsetf vel 0 0))))

(defmethod collide ((platform falling-platform) (block block) hit)
  (when (eq :falling (state platform))
    (let ((vel (frame-velocity platform)))
      (shake-camera :intensity 5)
      (setf (state platform) :blocked)
      (nv+ (location platform) (v* vel (hit-time hit)))
      (vsetf vel 0 0))))

(define-shader-entity elevator (lit-sprite moving-platform)
  ((bsize :initform (nv/ (vec 32 16) 2))
   (fit-to-bsize :initform NIL)
   (texture :initform (// 'kandria 'elevator))))

(defmethod handle ((ev tick) (elevator elevator))
  (ecase (state elevator)
    (:normal
     (vsetf (velocity elevator) 0 0))
    (:going-up
     (vsetf (velocity elevator) 0 +1.0))
    (:going-down
     (vsetf (velocity elevator) 0 -1.0))
    (:broken
     (vsetf (velocity elevator) 0 0)))
  (nv+ (frame-velocity elevator) (velocity elevator))
  (loop repeat 10 while (handle-collisions +world+ elevator)))

(defmethod collide :before ((player player) (elevator elevator) hit)
  (setf (interactable player) elevator))

(defmethod collide ((elevator elevator) (block block) hit)
  (unless (typep block 'platform)
    (let ((vel (frame-velocity elevator)))
      (setf (state elevator) :normal)
      (nv+ (location elevator) (v* vel (hit-time hit)))
      (vsetf vel 0 0))))

(defmethod interact ((elevator elevator) thing)
  (case (state elevator)
    (:normal
     (cond ((null (scan-collision +world+ (v+ (location elevator)
                                              (v_y (bsize elevator))
                                              1)))
            (setf (state elevator) :going-up))
           ((null (scan-collision +world+ (v- (location elevator)
                                              (v_y (bsize elevator))
                                              1)))
            (setf (state elevator) :going-down))))
    (:going-down
     (setf (state elevator) :going-up))
    (:going-up
     (setf (state elevator) :going-down))))
