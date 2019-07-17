(in-package #:org.shirakumo.fraf.leaf)

(defclass region (layered-container entity)
  ((author :initform "Anonymous" :initarg :author :accessor author)
   (version :initform "0.0.0" :initarg :version :accessor version)
   (description :initform "" :initarg :description :accessor description)
   (preview :initform NIL :initarg :preview :accessor preview))
  (:default-initargs :layers +layer-count+))

(defmethod enter :after ((region region) (scene scene))
  (setf (gethash 'region (name-map scene)) region))

(defclass version () ())

(defun coerce-version (symbol)
  (flet ((bail () (error "No such version ~s." symbol)))
    (let* ((class (or (find-class symbol NIL) (bail))))
      (unless (subtypep class 'version) (bail))
      (make-instance class))))

(defgeneric load-region (packet scene))
(defgeneric save-region (region packet &key version &allow-other-keys))
(defgeneric decode-region-payload (payload target packet version))
(defgeneric encode-region-payload (source payload packet version))

(defmethod save-region ((scene scene) target &rest args)
  (apply #'save-region (unit 'region scene) target args))

(defmethod save-region :around (region target &rest args &key (version T))
  (cond ((eql T version)
         ;; KLUDGE: latest version should be determined automatically.
         (apply #'call-next-method region target :version (make-instance 'v0) args))
        ((typep version 'version)
         (call-next-method))
        (T
         (error "VERSION must be an instance of VERSION or T."))))

(defmethod save-region (region (pathname pathname) &key version (if-exists :supersede))
  (with-packet (packet pathname :direction :output :if-exists if-exists)
    (save-region region packet :version version)))

(defmethod save-region (region (packet packet) &key version)
  (let ((meta (make-sexp-stream (list :identifier 'region
                                      :version (type-of version))
                                (encode-region-payload region NIL packet version))))
    (setf (packet-entry "meta.lisp" packet) meta)))

(defmethod load-region ((pathname pathname) scene)
  (with-packet (packet pathname :direction :input)
    (load-region packet scene)))

(defmethod load-region ((packet packet) (scene scene))
  (destructuring-bind (header info) (parse-sexps (packet-entry "meta.lisp" packet :element-type 'character))
    (let ((region (decode-region-payload
                   info (type-prototype 'region) packet
                   (destructuring-bind (&key identifier version) header
                     (assert (eql 'region identifier))
                     (coerce-version version)))))
      (enter region scene))))

(defmacro define-encoder ((type version) &rest args)
  (let ((version-instance (gensym "VERSION"))
        (object (gensym "OBJECT"))
        (method-combination (loop for option = (car args)
                                  until (listp option)
                                  collect (pop args))))
    (destructuring-bind ((buffer packet) &rest body) args
      (let ((buffer-name (unlist buffer)))
        `(defmethod encode-region-payload ,@method-combination ((,type ,type) ,buffer ,packet (,version-instance ,version))
           (flet ((encode (,object &optional (,buffer-name ,buffer-name))
                    (encode-region-payload ,object
                                           ,buffer-name
                                           ,(unlist packet)
                                           ,version-instance)))
             (declare (ignorable #'encode))
             ,@body))))))

(trivial-indent:define-indentation define-encoder (4 4 &body))

(defmacro define-decoder ((type version) &rest args)
  (let ((version-instance (gensym "VERSION"))
        (object (gensym "OBJECT"))
        (method-combination (loop for option = (car args)
                                  until (listp option)
                                  collect (pop args))))
    (destructuring-bind ((buffer packet) &rest body) args
      (let ((buffer-name (unlist buffer)))
        `(defmethod decode-region-payload ,@method-combination (,buffer (,type ,type) ,packet (,version-instance ,version))
           (flet ((decode (,object &optional (,buffer-name ,buffer-name))
                    (decode-region-payload ,buffer-name
                                           (if (symbolp ,object)
                                               (type-prototype ,object)
                                               ,object)
                                           ,(unlist packet)
                                           ,version-instance)))
             (declare (ignorable #'decode))
             ,@body))))))

(trivial-indent:define-indentation define-decoder (4 4 &body))
