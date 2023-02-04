(in-package #:org.shirakumo.fraf.kandria)

(defvar *modules* (make-hash-table :test 'eql))

(defun module-directory ()
  (pathname-utils:subdirectory (data-root) "mods"))

(defclass module ()
  ((name :initarg :name :accessor name)
   (title :initarg :title :initform "Untitled" :accessor title)
   (version :initarg :version :initform "0.0.0" :accessor version)
   (author :initarg :author :initform '("Anonymous") :accessor author)
   (description :initarg :description :initform "" :accessor description)
   (upstream :initarg :upstream :initform "" :accessor upstream)
   (preview :initarg :preview :initform NIL :accessor preview)))

(defclass stub-module (module)
  ((file :initarg :file :accessor file)))

(defmethod name ((module module))
  (class-name (class-of module)))

(defun minimal-load-module (file)
  (depot:with-depot (depot file)
    (destructuring-bind (header initargs)
        (parse-sexps (depot:read-from (depot:entry "meta.lisp" depot) 'character))
      (assert (eq 'save-state (getf header :identifier)))
      (unless (supported-p (make-instance (getf header :version)))
        (cerror "Try it anyway." 'unsupported-save-file))
      (when (depot:entry-exists-p "preview.png" depot)
        ;; KLUDGE: This fucking sucks, yo.
        (let ((temp (tempfile :type "png" :id (format NIL "kandria-mod-~a" (depot:id depot)))))
          (depot:read-from (depot:entry "preview.png" depot) temp :if-exists :supersede)
          (push temp initargs)
          (push :preview initargs)))
      (apply #'make-instance 'stub-module :file file initargs))))

(defun list-modules (&key (loaded-only T))
  (let ((modules (alexandria:hash-table-values *modules*)))
    (unless loaded-only
      (loop for file in (filesystem-utils:list-contents (module-directory))
            for mod = (minimal-load-module file)
            do (pushnew mod modules :key #'name)))
    modules))

(defgeneric load-module (module))

(defmethod load-module ((name string))
  (load-module (pathname-utils:subdirectory (module-directory) name)))

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

(defmethod load-module ((module stub-module))
  (load-module (file module)))

(defmethod find-module ((name symbol))
  (gethash name *modules*))
