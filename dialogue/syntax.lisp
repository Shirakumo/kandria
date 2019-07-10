(in-package #:org.shirakumo.fraf.leaf.dialogue.syntax)

(defclass parser (markless:parser)
  ()
  (:default-initargs :directives (list* 'placeholder 'emote 'clue
                                        'conditional-part 'part-separator
                                        'jump 'conditional
                                        (remove-if (lambda (s) (find s '(markless:underline markless:code)))
                                                   markless:*default-directives*))))

(defclass jump (markless:singular-line-directive)
  ())

(defmethod markless:prefix ((_ jump))
  #("<" " "))

(defmethod markless:begin ((_ jump) parser line cursor)
  (let ((component (make-instance 'components:jump :target (subseq line (+ 2 cursor)))))
    (markless:commit _ component parser))
  (length line))

(defmethod components::children ((_ components:conditional))
  (cdr (aref (components:clauses _) (1- (length (components:clauses _))))))

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

(defclass part-separator (markless:inline-directive)
  ())

(defmethod markless:prefix ((_ part-separator))
  #("|"))

(defmethod markless:begin ((_ part-separator) parser line cursor)
  (let* ((component (markless:stack-entry-component (markless:stack-top (markless:stack parser)))))
    (incf cursor)
    (typecase component
      (components:conditional-part
       (vector-push-extend (make-array 0 :adjustable T :fill-pointer T) (components:choices component))
       cursor)
      (components:clue
       (loop for i from cursor below (length line)
             do (when (and (char= (char line i) #\_)
                           (char= (char line (1- i)) #\_))
                  (setf (components:clue component) (subseq line cursor (1- i)))
                  (return (1- i)))
             finally (error 'markless:parser-error :cursor i)))
      (T
       (vector-push-extend "|" (components::children component))
       cursor))))

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

(defclass clue (markless:surrounding-inline-directive)
  ())

(defmethod markless:prefix ((_ clue))
  #("_" "_"))

(defmethod markless:begin ((_ clue) parser line cursor)
  (markless:commit _ (make-instance 'components:clue) parser)
  (+ 2 cursor))

(defmethod markless:end :after ((_ clue) component parser)
  (markless::vector-push-front "__" (components::children component)))

;; FIXME

(defmethod markless:evaluate-instruction ((instruction components::fake-instruction) parser))

(defmethod markless:parse-instruction ((proto components:go) line cursor)
  (make-instance (class-of proto) :target (subseq line cursor)))

(defmethod markless:parse-instruction ((proto components:speed) line cursor)
  (make-instance (class-of proto) :speed (cl-markless::parse-float line cursor)))

(defmethod markless:parse-instruction ((proto components:shake) line cursor)
  (make-instance (class-of proto) :duration (cl-markless::parse-float line cursor)))

(defmethod markless:parse-instruction ((proto components:move) line cursor)
  (destructuring-bind (x y duration) (cl-markless::split-string cursor #\Space cursor)
    (make-instance (class-of proto) :duration (cl-markless::parse-float duration)
                                    :location (3d-vectors:vec2
                                               (cl-markless::parse-float x)
                                               (cl-markless::parse-float y)))))

(defmethod markless:parse-instruction ((proto components:zoom) line cursor)
  (destructuring-bind (zoom duration) (cl-markless::split-string cursor #\Space cursor)
    (make-instance (class-of proto) :duration (cl-markless::parse-float duration)
                                    :zoom (cl-markless::parse-float zoom))))

(defmethod markless:parse-instruction ((proto components:roll) line cursor)
  (destructuring-bind (angle duration) (cl-markless::split-string cursor #\Space cursor)
    (make-instance (class-of proto) :duration (cl-markless::parse-float duration)
                                    :angle (cl-markless::parse-float angle))))

(defmethod markless:parse-instruction ((proto components:show) line cursor)
  (destructuring-bind (map &optional x y zoom angle duration) (cl-markless::split-string cursor #\Space cursor)
    (make-instance (class-of proto) :duration (cl-markless::parse-float duration)
                                    :location (3d-vectors:vec2
                                               (if x (cl-markless::parse-float x) 0)
                                               (if y (cl-markless::parse-float y) 0))
                                    :zoom (if zoom (cl-markless::parse-float zoom) 1.0)
                                    :angle (if angle (cl-markless::parse-float angle) 0.0)
                                    :map map)))

(defmethod markless:parse-instruction ((proto components:setf) line cursor)
  (multiple-value-bind (place cursor) (read-from-string line T NIL :start cursor)
    (multiple-value-bind (form cursor) (read-from-string line T NIL :start cursor)
      (when (< cursor (length line))
        (error 'markless:parser-error :cursor cursor))
      (make-instance (class-of proto) :place place :form form))))

(defmethod markless:parse-instruction ((proto components:eval) line cursor)
  (multiple-value-bind (form cursor) (read-from-string line T NIL :start cursor)
    (when (< cursor (length line))
      (error 'markless:parser-error :cursor cursor))
    (make-instance (class-of proto) :form form)))
