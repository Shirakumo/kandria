(in-package #:org.shirakumo.fraf.kandria)

(defclass cta-button (button)
  ((icon :accessor icon)))

(defmethod initialize-instance :after ((button cta-button) &key icon)
  (let ((code (ecase icon
                (:twitter #xF099)
                (:youtube #xF167)
                (:discord #xF392)
                (:reddit  #xF1A1)
                (:steam   #xF1B6)
                (:itchio  #xF83A)
                (:kickstarter #xF3BB)
                (:email   #x0020)
                (:mail    #x0020))))
    (setf (icon button) (string (code-char code)))))

(presentations:define-realization (ui cta-button)
  ((:label simple:text)
   (alloy:margins 20 10 5 10)
   alloy:text
   :font (setting :display :font)
   :halign :left
   :valign :middle)
  ((:icon simple:text)
   (alloy:extent (alloy:ph -1.5) (alloy:ph -0.25) (alloy:ph 1.5) (alloy:ph 1.5))
   (icon alloy:renderable)
   :size (alloy:ph 0.8)
   :pattern colors:white
   :font "Brands"
   :halign :left
   :valign :middle))

(presentations:define-update (ui cta-button)
  (:label
   :size (if alloy:focus (alloy:un 22) (alloy:un 20))
   :offset (if alloy:focus (alloy:point 20 0) (alloy:point 0 0)))
  (:icon
   :size (if alloy:focus (alloy:ph 0.9) (alloy:ph 0.8))
   :offset (if alloy:focus (alloy:point 20 0) (alloy:point 0 0))))

(presentations:define-animated-shapes cta-button
  (:label (simple:size :duration 0.2) (presentations:offset :duration 0.2))
  (:icon (simple:size :duration 0.3) (presentations:offset :duration 0.2)))

(defclass end-screen (menuing-panel pausing-panel)
  ())
