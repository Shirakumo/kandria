(in-package #:org.shirakumo.fraf.leaf)

(defclass paint (tool)
  ((previous :initform () :accessor previous)))

(defmethod label ((tool paint)) "Paint")

(defmethod handle ((event mouse-press) (tool paint))
  (setf (state tool) :placing)
  (paint-tile tool event))

(defmethod handle ((event mouse-release) (tool paint))
  (setf (state tool) NIL))

(defmethod handle ((event mouse-move) (tool paint))
  (case (state tool)
    (:placing
     (paint-tile tool event))))

(defun paint-tile (tool event)
  (let* ((loc (nvalign (nv- (mouse-world-pos (pos event)) (/ +tile-size+ 2)) +tile-size+))
         (loc (vec (vx loc) (vy loc) (layer (sidebar (editor tool)))))
         (entity (entity tool))
         (tile (cond ((retained 'mouse :left)
                      (tile-to-place (sidebar (editor tool))))
                     (T
                      (vec 0 0)))))
    (unless (equalp (list loc entity tile) (previous tool))
      (setf (previous tool) (list loc entity tile))
      (commit (capture-action (tile loc entity) tile) tool))))
