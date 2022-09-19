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

(defclass prerelease-notice (panel)
  ())

(defmethod initialize-instance :after ((panel prerelease-notice) &key)
  (let ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout))
        (label (make-instance 'label :value (format NIL "Pre-release version ~a, do not record." (version :app))
                                     :style `((:label :halign :middle :valign :middle :pattern ,(colored:color 1 1 1 0.5))))))
    (alloy:enter label layout :constraints `((:left 0) (:bottom 10) (:fill :w) (:height 20)))
    (alloy:finish-structure panel layout NIL)))
