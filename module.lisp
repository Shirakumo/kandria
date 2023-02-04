(in-package #:org.shirakumo.fraf.kandria)

(defvar *modules* (make-hash-table :test 'eql))

(defun module-directory ()
  (pathname-utils:subdirectory (data-root) "mods"))

(defclass module ()
  ((name :initarg :name :initform (arg! :name) :accessor name)
   (title :initarg :title :initform (arg! :title) :accessor title)
   (version :initarg :version :initform (arg! :version) :accessor version)
   (author :initarg :author :initform (arg! :author) :accessor author)
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
  module)

(defmethod load-module :around ((module module))
  (call-next-method)
  module)

(defmethod load-module :after ((module module))
  (setf (gethash (name module) *modules*) module))

(defmethod load-module ((module stub-module))
  (load-module (file module)))

(defmethod find-module ((name symbol))
  (gethash name *modules*))

(defun ensure-mod-package ()
  (let ((package (or (find-package '#:org.shirakumo.fraf.kandria.mod)
                     (make-package '#:org.shirakumo.fraf.kandria.mod :use (list '#:cl+trial)))))
    (do-external-symbols (symbol '#:org.shirakumo.fraf.kandria)
      (shadowing-import symbol package))
    (import 'define-module '#:cl-user)
    (do-symbols (symbol package)
      (export symbol package))))

(ensure-mod-package)

(defmacro define-module (name &optional superclasses slots &rest options)
  (let* ((package-name (format NIL "~a.~a" '#:org.shirakumo.fraf.kandria.mod name))
         (class-name (intern (string name) '#:org.shirakumo.fraf.kandria.mod))
         (use (find :use options :key #'car)))
    `(progn
       (defpackage ,package-name
         (:use #:org.shirakumo.fraf.kandria.mod ,@(rest use))
         (:import-from #:org.shirakumo.fraf.kandria.mod ,(string class-name))
         ,@(remove use options))
       (in-package ,package-name)
       
       (defclass ,class-name (,@superclasses module)
         ((name :initform ',name)
          ,@slots)))))
