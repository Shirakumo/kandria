(in-package #:org.shirakumo.fraf.kandria)

(defun should-show-pause-screen (world)
  (and (unit 'ui-pass world)
       (not (find-panel 'load-panel world))
       (not (find-panel 'main-menu world))
       (unit 'environment world)))

(defmethod handle :after ((ev lose-focus) (world world))
  (when (and (setting :gameplay :pause-on-focus-loss)
             (should-show-pause-screen world))
    (show-panel 'pause-screen)
    (clear-retained)))

(defmethod handle :after ((ev gain-focus) (world world))
  (hide-panel 'pause-screen world))

(steam:define-callback steam*::game-overlay-activated (result active)
  (v:info :kandria "Steam game overlay ~:[deactivated~;activated~]" (= 1 active))
  (when (should-show-pause-screen (scene +main+))
    (if (= 1 active)
        (show-panel 'pause-screen)
        (hide-panel 'pause-screen))))

(defclass pause-screen (pausing-panel)
  ())

(defmethod initialize-instance :after ((panel pause-screen) &key)
  (let* ((layout (make-instance 'load-screen-layout :style `((:bg :pattern ,(colored:color 0 0 0 0.5)))))
         (header (make-instance 'header :level 0 :value #@game-paused-title))
         (focus (make-instance 'alloy:focus-list)))
    (alloy:enter header layout :constraints `(:center (:size 1000 1000)))
    (alloy:on alloy:exit (focus)
      (setf (alloy:focus focus) :strong))
    (alloy:finish-structure panel layout focus)))

#++
(defmethod handle ((ev input-event) (panel pause-screen))
  (unless (or (typep ev 'mouse-move)
              (typep ev 'gamepad-move))
    (hide panel)))
