(in-package #:org.shirakumo.fraf.kandria)

(defclass main (org.shirakumo.fraf.trial.steam:main
                #-kandria-release org.shirakumo.fraf.trial.notify:main
                org.shirakumo.fraf.trial.harmony:settings-main)
  ((scene :initform NIL)
   (state :initform NIL :accessor state)
   (timestamp :initform (get-universal-time) :accessor timestamp)
   (loader :initform (make-instance 'load-screen))
   (org.shirakumo.fraf.trial.steam:use-steaminput :initform NIL)
   (game-speed :initform 1.0 :accessor game-speed))
  (:default-initargs
   :clear-color (vec 2/17 2/17 2/17 0)
   :context '(:version (3 3) :profile :core :title "Kandria")
   :app-id
   #-kandria-demo 1261430
   #+kandria-demo 1918910))

(defmethod initialize-instance ((main main) &key app-id world state)
  (declare (ignore app-id))
  (call-next-method)
  (etypecase state
    (null)
    (save-state
     (setf (state main) state))
    ((or pathname string)
     (setf (state main) (minimal-load-state (merge-pathnames state (save-state-path "1")))))
    ((eql T)
     (setf (state main) (first (list-saves)))))
  (let ((depot (if world
                   (depot:ensure-depot world)
                   (find-world))))
    (when (typep depot 'org.shirakumo.zippy:zip-file)
      (org.shirakumo.zippy:move-in-memory depot))
    (setf (scene main) (make-instance 'world :depot depot))))

(defmethod trial-harmony:server-initargs append ((main main))
  (list :mixers '((:music mixed:basic-mixer :effects ((mixed:biquad-filter :filter :lowpass :name :music-lowpass)))
                  (:effect mixed:plane-mixer))
        :effects '((mixed:biquad-filter :filter :lowpass :name :lowpass)
                   (mixed:speed-change :name :speed))))

(defmethod initialize-instance :after ((main main) &key region)
  (setf (mixed:min-distance harmony:*server*) (* +tile-size+ 5))
  (setf (mixed:max-distance harmony:*server*) (* +tile-size+ (vx +tiles-in-view+)))
  (setf (game-speed main) (setting :gameplay :game-speed))
  (load-achievement-data T)
  (when region
    (load-region region T)))

(defmethod update ((main main) tt dt fc)
  (promise:tick-all dt)
  (let* ((scene (scene main))
         (dt (* (time-scale scene) (game-speed main) (float dt 1.0)))
         (ev (load-time-value (allocate-instance (find-class 'tick)))))
    (let ((target (expt 2 (/ (log (max 0.1 (* dt 100.0)) 2) 3)))
          (source (mixed:speed-factor (harmony:segment :speed T))))
      (setf (mixed:speed-factor (harmony:segment :speed T)) (+ (* target 0.05) (* source 0.95))))
    (when (< 0 (pause-timer scene))
      (decf (pause-timer scene) dt)
      (setf dt (* dt 0.1)))
    (setf (slot-value ev 'tt) tt)
    (setf (slot-value ev 'dt) dt)
    (setf (slot-value ev 'fc) fc)
    (issue scene ev)
    (process scene)))

(defmethod (setf scene) :after (scene (main main))
  (setf +world+ scene))

(defmethod finalize :after ((main main))
  (setf +world+ NIL))

(defmethod save-state ((main main) (state (eql T)) &rest args)
  (apply #'save-state main (or (state main) (make-instance 'save-state :filename "1")) args))

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
    (clear-spawns)
    (load-state (initial-state (scene main)) (scene main))
    (unwind-protect
         (trial:commit (scene main) (loader main) :show-screen T :cold T)
      (setf (state main) state))))

(defmethod load-state ((state save-state) (main main))
  (restart-case
      (handler-bind ((error (lambda (e)
                              (when (deploy:deployed-p)
                                (v:severe :kandria.save "Failed to load save state ~a: ~a" state e)
                                (v:debug :kandria.save e)
                                #++
                                (invoke-restart 'reset)))))
        (clear-spawns)
        (prog1 (load-state state (scene main))
          (unwind-protect
               (trial:commit (scene main) (loader main) :show-screen T)
            (setf (state main) state)
            #++
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
                               (merge-pathnames "CREDITS.mess" (data-root)))))
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
                                                               :default (first (mapcar #'file (list-saves)))
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
           (append (setting :debugging :initargs)
                   initargs
                   (list :context (list :width (first (setting :display :resolution))
                                        :height (second (setting :display :resolution))
                                        :vsync (setting :display :vsync)
                                        :fullscreen (setting :display :fullscreen)
                                        :title "Kandria"
                                        :version '(3 3)
                                        :profile :core)
                         :audio-backend (setting :audio :backend))))))

(defmethod setup-scene ((main main) (scene world))
  (enter (camera scene) scene)
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
  (when (setting :debugging :fps-counter)
    (enter (make-instance 'trial:fps-counter) (scene main)))
  (register (make-instance 'walkntalk) scene))

(defmethod load-game (state (main main))
  (let ((scene (scene main)))
    (setf (action-lists scene) ())
    (tagbody retry
       (loop for panel in (panels (unit 'ui-pass scene))
             do (unless (typep panel '(or prerelease-notice hud))
                  (hide panel)
                  (go retry)))))
  (show-panel 'load-panel :loader (loader main))
  (render main main)
  (refresh-language T)
  (load-state state main))

(defmethod reset ((main main))
  (let ((scene (scene main)))
    (let ((els ()))
      (alloy:do-elements (el (alloy:popups (alloy:layout-tree (unit 'ui-pass +world+))))
        (when (typep el 'popup)
          (push el els)))
      (mapc #'hide els))
    (hide-panel '(not prerelease-notice))
    (setf (state main) NIL)
    (reset (camera scene))
    (leave (region scene) scene)
    (setf (strength (unit 'sandstorm scene)) 0.0)
    (setf (strength (unit 'distortion scene)) 0.0)
    (setf (storyline scene) (make-instance 'quest:storyline))
    (trial:commit scene (loader main))
    (discard-events scene)
    (clear-retained)
    (show-panel 'main-menu)))

(defmethod setup-rendering :after ((main main))
  (disable :cull-face :scissor-test :depth-test)
  (cond ((state main)
         (load-game (state main) main))
        (T
         (show-panel 'startup-screen))))

(define-setting-observer video-misc :display (value)
  (when *context*
    (destructuring-bind (&key ui-scale gamma &allow-other-keys) value
      (with-eval-in-render-loop (+world+)
        (invoke-restart 'trial::reset-render-loop))
      (when (and gamma (unit 'render (scene +main+)))
        (setf (monitor-gamma (unit 'render (scene +main+))) gamma)
        (setf (alloy:base-scale (unit 'ui-pass T)) ui-scale)))))

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
