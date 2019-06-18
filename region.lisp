(in-package #:org.shirakumo.fraf.leaf)

(defclass version () ())
(defclass v0 (version) ())

(defgeneric load-region (source scene))
(defgeneric save-region (scene target &key version &allow-other-keys))
(defgeneric decode-region-payload (source target version))
(defgeneric encode-region-payload (source target version))

(defmethod save-region (scene (pathname pathname) &key version (if-exists :supersede))
  (zip:with-output-to-zipfile (file pathname :if-exists if-exists)
    (save-region scene file :version version)))

(defmethod save-region (scene (file zip::zipwriter) &key version)
  ;; FIXME: metadata
  (let ((meta (make-sexp-stream `(:identifier region :version ,(type-of version))))
        (data (string-binary-stream (with-output-to-string (stream)
                                      (encode-region-payload scene stream version)))))
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
      (declare (ignore information))
      (decode-region-payload
       (zip:zipfile-entry-contents data)
       scene
       (destructuring-bind (&key identifier version) header
         (assert (eql 'region identifier))
         (coerce-version version))))))

(defun coerce-version (symbol)
  (flet ((bail () (error "No such version ~s." symbol)))
    (let* ((class (or (find-class symbol NIL) (bail))))
      (unless (subtypep class 'version) (bail))
      (make-instance class))))

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

(define-decoder (scene v0) (buffer)
  (destructuring-bind (&key name entities) (first (parse-sexp-vector buffer))
    (setf (slot-value scene 'name) name)
    (loop for (type . initargs) in entities
          do (enter (decode type initargs) scene))
    scene))

(define-encoder (scene v0) (stream)
  (with-leaf-io-syntax
    (write (list :name (name scene)
                 :entities (for:for ((entity over scene)
                                     (_ collecting (encode entity)))))
           :stream stream
           :case :downcase)))

(define-decoder (player v0) (initargs)
  (destructuring-bind (x y) (getf initargs :location)
    (make-instance 'player :location (vec2 x y))))

(define-encoder (player v0) (_)
  `(player :location ,(encode (location player))))

(define-decoder (chunk v0) (initargs)
  (destructuring-bind (&key name location size background tileset layers) initargs
    (make-instance 'chunk :name name
                          :location (vec2 (first location) (second location))
                          :size (cons (first size) (second size))
                          :tileset (asset (first tileset) (second tileset))
                          :background (asset (first tileset) (second tileset)))))

(define-encoder (chunk v0) (_)
  `(chunk :name ,(name chunk)
          :location ,(encode (location chunk))
          :size (,(car (size chunk)) ,(cdr (size chunk)))
          :tileset ,(encode (tileset chunk))
          :background ,(encode (background chunk))
          :layers ()))

(define-encoder (vec2 v0) (_)
  (list (vx vec2)
        (vy vec2)))

(define-encoder (asset v0) (_)
  (list (name (pool asset))
        (name asset)))
