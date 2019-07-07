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
