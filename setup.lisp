#|
exec sbcl --dynamic-space-size 4GB --noinform --no-sysinit --no-userinit --load "$0"
|#

(in-package #:cl-user)

(defvar *kandria-root* #.(make-pathname :type NIL :name NIL :defaults (or *load-pathname* (error "This file must be LOADed."))))
(defvar *kandria-install-root* NIL)

(unless (find-package '#:asdf)
  (require :asdf))

(cond ((probe-file (merge-pathnames "install/" *kandria-root*))
       (setf *kandria-install-root* (merge-pathnames "install/" *kandria-root*)))
      ((probe-file (merge-pathnames ".install" *kandria-root*))
       (let ((path (string-trim '(#\Linefeed #\Return #\Space) (uiop:read-file-string (merge-pathnames ".install" *kandria-root*)))))
         (setf *kandria-install-root* (uiop:parse-native-namestring path :ensure-directory T))))
      (T
       (error
"Kandria install root is not configured!

Please create a file called .install within the source directory which
contains the path to your full Kandria game installation and then try
again.")))

;;; Load quicklisp
(unless (find-package '#:quicklisp)
  (unless (probe-file (merge-pathnames "quicklisp/setup.lisp" *kandria-root*))
    (error "Quicklisp is not set up. Did you run install.lisp?"))
  (load (merge-pathnames "quicklisp/setup.lisp" *kandria-root*)))

;;; Ensure extra projects are known
(pushnew (merge-pathnames "local-projects/" *kandria-root*) ql:*local-project-directories* :test #'equalp)

;;; Configure CFFI early to ensure shared libraries can be found.
(ql:quickload "cffi")
(pushnew *kandria-install-root* cffi:*foreign-library-directories* :test #'equalp)
(ql:quickload "deploy")

;;; Ensure Kandria is known
(unless (asdf:find-system "kandria" NIL)
  (asdf:load-asd (merge-pathnames "kandria.asd" *kandria-root*))
  (asdf:load-asd (merge-pathnames "quest/kandria-quest.asd" *kandria-root*)))

;;; Load er in.
(ql:quickload "kandria")

;;; Launch Emacs
(unless (or swank::*connections*
            (find-package '#:org.shirakumo.fraf.kandria.install))
  (let ((port (swank:create-server)))
    (handler-case (sb-ext:run-program #+windows "emacs.exe" #-windows "emacs"
                                      (list (format NIL "--eval=(slime-connect \"localhost\" ~a port)" port))
                                      :wait NIL :search T)
      (error (e)
        (format *error-output* "; Failed to launch emacs: ~a~%" e)
        (format *error-output* "; Please use slime-connect with port ~a.~%" port)))))
