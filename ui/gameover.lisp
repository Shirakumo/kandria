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
  (let* ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout))
         (focus (make-instance 'alloy:focus-list))
         (header (make-instance 'header :value #@game-over-title))
         (cont (make-instance 'pause-button :focus-parent focus :value #@resume-game
                                            :on-activate (lambda ()
                                                           (setf (health (unit 'player T))
                                                                 (maximum-health (unit 'player T)))
                                                           (hide panel))))
         (load (make-instance 'pause-button :focus-parent focus :value #@load-last-save
                                            :on-activate (lambda ()
                                                           (load-state T +main+)
                                                           (hide panel))))
         (quit (make-instance 'pause-button :focus-parent focus :value #@exit-game
                                            :on-activate (lambda ()
                                                           (quit *context*)))))
    (alloy:enter header layout
                 :constraints `((:top 50) (:left 0) (:right 0) (:height 100)))
    (unless (deploy:deployed-p)
      (alloy:enter cont layout
                   :constraints `((:below ,header 20) (:center :w) (:width 300) (:height 30))))
    (alloy:enter load layout
                 :constraints `((:below ,header 20) (:center :w) (:width 300) (:height 30)))
    (alloy:enter quit layout
                 :constraints `((:below ,load 5) (:center :w) (:width 300) (:height 30)))
    (alloy:finish-structure panel layout focus)))
