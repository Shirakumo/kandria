(in-package #:org.shirakumo.fraf.kandria)

(defclass input-action-button (alloy:direct-value-component)
  ())

(defmethod alloy:activate ((button input-action-button))
  (show (make-instance 'input-change-panel :source button)
        :width (alloy:un 800) :height (alloy:un 170)))

(defmethod alloy:text ((button input-action-button))
  (flet ((out (a)
           (with-output-to-string (out)
             (loop for char across a
                   do (write-char #\Space out)
                      (write-char char out)))))
    (out
     (case +input-source+
       (:keyboard
        (let ((mouse (trial::action-prompts (alloy:value button) :bank :mouse)))
          (if (string= "" mouse)
              (trial::action-prompts (alloy:value button) :bank :keyboard)
              mouse)))
       (T
        (trial::action-prompts (alloy:value button) :bank +input-source+))))))

(defmethod (setf alloy:focus) :after ((focus (eql :strong)) (button input-action-button))
  (setf (alloy:focus (alloy:focus-parent button)) :strong))

(presentations:define-realization (ui input-action-button)
  ((background simple:rectangle)
   (alloy:margins)
   :pattern colors:black)
  ((name simple:text)
   (alloy:margins 5)
   (language-string alloy:value)
   :pattern colors:white
   :size (alloy:un 15)
   :font (setting :display :font)
   :halign :start
   :valign :middle)
  ((binding simple:text)
   (alloy:margins 5)
   alloy:text
   :pattern colors:white
   :size (alloy:un 30)
   :font "PromptFont"
   :halign :end
   :valign :middle))

(presentations:define-update (ui input-action-button)
  (background
   :pattern (if alloy:focus colors:white colors:black))
  (name
   :pattern (if alloy:focus colors:black colors:white))
  (binding
   :text alloy:text
   :pattern (if alloy:focus colors:black colors:white)))

(defclass input-mapping-structure (alloy:observable-object org.shirakumo.alloy.layouts.constraint:layout alloy:focus-list alloy:renderable)
  ((toggle :initform NIL :accessor toggle)
   (event :initform NIL :accessor event)))

(defmethod initialize-instance :after ((structure input-mapping-structure) &key binding)
  (when binding
    (setf (event structure) (trial::make-event-from-binding binding))
    (setf (toggle structure) (eql :rise-only (getf (rest binding) :edge))))
  (let* ((label (alloy:represent (slot-value structure 'event) 'input-label))
         (toggle (alloy:represent (slot-value structure 'toggle) 'alloy:labelled-switch :text (@ input-toggles-state)))
         (remove (make-instance 'popup-button
                                :value (@ remove-input-mapping)
                                :on-activate (lambda ()
                                               (setf (alloy:focus (alloy:focus-parent structure)) :strong)
                                               (alloy:leave structure T)))))
    (alloy:enter label structure
                 :constraints `((:left 5) (:right 5) (:top 5) (= :b 50)))
    (alloy:enter toggle structure
                 :constraints `((:left 5) (:right 5) (:below ,label 2) (:height 20)))
    (alloy:enter remove structure
                 :constraints `((:left 5) (:right 5) (:below ,toggle 2) (:height 20)))))

(defmethod (setf alloy:focus) :after (a (structure input-mapping-structure))
  (alloy:mark-for-render structure))

(defmethod input-binding ((structure input-mapping-structure))
  (when (event structure)
    (trial::binding-from-event (event structure) :edge (if (toggle structure) :rise-only :rise))))

(presentations:define-realization (ui input-mapping-structure)
  ((:background simple:rectangle)
   (alloy:margins)
   :pattern colors:transparent)
  ((:border simple:rectangle)
   (alloy:extent 0 0 (alloy:pw 1) 5)))

(presentations:define-update (ui input-mapping-structure)
  (:background
   :pattern (if alloy:focus (colored:color 0 0 0 0.1) colors:transparent))
  (:border
   :pattern (if alloy:focus colors:accent colors:transparent)))

(defclass input-label (alloy:value-component)
  ())

(defmethod alloy:text ((label input-label))
  (let ((event (alloy:value label)))
    (if event
        (string (prompt-char event))
        "...")))

(defmethod alloy:accept ((label input-label))
  (setf (alloy:focus (alloy:focus-parent label)) :strong)
  (discard-events +world+)
  (alloy:focus-prev (alloy:focus-parent label)))

(defmethod handle (thing (label input-label)))

(defmethod (setf alloy:focus) :after ((focus (eql :strong)) (label input-label))
  (setf (alloy:value label) NIL))

(defmethod alloy:handle ((ev alloy:pointer-up) (label input-label))
  (cond ((eql :strong (alloy:focus label))
         (setf (alloy:value label) (make-instance 'mouse-press :pos (vec 0 0) :button (alloy:kind ev)))
         (alloy:accept label))
        (T
         (call-next-method))))

(defmethod handle ((ev key-press) (label input-label))
  (setf (alloy:value label) ev)
  (alloy:accept label))

(defmethod handle ((ev gamepad-press) (label input-label))
  (setf (alloy:value label) ev)
  (alloy:accept label))

(defmethod handle ((ev gamepad-move) (label input-label))
  (when (< 0.5 (abs (pos ev)))
    (setf (alloy:value label) ev)
    (alloy:accept label)))

(presentations:define-realization (ui input-label)
  ((background simple:rectangle)
   (alloy:margins)
   :pattern colors:transparent)
  ((border simple:rectangle)
   (alloy:margins)
   :pattern colors:black
   :line-width (alloy:un 1))
  ((label simple:text)
   (alloy:margins)
   alloy:text
   :font "PromptFont"
   :size (alloy:un 30)
   :pattern colors:black
   :halign :middle
   :valign :middle))

(presentations:define-update (ui input-label)
  (background :pattern (if alloy:focus (colored:color 0.8 0.8 0.8) (colored:color 0.9 0.9 0.9)))
  (label :text alloy:text)
  (border :pattern (if (eq :strong alloy:focus) colors:black colors:transparent)))

(defclass input-change-panel (alloy:observable-object popup-panel)
  ())

(defmethod initialize-instance :after ((panel input-change-panel) &key source)
  (let* ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout
                                :shapes (list (simple:rectangle (unit 'ui-pass T) (alloy:margins) :pattern colors:white))))
         (bindings (make-instance 'alloy:horizontal-linear-layout :min-size (alloy:size 120 50) :cell-margins (alloy:margins)))
         (focus (make-instance 'alloy:focus-list))
         (label (make-instance 'popup-label :value (language-string (alloy:value source))))
         (ok (make-instance 'popup-button
                            :value (@ accept-input-change)
                            :on-activate (lambda ()
                                           (let ((bindings (remove-if #'null (map 'list #'input-binding (alloy:elements bindings)))))
                                             (trial::update-action-bindings bindings (alloy:value source)
                                                                            :prune-types (if (eql +input-source+ :keyboard)
                                                                                             '(key mouse)
                                                                                             '(button axis))))
                                           (save-keymap)
                                           (alloy:mark-for-render source)
                                           (hide panel))))
         (cancel (make-instance 'popup-button
                                :value (@ cancel-input-change)
                                :on-activate (lambda ()
                                               (hide panel))))
         (add (make-instance 'popup-button
                             :value (@ add-input-mapping)
                             :on-activate (lambda ()
                                            (let ((binding (make-instance 'input-mapping-structure)))
                                              (alloy:enter binding bindings)
                                              (alloy:enter binding focus))))))
    (dolist (binding (action-bindings 'trial::keymap (alloy:value source) :device (case +input-source+ (:keyboard :keyboard) (T :gamepad))))
      (let ((binding (make-instance 'input-mapping-structure :binding binding)))
        (alloy:enter binding bindings)
        (alloy:enter binding focus)))
    (alloy:enter add focus)
    (alloy:enter ok focus)
    (alloy:enter cancel focus)
    (alloy:enter label layout
                 :constraints `((:top 0) (:left 5) (:right 5) (:height 20)))
    (alloy:enter cancel layout
                 :constraints `((:bottom 5) (:right 5) (:size 150 30)))
    (alloy:enter ok layout
                 :constraints `((:bottom 5) (:left-of ,cancel 5) (:size 150 30)))
    (alloy:enter add layout
                 :constraints `((:below ,label 5) (:above ,ok 5) (:right 0) (:width 50)))
    (alloy:enter bindings layout
                 :constraints `((:below ,label 5) (:above ,ok 5) (:left 0) (:right 50)))
    (alloy:on alloy:exit (focus)
      (setf (alloy:focus cancel) :strong))
    (alloy:finish-structure panel layout focus)))

(defmethod show :after ((panel input-change-panel) &key)
  ;;(setf (alloy:focus (label panel)) :strong)
  )

(defmethod handle :after ((ev event) (panel input-change-panel))
  (let ((focused (alloy:focused (unit 'ui-pass T))))
    (when (typep focused 'input-label)
      (handle ev focused))))

(defclass options-menu (tab-view menuing-panel)
  ())

(defmethod initialize-instance :after ((panel options-menu) &key)
  (macrolet ((control (label setting type &rest args)
               `(let ((label (alloy:represent ,(if (stringp label) label `(@ ,label)) 'setting-label))
                      (slider (alloy:represent (setting ,@setting) ,type ,@args)))
                  (alloy:enter label layout)
                  (alloy:enter slider layout)
                  (alloy:enter slider focus)))
             (with-tab (name &body body)
               `(let* ((layout-outer (make-instance 'alloy:border-layout :padding (alloy:margins 30)))
                       (layout (make-instance 'alloy:grid-layout :col-sizes '(400 300) :row-sizes '(40)
                                                                 :layout-parent layout-outer))
                       (focus (make-instance 'vertical-menu-focus-list)))
                  ,@body
                  (add-tab panel (@ ,name) layout-outer focus))))
    (with-tab audio-settings
      (typecase (harmony:segment :drain (harmony:segment :output T))
        (org.shirakumo.fraf.mixed.dummy:drain
         (alloy:enter (make-instance 'label :value #@no-sound-backend-available-warning :style `((:label :pattern ,colors:red :offset ,(alloy:point 30 0))))
                      layout-outer :place :north :size (alloy:un 40)))
        (org.shirakumo.fraf.mixed:device-drain
         (control audio-output-device (:audio :device) 'alloy:combo-set :value-set (list* :default (mixed:list-devices (harmony:segment :drain (harmony:segment :output T)))))))
      (control master-volume (:audio :volume :master) 'alloy:ranged-slider :range '(0 . 1) :step 0.1)
      (control effect-volume (:audio :volume :effect) 'alloy:ranged-slider :range '(0 . 1) :step 0.1)
      (control music-volume (:audio :volume :music) 'alloy:ranged-slider :range '(0 . 1) :step 0.1))
    (with-tab video-settings
      (control screen-resolution (:display :resolution) 'org.shirakumo.fraf.trial.alloy:video-mode)
      (control should-application-fullscreen (:display :fullscreen) 'alloy:checkbox)
      (control activate-vsync (:display :vsync) 'alloy:checkbox)
      (control gamma (:display :gamma) 'alloy:ranged-slider :range '(1.5 . 3.0) :step 0.1)
      (control render-shadows (:display :shadows) 'alloy:checkbox)
      (control user-interface-scale-factor (:display :ui-scale) 'alloy:ranged-slider :range '(0.25 . 2.0) :step 0.25)
      (control font (:display :font) 'alloy:combo-set :value-set '("PromptFont" "OpenDyslexic" "ComicSans"))
      (control display-hud (:gameplay :display-hud) 'alloy:checkbox))
    (let* ((layout (make-instance 'alloy:border-layout :padding (alloy:margins 30)))
           (list (make-instance 'alloy:vertical-linear-layout :cell-margins (alloy:margins 2 10 2 2) :min-size (alloy:size 300 50)))
           (clipper (make-instance 'alloy:clip-view :limit :x :layout-parent layout))
           (scroll (alloy:represent-with 'alloy:y-scrollbar clipper))
           (focus (make-instance 'vertical-menu-focus-list)))
      (alloy:enter list clipper)
      (alloy:enter scroll layout :place :east :size (alloy:un 20))
      (labels ((reset ()
                 (load-keymap :reset T))
               (confirm ()
                 (show (make-instance 'prompt-panel :text (@ confirm-input-mapping-reset) :on-accept #'reset)
                       :width (alloy:un 500) :height (alloy:un 300))))
        (make-instance 'button :value (@ reset-input-mapping) :on-activate #'confirm :layout-parent list :focus-parent focus))
      (dolist (action-set '(in-game in-menu in-map fishing))
        (make-instance 'label :value (language-string action-set) :layout-parent list)
        (dolist (action (sort (mapcar #'class-name (c2mop:class-direct-subclasses (find-class action-set)))
                              #'string< :key #'language-string))
          (make-instance 'input-action-button :value action :layout-parent list :focus-parent focus)))
      (add-tab panel (@ control-settings) layout focus))
    (with-tab gameplay-settings
      (control rumble (:gameplay :rumble) 'alloy:ranged-slider :range '(0.0 . 1.0) :step 0.1 :grid 0.1)
      (control screen-shake-strength (:gameplay :screen-shake) 'alloy:ranged-slider :range '(0.0 . 16.0) :step 0.1 :grid 0.1)
      (control pause-on-focus-loss (:gameplay :pause-on-focus-loss) 'alloy:checkbox)
      (control invincible-player (:gameplay :god-mode) 'alloy:checkbox)
      (control infinite-dash (:gameplay :infinite-dash) 'alloy:checkbox)
      (control infinite-climb (:gameplay :infinite-climb) 'alloy:checkbox)
      (control allow-resume-after-death (:gameplay :allow-resuming-death) 'alloy:checkbox)
      (control wolves-explode-on-death (:gameplay :exploding-wolves) 'alloy:checkbox)
      (control game-speed (:gameplay :game-speed) 'alloy:ranged-slider :range '(0.1 . 2.0) :step 0.1 :grid 0.1)
      (control damage-input-multiplier (:gameplay :damage-input) 'alloy:ranged-slider :range '(0.0 . 5.0) :step 0.1)
      (control damage-output-multiplier (:gameplay :damage-output) 'alloy:ranged-slider :range '(0.0 . 5.0) :step 0.1)
      (control level-multiplier (:gameplay :level-multiplier) 'alloy:ranged-slider :range '(0.0 . 10.0) :step 0.1))
    (with-tab language-settings
      (control game-language (:language) 'alloy:combo-set :value-set (languages))
      (control text-speed (:gameplay :text-speed) 'alloy:ranged-slider :range '(0.0 . 0.5) :step 0.01 :grid 0.01)
      (control auto-advance-after (:gameplay :auto-advance-after) 'alloy:ranged-slider :range '(0.0 . 30.0) :step 0.1 :grid 0.1)
      (control should-auto-advance-dialog (:gameplay :auto-advance-dialog) 'alloy:checkbox)
      (control display-text-effects (:gameplay :display-text-effects) 'alloy:checkbox)
      (control display-swears (:gameplay :display-swears) 'alloy:checkbox))
    (when (setting :debugging :show-debug-settings)
      (with-tab development-settings
        (control show-debug-settings (:debugging :show-debug-settings) 'alloy:checkbox)
        (control send-diagnostics (:debugging :send-diagnostics) 'alloy:checkbox)
        (control allow-editor (:debugging :allow-editor) 'alloy:checkbox)
        (control camera-control (:debugging :camera-control) 'alloy:checkbox)
        (control show-fps-counter (:debugging :fps-counter) 'alloy:checkbox)
        (control start-swank-server (:debugging :swank) 'alloy:checkbox)
        (control swank-server-port (:debugging :swank-port) 'alloy:ranged-wheel :range '(1024 . 65535))
        (control "Don't take screenshots" (:debugging :dont-save-screenshot) 'alloy:checkbox)
        (alloy:enter (alloy:represent #@open-config-dir 'setting-label) layout)
        (make-instance 'button :value #@generic-proceed-button :on-activate (lambda () (open-in-file-manager (config-directory)))
                               :layout-parent layout :focus-parent focus)))
    (alloy:on alloy:exit ((alloy:focus-element panel))
      (when (active-p panel)
        (hide panel)))))

(defclass back-button (tab)
  ())

(defmethod alloy:activate ((button back-button))
  (harmony:play (// 'sound 'ui-focus-out))
  (alloy:exit (alloy:focus-element (tab-view button))))

(defmethod show :before ((panel options-menu) &key)
  (alloy:enter (make-instance 'back-button :value (@ go-backwards-in-ui)) panel)
  (let ((layout (make-instance 'menu-layout)))
    (alloy:enter (alloy:layout-element panel) layout :place :center)
    (setf (slot-value panel 'alloy:layout-element) layout)))
