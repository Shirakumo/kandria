(in-package #:org.shirakumo.fraf.kandria)

(defclass sticky-element (alloy:popup alloy:direct-value-component)
  ((offset :initform (random* 0 16) :accessor offset)))

(defmethod show ((element sticky-element) &key)
  (unless (find-panel 'fullscreen-panel)
    (unless (alloy:layout-tree element)
      (alloy:enter element (unit 'ui-pass T) :w 1 :h 1))
    (alloy:with-unit-parent element
      (let* ((target (alloy:value element))
             (screen-location (world-screen-pos (vec (vx (location target))
                                                     (+ (vy (location target)) (vy (bsize target)) 10
                                                        (offset element)))))
             (size (alloy:suggest-bounds (alloy:px-extent 0 0 96 8) element)))
        (setf (alloy:bounds element) (alloy:px-extent (- (vx screen-location) (/ (alloy:pxw size) 2))
                                                      (+ (vy screen-location) (alloy:pxh size))
                                                      (max 1 (alloy:pxw size))
                                                      (max 1 (alloy:pxh size))))))))

(defmethod hide ((prompt sticky-element))
  (when (alloy:layout-tree prompt)
    (alloy:leave prompt T)))

(defclass nametag-element (sticky-element)
  ())

(defmethod alloy:text ((element nametag-element))
  (nametag (alloy:value element)))

(presentations:define-realization (ui nametag-element)
  ((:background simple:rectangle)
   (alloy:extent -2 -8 100 10))
  ((:label simple:text)
   (alloy:extent 0 -5 1000 15)
   alloy:text
   :halign :start
   :valign :middle
   :font (setting :display :font)
   :size (alloy:un 12)
   :pattern colors:white))

(presentations:define-update (ui nametag-element)
  (:label
   :text alloy:text))

(defclass enemy-health-bar (sticky-element)
  ())

(defmethod alloy:text ((element enemy-health-bar))
  (princ-to-string (level (alloy:value element))))

(presentations:define-realization (ui enemy-health-bar)
  ((:background simple:rectangle)
   (alloy:margins -2 2 -2 -5))
  ((:bar simple:rectangle)
   (alloy:margins))
  ((:level simple:text)
   (alloy:extent -105 -5 100 20)
   alloy:text
   :halign :end
   :valign :middle
   :font (setting :display :font)
   :size (alloy:un 12)
   :pattern colors:white))

(presentations:define-update (ui enemy-health-bar)
  (:bar
   :pattern colors:white
   :scale (let ((p (/ (health alloy:value) (maximum-health alloy:value))))
            (alloy:px-size p 1)))
  (:level
   :text alloy:text
   :pattern (if (<= 10 (- (level alloy:value) (level (unit 'player +world+))))
                colors:red colors:white)))

(defclass hud-element ()
  ((timeout :initarg :timeout :initform (if (setting :gameplay :display-hud) 5.0 0.0) :accessor timeout)))

(defmethod animation:update :after ((element hud-element) dt)
  (when (< 0.0 (timeout element))
    (decf (timeout element) dt)
    (alloy:mark-for-render element)))

(defmethod (setf alloy:value) :after (value (info hud-element))
  (setf (timeout info) 5.0))

(defmethod (setf timeout) :around (value (element hud-element))
  (if (setting :gameplay :display-hud)
      (call-next-method)
      (call-next-method 0.0 element)))

(presentations:define-update (ui hud-element)
  (:label
   :text alloy:text
   :pattern (colored:color 1 1 1 (min 1 (* 1.5 (timeout alloy:renderable))))))

(defclass level-up (alloy:label* hud-element)
  ((timeout :initform 0.0)
   (alloy:value :initform 1)))

(defmethod alloy:text ((element level-up))
  (format NIL "LVL ~d" (alloy:value element)))

(presentations:define-realization (ui level-up)
  ((background simple:rectangle)
   (alloy:margins 2 20 2 5)
   :pattern (colored:color 0.1 0.1 0.1 0.25))
  ((background-2 simple:rectangle)
   (alloy:margins -5 40 -5 -5)
   :pattern (colored:color 0.1 0.1 0.1 0.25))
  ((bar simple:rectangle)
   (alloy:extent 0 0 (alloy:pw 1) 2)
   :pattern colors:white)
  ((title simple:text)
   (alloy:margins -10)
   (@ level-up-notification)
   :halign :middle
   :valign :middle
   :font (setting :display :font)
   :size (alloy:un 50)
   :pattern colors:white)
  ((level simple:text)
   (alloy:margins -10 -10 -10 -100)
   alloy:text
   :halign :middle
   :valign :middle
   :font (setting :display :font)
   :size (alloy:un 30)
   :pattern colors:white))

(presentations:define-update (ui level-up)
  (title
   :pattern (colored:color 1 1 1 (min 1 (timeout alloy:renderable))))
  (level
   :text alloy:text
   :pattern (colored:color 1 1 1 (min 1 (timeout alloy:renderable))))
  (background
   :pattern (colored:color 0.1 0.1 0.1 (min 1 (timeout alloy:renderable))))
  (background-2
   :pattern (colored:color 0.1 0.1 0.1 (* 0.75 (min 1 (timeout alloy:renderable)))))
  (bar
   :pattern (colored:color 1 1 1 (min 1 (timeout alloy:renderable)))))

(defclass health-bar (alloy:direct-value-component hud-element)
  ())

(defmethod initialize-instance :after ((bar health-bar) &key)
  (alloy:on health (value (alloy:value bar))
    (alloy:mark-for-render bar)))

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
   :font (setting :display :font)
   :size (alloy:un 12)))

(presentations:define-update (ui health-bar)
  (:bar
   :pattern (colored:color 1 1 1 (min 1 (timeout alloy:renderable)))
   :scale (let ((p (/ (health alloy:value) (maximum-health alloy:value))))
            (alloy:px-size p 1)))
  (:background
   :pattern (colored:color 0 0 0 (* 0.1 (min 1 (timeout alloy:renderable)))))
  (:border
   :hidden-p NIL
   :z-index 0
   :pattern (colored:color 0 0 0 (min 1 (timeout alloy:renderable))))
  (:label
   :text (format NIL "~3d%" (floor (* 100 (health alloy:value)) (maximum-health alloy:value)))))

(defclass location-info (alloy:label* hud-element)
  ((alloy:value :initform "")
   (timeout :initform 0.0)))

(presentations:define-realization (ui location-info)
  ((:bord simple:rectangle)
   (alloy:extent 0 -5 (alloy:pw 1) 1)
   :pattern colors:white)
  ((:label simple:text)
   (alloy:margins) alloy:text
   :font (setting :display :font)
   :valign :top
   :halign :right
   :size (alloy:un 16)))

(presentations:define-update (ui location-info)
  (:bord
   :pattern (colored:color 1 1 1 (min 1 (timeout alloy:renderable)))))

(defclass status-line (alloy:label* hud-element)
  ((importance :initarg :importance :initform :normal :accessor importance)
   (times :initarg :times :initform 1 :accessor times)))

(defmethod alloy:text ((line status-line))
  (if (<= (times line) 1)
      (alloy:value line)
      (format NIL "~a (x~d)" (alloy:value line) (times line))))

(presentations:define-realization (ui status-line)
  ((:label simple:text)
   (alloy:margins 0 -10) alloy:text
   :font (setting :display :font)
   :valign :top
   :halign :left
   :size (ecase (importance alloy:renderable)
           (:note (alloy:un 16))
           (:normal (alloy:un 20))
           (:important (alloy:un 26)))
   :pattern (ecase (importance alloy:renderable)
              (:note colors:white)
              (:normal colors:white)
              (:important colors:yellow))))

(defmethod animation:update :after ((line status-line) dt)
  (when (and (< (timeout line) 0.0)
             (alloy:layout-tree line))
    (alloy:leave line T)))

(defmethod alloy:suggest-bounds ((extent alloy:extent) (element status-line))
  (alloy:extent (alloy:x extent)
                (alloy:y extent)
                500
                (ecase (importance element)
                  (:note 20)
                  (:normal 26)
                  (:important 32))))

(defclass timer-line (alloy:label)
  ((alloy:value :initform "00:00")))

(defmethod alloy:text ((timer timer-line))
  (let ((clock (alloy:value timer)))
    (multiple-value-bind (ts ms) (floor clock)
      (multiple-value-bind (tm s) (floor ts 60)
        (format NIL "~2,'0d:~2,'0d.~2,'0d"
                tm s (floor (* 100 ms)))))))

(presentations:define-realization (ui timer-line)
  ((:label simple:text)
   (alloy:margins) alloy:text
   :font "PromptFont"
   :valign :middle
   :halign :middle
   :size (alloy:un 26)))

(presentations:define-update (ui timer-line)
  (:label :pattern colors:white))

(defclass hud-layout (org.shirakumo.alloy.layouts.constraint:layout)
  ())

(defmethod alloy:render :after ((ui ui) (layout hud-layout))
  (let ((wheel (stamina-wheel (unit 'player +world+))))
    (when (and (allocated-p (shader-program wheel))
               (< 0.0 (visibility wheel)))
      (with-pushed-matrix ()
        (render wheel T)))))

(defclass hud (panel)
  ((health :accessor health)
   (location :accessor location)
   (lines :accessor lines)
   (level-up :accessor level-up)
   (timer :initform NIL :accessor timer)))

(defmethod initialize-instance :after ((hud hud) &key (player (unit 'player T)))
  (let* ((layout (make-instance 'hud-layout))
         (bar (setf (health hud) (make-instance 'health-bar :value player)))
         (list (setf (lines hud) (make-instance 'alloy:vertical-linear-layout)))
         (loc (setf (location hud) (make-instance 'location-info)))
         (level-up (setf (level-up hud) (make-instance 'level-up))))
    (alloy:enter bar layout :constraints `((:left 80) (:top 20) (:height 15) (:width 300)))
    (alloy:enter list layout :constraints `((:left 20) (:top 220) (:size 1920 1000)))
    (alloy:enter loc layout :constraints `((:right 50) (:top 50) (:height 20) (:width 500)))
    (alloy:enter level-up layout :constraints `((:center :w) (:top 100) (:width 500) (:height 50)))
    (alloy:finish-structure hud layout NIL)))

(defmethod alloy:enter ((string string) (panel hud) &key (importance :normal))
  (let ((layout (lines panel)))
    (or (alloy:do-elements (element layout)
          (when (string= (alloy:value element) string)
            (incf (times element))
            (setf (timeout element) 5.0)
            (alloy:mark-for-render element)
            (return T)))
        (make-instance 'status-line :value string :importance importance :layout-parent layout))))

(defmethod clear ((panel hud))
  (let ((layout (lines panel)))
    (alloy:do-elements (element layout)
      (when (alloy:layout-tree element)
        (alloy:leave element layout)))))

(defun location-info (string)
  (let ((hud (find-panel 'hud)))
    (when (and hud (string/= string (alloy:value (location hud))))
      (setf (alloy:value (location hud)) string)
      (harmony:play (// 'sound 'ui-location-enter)))))

(defun status (importance &optional string &rest args)
  (let ((panel (find-panel 'hud)))
    (when panel
      (when (stringp importance)
        (push string args)
        (setf string importance)
        (setf importance :normal))
      (with-eval-in-render-loop (+world+)
        (alloy:enter (format NIL "~?" string args) panel :importance importance)))))

(defun show-timer (quest)
  (hide-timer)
  (let ((panel (find-panel 'hud))
        (timer (alloy:represent (clock quest) 'timer-line)))
    (alloy:enter timer (alloy:layout-element panel) :constraints `((:center :w) (:top 120) (:size 300 30)))
    (setf (timer panel) timer)))

(defun hide-timer ()
  (let* ((panel (find-panel 'hud))
         (timer (timer panel)))
    (when timer
      (alloy:leave timer (alloy:layout-parent timer))
      (setf (timer panel) NIL))))

(defmethod level-up :after ((player player))
  (let ((hud (find-panel 'hud)))
    (when hud
      (harmony:play (// 'sound 'ui-level-up) :reset T)
      (setf (alloy:value (level-up hud)) (level player)))))
