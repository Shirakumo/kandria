(in-package #:org.shirakumo.fraf.kandria)

(defclass browser (tool)
  ())

(defmethod label ((tool browser)) "")
(defmethod title ((tool browser)) "Browse (B)")

(defmethod handle ((event mouse-press) (tool browser))
  (cond ((retained :shift)
         (setf (state tool) :zoom))
        (T
         (setf (state tool) :drag))))

(defmethod handle ((event mouse-release) (tool browser))
  (setf (state tool) NIL))

(defmethod handle ((event mouse-move) (tool browser))
  (let ((camera (camera +world+)))
    (case (state tool)
      (:drag
       (let ((loc (location camera)))
         (incf (vx loc) (/ (- (vx (old-pos event)) (vx (pos event))) (view-scale camera) (zoom camera)))
         (incf (vy loc) (/ (- (vy (old-pos event)) (vy (pos event))) (view-scale camera) (zoom camera)))))
      (:zoom
       (let ((dp (+ (- (vx (pos event)) (vx (old-pos event)))
                    (- (vy (pos event)) (vy (old-pos event))))))
         (setf (zoom camera) (clamp 0.1 (+ (zoom camera) (/ dp 100)) 3.0)))))))
