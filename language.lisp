(in-package #:org.shirakumo.fraf.kandria)

(define-global +languages+
    (mapcar #'pathname-name
            (directory (merge-pathnames "world/lang/*.lisp" (root)))))

(define-global +language-data+ NIL)

(defun language-file (language)
  (merge-pathnames (make-pathname :name (string-downcase language)
                                  :type "lisp"
                                  :directory `(:relative "world" "lang"))
                   (root)))

(defun load-language (&optional (language (setting :language :code)))
  (let ((table (make-hash-table :test 'eq)))
    (v:info :kandria.language "Loading language ~s" language)
    (with-kandria-io-syntax
      (with-open-file (stream (language-file language))
        (loop for k = (read stream NIL)
              for v = (read stream NIL)
              while k
              do (setf (gethash k table) v))
        (setf +language-data+ table)))))

(defun save-language (&optional (language (setting :language :code)))
  (when +language-data+
    (v:info :kandria.language "Saving language ~s" language)
    (with-kandria-io-syntax
      (with-open-file (stream (language-file language)
                              :direction :output
                              :if-exists :supersede)
        (loop for k being the hash-keys of +language-data+
              for v being the hash-keys of +language-data+
              do (format stream "~s ~s~%" k v))))))

(declaim (inline language-string))
(defun language-string (identifier)
  (unless +language-data+ (load-language))
  (or (gethash identifier +language-data+)
      (error "No language string defined for ~s" identifier)))

(defun (setf language-string) (string identifier)
  (unless +language-data+ (load-language))
  (check-type string string)
  (check-type identifier symbol)
  (setf (gethash identifier +language-data+) string))

(defun @format (destination identifier &rest args)
  (format destination "~?" (language-string identifier) args))

(defun @formats (identifier &rest args)
  (format NIL "~?" (language-string identifier) args))

(defmacro @ (identifier)
    `(language-string ',identifier))

(set-dispatch-macro-character
 #\# #\@ (lambda (s c a)
           (declare (ignore c a))
           (language-string ,(read s T NIL T))))
