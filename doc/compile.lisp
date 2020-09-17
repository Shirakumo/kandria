#|
sbcl --noinform --load "$0" --eval '(generate-all)' --quit && exit
|#

(ql:quickload '(cl-markless-plump lass lquery) :silent T)

(defun style ()
  (lass:compile-and-write
   '(article
     :max-width 800px
     :font-size 12pt
     :font-family sans-serif
     :margin 3em auto
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

(defun suffix-p (suffix string)
  (and (<= (length suffix) (length string))
       (string= string suffix :start1 (- (length string) (length suffix)))))

(defun fixup-href (node)
  (let ((href (plump:attribute node "href")))
    (when (suffix-p ".mess" href)
      (setf (plump:attribute node "href") (format NIL "~a.html" (subseq href 0 (- (length href) (length ".mess"))))))
    node))

(defun generate (file)
  (let ((dom (plump:make-root)))
    (cl-markless:output (cl-markless:parse file T)
                        :target dom
                        :format (make-instance 'org.shirakumo.markless.plump:plump
                                               :css (style)))
    (lquery:$ dom "a[href]" (each #'fixup-href))
    (with-open-file (stream (make-pathname :type "html" :defaults file)
                            :direction :output
                            :if-exists :supersede)
      (plump:serialize dom stream))))

(defun generate-all ()
  (dolist (file (directory (make-pathname :name :wild :type "mess"
                                          :defaults #.(or *compile-file-pathname* *load-pathname* *default-pathname-defaults*))))
    (with-simple-restart (continue "Ignore ~a" file)
      (generate file))))
