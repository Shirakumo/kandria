(in-package #:org.shirakumo.fraf.leaf)

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

(defmethod handle ((event mouse-move) (tool freeform))
  (case (state tool)
    (:moving
     (let ((new (nvalign (nv+ (nv- (mouse-world-pos (pos event)) (start-pos tool))
                              (original-loc tool))
                         +tile-size+))
           (entity (entity tool)))
       (when (v/= new (location entity))
         (commit (capture-action (location entity) new) tool))))
    (:resizing
     (let ((new (vmax (nvalign (nvabs (nv- (mouse-world-pos (pos event)) (original-loc tool))) (/ +tile-size+ 2)) +tile-size+))
           (old (vcopy (bsize (entity tool))))
           (orig (original-loc tool))
           (entity (entity tool)))
       (when (v/= new old)
         (commit (make-instance 'closure-action
                                :redo (lambda (_)
                                        (resize entity (* 2 (vx new)) (* 2 (vy new)))
                                        ;; FIXME: Not quite right yet.
                                        (setf (location entity) (v+ orig (v- new old))))
                                :undo (lambda (_) (resize entity (* 2 (vx old)) (* 2 (vy old)))))
                 tool))))))
