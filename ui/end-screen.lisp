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

(defclass end-screen (pausing-panel menuing-panel)
  ())

(defmethod initialize-instance :after ((prompt end-screen) &key next)
  (let* ((layout (make-instance 'big-prompt-layout))
         (focus (make-instance 'alloy:focus-list))
         (title (make-instance 'header :level 0 :value (@ module-world-completed-title)))
         (description (make-instance 'label :value (@formats 'module-world-completed-description (title +world+) (author +world+)) :style `((:label :size ,(alloy:un 18)
                                                                                                                                                    :valign :top
                                                                                                                                                    :halign :center))))
         (module (module +world+)))
    (alloy:enter title layout :constraints `((:fill :w) (:top 50) (:height 150)))
    (alloy:enter description layout :constraints `((:center :w) (:below ,title 20) (:size 1000 100)))

    (when (and module (ignore-errors (search-module T module)))
      (let ((rate-up (alloy:represent module 'module-rating-button :rating +1 :focus-parent focus))
            (rate-down (alloy:represent module 'module-rating-button :rating -1 :focus-parent focus)))
        (alloy:enter rate-up layout :constraints `((:below ,description 10) (:size 100 50) (:off-center :w -60)))
        (alloy:enter rate-down layout :constraints `((:below ,description 10) (:size 100 50) (:off-center :w +60)))))

    (let* ((buttons (make-instance 'alloy:vertical-linear-layout)))
      (macrolet ((with-button (label &body body)
                   `(let ((button (alloy:represent (@ ,label) 'button :focus-parent focus :layout-parent buttons)))
                      (alloy:on alloy:activate (button)
                        ,@body))))
        (when next
          (with-button module-proceed-to-next-world
            (load-into-world next)))
        (with-button module-replay-current-world
          (load-into-world +world+))
        (with-button module-edit-world
          (hide prompt)
          (show-panel 'editor))
        (with-button return-to-main-menu
          (return-to-main-menu)))
      (alloy:enter buttons layout :constraints `((:center :w) (:size 300 100) (:below ,description 200)))
      (alloy:on alloy:exit (focus)
        (setf (alloy:focus (alloy:index-element (1- (alloy:element-count focus)) focus)) :strong)))
    (alloy:finish-structure prompt layout focus)))

