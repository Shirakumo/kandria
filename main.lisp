(in-package #:org.shirakumo.fraf.kandria)

(defclass main (org.shirakumo.fraf.trial.steam:main
                org.shirakumo.fraf.trial.notify:main)
  ((scene :initform NIL)
   (state :accessor state)
   (quicksave :initform (make-instance 'quicksave :play-time 0) :accessor quicksave)
   (timestamp :initform (get-universal-time) :accessor timestamp)
   (org.shirakumo.fraf.trial.steam:use-steaminput :initform NIL))
  (:default-initargs
   :clear-color (vec 2/17 2/17 2/17 0)
   :version '(3 3) :profile :core
   :title #.(format NIL "Kandria - ~a" (version :kandria))
   :app-id 1261430))

(defmethod initialize-instance ((main main) &key state app-id)
  (declare (ignore app-id))
  (setf +main+ main)
  (call-next-method)
  (setf +input-source+ :keyboard)
  (with-packet (packet (pathname-utils:subdirectory (root) "world") :direction :input)
    (setf (scene main) (make-instance 'world :packet packet)))
  ;; FIXME: Allow running without sound.
  (harmony:start (harmony:make-simple-server :name "Kandria" :latency (setting :audio :latency)
                                             :effects `((mixed:frequency-pass :cutoff 500 :bypass T :name low-pass))))
  (loop for (k v) on (setting :audio :volume) by #'cddr
        do (setf (harmony:volume k) v))
  ;; Load initial state
  (cond (state
         (load-state state main))
        (T
         (load-state (initial-state (scene main)) main)
         (save-state main (quicksave main))
         (make-instance 'save-state))))

(defmethod update ((main main) tt dt fc)
  (issue (scene main) 'tick :tt tt :dt (* (time-scale (scene main)) (float dt 1.0)) :fc fc)
  (process (scene main)))

(defmethod setup-rendering :after ((main main))
  (disable :cull-face :scissor-test :depth-test))

(defmethod (setf scene) :after (scene (main main))
  (setf +world+ scene))

(defmethod finalize :after ((main main))
  (setf +world+ NIL)
  (harmony:free harmony:*server*)
  (setf harmony:*server* NIL)
  (setf +main+ NIL))

(defmethod save-state ((main main) (state (eql T)) &rest args)
  (apply #'save-state main (make-instance 'save-state) args))

(defmethod save-state ((main main) (state (eql :quick)) &rest args)
  (apply #'save-state main (quicksave main) args))

(defmethod save-state ((main main) (state save-state) &rest args)
  (prog1 (apply #'save-state (scene main) state args)
    (unless (typep state 'quicksave)
      (setf (state main) state))))

(defmethod load-state ((state (eql T)) (main main))
  (load-state (state main) (scene main)))

(defmethod load-state ((state (eql :quick)) (main main))
  (load-state (quicksave main) (scene main)))

(defmethod load-state ((state save-state) (main main))
  (prog1 (load-state state (scene main))
    (unless (typep state 'quicksave)
      (setf (state main) state))))

(defun session-time (&optional (main +main+))
  (- (get-universal-time) (timestamp main)))

(defun total-play-time (&optional (main +main+))
  ;; FIXME: This is /not/ correct as repeat saving and loading will accrue time manyfold.
  #++
  (+ (- (get-universal-time) (timestamp main))
     (play-time (state main)))
  ;; FIXME: This is /not/ correct either as it's influenced by time dilution and dilation.
  (clock (scene main)))

(defun launch (&rest initargs)
  (labels ((recurse (class)
             (c2mop:finalize-inheritance class)
             (dolist (sub (c2mop:class-direct-subclasses class))
               (recurse sub))))
    (recurse (find-class 'shader-entity)))
  (flet ((launch ()
           (let ((*package* #.*package*))
             (v:info :kandria "Launching version ~a" (version :kandria))
             (load-keymap)
             (load-settings)
             (save-settings)
             (apply #'trial:launch 'main
                    :width (first (setting :display :resolution))
                    :height (second (setting :display :resolution))
                    :vsync (setting :display :vsync)
                    :fullscreen (setting :display :fullscreen)
                    initargs))))
    (if (deploy:deployed-p)
        (float-features:with-float-traps-masked T
          (launch))
        (launch))))

(defmethod setup-scene ((main main) scene)
  (enter (make-instance 'fade) scene)
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
        (blend (make-instance 'blend-pass :name 'blend)))
    (connect (port shadow 'shadow-map) (port rendering 'shadow-map) scene)
    (connect (port lighting 'color) (port rendering 'lighting) scene)
    (connect (port rendering 'color) (port displacement 'previous-pass) scene)
    (connect (port disp-render 'displacement-map) (port displacement 'displacement-map) scene)
    (connect (port displacement 'color) (port sandstorm 'previous-pass) scene)
    (connect (port sandstorm 'color) (port distortion 'previous-pass) scene)
    (connect (port distortion 'color) (port blend 'trial::a-pass) scene)
    (connect (port ui 'color) (port blend 'trial::b-pass) scene))
  (register (make-instance 'walkntalk) scene)
  (show (make-instance 'status-lines))
  #++
  (show (make-instance 'report-button)))

(defmethod change-scene :after ((main main) scene &key)
  (let ((region (region scene)))
    (setf (chunk-graph region) (make-chunk-graph region))))

(defun apply-video-settings ()
  (destructuring-bind (&key resolution fullscreen vsync ui-scale) (setting :display)
    (resize *context* (first resolution) (second resolution))
    (show *context* :fullscreen fullscreen)
    (setf (vsync *context*) vsync)
    (setf (alloy:base-scale (unit 'ui-pass T)) ui-scale)))

(define-setting-observer volumes :audio :volume (value)
  (when harmony:*server*
    (loop for (k v) on value by #'cddr
          do (setf (harmony:volume k) v))))

