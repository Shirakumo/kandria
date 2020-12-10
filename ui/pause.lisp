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
    (macrolet ((with-button (name &body action)
                 `(alloy:enter (make-instance 'button :value ,name :on-activate (lambda () ,@action)) list)))
      (with-button "Resume"
        (hide menu))
      (with-button "Quicksave"
        (save-state +world+ :quick)
        (hide menu))
      (with-button "Quickload"
        (load-state :quick +world+)
        (hide menu))
      (with-button "Save & Quit"
        ;; TODO: Confirm
        (save-state +world+ T)
        (quit *context*)))
    (alloy:finish-structure menu layout list)))

(defmethod show :after ((menu pause-menu) &key)
  (let ((list (alloy:focus-element menu)))
    (setf (alloy:index list) 0)))
