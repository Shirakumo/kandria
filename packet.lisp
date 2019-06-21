(in-package #:org.shirakumo.fraf.leaf)

(defun parse-sexp-vector (vector)
  (with-leaf-io-syntax
    (loop with eof = (make-symbol "EOF")
          with string = (babel:octets-to-string vector :encoding :utf-8)
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
