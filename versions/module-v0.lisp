(in-package #:org.shirakumo.fraf.kandria)

(defclass module-v0 (version) ())
(defclass module-v1 (version) ())

(defmethod supported-p ((_ module-v0)) T)

(defvar *module-class-name*)

(defun register-worlds (module)
  (flet ((register (file)
           (with-simple-restart (continue "Ignore the world.")
             (let ((world (handler-case (minimal-load-world file)
                            #+kandria-release
                            (error (e)
                              (v:warn :kandria.module "Ignoring ~a as a world: ~a" file e)
                              (v:debug :kandria.module e)))))
               (when world
                 (setf (worlds module) (list* world (remove (id world) (worlds module) :key #'id :test #'string=))))))))
    (mapc #'register (directory (merge-pathnames "*.zip" (module-root module))))
    (mapc #'register (directory (merge-pathnames "world*/" (module-root module))))))

(define-decoder (module module-v0) (initargs depot)
  (let ((*module-class-name* NIL))
    (load-source-file (depot:entry "setup.lisp" depot))
    (let* ((id (getf initargs :id))
           (class (find-class *module-class-name* NIL))
           (module (find-module id)))
      (when (or (null *module-class-name*) (null class) (not (c2mop:subclassp class 'module)))
        (error "Mod ~a does not define a module class!" depot))
      (let ((module (apply #'ensure-instance module class initargs)))
        (load-module module)
        (register-worlds module)))))

(define-encoder (module module-v0) (_b depot)
  (depot:with-open (tx (depot:ensure-entry "meta.lisp" depot) :output 'character)
    (let ((*standard-output* (depot:to-stream tx)))
      (princ* `(:identifier module :version ,(type-of module-v0)))
      (princ* `(:id ,(id module)
                :title ,(title module)
                :author ,(author module)
                :version ,(version module)
                :description ,(description module)
                :upstream ,(upstream module))))))
