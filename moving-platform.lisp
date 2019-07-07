(in-package #:org.shirakumo.fraf.leaf)

(define-shader-subject moving-platform (lighted-sprite-entity game-entity solid)
  ()
  (:default-initargs
   :bsize (vec2 32 32)))

(defmethod collides-p ((platform moving-platform) thing hit) NIL)
(defmethod collides-p ((platform moving-platform) (block block) hit) T)

(define-shader-subject falling-platform (moving-platform)
  ((acceleration :initform (vec 0 -0.075) :accessor acceleration)))

(defmethod tick ((platform falling-platform) ev)
  (ecase (state platform)
    (:normal
     (loop repeat 10 while (scan (surface platform) platform)))
    (:falling
     (nv+ (velocity platform) (acceleration platform))
     (loop repeat 10 while (scan (surface platform) platform))
     (nv+ (location platform) (velocity platform)))))

(defmethod collide :before ((player player) (platform falling-platform) hit)
  (when (< 0 (vy (hit-normal hit)))
    (unless (scan (surface platform) (v+ (location platform)
                                         (v* (bsize platform)
                                             (vec2 (signum (vx (acceleration platform)))
                                                   (signum (vy (acceleration platform))))
                                             1.1)))
        (setf (state platform) :falling))))

(defmethod collide ((platform falling-platform) (block block) hit)
  (let ((vel (velocity platform)))
    (shake-camera)
    (setf (state platform) :normal)
    (nv+ (location platform) (v* vel (hit-time hit)))
    (vsetf vel 0 0)))

(define-shader-subject elevator (moving-platform)
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
