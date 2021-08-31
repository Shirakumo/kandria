(in-package #:org.shirakumo.fraf.kandria)

(defclass header (label)
  ())

(presentations:define-update (ui header)
  (:label
   :size (alloy:un 70)
   :halign :middle
   :valign :middle))

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

(defclass game-over (pausing-panel menuing-panel)
  ())

(defmethod initialize-instance :after ((panel game-over) &key)
  (let* ((layout (make-instance 'eating-constraint-layout))
         (focus (make-instance 'alloy:focus-list))
         (buttons (make-instance 'alloy:vertical-linear-layout :min-size (alloy:size 300 40)))
         (header (make-instance 'header :value #@game-over-title)))
    (macrolet ((with-button (name &body body)
                 `(make-instance 'pause-button :focus-parent focus :layout-parent buttons
                                               :value (@ ,name) :on-activate (lambda () ,@body))))
      (unless (deploy:deployed-p)
        (with-button resume-game
          (setf (health (unit 'player T))
                (maximum-health (unit 'player T)))
          (hide panel)))
      (with-button load-last-save
        (load-state T +main+)
        (hide panel))
      (with-button return-to-main-menu
        (reset (unit 'environment +world+))
        (transition
          :kind :black
          (reset +main+)
          (invoke-restart 'discard-events))))
    (alloy:enter header layout
                 :constraints `((:top 50) (:left 0) (:right 0) (:height 100)))
    (alloy:enter buttons layout
                 :constraints `((:below ,header 50) (:center :w) (:width 300) (:bottom 50)))
    (alloy:finish-structure panel layout focus)))
