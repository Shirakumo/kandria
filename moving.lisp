(in-package #:org.shirakumo.fraf.leaf)

(define-global +default-medium+ (make-instance 'air))

(defclass moving (game-entity)
  ((collisions :initform (make-array 4 :initial-element NIL) :reader collisions)
   (medium :initform +default-medium+ :accessor medium)))

(defmethod handle ((ev tick) (moving moving))
  (when (next-method-p) (call-next-method))
  (let ((loc (location moving))
        (size (bsize moving))
        (collisions (collisions moving)))
    ;; Scan for medium
    (for:for ((entity over (region +world+)))
      (when (and (typep entity 'medium)
                 (contained-p entity moving))
        (setf (medium moving) entity)
        (return))
      (returning (setf (medium moving) +default-medium+)))
    (nv* (velocity moving) (drag (medium moving)))
    ;; Scan for hits
    (fill collisions NIL)
    (loop for i from 0
          do (unless (handle-collisions +world+ moving)
               (return))
             ;; KLUDGE: If we have too many collisions in a frame, we assume
             ;;         we're stuck somewhere, so just die.
             (cond ((< 11 i) (die moving))
                   ((< 10 i) (vsetf (frame-velocity moving) 0 0))))
    ;; Point test for adjacent walls
    (let ((l (scan-collision +world+ (vec (- (vx loc) (vx size) 1) (vy loc))))
          (r (scan-collision +world+ (vec (+ (vx loc) (vx size) 1) (vy loc))))
          (u (scan-collision +world+ (vec (vx loc) (+ (vy loc) (vy size) 1) (vx size) 1)))
          (b (scan-collision +world+ (vec (vx loc) (- (vy loc) (vy size) 1) (vx size) 1))))
      (when l (setf (aref collisions 3) (hit-object l)))
      (when r (setf (aref collisions 1) (hit-object r)))
      (when u (setf (aref collisions 0) (hit-object u)))
      (when b (setf (aref collisions 2) (hit-object b))))))

(defmethod collide ((moving moving) (block block) hit)
  (let* ((loc (location moving))
         (vel (frame-velocity moving))
         (pos (hit-location hit))
         (normal (hit-normal hit))
         (height (vy (bsize moving)))
         (t-s (/ (block-s block) 2)))
    (cond ((= +1 (vy normal)) (setf (svref (collisions moving) 2) block)
           (setf (vy (velocity moving)) (max 0 (vy (velocity moving)))))
          ((= -1 (vy normal)) (setf (svref (collisions moving) 0) block))
          ((= +1 (vx normal)) (setf (svref (collisions moving) 3) block))
          ((= -1 (vx normal)) (setf (svref (collisions moving) 1) block)))
    (nv+ loc (v* vel (hit-time hit)))
    (nv- vel (v* normal (v. vel normal)))
    ;; If we're just bumping the edge, move us up.
    (when (and (< -1 (- (vy loc) height (+ t-s (vy pos))) 1)
               (/= 0 (vx normal))
               (not (scan-collision +world+ (v+ pos (vec 0 t-s)))))
      (setf (svref (collisions moving) 2) block)
      (incf (vy loc)))
    ;; Zip out of ground in case of clipping
    (cond ((and (/= 0 (vy normal))
                 (< (vy pos) (vy loc))
                 (< (- (vy loc) height)
                    (+ (vy pos) t-s)))
           (setf (vy loc) (+ (vy pos) t-s height)))
          ((and (/= 0 (vy normal))
                (< (vy loc) (vy pos))
                (< (- (vy pos) t-s)
                   (+ (vy loc) height)))
           (setf (vy loc) (- (vy pos) t-s height))))))

(defmethod collides-p ((moving moving) (block platform) hit)
  (and (< (vy (frame-velocity moving)) 0)
       (<= (+ (vy (hit-location hit)) (floor +tile-size+ 2))
           (- (vy (location moving)) (vy (bsize moving))))))

(defmethod collide ((moving moving) (block platform) hit)
  (let* ((loc (location moving))
         (vel (frame-velocity moving))
         (pos (hit-location hit))
         (normal (hit-normal hit))
         (height (vy (bsize moving)))
         (t-s (/ (block-s block) 2)))
    (setf (svref (collisions moving) 2) block)
    (nv+ loc (v* vel (hit-time hit)))
    (nv- vel (v* normal (v. vel normal)))
    ;; Force clamp velocity to zero to avoid "speeding up while on ground"
    (setf (vy (velocity moving)) (max 0 (vy (velocity moving))))
    ;; Zip
    (when (< (- (vy loc) height)
             (+ (vy pos) t-s))
      (setf (vy loc) (+ (vy pos) t-s height)))))

(defmethod collides-p ((moving moving) (block spike) hit)
  ;; Switch to using circular mask for more lenient detection.
  (let ((sqrdist (vsqrdist2 (location moving) (hit-location hit))))
    (< sqrdist (expt +tile-size+ 2))))

(defmethod collide ((moving moving) (block spike) hit)
  (die moving))

(defmethod collides-p ((moving moving) (block slope) hit)
  (ignore-errors
   (let ((tt (slope (location moving) (frame-velocity moving) (bsize moving) block (hit-location hit))))
     (when tt
       (setf (hit-time hit) tt)
       (setf (hit-normal hit) (nvunit (vec2 (- (vy2 (slope-l block)) (vy2 (slope-r block)))
                                            (- (vx2 (slope-r block)) (vx2 (slope-l block))))))))))

(defmethod collide ((moving moving) (block slope) hit)
  (let* ((loc (location moving))
         (vel (frame-velocity moving))
         (normal (hit-normal hit)))
    (setf (svref (collisions moving) 2) block)
    (nv+ loc (v* vel (hit-time hit)))
    (nv- vel (v* normal (v. vel normal)))
    ;; Force clamp velocity to zero to avoid "speeding up while on ground"
    (setf (vy (velocity moving)) (max 0 (vy (velocity moving))))
    ;; Make sure we stop sliding down the slope.
    (when (< (abs (vx vel)) 0.1)
      (setf (vx vel) 0))
    ;; Zip
    (let* ((xrel (/ (- (vx loc) (vx (hit-location hit))) +tile-size+)))
      (when (< (vx normal) 0) (incf xrel))
      ;; KLUDGE: we add a bias of 0.1 here to ensure we stop colliding with the slope.
      (let ((yrel (lerp (vy (slope-l block)) (vy (slope-r block)) (clamp 0f0 xrel 1f0))))
        (setf (vy loc) (+ 0.05 yrel (vy (bsize moving)) (vy (hit-location hit))))))))

(defmethod collide ((moving moving) (other game-entity) hit)
  (let* ((loc (location moving))
         (vel (frame-velocity moving))
         (pos (location other))
         (normal (hit-normal hit))
         (bsize (bsize moving))
         (psize (bsize other)))
    (cond ((= +1 (vy normal)) (setf (svref (collisions moving) 2) other)
           (setf (vy (velocity moving)) (max (vy (velocity other)) (vy (velocity moving)))))
          ((= -1 (vy normal)) (setf (svref (collisions moving) 0) other))
          ((= +1 (vx normal)) (setf (svref (collisions moving) 3) other))
          ((= -1 (vx normal)) (setf (svref (collisions moving) 1) other)))
    ;; I know not doing this seems very wrong, but doing it
    ;; causes weirdly slow movement on falling platforms.
    ;;(nv+ loc (v* (v+ vel (frame-velocity other)) (hit-time hit)))
    (cond ((< (* (vy vel) (vy normal)) 0) (setf (vy vel) 0))
          ((< (* (vx vel) (vx normal)) 0) (setf (vx vel) 0)))
    (nv+ vel (velocity other))
    ;; Zip out of ground in case of clipping
    (cond ((and (/= 0 (vy normal))
                (< (vy pos) (vy loc))
                (< (- (vy loc) (vy bsize))
                   (+ (vy pos) (vy psize))))
           (setf (vy loc) (+ (vy pos) (vy psize) (vy bsize))))
          ((and (/= 0 (vy normal))
                (< (vy loc) (vy pos))
                (< (- (vy pos) (vy psize))
                   (+ (vy loc) (vy bsize))))
           (setf (vy loc) (- (vy pos) (vy psize) (vy bsize))))
          ((and (/= 0 (vx normal))
                (< (vx pos) (vx loc))
                (< (- (vx loc) (vx bsize))
                   (+ (vx pos) (vx psize))))
           (setf (vx loc) (+ (vx pos) (vx psize) (vx bsize))))
          ((and (/= 0 (vx normal))
                (< (vx loc) (vx pos))
                (< (- (vx pos) (vx psize))
                   (+ (vx loc) (vx bsize))))
           (setf (vx loc) (- (vx pos) (vx psize) (vx bsize)))))))

(defmethod collides-p ((moving moving) (stopper stopper) hit) NIL)
