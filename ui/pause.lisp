(in-package #:org.shirakumo.fraf.kandria)

(defclass pause-list (alloy:vertical-linear-layout alloy:focus-list alloy:renderable)
  ((alloy:min-size :initform (alloy:size 100 50))))

(presentations:define-realization (ui pause-list)
  ((:bg simple:rectangle)
   (alloy:margins)
   :pattern (colored:color 0 0 0 0.75)))

(defclass pause-menu (pausing-panel)
  ())

(defmethod initialize-instance :after ((menu pause-menu) &key)
  (let ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout))
        (list (make-instance 'pause-list)))
    (alloy:enter list layout :constraints `((:top 0) (:bottom 0) (:width 400) (:center :w)))
    (alloy:enter (make-instance 'button :value "Resume" :on-activate (lambda () (hide menu))) list)
    (alloy:enter (make-instance 'button :value "Quit" :on-activate (lambda () (quit *context*))) list)
    (alloy:finish-structure menu layout list)))
