(in-package #:org.shirakumo.fraf.leaf)

(defclass main (#-darwin org.shirakumo.fraf.trial.steam:main
                #+darwin org.shirakumo.fraf.trial:main)
  ((scene :initform NIL)
   (state :accessor state)
   (quicksave :initform (make-instance 'save-state :filename "quicksave") :accessor quicksave))
  (:default-initargs
   :clear-color (vec 2/17 2/17 2/17 0)
   :title #.(format NIL "Kandria - ~a" (version :kandria))
   :app-id 1261430))

(deploy:define-hook (:deploy leaf -1) (directory)
  (let ((root (root)))
    (labels ((prune (file)
               (cond ((listp file)
                      (mapc #'prune file))
                     ((wild-pathname-p file)
                      (prune (directory file)))
                     ((pathname-utils:directory-p file)
                      (uiop:delete-directory-tree file :validate (constantly T) :if-does-not-exist :ignore))
                     (T
                      (delete-file file))))
             (copy-file (file)
               (uiop:copy-file (merge-pathnames file root)
                               (merge-pathnames file directory))))
      (copy-file "CHANGES.mess")
      (copy-file "README.mess")
      (copy-file "keymap.lisp")
      (deploy:copy-directory-tree (pathname-utils:subdirectory root "world") directory)
      (deploy:status 1 "Pruning assets")
      ;; Prune undesired assets. This sucks, an automated, declarative way would be much better.
      (prune (pathname-utils:subdirectory directory "pool" "EFFECTS"))
      (prune (pathname-utils:subdirectory directory "pool" "WORKBENCH"))
      (prune (pathname-utils:subdirectory directory "pool" "TRIAL" "nissi-beach"))
      (prune (pathname-utils:subdirectory directory "pool" "TRIAL" "masko-naive"))
      (prune (make-pathname :name :wild :type "png" :defaults (pathname-utils:subdirectory directory "pool" "TRIAL")))
      (prune (make-pathname :name :wild :type "svg" :defaults (pathname-utils:subdirectory directory "pool" "TRIAL")))
      (prune (make-pathname :name :wild :type "jpg" :defaults (pathname-utils:subdirectory directory "pool" "TRIAL")))
      (prune (make-pathname :name :wild :type "frag" :defaults (pathname-utils:subdirectory directory "pool" "TRIAL")))
      (prune (make-pathname :name :wild :type "ase" :defaults (pathname-utils:subdirectory directory "pool" "LEAF"))))))

(defmethod initialize-instance ((main main) &key state app-id)
  (declare (ignore app-id))
  (call-next-method)
  (with-packet (packet (pathname-utils:subdirectory (root) "world") :direction :input)
    (setf (scene main) (make-instance 'world :packet packet)))
  (load-mapping (merge-pathnames "keymap.lisp" (root)))
  (harmony:start (harmony:make-simple-server :name "Kandria" :latency (setting :audio :latency)))
  (loop for (k v) on (setting :audio :volume) by #'cddr
        do (setf (harmony:volume k) v))
  ;; Load initial state
  (setf (state main)
        (cond (state
               (load-state state (scene main)))
              (T
               (load-state (initial-state (scene main)) (scene main))
               (save-state (scene main) (quicksave main))
               (make-instance 'save-state)))))

(defmethod update ((main main) tt dt fc)
  (issue (scene main) 'tick :tt tt :dt (* (time-scale (scene main)) (float dt 1.0)) :fc fc)
  (process (scene main)))

(defmethod setup-rendering :after ((main main))
  (disable :cull-face :scissor-test :depth-test))

(defmethod (setf scene) :after (scene (main main))
  (setf +world+ scene))

(defmethod finalize :after ((main main))
  (setf +world+ NIL)
  (harmony:free harmony:*server*))

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
    (v:info :kandria "Launching version ~a" (version :kandria))
    (apply #'trial:launch 'main
           :width (setting :display :width)
           :height (setting :display :height)
           :vsync (setting :display :vsync)
           ;;:fullscreen (setting :display :fullscreen)
           initargs)))

(defmethod render :before ((controller controller) program)
  (let ((editor (unit :editor T)))
    (when editor
      (setf (show-overlay controller) (and (not (deploy:deployed-p))
                                           (not (active-p editor)))))))

(defmethod setup-scene ((main main) scene)
  (flet ((observe (func)
           (observe! (funcall func (unit 'player scene)) :title func)))
    (observe 'location)
    (observe 'velocity)
    (observe 'state)
    (observe 'name)
    (observe 'climb-strength)
    (observe 'jump-time)
    (observe 'air-time))
  
  (enter (make-instance 'fade) scene)
  (enter (make-instance 'inactive-editor) scene)
  (enter (make-instance 'camera) scene)
  (let ((shadow (make-instance 'shadow-map-pass))
        (lighting (make-instance 'lighting-pass))
        (rendering (make-instance 'rendering-pass))
        (distortion (make-instance 'distortion-pass))
        ;; This is dumb and inefficient. Ideally we'd connect the same output
        ;; to both distortion and UI and then just make the UI pass not clear
        ;; the framebuffer when drawing.
        (ui (make-instance 'ui-pass))
        (blend (make-instance 'blend-pass)))
    (connect (port shadow 'shadow-map) (port rendering 'shadow-map) scene)
    (connect (port lighting 'color) (port rendering 'lighting) scene)
    (connect (port rendering 'color) (port distortion 'previous-pass) scene)
    (connect (port distortion 'color) (port blend 'trial::a-pass) scene)
    (connect (port ui 'color) (port blend 'trial::b-pass) scene)))
