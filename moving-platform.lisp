(in-package #:org.shirakumo.fraf.leaf)

(define-shader-subject moving-platform (chunk game-entity)
  ())

(defmethod scan ((platform moving-platform) (target game-entity))
  (let ((hit (aabb (location target) (v- (velocity target) (velocity platform))
                   (location platform) (v+ (bsize platform) (bsize target)))))
    (when hit
      (setf (hit-object hit) platform)
      (collide target platform hit))))

(defmethod tick ((platform moving-platform) ev)
  (let ((vel (velocity platform)))
    (loop while (and (or (/= 0 (vx vel)) (/= 0 (vy vel)))
                     (scan +level+ platform)))
    (nv+ (location platform) vel)))

(define-shader-subject falling-platform (moving-platform)
  ((status :initform :hanging :accessor status)
   (direction :initarg :direction :accessor direction)
   (dt :initform 0.0 :accessor dt))
  (:default-initargs :direction (vec 0 -1)))

(defmethod tick :before ((platform falling-platform) ev)
  (when (eq :falling (status platform))
    (incf (dt platform) (dt ev))
    (let ((ease (flare:ease (/ (dt platform) 1) 'flare:quint-in 0 6)))
      (vsetf (velocity platform)
             (* ease (vx (direction platform)))
             (* ease (vy (direction platform)))))))

(defmethod collide ((platform falling-platform) object hit)
  (let ((loc (location platform))
        (vel (velocity platform))
        (size (bsize platform))
        (normal (hit-normal hit)))
    (nv+ loc (v* vel (hit-time hit)))
    (cond ((/= 0 (vy normal))
           (loop for x from (- (vx loc) (vx size)) to (+ (vx loc) (vx size)) by 8
                 do (enter (make-instance 'dust-cloud :location (vec x (- (vy loc) (* (vy normal) (- (vy size) 8))))
                                                      :direction normal)
                           +level+)))
          ((/= 0 (vx normal))
           (loop for y from (- (vy loc) (vy size)) to (+ (vy loc) (vy size)) by 8
                 do (enter (make-instance 'dust-cloud :location (vec (- (vx loc) (* (vx normal) (- (vx size) 8))) y)
                                                      :direction normal)
                           +level+))))
    (setf (shake-counter (unit :camera T)) 20)
    (stop platform)))

(defmethod stop ((platform moving-platform))
  (vsetf (velocity platform) 0 0)
  (setf (status platform) :stopped))
