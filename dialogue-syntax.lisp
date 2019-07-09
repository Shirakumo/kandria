(defpackage #:org.shirakumo.fraf.leaf.dialogue.components
  (:export
   #:jump
   #:placeholder
   #:form
   #:emote
   #:conditional-part
   #:choices
   #:conditional-header
   #:conditional-branch
   #:go))

(defpackage #:org.shirakumo.fraf.leaf.dialogue
  (:use #:cl)
  (:local-nicknames
   (#:components #:org.shirakumo.fraf.leaf.dialogue.components)
   (#:markless-components #:org.shirakumo.markless.components)
   (#:markless #:org.shirakumo.markless))
  (:export
   #:parser
   #:jump
   #:placeholder
   #:emote
   #:conditional-part
   #:conditional-header
   #:conditional-branch))

(in-package #:org.shirakumo.fraf.leaf.dialogue)

(defclass parser (markless:parser)
  ()
  (:default-initargs :directives (list* 'jump 'placeholder 'emote 'conditional-part
                                        'conditional-part-separator
                                        'conditional-header
                                        'conditional-branch
                                        markless:*default-directives*)))

(defclass components:jump (markless-components:block-component)
  ((markless-components:target
    :initarg :target
    :initform (cl:error "TARGET required")
    :accessor markless-components:target)))

(defclass jump (markless:singular-line-directive)
  ())

(defmethod markless:prefix ((_ jump))
  #("<" " "))

(defmethod markless:begin ((_ jump) parser line cursor)
  (let ((component (make-instance 'components:jump :target (subseq line (+ 2 cursor)))))
    (markless:commit _ component parser))
  (length line))

(defclass components:conditional-header (markless-components:block-component)
  ((components:form
    :initarg :form
    :initform (error "FORM required")
    :accessor components:form)))

(defclass conditional-header (markless:singular-line-directive)
  ())

(defmethod markless:prefix ((_ conditional-header))
  #("?" " "))

(defmethod markless:begin ((_ conditional-header) parser line cursor)
  (multiple-value-bind (form cursor) (read-from-string line T NIL :start (+ 2 cursor))
    (when (< cursor (length line))
      (error 'markless:parser-error :cursor cursor))
    (let ((component (make-instance 'components:conditional-header :form form)))
      (markless:commit _ component parser)))
  (length line))

(defclass components:conditional-branch (markless-components:block-component)
  ((components:form
    :initarg :form
    :accessor components:form)))

(defclass conditional-branch (markless:singular-line-directive)
  ())

(defmethod markless:prefix ((_ conditional-branch))
  #("|" "?"))

(defmethod markless:begin ((_ conditional-branch) parser line cursor)
  (if (< (+ 2 cursor) (length line))
      (multiple-value-bind (form cursor) (read-from-string line T NIL :start (+ 2 cursor))
        (when (< cursor (length line))
          (error 'markless:parser-error :cursor cursor))
        (let ((component (make-instance 'components:conditional-branch :form form)))
          (markless:commit _ component parser)))
      (let ((component (make-instance 'components:conditional-branch)))
        (markless:commit _ component parser)))
  (length line))

(defclass components:placeholder (markless-components:inline-component)
  ((components:form
    :initarg :form
    :initform (error "FORM required")
    :accessor components:form)))

(defvar *placeholder-readtable* (copy-readtable))

(set-macro-character #\} (lambda (stream char)
                           (declare (ignore char))
                           (error 'reader-error :stream stream))
                     NIL *placeholder-readtable*)

(defclass placeholder (markless:inline-directive)
  ())

(defmethod markless:prefix ((_ placeholder))
  #("{"))

(defmethod markless:begin ((_ placeholder) parser line cursor)
  (let ((*readtable* *placeholder-readtable*))
    (multiple-value-bind (form cursor) (read-from-string line T NIL :start (1+ cursor))
      (let* ((entry (markless:stack-top (markless:stack parser)))
             (children (markless-components:children (markless:stack-entry-component entry))))
        (vector-push-extend (make-instance 'components:placeholder :form form) children)
        (unless (char= #\} (aref line cursor))
          (error 'markless:parser-error :cursor cursor))
        (+ 1 cursor)))))

(defclass components:emote (markless-components:inline-component)
  ((components:emote
    :initarg :emote
    :initform (error "EMOTE required")
    :accessor components:emote)))

(defclass emote (markless:inline-directive)
  ())

(defmethod markless:prefix ((_ emote))
  #("(" ":"))

(defmethod markless:begin ((_ emote) parser line cursor)
  (let* ((entry (markless:stack-top (markless:stack parser)))
         (children (markless-components:children (markless:stack-entry-component entry)))
         (end (loop for i from (+ 2 cursor) below (length line)
                    do (when (char= #\) (char line i))
                         (return i)))))
    (unless end
      (error 'markless:parser-error :cursor cursor))
    (vector-push-extend (make-instance 'components:emote :emote (subseq line cursor end)) children)
    (+ 1 end)))

(defclass components:conditional-part (markless-components:inline-component)
  ((components:form
    :initarg :form
    :initform (error "FORM required")
    :accessor components:form)
   (components:choices
    :initform (make-array 0 :adjustable T :fill-pointer T)
    :accessor components:choices)))

(defmethod markless-components:children ((_ components:conditional-part))
  (aref (components:choices _) (1- (length (components:choices _)))))

(defmethod markless:output-component ((c components:conditional-part) (s stream) (f markless:debug))
  (format s "/~a" (type-of c))
  (let ((markless::*level* (1+ markless::*level*)))
    (loop for children across (components:choices c)
          do (loop for child across children
                   do (markless:output-component child s f))
             (let ((markless::*level* (1- markless::*level*)))
               (markless:output-component "--" s f)))))

(defclass conditional-part-separator (markless:inline-directive)
  ())

(defmethod markless:prefix ((_ conditional-part-separator))
  #("|"))

(defmethod markless:begin ((_ conditional-part-separator) parser line cursor)
  (let* ((component (markless:stack-entry-component (markless:stack-top (markless:stack parser)))))
    (if (typep component 'components:conditional-part)
        (vector-push-extend (make-array 0 :adjustable T :fill-pointer T) (components:choices component))
        (vector-push-extend "|" (markless-components:children component)))
    (+ 1 cursor)))

(defclass conditional-part (markless:inline-directive)
  ())

(defmethod markless:prefix ((_ conditional-part))
  #("["))

(defmethod markless:begin ((_ conditional-part) parser line cursor)
  (multiple-value-bind (form cursor) (read-from-string line T NIL :start cursor)
    (let ((component (make-instance 'components:conditional-part :form form)))
      (vector-push-extend (make-array 0 :adjustable T :fill-pointer T) (components:choices component))
      (markless:commit _ component parser))
    cursor))

(defmethod markless:invoke ((_ conditional-part) component parser line cursor)
  (markless:read-inline parser line cursor #\]))

(defmethod markless:consume-end ((_ conditional-part) component parser line cursor)
  (markless:match! "]" line cursor))

(defmethod markless:end :after ((_ conditional-part) component parser)
  ;; FIXME
  (markless::vector-push-front "[" (markless-components:children component)))


(defclass components:go (markless-components:instruction)
  ((markless-components:target
    :initarg :target
    :initform (cl:error "TARGET required")
    :accessor markless-components:target)))

(defmethod markless:parse-instruction ((proto components:go) line cursor)
  (make-instance (class-of proto) :target (subseq line cursor)))

(defmethod markless:evaluate-instruction ((instruction components:go) parser))
