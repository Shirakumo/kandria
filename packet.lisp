(in-package #:org.shirakumo.fraf.leaf)

(defclass packet ()
  ((storage :initarg :storage :reader storage)
   (offset :initarg :offset :initform "" :accessor offset)))

(defgeneric entry-path (entry packet))
(defgeneric call-with-packet (function storage &key offset direction if-exists if-does-not-exist))
(defgeneric call-with-packet-entry (function entry packet &key element-type))
(defgeneric packet-entry (entry packet &key element-type))
(defgeneric (setf packet-entry) (data entry packet))

(defmacro with-packet ((packet storage &rest args) &body body)
  (let ((thunk (gensym "THUNK")))
    `(flet ((,thunk (,packet)
              ,@body))
       (call-with-packet #',thunk ,storage ,@args))))

(defmacro with-packet-entry ((stream entry packet &rest args) &body body)
  (let ((thunk (gensym "THUNK")))
    `(flet ((,thunk (,stream)
              ,@body))
       (call-with-packet-entry #',thunk ,entry ,packet ,@args))))

(defmethod call-with-packet (function (pathname pathname) &key offset direction (if-exists :error) (if-does-not-exist :create))
  (let ((direction (or direction :input)))
    (ecase direction
      (:input
       (unless (probe-file pathname)
         (ecase if-does-not-exist
           (:error (error 'file-error :pathname pathname))
           ((NIL) (funcall function NIL))
           (:create
            (cond ((equal "zip" (pathname-type pathname))
                   (zip:with-zipfile (zip pathname)
                     (funcall function (make-instance 'zip-read-packet
                                                      :storage zip
                                                      :offset offset))))
                  ((pathname-utils:directory-p pathname)
                   (funcall function (make-instance 'dir-packet
                                                    :direction :input
                                                    :storage pathname
                                                    :offset offset)))
                  (T
                   (error "Don't know how to open ~s" pathname)))))))
      (:output
       (when (probe-file pathname)
         (ecase if-exists
           (:error (error 'file-error :pathname pathname))
           ((NIL) (funcall function NIL))
           ((:new-version :rename :rename-and-delete :overwrite :append :supersede)
            (cond ((equal "zip" (pathname-type pathname))
                   (zip:with-output-to-zipfile (zip pathname :if-exists if-exists)
                     (funcall function (make-instance 'zip-write-packet
                                                      :storage zip
                                                      :offset offset))))
                  ((pathname-utils:directory-p pathname)
                   (funcall function (make-instance 'dir-packet
                                                    :direction :output
                                                    :storage pathname
                                                    :offset offset)))
                  (T
                   (error "Don't know how to write ~s" pathname))))))))))

(defmethod packet-entry (name (packet packet) &key element-type)
  (with-packet-entry (stream name packet :element-type element-type)
    (let ((sequence (make-array (file-length stream) :element-type (stream-element-type stream))))
      (loop for start = 0 then read
            for read = (read-sequence sequence stream :start start)
            while (< read (length sequence)))
      sequence)))

(defmethod (setf packet-entry) ((data stream) name (packet packet))
  (with-open-stream (data data)
    (with-packet-entry (output name packet :element-type (stream-element-type data))
      (loop with buffer = (make-array 4096 :element-type (stream-element-type data))
            for end = (read-sequence buffer data)
            until (= 0 end)
            do (write-sequence buffer output :end end)))))

(defmethod (setf packet-entry) ((data vector) name (packet packet))
  (with-packet-entry (stream name packet :element-type (array-element-type data))
    (write-sequence data stream)))

(defclass zip-packet ()
  ())

(defmethod call-with-packet (function (packet zip-packet) &key offset)
  (make-instance (class-of packet) :offset (format NIL "~a/~a" (offset packet) offset)
                                   :storage (storage packet)))

(defmethod entry-path (entry (packet zip-packet))
  (format NIL "~a/~a" (offset packet) entry))

(defmethod packet-entry (entry (packet zip-packet) &key element-type)
  (let ((element-type (or element-type '(unsigned-byte 8)))
        (file (zip:get-zipfile-entry (entry-path entry packet) (storage packet))))
    (unless file (error "No such entry ~s" name))
    (let ((content (zip:zipfile-entry-contents file)))
      (cond ((eql '(unsigned-byte 8) element-type)
             content)
            ((subtypep element-type 'character)
             (babel:octets-to-string content :encoding :utf-8))
            (T (error "Element-type ~s is unsupported." element-type))))))

(defmethod (setf packet-entry) ((data stream) entry (packet zip-packet))
  (zip:write-zipentry (storage packet) (entry-path entry packet) data :file-write-date (get-universal-time)))

(defmethod (setf packet-entry) ((data vector) entry (packet zip-packet))
  (setf (packet-entry entry packet) (make-instance 'fast-io:fast-input-stream :vector data)))

(defmethod (setf packet-entry) ((data string) entry (packet zip-packet))
  (setf (packet-entry entry packet) (babel:string-to-octets data :encoding :utf-8)))

(defclass zip-write-packet (zip-packet)
  ())

(defmethod call-with-packet-entry (function entry (packet zip-write-packet) &key element-type)
  (let ((element-type (or element-type '(unsigned-byte 8))))
    (zip:write-zipentry
     (storage packet) (entry-path entry packet)
     (cond ((eql '(unsigned-byte 8) element-type)
            (let ((stream (make-instance 'fast-io:fast-output-stream)))
              (funcall function stream)
              (make-instance 'fast-io:fast-input-stream :vector (fast-io:finish-output-stream stream))))
           ((subtypep element-type 'character)
            (let ((string (with-output-to-string (stream NIL :element-type element-type)
                            (funcall function stream))))
              (make-string-input-stream string)))
           (T (error "Element-type ~s is unsupported." element-type)))
     :file-write-date (get-universal-time))))

(defclass zip-read-packet (zip-packet)
  ())

(defmethod call-with-packet-entry (function entry (packet zip-read-packet) &key element-type)
  (let ((element-type (or element-type '(unsigned-byte 8)))
        (entry (zip:get-zipfile-entry (entry-path entry packet) (storage packet))))
    (unless entry (error 'file-error :pathname name))
    (let ((contents (zip:zipfile-entry-contents entry)))
      (cond ((eql '(unsigned-byte 8) element-type)
             (funcall function (make-instance 'fast-io:fast-input-stream :vector contents)))
            ((subtypep element-type 'character)
             (with-input-from-string (stream (babel:octets-to-string contents :encoding :utf-8))
               (funcall function stream)))
            (T (error "Element-type ~s is unsupported." element-type))))))

(defclass dir-packet ()
  ((direction :initarg :direction :reader direction)))

(defmethod call-with-packet (function (packet dir-packet) &key offset)
  (make-instance (class-of packet) :offset (format NIL "~a/~a/" (offset packet) offset)
                                   :direction (direction packet)
                                   :storage (storage packet)))

(defmethod entry-path (entry (packet dir-packet))
  (merge-pathnames entry (merge-pathnames (offset packet) (storage packet))))

(defmethod call-with-packet-entry (function entry (packet dir-packet) &key element-type)
  (with-open-file (stream (entry-path entry packet)
                          :direction (direction packet)
                          :element-type (or element-type '(unsigned-byte 8))
                          :if-exists :supersede)
    (funcall function stream)))

(defun parse-sexps (string)
  (with-leaf-io-syntax
      (loop with eof = (make-symbol "EOF")
            with i = 0
            collect (multiple-value-bind (data next) (read-from-string string NIL EOF :start i)
                      (setf i next)
                      (if (eql data EOF)
                          (loop-finish)
                          data)))))

(defun string-binary-stream (string)
  (make-instance 'fast-io:fast-input-stream
                 :vector (babel:string-to-octets string :encoding :utf-8)))

(defun make-sexp-stream (&rest expressions)
  (string-binary-stream (with-output-to-string (stream)
                          (with-leaf-io-syntax
                              (dolist (expr expressions)
                                (write expr :stream stream :case :downcase)
                                (fresh-line stream))))))

(defmethod load-packet-file :around (packet name (type (eql T)))
  (load-packet-file packet name (kw (pathname-type name))))

(defmethod load-packet-file (packet name type)
  (error "Don't know how to load a file of type ~d." type))

(defmethod load-packet-file ((dir pathname) name type)
  (with-open-file (stream (merge-pathnames name dir) :element-type '(unsigned-byte 8))
    (load-packet-file stream name type)))

(defmethod load-packet-file ((zip zip:zipfile) name type)
  (load-packet-file (or (zip:get-zipfile-entry name zip)
                        (error "No such file in packet: ~a" name))
                    name type))

(defmethod load-packet-file ((zip zip::zipfile-entry) name type)
  (load-packet-file (zip:zipfile-entry-contents zip) name type))

(defmethod load-packet-file ((vector vector) name type)
  (load-packet-file (make-instance 'fast-io:fast-input-stream :vector vector) name type))

(defmethod load-packet-file ((stream stream) name (type (eql :png)))
  (pngload:data (pngload:load-stream stream :flatten T)))

(defmethod load-packet-file ((vector vector) name (type (eql :raw)))
  vector)
