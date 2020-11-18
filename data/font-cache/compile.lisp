#|
sbcl --noinform --load "$0" --eval "(generate-bmfont $1)" --quit && exit
|#

(defun query-chars (font)
  (uiop:run-program (list "fc-match" "--format=%{charset}" font) :output :string))

(defun query-file (font)
  (uiop:run-program (list "fc-match" "--format=%{file}" font) :output :string))

(defun split (char string)
  (let ((buffer (make-string-output-stream))
        (parts ()))
    (flet ((out ()
             (let ((string (get-output-stream-string buffer)))
               (when (string/= "" string)
                 (push string parts)))))
      (loop for c across string
            do (if (char= c char)
                   (out)
                   (write-char c buffer)))
      (nreverse parts))))

(defun normalize-charlist (parts)
  (let ((nums ()))
    (dolist (part parts (sort nums #'<))
      (let ((dash (position #\- part)))
        (if dash
            (loop for i from (parse-integer part :radix 16 :end dash)
                  to (parse-integer part :radix 16 :start (1+ dash))
                  do (push i nums))
            (push (parse-integer part :radix 16) nums))))))

(defun charset (font)
  (mapcar #'code-char (normalize-charlist (split #\Space (query-chars font)))))

(defun write-charset (charset output)
  (with-open-file (stream output :direction :output
                                 :if-exists :supersede
                                 :external-format :utf-8)
    (write-sequence charset stream)
    output))

(defun generate-bmfont (font &key (size '(2048 2048)) (charset (charset font)))
  (let ((tmp "/tmp/charset.txt"))
    (destructuring-bind (w h) size
      (write-charset charset tmp)
      (uiop:run-program (list "msdf-bmfont" "-f" "json" "-o" font "-i" tmp "-m" (format NIL "~d,~d" w h) (query-file font))
                        :output T :error-output T))))
