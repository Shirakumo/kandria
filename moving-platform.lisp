(in-package #:org.shirakumo.fraf.leaf)

(define-shader-subject moving-platform (game-entity resizable solid)
  ()
  (:default-initargs
   :bsize (vec2 32 32)))

(defmethod collides-p ((platform moving-platform) thing hit) NIL)
(defmethod collides-p ((platform moving-platform) (block block) hit) T)
(defmethod collides-p ((platform moving-platform) (solid solid) hit) T)

(define-shader-subject falling-platform (lit-sprite moving-platform)
  ((acceleration :initform (vec2 0 0) :accessor acceleration)
   (gravity :initform (vec2 0 (- +vgrav+)) :initarg :gravity :accessor gravity)))

(defmethod (setf location) :after (location (platform falling-platform))
  (setf (state platform) :normal))

(defmethod tick ((platform falling-platform) ev)
  (ecase (state platform)
    (:blocked)
    (:normal
     (loop repeat 10 while (scan (surface platform) platform)))
    (:falling
     (nv+ (acceleration platform) (v* (gravity platform) (dt ev)))
     (nv+ (velocity platform) (acceleration platform))
     (loop repeat 10 while (scan (surface platform) platform))
     (nv+ (location platform) (v* (velocity platform) (* 100 (dt ev)))))))

(defmethod collide :before ((player player) (platform falling-platform) hit)
  (when (< 0 (vy (hit-normal hit)))
    (nv+ (velocity platform) (acceleration platform))
    (if (scan (surface platform) platform)
        (vsetf (velocity platform) 0 0)
        (setf (state platform) :falling))))

(defmethod collide ((platform falling-platform) (other falling-platform) hit)
  (when (and (eq :falling (state platform))
             (< 0 (vy (hit-normal hit))))
    (let ((vel (velocity platform)))
      (shake-camera)
      (nv+ (location platform) (v* vel (hit-time hit)))
      (vsetf vel (vx (velocity other)) (vy (velocity other)))
      (if (eq :blocked (state other))
          (setf (state platform) :blocked)
          (setf (state other) :falling)))))

(defmethod collide ((platform falling-platform) (solid solid) hit)
  (when (eq :falling (state platform))
    (let ((vel (velocity platform)))
      (shake-camera)
      (setf (state platform) :blocked)
      (nv+ (location platform) (v* vel (hit-time hit)))
      (vsetf vel 0 0))))

(defmethod collide ((platform falling-platform) (block block) hit)
  (when (eq :falling (state platform))
    (let ((vel (velocity platform)))
      (shake-camera)
      (setf (state platform) :blocked)
      (nv+ (location platform) (v* vel (hit-time hit)))
      (vsetf vel 0 0))))

(define-shader-subject elevator (sprite-entity moving-platform)
  ()
  (:default-initargs :bsize (nv/ (vec 32 16) 2)))

(defmethod tick ((elevator elevator) ev)
  (ecase (state elevator)
    (:normal)
    (:going-up
     (vsetf (velocity elevator) 0 +10))
    (:going-down
     (vsetf (velocity elevator) 0 -10))
    (:broken))
  (loop repeat 10 while (scan (surface elevator) elevator))
  (nv+ (location elevator) (velocity elevator)))

(defmethod collide :before ((player player) (elevator elevator) hit)
  (setf (interactable player) elevator))

(defmethod collide ((elevator elevator) (block block) hit)
  (let ((vel (velocity elevator)))
    (setf (state elevator) :normal)
    (nv+ (location elevator) (v* vel (hit-time hit)))
    (vsetf vel 0 0)))

(define-handler (elevator interaction) (ev with)
  (when (and (eq elevator with)
             (eql :normal (state elevator)))
    (cond ((null (scan (surface elevator) (v+ (location elevator)
                                              (v_y (bsize elevator))
                                              1)))
           (setf (state elevator) :going-up))
          ((null (scan (surface elevator) (v- (location elevator)
                                              (v_y (bsize elevator))
                                              1)))
           (setf (state elevator) :going-down)))))
