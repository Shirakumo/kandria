(in-package #:org.shirakumo.fraf.kandria)

(defclass early-end-screen (swap-screen)
  ((time-between-pages :initform 10.0)))

(defmethod initialize-instance :after ((panel early-end-screen) &key message)
  (let* ((layout (alloy:layout-element panel)))
    (let ((page (make-instance 'org.shirakumo.alloy.layouts.constraint:layout)))
      (alloy:enter (make-instance 'label :value message
                                         :style `((:label :halign :middle :size ,(alloy:un 14))))
                   page :constraints `((:fill)))
      (alloy:enter page layout))))

(defmethod hide :after ((panel early-end-screen))
  (show-credits :transition NIL))
