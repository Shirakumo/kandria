(in-package #:org.shirakumo.fraf.leaf)

(defclass version () ())

(define-condition serializer-error ()
  ((version :initarg :version :reader version)))

(define-condition no-applicable-decoder (serializer-error)
  ((target :initarg :target :reader target))
  (:report (lambda (c s) (format s "No decoder for the target under ~a~%  ~a"
                                 (version c) (target c)))))

(define-condition no-applicable-encoder (serializer-error)
  ((source :initarg :source :reader source))
  (:report (lambda (c s) (format s "No encoder for the source under ~a~%  ~a"
                                 (version c) (source c)))))

(defun current-version ()
  ;; KLUDGE: latest version should be determined automatically.
  (make-instance 'v0))

(defun coerce-version (symbol)
  (flet ((bail () (error "No such version ~s." symbol)))
    (let* ((class (or (find-class symbol NIL) (bail))))
      (unless (subtypep class 'version) (bail))
      (make-instance class))))

(defun ensure-version (version &optional (default (current-version)))
  (etypecase version
    (version version)
    ((eql T) default)
    (symbol (coerce-version version))))

(defgeneric decode-payload (payload target packet version))
(defgeneric encode-payload (source payload packet version))

(defmethod decode-payload (payload target packet (version version))
  (error 'no-applicable-decoder :target target :version version))

(defmethod encode-payload (source payload packet (version version))
  (error 'no-applicable-encoder :source source :version version))

(defmacro define-encoder ((type version) &rest args)
  (let ((object (gensym "OBJECT"))
        (method-combination (loop for option = (car args)
                                  until (listp option)
                                  collect (pop args))))
    (destructuring-bind (version-instance version) (enlist version version)
      (destructuring-bind ((buffer packet) &rest body) args
        (let ((buffer-name (unlist buffer)))
          `(defmethod encode-payload ,@method-combination ((,type ,type) ,buffer ,packet (,version-instance ,version))
             (flet ((encode (,object &optional (,buffer-name ,buffer-name))
                      (encode-payload ,object
                                      ,buffer-name
                                      ,(unlist packet)
                                      ,version-instance)))
               (declare (ignorable #'encode))
               ,@body)))))))

(trivial-indent:define-indentation define-encoder (4 4 &body))

(defmacro define-decoder ((type version) &rest args)
  (let ((object (gensym "OBJECT"))
        (method-combination (loop for option = (car args)
                                  until (listp option)
                                  collect (pop args))))
    (destructuring-bind (version-instance version) (enlist version version)
      (destructuring-bind ((buffer packet) &rest body) args
        (let ((buffer-name (unlist buffer)))
          `(defmethod decode-payload ,@method-combination (,buffer (,type ,type) ,packet (,version-instance ,version))
             (flet ((decode (,object &optional (,buffer-name ,buffer-name))
                      (decode-payload ,buffer-name
                                      (if (symbolp ,object)
                                          (type-prototype ,object)
                                          ,object)
                                      ,(unlist packet)
                                      ,version-instance)))
               (declare (ignorable #'decode))
               ,@body)))))))

(trivial-indent:define-indentation define-decoder (4 4 &body))
