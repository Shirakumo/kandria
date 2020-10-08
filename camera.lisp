(in-package #:org.shirakumo.fraf.leaf)

(defclass camera (trial:2d-camera unpausable)
  ((flare:name :initform :camera)
   (scale :initform 1.0 :accessor view-scale)
   (target-size :initarg :target-size :accessor target-size)
   (target :initarg :target :initform NIL :accessor target)
   (intended-location :initform (vec2 0 0) :accessor intended-location)
   (zoom :initarg :zoom :initform 1.0 :accessor zoom)
   (intended-zoom :initform 1.0 :accessor intended-zoom)
   (region :initform NIL :accessor region)
   (shake-counter :initform 0 :accessor shake-counter)
   (shake-intensity :initform 3 :accessor shake-intensity))
  (:default-initargs
   :location (vec 0 0)
   :target-size (v* +tiles-in-view+ +tile-size+ .5)))

(defmethod enter :after ((camera camera) (scene scene))
  (setf (target camera) (unit 'player scene))
  (when (target camera)
    (setf (location camera) (vcopy (location (target camera))))))

(defun clamp-camera-target (camera target)
  (let ((region (region camera)))
    (when region
      (let ((lx (vx2 (location region)))
            (ly (vy2 (location region)))
            (lw (vx2 (bsize region)))
            (lh (vy2 (bsize region)))
            (cw (/ (vx2 (target-size camera)) (zoom camera)))
            (ch (/ (vy2 (target-size camera)) (zoom camera))))
        (setf (vx target) (clamp (+ lx cw (- lw))
                                 (vx target)
                                 (+ lx (- cw) lw)))
        (setf (vy target) (clamp (+ ly ch (- lh))
                                 (vy target)
                                 (+ ly (- ch) lh)))))))

(defmethod handle :before ((ev tick) (camera camera))
  (unless (and (unit :editor T) (active-p (unit :editor T)))
    (let ((loc (location camera))
          (int (intended-location camera)))
      ;; Camera zoom
      (let* ((z (zoom camera))
             (int (intended-zoom camera))
             (dir (/ (- (log int) (log z)) 10)))
        (if (< (abs (- z int)) (abs dir))
            (setf (zoom camera) int)
            (incf (zoom camera) dir)))
      ;; Camera movement
      (when (target camera)
        (let ((tar (location (target camera))))
          (vsetf int (vx tar) (vy tar))))
      (clamp-camera-target camera int)
      (let* ((dir (v- int loc))
             (len (max 1 (vlength dir)))
             (ease (clamp 0 (+ 0.2 (/ (expt len 1.5) 100)) 20)))
        (nv* dir (/ ease len))
        (nv+ loc dir))
      ;; Camera shake
      (when (< 0 (shake-counter camera))
        (decf (shake-counter camera))
        (dolist (device (gamepad:list-devices))
          (gamepad:rumble device (if (< 0 (shake-counter camera))
                                     (shake-intensity camera)
                                     0)))
        (nv+ loc (vrandr (* (shake-intensity camera) 0.1) (shake-intensity camera)))
        (clamp-camera-target camera loc)))))

(defmethod (setf zoom) :after (zoom (camera camera))
  (setf (view-scale camera) (float (/ (width *context*) (* 2 (vx (target-size camera)))))))

(defmethod snap-to-target ((camera camera) target)
  (setf (target camera) target)
  (setf (location camera) (vcopy (location target)))
  (clamp-camera-target camera (location camera)))

(defmethod (setf target) :after ((target game-entity) (camera camera))
  (setf (region camera) (find-containing target (region +world+))))

(defmethod handle :before ((ev resize) (camera camera))
  ;; Ensure we scale to fit width as much as possible without showing space
  ;; outside the chunk.
  (let* ((optimal-scale (float (/ (width ev) (* 2 (vx (target-size camera))))))
         (max-fit-scale (/ (height ev) (vy (bsize (region camera))) 2))
         (scale (max optimal-scale max-fit-scale)))
    (setf (view-scale camera) scale)
    (setf (vy (target-size camera)) (/ (height ev) scale 2))))

(defmethod (setf region) :after (region (camera camera))
  ;; Optimal bounds might have changed, update.
  (handle (make-instance 'resize :width (width *context*) :height (height *context*)) camera))

(defmethod handle ((ev switch-chunk) (camera camera))
  (setf (region camera) (chunk ev)))

(defmethod handle ((ev window-shown) (camera camera))
  (if (target camera)
      (snap-to-target camera (target camera))
      (vsetf (location camera) 0 0)))

(defmethod project-view ((camera camera))
  (let* ((z (max 0.0001 (* (view-scale camera) (zoom camera))))
         (v (nv- (v/ (target-size camera) (zoom camera)) (location camera))))
    (reset-matrix *view-matrix*)
    (scale-by z z z *view-matrix*)
    (translate-by (vx v) (vy v) 100 *view-matrix*)))

(defun shake-camera (&key (duration 20) (intensity 3))
  (let ((camera (unit :camera +world+)))
    (setf (shake-counter camera) duration)
    (setf (shake-intensity camera) intensity)))

(defun in-view-p (loc bsize)
  (let* ((camera (unit :camera T)))
    (let ((- (vec 0 0))
          (+ (vec (width *context*) (height *context*)))
          (off (v/ (target-size camera) (zoom camera))))
      (nv- (nv+ (nv/ - (view-scale camera) (zoom camera)) (location camera)) off)
      (nv- (nv+ (nv/ + (view-scale camera) (zoom camera)) (location camera)) off)
      (and (< (vx -) (+ (vx loc) (vx bsize)))
           (< (- (vx loc) (vx bsize)) (vx +))
           (< (- (vy loc) (vy bsize)) (vy +))
           (< (vy -) (+ (vy loc) (vy bsize)))))))
