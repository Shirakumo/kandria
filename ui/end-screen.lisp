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

(defmethod initialize-instance :after ((prompt end-screen) &key)
  (let* ((layout (make-instance 'big-prompt-layout))
         (focus (make-instance 'alloy:focus-list))
         (title (make-instance 'header :level 0 :value #@end-screen-title))
         (description (make-instance 'label :value #@end-screen-thanks :style `((:label :size ,(alloy:un 18) :valign :top)))))
    (alloy:enter title layout :constraints `((:fill :w) (:top 100) (:height 50)))
    (alloy:enter description layout :constraints `((:center :w) (:below ,title 50) (:size 1000 200)))
    (let ((cta-links (make-instance 'alloy:vertical-linear-layout :min-size (alloy:size 100 40))))
      (alloy:enter cta-links layout :constraints `((:center :w) (:below ,description 20) (:size 500 200)))
      (flet ((make-button (title icon url)
               (let ((button (make-instance 'cta-button :value title :icon icon :on-activate (lambda () (open-in-browser url)))))
                 (alloy:enter button cta-links)
                 (alloy:enter button focus))))
        (make-button #@kickstart-cta :kickstarter "https://kandria.com/kickstarter")
        (make-button #@wishlist-cta :steam "https://store.steampowered.com/app/1261430/Kandria/?utm_source=in-game&utm_content=end-screen")
        (make-button #@twitter-cta :twitter "https://twitter.com/shinmera")
        (make-button #@discord-cta :discord "https://kandria.com/discord"))
      (let* ((buttons (make-instance 'alloy:grid-layout :col-sizes '(T T T) :row-sizes '(50))))
        (make-instance 'button :focus-parent focus :layout-parent buttons :value #@show-stats :on-activate (lambda () (show-panel 'stats-screen)))
        (make-instance 'button :focus-parent focus :layout-parent buttons :value #@return-to-game :on-activate (lambda () (hide prompt)))
        (make-instance 'button :focus-parent focus :layout-parent buttons :value #@return-to-main-menu :on-activate (lambda () (return-to-main-menu)))
        (alloy:enter buttons layout :constraints `((:center :w) (:size 700 50) (:below ,cta-links 40)))
        (alloy:on alloy:exit (focus)
          (setf (alloy:focus (alloy:index-element (1- (alloy:element-count focus)) focus)) :strong))))
    (alloy:finish-structure prompt layout focus)))
