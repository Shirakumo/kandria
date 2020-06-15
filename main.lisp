(in-package #:org.shirakumo.fraf.leaf)

(defclass main (#+steam org.shirakumo.fraf.trial.steam:main
                #-steam org.shirakumo.fraf.trial:main)
  ((scene :initform NIL)
   (state :accessor state)
   (quicksave :initform (make-instance 'save-state :filename "quicksave") :accessor quicksave)
   #-steam (app-id :initarg :app-id))
  (:default-initargs :clear-color (vec 2/17 2/17 2/17 0)
                     :title #.(format NIL "Kandria - ~a" (asdf:component-version (asdf:find-system "leaf")))
                     :width 1280
                     :height 720
                     :app-id 1261430))

(deploy:define-hook (:deploy leaf) (directory)
  (uiop:copy-file (asdf:system-relative-pathname :leaf "CHANGES.mess")
                  (make-pathname :name "CHANGES" :type "mess" :defaults directory))
  (uiop:copy-file (asdf:system-relative-pathname :leaf "README.mess")
                  (make-pathname :name "README" :type "mess" :defaults directory)))

(defmethod initialize-instance ((main main) &key state)
  (call-next-method)
  ;; FIXME: This won't work deployed.
  (with-packet (packet (pathname-utils:parent (base (find-pool 'leaf))) :direction :input)
    (setf (scene main) (make-instance 'world :packet packet)))
  ;; Load initial state
  (setf (state main)
        (cond (state
               (load-state state (scene main)))
              (T
               (load-state (initial-state (scene main)) (scene main))
               ;;(save-state (scene main) (quicksave main))
               (make-instance 'save-state)))))

(defmethod update ((main main) tt dt fc)
  (issue (scene main) 'tick :tt tt :dt (* (time-scale (scene main)) dt) :fc fc)
  (process (scene main)))

(defmethod setup-rendering :after ((main main))
  (disable :cull-face :scissor-test :depth-test))

(defmethod (setf scene) :after (scene (main main))
  (setf +world+ scene))

(defmethod finalize :after ((main main))
  (setf +world+ NIL))

(defmethod save-state (world (state (eql T)) &rest args)
  (apply #'save-state world (state (handler *context*)) args))

(defmethod save-state (world (state (eql :quick)) &rest args)
  (apply #'save-state world (quicksave (handler *context*)) args))

(defmethod load-state ((state (eql T)) world)
  (load-state (state (handler *context*)) world))

(defmethod load-state ((state (eql :quick)) world)
  (load-state (quicksave (handler *context*)) world))

(defun launch (&rest initargs)
  (let ((*package* #.*package*))
    (apply #'trial:launch 'main initargs)))

(defmethod paint ((controller controller) (pass shader-pass))
  (let ((editor (unit :editor T)))
    (when editor
      (setf (show-overlay controller) NIL #++(not (active-p editor)))))
  (call-next-method))

(defmethod setup-scene ((main main) scene)
  (enter (make-instance 'inactive-editor) scene)
  (enter (make-instance 'camera) scene)
  (enter (make-instance 'render-pass) scene)
  ;; (let ((shadow (make-instance 'shadow-map-pass))
  ;;       (lighting (make-instance 'lighting-pass))
  ;;       (rendering (make-instance 'rendering-pass)))
  ;;   (connect (port shadow 'shadow-map) (port rendering 'shadow-map) scene)
  ;;   (connect (port lighting 'color) (port rendering 'lighting) scene))
  )

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
