#|
sbcl --noinform --load "$0" --eval '(kandria-docs:generate-all)' --quit && exit
|#

#+quicklisp (ql:quickload '(cl-markless-plump lass lquery cl-ppcre clip drakma) :silent T)

(defpackage #:kandria-docs
  (:use #:cl)
  (:export
   #:generate-documentation
   #:generate-website
   #:generate-press
   #:generate-all))
(in-package #:kandria-docs)

(defvar *here* #.(or *compile-file-pathname*
                     *load-pathname*
                     (error "LOAD this file.")))

(defun file (name type)
  (make-pathname :name name :type type :defaults *here*))

;;;; Markless extension for YouTube embeds
(defun youtube-code (url)
  (let ((pieces (nth-value 1 (cl-ppcre:scan-to-strings "((http|https)://)?(www\\.)?(youtube\\.com|youtu\\.be)/(watch\\?v=)?([0-9a-zA-Z_\\-]{4,12})" url))))
    (when pieces (aref pieces 5))))

(defclass youtube (cl-markless-components:video)
  ())

(defmethod cl-markless:output-component ((component youtube) (target plump-dom:nesting-node) (format cl-markless-plump:plump))
  (let ((element (plump-dom:make-element target "iframe")))
    (setf (plump-dom:attribute target "class") "video")
    (setf (plump-dom:attribute element "width") "100%")
    (setf (plump-dom:attribute element "height") "460")
    (setf (plump-dom:attribute element "frameborder") "no")
    (setf (plump-dom:attribute element "allowfullscreen") "yes")
    (setf (plump-dom:attribute element "src")
          (format NIL "https://www.youtube.com/embed/~a?" (youtube-code (cl-markless-components:target component))))
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

;;;; Compiling documentation pages
(defun style ()
  (lass:write-sheet
   (lass:compile-sheet
    '(article
      :max-width 900px
      :font-size 12pt
      :font-family sans-serif
      :margin 0 auto
      :padding 3em 1em 1em 1em
      :background (hex FAFAFA)
      :color (hex 050505)
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
       :background (hex E0E0E0))
      (code
       :background (hex F0F0F0)
       :padding 0 0.1em)
      (.code-block
       :padding 0.1em 0.5em)))
   :pretty NIL))

(defun suffix-p (suffix string)
  (and (<= (length suffix) (length string))
       (string= string suffix :start1 (- (length string) (length suffix)))))

(defun fixup-href (node)
  (let ((href (plump:attribute node "href")))
    (when (suffix-p ".mess" href)
      (setf (plump:attribute node "href") (format NIL "~a.html" (subseq href 0 (- (length href) (length ".mess"))))))
    node))

(defun generate-documentation (file)
  (let ((dom (plump:parse (file "doc-template" "html")))
        (article (cl-markless:parse file (make-instance 'cl-markless:parser :embed-types (list* 'youtube cl-markless:*default-embed-types*)))))
    (cl-markless:output article
                        :target (lquery:$1 dom "body")
                        :format (make-instance 'org.shirakumo.markless.plump:plump :css (style)))
    (lquery:$ dom "a[href]" (each #'fixup-href))
    (lquery:$ dom "title" (text (lquery:$1 dom "h1" (text))))
    (lquery:$ dom "meta[name=twitter:title],meta[property=og:title]" (attr :content (lquery:$1 dom "h1" (text))))
    (lquery:$ dom "meta[name=twitter:description],meta[property=og:description]" (attr :content (lquery:$1 dom "p" (text))))
    (lquery:$ dom "meta[name=twitter:image],meta[property=og:image]" (attr :content (lquery:$1 dom "img" (attr :src))))
    (with-open-file (stream (make-pathname :type "html" :defaults file)
                            :direction :output
                            :if-exists :supersede)
      (plump:serialize dom stream))))

;;;; Compiling the website
(defun process (in out &rest args)
  (with-open-file (stream out :direction :output
                              :if-exists :supersede)
    (let ((*package* #.*package*)
          (plump:*tag-dispatchers* plump:*html-tags*))
      (plump:serialize (apply #'clip:process in args) stream))))

(defun process-content (content)
  (let ((plump:*tag-dispatchers* plump:*html-tags*))
    (lquery:$1 (inline (plump:parse content))
      "p")))

(defun max-array (array n)
  (if (<= (length array) n)
      array
      (subseq array 0 n)))

(defun fetch-updates (&optional (url "https://tymoon.eu/api/reader/atom?tag=kandria"))
  (let ((plump:*tag-dispatchers* plump:*xml-tags*)
        (drakma:*text-content-types* '(("application" . "atom+xml"))))
    (lquery:$ (initialize (drakma:http-request url))
      "entry" (map (lambda (entry)
                     (list :title (lquery:$1 entry "title" (text))
                           :url (lquery:$1 entry "link" (attr :href))
                           :time (subseq (lquery:$1 entry "published" (text)) 0 (length "2020-02-04"))
                           :excerpt (process-content (lquery:$1 entry "content" (text)))))))))

(defun generate-press ()
  (flet ((file (name type)
           (merge-pathnames "press/" (file name type))))
    (let* ((*package* #.*package*)
           (plump:*tag-dispatchers* plump:*html-tags*)
           (dom (clip:process (file "index" "ctml")))
           (doc (cl-markless:parse (file "press" "mess") (make-instance 'cl-markless:parser :embed-types (list* 'youtube cl-markless:*default-embed-types*)))))
      (cl-markless:output doc :target (lquery:$1 dom "main") :format (make-instance 'org.shirakumo.markless.plump:plump))
      (lquery:$ dom "a[href]" (each #'fixup-href))
      (lquery:$ dom "img" (wrap "<a>") (combine (parent) (attr :src)) (map-apply (lambda (n u) (lquery:$ n (attr :href u)))))
      (loop for c across (cl-markless-components:children doc)
            do (when (and (typep c 'cl-markless-components:header)
                          (< (cl-markless-components:depth c) 3))
                 (let ((link (plump:make-element (lquery:$1 dom "nav") "a")))
                   (plump:make-text-node link (cl-markless-components:text c))
                   (setf (plump:attribute link "href") (format NIL "#~(~a~)" (cl-markless-components:text c))))))
      (with-open-file (stream (file "index" "html")
                              :direction :output
                              :if-exists :supersede)
        (plump:serialize dom stream)))))

(defun generate-website ()
  (process (file "index" "ctml") (file "index" "html")
           :updates (handler-case (max-array (fetch-updates) 3)
                      (usocket:ns-try-again-condition ()))))

(defun generate-all ()
  (generate-press)
  (dolist (file (directory (file :wild "mess")))
    (with-simple-restart (continue "Ignore ~a" file)
      (generate-documentation file))))
