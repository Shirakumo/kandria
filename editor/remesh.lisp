(in-package #:org.shirakumo.fraf.kandria)

(defclass remesh (tool)
  ())

(defmethod label ((tool remesh)) "")
(defmethod title ((tool remesh)) "Remesh")

(defmethod handle ((event mouse-press) (tool remesh))
  (let ((loc (mouse-world-pos (pos event))))
    (case (button event)
      (:left
       (add-vertex (entity tool) :location loc))
      (:right
       (clear (entity tool))))))
