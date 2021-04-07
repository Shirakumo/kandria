(defvar *latin-1* " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~¡¢£¤¥¦§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ")

(defun font-char-list (font)
  (with-output-to-string (stream)
    (sb-ext:run-program "fc-match" (list "--format=%{charset}" (pathname-name font)) :output stream :search T)))

(defun font-chars (font)
  (let ((parts (cl-ppcre:split " +" (font-char-list font)))
        (chars ()))
    (dolist (part parts chars)
      (let ((pos (position #\- part)))
        (if pos
            (loop for i from (parse-integer part :end pos :radix 16)
                  to (parse-integer part :start (1+ pos) :radix 16)
                  do (push (code-char i) chars))
            (push (code-char (parse-integer part :radix 16)) chars))))))

(defun generate-atlas (font &key (output #p"") (chars (font-chars font)))
  (let* ((charfile #p "/tmp/charfile.txt")
         (font (truename font)))
    (sb-posix:chdir (pathname-utils:to-directory output))
    (format T "~&Generating ~d chars..." (length chars))
    (with-open-file (stream charfile :direction :output :if-exists :supersede)
      (map NIL (lambda (c) (write-char c stream)) chars))
    (sb-ext:run-program "msdf-bmfont" (list "-f" "json"
                                            "-o" (pathname-name font)
                                            "-i" (namestring charfile)
                                            "-m" "1024,1024"
                                            (namestring font))
                        :search T :output *standard-output* :error *error-output*)
    (rename-file (make-pathname :name (pathname-name font) :type "json" :defaults output)
                 (make-pathname :name (or (pathname-name output) (pathname-name font)) :type "json" :defaults output))
    (rename-file (make-pathname :name (pathname-name font) :type "png" :defaults output)
                 (make-pathname :name (or (pathname-name output) (pathname-name font)) :type "png" :defaults output))))
