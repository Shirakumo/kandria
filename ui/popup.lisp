(in-package #:org.shirakumo.fraf.kandria)

(defclass popup-layout (alloy:fixed-layout)
  ())

(presentations:define-realization (ui popup-layout)
  ((:bg simple:rectangle)
   (alloy:extent (alloy:vw -1) (alloy:vh -1) (alloy:vw 2) (alloy:vh 2))
   :pattern (colored:color 0.05 0 0 0.2)))

(defmethod alloy:handle ((ev alloy:pointer-event) (focus popup-layout))
  (restart-case
      (call-next-method)
    (alloy:decline ()
      T)))

(defclass popup-button (button)
  ())

(presentations:define-update (ui popup-button)
  (:label
   :pattern (if alloy:focus colors:white colors:black)
   :size (alloy:un 15))
  (:background
   :pattern (if alloy:focus colors:black (colored:color 0.9 0.9 0.9))))

(defclass popup-label (label)
  ())

(presentations:define-update (ui popup-label)
  (:label
   :pattern colors:black
   :size (alloy:un 15)))
