(in-package #:org.shirakumo.fraf.leaf)

(defclass paint (tool)
  ())

(defmethod label ((tool paint)) "Paint")

(defmethod handle ((event mouse-press) (tool paint))
  (paint-tile tool event)
  (loop for layer across (layers (entity tool))
        for i from 0
        do (if (= i (layer (sidebar (editor tool))))
               (setf (visibility layer) 1.0)
               (setf (visibility layer) 0.5))))

(defmethod handle ((event mouse-release) (tool paint))
  (setf (state tool) NIL)
  (loop for layer across (layers (entity tool))
        do (setf (visibility layer) 1.0)))

(defmethod handle ((event mouse-move) (tool paint))
  (case (state tool)
    (:placing
     (paint-tile tool event))))

(defmethod handle ((event key-press) (tool paint))
  (case (key event)
    (:1 (setf (layer (sidebar (editor tool))) 0))
    (:2 (setf (layer (sidebar (editor tool))) 1))
    (:3 (setf (layer (sidebar (editor tool))) 2))
    (:4 (setf (layer (sidebar (editor tool))) 3))
    (:5 (setf (layer (sidebar (editor tool))) 4))))

(defmethod handle ((event mouse-scroll) (tool paint))
  (let ((tile (tile-to-place (sidebar (editor tool)))))
    (setf (tile-to-place (sidebar (editor tool)))
          (if (retained :shift)
              (vec (vx tile) (+ (vy tile) (signum (delta event))))
              (vec (+ (vx tile) (signum (delta event))) (vy tile))))))

(defun paint-tile (tool event)
  (let* ((entity (entity tool))
         (loc (mouse-tile-pos (pos event)))
         (loc (if (show-solids entity)
                  loc
                  (vec (vx loc) (vy loc) (layer (sidebar (editor tool))))))
         (tile (cond ((retained :left)
                      (tile-to-place (sidebar (editor tool))))
                     (T
                      (vec 0 0)))))
    (cond ((retained :control)
           (auto-tile entity loc))
          ((retained :shift)
           (flood-fill entity loc tile))
          ((and (typep event 'mouse-press) (eql :middle (button event)))
           (setf (tile-to-place (sidebar (editor tool)))
                 (print (tile loc entity))))
          ((and (tile loc entity) (v/= tile (tile loc entity)))
           (setf (state tool) :placing)
           (commit (capture-action (tile loc entity) tile) tool)))))
