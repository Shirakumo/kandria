(in-package #:org.shirakumo.fraf.kandria)

(define-condition module-source-not-found (error)
  ((name :initarg :name :accessor name))
  (:report (lambda (c s) (format s "No source for module with name ~s found." (name c)))))

(defvar *modules* (make-hash-table :test 'equal))

(defmethod module-config-directory ((name string))
  (pathname-utils:subdirectory (config-directory) "mods" name))

(defmethod module-config-directory ((name symbol))
  (module-config-directory (string-downcase name)))

(defun module-directory ()
  (pathname-utils:subdirectory (data-root) "mods"))

(defun find-module-file (name)
  (or (probe-file (pathname-utils:subdirectory (module-directory) (string-downcase name)))
      (first (directory (make-pathname :name (string-downcase name) :type :wild :defaults (module-directory))))
      (error 'module-source-not-found :name name)))

(defun list-worlds ()
  (sort (loop for module being the hash-values of *modules*
              when (active-p module)
              append (worlds module))
        #'string< :key #'title))

(defclass module (listener alloy:observable-object)
  ((id :initarg :id :initform (make-uuid) :accessor id)
   (title :initarg :title :initform (arg! :title) :accessor title)
   (version :initarg :version :initform (arg! :version) :accessor version)
   (author :initarg :author :initform (arg! :author) :accessor author)
   (description :initarg :description :initform "" :accessor description)
   (upstream :initarg :upstream :initform "" :accessor upstream)
   (preview :initarg :preview :initform NIL :accessor preview)
   (active-p :initarg :active-p :initform NIL :accessor active-p)
   (worlds :initform () :accessor worlds)
   (file :initarg :file :accessor file)))

(defmethod print-object ((module module) stream)
  (print-unreadable-object (module stream :type T)
    (format stream "~a ~a" (id module) (title module))))

(defgeneric module-package (module))
(defgeneric module-root (module))
(defgeneric load-module (module))
(defgeneric unload-module (module))

(defmethod module-root ((default (eql T)))
  (module-root *package*))

(defmethod module-root ((package package))
  (let ((var (or (find-symbol (string '#:*module-root*) package)
                 (error "This is not a module package:~% ~a" package))))
    (symbol-value var)))

(defmethod module-package (module-name)
  (module-package (or (find-module module-name)
                      (error "No module named ~s" module-name))))

(defmethod module-config-directory ((module module))
  (module-config-directory (id module)))

(defmethod (setf active-p) :before (value (module module))
  (if value
      (load-module module)
      (unload-module module)))

(defmethod (setf active-p) :after (value (module module))
  (save-active-module-list))

(defclass stub-module (module)
  ())

(defmethod update-instance-for-different-class ((module module) (stub stub-module) &key)
  (setf (slot-value stub 'active-p) NIL)
  (setf (slot-value stub 'worlds) ()))

(defun minimal-load-module (file)
  (depot:with-depot (depot file)
    (destructuring-bind (header initargs)
        (parse-sexps (depot:read-from (depot:entry "meta.lisp" depot) 'character))
      (assert (eq 'module (getf header :identifier)))
      (unless (supported-p (make-instance (getf header :version)))
        (cerror "Try it anyway." 'unsupported-save-file))
      (when (depot:entry-exists-p "preview.png" depot)
        ;; KLUDGE: This fucking sucks, yo.
        (let ((temp (tempfile :type "png" :id (format NIL "kandria-mod-~a" (depot:id depot)))))
          (depot:read-from (depot:entry "preview.png" depot) temp :if-exists :supersede)
          (push temp initargs)
          (push :preview initargs)))
      (let ((module (find-module (getf initargs :id))))
        (if module
            (apply #'reinitialize-instance module :file file initargs)
            (setf module (apply #'make-instance 'stub-module :file file initargs)))
        (setf (find-module T) module)))))

(defun register-modules ()
  (dolist (file (filesystem-utils:list-contents (module-directory)))
    (handler-case (minimal-load-module file)
      (unsupported-save-file ()
        (v:warn :kandria.module "Module version ~s is too old, ignoring." file)
        NIL)
      #+kandria-release
      (error (e)
        (v:warn :kandria.module "Module ~s failed to register, ignoring." file)
        (v:debug :kandria.module e)
        NIL))))

(defun list-modules (&optional (kind :active))
  (sort (ecase kind
          (:active
           (loop for module being the hash-values of *modules*
                 when (active-p module) collect module))
          (:inactive
           (loop for module being the hash-values of *modules*
                 unless (active-p module) collect module))
          (:available
           (loop for module being the hash-values of *modules*
                 collect module)))
        #'string< :key #'title))

(defmethod find-module ((id string))
  (gethash (string-downcase id) *modules*))

(defmethod (setf find-module) ((module module) (id string))
  (setf (gethash (string-downcase id) *modules*) module))

(defmethod (setf find-module) ((module module) (default (eql T)))
  (setf (gethash (string-downcase (id module)) *modules*) module))

(defun save-active-module-list ()
  (v:info :kandria.module "Saving active module list")
  (with-open-file (stream (make-pathname :name "modules" :type "lisp" :defaults (config-directory))
                          :direction :output :if-exists :supersede)
    (dolist (module (list-modules :active))
      (princ* (list (id module) (version module) (title module)) stream))))

(defun load-active-module-list ()
  (v:info :kandria.module "Loading active module list")
  (with-open-file (stream (make-pathname :name "modules" :type "lisp" :defaults (config-directory))
                          :direction :input :if-does-not-exist NIL)
    (when stream
      (loop for read = (read stream NIL #1='#:eof)
            until (eq read #1#)
            do (destructuring-bind (&optional id version title) read
                 (declare (ignore title))
                 (let ((module (find-module id)))
                   (cond ((null module)
                          (v:warn :kandria.module "No module with id~%  ~a~%found. Ignoring." id))
                         ((string/= version (version module))
                          (v:info :kandria.module "Module version is~%  ~a~%which differs from the one saved~%  ~a~%for~%  ~a"
                                  (version module) version module)
                          (load-module module))
                         (T
                          (load-module module)))))))))

(defmethod load-module ((module null)))

(defmethod load-module ((modules cons))
  (dolist (module modules)
    (with-simple-restart (continue "Ignore ~a" module)
      (load-module module))))

(defmethod load-module ((modules (eql :available)))
  (load-module (list-modules :available)))

(defmethod load-module ((modules (eql :active)))
  (load-module (list-modules :active)))

(defmethod load-module ((name string))
  (load-module (find-module-file name)))

(defmethod load-module ((pathname pathname))
  (depot:with-depot (depot pathname)
    (load-module depot)))

(defmethod load-module ((depot depot:depot))
  (destructuring-bind (header initargs)
      (parse-sexps (depot:read-from (depot:entry "meta.lisp" depot) 'character))
    (assert (eq 'module (getf header :identifier)))
    (let ((version (coerce-version (getf header :version))))
      (decode-payload initargs (allocate-instance (find-class 'module)) depot version))))

(defmethod load-module ((module module))
  module)

(defmethod load-module :around ((module module))
  (ensure-directories-exist (module-config-directory module))
  (call-next-method)
  module)

(defmethod load-module :after ((module module))
  (register-worlds module)
  (setf (find-module T) module)
  (setf (slot-value module 'active-p) T))

(defmethod load-module ((module stub-module))
  (load-module (file module)))

(defmethod unload-module ((module module))
  module)

(defmethod unload-module :after ((module module))
  (setf (slot-value module 'active-p) NIL)
  (delete-package (module-package module))
  (change-class module 'stub-module))

(defun ensure-mod-package ()
  (let ((package (or (find-package '#:org.shirakumo.fraf.kandria.mod)
                     (make-package '#:org.shirakumo.fraf.kandria.mod :use (list '#:cl+trial)))))
    (do-external-symbols (symbol '#:org.shirakumo.fraf.kandria)
      (shadowing-import symbol package))
    (import 'define-module '#:cl-user)
    (do-symbols (symbol package)
      (export symbol package))))

(ensure-mod-package)

(defmacro define-module (id &optional superclasses slots &rest options)
  (let* ((package-name (format NIL "~a.~a" '#:org.shirakumo.fraf.kandria.mod id))
         (package (or (find-package package-name)
                      (make-package package-name)))
         (class-name (intern (string '#:module) package)))
    (shadow class-name package)
    `(progn
       (defpackage ,package-name
         (:use #:org.shirakumo.fraf.kandria.mod)
         (:shadow #:module)
         (:local-nicknames
          (#:fish #:org.shirakumo.fraf.kandria.fish)
          (#:item #:org.shirakumo.fraf.kandria.item)
          (#:dialogue #:org.shirakumo.fraf.speechless)
          (#:quest #:org.shirakumo.fraf.kandria.quest)
          (#:alloy #:org.shirakumo.alloy)
          (#:trial-alloy #:org.shirakumo.fraf.trial.alloy)
          (#:simple #:org.shirakumo.alloy.renderers.simple)
          (#:presentations #:org.shirakumo.alloy.renderers.simple.presentations)
          (#:colored #:org.shirakumo.alloy.colored)
          (#:colors #:org.shirakumo.alloy.colored.colors)
          (#:animation #:org.shirakumo.alloy.animation)
          (#:harmony #:org.shirakumo.fraf.harmony.user)
          (#:mixed #:org.shirakumo.fraf.mixed)
          (#:steam #:org.shirakumo.fraf.steamworks)
          (#:depot #:org.shirakumo.depot)
          (#:action-list #:org.shirakumo.fraf.action-list)
          (#:sequences #:org.shirakumo.trivial-extensible-sequences))
         (:export #:module)
         ,@options)
       (,'in-package ,package-name)

       (defvar ,(intern (string '#:*module-root*) package)
         ,(make-pathname :name NIL :type NIL :defaults
                         (or *compile-file-truename* *load-truename*
                             (error "You must compile or load this file."))))

       (defvar ,(intern (string '#:*module-root*) package)
         ,(make-pathname :name NIL :type NIL :defaults
                         (or *compile-file-truename* *load-truename*
                             (error "You must compile or load this file."))))

       (when (boundp '*module-class-name*)
         (setf *module-class-name* ',class-name))

       (defclass ,class-name (,@superclasses module)
         ,slots)

       (defmethod module-root ((,class-name ,class-name))
         ,(intern (string '#:*module-root*) package-name))

       (defmethod module-package ((,class-name ,class-name))
         (find-package ,package-name)))))

(defun register-worlds (module)
  (flet ((register (file)
           (let ((world (handler-case (minimal-load-world file)
                          #+kandria-release
                          (error (e)
                            (v:warn :kandria.module "Ignoring ~a as a world: ~a" file e)
                            (v:debug :kandria.module e)))))
             (when world
               (setf (worlds module) (list* world (remove (id world) (worlds module) :key #'id :test #'string=)))))))
    (mapc #'register (directory (merge-pathnames "*.zip" (module-root module))))
    (register (merge-pathnames "world/" (module-root module)))))
