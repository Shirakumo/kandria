(in-package #:org.shirakumo.fraf.kandria)

(defclass sticky-element (alloy:direct-value-component)
  ((offset :initform (random* 0 16) :accessor offset)))

(defmethod show ((element sticky-element) &key)
  (unless (alloy:layout-tree element)
    (alloy:enter element (alloy:layout-element (find-panel 'hud))))
  (alloy:with-unit-parent element
    (let* ((target (alloy:value element))
           (screen-location (world-screen-pos (vec (vx (location target))
                                                   (+ (vy (location target)) (vy (bsize target)) 10
                                                      (offset element)))))
           (size (alloy:suggest-size (alloy:px-size 96 8) element)))
      (setf (alloy:bounds element) (alloy:px-extent (- (vx screen-location) (/ (alloy:pxw size) 2))
                                                    (+ (vy screen-location) (alloy:pxh size))
                                                    (max 1 (alloy:pxw size))
                                                    (max 1 (alloy:pxh size)))))))

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
  ((label simple:text)
   (alloy:extent 0 -5 1000 15)
   alloy:text
   :halign :start
   :valign :middle
   :font (setting :display :font)
   :size (alloy:un 12)
   :pattern colors:white
   :markup '((0 100 (:outline 1.0)))))

(presentations:define-update (ui nametag-element)
  (label
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
   :size (alloy:un 16)
   :pattern colors:white
   :markup '((0 100 (:outline 1.0)))))

(presentations:define-update (ui enemy-health-bar)
  (:bar
   :pattern colors:white
   :scale (let ((p (/ (health alloy:value) (maximum-health alloy:value))))
            (alloy:px-size p 1)))
  (:level
   :text alloy:text
   :pattern (if (<= 10 (- (level alloy:value) (level (node 'player +world+))))
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

(defclass boss-health-bar (alloy:direct-value-component hud-element)
  ())

(defmethod alloy:text ((element boss-health-bar))
  (princ-to-string (ceiling (health (alloy:value element)))))

(defmethod show ((element boss-health-bar) &key)
  (unless (alloy:layout-tree element)
    (alloy:enter element (alloy:layout-element (find-panel 'hud))
                 :constraints `((:required (:max-width 1500) (:center :w))
                                (:right 20) (:bottom 75) (:height 30)))))

(defmethod hide ((element boss-health-bar))
  (when (alloy:layout-tree element)
    (alloy:leave element T)))

(presentations:define-realization (ui boss-health-bar)
  ((:background simple:rectangle)
   (alloy:margins -2 2 -2 -5))
  ((:bar simple:rectangle)
   (alloy:margins)
   :pattern colors:orange)
  ((:fbar simple:rectangle)
   (alloy:margins)
   :pattern colors:white)
  ((:health simple:text)
   (alloy:margins -10)
   alloy:text
   :halign :middle
   :valign :middle
   :font (setting :display :font)
   :size (alloy:ph 0.75)
   :pattern colors:accent)
  ((:name simple:text)
   (alloy:extent 100 (alloy:ph 1.0) (alloy:pw 1.0) (alloy:ph 1.5))
   (language-string (type-of alloy:value))
   :halign :start
   :valign :middle
   :font (setting :display :font)
   :size (alloy:ph 0.5)
   :pattern colors:white
   :markup '((0 100 (:outline 1.0))))
  ((:level simple:text)
   (alloy:extent 10 (alloy:ph 1.0) (alloy:pw 1.0) (alloy:ph 1.5))
   (@formats 'enemy-level-string (level alloy:value))
   :halign :start
   :valign :middle
   :font (setting :display :font)
   :size (alloy:un 16)
   :pattern (if (<= 10 (- (level alloy:value) (level (node 'player +world+))))
                colors:red colors:white)
   :markup '((0 100 (:outline 1.0)))))

(presentations:define-update (ui boss-health-bar)
  (:bar
   :scale (let ((p (/ (health alloy:value) (maximum-health alloy:value))))
            (alloy:px-size p 1)))
  (:fbar
   :scale (let ((p (/ (health alloy:value) (maximum-health alloy:value))))
            (alloy:px-size p 1)))
  (:health
   :text alloy:text))

(presentations:define-animated-shapes boss-health-bar
  (:bar (presentations:scale :duration 0.5 :easing :cubic-in)))

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
   :size (alloy:un 12)
   :markup '((0 100 (:outline 1.0)))))

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
   (alloy:margins -10) alloy:text
   :font (setting :display :font)
   :valign :middle
   :halign :right
   :size (alloy:un 16)
   :markup '((0 100 (:outline 1.0)))))

(presentations:define-update (ui location-info)
  (:bord
   :pattern (colored:color 1 1 1 (min 1 (timeout alloy:renderable)))))

(defclass saving-status (alloy:label*)
  ((alloy:value :initform (@ saving-currently-possible))
   (hidden-p :initform T :accessor hidden-p)))

(defmethod (setf hidden-p) :after (value (status saving-status))
  (alloy:mark-for-render status))

(presentations:define-realization (ui saving-status)
  ((:label simple:text)
   (alloy:margins) alloy:text
   :font (setting :display :font)
   :valign :top
   :halign :right
   :size (alloy:un 20)
   :markup '((0 100 (:outline 1.0)))))

(presentations:define-update (ui saving-status)
  (:label
   :pattern colors:white
   :hidden-p (hidden-p alloy:renderable)))

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
              (:important colors:yellow))
   :markup '((0 1000 (:outline 1.0)))))

(defmethod animation:update :after ((line status-line) dt)
  (when (and (< (timeout line) 0.0)
             (alloy:layout-tree line))
    (alloy:leave line T)))

(defmethod alloy:suggest-size ((size alloy:size) (element status-line))
  (alloy:size 500
              (ecase (importance element)
                (:note 20)
                (:normal 26)
                (:important 32))))

(defclass timer-line (alloy:label)
  ((alloy:value :initform 0.0)
   (quest :initform NIL :initarg :quest)))

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
   :size (alloy:un 26)
   :markup '((0 100 (:outline 1.0)))))

(presentations:define-update (ui timer-line)
  (:label :pattern colors:white))

(defclass hud-layout (org.shirakumo.alloy.layouts.constraint:layout)
  ((player :initarg :player :accessor player)))

(defmethod alloy:render :after ((ui ui) (layout hud-layout))
  (let ((wheel (stamina-wheel (player layout))))
    (when (and (allocated-p (shader-program wheel))
               (< 0.0 (visibility wheel))
               (setting :gameplay :display-hud))
      (with-pushed-matrix ()
        (render wheel T)))))

(defmethod alloy:render :around ((ui ui) (layout hud-layout))
  (unless (find-panel 'editor)
    (call-next-method)))

(defclass hud (panel)
  ((health :accessor health)
   (location :accessor location)
   (lines :accessor lines)
   (level-up :accessor level-up)
   (saving :accessor saving)
   (timer :initform NIL :accessor timer)))

(defmethod initialize-instance :after ((hud hud) &key (player (node 'player T)))
  (let* ((layout (make-instance 'hud-layout :player player))
         (bar (setf (health hud) (make-instance 'health-bar :value player)))
         (list (setf (lines hud) (make-instance 'alloy:vertical-linear-layout)))
         (loc (setf (location hud) (make-instance 'location-info)))
         (level-up (setf (level-up hud) (make-instance 'level-up)))
         (saving (setf (saving hud) (make-instance 'saving-status))))
    (alloy:enter bar layout :constraints `((:left 80) (:top 20) (:height 15) (:width 300)))
    (alloy:enter list layout :constraints `((:left 20) (:top 220) (:size 1920 1000)))
    (alloy:enter loc layout :constraints `((:right 50) (:top 50) (:height 20) (:width 500)))
    (alloy:enter level-up layout :constraints `((:center :w) (:top 100) (:width 500) (:height 50)))
    (alloy:enter saving layout :constraints `((:right 50) (:top 20) (:height 50) (:width 500)))
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
    (when hud
      (cond ((null string)
             (setf (alloy:value (location hud)) "")
             (setf (timeout (location hud)) 0.0))
            ((string/= string (alloy:value (location hud)))
             (setf (alloy:value (location hud)) string)
             (harmony:play (// 'sound 'ui-location-enter)))))))

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
        (timer (alloy:represent (clock quest) 'timer-line :quest quest)))
    (alloy:enter timer (alloy:layout-element panel) :constraints `((:center :w) (:top 120) (:size 300 30)))
    (setf (timer panel) timer)))

(defun timer-quest ()
  (let* ((panel (find-panel 'hud))
         (timer (timer panel)))
    (when timer (slot-value timer 'quest))))

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

(defmethod handle ((ev switch-chunk) (hud hud))
  (setf (hidden-p (saving hud)) (or (not (setting :gameplay :display-hud))
                                    (timer hud)
                                    (not (save-point-available-p)))))

