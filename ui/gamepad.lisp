(in-package #:org.shirakumo.fraf.kandria)

(defclass gamepad-component (alloy:component)
  ((label :initarg :label :accessor label)))

(defmethod alloy:render-needed-p ((component gamepad-component)) T)

(defmethod alloy:text ((component gamepad-component))
  (or (prompt-string (label component) :bank (alloy:data component))
      (string (label component))))

(defclass button-display (gamepad-component)
  ())

(presentations:define-realization (ui button-display)
  ((:background simple:ellipse)
   (alloy:margins 2)
   :pattern (colored:color 0.15 0.15 0.15))
  ((:indicator simple:ellipse)
   (alloy:margins 6)
   :pattern colors:accent)
  ((:label simple:text)
   (alloy:margins)
   alloy:text
   :font "PromptFont"
   :size (alloy:un 20)
   :pattern colors:white
   :halign :middle
   :valign :middle))

(presentations:define-update (ui button-display)
  (:indicator
   :hidden-p (not (gamepad:button (label alloy:renderable) alloy:data))))

(defclass axis-display (gamepad-component)
  ())

(presentations:define-realization (ui axis-display)
  ((:background simple:rectangle)
   (alloy:margins 2)
   :pattern (colored:color 0.15 0.15 0.15))
  ((:indicator simple:rectangle)
   (alloy:margins 2)
   :pattern colors:accent)
  ((:label simple:text)
   (alloy:margins)
   alloy:text
   :font "PromptFont"
   :size (alloy:un 20)
   :pattern colors:white
   :halign :middle
   :valign :middle))

(presentations:define-update (ui axis-display)
  (:indicator
   :scale (alloy:px-size 1 (gamepad:axis (label alloy:renderable) alloy:data))))

(defclass bumper-display (button-display)
  ())

(presentations:define-realization (ui bumper-display)
  ((:background simple:rectangle)
   (alloy:margins 2)
   :pattern (colored:color 0.15 0.15 0.15))
  ((:indicator simple:rectangle)
   (alloy:margins 6)
   :pattern colors:accent)
  ((:label simple:text)
   (alloy:margins)
   alloy:text
   :font "PromptFont"
   :size (alloy:un 20)
   :pattern colors:white
   :halign :middle
   :valign :middle))

(defclass joystick-display (gamepad-component)
  ())

(defmethod x ((display joystick-display))
  (case (label display)
    (:L (gamepad:axis :L-H (alloy:data display)))
    (:R (gamepad:axis :R-H (alloy:data display)))
    (:DPAD (gamepad:axis :DPAD-H (alloy:data display)))
    (T 0.0)))

(defmethod y ((display joystick-display))
  (case (label display)
    (:L (gamepad:axis :L-V (alloy:data display)))
    (:R (gamepad:axis :R-V (alloy:data display)))
    (:DPAD (gamepad:axis :DPAD-V (alloy:data display)))
    (T 0.0)))

(presentations:define-realization (ui joystick-display)
  ((:background simple:ellipse)
   (alloy:margins 1)
   :pattern (colored:color 0.15 0.15 0.15))
  ((:indicator simple:ellipse)
   (alloy:extent 0 0 20 20)
   :pattern colors:accent)
  ((:label simple:text)
   (alloy:margins)
   alloy:text
   :font "PromptFont"
   :size (alloy:un 30)
   :pattern colors:white
   :halign :middle
   :valign :middle))

(presentations:define-update (ui joystick-display)
  (:indicator
   :offset (alloy:point (alloy:u- (alloy:pw (* 0.5 (1+ (x alloy:renderable))))
                                  (alloy:un 10))
                        (alloy:u- (alloy:ph (* 0.5 (1+ (y alloy:renderable))))
                                  (alloy:un 10)))))

(defclass dpad-display (joystick-display)
  ())

(presentations:define-realization (ui dpad-display)
  ((:background-1 simple:rectangle)
   (alloy:extent 0 (alloy:u- (alloy:ph 0.5) (alloy:un 15)) (alloy:pw 1) 30)
   :pattern (colored:color 0.15 0.15 0.15))
  ((:background-2 simple:rectangle)
   (alloy:extent (alloy:u- (alloy:pw 0.5) (alloy:un 15)) 0 30 (alloy:ph 1))
   :pattern (colored:color 0.15 0.15 0.15))
  ((:indicator simple:ellipse)
   (alloy:extent 0 0 20 20)
   :pattern colors:accent)
  ((:label simple:text)
   (alloy:margins)
   alloy:text
   :font "PromptFont"
   :size (alloy:un 30)
   :pattern colors:white
   :halign :middle
   :valign :middle))

(defclass gamepad-display (org.shirakumo.alloy.layouts.constraint:layout alloy:renderable)
  ((device :initarg :device :accessor device)))

(defmethod alloy:text ((display gamepad-display))
  (gamepad:name (device display)))

(presentations:define-realization (ui gamepad-display)
  ((bg-1 simple:polygon)
   (list (alloy:point 20 0)
         (alloy:point 0 20)
         (alloy:point 0 270)
         (alloy:point 20 290)
         (alloy:point 200 290)
         (alloy:point 140 20)
         (alloy:point 120 0))
   :pattern (colored:color 0.05 0.05 0.05))
  ((bg-2 simple:polygon)
   (list (alloy:point 480 0)
         (alloy:point 500 20)
         (alloy:point 500 270)
         (alloy:point 480 290)
         (alloy:point 300 290)
         (alloy:point 360 20)
         (alloy:point 380 0))
   :pattern (colored:color 0.05 0.05 0.05))
  ((bg-3 simple:rectangle)
   (alloy:extent 30 100 440 190)
   :pattern (colored:color 0.05 0.05 0.05)))

(defmethod initialize-instance :after ((layout gamepad-display) &key)
  (let ((device (device layout)))
    ;; TODO: we just use the default gamepad display. Badly mapped inputs,
    ;;       or inputs not part of the standard layout will not display.
    (let ((buttons (make-instance 'org.shirakumo.alloy.layouts.constraint:layout)))
      (alloy:enter (make-instance 'button-display :data device :label :A) buttons
                   :constraints `((:size 50 50) (:center :w) (:bottom 0)))
      (alloy:enter (make-instance 'button-display :data device :label :B) buttons
                   :constraints `((:size 50 50) (:center :h) (:right 0)))
      (alloy:enter (make-instance 'button-display :data device :label :X) buttons
                   :constraints `((:size 50 50) (:center :h) (:left 0)))
      (alloy:enter (make-instance 'button-display :data device :label :Y) buttons
                   :constraints `((:size 50 50) (:center :w) (:top 0)))
      (alloy:enter buttons layout :constraints `((:size 125 125) (:right 15) (:top 60))))
    (alloy:enter (make-instance 'dpad-display :data device :label :DPAD) layout
                 :constraints `((:size 90 90) (:left 15) (:top 75)))
    (let ((buttons (make-instance 'alloy:horizontal-linear-layout :min-size (alloy:size 50 30) :cell-margins (alloy:margins 10 0))))
      (alloy:enter (make-instance 'bumper-display :data device :label :SELECT) buttons)
      (alloy:enter (make-instance 'bumper-display :data device :label :HOME) buttons)
      (alloy:enter (make-instance 'bumper-display :data device :label :START) buttons)
      (alloy:enter buttons layout :constraints `((:size 200 30) (:center :w) (:top 60))))
    (alloy:enter (make-instance 'label :value (gamepad:name device) :style `((:label :halign :center :size ,(alloy:un 15)))) layout
                 :constraints `((:center :w) (:top 90) (:size 200 50)))
    (alloy:enter (make-instance 'bumper-display :data device :label :R1) layout
                 :constraints `((:size 100 20) (:top 20) (:right 30)))
    (alloy:enter (make-instance 'bumper-display :data device :label :L1) layout
                 :constraints `((:size 100 20) (:top 20) (:left 30)))
    (alloy:enter (make-instance 'axis-display :data device :label :R2) layout
                 :constraints `((:size 100 20) (:top 0) (:right 30)))
    (alloy:enter (make-instance 'axis-display :data device :label :L2) layout
                 :constraints `((:size 100 20) (:top 0) (:left 30)))
    (alloy:enter (make-instance 'joystick-display :data device :label :R) layout
                 :constraints `((:size 90 90) (:top 160) (:right 130)))
    (alloy:enter (make-instance 'joystick-display :data device :label :L) layout
                 :constraints `((:size 90 90) (:top 160) (:left 130)))))

(defmethod alloy:suggest-size (size (display gamepad-display))
  (alloy:size 500 300))

(defclass gamepad-diagnostics (panel)
  ())

(defmethod initialize-instance :after ((panel gamepad-diagnostics) &key)
  (let ((layout (make-instance 'alloy:flow-layout)))
    (dolist (gamepad (gamepad:list-devices))
      (alloy:enter (make-instance 'gamepad-display :device gamepad) layout))
    (alloy:finish-structure panel layout NIL)))

(defmethod handle ((ev gamepad-removed) (panel gamepad-diagnostics))
  (alloy:do-elements (element (alloy:layout-element panel))
    (when (eq (device ev) (device element))
      (alloy:leave element (alloy:layout-element panel)))))

(defmethod handle ((ev gamepad-added) (panel gamepad-diagnostics))
  (alloy:enter (make-instance 'gamepad-display :device (device ev)) (alloy:layout-element panel)))
