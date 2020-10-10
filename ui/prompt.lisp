(in-package #:org.shirakumo.fraf.kandria)

(defclass prompt (alloy:popup alloy:label*)
  () (:default-initargs :value ""))

(presentations:define-realization (ui prompt)
  ((:background simple:ellipse)
   (alloy:margins 0)
   :pattern colors:black)
  ((:label simple:text)
   (alloy:margins 2 0 0 0)
   alloy:text
   :valign :middle
   :halign :middle
   :font "PromptFont"
   :size (alloy:px 20)
   :pattern colors:white))

(presentations:define-update (ui prompt))

(defmethod show ((prompt prompt) &key button (input +input-source+) location)
  (when button
    (setf (alloy:value prompt) (prompt-char button :bank input)))
  (if location
      (alloy:with-unit-parent (unit 'ui-pass T)
        (let ((screen-location (world-screen-pos location))
              (bsize 20))
          (setf (alloy:bounds prompt) (alloy:px-extent (- (vx screen-location) bsize)
                                                       (+ (vy screen-location) bsize)
                                                       (* bsize 2) (* bsize 2)))))
      (setf (alloy:bounds prompt) (alloy:px-extent 16 16 16 16)))
  (unless (slot-boundp prompt 'alloy:layout-parent)
    (alloy:enter prompt (unit 'ui-pass T))))

(defmethod hide ((prompt prompt))
  (when (slot-boundp prompt 'alloy:layout-parent)
    (alloy:leave prompt T)))
