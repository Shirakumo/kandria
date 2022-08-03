#|
sbcl --noinform --no-sysinit --no-userinit --load "$0" --quit
exit
|#

(in-package #:cl-user)

(defvar *kandria-root* #.(make-pathname :type NIL :name NIL :defaults (or *load-pathname* (error "This file must be LOADed."))))

(unless (find-package '#:asdf)
  (require :asdf))

;;; Load quicklisp
(unless (find-package '#:quicklisp)
  (unless (probe-file (merge-pathnames "quicklisp/setup.lisp" *kandria-root*))
    (error "Quicklisp is not set up. Did you run install.lisp?"))
  (load (merge-pathnames "quicklisp/setup.lisp" *kandria-root*)))

;;; Ensure Kandria is known
(unless (asdf:find-system "kandria")
  (asdf:load-asd (merge-pathnames "kandria.asd" *kandria-root*)))

;;; Ensure extra projects are known
(push (merge-pathnames "local-projects/" *kandria-root*) ql:*local-project-directories*)

;;; Load er in
(ql:quickload "kandria")

;;; Stub out the pool paths
(cond ((probe-file (merge-pathnames "install/" *kandria-root*))
       (funcall (find-symbol (string '#:set-pool-paths-from-install) '#:kandria)
                (merge-pathnames "install/" *kandria-root*)))
      ((probe-file (merge-pathnames ".install" *kandria-root*))
       (funcall (find-symbol (string '#:set-pool-paths-from-install) '#:kandria)
                (pathname (uiop:read-file-string (merge-pathnames ".install" *kandria-root*))))))

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
