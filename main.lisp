(in-package #:org.shirakumo.fraf.leaf)

(defun new-world-packet ()
  (with-packet (packet (find-new-directory "world" (pool-path 'leaf "/")))
    packet))

(unless (find-pool 'world)
  (define-pool world
    :base :leaf))

(defclass empty-world (world)
  ()
  (:default-initargs
   :packet (new-world-packet)))

(defmethod initialize-instance :after ((world empty-world) &key)
  (let ((region (make-instance 'region :name 'base))
        (chunk (make-instance 'chunk)))
    (enter region world)
    (enter chunk region)
    (enter (make-instance 'player :location (vec 64 64)) region)))

(defclass main (org.shirakumo.fraf.trial.steam:main)
  ((scene :initform NIL)
   (state :accessor state))
  (:default-initargs :clear-color (vec 2/17 2/17 2/17 0)
                     :title "Kandria - 0.0.0"
                     :world "world"
                     :width 1280
                     :height 720
                     :app-id 1261430))

(defun world-path (world)
  (if (deploy:deployed-p)
      (pathname-utils:subdirectory (deploy:data-directory) world)
      (pathname-utils:subdirectory (asdf:system-source-directory 'leaf) world)))

(deploy:define-hook (:deploy leaf) (directory)
  (deploy:status 1 "Copying world")
  ;; FIXME: This fucking sucks man
  (reinitialize-instance (find-pool 'world) :base (pathname-utils:subdirectory (world-path "world") "data"))
  (deploy:copy-directory-tree (world-path "world") directory :copy-root T))

(defmethod initialize-instance ((main main) &key world state)
  (call-next-method)
  (setf (scene main)
        (if world
            (load-world (world-path world))
            (make-instance 'empty-world)))
  ;; Load initial state
  (setf (state main)
        (cond (state
               (load-state state (scene main)))
              (T
               (load-state (initial-state (scene main)) (scene main))
               (make-instance 'save-state)))))

(defmethod update ((main main) tt dt fc)
  (issue (scene main) 'trial:tick :tt tt :dt (* (time-scale (scene main)) dt) :fc fc)
  (process (scene main)))

(defmethod setup-rendering :after ((main main))
  (disable :cull-face :scissor-test :depth-test))

(defmethod (setf scene) :after (scene (main main))
  (setf +world+ scene))

(defmethod finalize :after ((main main))
  (setf +world+ NIL))

(defmethod save-state (world (state (eql T)) &rest args)
  (apply #'save-state world (state (handler *context*)) args))

(defmethod load-state ((state (eql T)) world)
  (load-state (state (handler *context*)) world))

(defun launch (&rest initargs)
  (apply #'trial:launch 'main initargs))

(defmethod paint ((controller controller) (pass shader-pass))
  ;;(setf (show-overlay controller) T)
  (call-next-method))

(defmethod setup-scene ((main main) scene)
  (enter (make-instance 'textbox) scene)
  (enter (make-instance 'inactive-editor) scene)
  (enter (make-instance 'camera) scene)

  (let ((shadow (make-instance 'shadow-map-pass))
        (lighting (make-instance 'lighting-pass))
        (rendering (make-instance 'rendering-pass)))
    (connect (port shadow 'shadow-map) (port rendering 'shadow-map) scene)
    (connect (port lighting 'color) (port rendering 'lighting) scene)))

#+leaf-inspector
(progn
  (sb-ext:defglobal +inspector+ NIL)
  
  (defmethod initialize-instance :after ((main main) &key)
    (setf +inspector+ (nth-value 1 (clouseau:inspect main :new-process t))))

  (defmethod finalize :after ((main main))
    (setf +world+ NIL)
    (setf +inspector+ NIL))

  (defmethod update :after ((main main) tt dt fc)
    (when (= 0 (mod fc 10))
      (let* ((pane (clim:find-pane-named +inspector+ 'clouseau::inspector))
             (state (clouseau::state pane)))
        (setf (clouseau:root-object state :run-hook-p t)
              (clouseau:root-object state))))))
