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
        (concatenate 'string
                     (action-string (alloy:value button) :bank :mouse)
                     " "
                     (action-string (alloy:value button) :bank :keyboard)))
       (T
        (action-string (alloy:value button) :bank +input-source+))))))

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
   (alloy:margins 0 0 5 0)
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

(defmethod initialize-instance :after ((structure input-mapping-structure) &key mapping)
  (when mapping
    (setf (event structure) (event-from-action-mapping mapping))
    (setf (toggle structure) (toggle-p mapping)))
  (let* ((label (alloy:represent (slot-value structure 'event) 'input-label))
         (toggle (alloy:represent (slot-value structure 'toggle) 'alloy:labelled-switch :text (@ input-toggles-state)))
         (remove (alloy:represent (@ remove-input-mapping) 'popup-button)))
    (alloy:on alloy:activate (remove)
      (setf (alloy:focus (alloy:focus-parent structure)) :strong)
      (alloy:leave structure T))
    (alloy:enter label structure
                 :constraints `((:left 5) (:right 5) (:top 5) (= :b 50)))
    (alloy:enter toggle structure
                 :constraints `((:left 5) (:right 5) (:below ,label 2) (:height 20)))
    (alloy:enter remove structure
                 :constraints `((:left 5) (:right 5) (:below ,toggle 2) (:height 20)))))

(defmethod (setf alloy:focus) :after (a (structure input-mapping-structure))
  (alloy:mark-for-render structure))

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
    (or (when event
          (prompt-string event))
        "...")))

(defmethod alloy:accept ((label input-label))
  (setf (alloy:focus (alloy:focus-parent label)) :strong)
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
  (setf (alloy:value label) (clone ev))
  (alloy:accept label))

(defmethod handle ((ev gamepad-press) (label input-label))
  (setf (alloy:value label) (clone ev))
  (alloy:accept label))

(defmethod handle ((ev gamepad-move) (label input-label))
  (when (< 0.5 (abs (pos ev)))
    (setf (alloy:value label) (clone ev))
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
                                :shapes (list (simple:rectangle (node 'ui-pass T) (alloy:margins) :pattern colors:white))))
         (bindings (make-instance 'alloy:horizontal-linear-layout :min-size (alloy:size 120 50) :cell-margins (alloy:margins)))
         (focus (make-instance 'alloy:visual-focus-manager))
         (label (make-instance 'popup-label :value (language-string (alloy:value source))))
         (ok (alloy:represent (@ accept-input-change) 'popup-button))
         (cancel (alloy:represent (@ cancel-input-change) 'popup-button))
         (add (alloy:represent (@ add-input-mapping) 'popup-button)))
    (alloy:on alloy:activate (ok)
      (let ((bindings (loop for element across (alloy:elements bindings)
                            when (event element)
                            collect (event-to-action-mapping (event element) (alloy:value source)
                                                             :toggle-p (toggle element)))))
        (update-action-mappings bindings
                                :prune-event-type (if (eql +input-source+ :keyboard)
                                                      '(or key-event mouse-event)
                                                      'gamepad-event)))
      (save-keymap)
      (alloy:mark-for-render source)
      (hide panel))
    (alloy:on alloy:activate (cancel)
      (hide panel))
    (alloy:on alloy:activate (add)
      (let ((binding (make-instance 'input-mapping-structure)))
        (alloy:enter binding bindings)
        (alloy:enter binding focus)
        (setf (alloy:focus binding) :strong)))
    (dolist (mapping (find-action-mappings (alloy:value source) (case +input-source+
                                                                  (:keyboard '(or key-event mouse-event))
                                                                  (T 'gamepad-event))))
      (dolist (mapping (stratify-action-mapping mapping))
        (let ((binding (make-instance 'input-mapping-structure :mapping mapping)))
          (alloy:enter binding bindings)
          (alloy:enter binding focus))))
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
      (setf (alloy:focus focus) :strong)
      (setf (alloy:focus cancel) :weak))
    (alloy:finish-structure panel layout focus)))

(defmethod show :after ((panel input-change-panel) &key)
  ;;(setf (alloy:focus (label panel)) :strong)
  )

(defmethod handle :after ((ev event) (panel input-change-panel))
  (let ((focused (alloy:focused (node 'ui-pass T))))
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
             (with-tab ((name &rest tab-args) &body body)
               `(let* ((layout-outer (make-instance 'alloy:border-layout :padding (alloy:margins 30)))
                       (layout (make-instance 'alloy:grid-layout :col-sizes '(400 300) :row-sizes '(40)
                                                                 :layout-parent layout-outer))
                       (focus (make-instance 'vertical-menu-focus-list)))
                  ,@body
                  (add-tab panel ,(alloy:expand-place-data `(@ ,name)) layout-outer focus ,@tab-args))))
    (with-tab (audio-settings :icon "")
      #-nx
      (typecase (harmony:segment :drain (harmony:segment :output T))
        (org.shirakumo.fraf.mixed.dummy:drain
         (alloy:enter (make-instance 'label :value (@ no-sound-backend-available-warning) :style `((:label :pattern ,colors:red :offset ,(alloy:point 30 0))))
                      layout-outer :place :north :size (alloy:un 40)))
        (org.shirakumo.fraf.mixed:device-drain
         (control audio-output-device (:audio :device) 'alloy:combo-set :value-set (list* :default (mixed:list-devices (harmony:segment :drain (harmony:segment :output T)))))))
      (control master-volume (:audio :volume :master) 'alloy:ranged-slider :range '(0.0 . 1.0) :step 0.1)
      (control effect-volume (:audio :volume :effect) 'alloy:ranged-slider :range '(0.0 . 1.0) :step 0.1)
      (control music-volume (:audio :volume :music) 'alloy:ranged-slider :range '(0.0 . 1.0) :step 0.1))
    (with-tab (video-settings :icon "")
      #-nx (control display-used (:display :monitor) 'org.shirakumo.fraf.trial.alloy:monitor)
      #-nx (control screen-resolution (:display :resolution) 'org.shirakumo.fraf.trial.alloy:video-mode)
      #-nx (control should-application-fullscreen (:display :fullscreen) 'alloy:checkbox)
      #-nx (control activate-vsync (:display :vsync) 'alloy:checkbox)
      #-nx (control target-framerate (:display :target-framerate) 'alloy:combo-set :value-set (list :none 30 60 90 120 144 240 300))
      #-nx (control gamma (:display :gamma) 'alloy:ranged-slider :range '(1.5 . 3.0) :step 0.1)
      #-nx (control render-shadows (:display :shadows) 'alloy:checkbox)
      (control user-interface-scale-factor (:display :ui-scale) 'alloy:ranged-slider :range '(0.2 . 2.0) :step 0.1)
      (control font (:display :font) 'alloy:combo-set :value-set '("PromptFont" "OpenDyslexic" "ComicSans"))
      (control display-hud (:gameplay :display-hud) 'alloy:checkbox)
      (control show-hit-sting-lines (:gameplay :show-hit-stings) 'alloy:checkbox)
      (control visual-safe-mode (:gameplay :visual-safe-mode) 'alloy:checkbox))
    (let* ((layout (make-instance 'alloy:border-layout :padding (alloy:margins 30)))
           (list (make-instance 'alloy:vertical-linear-layout :cell-margins (alloy:margins 2 10 2 2) :min-size (alloy:size 300 50)))
           (clipper (make-instance 'alloy:clip-view :limit :x :layout-parent layout))
           (scroll (alloy:represent-with 'alloy:y-scrollbar clipper))
           (focus (make-instance 'vertical-menu-focus-list)))
      (alloy:enter list clipper)
      (alloy:enter scroll layout :place :east :size (alloy:un 20))
      (let ((button (alloy:represent (@ reset-input-mapping) 'button :layout-parent list :focus-parent focus)))
        (alloy:on alloy:activate (button)
          (show (make-instance 'prompt-panel :text (@ confirm-input-mapping-reset) :on-accept (lambda () (load-keymap :reset T)))
                :width (alloy:un 500) :height (alloy:un 300))))
      (dolist (action-set '(in-game in-menu in-map fishing))
        (make-instance 'label :value (language-string action-set) :layout-parent list)
        (dolist (action (sort (mapcar #'class-name (c2mop:class-direct-subclasses (find-class action-set)))
                              #'text< :key #'language-string))
          (make-instance 'input-action-button :value action :layout-parent list :focus-parent focus)))
      (add-tab panel (make-instance 'trial-alloy:language-data :name 'control-settings) layout focus :icon ""))
    (with-tab (gameplay-settings :icon "")
      (control rumble (:gameplay :rumble) 'alloy:ranged-slider :range '(0.0 . 1.0) :step 0.1 :grid 0.1)
      (control screen-shake-strength (:gameplay :screen-shake) 'alloy:ranged-slider :range '(0.0 . 16.0) :step 0.1 :grid 0.1)
      #-nx (control pause-on-focus-loss (:gameplay :pause-on-focus-loss) 'alloy:checkbox)
      (control invincible-player (:gameplay :god-mode) 'alloy:checkbox)
      (control infinite-dash (:gameplay :infinite-dash) 'alloy:checkbox)
      (control infinite-climb (:gameplay :infinite-climb) 'alloy:checkbox)
      (control allow-resume-after-death (:gameplay :allow-resuming-death) 'alloy:checkbox)
      (control wolves-explode-on-death (:gameplay :exploding-wolves) 'alloy:checkbox)
      (control show-speedrun-splits (:gameplay :show-splits) 'alloy:checkbox)
      (control game-speed (:gameplay :game-speed) 'alloy:ranged-slider :range '(0.1 . 2.0) :step 0.1 :grid 0.1)
      (control damage-input-multiplier (:gameplay :damage-input) 'alloy:ranged-slider :range '(0.0 . 5.0) :step 0.1)
      (control damage-output-multiplier (:gameplay :damage-output) 'alloy:ranged-slider :range '(0.0 . 5.0) :step 0.1)
      (control level-multiplier (:gameplay :level-multiplier) 'alloy:ranged-slider :range '(0.0 . 10.0) :step 0.1)
      (when (region +world+)
        (alloy:enter (alloy:represent (@ open-cheat-menu) 'setting-label) layout)
        (let ((button (alloy:represent (@ generic-proceed-button) 'button :layout-parent layout :focus-parent focus)))
          (alloy:on alloy:activate (button)
            (show-panel 'cheat-panel)))))
    (with-tab (language-settings :icon "")
      (when (rest (languages))
        (control game-language (:language) 'trial-alloy:language))
      (control text-speed (:gameplay :text-speed) 'alloy:ranged-slider :range '(0.0 . 0.5) :step 0.01 :grid 0.01)
      (control auto-advance-after (:gameplay :auto-advance-after) 'alloy:ranged-slider :range '(0.0 . 30.0) :step 0.1 :grid 0.1)
      (control should-auto-advance-dialog (:gameplay :auto-advance-dialog) 'alloy:checkbox)
      (control display-text-effects (:gameplay :display-text-effects) 'alloy:checkbox)
      (control display-swears (:gameplay :display-swears) 'alloy:checkbox))
    (when (setting :debugging :show-debug-settings)
      (with-tab (development-settings :icon "")
        (control show-debug-settings (:debugging :show-debug-settings) 'alloy:checkbox)
        (control show-startup-logos (:debugging :show-startup-screen) 'alloy:checkbox)
        (control kiosk-mode (:debugging :kiosk-mode) 'alloy:checkbox)
        (control send-diagnostics (:debugging :send-diagnostics) 'alloy:checkbox)
        (control dont-send-error-reports (:debugging :dont-submit-reports) 'alloy:checkbox)
        #++(control allow-editor (:debugging :allow-editor) 'alloy:checkbox)
        (control show-mod-menu-entry (:debugging :show-mod-menu-entry) 'alloy:checkbox)
        (control camera-control (:debugging :camera-control) 'alloy:checkbox)
        (control show-fps-counter (:debugging :fps-counter) 'alloy:checkbox)
        (control start-swank-server (:debugging :swank) 'alloy:checkbox)
        (control swank-server-port (:debugging :swank-port) 'alloy:ranged-wheel :range '(1024 . 65535))
        #++(control "Don't take screenshots" (:debugging :dont-save-screenshot) 'alloy:checkbox)
        (alloy:enter (alloy:represent (@ open-config-dir) 'setting-label) layout)
        (let ((button (alloy:represent (@ generic-proceed-button) 'button :layout-parent layout :focus-parent focus)))
          (alloy:on alloy:activate (button)
            (open-in-file-manager (config-directory))))
        (alloy:enter (alloy:represent (@ change-module-directory) 'setting-label) layout)
        (let ((button (alloy:represent (@ generic-proceed-button) 'button :layout-parent layout :focus-parent focus)))
          (alloy:on alloy:activate (button)
            (let* ((dir (module-directory))
                   (new (org.shirakumo.file-select:existing :title (@ change-module-directory) :default dir :filter :directory)))
              (when new
                (toast (@ generic-working-notice))
                (promise:-> (trial::promise
                             (with-eval-in-task-thread ()
                               (filesystem-utils:copy-file dir new)
                               (setf (setting :modules :directory) (pathname-utils:native-namestring new))
                               (register-module 'null)
                               (register-module T)))
                  (:then () (toast (@ generic-success-notice)))
                  (:handle () (toast (@ generic-failure-notice))
                           (setf (setting :modules :directory) (pathname-utils:native-namestring dir))))))))))
    (alloy:on alloy:exit ((alloy:focus-element panel))
      (when (active-p panel)
        (hide panel)))))

(defclass back-button (tab)
  ())

(defmethod alloy:activate ((button back-button))
  (harmony:play (// 'sound 'ui-focus-out))
  (alloy:exit (alloy:focus-element (tab-view button))))

(defmethod show :before ((panel options-menu) &key)
  (alloy:enter (alloy:represent (@ go-backwards-in-ui) 'back-button :icon "") panel)
  (let ((layout (make-instance 'menu-layout)))
    (alloy:enter (alloy:layout-element panel) layout :place :center)
    (setf (slot-value panel 'alloy:layout-element) layout)))
