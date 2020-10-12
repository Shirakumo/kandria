#|
sbcl --noinform --load "$0" --eval '(generate-all)' --quit && exit
|#

(ql:quickload '(cl-markless-plump lass lquery cl-ppcre) :silent T)

(defun youtube-code (url)
  (let ((pieces (nth-value 1 (cl-ppcre:scan-to-strings "((http|https)://)?(www\\.)?(youtube\\.com|youtu\\.be)/(watch\\?v=)?([0-9a-zA-Z_\\-]{4,12})" url))))
    (when pieces (aref pieces 5))))

(defclass youtube (cl-markless-components:video)
  ())

(defmethod cl-markless:output-component ((component youtube) (target plump-dom:nesting-node) (format cl-markless-plump:plump))
  (let ((element (plump-dom:make-element target "iframe")))
    (setf (plump-dom:attribute element "width") "100%")
    (setf (plump-dom:attribute element "height") "240")
    (setf (plump-dom:attribute element "frameborder") "no")
    (setf (plump-dom:attribute element "allowfullscreen") "yes")
    (setf (plump-dom:attribute element "src")
          (format NIL "//www.youtube.com/embed/~a?" (youtube-code (cl-markless-components:target component))))
    (loop for option in (cl-markless-components:options component)
          do (typecase option
               (cl-markless-components:autoplay-option
                (setf (plump-dom:attribute element "src")
                      (format NIL "~aautoplay=1&" (plump-dom:attribute element "src"))))
               (cl-markless-components:loop-option
                (setf (plump-dom:attribute element "src")
                      (format NIL "~aloop=1&" (plump-dom:attribute element "src"))))
               (cl-markless-components:width-option
                (setf (plump-dom:attribute element "width")
                      (format NIL "~d~(~a~)"
                              (cl-markless-components:size option)
                              (cl-markless-components:unit option))))
               (cl-markless-components:height-option
                (setf (plump-dom:attribute element "height")
                      (format NIL "~d~(~a~)"
                              (cl-markless-components:size option)
                              (cl-markless-components:unit option))))
               (cl-markless-components:float-option
                (setf (plump-dom:attribute element "style")
                      (format NIL "float:~(~a~)" (cl-markless-components:direction option))))))))

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
    (cl-markless:output (cl-markless:parse file (make-instance 'cl-markless:parser :embed-types (list* 'youtube cl-markless:*default-embed-types*)))
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
