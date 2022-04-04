(in-package #:org.shirakumo.fraf.kandria)

(defclass prompt-label (alloy:label*)
  ())

(presentations:define-realization (ui prompt-label)
  ((:label simple:text)
   (alloy:margins)
   alloy:text
   :valign :middle
   :halign :middle
   :font "PromptFont"
   :size (alloy:un 30)
   :pattern colors:white))

(presentations:define-update (ui prompt-label)
  (:label :pattern colors:white))

(defclass prompt-description (alloy:label*)
  ())

(presentations:define-realization (ui prompt-description)
  ((:label simple:text)
   (alloy:margins)
   alloy:text
   :valign :middle
   :halign :middle
   :font (setting :display :font)
   :size (alloy:un 15)
   :pattern colors:white))

(presentations:define-update (ui prompt-description)
  (:label :pattern colors:white))

(defclass prompt (alloy:popup alloy:horizontal-linear-layout alloy:renderable popup)
  ((alloy:cell-margins :initform (alloy:margins))
   (alloy:min-size :initform (alloy:size))
   (label :accessor label)
   (description :accessor description)))

(defmethod initialize-instance :after ((prompt prompt) &key button description input)
  (let ((label (setf (label prompt) (make-instance 'prompt-label :value (if button (coerce-button-string button input) ""))))
        (descr (setf (description prompt) (make-instance 'prompt-description :value (or description "")))))
    (alloy:enter label prompt)
    (alloy:enter descr prompt)))

(presentations:define-realization (ui prompt)
  ((:tail-shadow simple:polygon)
   (list (alloy:point -2 0) (alloy:point 22 0) (alloy:point 10 -12))
   :pattern colors:white)
  ((:background-shadow simple:rectangle)
   (alloy:margins -5 -2 -5 -4)
   :pattern colors:white)
  ((:tail simple:polygon)
   (list (alloy:point 0 0) (alloy:point 20 0) (alloy:point 10 -10))
   :pattern (colored:color 0.15 0.15 0.15))
  ((:background simple:rectangle)
   (alloy:margins -5 -2 -5 -2)
   :pattern colors:black))

(presentations:define-update (ui prompt)
  (:tail-shadow
   :points (list (alloy:point -2 0) (alloy:point 22 0) (alloy:point 10 -12)))
  (:tail
   :points (list (alloy:point 0 0) (alloy:point 20 0) (alloy:point 10 -10)))
  (:label :pattern colors:white))

(defun coerce-button-string (button &optional input)
  (etypecase button
    (string button)
    (symbol (string (prompt-char button :bank input)))
    (list (map 'string (lambda (c) (prompt-char c :bank input)) button))))

(defmethod show ((prompt prompt) &key button input location (description NIL description-p))
  (unless (find-panel 'fullscreen-panel)
    (when button
      (setf (alloy:value (label prompt)) (coerce-button-string button input)))
    (when description-p
      (setf (alloy:value (description prompt)) (or description "")))
    (unless (alloy:layout-tree prompt)
      (alloy:enter prompt (unit 'ui-pass T) :w 1 :h 1))
    (alloy:mark-for-render prompt)
    (alloy:with-unit-parent prompt
      (let* ((screen-location (world-screen-pos location))
             (size (alloy:suggest-bounds (alloy:px-extent 0 0 16 16) prompt)))
        (setf (alloy:bounds prompt) (alloy:px-extent (- (vx screen-location) (alloy:to-px (alloy:un 10)))
                                                     (+ (vy screen-location) (alloy:pxh size))
                                                     (max 1 (alloy:pxw size))
                                                     (max 1 (alloy:pxh size))))))))

(defmethod hide ((prompt prompt))
  (when (alloy:layout-tree prompt)
    (alloy:leave prompt T)))

(defclass big-prompt (alloy:label*)
  ())

(presentations:define-realization (ui big-prompt)
  ((:label simple:text)
   (alloy:margins -10) alloy:text
   :font "PromptFont"
   :size (alloy:un 90)
   :valign :middle
   :halign :middle))

(animation:define-animation (pulse :loop T)
  0.0 ((setf presentations:scale) (alloy:px-size 1.0))
  0.3 ((setf presentations:scale) (alloy:px-size 1.2) :easing animation::quint-in)
  0.6 ((setf presentations:scale) (alloy:px-size 1.0) :easing animation::quint-out))

(defmethod presentations:realize-renderable :after ((ui ui) (prompt big-prompt))
  (let ((text (presentations:find-shape :label prompt)))
    ;; KLUDGE: no idea why this pivot is like this, but whatever...
    (setf (presentations:pivot text) (alloy:point 180 45))
    (animation:apply-animation 'pulse text)))

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

(defmethod show :after ((prompt fullscreen-prompt) &key)
  (harmony:play (// 'sound 'ui-tutorial-popup)))

(defmethod handle ((ev event) (prompt fullscreen-prompt))
  (when (etypecase (button prompt)
          (list (loop for type in (button prompt)
                      thereis (typep ev type)))
          (symbol (typep ev (button prompt))))
    (hide prompt)))

(defun fullscreen-prompt (action &key (title action) input (description (trial::mksym #.*package* title '/description)))
  (show (make-instance 'fullscreen-prompt :button action :input input :title title :description description)))
