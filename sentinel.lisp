(in-package #:org.shirakumo.fraf.kandria)

(defclass sentinel (listener located-entity)
  ((name :initform :sentinel)))

(defmethod bsize ((sentinel sentinel)) #.(vec 1 1))

(defmethod enter ((sentinel sentinel) (world world))
  (setf (active-p (action-set 'in-map)) T))

(defmethod leave ((sentinel sentinel) (world world))
  (setf (active-p (action-set 'in-game)) T))

(defmethod handle ((ev tick) (sentinel sentinel))
  (let ((loc (location sentinel))
        (dt (dt ev))
        (spd (if (retained :shift)
                 500.0
                 200.0)))
    (when (retained 'pan-left)
      (decf (vx loc) (* spd dt)))
    (when (retained 'pan-right)
      (incf (vx loc) (* spd dt)))
    (when (retained 'pan-down)
      (decf (vy loc) (* spd dt)))
    (when (retained 'pan-up)
      (incf (vy loc) (* spd dt)))
    (when (retained 'zoom-in)
      (setf (intended-zoom (unit :camera T))
            (clamp 0.1 (expt 2 (+ (log (intended-zoom (unit :camera T)) 2) (* 2 dt))) 10.0)))
    (when (retained 'zoom-out)
      (setf (intended-zoom (unit :camera T))
            (clamp 0.1 (expt 2 (- (log (intended-zoom (unit :camera T)) 2) (* 2 dt))) 10.0)))))
