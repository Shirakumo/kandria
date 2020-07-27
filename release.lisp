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

(defun build ()
  (with-simple-restart (continue "Treat build as successful")
    (sb-ext:run-program "sbcl" (list "--eval" "(asdf:make :leaf :force T)"
                                     "--quit")
                        :search T :output T :input NIL)))

(defun deploy ()
  (let* ((source (asdf:system-source-directory "leaf"))
         (vername (format NIL "leaf-~a" (version)))
         (bindir (pathname-utils:subdirectory source "bin"))
         (reldir (pathname-utils:subdirectory source "releases"))
         (verdir (pathname-utils:subdirectory reldir vername)))
    (ensure-directories-exist reldir)
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

(defun itch (release)
  (sb-ext:run-program "butler" (list "push" (uiop:native-namestring release)
                                     (format NIL "Shinmera/kandria:~{~a~^-~}" (release-systems release))
                                     "--userversion" (version))
                      :search T :output T))

(defun humble (release))

(defun steam (release))

(defun release (&key push)
  (deploy:status 0 "Releasing ~a" (version))
  (deploy:status 1 "Deploying to release directory")
  (let ((release (deploy)))
    (deploy:status 1 "Creating bundle zip")
    (bundle release)
    (when push
      (deploy:status 1 "Uploading to itch.io")
      (itch release))
    release))
