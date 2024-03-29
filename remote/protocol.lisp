(in-package #:org.shirakumo.fraf.kandria)

(define-condition not-authenticated (error)
  ((remote :initarg :remote)))

(define-condition module-installation-failed (error)
  ((module :initarg :module)
   (error :initarg :error :reader original-error)))

(defvar *remote-funcs* ())

(defclass remote-module (module)
  ())

(defmethod active-p ((module remote-module))
  NIL)

(defgeneric user-authored-p (remote module))
(defgeneric authenticated-p (remote))
(defgeneric logout (remote))
(defgeneric remote (module))
(defgeneric rating (remote-module))
(defgeneric (setf rating) (rating remote-module))
(defgeneric download-count (remote-module))
(defgeneric search-module (remote id))
(defgeneric search-modules (remote &key query sort page))
(defgeneric subscribed-p (remote module))
(defgeneric subscribe-module (remote module))
(defgeneric unsubscribe-module (remote module))
(defgeneric install-module (remote module))
(defgeneric upload-module (remote module))
(defgeneric remote-id (module))

(defmethod user-authored-p (remote (module module))
  (user-authored-p remote (search-module remote module)))

(defmethod search-module (remote (module module))
  (search-module remote (id module)))

(defmethod subscribe-module (remote (module module))
  (subscribe-module remote (search-module remote module)))

(defmethod unsubscribe-module (remote (module module))
  (unsubscribe-module remote (search-module remote module)))

(defmethod install-module (remote (module module))
  (install-module remote (search-module remote module)))

(defmethod subscribe-module ((all (eql T)) module)
  (loop for remote in (list-remotes)
        thereis (subscribe-module remote module)))

(defmethod unsubscribe-module ((all (eql T)) module)
  (loop for remote in (list-remotes)
        thereis (unsubscribe-module remote module)))

(defmethod install-module ((all (eql T)) module)
  (loop for remote in (list-remotes)
        thereis (install-module remote module)))

(defmethod search-module ((all (eql T)) module)
  (loop for remote in (list-remotes)
        thereis (search-module remote module)))

(defmethod search-modules ((all (eql T)) &rest args)
  (delete-duplicates
   (loop for remote in (list-remotes)
         append (apply #'search-modules remote args))
   :key #'id :test #'string=))

(defmethod upload-module :after (remote (module module))
  (setf (locally-changed-p module) NIL))

(defun list-remotes ()
  (loop for func in *remote-funcs*
        for remote = (handler-case (funcall func)
                       (not-authenticated ()))
        when remote collect remote))

(defmethod register-module ((remotes (eql :remote)))
  (dolist (func *remote-funcs*)
    (handler-case (register-module (funcall func))
      (not-authenticated ()))))

(defmethod (setf subscribed-p) (value remote module)
  (if value
      (subscribe-module remote module)
      (unsubscribe-module remote module)))

(defmethod install-module ((path pathname) (module module))
  (let ((canonical (make-pathname :name (id module) :type "zip" :defaults (module-directory))))
    (uiop:copy-file path canonical)
    (setf (file module) canonical)
    (register-module module)))

(defmethod (setf rating) (rating (module module))
  (let ((remote (search-module T module)))
    (when remote
      (setf (rating remote) rating))
    rating))

(defmethod remote ((module module))
  (loop for remote in (list-remotes)
        when (search-module remote module)
        do (return remote)
        finally (no-applicable-method #'remote module)))

(defmethod module-editable-p ((module module))
  (unless (typep module 'remote-module)
    (loop for remote in (list-remotes)
          for remote-module = (ignore-errors (search-module remote module))
          thereis (or (null remote-module) (user-authored-p remote remote-module)))))
