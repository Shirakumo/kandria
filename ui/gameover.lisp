(in-package #:org.shirakumo.fraf.kandria)

(defclass pause-button (button)
  ())

(presentations:define-update (ui pause-button)
  (:background
   :pattern (ecase alloy:focus
              ((:weak :strong) colors:white)
              ((NIL) (colored:color 0 0 0 0.5))))
  (:label
   :size (alloy:un 20)
   :pattern (ecase alloy:focus
              ((:weak :strong) colors:black)
              ((NIL) colors:white))))

(defclass game-over-panel (pausing-panel menuing-panel)
  ())

(defmethod initialize-instance :after ((panel game-over-panel) &key)
  (let* ((layout (make-instance 'load-screen-layout :style `((:bg :pattern ,(colored:color 0.2 0.3 0.7 0.75)))))
         (focus (make-instance 'alloy:focus-list))
         (buttons (make-instance 'alloy:vertical-linear-layout :min-size (alloy:size 300 40)))
         (header (make-instance 'header :value #@game-over-title :level 0)))
    (macrolet ((with-button (name &body body)
                 `(let ((button (alloy:represent (@ ,name) 'pause-button :focus-parent focus :layout-parent buttons)))
                    (alloy:on alloy:activate (button)
                      ,@body))))
      (when (setting :gameplay :allow-resuming-death)
        (with-button resume-game
          (setf (health (unit 'player T))
                (maximum-health (unit 'player T)))
          (setf (state (unit 'player T)) :normal)
          (hide panel)))
      (with-button load-last-save
        (hide panel)
        (load-game T +main+))
      (with-button return-to-main-menu
        (reset (unit 'environment +world+))
        (transition
          :kind :black
          (reset +main+))))
    (alloy:enter header layout
                 :constraints `((:top 50) (:left 0) (:right 0) (:height 100)))
    (alloy:enter buttons layout
                 :constraints `((:below ,header 50) (:center :w) (:width 300) (:bottom 50)))
    (alloy:finish-structure panel layout focus)))
