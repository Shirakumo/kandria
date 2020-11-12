#|
sbcl --noinform --load "$0" --eval '(kandria-docs:generate)' --quit && exit
|#

#+quicklisp (ql:quickload '(cl-markless-plump lass lquery cl-ppcre clip) :silent T)

(defpackage #:kandria-docs
  (:use #:cl)
  (:export
   #:generate))
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
(defun suffix-p (suffix string)
  (and (<= (length suffix) (length string))
       (string= string suffix :start1 (- (length string) (length suffix)))))

(defun fixup-href (node)
  (let ((href (plump:attribute node "href")))
    (when (suffix-p ".mess" href)
      (setf (plump:attribute node "href") (format NIL "~a.html" (subseq href 0 (- (length href) (length ".mess"))))))
    node))

(defun generate ()
  (let* ((*package* #.*package*)
         (plump:*tag-dispatchers* plump:*html-tags*)
         (dom (clip:process (file "index" "ctml")))
         (doc (cl-markless:parse (file "press" "mess") (make-instance 'cl-markless:parser :embed-types (list* 'youtube cl-markless:*default-embed-types*)))))
    (cl-markless:output doc :target (lquery:$1 dom "main") :format (make-instance 'org.shirakumo.markless.plump:plump))
    (lquery:$ dom "a[href]" (each #'fixup-href))
    (loop for c across (cl-markless-components:children doc)
          do (when (and (typep c 'cl-markless-components:header)
                        (< (cl-markless-components:depth c) 3))
               (let ((link (plump:make-element (lquery:$1 dom "nav") "a")))
                 (plump:make-text-node link (cl-markless-components:text c))
                 (setf (plump:attribute link "href") (format NIL "#~(~a~)" (cl-markless-components:text c))))))
    (with-open-file (stream (file "index" "html")
                            :direction :output
                            :if-exists :supersede)
      (plump:serialize dom stream))))
