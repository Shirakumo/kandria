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
   (alloy:extent (alloy:ph -1.5) 0 (alloy:ph 1.5) (alloy:ph 1.5))
   (icon alloy:renderable)
   :size (alloy:ph 0.8)
   :pattern colors:white
   :font "Brands"
   :halign :left
   :valign :middle))

(presentations:define-update (ui cta-button)
  (:label
   :size (if alloy:focus (alloy:un 22) (alloy:un 20)))
  (:icon
   :size (if alloy:focus (alloy:ph 0.9) (alloy:ph 0.8))))

(presentations:define-animated-shapes cta-button
  (:label (simple:size :duration 0.2))
  (:icon (simple:size :duration 0.3)))

(defclass end-screen (menuing-panel pausing-panel)
  ())

(defmethod initialize-instance :after ((prompt end-screen) &key)
  (let* ((layout (make-instance 'big-prompt-layout))
         (focus (make-instance 'alloy:focus-list))
         (title (make-instance 'header :level 0 :value #@end-screen-title))
         (description (make-instance 'label :value #@end-screen-thanks :style `((:label :size ,(alloy:un 18) :valign :top)))))
    (alloy:enter title layout :constraints `((:center :w) (:top 100) (:center :w) (:size 2000 50)))
    (alloy:enter description layout :constraints `((:center :w) (:below ,title 50) (:size 1000 200)))
    (let ((inner (make-instance 'alloy:vertical-linear-layout :min-size (alloy:size 100 40))))
      (alloy:enter inner layout :constraints `((:center :w) (:below ,description 20) (:size 500 200)))
      (flet ((make-button (title icon url)
               (let ((button (make-instance 'cta-button :value title :icon icon :on-activate (lambda () (open-in-browser url)))))
                 (alloy:enter button inner)
                 (alloy:enter button focus))))
        (if (steam:steamworks-available-p)
            (make-button #@subscribe-cta :mail "https://courier.tymoon.eu/subscription/1")
            (make-button #@wishlist-cta :steam "https://store.steampowered.com/app/1261430/Kandria/?utm_source=in-game&utm_content=end-screen"))
        (make-button #@twitter-cta :twitter "https://twitter.com/shinmera")
        (make-button #@discord-cta :discord "https://kandria.com/discord"))
      (let ((return (make-instance 'button :focus-parent focus :value #@return-to-game :on-activate (lambda () (hide prompt))))
            (menu (make-instance 'button :focus-parent focus :value #@return-to-main-menu :on-activate (lambda () (return-to-main-menu)))))
        (alloy:enter return layout :constraints `((:below ,inner 40) (:size 300 40) (= :x (- (+ :rx (/ :rw 2)) (/ :w 2) +180))))
        (alloy:enter menu   layout :constraints `((:below ,inner 40) (:size 300 40) (= :x (- (+ :rx (/ :rw 2)) (/ :w 2) -180))))))
    (alloy:finish-structure prompt layout focus)))
