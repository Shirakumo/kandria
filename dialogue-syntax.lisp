(defpackage #:org.shirakumo.fraf.leaf.dialogue.components
  (:use #:org.shirakumo.markless.components)
  (:export
   #:jump
   #:placeholder
   #:form
   #:emote
   #:conditional-part
   #:choices
   #:conditional
   #:clauses
   #:go
   #:speed
   #:camera-instruction
   #:duration
   #:shake
   #:move
   #:location
   #:zoom
   #:roll
   #:angle
   #:show
   #:map
   #:location
   #:setf
   #:place))

(defpackage #:org.shirakumo.fraf.leaf.dialogue
  (:use #:cl)
  (:local-nicknames
   (#:components #:org.shirakumo.fraf.leaf.dialogue.components)
   (#:markless #:org.shirakumo.markless))
  (:export
   #:parser
   #:jump
   #:placeholder
   #:emote
   #:conditional-part
   #:conditional))

(in-package #:org.shirakumo.fraf.leaf.dialogue)

(defclass parser (markless:parser)
  ()
  (:default-initargs :directives (list* 'placeholder 'emote
                                        'conditional-part 'conditional-part-separator
                                        'jump 'conditional
                                        markless:*default-directives*)))

(defclass components:jump (components::block-component)
  ((components::target :initarg :target :initform (cl:error "TARGET required") :accessor components::target)))

(defclass jump (markless:singular-line-directive)
  ())

(defmethod markless:prefix ((_ jump))
  #("<" " "))

(defmethod markless:begin ((_ jump) parser line cursor)
  (let ((component (make-instance 'components:jump :target (subseq line (+ 2 cursor)))))
    (markless:commit _ component parser))
  (length line))

(defclass components:conditional (components::block-component)
  ((components:clauses :initform (make-array 0 :adjustable T :fill-pointer T) :accessor components:clauses)))

(defmethod components::children ((_ components:conditional))
  (cdr (aref (components:clauses _) (1- (length (components:clauses _))))))

(defmethod markless:output-component ((c components:conditional) (s stream) (f markless:debug))
  (format s "/~a" (type-of c))
  (let ((markless::*level* (1+ markless::*level*)))
    (loop for (predicate . children) across (components:clauses c)
          do (let ((markless::*level* (1- markless::*level*)))
               (markless:output-component (format NIL "-- ~s" predicate) s f))
             (loop for child across children
                   do (markless:output-component child s f)))))

(defclass conditional (markless:singular-line-directive)
  ())

(defmethod markless:prefix ((_ conditional))
  #("?" " "))

(defmethod markless:begin ((_ conditional) parser line cursor)
  (multiple-value-bind (form cursor) (read-from-string line T NIL :start (+ 2 cursor))
    (when (< cursor (length line))
      (error 'markless:parser-error :cursor cursor))
    (let ((component (make-instance 'components:conditional)))
      (vector-push-extend (cons form (make-array 0 :adjustable T :fill-pointer T))
                          (components:clauses component))
      (markless:commit _ component parser)))
  (length line))

(defmethod markless:consume-prefix ((_ conditional) component parser line cursor)
  (or (markless:match! "| " line cursor)
      (when (markless:match! "|?" line cursor)
        (if (< (+ 2 cursor) (length line))
            (multiple-value-bind (form cursor) (read-from-string line T NIL :start (+ 2 cursor))
              (when (< cursor (length line))
                (error 'markless:parser-error :cursor cursor))
              (vector-push-extend (cons form (make-array 0 :adjustable T :fill-pointer T))
                                  (components:clauses component)))
            (vector-push-extend (cons T (make-array 0 :adjustable T :fill-pointer T))
                                (components:clauses component)))
        (length line))))

(defclass components:placeholder (components::inline-component)
  ((components:form :initarg :form :initform (error "FORM required") :accessor components:form)))

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
             (children (components::children (markless:stack-entry-component entry))))
        (vector-push-extend (make-instance 'components:placeholder :form form) children)
        (unless (char= #\} (aref line cursor))
          (error 'markless:parser-error :cursor cursor))
        (+ 1 cursor)))))

(defclass components:emote (components::inline-component)
  ((components:emote :initarg :emote :initform (error "EMOTE required") :accessor components:emote)))

(defclass emote (markless:inline-directive)
  ())

(defmethod markless:prefix ((_ emote))
  #("(" ":"))

(defmethod markless:begin ((_ emote) parser line cursor)
  (let* ((entry (markless:stack-top (markless:stack parser)))
         (children (components::children (markless:stack-entry-component entry)))
         (end (loop for i from (+ 2 cursor) below (length line)
                    do (when (char= #\) (char line i))
                         (return i)))))
    (unless end
      (error 'markless:parser-error :cursor cursor))
    (vector-push-extend (make-instance 'components:emote :emote (subseq line cursor end)) children)
    (+ 1 end)))

(defclass components:conditional-part (components::inline-component)
  ((components:form :initarg :form :initform (error "FORM required") :accessor components:form)
   (components:choices :initform (make-array 0 :adjustable T :fill-pointer T) :accessor components:choices)))

(defmethod components::children ((_ components:conditional-part))
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
        (vector-push-extend "|" (components::children component)))
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
  (markless::vector-push-front "[" (components::children component)))

(defclass components::fake-instruction (components::instruction) ())

(defmethod markless:evaluate-instruction ((instruction components::fake-instruction) parser))

(defclass components:go (components::fake-instruction)
  ((components::target :initarg :target :initform (error "TARGET required") :accessor components::target)))

(defmethod markless:parse-instruction ((proto components:go) line cursor)
  (make-instance (class-of proto) :target (subseq line cursor)))

(defclass components:speed (components::fake-instruction)
  ((components:speed :initarg :speed :initform (error "SPEED required") :accessor components:speed)))

(defmethod markless:parse-instruction ((proto components:speed) line cursor)
  (make-instance (class-of proto) :speed (cl-markless::parse-float line cursor)))

(defclass components:camera-instruction (components::fake-instruction)
  ((components:duration :initarg :duration :initform (error "DURATION required") :accessor components:duration)))

(defclass components:shake (components:camera-instruction)
  ())

(defmethod markless:parse-instruction ((proto components:shake) line cursor)
  (make-instance (class-of proto) :duration (cl-markless::parse-float line cursor)))

(defclass components:move (components:camera-instruction)
  ((components:location :initarg :location :initform (error "LOCATION required") :accessor components:location)))

(defmethod markless:parse-instruction ((proto components:move) line cursor)
  (destructuring-bind (x y duration) (cl-markless::split-string cursor #\Space cursor)
    (make-instance (class-of proto) :duration (cl-markless::parse-float duration)
                                    :location (3d-vectors:vec2
                                               (cl-markless::parse-float x)
                                               (cl-markless::parse-float y)))))

(defclass components:zoom (components:camera-instruction)
  ((components:zoom :initarg :zoom :initform (error "ZOOM required") :accessor components:zoom)))

(defmethod markless:parse-instruction ((proto components:zoom) line cursor)
  (destructuring-bind (zoom duration) (cl-markless::split-string cursor #\Space cursor)
    (make-instance (class-of proto) :duration (cl-markless::parse-float duration)
                                    :zoom (cl-markless::parse-float zoom))))

(defclass components:roll (components:camera-instruction)
  ((components:angle :initarg :angle :initform (error "ANGLE required") :accessor components:angle)))

(defmethod markless:parse-instruction ((proto components:roll) line cursor)
  (destructuring-bind (angle duration) (cl-markless::split-string cursor #\Space cursor)
    (make-instance (class-of proto) :duration (cl-markless::parse-float duration)
                                    :angle (cl-markless::parse-float angle))))

(defclass components:show (components:roll components:zoom components:move)
  ((components:map :initarg :map :initform (error "MAP required") :accessor components:map)))

(defmethod markless:parse-instruction ((proto components:show) line cursor)
  (destructuring-bind (map &optional x y zoom angle duration) (cl-markless::split-string cursor #\Space cursor)
    (make-instance (class-of proto) :duration (cl-markless::parse-float duration)
                                    :location (3d-vectors:vec2
                                               (if x (cl-markless::parse-float x) 0)
                                               (if y (cl-markless::parse-float y) 0))
                                    :zoom (if zoom (cl-markless::parse-float zoom) 1.0)
                                    :angle (if angle (cl-markless::parse-float angle) 0.0)
                                    :map map)))

(defclass components:setf (components::fake-instruction)
  ((components:place :initarg :place :initform (error "PLACE required") :accessor components:place)
   (components:form :initarg :form :initform (error "FORM required") :accessor components:form)))

(defmethod markless:parse-instruction ((proto components:setf) line cursor)
  (multiple-value-bind (place cursor) (read-from-string line T NIL :start cursor)
    (multiple-value-bind (form cursor) (read-from-string line T NIL :start cursor)
      (when (< cursor (length line))
        (error 'markless:parser-error :cursor cursor))
      (make-instance (class-of proto) :place place :form form))))
