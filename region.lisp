(in-package #:org.shirakumo.fraf.leaf)

(defclass region (container-unit)
  ((objects :initform NIL)
   (author :initform "Anonymous" :initarg :author :accessor author)
   (version :initform "0.0.0" :initarg :version :accessor version)
   (description :initform "" :initarg :description :accessor description)
   (preview :initform NIL :initarg :preview :accessor preview)))

(defmethod initialize-instance :after ((region region) &key (layers 5))
  (let ((objects (make-array layers)))
    (dotimes (i layers)
      (setf (aref objects i) (make-array 0 :adjustable T :fill-pointer T)))
    (setf (objects region) objects)))

(defgeneric layer-index (unit))

(defmethod layer-index ((unit unit)) 0)

(defmethod enter ((unit unit) (region region))
  (let ((layer (+ (layer-index unit)
                  (floor (length (objects region)) 2))))
    (vector-push-extend unit (aref (objects region) layer))))

(defmethod enter ((chunk chunk) (region region))
  (dotimes (layer (length (objects region)))
    (vector-push-extend chunk (aref (objects region) layer))))

(defmethod leave ((unit unit) (region region))
  (let ((layer (+ (layer-index unit)
                  (floor (length (objects region)) 2))))
    (array-utils:vector-pop-position*
     (aref (objects region) layer)
     (position unit (aref (objects region) layer)))))

(defmethod leave ((chunk chunk) (region region))
  (dotimes (layer (length (objects region)))
    (array-utils:vector-pop-position*
     (aref (objects region) layer)
     (position chunk (aref (objects region) layer)))))

(defclass region-iterator (for:iterator)
  ((layer :initarg :layer :accessor layer)
   (start :initform 0 :accessor start)))

(defmethod for:has-more ((iterator region-iterator))
  (< (layer iterator) (length (for:object iterator))))

(defmethod for:next ((iterator region-iterator))
  (let ((layer (aref (for:object iterator) (layer iterator))))
    (prog1 (aref layer (start iterator))
      (incf (start iterator))
      (when (<= (length layer) (start iterator))
        (setf (start iterator) 0)
        (loop for i from (1+ (layer iterator)) below (length (for:object iterator))
              while (= 0 (length (aref (for:object iterator) i)))
              finally (setf (layer iterator) i))))))

(defmethod (setf for:current) ((unit unit) (iterator region-iterator))
  (setf (aref (aref (for:object iterator) (layer iterator))
              (start iterator))
        unit))

(defmethod for:make-iterator ((region region) &key)
  (make-instance 'region-iterator
                 :object (objects region)
                 :layer (or (position 0 (objects region) :key #'length :test-not #'=)
                            MOST-POSITIVE-FIXNUM)))

(defclass version () ())

(defun coerce-version (symbol)
  (flet ((bail () (error "No such version ~s." symbol)))
    (let* ((class (or (find-class symbol NIL) (bail))))
      (unless (subtypep class 'version) (bail))
      (make-instance class))))

(defgeneric load-region (source scene))
(defgeneric save-region (region target &key version &allow-other-keys))
(defgeneric decode-region-payload (source target version))
(defgeneric encode-region-payload (source target version))

(defmethod save-region :around (region target &rest args &key (version T))
  (cond ((eql T version)
         ;; KLUDGE: latest version should be determined automatically.
         (apply #'call-next-method region target :version (make-instance 'v0) args))
        ((typep version 'version)
         (call-next-method))
        (T
         (error "VERSION must be an instance of VERSION or T."))))

(defmethod save-region (region (pathname pathname) &key version (if-exists :supersede))
  (zip:with-output-to-zipfile (file pathname :if-exists if-exists)
    (save-region region file :version version)))

(defmethod save-region (region (file zip::zipwriter) &key version)
  ;; FIXME: preview
  (let ((meta (make-sexp-stream (list :identifier 'region
                                      :version (type-of version))
                                (list :author (author region)
                                      :version (version region)
                                      :description (description region))))
        (data (string-binary-stream (with-output-to-string (stream)
                                      (encode-region-payload region stream version)))))
    (zip:write-zipentry file "meta.lisp" meta :file-write-date (get-universal-time))
    (zip:write-zipentry file "data" data :file-write-date (get-universal-time))))

(defmethod load-region ((pathname pathname) scene)
  (zip:with-zipfile (file pathname)
    (load-region file scene)))

(defmethod load-region ((file zip:zipfile) scene)
  (let ((meta (zip:get-zipfile-entry "meta.lisp" file))
        (data (zip:get-zipfile-entry "data" file)))
    (unless (or meta data)
      (error "Malformed region file."))
    (destructuring-bind (header information)
        (parse-sexp-vector (zip:zipfile-entry-contents meta))
      (let ((region (apply #'make-instance 'region information)))
        (enter region scene)
        (decode-region-payload
         (zip:zipfile-entry-contents data)
         region
         (destructuring-bind (&key identifier version) header
           (assert (eql 'region identifier))
           (coerce-version version)))))))

(defun parse-sexp-vector (vector)
  (loop with eof = (make-symbol "EOF")
        with string = (babel:octets-to-string vector :encoding :utf-8)
        with i = 0
        collect (multiple-value-bind (data next) (read-from-string string NIL EOF :start i)
                  (setf i next)
                  (if (eql data EOF)
                      (loop-finish)
                      data))))

(defun string-binary-stream (string)
  (make-instance 'fast-io:fast-input-stream
                 :vector (babel:string-to-octets string :encoding :utf-8)))

(defun make-sexp-stream (&rest expressions)
  (string-binary-stream (with-output-to-string (stream)
                          (with-leaf-io-syntax
                            (dolist (expr expressions)
                              (write expr :stream stream :case :downcase))))))

(defmacro define-encoder ((type version) &rest args)
  (let ((version-instance (gensym "VERSION"))
        (object (gensym "OBJECT"))
        (method-combination (loop for option = (car args)
                                  until (listp option)
                                  collect (pop args))))
    (destructuring-bind ((buffer) &rest body) args
      `(defmethod encode-region-payload ,@method-combination ((,type ,type) ,buffer (,version-instance ,version))
         (flet ((encode (,object)
                  (encode-region-payload ,object ,buffer ,version-instance)))
           (declare (ignorable #'encode))
           ,@body)))))

(trivial-indent:define-indentation define-encoder (4 4 &body))

(defmacro define-decoder ((type version) &rest args)
  (let ((version-instance (gensym "VERSION"))
        (object (gensym "OBJECT"))
        (method-combination (loop for option = (car args)
                                  until (listp option)
                                  collect (pop args))))
    (destructuring-bind ((buffer) &rest body) args
      `(defmethod decode-region-payload ,@method-combination (,buffer (,type ,type) (,version-instance ,version))
         (flet ((decode (,object &optional (,buffer ,buffer))
                  (decode-region-payload ,buffer
                                         (if (symbolp ,object)
                                             (type-prototype ,object)
                                             ,object)
                                         ,version-instance)))
           (declare (ignorable #'decode))
           ,@body)))))

(trivial-indent:define-indentation define-decoder (4 4 &body))
