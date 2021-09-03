(in-package #:org.shirakumo.fraf.kandria)

(defclass hud-element ()
  ((timeout :initarg :timeout :initform 5.0 :accessor timeout)))

(defmethod animation:update :after ((element hud-element) dt)
  (decf (timeout element) dt)
  (alloy:mark-for-render element))

(defmethod (setf alloy:value) :after (value (info hud-element))
  (setf (timeout info) 5.0))

(presentations:define-update (ui hud-element)
  (:label
   :text alloy:text
   :pattern (colored:color 1 1 1 (min 1 (* 1.5 (timeout alloy:renderable))))))

(defclass health-bar (alloy:progress hud-element)
  ())

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
   :pattern (colored:color 1 1 1 (min 1 (timeout alloy:renderable))))
  (:background
   :pattern (colored:color 0 0 0 (* 0.1 (min 1 (timeout alloy:renderable)))))
  (:border
   :hidden-p NIL
   :z-index 0
   :pattern (colored:color 0 0 0 (min 1 (timeout alloy:renderable))))
  (:label
   :text (format NIL "~3d%" (floor (* 100 alloy:value) (alloy:maximum alloy:renderable)))))

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
   (alloy:margins) alloy:text
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
             (slot-boundp line 'alloy:layout-parent))
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

(defclass hud (panel)
  ((health :accessor health)
   (location :accessor location)
   (lines :accessor lines)
   (timer :initform NIL :accessor timer)))

(defmethod initialize-instance :after ((hud hud) &key (player (unit 'player T)))
  (let* ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout))
         (bar (setf (health hud) (alloy:represent (health player) 'health-bar :maximum (maximum-health player))))
         (list (setf (lines hud) (make-instance 'alloy:vertical-linear-layout)))
         (loc (setf (location hud) (make-instance 'location-info))))
    (alloy:enter bar layout :constraints `((:left 80) (:top 20) (:height 15) (:width 300)))
    (alloy:enter list layout :constraints `((:left 20) (:top 220) (:size 1920 1000)))
    (alloy:enter loc layout :constraints `((:right 50) (:top 50) (:height 20) (:width 500)))
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
  (let ((layout (lines hud)))
    (alloy:do-elements (element layout)
      (when (slot-boundp element 'alloy:layout-parent)
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
