(in-package #:org.shirakumo.fraf.leaf)

(defclass paint (tool)
  ())

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

(defmethod handle ((event key-press) (tool paint))
  (case (key event)
    (:1 (setf (layer (sidebar (editor tool))) -2))
    (:2 (setf (layer (sidebar (editor tool))) -1))
    (:3 (setf (layer (sidebar (editor tool)))  0))
    (:4 (setf (layer (sidebar (editor tool))) +1))
    (:5 (setf (layer (sidebar (editor tool))) +2))
    (:0 (setf (layer (sidebar (editor tool))) +3))))

(defmethod handle ((event mouse-scroll) (tool paint))
  (let ((tile (tile-to-place (sidebar (editor tool)))))
    (setf (tile-to-place (sidebar (editor tool)))
          (vec (+ (vx tile) (signum (delta event))) (vy tile)))))

(defun paint-tile (tool event)
  (let* ((loc (nvalign (nv- (mouse-world-pos (pos event)) (/ +tile-size+ 2)) +tile-size+))
         (loc (vec (vx loc) (vy loc) (layer (sidebar (editor tool)))))
         (entity (entity tool))
         (tile (cond ((retained 'mouse :left)
                      (tile-to-place (sidebar (editor tool))))
                     (T
                      (vec 0 0)))))
    (cond ((retained 'modifiers :control)
           (auto-tile entity loc))
          ((retained 'modifiers :shift)
           (flood-fill entity loc tile))
          ((and (tile loc entity) (v/= tile (tile loc entity)))
           (commit (capture-action (tile loc entity) tile) tool)))))
