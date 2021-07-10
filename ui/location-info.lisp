(in-package #:org.shirakumo.fraf.kandria)

(defclass location-info (alloy:popup alloy:label*)
  ((timeout :initform 5.0 :accessor timeout)))

(presentations:define-realization (ui location-info)
  ((:bord simple:rectangle)
   (alloy:extent 0 -5 (alloy:pw 1) 1)
   :pattern colors:white)
  ((:label simple:text)
   (alloy:margins) alloy:text
   :font (setting :display :font)
   :valign :top
   :halign :right
   :size (alloy:un 16)))

(presentations:define-update (ui location-info)
  (:label
   :pattern (colored:color 1 1 1 (min 1 (* 1.5 (timeout alloy:renderable)))))
  (:bord
   :pattern (colored:color 1 1 1 (min 1 (timeout alloy:renderable)))))

(defmethod alloy:render-needed-p ((line location-info)) T)

(defmethod (setf alloy:value) :after (value (info location-info))
  (setf (timeout info) 5.0))

(defmethod show ((info location-info) &key)
  (let ((ui (unit 'ui-pass T)))
    (alloy:with-unit-parent ui
      (setf (alloy:bounds info) (alloy:px-extent (alloy:u- (alloy:vw 1) (alloy:un 550))
                                                 (alloy:u- (alloy:vh 1) (alloy:un 50))
                                                 (alloy:un 500)
                                                 (alloy:un 20))))
    (alloy:enter info ui)))

(defmethod hide ((info location-info))
  (when (slot-boundp info 'alloy:layout-parent)
    (alloy:leave info T)))

(defmethod animation:update :after ((info location-info) dt)
  (when (<= (decf (timeout info) dt) 0.0)
    (hide info)))

(defun location-info (string)
  (let ((info (alloy:do-elements (element (alloy:popups (alloy:layout-tree (unit 'ui-pass T))))
                (when (typep element 'location-info) (return element)))))
    (if info
        (setf (alloy:value info) string)
        (show (make-instance 'location-info :value string)))))
