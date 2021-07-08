(in-package #:org.shirakumo.fraf.kandria)

(defclass prompt (alloy:popup alloy:label*)
  () (:default-initargs :value ""))

(presentations:define-realization (ui prompt)
  ((:tail-shadow simple:polygon)
   (list (alloy:point (alloy:pw 0) (alloy:ph 0.5))
         (alloy:point (alloy:pw 1) (alloy:ph 0.5))
         (alloy:point (alloy:pw 0.5) (alloy:ph -0.3)))
   :pattern colors:white)
  ((:background-shadow simple:ellipse)
   (alloy:margins -1)
   :pattern colors:white)
  ((:tail simple:polygon)
   (list (alloy:point (alloy:pw 0) (alloy:ph 0.5))
         (alloy:point (alloy:pw 1) (alloy:ph 0.5))
         (alloy:point (alloy:pw 0.5) (alloy:ph -0.2)))
   :pattern (colored:color 0.15 0.15 0.15))
  ((:background simple:ellipse)
   (alloy:margins 0)
   :pattern colors:black)
  ((:label simple:text)
   (alloy:margins 2 0 0 0)
   alloy:text
   :valign :middle
   :halign :middle
   :font "PromptFont"
   :size (alloy:un 20)
   :pattern colors:white))

(presentations:define-update (ui prompt)
  (:label :pattern colors:white))

(defmethod show ((prompt prompt) &key button (input (case +input-source+
                                                      (:keyboard :keyboard)
                                                      (T :gamepad)))
                                      location)
  (when button
    (setf (alloy:value prompt)
          (etypecase button
            (symbol (string (prompt-char button :bank input)))
            (string button)
            (list (map 'string (lambda (c) (prompt-char c :bank input)) button)))))
  (if location
      (alloy:with-unit-parent (unit 'ui-pass T)
        (let ((screen-location (world-screen-pos location))
              (bsize (alloy:to-px (alloy:un 20))))
          (setf (alloy:bounds prompt) (alloy:px-extent (- (vx screen-location) bsize)
                                                       (+ (vy screen-location) bsize)
                                                       (* bsize 2 (length (alloy:value prompt)))
                                                       (* bsize 2)))))
      (setf (alloy:bounds prompt) (alloy:extent 16 16 16 16)))
  (unless (slot-boundp prompt 'alloy:layout-parent)
    (alloy:enter prompt (unit 'ui-pass T))))

(defmethod hide ((prompt prompt))
  (when (slot-boundp prompt 'alloy:layout-parent)
    (alloy:leave prompt T)))
