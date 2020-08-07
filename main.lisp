(in-package #:org.shirakumo.fraf.leaf)

(defun root ()
  (if (deploy:deployed-p)
      (deploy:runtime-directory)
      (pathname-utils:to-directory #.(or *compile-file-pathname* *load-pathname*))))

(defclass main (#-darwin org.shirakumo.fraf.trial.steam:main
                #+darwin org.shirakumo.fraf.trial:main)
  ((scene :initform NIL)
   (state :accessor state)
   (quicksave :initform (make-instance 'save-state :filename "quicksave") :accessor quicksave))
  (:default-initargs :clear-color (vec 2/17 2/17 2/17 0)
                     :title #.(format NIL "Kandria - ~a" (asdf:component-version (asdf:find-system "leaf")))
                     :width 1280
                     :height 720
                     :app-id 1261430))

(deploy:define-hook (:deploy leaf -1) (directory)
  (let ((root (root)))
    (labels ((prune (file)
               (cond ((listp file)
                      (mapc #'prune file))
                     ((wild-pathname-p file)
                      (prune (directory file)))
                     ((pathname-utils:directory-p file)
                      (uiop:delete-directory-tree file :validate (constantly T)))
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

(defmethod render :before ((controller controller) program)
  (let ((editor (unit :editor T)))
    (when editor
      (setf (show-overlay controller) (and (not (deploy:deployed-p))
                                           (not (active-p editor)))))))

(defmethod setup-scene ((main main) scene)
  (observe! (location (unit 'player scene)) :title :loc)
  (observe! (velocity (unit 'player scene)) :title :vel)
  (observe! (collisions (unit 'player scene)) :title :col)
  (observe! (state (unit 'player scene)) :title :state)
  (observe! (name (animation (unit 'player scene))) :title :anim)
  (observe! (multiplier (frame (unit 'player scene))) :title :mult)
  (observe! (climb-strength (unit 'player scene)) :title :climb)
  
  (enter (make-instance 'sweep) scene)
  (enter (make-instance 'inactive-editor) scene)
  (enter (make-instance 'camera) scene)
  (let ((shadow (make-instance 'shadow-map-pass))
        (lighting (make-instance 'lighting-pass))
        (rendering (make-instance 'rendering-pass)))
    (connect (port shadow 'shadow-map) (port rendering 'shadow-map) scene)
    (connect (port lighting 'color) (port rendering 'lighting) scene)))
