(in-package #:org.shirakumo.fraf.kandria)

#+trial-steam
(defclass main-steam (org.shirakumo.fraf.trial.steam:main)
  () (:default-initargs :steam '(:app-id 1261430)))

#+trial-gog
(defclass main-gog (org.shirakumo.fraf.trial.gog:main)
  () (:default-initargs :gog '(:client-id "57241758991992155"
                               :client-secret "bc8667469838f79aea8a14936dc669d63c094f67069a38bee22d984ebeba8657")))

(defclass main (#+trial-gog main-gog
                #+trial-steam main-steam
                #+trial-notify org.shirakumo.fraf.trial.notify:main
                org.shirakumo.fraf.trial.harmony:settings-main
                org.shirakumo.fraf.trial:task-runner-main)
  ((scene :initform NIL)
   (state :initform NIL :accessor state)
   (timestamp :initform (get-universal-time) :accessor timestamp)
   (loader :initform (make-instance 'load-screen))
   (game-speed :initform 1.0 :accessor game-speed)
   (changes-saved-p :initform T :accessor changes-saved-p))
  (:default-initargs
   :context '(:version (3 3) :profile :core :title "Kandria")))

(defmethod initialize-instance ((main main) &key app-id world state)
  (declare (ignore app-id))
  (call-next-method)
  (let ((depot (if world
                   (depot:ensure-depot world)
                   (find-world)))
        (initargs ()))
    (when (typep depot 'org.shirakumo.depot.zip:zip-archive)
      (org.shirakumo.zippy:move-in-memory depot))
    ;; KLUDGE: this sucks. Spillage from version protocol to prefetch...
    (when (depot:entry-exists-p "meta.lisp" depot)
      (setf initargs (second (parse-sexps (depot:read-from (depot:entry "meta.lisp" depot) 'character)))))
    (setf (scene main) (apply #'make-instance 'world :depot depot initargs)))
  (when (and world (null state))
    (setf state :new))
  (etypecase state
    (save-state
     (setf (state main) state))
    ((or pathname string)
     (setf (state main) (minimal-load-state (merge-pathnames state (save-state-path "1")))))
    ((eql T)
     (setf (state main) (first (list-saves))))
    ((eql :new)
     (setf (state main) :new))
    (null)))

(defmethod trial-harmony:server-initargs append ((main main))
  (list :mixers '((:music mixed:basic-mixer :effects ((mixed:biquad-filter :filter :lowpass :name :music-lowpass)))
                  (:effect mixed:plane-mixer))
        :effects '((mixed:biquad-filter :filter :lowpass :name :lowpass)
                   (mixed:speed-change :name :speed))))

(defmethod initialize-instance :after ((main main) &key)
  (setf (mixed:min-distance harmony:*server*) (* +tile-size+ 5))
  (setf (mixed:max-distance harmony:*server*) (* +tile-size+ (vx +tiles-in-view+)))
  (setf (game-speed main) (setting :gameplay :game-speed))
  (load-achievement-data T)
  (with-eval-in-task-thread ()
    (handler-bind (#+kandria-release (module-registration-failed #'continue))
      (register-module T))
    (register-module :remote)
    (unless (setting :debugging :dont-load-mods)
      (load-active-module-list))))

(defmethod update ((main main) tt dt fc)
  (let* ((scene (scene main))
         (dt (* (time-scale scene) (game-speed main) (float dt 1.0))))
    (let ((target (expt 2 (/ (log (max 0.1 (* dt 100.0)) 2) 3)))
          (source (mixed:speed-factor (harmony:segment :speed T))))
      (setf (mixed:speed-factor (harmony:segment :speed T)) (+ (* target 0.05) (* source 0.95))))
    (when (< 0 (pause-timer scene))
      (decf (pause-timer scene) dt)
      (setf dt (* dt 0.1)))
    (issue scene 'pre-tick :tt tt :dt dt :fc fc)
    (issue scene 'tick :tt tt :dt dt :fc fc)
    (issue scene 'post-tick :tt tt :dt dt :fc fc)
    (process scene)))

(defmethod (setf scene) :after (scene (main main))
  (setf +world+ scene))

(defmethod finalize :after ((main main))
  (clear +editor-history+)
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
    (clear +editor-history+)
    (setf (changes-saved-p main) T)
    (load-state (initial-state (scene main)) (scene main))
    (unwind-protect
         (trial:commit (scene main) (loader main) :show-screen T :cold T)
      (setf (state main) state))))

(defmethod load-state ((state save-state) (main main))
  (restart-case
      (handler-bind ((save-file-outdated (lambda (e)
                                           (invoke-restart 'migrate (version e))))
                     (error (lambda (e)
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
  (when (and main (scene main))
    (clock (scene main))))

(define-command-line-command credits ()
  :help "Print the game credits"
  (format T "~&~a~%" (alexandria:read-file-into-string
                      (merge-pathnames "CREDITS.mess" (data-root)))))

(define-command-line-command region ((region "The name of the region to load"))
  :help "Launch to a particular game region"
  (launch :region region))

(define-command-line-command world ((path "The path to the world file to load"))
  :help "Launch another game world from a file"
  (launch :world path))

(define-command-line-command state (&optional (path NIL "The path to the save state to load"))
  :help "Load directly into a particular save state"
  (let ((path (or path (org.shirakumo.file-select:existing :title "Select save state"
                                                           :default (first (mapcar #'file (list-saves)))
                                                           :filter '(("Save Files" "zip"))))))
    (launch :state path)))

(define-command-line-command swank (&optional (port NIL "The port to start swank on. Defaults to 4005"))
  :help "Start SWANK and wait"
  (let ((port (manage-swank T port)))
    (format T "~&Started swank on port ~d.~%" port)
    (loop (sleep 1))))

(define-command-line-command trial::copyright ()
  :help "Display copyright information"
  (format T "~&Kandria v~a

Website:     https://kandria.com
Discord:     https://kandria.com/discord
Steam page:  https://kandria.com/steam
Editor Help: https://kandria.com/editor
Support:     mailto:shirakumo@tymoon.eu

© ~d ~a, all rights reserved"
          (version :app) #.(nth-value 5 (get-decoded-time)) +app-vendor+))

(defun main ()
  (command-line-toplevel)
  (launch))

(defmethod render-loop :around ((main main))
  (let ((*package* #.*package*))
    (call-next-method)))

(defun launch (&rest initargs)
  (let ((*package* #.*package*))
    (default-startup-load)
    (manage-swank)
    (apply #'trial:launch 'main
           (append (setting :debugging :initargs)
                   initargs
                   (list :context (list :width (first (setting :display :resolution))
                                        :height (second (setting :display :resolution))
                                        :vsync (setting :display :vsync)
                                        :fullscreen (if (setting :display :fullscreen)
                                                        (setting :display :monitor))
                                        :title "Kandria"
                                        :version '(3 3)
                                        :profile :core))))))

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
       (loop for panel in (panels (node 'ui-pass scene))
             do (unless (typep panel '(or prerelease-notice hud))
                  (hide panel)
                  (go retry)))))
  (show-panel 'load-panel :loader (loader main))
  (render main main)
  (load-state state main)
  (refresh-language T))

(defmethod reset ((main main))
  (let ((scene (scene main)))
    (let ((els ()))
      (alloy:do-elements (el (alloy:popups (alloy:layout-tree (node 'ui-pass +world+))))
        (when (typep el 'popup)
          (push el els)))
      (mapc #'hide els))
    (hide-panel '(not prerelease-notice))
    (setf (state main) NIL)
    (reset (camera scene))
    (leave (region scene) scene)
    (setf (strength (node 'sandstorm scene)) 0.0)
    (setf (strength (node 'distortion scene)) 0.0)
    (setf (storyline scene) (make-instance 'storyline))
    (setf (changes-saved-p main) T)
    (trial:commit scene (loader main))
    (clear-retained)
    (let ((depot (find-world)))
      (setf (depot (scene main)) depot))
    (show-panel 'main-menu)))

(defmacro with-saved-changes-prompt (&body body)
  `(flet ((thunk ()
            ,@body))
     (if (changes-saved-p +main+)
         (thunk)
         (promise:-> (prompt (@ error-unsaved-changes))
           (:then () (thunk))))))

(defmethod handle ((ev window-close) (main main))
  (with-saved-changes-prompt (quit (context main))))

(defmethod setup-rendering :after ((main main))
  (disable-feature :cull-face :scissor-test :depth-test)
  (etypecase (state main)
    (save-state (load-game (state main) main))
    ((eql :new) (setf (state main) (make-instance 'save-state :filename "new")) (load-game NIL main))
    (null (if (setting :debugging :show-startup-screen)
              (show-panel 'startup-screen)
              (show-panel 'main-menu)))))

(define-setting-observer video-misc :display (value)
  (when *context*
    (destructuring-bind (&key ui-scale gamma &allow-other-keys) value
      (with-eval-in-render-loop (+world+)
        (invoke-restart 'trial::reset-render-loop))
      (when (and gamma (node 'render (scene +main+)))
        (setf (monitor-gamma (node 'render (scene +main+))) gamma)
        (setf (alloy:base-scale (node 'ui-pass T)) ui-scale)))))

(define-setting-observer game-speed :gameplay :game-speed (value)
  (when +main+
    (setf (game-speed +main+) (float value 0f0))))

(defun manage-swank (&optional (mode (setting :debugging :swank)) port)
  #+swank
  (let ((port (or port (setting :debugging :swank-port) swank::default-server-port)))
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
