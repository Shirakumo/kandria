(in-package #:org.shirakumo.fraf.kandria)

(define-condition module-source-not-found (error)
  ((name :initarg :name :accessor name))
  (:report (lambda (c s) (format s "No source for module with name ~s found." (name c)))))

(defvar *modules* (make-hash-table :test 'equal))
(defvar *worlds* ())

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
  (sort (copy-list *worlds*) #'string< :key #'title))

(defclass module (alloy:observable-object)
  ((name :initarg :name :initform (arg! :name) :accessor name)
   (title :initarg :title :initform (arg! :title) :accessor title)
   (version :initarg :version :initform (arg! :version) :accessor version)
   (author :initarg :author :initform (arg! :author) :accessor author)
   (description :initarg :description :initform "" :accessor description)
   (upstream :initarg :upstream :initform "" :accessor upstream)
   (preview :initarg :preview :initform NIL :accessor preview)
   (active-p :initarg :active-p :initform NIL :accessor active-p)))

(defgeneric module-package (module))
(defgeneric module-root (module))

(defmethod module-package (module-name)
  (module-package (or (find-module module-name)
                      (error "No module named ~s" module-name))))

(defmethod module-config-directory ((module module))
  (module-config-directory (name module)))

(defmethod print-object ((module module) stream)
  (print-unreadable-object (module stream :type T)
    (format stream "~a" (name module))))

(defclass stub-module (module)
  ((file :initarg :file :accessor file)))

(defmethod (setf active-p) :before (value (module module))
  (when value
    (load-module module)))

(defmethod (setf active-p) :after (value (module module))
  (save-active-module-list))

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
      (apply #'make-instance 'stub-module :file file initargs))))

(defun list-modules (&optional (kind :loaded))
  (let ((modules (alexandria:hash-table-values *modules*)))
    (flet ((try-minimal-load (file)
             (handler-case (pushnew (minimal-load-module file) modules :key #'name)
               (unsupported-save-file ()
                 (v:warn :kandria.module "Module version ~s is too old, ignoring." file)
                 NIL)
               #+kandria-release
               (error (e)
                 (v:warn :kandria.module "Module ~s failed to load, ignoring." file)
                 (v:debug :kandria.module e)
                 NIL))))
      (ecase kind
        (:loaded)
        (:available
         (dolist (file (filesystem-utils:list-contents (module-directory)))
           (try-minimal-load file)))
        (:active
         (setf modules (remove-if-not #'active-p modules))
         (let ((path (make-pathname :name "modules" :type "lisp" :defaults (config-directory))))
           (when (probe-file path)
             (dolist (name (parse-sexps (alexandria:read-file-into-string path)))
               (handler-case (try-minimal-load (find-module-file name))
                 #+kandria-release
                 (module-source-not-found (e)
                   (v:warn :kandria.module "Module ~s failed to load, ignoring." name)
                   (v:debug :kandria.module e)))))))))
    (sort modules #'string< :key #'name)))

(defun save-active-module-list ()
  (v:info :kandria.module "Saving active module list")
  (with-open-file (stream (make-pathname :name "modules" :type "lisp" :defaults (config-directory))
                          :direction :output :if-exists :supersede)
    (dolist (module (list-modules :active))
      (princ* (name module) stream))))

(defgeneric load-module (module))

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
  (setf (gethash (string-downcase (name module)) *modules*) module)
  (setf (slot-value module 'active-p) T))

(defmethod load-module ((module stub-module))
  (setf (gethash (string-downcase (name module)) *modules*) module)
  (load-module (file module)))

(defmethod find-module ((name symbol))
  (gethash (string-downcase name) *modules*))

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
         (local-nicknames (find :local-nicknames options :key #'car))
         (use (find :use options :key #'car)))
    `(progn
       (defpackage ,package-name
         (:use #:org.shirakumo.fraf.kandria.mod ,@(rest use))
         (:import-from #:org.shirakumo.fraf.kandria.mod ,(string class-name))
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
          (#:sequences #:org.shirakumo.trivial-extensible-sequences)
          ,@local-nicknames)
         ,@(remove use (remove local-nicknames options)))
       (,'in-package ,package-name)

       (set (intern (string '#:*module-root*) ,package-name)
            ,(make-pathname :name NIL :type NIL :defaults
                            (or *compile-file-truename* *load-truename*
                                (error "You must compile or load this file."))))

       (defclass ,class-name (,@superclasses module)
         ((name :initform ',name)
          ,@slots))

       (defmethod module-root ((,class-name ,class-name))
         (symbol-value (intern (string '#:*module-root*) ,package-name)))

       (defmethod module-package ((,class-name ,class-name))
         (find-package ',package-name)))))

(defmethod module-root ((package package))
  (let ((var (or (find-symbol (string '#:*module-root*) package)
                 (error "This is not a module package:~% ~a" package))))
    (symbol-value var)))

(defun register-worlds (&optional (root-or-worlds *package*))
  (etypecase root-or-worlds
    (list
     (dolist (file root-or-worlds)
       (let ((world (handler-case (minimal-load-world file)
                      #+kandria-release
                      (error (e)
                        (v:warn :kandria.module "Ignoring ~a as a world: ~a" file e)
                        (v:debug :kandria.module e)))))
         (when world
           (setf *worlds* (list* world (remove (id world) *worlds* :key #'id :test #'string=)))))))
    ((or module package)
     (register-worlds (module-root root-or-worlds)))
    (pathname
     (cond ((wild-pathname-p root-or-worlds)
            (register-worlds (directory root-or-worlds)))
           ((pathname-utils:directory-p root-or-worlds)
            (register-worlds (merge-pathnames "*.zip" root-or-worlds)))
           (T
            (register-worlds (list root-or-worlds)))))))
