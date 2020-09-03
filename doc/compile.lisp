#|
sbcl --noinform --load "$0" --eval '(generate-all)' --quit && exit
|#

(ql:quickload '(cl-markless-plump lass) :silent T)

(defun style ()
  (lass:compile-and-write
   '(article
     :max-width 800px
     :margin 0 auto
     (h1
      :text-align center
      :font-size 2em)
     (img
      :margin 0 auto
      :max-width 100%)
     (blockquote
      :border-left 0.2em solid gray
      :margin-left 1em
      :padding-left 1em)
     (figcaption
      :padding 0.2em 1em
      :background (hex E0E0E0)))))

(defun generate (file)
  (handler-bind ((file-exists (lambda (e)
                                (declare (ignore e))
                                (invoke-restart 'supersede))))
    (cl-markless:output (cl-markless:parse file T)
                        :target (make-pathname :type "html" :defaults file)
                        :format (make-instance 'org.shirakumo.markless.plump:plump
                                               :css (style)))))

(defun generate-all ()
  (dolist (file (directory (make-pathname :name :wild :type "mess"
                                          :defaults #.(or *compile-file-pathname* *load-pathname* *default-pathname-defaults*))))
    (with-simple-restart (continue "Ignore ~a" file)
      (generate file))))
