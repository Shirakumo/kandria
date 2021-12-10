(in-package #:org.shirakumo.fraf.kandria)

(defclass main (org.shirakumo.fraf.trial.steam:main
                org.shirakumo.fraf.trial.notify:main)
  ((scene :initform NIL)
   (state :initform NIL :accessor state)
   (timestamp :initform (get-universal-time) :accessor timestamp)
   (loader :initform (make-instance 'load-screen))
   (org.shirakumo.fraf.trial.steam:use-steaminput :initform NIL)
   (game-speed :initform 1.0 :accessor game-speed))
  (:default-initargs
   :clear-color (vec 2/17 2/17 2/17 0)
   :version '(3 3) :profile :core
   :title "Kandria"
   :app-id 1261430))

(defmethod initialize-instance ((main main) &key app-id world state audio-backend)
  (declare (ignore app-id))
  (setf +main+ main)
  (call-next-method)
  (setf +input-source+ :keyboard)
  (etypecase state
    (null)
    (save-state
     (setf (state main) state))
    ((or pathname string)
     (setf (state main) (minimal-load-state (merge-pathnames state (save-state-path "1")))))
    ((eql T)
     (setf (state main) (first (list-saves)))))
  (with-packet (packet (or world (pathname-utils:subdirectory (root) "world")) :direction :input)
    (setf (scene main) (make-instance 'world :packet packet)))
  (flet ((start (drain)
           (harmony:start (harmony:make-simple-server :name "Kandria" :latency (setting :audio :latency)
                                                      :mixers '(:music :speech (:effect mixed:plane-mixer))
                                                      :effects '((mixed:biquad-filter :filter :lowpass :name :lowpass)
                                                                 (mixed:speed-change :name :speed))
                                                      :drain drain))))
    (handler-case (with-error-logging (:kandria "Failed to set up sound, falling back to dummy output.")
                    (start (or audio-backend (setting :audio :backend) :default)))
      (error () (start :dummy))))
  (setf (mixed:min-distance harmony:*server*) (* +tile-size+ 5))
  (setf (mixed:max-distance harmony:*server*) (* +tile-size+ (vx +tiles-in-view+)))
  (loop for (k v) on (setting :audio :volume) by #'cddr
        do (setf (harmony:volume k) v)))

(defmethod initialize-instance :after ((main main) &key region)
  (when region
    (load-region region T))
  (setf (game-speed main) (setting :gameplay :game-speed)))

(defmethod update ((main main) tt dt fc)
  (let* ((scene (scene main))
         (dt (* (time-scale scene) (game-speed main) (float dt 1.0)))
         (ev (load-time-value (make-instance 'tick))))
    (when (< 0 (pause-timer scene))
      (decf (pause-timer scene) dt)
      (setf dt (* dt 0.0)))
    (let ((target (* dt 100.0))
          (source (mixed:speed-factor (harmony:segment :speed T))))
      (setf (mixed:speed-factor (harmony:segment :speed T)) (+ (* target 0.05) (* source 0.95))))
    (setf (slot-value ev 'tt) tt)
    (setf (slot-value ev 'dt) dt)
    (setf (slot-value ev 'fc) fc)
    (issue scene ev)
    (process scene)))

(defmethod (setf scene) :after (scene (main main))
  (setf +world+ scene))

(defmethod finalize :after ((main main))
  (setf +world+ NIL)
  (when harmony:*server*
    (harmony:free harmony:*server*))
  (setf harmony:*server* NIL)
  (setf +main+ NIL))

(defmethod save-state ((main main) (state (eql T)) &rest args)
  (unless (state main)
    (setf (state main) (make-instance 'save-state :filename "1")))
  (apply #'save-state main (state main) args))

(defmethod save-state ((main main) (state save-state) &rest args)
  (prog1 (apply #'save-state (scene main) state args)
    (setf (state main) state)))

(defmethod load-state ((state (eql T)) (main main))
  (cond ((state main)
         (load-state (state main) main))
        ((list-saves)
         (load-state (first (list-saves)) main))
        (T
         (load-state NIL main))))

(defmethod load-state ((state null) (main main))
  (let ((state (or (state main) (make-instance 'save-state :filename "1"))))
    (load-state (initial-state (scene main)) (scene main))
    (clear-spawns)
    (unwind-protect
         (trial:commit (scene main) (loader main) :show-screen T :cold T)
      (setf (state main) state))))

(defmethod load-state ((state save-state) (main main))
  (restart-case
      (handler-bind ((error (lambda (e)
                              (when (deploy:deployed-p)
                                (v:severe :kandria.save "Failed to load save state ~a: ~a" state e)
                                (v:debug :kandria.save e)
                                (invoke-restart 'reset)))))
        (prog1 (load-state state (scene main))
          (clear-spawns)
          #-kandria-release
          (enter (make-instance 'trial::fps-counter) (scene main))
          (unwind-protect
               (trial:commit (scene main) (loader main) :show-screen T)
            (setf (state main) state)
            (save-state main state))))
    (reset ()
      :report "Ignore the save and reset to the initial state."
      (load-state NIL main))))

(defun session-time (&optional (main +main+))
  (- (get-universal-time) (timestamp main)))

(defun total-play-time (&optional (main +main+))
  ;; FIXME: This is /not/ correct as repeat saving and loading will accrue time manyfold.
  #++
  (+ (- (get-universal-time) (timestamp main))
     (play-time (state main)))
  ;; FIXME: This is /not/ correct either as it's influenced by time dilution and dilation.
  (clock (scene main)))

(defun main ()
  (let* ((args (uiop:command-line-arguments))
         (arg (pop args)))
    (cond ((null arg)
           (launch))
          ((equal arg "config-directory")
           (format T "~&~a~%" (uiop:native-namestring (config-directory))))
          ((equal arg "controller-config")
           (gamepad::configurator-main))
          ((equal arg "system-info")
           (loop for (header . info) in (org.shirakumo.feedback.client::gather-system-info)
                 do (format T "~&~% ========== ~a ==========~%" header)
                    (write-string info)))
          ((equal arg "credits")
           (format T "~&~a~%" (alexandria:read-file-into-string
                               (merge-pathnames "CREDITS.mess" (root)))))
          ((equal arg "region")
           (if args
               (launch :region (pop args))
               (format T "~&Please pass a region file to load.~%")))
          ((equal arg "report")
           (let ((report (format NIL "~{~a~^ ~}" args)))
             (org.shirakumo.fraf.trial.feedback:submit-report
              :files NIL :description report)
             (format T "~&Report sent. Thank you!~%")))
          ((equal arg "swank")
           (let ((port (manage-swank T)))
             (format T "~&Started swank on port ~d.~%" port)
             (loop (sleep 1))))
          ((equal arg "state")
           (let ((path (if args
                           (uiop:parse-native-namestring (format NIL "~{~a~^ ~}" args))
                           (org.shirakumo.file-select:existing :title "Select save state"
                                                               :default (first (mapcar #'fil (list-saves)))
                                                               :filter '(("Save Files" "zip"))))))
             (launch :state path)))
          ((equal arg "world")
           (if args
               (let ((path (format NIL "~{~a~^ ~}" args)))
                 (launch :world path))
               "~&Please pass a world file to load.~%"))
          ((equal arg "help")
           (format T "~&Kandria v~a

Website:     https://kandria.com
Discord:     https://kandria.com/discord
Steam page:  https://kandria.com/steam
Editor Help: https://kandria.com/editor

Possible sub-commands:
  config-directory      Show the directory with config and save files.
  controller-config     Launch the controller configuration utility.
  credits               Show the game credits.
  help                  Show this help screen.
  region [region]       Load the region from the specified file.
  report [report...]    Send a feedback report.
  state [save]          Load the save from the specified file.
  swank                 Launch swank to allow debugging.
  world [world]         Load the world from the specified file.
" (version :app))))))

(defmethod render-loop :around ((main main))
  (let ((*package* #.*package*))
    (call-next-method)))

(defun launch (&rest initargs)
  (let ((*package* #.*package*))
    (load-keymap)
    (ignore-errors
     (load-settings))
    (save-settings)
    (manage-swank)
    (apply #'trial:launch 'main
           :width (first (setting :display :resolution))
           :height (second (setting :display :resolution))
           :vsync (setting :display :vsync)
           :fullscreen (setting :display :fullscreen)
           (append (setting :debugging :initargs) initargs))))

(defmethod setup-scene ((main main) (scene world))
  (enter (make-instance 'camera) scene)
  (let ((shadow (make-instance 'shadow-map-pass))
        (lighting (make-instance 'lighting-pass))
        (rendering (make-instance 'rendering-pass))
        (distortion (make-instance 'distortion-pass))
        (disp-render (make-instance 'displacement-render-pass))
        (displacement (make-instance 'displacement-pass))
        (sandstorm (make-instance 'sandstorm-pass))
        ;; This is dumb and inefficient. Ideally we'd connect the same output
        ;; to both distortion and UI and then just make the UI pass not clear
        ;; the framebuffer when drawing.
        (ui (make-instance 'ui-pass :base-scale (setting :display :ui-scale)))
        (blend (make-instance 'combine-pass)))
    (connect (port shadow 'shadow-map) (port rendering 'shadow-map) scene)
    (connect (port lighting 'color) (port rendering 'lighting) scene)
    (connect (port rendering 'color) (port displacement 'previous-pass) scene)
    (connect (port disp-render 'displacement-map) (port displacement 'displacement-map) scene)
    (connect (port displacement 'color) (port sandstorm 'previous-pass) scene)
    (connect (port sandstorm 'color) (port distortion 'previous-pass) scene)
    (connect (port distortion 'color) (port blend 'trial::a-pass) scene)
    (connect (port ui 'color) (port blend 'trial::b-pass) scene))
  (register (make-instance 'walkntalk) scene))

(defmethod load-game (state (main main))
  (hide-panel 'save-menu)
  (hide-panel 'main-menu)
  (show-panel 'load-panel :loader (loader main))
  (render main main)
  (load-state state main))

(defmethod reset ((main main))
  (let ((scene (scene main)))
    (hide-panel T)
    (setf (state main) NIL)
    (reset (unit :camera scene))
    (leave (region scene) scene)
    (setf (storyline scene) (make-instance 'quest:storyline))
    (compile-to-pass scene scene)
    (trial:commit scene (loader main))
    (discard-events scene)
    (show-panel 'main-menu)))

(defmethod setup-rendering :after ((main main))
  (disable :cull-face :scissor-test :depth-test)
  (cond ((state main)
         (load-game (state main) main))
        (T
         (show-panel 'main-menu))))

(defun apply-video-settings (&optional (settings (setting :display)))
  (when *context*
    (destructuring-bind (&key resolution fullscreen vsync ui-scale gamma &allow-other-keys) settings
      (when (and gamma (unit 'render (scene +main+)))
        (setf (monitor-gamma (unit 'render (scene +main+))) gamma))
      (show *context* :fullscreen fullscreen :mode resolution)
      (setf (vsync *context*) vsync)
      (setf (alloy:base-scale (unit 'ui-pass T)) ui-scale))))

(define-setting-observer volumes :audio :volume (value)
  (when harmony:*server*
    (loop for (k v) on value by #'cddr
          do (setf (harmony:volume k) v))))

(define-setting-observer video :display (value)
  (apply-video-settings value))

(define-setting-observer game-speed :gameplay :game-speed (value)
  (when +main+
    (setf (game-speed +main+) (float value 0f0))))

(defun manage-swank (&optional (mode (setting :debugging :swank)))
  (let ((port (or (setting :debugging :swank-port) swank::default-server-port)))
    (handler-case
        (cond (mode
               (v:info :kandria.debugging "Launching SWANK server on port ~a." port)
               (swank:create-server :port port :dont-close T)
               (setf *inhibit-standalone-error-handler* T))
              (T
               (ignore-errors (swank:stop-server port))
               (setf *inhibit-standalone-error-handler* NIL)))
      (error (e)
        (v:error :kandria.debugging "Failed to start swank: ~a" e)
        (v:debug :kandria.debugging e)))
    port))

(define-setting-observer swank :debugging :swank (value)
  (manage-swank value))

(load-quests :eng)
