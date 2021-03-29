(defpackage #:release
  (:use #:cl)
  (:local-nicknames
   (#:putils #:org.shirakumo.pathname-utils)
   (#:zippy #:org.shirakumo.zippy))
  (:export
   #:release
   #:build
   #:deploy
   #:bundle
   #:upload
   #:make))
(in-package #:release)

(defun run (program &rest args)
  (assert (= 0 (sb-ext:process-exit-code (sb-ext:run-program program args :search T :output *standard-output*)))))

(defun run* (program &rest args)
  (with-output-to-string (out)
    (assert (= 0 (sb-ext:process-exit-code (sb-ext:run-program program args :search T :output out))))))

(defun version ()
  (asdf:component-version (asdf:find-system "kandria")))

(defun output ()
  (pathname-utils:to-directory #.(or *compile-file-pathname* *load-pathname*)))

(defun get-pass (name)
  (ignore-errors
   (let ((candidates (cl-ppcre:split "\\n+" (run* "pass" "find" name))))
     (when (cdr candidates)
       (let* ((entry (subseq (second candidates) (length "├── ")))
              (data (run* "pass" "show" entry)))
         (first (cl-ppcre:split "\\n+" data)))))))

(defun query-pass ()
  (format *query-io* "~&Enter Steam password:~%> ")
  (read-line *query-io*))

(defun file-replace (in out replacements)
  (let ((content (alexandria:read-file-into-string in)))
    (loop for (search replace) in replacements
          do (setf content (cl-ppcre:regex-replace-all search content replace)))
    (alexandria:write-string-into-file content out :if-exists :supersede)))

(defmethod build :around (target)
  (with-simple-restart (continue "Treat build as successful")
    (call-next-method)))

(defvar *sbcl-build-args* '("--dynamic-space-size" "4096"
                            "--eval" "(push :kandria-release *features*)"
                            "--eval" "(push :trial-optimize-all *features*)"
                            "--eval" "(push :cl-opengl-no-masked-traps *features*)"
                            "--eval" "(push :cl-opengl-no-check-error *features*)"
                            "--eval" "(asdf:make :kandria :force T)" "--disable-debugger" "--quit"))

(defmethod build ((target (eql :linux)))
  (apply #'run "sbcl-lin" *sbcl-build-args*))

(defmethod build ((target (eql :windows)))
  (apply #'run "sbcl-win" *sbcl-build-args*))

(defmethod build ((target (eql :macos)))
  (apply #'run "sbcl-mac" *sbcl-build-args*))

(defmethod build ((target (eql T)))
  (build :linux)
  (build :windows))

(defmethod build ((target null)))

(defun release ()
  (pathname-utils:subdirectory (output) (format NIL "kandria-~a" (version))))

(defun deploy ()
  (let* ((release (release))
         (bindir (pathname-utils:subdirectory (asdf:system-source-directory "kandria") "bin")))
    (ensure-directories-exist release)
    (deploy:copy-directory-tree bindir release :copy-root NIL)
    (uiop:delete-file-if-exists (merge-pathnames "trial.log" release))
    release))

(defun bundle (release)
  (let ((bundle (make-pathname :name (pathname-utils:directory-name release) :type "zip"
                               :defaults (pathname-utils:parent release))))
    (zippy:compress-zip release bundle :if-exists :supersede)
    bundle))

(defun release-systems (release)
  (let ((systems ()))
    (when (probe-file (make-pathname :name "kandria-linux" :type "run" :defaults release))
      (push "linux" systems))
    (when (probe-file (make-pathname :name "kandria-macos" :defaults release))
      (push "mac" systems))
    (when (probe-file (make-pathname :name "kandria-windows" :type "exe" :defaults release))
      (push "windows" systems))
    systems))

(defmethod upload ((service (eql :itch)) &key (release (release)) &allow-other-keys)
  (run "butler" "push" (uiop:native-namestring release)
       (format NIL "Shinmera/kandria:~{~a~^-~}" (release-systems release))
       "--userversion" (version)))

(defmethod upload ((service (eql :steam)) &key (release (release)) (branch "developer") preview (user "shirakumo_org") password &allow-other-keys)
  (let ((template (make-pathname :name "app-build" :type "vdf" :defaults (output)))
        (build (make-pathname :name "app-build" :type "vdf" :defaults release)))
    (file-replace template build `(("\\$CONTENT" ,(uiop:native-namestring release))
                                   ("\\$BRANCH" ,(or branch ""))
                                   ("\\$PREVIEW" ,(if preview "1" "0"))))
    (run "steamcmd.sh" "+login" user (or password (get-pass user) (query-pass)) "+run_app_build" (uiop:native-namestring build) "+quit")))

(defmethod upload ((service (eql T)) &rest args &key &allow-other-keys)
  (dolist (service '(:itch :steam))
    (apply #'upload service args)))

(defun make (&key (build T) (upload :steam))
  (deploy:status 0 "Building ~a" (version))
  (build build)
  (deploy:status 1 "Deploying to release directory")
  (let ((release (deploy)))
    (deploy:status 1 "Creating bundle zip")
    (bundle release)
    (when upload
      (deploy:status 1 "Uploading")
      (upload upload :release release))
    release))
