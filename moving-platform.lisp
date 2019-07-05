(in-package #:org.shirakumo.fraf.leaf)

(define-shader-subject moving-platform (lighted-sprite-entity game-entity solid)
  ((velocity :initform (vec 0.5 0))))

(defmethod tick ((platform moving-platform) ev)
  (ecase (state platform)
    (:normal
     (loop repeat 10 while (scan (surface platform) platform))
     (nv+ (location platform) (velocity platform)))
    (:stopped)))

(defmethod collides-p ((platform moving-platform) thing hit) NIL)
(defmethod collides-p ((platform moving-platform) (block block) hit) T)

(defmethod collide ((platform moving-platform) (block block) hit)
  (let ((vel (velocity platform)))
    (nv+ (location platform) (v* vel (hit-time hit)))
    (vsetf vel (vy vel) (- (vx vel)))))
