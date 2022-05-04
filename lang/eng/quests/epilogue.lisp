;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria epilogue)
  :author "Tim White"
  :title "Return to the Camp"
  :description "Catherine and I need to reach the surface and get back to the camp. I hope everyone is okay."
  (:eval
   (complete 'world)
   (setf (location 'fi) (location 'epilogue-fi))
   (setf (direction 'fi) -1)
   (setf (location 'jack) (location 'epilogue-jack))
   (setf (direction 'jack) -1)
   (setf (location 'innis) (location 'epilogue-innis))
   (setf (direction 'innis) -1)
   (deactivate (unit 'semi-surface-spawner-1))
   (deactivate (unit 'semi-surface-spawner-3)))
  (:go-to (platform-start :follow catherine)
   :title "Return to the surface"
   "~ catherine
   (:concerned)I hope everyone's okay up there.")
  (:go-to (tutorial-end :follow catherine)
   :title "Return to the camp")
  (:go-to (epilogue-end :follow catherine))
  (:eval
   (move :freeze player))
  (:wait 2.0)
  (:eval
    (transition :kind :black (show-panel 'credits))))