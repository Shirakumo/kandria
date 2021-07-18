(in-package #:org.shirakumo.fraf.kandria)

(defclass prompt (alloy:popup alloy:label*)
  () (:default-initargs :value ""))

(presentations:define-realization (ui prompt)
  ((:tail-shadow simple:polygon)
   (list (alloy:point (alloy:pw 0) (alloy:ph 0.5))
         (alloy:point (alloy:pw 1) (alloy:ph 0.5))
         (alloy:point (alloy:pw 0.5) (alloy:ph -0.3)))
   :pattern colors:white)
  ((:background-shadow simple:rectangle)
   (alloy:margins 0 0 0 -2)
   :pattern colors:white)
  ((:tail simple:polygon)
   (list (alloy:point (alloy:pw 0) (alloy:ph 0.5))
         (alloy:point (alloy:pw 1) (alloy:ph 0.5))
         (alloy:point (alloy:pw 0.5) (alloy:ph -0.2)))
   :pattern (colored:color 0.15 0.15 0.15))
  ((:background simple:rectangle)
   (alloy:margins 0)
   :pattern colors:black)
  ((:label simple:text)
   (alloy:margins 2 0 0 0)
   alloy:text
   :valign :middle
   :halign :middle
   :font "PromptFont"
   :size (alloy:un 30)
   :pattern colors:white))

(presentations:define-update (ui prompt)
  (:tail-shadow
   :points (list (alloy:point (alloy:pw 0) (alloy:ph 0.5))
                 (alloy:point (alloy:pw 1) (alloy:ph 0.5))
                 (alloy:point (alloy:pw 0.5) (alloy:ph -0.3))))
  (:tail
   :points (list (alloy:point (alloy:pw 0) (alloy:ph 0.5))
                 (alloy:point (alloy:pw 1) (alloy:ph 0.5))
                 (alloy:point (alloy:pw 0.5) (alloy:ph -0.2))))
  (:label :pattern colors:white))

(defun coerce-button-string (button &optional input)
  (let ((input (or input (case +input-source+
                           (:keyboard :keyboard)
                           (T :gamepad)))))
    (etypecase button
      (string button)
      (symbol (string (prompt-char button :bank input)))
      (list (map 'string (lambda (c) (prompt-char c :bank input)) button)))))

(defmethod show ((prompt prompt) &key button input location)
  (when button
    (setf (alloy:value prompt) (coerce-button-string button input)))
  (if location
      (alloy:with-unit-parent (unit 'ui-pass T)
        (let* ((screen-location (world-screen-pos location))
               (bsize (alloy:to-px (alloy:un 25)))
               (width (* bsize 2 (length (alloy:value prompt)))))
          (setf (alloy:bounds prompt) (alloy:px-extent (- (vx screen-location) (/ width 2))
                                                       (+ (vy screen-location) bsize)
                                                       width
                                                       (* bsize 2)))))
      (setf (alloy:bounds prompt) (alloy:extent 16 16 16 16)))
  (unless (slot-boundp prompt 'alloy:layout-parent)
    (alloy:enter prompt (unit 'ui-pass T))))

(defmethod hide ((prompt prompt))
  (when (slot-boundp prompt 'alloy:layout-parent)
    (alloy:leave prompt T)))

(defclass big-prompt (alloy:label*)
  ())

(presentations:define-realization (ui big-prompt)
  ((:label simple:text)
   (alloy:margins) alloy:text
   :font "PromptFont"
   :size (alloy:un 90)
   :valign :middle
   :halign :middle))

(defclass big-prompt-title (alloy:label*)
  ())

(presentations:define-realization (ui big-prompt-title)
  ((:top-border simple:rectangle)
   (alloy:extent 0 0 (alloy:pw 1) 2)
   :pattern colors:white)
  ((:label simple:text)
   (alloy:margins) alloy:text
   :font (setting :display :font)
   :size (alloy:un 20)
   :valign :top
   :halign :left
   :wrap T))

(defclass big-prompt-description (alloy:label*)
  ())

(presentations:define-realization (ui big-prompt-description)
  ((:top-border simple:rectangle)
   (alloy:extent 0 (alloy:ph 1) (alloy:pw 1) 2)
   :pattern colors:white)
  ((:label simple:text)
   (alloy:margins) alloy:text
   :font (setting :display :font)
   :size (alloy:un 30)
   :valign :top
   :halign :middle
   :wrap T))

(defclass big-prompt-layout (org.shirakumo.alloy.layouts.constraint:layout alloy:renderable)
  ())

(presentations:define-realization (ui big-prompt-layout)
  ((:bg simple:rectangle)
   (alloy:margins)
   :pattern (colored:color 0 0 0 0.5)))

(defclass fullscreen-prompt (pausing-panel)
  ((button :initarg :button :accessor button)))

(defmethod initialize-instance :after ((prompt fullscreen-prompt) &key button input title description)
  (let ((layout (make-instance 'big-prompt-layout))
        (button (make-instance 'big-prompt :value (coerce-button-string button input)))
        (title (make-instance 'big-prompt-title :value (ensure-language-string title)))
        (description (make-instance 'big-prompt-description :value (ensure-language-string description))))
    (alloy:enter button layout :constraints `(:center (:size 500 120)))
    (alloy:enter description layout :constraints `((:center :w) (:below ,button 20) (:size 1000 1000)))
    (alloy:enter title layout :constraints `((:center :w) (:above ,button 20) (:align :left ,description -30) (:size 300 30)))
    (alloy:finish-structure prompt layout NIL)))

(defmethod handle ((ev event) (prompt fullscreen-prompt))
  (when (etypecase (button prompt)
          (list (loop for type in (button prompt)
                      thereis (typep ev type)))
          (symbol (typep ev (button prompt))))
    (hide prompt)))

(defun fullscreen-prompt (action &key (title action) input (description (trial::mksym #.*package* title '/description)))
  (show (make-instance 'fullscreen-prompt :button action :input input :title title :description description)))
