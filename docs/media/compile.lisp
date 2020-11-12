#|
sbcl --noinform --load "$0" --eval '(generate)' --quit && exit
|#

(defun generate-image (i o w h)
  (loop
     (with-simple-restart (retry "Retry generation")
       (format T "~&Compiling ~a...~%" i)
       (uiop:run-program (list "krita" (namestring i) "--export" "--export-filename" (namestring o)))
       (uiop:run-program (list "mogrify" "-resize" (format NIL "~dx~d" w h) (namestring o)))
       (return))))

(defun generate ()
  (loop for (f w h) in '(("header capsule" 231 87)
                         ("main capsule" 616 353)
                         ("background" 1438 810)
                         ("library capsule" 600 900)
                         ("library hero" 1920 620)
                         ("library logo" 640 360)
                         ("community icon" 32 32)
                         ("community capsule" 184 69))
        for k = (make-pathname :type "kra" :defaults f)
        for o = (make-pathname :type "png" :defaults f)
        do (when (or (null (probe-file o))
                     (< (file-write-date o) (file-write-date k)))
             (generate-image k o w h))))
