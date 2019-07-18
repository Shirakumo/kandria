(in-package #:org.shirakumo.fraf.leaf)

(defclass packet ()
  ((storage :initarg :storage :reader storage)
   (offset :initarg :offset :initform "" :accessor offset)))

(defgeneric entry-path (entry packet))
(defgeneric call-with-packet (function storage &key offset direction if-exists if-does-not-exist))
(defgeneric call-with-packet-entry (function entry packet &key element-type))
(defgeneric packet-entry (entry packet &key element-type))
(defgeneric (setf packet-entry) (data entry packet))
(defgeneric list-entries (offset packet))

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

(defmethod call-with-packet (function (pathname pathname) &key (offset "") direction (if-exists :error) (if-does-not-exist :create))
  (let ((direction (or direction :input)))
    (ecase direction
      (:input
       (ecase (if (probe-file pathname)
                  :create
                  if-does-not-exist)
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
                 (error "Don't know how to open ~s" pathname))))))
      (:output
       (ecase (if (probe-file pathname)
                  if-exists
                  :supersede)
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
                 (error "Don't know how to write ~s" pathname)))))))))

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

(defclass zip-packet (packet)
  ())

(defmethod call-with-packet (function (packet zip-packet) &key offset direction if-exists if-does-not-exist)
  (declare (ignore direction if-exists if-does-not-exist))
  ;; FIXME: what if offset is another packet?
  (make-instance (class-of packet) :offset (format NIL "~a/~a" (offset packet) offset)
                                   :storage (storage packet)))

(defmethod entry-path (entry (packet zip-packet))
  (format NIL "~a/~a" (offset packet)
          (etypecase entry
            (pathname (namestring entry))
            (string entry))))

(defmethod packet-entry (entry (packet zip-packet) &key element-type)
  (let ((element-type (or element-type '(unsigned-byte 8)))
        (file (zip:get-zipfile-entry (entry-path entry packet) (storage packet))))
    (unless file (error "No such entry ~s" entry))
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
    (unless entry (error 'file-error :pathname entry))
    (let ((contents (zip:zipfile-entry-contents entry)))
      (cond ((eql '(unsigned-byte 8) element-type)
             (funcall function (make-instance 'fast-io:fast-input-stream :vector contents)))
            ((subtypep element-type 'character)
             (with-input-from-string (stream (babel:octets-to-string contents :encoding :utf-8))
               (funcall function stream)))
            (T (error "Element-type ~s is unsupported." element-type))))))

(defmethod list-entries (offset (packet zip-read-packet))
  (loop with base = (offset packet)
        for entry in (zip:zipfile-entries (storage packet))
        for name = (zip:zipfile-entry-name entry)
        when (and (< (length base) (length name))
                  (string= base name :end2 (length base)))
        collect name))

(defclass dir-packet (packet)
  ((direction :initarg :direction :reader direction)))

(defmethod call-with-packet (function (packet dir-packet) &key offset direction if-exists if-does-not-exist)
  (declare (ignore direction if-exists if-does-not-exist))
  ;; FIXME: what if offset is another packet?
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

(defmethod list-entries (offset (packet dir-packet))
  (let ((base (entry-path offset packet)))
    (loop for path in (directory (merge-pathnames base pathname-utils:*wild-path*))
          collect (enough-namestring path (storage packet)))))

(defun current-version ()
  ;; KLUDGE: latest version should be determined automatically.
  (make-instance 'v0))

(defun ensure-version (version)
  (etypecase version
    (version version)
    ((eql T) (current-version))))

(defgeneric decode-payload (payload target packet version))
(defgeneric encode-payload (source payload packet version))

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
