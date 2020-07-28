(defpackage #:release
  (:use #:cl)
  (:local-nicknames
   (#:putils #:org.shirakumo.pathname-utils)
   (#:zippy #:org.shirakumo.zippy))
  (:export
   #:deploy
   #:bundle
   #:release))
(in-package #:release)

(defun version ()
  (asdf:component-version (asdf:find-system "leaf")))

(defun output ()
  (pathname-utils:to-directory #.(or *compile-file-pathname* *load-pathname*)))

(defun query-pass ()
  (format *query-io* "~&Enter Steam password:~%> ")
  (read-line *query-io*))

(defun file-replace (in out replacements)
  (let ((content (alexandria:read-file-into-string in)))
    (loop for (search replace) in replacements
          do (setf content (cl-ppcre:regex-replace-all search content replace)))
    (alexandria:write-string-into-file content out :if-exists :supersede)))

(defun build ()
  (with-simple-restart (continue "Treat build as successful")
    (sb-ext:run-program "sbcl" (list "--eval" "(asdf:make :leaf :force T)"
                                     "--quit")
                        :search T :output *standard-output*)))

(defun deploy ()
  (let* ((vername (format NIL "leaf-~a" (version)))
         (bindir (pathname-utils:subdirectory (asdf:system-source-directory "leaf") "bin"))
         (verdir (pathname-utils:subdirectory (output) vername)))
    (ensure-directories-exist verdir)
    (deploy:copy-directory-tree bindir verdir :copy-root NIL)
    (uiop:delete-file-if-exists (merge-pathnames "trial.log" verdir))
    verdir))

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

(defun itch (release &key &allow-other-keys)
  (sb-ext:run-program "butler" (list "push" (uiop:native-namestring release)
                                     (format NIL "Shinmera/kandria:~{~a~^-~}" (release-systems release))
                                     "--userversion" (version))
                      :search T :output *standard-output*))

(defun steam (release &key (branch "developer") (preview T) password &allow-other-keys)
  (let ((template (make-pathname :name "app-build" :type "vdf" :defaults (output)))
        (build (make-pathname :name "app-build" :type "vdf" :defaults release)))
    (file-replace template build `(("\\$CONTENT" ,(uiop:native-namestring release))
                                   ("\\$BRANCH" ,(or branch ""))
                                   ("\\$PREVIEW" ,(if preview "1" "0"))))
    (sb-ext:run-program "steamcmd.sh" (list "+login" "shinmera" (or password (query-pass)) "+run_app_build" (uiop:native-namestring build) "+quit")
                        :search T :output *standard-output*)))

(defun upload (release &rest args &key (services T))
  (case services ((T :itch) (apply #'itch release args)))
  (case services ((T :steam) (apply #'steam release args))))

(defun release (&key upload)
  (deploy:status 0 "Releasing ~a" (version))
  (deploy:status 1 "Deploying to release directory")
  (let ((release (deploy)))
    (deploy:status 1 "Creating bundle zip")
    (bundle release)
    (when upload
      (deploy:status 1 "Uploading")
      (upload release :services upload))
    release))
