(in-package #:org.shirakumo.fraf.kandria)

(defclass freeform (tool)
  ((start-pos :initform NIL :accessor start-pos)
   (original-loc :initform NIL :accessor original-loc)
   (original-size :initform NIL :accessor original-size)
   (original-data :initform NIL :accessor original-data)))

(defmethod label ((tool freeform)) "")
(defmethod title ((tool freeform)) "Freeform (F)")

(defmethod commit-resize-data ((entity sized-entity))
  (list (vcopy (bsize entity))
        (vcopy (location entity))))

(defmethod restore-resize-data ((entity sized-entity) data)
  (v<- (bsize entity) (first data))
  (v<- (location entity) (second data)))

(defun near-border-p (pos entity)
  (let* ((p (nv- (mouse-world-pos pos)
                 (location entity)))
         (b (bsize entity))
         ;; Box SDF
         (d (nv- (vabs p) b))
         (d (+ (min 0 (max (vx d) (vy d)))
               (vlength (vmax d 0)))))
    ;; If close to borders, resize.
    (< (abs d) (/ 3.0 (zoom (camera +world+))))))

(defmethod handle ((event mouse-press) (tool freeform))
  (let ((entity (entity tool)))
    (cond ((retained :control)
           (let ((new (closest-acceptable-location (entity tool) (vcopy (mouse-world-pos (pos event)))))
                 (old (vcopy (location entity))))
             (with-commit (tool "Move ~a" (descriptor entity))
               ((setf (location entity) new))
               ((setf (location entity) old)))))
          (T
           (etypecase entity
             (resizable
              (setf (state tool) (if (near-border-p (pos event) entity)
                                     :resizing
                                     :moving)))
             (located-entity
              (setf (state tool) :moving)))))
    (setf (original-data tool) (commit-resize-data entity))
    (setf (start-pos tool) (mouse-world-pos (pos event)))
    (setf (original-loc tool) (vcopy (location entity)))
    (setf (original-size tool) (vcopy (bsize entity)))))

(defmethod handle ((event mouse-release) (tool freeform))
  (let ((entity (entity tool)))
    (case (state tool)
      (:moving
       (let ((new (vcopy (location entity)))
             (old (vcopy (original-loc tool))))
         (with-commit (tool "Move ~a" (descriptor entity))
             ((setf (location entity) new)
              (bvh:bvh-update (bvh (region +world+)) entity))
             ((setf (location entity) old)
              (bvh:bvh-update (bvh (region +world+)) entity)))))
      (:resizing
       (let ((new-loc (vcopy (location entity)))
             (old-loc (vcopy (original-loc tool)))
             (new-size (vcopy (bsize entity)))
             (old-size (vcopy (original-size tool)))
             (xanchor (if (< (vx (original-loc tool)) (vx (start-pos tool))) :left :right))
             (yanchor (if (< (vy (original-loc tool)) (vy (start-pos tool))) :bottom :top))
             (original-data (original-data tool)))
         (typecase entity
           (layer
            (with-commit (tool "Resize ~a" (descriptor entity))
              ((resize-layer entity (* 2 (vx new-size)) (* 2 (vy new-size)) xanchor yanchor)
               (when (/= (vx (bsize entity)) (vx old-size))
                 (setf (vx (location entity)) (vx new-loc)))
               (when (/= (vy (bsize entity)) (vy old-size))
                 (setf (vy (location entity)) (vy new-loc)))
               (bvh:bvh-update (bvh (region +world+)) entity))
              ((restore-resize-data entity original-data)
               (v<- (location entity) old-loc)
               (bvh:bvh-update (bvh (region +world+)) entity))))
           (T
            (with-commit (tool "Resize ~a" (descriptor entity))
              ((resize entity (* 2 (vx new-size)) (* 2 (vy new-size)))
               (setf (location entity) new-loc)
               (bvh:bvh-update (bvh (region +world+)) entity))
              ((resize entity (* 2 (vx old-size)) (* 2 (vy old-size)))
               (setf (location entity) old-loc)
               (bvh:bvh-update (bvh (region +world+)) entity)))))))))
  (setf (state tool) NIL))

(defun nvalign-corner (loc bsize grid)
  (nv+ (nvalign (v- loc bsize) grid) bsize))

(defmethod handle ((event mouse-move) (tool freeform))
  (case (state tool)
    (:moving
     (let* ((entity (entity tool))
            (new (closest-acceptable-location
                  entity (nvalign-corner
                          (nv+ (nv- (mouse-world-pos (pos event)) (start-pos tool))
                               (original-loc tool))
                          (bsize entity)
                          (typecase entity
                            (chunk +tile-size+)
                            (T (/ +tile-size+ 2)))))))
       (when (v/= new (location entity))
         (setf (location entity) new)
         (update-marker (editor tool)))))
    (:resizing
     (let* ((entity (entity tool))
            (current (nvalign (mouse-world-pos (pos event)) +tile-size+))
            (starting (nvalign (start-pos tool) +tile-size+))
            (new-pos (v+ (original-loc tool) (nv/ (v- current starting) 2)))
            (new-size (nvalign (vmax (nv/ (vec +tile-size+ +tile-size+) 2)
                                     (nvabs (v- current new-pos)))
                               (/ +tile-size+ 2)))
            (old-size (vcopy (bsize entity))))
       (when (v/= new-size old-size)
         ;; FIXME: this is destructive for chunks. Need some way to either copy state or not throw it away too eagerly.
         (typecase entity
           (layer (resize-layer entity (* 2 (vx new-size)) (* 2 (vy new-size))
                                (if (< (vx (original-loc tool)) (vx starting)) :left :right)
                                (if (< (vy (original-loc tool)) (vy starting)) :bottom :top)))
           (T (resize entity (* 2 (vx new-size)) (* 2 (vy new-size)))))
         (when (/= (vx (bsize entity)) (vx old-size))
           (setf (vx (location entity)) (vx new-pos)))
         (when (/= (vy (bsize entity)) (vy old-size))
           (setf (vy (location entity)) (vy new-pos)))
         (when (v/= (bsize entity) old-size)
           (update-marker (editor tool))))))
    (T
     (cond ((not (near-border-p (pos event) (entity tool)))
            (setf (cursor *context*) NIL))
           (T ;; FIXME: show proper resize direction
            (let ((pos (mouse-world-pos (pos event)))
                  (loc (location (entity tool))))
              (setf (cursor *context*) (cond ((and (< (vy pos) (vy loc)) (< (vx pos) (vx loc))) :nesw-resize)
                                             ((and (< (vy loc) (vy pos)) (< (vx pos) (vx loc))) :nwse-resize)
                                             ((and (< (vy pos) (vy loc)) (< (vx loc) (vx pos))) :nwse-resize)
                                             ((and (< (vy loc) (vy pos)) (< (vx loc) (vx pos))) :nesw-resize)
                                             (T :resize)))))))))
