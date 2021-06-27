(in-package #:org.shirakumo.fraf.kandria)

(defclass menu-layout (alloy:border-layout alloy:renderable)
  ())

(presentations:define-realization (ui menu-layout)
  ((:bg simple:rectangle)
   (alloy:margins)
   :pattern (colored:color 0.1 0.1 0.1)))

(defclass vertical-tab-bar (alloy:vertical-linear-layout alloy:focus-list alloy:observable alloy:renderable)
  ((alloy:min-size :initform (alloy:size 250 50))
   (alloy:cell-margins :initform (alloy:margins))))

(defmethod (setf alloy:focus) :after ((focus (eql :strong)) (bar vertical-tab-bar))
  (cond ((null (alloy:index bar))
         (setf (alloy:index bar) 0))
        ((alloy:focused bar)
         (setf (alloy:focus (alloy:focused bar)) :weak))
        (T
         (setf (alloy:focused bar) (alloy:index-element (alloy:index bar) bar)))))

(presentations:define-realization (ui vertical-tab-bar)
  ((:bg simple:rectangle)
   (alloy:margins)
   :pattern (colored:color 0.15 0.15 0.15)))

(defclass tab-view (alloy:structure)
  ())

(defmethod initialize-instance :after ((view tab-view) &key layout-parent focus-parent tabs)
  (let* ((layout (make-instance 'alloy:border-layout :layout-parent layout-parent))
         (list (make-instance 'vertical-tab-bar :focus-parent focus-parent)))
    (alloy:enter list layout :place :west :size (alloy:un 250))
    (dolist (tab tabs)
      (apply #'add-tab view tab))
    (alloy:finish-structure view layout list)))

(defun add-tab (view name layout-element focus-element)
  (let ((tab (make-instance 'tab :value name)))
    (alloy:enter focus-element tab)
    (alloy:enter layout-element tab)
    (alloy:enter tab view)
    tab))

(defclass tab (alloy:label*)
  ((tab-view :initarg :tab-view :accessor tab-view)
   (alloy:focus-element :initform NIL :accessor alloy:focus-element)
   (alloy:layout-element :initform NIL :accessor alloy:layout-element)))

(defmethod alloy:enter ((tab tab) (view tab-view) &key)
  (setf (tab-view tab) view)
  (alloy:enter tab (alloy:focus-element view)))

(defmethod alloy:enter ((element alloy:element) (button tab) &key)
  (when (typep element 'alloy:focus-element)
    (setf (alloy:focus-element button) element)
    (when (alloy:focus-tree button)
      (alloy::set-focus-tree element (alloy:focus-tree button))))
  (when (typep element 'alloy:layout-element)
    (setf (alloy:layout-element button) element)
    (when (alloy:layout-tree button)
      (alloy::set-layout-tree element (alloy:layout-tree button)))))

(defmethod alloy::set-focus-tree :before (value (item tab))
  (when (alloy:focus-element item)
    (alloy::set-focus-tree value (alloy:focus-element item))))

(defmethod alloy::set-layout-tree :before (value (item tab))
  (when (alloy:layout-element item)
    (alloy::set-layout-tree value (alloy:layout-element item))))

(defmethod alloy:notice-focus (sub (item tab)))
(defmethod alloy:notice-bounds (sub (item tab)))

(defmethod alloy:register :after ((item tab) (renderer alloy:renderer))
  (when (alloy:layout-element item)
    (alloy:register (alloy:layout-element item) renderer)))

(defmethod alloy:activate ((button tab))
  (when (alloy:layout-element button)
    (let ((layout (alloy:layout-element (tab-view button))))
      (when (alloy:index-element :center layout)
        (alloy:leave (alloy:index-element :center layout) layout))
      (alloy:enter (alloy:layout-element button) layout)))
  (when (alloy:focus-element button)
    (setf (alloy:focus (alloy:focus-element button)) :strong)))

(defmethod (setf alloy:focus) :after ((value (eql :weak)) (button tab))
  (when (alloy:layout-element button)
    (let ((layout (alloy:layout-element (tab-view button))))
      (when (alloy:index-element :center layout)
        (alloy:leave (alloy:index-element :center layout) layout))
      (alloy:enter (alloy:layout-element button) layout))))

(defmethod (setf alloy:focus) :after ((value (eql :strong)) (element tab))
  (setf (alloy:focus (alloy:focus-element (tab-view element))) :strong))

(defmethod alloy:active-p ((button tab))
  (not (null (alloy:focus button))))

(presentations:define-realization (ui tab)
  ((:border simple:rectangle)
   (alloy:extent 0 0 5 (alloy:ph 1))
   :pattern colors:white)
  ((:background simple:rectangle)
   (alloy:margins)
   :pattern colors:transparent)
  ((:label simple:text)
   (alloy:margins 10 0 0 0) alloy:text
   :font (setting :display :font)
   :size (alloy:un 20)
   :halign :start
   :valign :middle))

(presentations:define-update (ui tab)
  (:border
   :scale (alloy:size (if (alloy:active-p alloy:renderable) 1.0 0.0) 1.0))
  (:background
   :pattern (cond ((eql :weak alloy:focus)
                   (if (eql :strong (alloy:focus (alloy:focus-parent alloy:renderable)))
                       (colored:color 0.5 0.5 0.5)
                       (colored:color 0.3 0.3 0.3)))
                  (T (if (alloy:active-p alloy:renderable)
                         (colored:color 0.3 0.3 0.3)
                         colors:transparent))))
  (:label
   :pattern (if (alloy:active-p alloy:renderable)
                colors:white
                (colored:color 0.9 0.9 0.9))))

(presentations:define-animated-shapes tab
  (:border (presentations:scale :duration 0.2))
  (:background (simple:pattern :duration 0.2)))

(defclass setting-label (alloy:label)
  ())

(presentations:define-update (ui setting-label)
  (:label :size (alloy:un 15)))

(defclass task-widget (label)
  ())

(presentations:define-realization (ui task-widget)
  ((:indicator simple:ellipse)
   (alloy:extent (alloy:ph 0.25) (alloy:ph 0.25) (alloy:ph 0.5) (alloy:ph 0.5))
   :pattern colors:accent)
  ((:label simple:text)
   (alloy:margins (alloy:ph 1.0) 0 0 0)
   alloy:text
   :size (alloy:un 15)
   :font (setting :display :font)))

(defclass quest-widget (org.shirakumo.alloy.layouts.constraint:layout alloy:focus-element alloy:renderable)
  ((quest :initarg :quest :accessor quest)))

(defmethod initialize-instance :after ((widget quest-widget) &key quest)
  (let ((header (make-instance 'label :value (quest:title quest) :style `((:label :size ,(alloy:un 30)))))
        (description (make-instance 'label :value (quest:description quest) :style `((:label :size ,(alloy:un 15) :valign :top))))
        (tasks (make-instance 'alloy:vertical-linear-layout)))
    (alloy:enter header widget :constraints `((:top 10) (:left 10) (:right 10) (:height 50)))
    (alloy:enter description widget :constraints `((:below ,header 10) (:left 15) (:right 30) (:height 50)))
    (alloy:enter tasks widget :constraints `((:below ,description 10) (:left 0) (:right 0) (:bottom 0)))
    (dolist (task (quest:active-tasks quest))
      (when (visible-p task)
        (alloy:enter (make-instance 'task-widget :value (quest:title task)) tasks)))))

(presentations:define-realization (ui quest-widget)
  ((:bg simple:rectangle)
   (alloy:margins))
  ((:bord simple:rectangle)
   (alloy:margins 0 0 0 (alloy:ph 0.95))
   :pattern (ecase (quest:status (quest alloy:renderable))
              (:active colors:accent)
              (:complete colors:dim-gray)
              (:failed colors:dark-red))))

(presentations:define-update (ui quest-widget)
  (:bg
   :pattern (case alloy:focus
              (:strong (colored:color 0.3 0.3 0.3))
              (:weak (colored:color 0.3 0.3 0.3))
              (T (colored:color 0.2 0.2 0.2)))))

(defclass input-label (label)
  ())

(presentations:define-update (ui input-label)
  (:label :size (alloy:un 30) :halign :middle :valign :middle))

(defclass menu (pausing-panel)
  ((status-display :initform NIL :accessor status-display)))

(defmethod handle ((ev tick) (menu menu))
  (setf (alloy:value (status-display menu)) (overview-text)))

(defmethod show :before ((menu menu) &key)
  (hide (unit 'walkntalk T)))

(defmethod show :after ((menu menu) &key)
  (alloy:activate (alloy:focus-element menu)))

;; FIXME: scroll views for items and quests
(defmethod initialize-instance :after ((panel menu) &key)
  (let ((layout (make-instance 'menu-layout))
        (tabs (make-instance 'tab-view)))
    (alloy:on alloy:exit ((alloy:focus-element tabs))
      (hide panel))
    (alloy:enter tabs layout :place :center)
    (macrolet ((control (label setting type &rest args)
                 `(let ((label (alloy:represent (@ ,label) 'setting-label))
                        (slider (alloy:represent (setting ,@setting) ,type ,@args)))
                    (alloy:enter label layout)
                    (alloy:enter slider layout)
                    (alloy:enter slider focus)))
               (with-tab ((name layout &rest layout-args) &body body)
                 `(let* ((layout (make-instance ,layout ,@layout-args))
                         (focus (make-instance 'alloy:focus-list)))
                    ,@body
                    (add-tab tabs ,name layout focus)))
               (with-tab-view (name &body body)
                 `(let* ((view (make-instance 'tab-view))
                         (tab (add-tab tabs ,name (alloy:layout-element view) (alloy:focus-element view)))
                         (tabs view))
                    (declare (ignore tab))
                    ,@body))
               (with-options-tab (name &body body)
                 `(with-tab ((@ ,name) 'alloy:grid-layout :col-sizes '(200 300) :row-sizes '(40))
                    ,@body))
               (with-button (name &body body)
                 `(make-instance 'button :value (@ ,name) :on-activate (lambda () ,@body) :focus-parent focus)))
      (with-tab ((@ overview-menu) 'org.shirakumo.alloy.layouts.constraint:layout)
        (let ((resume (with-button resume-game (hide panel)))
              ;; FIXME: Need monospace font.
              (status (make-instance 'label :value (overview-text) :style `((:label :valign :top :size ,(alloy:un 15))))))
          (setf (status-display panel) status)
          (alloy:enter status layout :constraints `((:margin 10)))
          (alloy:enter resume layout :constraints `((:bottom 10) (:left 10) (:width 200) (:height 40)))
          (when (saving-possible-p)
            (bvh:do-fitting (object (bvh (region +world+)) (chunk (unit 'player +world+)))
              (when (typep object 'save-point)
                (let ((save (with-button save-game (save-state +main+ T))))
                  (alloy:enter save layout :constraints `((:bottom 10) (:right-of ,resume 10) (:width 200) (:height 40))))
                (return))))))

      (with-tab ((@ quest-menu) 'alloy:vertical-linear-layout :min-size (alloy:size 300 200))
        (dolist (quest (quest:known-quests (storyline +world+)))
          (unless (or (eq :inactive (quest:status quest))
                      (not (visible-p quest)))
            (let ((widget (make-instance 'quest-widget :quest quest)))
              (alloy:enter widget layout)
              (alloy:enter widget focus)))))

      (with-tab-view (@ inventory-menu)
        (let ((inventory (unit 'player T)))
          (dolist (category '(consumable-item quest-item value-item special-item))
            (with-tab ((language-string category) 'alloy:vertical-linear-layout :min-size (alloy:size 300 50))
              (dolist (item (list-items inventory category))
                (let ((button (make-instance 'item-button :value item :inventory inventory)))
                  (alloy:enter button layout)
                  (alloy:enter button focus)))))))

      (with-tab ((@ controls-menu) 'alloy:grid-layout :col-sizes '(300 100 100) :row-sizes '(50))
        (make-instance 'alloy:label* :value "Action" :layout-parent layout)
        (make-instance 'alloy:label* :value "Key" :layout-parent layout)
        (make-instance 'alloy:label* :value "Pad" :layout-parent layout)
        (dolist (action '(left right up down jump light-attack heavy-attack interact dash climb crawl quickmenu report-bug))
          (make-instance 'alloy:label* :value (string action) :layout-parent layout)
          (let ((keyboard (first (action-input 'trial::keymap action :device :keyboard)))
                (gamepad (first (action-input 'trial::keymap action :device :gamepad))))
            (when keyboard
              (make-instance 'input-label :value (string (or (prompt-char keyboard :bank :mouse)
                                                             (prompt-char keyboard :bank :keyboard)))
                                          :layout-parent layout))
            (when gamepad
              (make-instance 'input-label :value (string (or (prompt-char gamepad :bank :gamepad)))
                                          :layout-parent layout)))))
      
      (with-tab-view (@ open-options-menu)
        (with-options-tab audio-settings
          (control master-volume (:audio :volume :master) 'alloy:ranged-slider :range '(0 . 1) :step 0.1)
          (control effect-volume (:audio :volume :effect) 'alloy:ranged-slider :range '(0 . 1) :step 0.1)
          (control speech-volume (:audio :volume :speech) 'alloy:ranged-slider :range '(0 . 1) :step 0.1)
          (control music-volume (:audio :volume :music) 'alloy:ranged-slider :range '(0 . 1) :step 0.1))
        (with-options-tab video-settings
          (control screen-resolution (:display :resolution) 'org.shirakumo.fraf.trial.alloy:video-mode)
          (control should-application-fullscreen (:display :fullscreen) 'alloy:switch)
          (control activate-vsync (:display :vsync) 'alloy:switch)
          (control user-interface-scale-factor (:display :ui-scale) 'alloy:ranged-slider :range '(0.25 . 2.0) :step 0.25)
          (control font (:display :font) 'alloy:combo-set :value-set '("PromptFont" "OpenDyslexic" "ComicSans")))
        (with-options-tab gameplay-settings
          (control rumble (:gameplay :rumble) 'alloy:ranged-slider :range '(0.0 . 1.0) :step 0.1)
          (control screen-shake-strength (:gameplay :screen-shake) 'alloy:ranged-slider :range '(0.0 . 16.0) :step 1.0)
          (control text-speed (:gameplay :text-speed) 'alloy:ranged-slider :range '(0.0 . 0.5) :step 0.01)
          (control auto-advance-after (:gameplay :auto-advance-after) 'alloy:ranged-slider :range '(0.0 . 30.0) :step 1.0)
          (control invincible-player (:gameplay :god-mode) 'alloy:switch)
          (control player-palette (:gameplay :palette) 'alloy:combo-set :value-set (palettes (asset 'kandria 'player))))
        (with-options-tab language-settings
          (control game-language (:language) 'alloy:combo-set :value-set (languages))))

      (with-tab ((@ exit-game) 'org.shirakumo.alloy.layouts.constraint:layout)
        (let ((resume (with-button resume-game (hide panel)))
              (exit (with-button exit-game (quit *context*)))
              (reset (with-button reset-game
                       (with-packet (packet (pathname-utils:subdirectory (root) "world") :direction :input)
                         (let ((scene (make-instance 'world :packet packet)))
                           (change-scene +main+ scene)
                           (load-state (initial-state scene) +main+)
                           (save-state +main+ T))))))
          (alloy:enter resume layout :constraints `((:bottom 10) (:left 10) (:width 200) (:height 40)))
          (alloy:enter exit layout :constraints `((:bottom 10) (:right-of ,resume 10) (:width 200) (:height 40)))
          (alloy:enter reset layout :constraints `((:bottom 10) (:right-of ,exit 10) (:width 200) (:height 40))))))
    (alloy:finish-structure panel layout (alloy:focus-element tabs))))

(defun overview-text ()
  (let ((player (unit 'player +world+)))
    (format NIL "~
~a: ~16t~a
~a: ~16t~a ~a
~a: ~16t~a
~a: ~16t~a%"
            (@ in-game-datetime) (format-absolute-time (truncate (timestamp +world+)))
            (@ current-play-time) (format-relative-time (session-time))
            (if (< (* 60 60 4) (session-time)) (@ long-play-time-warning) "")
            (@ total-play-time) (format-relative-time (total-play-time))
            (@ player-health) (health-percentage player))))
;; FIXME: when changing language or font, UI needs to update immediately
