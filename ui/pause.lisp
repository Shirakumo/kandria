(in-package #:org.shirakumo.fraf.kandria)

(defclass pause-list (alloy:vertical-linear-layout alloy:focus-list pane)
  ((alloy:min-size :initform (alloy:size 100 50))
   (alloy:cell-margins :initform (alloy:margins))))

(defclass pause-menu (pausing-panel)
  ())

(defmethod initialize-instance :after ((menu pause-menu) &key)
  (let ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout))
        (list (make-instance 'pause-list)))
    (alloy:enter list layout :constraints `((:top 0) (:bottom 0) (:width 400) (:center :w)))
    (macrolet ((with-button (name &body action)
                 `(alloy:enter (make-instance 'button :value (@ ,name) :on-activate (lambda () ,@action)) list)))
      (with-button resume-game
        (hide menu))
      (with-button create-quick-save
        (save-state +world+ :quick)
        (hide menu))
      (with-button load-last-quick-save
        (load-state :quick +world+)
        (hide menu))
      (with-button open-options-menu
        (show (make-instance 'options-menu)))
      (with-button save-and-quit-game
        ;; TODO: Confirm
        (save-state +world+ T)
        (quit *context*)))
    (alloy:finish-structure menu layout list)))

(defmethod show :after ((menu pause-menu) &key)
  (let ((list (alloy:focus-element menu)))
    (setf (alloy:index list) 0)))
