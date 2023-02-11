(in-package #:org.shirakumo.fraf.kandria)

(define-condition not-authenticated (error)
  ((remote :initarg :remote)))

(defvar *remote-funcs* ())

(defgeneric search-module (remote id))
(defgeneric search-modules (remote &key query sort page))
(defgeneric subscribe-module (remote module))
(defgeneric unsubscribe-module (remote module))
(defgeneric install-module (remote module))
(defgeneric upload-module (remote module))

(defmethod search-module (remote (module module))
  (search-module remote (id module)))

(defmethod subscribe-module (remote (module module))
  (subscribe-module module (search-module remote module)))

(defmethod unsubscribe-module (remote (module module))
  (unsubscribe-module module (search-module remote module)))

(defmethod install-module (remote (module module))
  (install-module module (search-module remote module)))

(defmethod search-modules ((all (eql T)) &rest args)
  (delete-duplicates
   (loop for remote in (list-remotes)
         append (apply #'search-modules remote args))
   :key #'id :test #'string=))

(defun list-remotes ()
  (loop for func in *remote-funcs*
        for remote = (handler-case (funcall func)
                       (not-authenticated ()))
        when remote collect remote))

(defmethod register-module ((remotes (eql :remote)))
  (dolist (func *remote-funcs*)
    (handler-case (register-module (funcall func))
      (not-authenticated ()))))
