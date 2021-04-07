(in-package #:org.shirakumo.fraf.kandria)

(defclass menu-layout (alloy:border-layout alloy:renderable)
  ())

(presentations:define-realization (ui menu-layout)
  ((:bg simple:rectangle)
   (alloy:margins)
   :pattern (colored:color 0.1 0.1 0.1)))

(defclass vertical-tab-bar (alloy:vertical-linear-layout alloy:renderable)
  ((alloy:min-size :initform (alloy:size 250 50))
   (alloy:cell-margins :initform (alloy:margins))))

(presentations:define-realization (ui vertical-tab-bar)
  ((:bg simple:rectangle)
   (alloy:margins)
   :pattern (colored:color 0.15 0.15 0.15)))

(defclass tab-button (alloy:value-component)
  ((alloy:text :initarg :text :accessor alloy:text)
   (alloy:index :initarg :index :accessor alloy:index)))

(defmethod alloy:exit ((button tab-button))
  (call-next-method))

(defmethod alloy:activate ((button tab-button))
  (setf (alloy:focus button) :strong)
  (setf (alloy:value button) (alloy:index button)))

(defmethod alloy:active-p ((button tab-button))
  (= (alloy:value button) (alloy:index button)))

(presentations:define-realization (ui tab-button)
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

(presentations:define-update (ui tab-button)
  (:border
   :hidden-p (not (alloy:active-p alloy:renderable)))
  (:background
   :pattern (ecase alloy:focus
              (:strong (colored:color 0.5 0.5 0.5))
              (:weak (colored:color 0.3 0.3 0.3))
              ((NIL) (if (alloy:active-p alloy:renderable)
                         (colored:color 0.3 0.3 0.3)
                         colors:transparent))))
  (:label
   :pattern (if (alloy:active-p alloy:renderable)
                colors:white
                (colored:color 0.9 0.9 0.9))))

(defclass options-stack (alloy:focus-stack alloy:observable)
  ())

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
      (alloy:enter (make-instance 'task-widget :value (quest:title task)) tasks))))

(presentations:define-realization (ui quest-widget)
  ((:bg simple:rectangle)
   (alloy:margins))
  ((:bord simple:rectangle)
   (alloy:margins 0 0 0 (alloy:ph 0.95))
   :pattern (case (quest:status (quest alloy:renderable))
              (:active colors:accent)
              (:complete colors:dim-gray)
              (:failed colors:dark-red))))

(presentations:define-update (ui quest-widget)
  (:bg
   :pattern (ecase alloy:focus
              (:strong (colored:color 0.3 0.3 0.3))
              (:weak (colored:color 0.3 0.3 0.3))
              ((NIL) (colored:color 0.2 0.2 0.2)))))

(defclass menu (pausing-panel)
  ((status-display :initform NIL :accessor status-display)))

(defmethod handle ((ev tick) (menu menu))
  (setf (alloy:value (status-display menu)) (overview-text)))

;; FIXME: scroll views for items and quests
(defmethod initialize-instance :after ((panel menu) &key)
  (let ((layout (make-instance 'menu-layout))
        (tabs (make-instance 'vertical-tab-bar))
        (center (make-instance 'alloy:swap-layout))
        (focus (make-instance 'options-stack)))
    (alloy:on alloy:exit (focus)
      (hide panel))
    ;; FIXME: focus proper layer in focus stack...
    (alloy:enter tabs layout :place :west :size (alloy:un 250))
    (alloy:enter center layout :place :center)
    (macrolet ((with-tab ((tab name &rest layout) &body fill)
                 `(let* ((,tab (make-instance ,@layout))
                         (layer (1+ (alloy:element-count tabs)))
                         (button (alloy:represent (alloy:index center) 'tab-button :index (1- layer) :text ,name)))
                    (alloy:enter button tabs)
                    (alloy:enter button focus :layer 0)
                    (alloy:enter ,tab center)
                    ,@fill))
               (with-options-tab ((tab name) &body fill)
                 `(with-tab (,tab ,name 'alloy:grid-layout :col-sizes '(200 300) :row-sizes '(50) :cell-margins (alloy:margins 10))
                    ,@fill))
               (with-button (name &body action)
                 `(make-instance 'button :value (@ ,name) :on-activate (lambda () ,@action)))
               (control (layout label setting type &rest args)
                 `(let ((label (alloy:represent (@ ,label) 'setting-label))
                        (slider (alloy:represent (setting ,@setting) ,type ,@args)))
                    (alloy:enter label ,layout)
                    (alloy:enter slider ,layout)
                    (alloy:enter slider focus :layer layer))))
      (with-tab (tab (@ overview-menu) 'org.shirakumo.alloy.layouts.constraint:layout)
        (let ((quick (with-button create-quick-save
                       (save-state +main+ :quick)))
              (resume (with-button resume-game
                        (hide panel)))
              ;; FIXME: Need monospace font.
              (status (make-instance 'label :value (overview-text) :style `((:label :valign :top :size ,(alloy:un 15))))))
          (setf (status-display panel) status)
          (alloy:enter status tab :constraints `((:margin 10)))
          (alloy:enter resume tab :constraints `((:bottom 10) (:left 10) (:width 200) (:height 40)))
          (alloy:enter quick tab :constraints `((:bottom 10) (:right-of ,resume 10) (:width 200) (:height 40)))
          (alloy:enter resume focus :layer layer)
          (alloy:enter quick focus :layer layer)))
      
      (with-tab (tab (@ world-map-menu) 'org.shirakumo.alloy.layouts.constraint:layout)
        )
      
      (with-tab (tab (@ quest-menu) 'alloy:vertical-linear-layout :min-size (alloy:size 300 200))
        (dolist (quest (quest:known-quests (storyline +world+)))
          (let ((widget (make-instance 'quest-widget :quest quest)))
            (alloy:enter widget tab)
            (alloy:enter widget focus :layer layer))))
      
      (with-tab (tab (@ inventory-menu) 'alloy:border-layout)
        (let ((tabs (make-instance 'vertical-tab-bar :style `((:bg :pattern ,(colored:color 0.12 0.12 0.12)))))
              (center (make-instance 'alloy:swap-layout))
              (ifocus (make-instance 'alloy:focus-stack)))
          (alloy:enter tabs tab :place :west :size (alloy:un 200))
          (alloy:enter center tab :place :center)
          (alloy:enter ifocus focus :layer layer)
          (let ((focus ifocus)
                (inventory (unit 'player T)))
            (dolist (category '(consumable-item quest-item value-item special-item))
              (with-tab (tab (language-string category) 'alloy:vertical-linear-layout :min-size (alloy:size 300 50))
                (dolist (item (list-items inventory category))
                  (let ((button (make-instance 'item-button :value item :inventory inventory)))
                    (alloy:enter button tab)
                    (alloy:enter button focus :layer layer))))))))
      
      (with-tab (tab (@ options-menu) 'alloy:border-layout)
        (let ((tabs (make-instance 'vertical-tab-bar :style `((:bg :pattern ,(colored:color 0.12 0.12 0.12)))))
              (center (make-instance 'alloy:swap-layout))
              (ifocus (make-instance 'alloy:focus-stack)))
          (alloy:enter tabs tab :place :west :size (alloy:un 200))
          (alloy:enter center tab :place :center)
          (alloy:enter ifocus focus :layer layer)
          (let ((focus ifocus))
            (with-options-tab (audio (@ audio-settings))
              (control audio master-volume (:audio :volume :master) 'alloy:ranged-slider :range '(0 . 1) :step 0.1)
              (control audio effect-volume (:audio :volume :effect) 'alloy:ranged-slider :range '(0 . 1) :step 0.1)
              (control audio speech-volume (:audio :volume :speech) 'alloy:ranged-slider :range '(0 . 1) :step 0.1)
              (control audio music-volume (:audio :volume :music) 'alloy:ranged-slider :range '(0 . 1) :step 0.1))
            (with-options-tab (video (@ video-settings))
              (let ((modes (sort (delete-duplicates
                                  (loop for mode in (cl-glfw3:get-video-modes (cl-glfw3:get-primary-monitor))
                                        collect (list (getf mode '%CL-GLFW3:WIDTH) (getf mode '%CL-GLFW3:HEIGHT)))
                                  :test #'equal)
                                 #'> :key #'car))
                    (apply (make-instance 'button :value (@ apply-video-settings-now) :on-activate 'apply-video-settings)))
                (control video screen-resolution (:display :resolution) 'alloy:combo-set :value-set modes)
                (control video should-application-fullscreen (:display :fullscreen) 'alloy:switch)
                (control video activate-vsync (:display :vsync) 'alloy:switch)
                (control video user-interface-scale-factor (:display :ui-scale) 'alloy:ranged-slider :range '(0.25 . 2.0) :step 0.25)
                (alloy:enter apply video)
                (alloy:enter apply focus :layer 1)))
            (with-options-tab (gameplay (@ gameplay-settings))
              (control gameplay rumble (:gameplay :rumble) 'alloy:ranged-slider :range '(0.0 . 1.0) :step 0.1)
              (control gameplay screen-shake-strength (:gameplay :screen-shake) 'alloy:ranged-slider :range '(0.0 . 16.0) :step 1.0)
              (control gameplay text-speed (:gameplay :text-speed) 'alloy:ranged-slider :range '(0.0 . 0.5) :step 0.01)
              (control gameplay auto-advance-after (:gameplay :auto-advance-after) 'alloy:ranged-slider :range '(0.0 . 30.0) :step 1.0)
              (control gameplay invincible-player (:gameplay :god-mode) 'alloy:switch))
            (with-options-tab (language (@ language-settings))
              (control language game-language (:language :code) 'alloy:combo-set :value-set +languages+)))))
      
      (with-tab (tab (@ load-game-menu) 'org.shirakumo.alloy.layouts.constraint:layout)
        ))
    (alloy:finish-structure panel layout focus)))

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
;; FIXME: when changing language UI needs to update immediately
