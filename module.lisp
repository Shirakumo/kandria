(in-package #:org.shirakumo.fraf.kandria)

(define-condition module-source-not-found (error)
  ((name :initarg :name :accessor name))
  (:report (lambda (c s) (format s "No source for module with name ~s found." (name c)))))

(define-condition module-registration-failed (error)
  ((file :initarg :file :accessor file)
   (error :initarg :error :reader original-error)))

(defvar *modules* (make-hash-table :test 'equal))

(defmethod module-config-directory ((name string))
  (pathname-utils:subdirectory (config-directory) "mods/config/" name))

(defmethod module-config-directory ((name symbol))
  (module-config-directory (string-downcase name)))

(defmethod module-config-file (file module)
  (merge-pathnames file (module-config-directory module)))

(defun module-directory ()
  (let ((setting (setting :modules :directory)))
    (if setting
        (pathname-utils:parse-native-namestring setting :as :directory)
        (pathname-utils:subdirectory (config-directory) "mods/"))))

(defun find-module-file (name)
  (or (probe-file (pathname-utils:subdirectory (module-directory) (string-downcase name)))
      (first (directory (make-pathname :name (string-downcase name) :type :wild :defaults (module-directory))))
      (error 'module-source-not-found :name name)))

(defun list-worlds ()
  (sort (loop for module being the hash-values of *modules*
              when (active-p module)
              append (worlds module))
        #'text< :key #'title))

(define-event module-event () (module))
(define-event module-loaded (module-event))
(define-event module-unloaded (module-event))
(define-event module-registered (module-event))
(define-event module-unregistered (module-event))

(defclass module (listener alloy:observable-object)
  ((id :initarg :id :initform (make-uuid) :accessor id)
   (title :initarg :title :initform (arg! :title) :accessor title)
   (version :initarg :version :initform (arg! :version) :accessor version)
   (author :initarg :author :initform (arg! :author) :accessor author)
   (description :initarg :description :initform "" :accessor description)
   (upstream :initarg :upstream :initform "" :accessor upstream)
   (preview :initarg :preview :initform NIL :accessor preview)
   (checksum :initarg :checksum :initform NIL :accessor checksum)
   (active-p :initarg :active-p :initform NIL :accessor active-p)
   (worlds :initform () :accessor worlds)
   (file :initarg :file :accessor file)))

(defmethod print-object ((module module) stream)
  (print-unreadable-object (module stream :type NIL)
    (format stream "~a ~a ~a" (type-of module) (id module) (title module))))

(defgeneric module-package (module))
(defgeneric module-root (module))
(defgeneric load-module (module))
(defgeneric unload-module (module))
(defgeneric locally-changed-p (module))

(defmethod locally-changed-p ((module module))
  (or (null (checksum module))
      (string/= (checksum module) (checksum (file module)))))

(defmethod (setf locally-changed-p) (value (module module))
  (cond (value
         (setf (checksum module) NIL)
         (filesystem-utils:ensure-deleted (module-config-file ".checksum" module)))
        (T
         (setf (checksum module) (checksum (file module)))
         (alexandria:write-string-into-file (checksum module) (module-config-file ".checksum" module)
                                            :if-exists :supersede))))

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

(defmethod (setf preview) ((path pathname) (module module))
  (cond ((pathname-utils:relative-p path)
         (setf (slot-value module 'preview) path))
        ((pathname-utils:subpath-p path (file module))
         (setf (slot-value module 'preview) (pathname-utils:enough-pathname path (file module))))
        (T
         (v:info :kandria.module "Updating preview of ~a to ~a" module path)
         (depot:with-depot (depot (file module) :commit T)
           (depot:write-to (depot:ensure-entry "preview.png" depot) path))
         (unless (preview module)
           (setf (slot-value module 'preview) (tempfile :type "png" :id (format NIL "kandria-mod-~a" (id module)))))
         (uiop:copy-file path (preview module))
         ;; KLUDGE: clear cache.
         (trial-alloy::deallocate-image-cache (preview module) (u 'ui-pass)))))

(defmethod (setf active-p) :before (value (module module))
  (if value
      (load-module module)
      (unload-module module)))

(defmethod (setf active-p) :after (value (module module))
  (save-active-module-list))

(defmethod module ((world world))
  (loop for module being the hash-values of *modules*
        do (when (loop for other in (worlds module)
                       thereis (string= (id world) (id other)))
             (return module))))

(defmethod module-usable-p ((module module))
  (cond ((probe-file (file module))
         module)
        (T
         (v:warn :kandria.module "Module sources for ~a disappeared! Unloading and deregistering." module)
         (when (active-p module)
           (ignore-errors
            (with-error-logging (:kandria.module "Error during unload: ~a")
              (unload-module module))))
         (setf (find-module module) NIL)
         nil)))

(defclass stub-module (module)
  ())

(defmethod update-instance-for-different-class ((module module) (stub stub-module) &key)
  (setf (slot-value stub 'active-p) NIL)
  (setf (slot-value stub 'worlds) ()))

(defun minimal-load-module (file)
  (depot:with-depot (depot file)
    (when (and (not (depot:entry-exists-p "meta.lisp" depot))
               (depot:query-entries depot :type :directory))
      (setf depot (first (depot:query-entries depot :type :directory))))
    ;; Just ignore depots that have nothing in them.
    (when (depot:query-entries depot)
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
          (cond ((null module)
                 (setf module (apply #'make-instance 'stub-module :file file initargs))
                 (v:info :kandria.module "Registered ~a at ~a" module file))
                ((or (null (file module))
                     (null (probe-file (file module)))
                     (<= (file-write-date (file module)) (file-write-date file)))
                 (apply #'reinitialize-instance module :file file initargs))
                (T
                 (v:info :kandria.module "Refusing to update location of ~a to ~a as the new location is older." module file)))
          (setf (find-module module) T))))))

(defmethod register-module ((file pathname))
  (handler-bind (#+kandria-release
                 ((and error (not unsupported-save-file))
                   (lambda (e)
                     (v:warn :kandria.module "Module ~s failed to register." file)
                     (v:debug :kandria.module e)
                     (error 'module-registration-failed :file file :error e))))
    (minimal-load-module file)))

(defmethod register-module ((defaults (eql 'null)))
  (mapcar #'unload-module (list-modules))
  (clrhash *modules*))

(defmethod register-module ((defaults (eql T)))
  (when (probe-file (module-directory))
    (dolist (file (filesystem-utils:list-contents (module-directory)))
      (with-simple-restart (continue "Ignore the failing module")
        (handler-case (register-module file)
          (unsupported-save-file ()
            (v:warn :kandria.module "Module version ~s is too old, ignoring." file)))))))

(defun list-modules (&optional (kind :active))
  (sort (ecase kind
          (:active
           (loop for module being the hash-values of *modules*
                 when (and (active-p module) (module-usable-p module))
                 collect module))
          (:inactive
           (loop for module being the hash-values of *modules*
                 when (and (not (active-p module)) (module-usable-p module))
                 collect module))
          (:available
           (loop for module being the hash-values of *modules*
                 when (module-usable-p module)
                 collect module)))
        #'text< :key #'title))

(defmethod find-module ((id string))
  (let ((module (gethash (string-downcase id) *modules*)))
    (cond ((and module (module-usable-p module))
           module)
          (T
           (loop for module being the hash-values of *modules*
                 do (when (and (string-equal id (title module))
                               (module-usable-p module))
                      (return module)))))))

(defmethod (setf find-module) ((module module) (id string))
  (let ((existing (gethash (string-downcase id) *modules*)))
    (unless (eq module existing)
      (when (and existing +world+)
        (issue +world+ 'module-unregistered :module existing))
      (setf (gethash (string-downcase id) *modules*) module)
      (when +world+ (issue +world+ 'module-registered :module module))))
  module)

(defmethod (setf find-module) ((none null) (id string))
  (let ((module (gethash (string-downcase id) *modules*)))
    (when module
      (remhash (string-downcase id) *modules*)
      (when +world+ (issue +world+ 'module-unregistered :module module))))
  NIL)

(defmethod (setf find-module) (value (module module))
  (setf (find-module (id module)) value))

(defmethod (setf find-module) ((default (eql T)) (module module))
  (setf (find-module (id module)) module))

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
      (handler-bind (#+kandria-release (error #'continue))
        (loop (with-simple-restart (continue "Ignore the module line.")
                (let ((read (read stream NIL #1='#:eof)))
                  (when (eq read #1#) (return))
                  (destructuring-bind (&optional id version title) read
                    (declare (ignore title))
                    (let ((module (find-module id)))
                      (cond ((null module)
                             (v:warn :kandria.module "No module with id~%  ~a~%found. Ignoring." id))
                            ((string/= version (version module))
                             (v:info :kandria.module "Module version is~%  ~a~%which differs from the one saved~%  ~a~%for~%  ~a"
                                     (version module) version module)
                             (load-module module))
                            (T
                             (load-module module))))))))))))

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
  (when (and (not (depot:entry-exists-p "meta.lisp" depot))
             (depot:query-entries depot :type :directory))
    (setf depot (first (depot:query-entries depot :type :directory))))
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
  (when (probe-file (module-config-file ".checksum" module))
    (setf (checksum module) (alexandria:read-file-into-string (module-config-file ".checksum" module))))
  (setf (find-module module) T)
  (setf (slot-value module 'active-p) T)
  (when +world+ (issue +world+ 'module-loaded :module module)))

(defmethod load-module ((module stub-module))
  (load-module (file module)))

(defmethod unload-module ((module module))
  module)

(defmethod unload-module :after ((module module))
  (setf (slot-value module 'active-p) NIL)
  (unless (typep module 'stub-module)
    (delete-package (module-package module))
    (change-class module 'stub-module)
    (when +world+ (issue +world+ 'module-unloaded :module module))))

(defun ensure-mod-package ()
  (let ((package (or (find-package '#:org.shirakumo.fraf.kandria.mod)
                     (make-package '#:org.shirakumo.fraf.kandria.mod))))
    (use-package '#:cl+trial package)
    (do-external-symbols (symbol '#:org.shirakumo.fraf.kandria)
      (shadowing-import (list symbol) package))
    (import 'define-module '#:cl-user)
    (let ((symbols ()))
      (do-symbols (symbol package) (push symbol symbols))
      (export symbols package))))

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
         ,(or *module-root*
              (depot:from-pathname
               (make-pathname :name NIL :type NIL :defaults
                              (or *compile-file-truename* *load-truename*
                                  (error "You must compile or load this file."))))))

       (when (boundp '*module-class-name*)
         (setf *module-class-name* ',class-name))

       (defclass ,class-name (,@superclasses module)
         ,slots)

       (defmethod module-root ((,class-name ,class-name))
         ,(intern (string '#:*module-root*) package-name))

       (defmethod module-package ((,class-name ,class-name))
         (find-package ,package-name)))))

(defmethod checksum ((pathname pathname))
  (let ((digest (ironclad:make-digest :sha256)))
    (labels ((recurse (pathname)
               (cond ((wild-pathname-p pathname)
                      (dolist (child (directory pathname))
                        (recurse child)))
                     ((filesystem-utils:directory-p pathname)
                      (dolist (child (filesystem-utils:list-contents pathname))
                        (recurse child)))
                     (T
                      (with-open-file (stream pathname :element-type '(unsigned-byte 8))
                        (ironclad:update-digest digest stream))))))
      (recurse pathname)
      (ironclad:byte-array-to-hex-string (ironclad:produce-digest digest)))))
