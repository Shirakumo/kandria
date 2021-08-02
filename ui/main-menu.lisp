(in-package #:org.shirakumo.fraf.kandria)

(defclass main-menu-button (button)
  ())

(presentations:define-realization (ui main-menu-button)
  ((:label simple:text)
   (alloy:margins) alloy:text
   :font (setting :display :font)
   :halign :middle :valign :middle)
  ((:border simple:rectangle)
   (alloy:extent 0 0 (alloy:pw 1) 1)))

(presentations:define-update (ui main-menu-button)
  (:label
   :size (alloy:un 16)
   :pattern colors:white)
  (:border
   :pattern (if alloy:focus colors:white colors:transparent)))

(presentations:define-animated-shapes main-menu-button
  (:border (simple:pattern :duration 0.2)))

(defclass main-menu (menuing-panel)
  ())

(defmethod initialize-instance :after ((panel main-menu) &key)
  (let ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout))
        (menu (make-instance 'alloy:vertical-linear-layout :cell-margins (alloy:margins 5) :min-size (alloy:size 100 30)))
        (focus (make-instance 'alloy:focus-list)))
    (alloy:enter menu layout :constraints `((:center :w) (:bottom 20) (:top 400) (:width 200)))
    (macrolet ((with-button ((name) &body body)
                 `(make-instance 'main-menu-button :value (@ ,name) :on-activate (lambda ()
                                                                                   (discard-events +world+)
                                                                                   ,@body)
                                                   :focus-parent focus :layout-parent menu)))
      (when (list-saves)
        (with-button (load-game-menu)
          (show-panel 'save-menu :intent :load)))
      (with-button (new-game)
        (if (list-saves)
            (show-panel 'save-menu :intent :new)
            (load-game NIL +main+)))
      (with-button (options-menu)
        (show-panel 'options-menu))
      (with-button (credits-menu)
        (show-panel 'credits))
      #++
      (with-button (changelog-menu)
        )
      (with-button (exit-game)
        (quit *context*)))
    (alloy:finish-structure panel layout focus)))
