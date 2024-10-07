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

(defclass prompt (alloy:horizontal-linear-layout alloy:renderable)
  ((alloy:cell-margins :initform (alloy:margins))
   (alloy:min-size :initform (alloy:size 16 16))
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
    (symbol (prompt-string button :bank input :default (@ unbound-action-label)))
    (list (format NIL "~{~a~^ ~}" (mapcar (lambda (c) (prompt-string c :bank input :default "")) button)))))

(defmethod show ((prompt prompt) &key button input location (description NIL description-p))
  (when button
    (setf (alloy:value (label prompt)) (coerce-button-string button input)))
  (when description-p
    (setf (alloy:value (description prompt)) (or description "")))
  (unless (alloy:layout-tree prompt)
    (alloy:enter prompt (alloy:layout-element (find-panel 'hud))))
  (alloy:mark-for-render prompt)
  (alloy:with-unit-parent prompt
    (let* ((screen-location (world-screen-pos location))
           (size (alloy:suggest-size (alloy:px-size 16 16) prompt)))
      (setf (alloy:bounds prompt) (alloy:px-extent (min (- (vx screen-location) (alloy:to-px (alloy:un 10)))
                                                        (- (alloy:to-px (alloy:vw 1)) (alloy:pxw size)))
                                                   (min (+ (vy screen-location) (alloy:pxh size))
                                                        (- (alloy:to-px (alloy:vh 1)) (alloy:pxh size)))
                                                   (max 1 (alloy:pxw size))
                                                   (max 1 (alloy:pxh size)))))))

(defmethod hide ((prompt prompt))
  (when (alloy:layout-tree prompt)
    (alloy:leave prompt T)))

(defmethod alloy:render :around ((ui ui) (prompt prompt))
  (unless (find-panel 'fullscreen-panel)
    (call-next-method)))

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

(defclass big-prompt-layout (eating-constraint-layout alloy:renderable)
  ())

(presentations:define-realization (ui big-prompt-layout)
  ((:bg simple:rectangle)
   (alloy:margins)
   :pattern (colored:color 0 0 0 0.5)))

(defclass fullscreen-prompt (action-set-change-panel pausing-panel)
  ((button :initarg :button :accessor button)))

(defmethod initialize-instance :after ((prompt fullscreen-prompt) &key button input title description)
  (let ((layout (make-instance 'big-prompt-layout))
        (button (make-instance 'big-prompt :value (coerce-button-string button input)))
        (title (make-instance 'big-prompt-title :value (ensure-language-string title)))
        (description (make-instance 'big-prompt-description :value (ensure-language-string description)))
        (confirm (make-instance 'label :value (@ press-prompted-button) :style `((:label :size ,(alloy:un 14)) :halign :middle))))
    (alloy:enter button layout :constraints `(:center (:size 500 120)))
    (alloy:enter description layout :constraints `((:center :w) (:below ,button 20) (:size 1000 150)))
    (alloy:enter title layout :constraints `((:center :w) (:above ,button 20) (:align :left ,description -30) (:size 300 30)))
    (alloy:enter confirm layout :constraints `((:center :w) (:below ,description 20) (:size 1000 30)))
    (alloy:finish-structure prompt layout NIL)))

(defmethod show :after ((prompt fullscreen-prompt) &key)
  (harmony:play (// 'sound 'ui-tutorial-popup)))

(defmethod handle ((ev event) (prompt fullscreen-prompt))
  (when (etypecase (button prompt)
          (list (loop for type in (button prompt)
                      thereis (typep ev type)))
          (symbol (typep ev (button prompt))))
    (hide prompt)))

(defmethod (setf active-p) :after (value (panel fullscreen-prompt))
  (when value
    (setf (active-p (action-set 'in-game)) T)))

(defun fullscreen-prompt (action &key (title action) input (description (trial::mksym #.*package* title '/description)))
  (show (make-instance 'fullscreen-prompt :button action :input input :title title :description description)))

(defclass quest-indicator (alloy:popup alloy:renderable popup)
  ((angle :initform 0f0 :accessor angle)
   (target :initarg :target :accessor target)
   (clock :initarg :clock :initform 5f0 :accessor clock)))

(defmethod initialize-instance :after ((prompt quest-indicator) &key target)
  (let* ((target (typecase target
                  (entity target)
                  (symbol (node target +world+))
                  (T target))))
    (setf (target prompt) (closest-visible-target target))))

(defmethod animation:update :after ((prompt quest-indicator) dt)
  (when (alloy:layout-tree prompt)
    (let* ((target (target prompt))
           (tloc (ensure-location target))
           (bounds (in-view-tester (camera +world+))))
      (cond ((in-bounds-p tloc bounds)
             (let* ((yoff (typecase target
                            (layer 0.0)
                            (sized-entity (vy (bsize target)))
                            (T 0.0)))
                    (screen-location (world-screen-pos (tvec (vx tloc) (+ (vy tloc) yoff)))))
               (setf (angle prompt) (* 1.5 PI))
               (setf (alloy:bounds prompt) (alloy:px-extent (vx screen-location) (alloy:u+ (alloy:un 60) (vy screen-location))
                                                            1 1))))
            (T
             (labels ((div (x)
                        (if (= 0.0 x) 100000.0 (/ x)))
                      (ray-rect (bounds origin direction)
                        ;; Project ray from inside bounds to border and compute intersection.
                        (let* ((scale-x (div (vx direction)))
                               (scale-y (div (vy direction)))
                               (tx1 (* scale-x (- (vx bounds) (vx origin))))
                               (tx2 (* scale-x (- (vz bounds) (vx origin))))
                               (ty1 (* scale-y (- (vy bounds) (vy origin))))
                               (ty2 (* scale-y (- (vw bounds) (vy origin))))
                               (tt (min (max tx1 tx2) (max ty1 ty2))))
                          (nv+ (v* direction tt) origin))))
               (let* ((middle (tvec (* (+ (vx bounds) (vz bounds)) 0.5)
                                    (* (+ (vy bounds) (vw bounds)) 0.5)))
                      (direction (v- tloc middle))
                      (position (ray-rect (tvec (+ (vx bounds) 30) (+ (vy bounds) 30)
                                                (- (vz bounds) 30) (- (vw bounds) 30))
                                          middle direction))
                      (screen-location (world-screen-pos position)))
                 (setf (alloy:bounds prompt) (alloy:px-extent (vx screen-location) (vy screen-location) 1 1))
                 (setf (angle prompt) (point-angle direction))))))
      (if (<= (decf (clock prompt) dt) 0f0)
          (hide prompt)
          (alloy:mark-for-render prompt)))))

(presentations:define-realization (ui quest-indicator)
  ((:indicator simple:polygon)
   (list (alloy:point 0 -20)
         (alloy:point 50 0)
         (alloy:point 0 20))
   :pattern colors:white)
  ((:bg simple:ellipse)
   (alloy:extent -28 -28 56 56)
   :pattern colors:white)
  ((:indicator-fill simple:polygon)
   (list (alloy:point 0 -15)
         (alloy:point 45 0)
         (alloy:point 0 15))
   :pattern (colored:color 0.2 0.2 0.2))
  ((:fg simple:ellipse)
   (alloy:extent -25 -25 50 50)
   :pattern (colored:color 0.2 0.2 0.2))
  ((:text simple:text)
   (alloy:extent -32 -28 60 60)
   "⌖"
   :font "PromptFont"
   :pattern colors:white
   :size (alloy:un 35)
   :halign :middle
   :valign :middle))

(presentations:define-update (ui quest-indicator)
  (:indicator
   :rotation (angle alloy:renderable))
  (:indicator-fill
   :rotation (angle alloy:renderable)))

(defmethod show ((prompt quest-indicator) &key target)
  (unless (alloy:layout-tree prompt)
    (alloy:enter prompt (node 'ui-pass T) :w 1 :h 1))
  (when target
    (setf (target prompt) target))
  (alloy:mark-for-render prompt))

(defmethod hide ((prompt quest-indicator))
  (when (alloy:layout-tree prompt)
    (alloy:leave prompt T)))
