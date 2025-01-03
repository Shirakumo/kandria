#| How to:
# First, install SBCL by whatever means you can. On Linux, this is
# usually via your package manager. On Windows you'll need an installer
# from sbcl.org.
# 
# Next, run this script. From a Unix shell, you should be able to just
# run ./install.lisp . If you are using a Windows command prompt,
# instead ensure SBCL is in your PATH, and perform the following line
# on your own.

exec sbcl --dynamic-space-size 4GB --noinform --no-sysinit --no-userinit --load "$0" --eval '(org.shirakumo.fraf.kandria.install:install)' --quit

# The script will set up Quicklisp inside the Kandria distribution and
# also install any other prerequisite libraries.
|#

#-sbcl (error "You must use the SBCL lisp implementation to set up Kandria.")

(eval-when (:load-toplevel :execute)
  (require :sb-bsd-sockets))

(defpackage #:org.shirakumo.fraf.kandria.install
  (:use #:cl)
  (:export #:install))
(in-package #:org.shirakumo.fraf.kandria.install)

(require :uiop)

(defvar *kandria-root* #.(make-pathname :name NIL :type NIL :defaults (or *load-pathname* (error "This file must be LOADed."))))

(defun call-with-connection (function host port)
  (let ((endpoint (sb-bsd-sockets:host-ent-address (sb-bsd-sockets:get-host-by-name host)))
        (socket (make-instance 'sb-bsd-sockets:inet-socket :protocol :tcp :type :stream)))
    (sb-bsd-sockets:socket-connect socket endpoint port)
    (let ((stream (sb-bsd-sockets:socket-make-stream socket :element-type 'character :input T :output T :buffering :full)))
      (unwind-protect
           (funcall function stream)
        (close stream)))))

(defmacro with-connection ((stream host port) &body body)
  `(call-with-connection (lambda (,stream) ,@body) ,host ,port))

(defun read-http-line (stream)
  (with-output-to-string (out)
    (loop for prev = #\Nul then cur
          for cur = (read-char stream NIL)
          until (or (null cur)
                    (and (char= prev #\Return)
                         (char= cur #\Linefeed)))
          do (unless (char= #\Nul prev) (write-char prev out)))))

(defmacro f (package function &rest args)
  `(funcall (find-symbol (string ',function) ',package)
            ,@args))

(defmacro a (package function &rest args)
  `(apply (find-symbol (string ',function) ',package)
          ,@args))

(defun load-quicklisp-quickstart ()
  (with-connection (stream "beta.quicklisp.org" 80)
    (format stream "GET /quicklisp.lisp HTTP/1.1~c~c" #\Return #\Linefeed)
    (format stream "Host: beta.quicklisp.org~c~c" #\Return #\Linefeed)
    (format stream "Connection: close~c~c" #\Return #\Linefeed)
    (format stream "~c~c" #\Return #\Linefeed)
    (finish-output stream)
    (let ((start (read-http-line stream))
          (headers (loop for string = (read-http-line stream)
                         until (string= "" string)
                         collect (loop for string in (uiop:split-string string :separator ":")
                                       collect (string-trim string " ")))))
      (unless (search "200" start)
        (error "HTTP request failed with status line: ~a" start))
      (let ((encoding (second (assoc "transfer-encoding" headers :test #'string-equal)))
            (output (merge-pathnames "quicklisp.lisp" (uiop:temporary-directory))))
        (with-open-file (output output :direction :output :if-exists :supersede)
          (if (equal "chunked" encoding)
              (error "Fuck")
              (uiop:copy-stream-to-stream stream output)))
        (unwind-protect
             (load output)
          (delete-file output))))))

(defun install-quicklisp (&rest args)
  (unless (find-package 'quicklisp-quickstart)
    (load-quicklisp-quickstart))
  (a quicklisp-quickstart install args))

(defun status (format &rest args)
  (format *query-io* "; ~?~%" format args))

(defun install-environment (&optional (path *kandria-root*))
  (cond ((find-package :quicklisp)
         (status "Installing Quicklisp...")
         (install-quicklisp :path path))
        (T
         (ql:update-all-dists)))
  (unless (find "shirakumo" (f ql-dist all-dists) :key #'ql-dist:name :test #'string-equal)
    (f ql-dist install-dist "http://dist.shirakumo.org/shirakumo.txt" :prompt NIL))
  (unless (or (probe-file (merge-pathnames "install/" *kandria-root*))
              (probe-file (merge-pathnames ".install" *kandria-root*)))
    (status "Please enter the location of the Kandria game installation.")
    (status "On Steam you can find this by right-clicking Kandria, and selecting \"Browse local files\".")
    (loop for pathname = (uiop:parse-native-namestring (read-line *query-io*) :ensure-directory T)
          do (if (probe-file pathname)
                 (with-open-file (stream (merge-pathnames ".install" *kandria-root*) :direction :output)
                   (write-string (uiop:native-namestring pathname) stream))
                 (status "The given path does not exist. Please try again."))))
  (load (merge-pathnames "setup.lisp" path))
  (status "Done!"))

(install-environment)
