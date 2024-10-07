(in-package #:org.shirakumo.fraf.kandria)

(defclass lighting (alloy:dialog)
  ()
  (:default-initargs
   :title "Change Lighting"
   :extent (alloy:size 400 300)
   :reject NIL))

(defmethod alloy:accept ((lighting lighting)))

(defmethod initialize-instance :after ((lighting lighting) &key)
  (let* ((pass (node 'lighting-pass T))
         (layout (make-instance 'alloy:vertical-linear-layout :layout-parent lighting))
         (focus (make-instance 'alloy:focus-list :focus-parent lighting))
         (gi NIL)
         (combo (alloy:represent gi 'alloy:combo-set :value-set (mapcar #'name (list-gis)) :layout-parent layout :focus-parent focus))
         (hour (alloy:represent (hour +world+) 'alloy:ranged-slider :range '(0 . 24) :layout-parent layout :focus-parent focus)))
    (alloy:on alloy:value (gi combo)
      (setf (lighting pass) (gi gi))
      (force-lighting pass))
    (alloy:on alloy:value (value hour)
      (synchronize +world+ value)
      (update-lighting pass))))

