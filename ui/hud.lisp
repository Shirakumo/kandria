(in-package #:org.shirakumo.fraf.kandria)

(defclass health-bar (alloy:progress)
  ())

(presentations:define-realization (ui health-bar)
  ((:background simple:rectangle)
   (alloy:margins -60 2 -2 -5))
  ((:bar simple:rectangle)
   (alloy:margins))
  ((:border simple:rectangle)
   (alloy:extent -5 -5 307 2))
  ((:label simple:text)
   (alloy:extent -60 -5 50 15)
   "100%"
   :halign :end
   :valign :middle
   :font "PromptFont"
   :size (alloy:un 12)))

(presentations:define-update (ui health-bar)
  (:bar
   :pattern colors:white)
  (:background
   :pattern (colored:color 0 0 0 0.1))
  (:border
   :pattern colors:black
   :hidden-p NIL
   :z-index 0)
  (:label
   :text (format NIL "~3d%" (floor (* 100 alloy:value) (alloy:maximum alloy:renderable)))
   :pattern colors:white))

(defclass hud (panel)
  ())

(defmethod initialize-instance :after ((hud hud) &key (player (unit 'player T)))
  (let* ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout))
         (bar (alloy:represent (health player) 'health-bar :maximum (maximum-health player))))
    (alloy:enter bar layout :constraints `((:left 80) (:top 20) (:height 15) (:width 300)))
    (alloy:finish-structure hud layout NIL)))
