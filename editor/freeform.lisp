(in-package #:org.shirakumo.fraf.kandria)

(defclass freeform (tool)
  ((start-pos :initform NIL :accessor start-pos)
   (original-loc :initform NIL :accessor original-loc)))

(defmethod label ((tool freeform)) "Freeform")

(defmethod handle ((event mouse-press) (tool freeform))
  (etypecase (entity tool)
    (resizable
     (let* ((p (nv- (mouse-world-pos (pos event))
                    (location (entity tool))))
            (b (bsize (entity tool)))
            ;; Box SDF
            (d (nv- (vabs p) b))
            (d (+ (min 0 (max (vx d) (vy d)))
                  (vlength (vmax d 0)))))
       ;; If close to borders, resize.
       (setf (state tool) (if (< (abs d) 5)
                              :resizing
                              :moving))))
    (located-entity
     (setf (state tool) :moving)))
  (setf (start-pos tool) (mouse-world-pos (pos event)))
  (setf (original-loc tool) (vcopy (location (entity tool)))))

(defmethod handle ((event mouse-release) (tool freeform))
  (setf (state tool) NIL))

(defun nvalign-corner (loc bsize grid)
  (nv+ (nvalign (v- loc bsize) grid) bsize))

(defmethod handle ((event mouse-move) (tool freeform))
  (case (state tool)
    (:moving
     (let ((new (nvalign-corner
                 (nv+ (nv- (mouse-world-pos (pos event)) (start-pos tool))
                      (original-loc tool))
                 (bsize (entity tool))
                 (/ +tile-size+ 2)))
           (entity (entity tool)))
       (when (v/= new (location entity))
         (commit (capture-action (location entity) new) tool))))
    (:resizing
     (let* ((entity (entity tool))
            (current (nvalign (mouse-world-pos (pos event)) +tile-size+))
            (starting (nvalign (start-pos tool) +tile-size+))
            (new-pos (v+ (original-loc tool) (nv/ (v- current starting) 2)))
            (new-size (vmax (nv/ (vec +tile-size+ +tile-size+) 2)
                            (nvabs (v- current new-pos))))
            (old-pos (vcopy (location entity)))
            (old-size (vcopy (bsize entity))))
       (when (v/= new-size (bsize entity))
         (commit (make-instance 'closure-action
                                :redo (lambda (_)
                                        (resize entity (* 2 (vx new-size)) (* 2 (vy new-size)))
                                        (setf (location entity) new-pos))
                                :undo (lambda (_)
                                        (resize entity (* 2 (vx old-size)) (* 2 (vy old-size)))
                                        (setf (location entity) old-pos)))
                 tool))))))
