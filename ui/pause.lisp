(in-package #:org.shirakumo.fraf.kandria)

(defclass pause-list (alloy:vertical-linear-layout alloy:focus-list alloy:renderable)
  ())

(presentations:define-realization (ui pause-list)
  ((:background simple:rectangle)
   (alloy:margins)
   :pattern (colored:color 0 0 0 0.5)))

(defclass pause-menu (pausing-panel)
  ())

(defmethod initialize-instance :after ((menu pause-menu) &key)
  (let ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout))
        (list (make-instance 'pause-list)))
    (alloy:enter list layout :constraints `((:top 0) (:bottom 0) (:width 300) (:center :w)))
    (alloy:finish-structure menu layout list)))
