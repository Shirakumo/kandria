(in-package #:org.shirakumo.fraf.kandria)

(defclass palette-button (label)
  ())

(defmethod alloy:text ((button palette-button))
  (title (alloy:value button)))

(defmethod (setf alloy:focus) :after (focus (button palette-button))
  (when focus
    (setf (palette-index (unit 'player +world+)) (palette-index (alloy:value button)))))

(presentations:define-realization (ui palette-button)
  ((:background simple:rectangle)
   (alloy:margins)
   :pattern colors:black)
  ((:label simple:text)
   (alloy:margins 5)
   alloy:text
   :size (alloy:un 15)
   :font (setting :display :font)
   :pattern colors:white
   :valign :middle
   :halign :start))

(presentations:define-update (ui palette-button)
  (:background
   :pattern (if alloy:focus colors:white colors:black))
  (:label
   :pattern (if alloy:focus colors:black colors:white)))

(defclass wardrobe (menuing-panel pausing-panel)
  ())

(defmethod initialize-instance :after ((panel wardrobe) &key)
  (let* ((layout (make-instance 'eating-constraint-layout
                                :shapes (list (simple:rectangle (unit 'ui-pass T) (alloy:margins) :pattern (colored:color 0 0 0 0.5)))))
         (clipper (make-instance 'alloy:clip-view :limit :x))
         (scroll (alloy:represent-with 'alloy:y-scrollbar clipper))
         (focus (make-instance 'alloy:focus-list))
         (list (make-instance 'alloy:vertical-linear-layout
                              :shapes (list (simple:rectangle (unit 'ui-pass T) (alloy:margins) :pattern (colored:color 0 0 0 0.5)))
                              :min-size (alloy:size 100 50))))
    (alloy:enter list clipper)
    (alloy:enter clipper layout :constraints `((:width 500) (:right 70) (:bottom 100) (:top 100)))
    (alloy:enter scroll layout :constraints `((:width 20) (:right 50) (:bottom 100) (:top 100)))
    (alloy:enter (make-instance 'label :value (@ wardrobe-title)) layout :constraints `((:left 50) (:above ,clipper 10) (:size 500 50)))
    (dolist (palette (unlocked-palettes (unit 'player +world+)))
      (make-instance 'palette-button :value palette :layout-parent list :focus-parent focus))
    (let ((back (make-instance 'button :value (@ go-backwards-in-ui) :on-activate (lambda () (hide panel)))))
      (alloy:enter back layout :constraints `((:left 50) (:below ,clipper 10) (:size 200 50)))
      (alloy:enter back focus)
      (alloy:on alloy:exit (focus)
        (setf (alloy:focus back) :strong)))
    (alloy:finish-structure panel layout focus)))

#++T
(progn #!(show-panel 'wardrobe))
