(in-package #:org.shirakumo.fraf.kandria)

(defvar *modules* (make-hash-table :test 'eql))

(defclass module ()
  ((title :initarg :title :initform "Untitled" :accessor title)
   (version :initarg :version :initform "0.0.0" :accessor version)
   (author :initarg :author :initform '("Anonymous") :accessor author)
   (description :initarg :description :initform "" :accessor description)
   (upstream :initarg :upstream :initform "" :accessor upstream)))

(defmethod initialize-instance :after ((module module) &key name)
  (declare (ignore name)))

(defmethod name ((module module))
  (class-name (class-of module)))

(defgeneric load-module (module))

(defmethod load-module ((name string))
  (load-module (pathname-utils:subdirectory (data-root) "mods" name)))

(defmethod load-module ((pathname pathname))
  (depot:with-depot (depot pathname)
    (load-module depot)))

(defmethod load-module ((depot depot:depot))
  (destructuring-bind (header initargs)
      (parse-sexps (depot:read-from (depot:entry "meta.lisp" depot) 'character))
    (assert (eq 'module (getf header :identifier)))
    (let ((version (coerce-version (getf header :version))))
      (decode-payload initargs 'module depot version))))

(defmethod load-module ((module module))
  (setf (gethash (name module) *modules*) module))

(defmethod find-module ((name symbol))
  (gethash name *modules*))
