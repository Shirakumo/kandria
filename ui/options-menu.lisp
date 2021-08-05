(in-package #:org.shirakumo.fraf.kandria)

(defclass input-action-button (alloy:direct-value-component)
  ())

(defmethod alloy:activate ((button input-action-button))
  (show-panel 'input-change-panel :source button))

(defmethod alloy:text ((button input-action-button))
  (case +input-source+
    (:keyboard
     (string (or (prompt-char (alloy:value button) :bank :mouse)
                 (prompt-char (alloy:value button) :bank :keyboard)
                 "<?>")))
    (T
     (string (or (prompt-char (alloy:value button) :bank :gamepad)
                 "<?>")))))

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

(defclass input-label (alloy:direct-value-component)
  ())

(defmethod alloy:accept ((label input-label))
  (setf (alloy:focus (alloy:focus-parent label)) :strong)
  (discard-events +world+)
  (alloy:focus-prev (alloy:focus-parent label)))

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
  (background :pattern (if alloy:focus (colored:color 0.9 0.9 0.9) colors:white))
  (label :text alloy:text)
  (border :pattern (if (eq :strong alloy:focus) colors:black colors:transparent)))

(defclass input-change-panel (popup-panel)
  ((label :accessor label)
   (event :initform NIL :accessor event)))

(defmethod initialize-instance :after ((panel input-change-panel) &key source)
  (let* ((layout (make-instance 'alloy:grid-layout :col-sizes '(150 150) :row-sizes '(80 T 40)
                                                   :shapes (list (simple:rectangle (unit 'ui-pass T) (alloy:margins) :pattern colors:white))))
         (focus (make-instance 'alloy:focus-list))
         (label (setf (label panel) (make-instance 'input-label :value "..." :focus-parent focus)))
         (ok (make-instance 'popup-button
                            :value (@ accept-input-change)
                            :on-activate (lambda ()
                                           (when (event panel)
                                             (set-trigger-from-event (event panel) (alloy:value source))
                                             (save-keymap)
                                             (alloy:mark-for-render source))
                                           (hide panel))
                            :focus-parent focus))
         (cancel (make-instance 'popup-button
                                :value (@ cancel-input-change)
                                :on-activate (lambda ()
                                               (hide panel))
                                :focus-parent focus)))
    (alloy:enter (make-instance 'popup-label :value (language-string (alloy:value source))) layout)
    (alloy:enter label layout)
    (alloy:enter ok layout :col 0 :row 2)
    (alloy:enter cancel layout :col 1 :row 2)
    (alloy:on alloy:exit (focus)
      (setf (alloy:focus cancel) :strong))
    (alloy:finish-structure panel layout focus)))

(defmethod show :after ((panel input-change-panel) &key)
  (setf (alloy:focus (label panel)) :strong))

(defmethod handle ((ev mouse-press) (panel input-change-panel))
  (when (eql :strong (alloy:focus (label panel)))
    (setf (alloy:value (label panel)) (string (prompt-char (button ev) :bank :mouse)))
    (setf (event panel) ev)
    (alloy:accept (label panel))))

(defmethod handle ((ev key-press) (panel input-change-panel))
  (when (eql :strong (alloy:focus (label panel)))
    (setf (alloy:value (label panel)) (string (prompt-char (key ev) :bank :keyboard)))
    (setf (event panel) ev)
    (alloy:accept (label panel))))

(defmethod handle ((ev gamepad-press) (panel input-change-panel))
  (when (eql :strong (alloy:focus (label panel)))
    (setf (alloy:value (label panel)) (string (prompt-char (button ev) :bank :gamepad)))
    (setf (event panel) ev)
    (alloy:accept (label panel))))

(defmethod handle ((ev gamepad-move) (panel input-change-panel))
  (when (and (eql :strong (alloy:focus (label panel)))
             (< 0.5 (abs (pos ev))))
    (let ((char (case (axis ev)
                  (:l-h (if (< 0 (pos ev)) :l-r :l-l))
                  (:l-v (if (< 0 (pos ev)) :l-u :l-d))
                  (:r-h (if (< 0 (pos ev)) :r-r :r-l))
                  (:r-v (if (< 0 (pos ev)) :r-u :r-d))
                  (:dpad-h (if (< 0 (pos ev)) :dpad-r :dpad-l))
                  (:dpad-v (if (< 0 (pos ev)) :dpad-u :dpad-d)))))
      (setf (alloy:value (label panel)) (string (prompt-char char :bank :gamepad))))
    (setf (event panel) ev)
    (alloy:accept (label panel))))

(defclass options-menu (tab-view menuing-panel)
  ())

(defmethod initialize-instance :after ((panel options-menu) &key)
  (macrolet ((control (label setting type &rest args)
               `(let ((label (alloy:represent (@ ,label) 'setting-label))
                      (slider (alloy:represent (setting ,@setting) ,type ,@args)))
                  (alloy:enter label layout)
                  (alloy:enter slider layout)
                  (alloy:enter slider focus)))
             (with-tab (name &body body)
               `(let* ((layout (make-instance 'alloy:grid-layout :col-sizes '(200 300) :row-sizes '(40)))
                       (focus (make-instance 'alloy:focus-list)))
                  ,@body
                  (add-tab panel (@ ,name) layout focus))))
    (with-tab audio-settings
      (control master-volume (:audio :volume :master) 'alloy:ranged-slider :range '(0 . 1) :step 0.1)
      (control effect-volume (:audio :volume :effect) 'alloy:ranged-slider :range '(0 . 1) :step 0.1)
      (control speech-volume (:audio :volume :speech) 'alloy:ranged-slider :range '(0 . 1) :step 0.1)
      (control music-volume (:audio :volume :music) 'alloy:ranged-slider :range '(0 . 1) :step 0.1))
    (with-tab video-settings
      (control screen-resolution (:display :resolution) 'org.shirakumo.fraf.trial.alloy:video-mode)
      (control should-application-fullscreen (:display :fullscreen) 'alloy:switch)
      (control activate-vsync (:display :vsync) 'alloy:switch)
      (control user-interface-scale-factor (:display :ui-scale) 'alloy:ranged-slider :range '(0.25 . 2.0) :step 0.25)
      (control font (:display :font) 'alloy:combo-set :value-set '("PromptFont" "OpenDyslexic" "ComicSans")))
    (let* ((layout (make-instance 'alloy:border-layout))
           (list (make-instance 'alloy:vertical-linear-layout :cell-margins (alloy:margins 2 10 2 2) :min-size (alloy:size 100 50)))
           (clipper (make-instance 'alloy:clip-view :limit :x :layout-parent layout))
           (scroll (alloy:represent-with 'alloy:y-scrollbar clipper))
           (focus (make-instance 'alloy:focus-list)))
      (alloy:enter list clipper)
      (alloy:enter scroll layout :place :east :size (alloy:un 20))
      (dolist (action-set '(in-game in-menu fishing))
        (make-instance 'label :value (language-string action-set) :layout-parent list)
        (dolist (action (sort (mapcar #'class-name (c2mop:class-direct-subclasses (find-class action-set)))
                              #'string< :key #'language-string))
          (make-instance 'input-action-button :value action :layout-parent list :focus-parent focus)))
      (add-tab panel (@ control-settings) layout focus))
    (with-tab gameplay-settings
      (control rumble (:gameplay :rumble) 'alloy:ranged-slider :range '(0.0 . 1.0) :step 0.1)
      (control screen-shake-strength (:gameplay :screen-shake) 'alloy:ranged-slider :range '(0.0 . 16.0) :step 1.0)
      (control text-speed (:gameplay :text-speed) 'alloy:ranged-slider :range '(0.0 . 0.5) :step 0.01)
      (control auto-advance-after (:gameplay :auto-advance-after) 'alloy:ranged-slider :range '(0.0 . 30.0) :step 1.0)
      (control invincible-player (:gameplay :god-mode) 'alloy:switch)
      (control player-palette (:gameplay :palette) 'alloy:combo-set :value-set (palettes (asset 'kandria 'player))))
    (with-tab language-settings
      (control game-language (:language) 'alloy:combo-set :value-set (languages)))
    (alloy:on alloy:exit ((alloy:focus-element panel))
      (when (active-p panel)
        (hide panel)))))
