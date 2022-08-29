(in-package #:org.shirakumo.fraf.kandria)

(defclass intro-panel (swap-screen)
  ((time-between-pages :initform 10.0)))

(defmethod initialize-instance :after ((panel intro-panel) &key)
  (let* ((layout (alloy:layout-element panel))
         (page (make-instance 'org.shirakumo.alloy.layouts.constraint:layout)))
    (alloy:enter (make-instance 'label :value (@ game-intro-notice)
                                       :style `((:label :halign :middle :size ,(alloy:un 14))))
                 page :constraints `((:fill)))
    (alloy:enter page layout)))

