(in-package #:org.shirakumo.fraf.kandria.dialogue.components)

(defclass jump (components:block-component)
  ((target :initarg :target :initform (error "TARGET required") :accessor components:target)))

(defclass conditional (components:block-component)
  ((clauses :initform (make-array 0 :adjustable T :fill-pointer T) :accessor clauses)))

(defmethod markless:output-component ((c conditional) (s stream) (f markless:debug))
  (format s "/~a" (type-of c))
  (let ((markless::*level* (1+ markless::*level*)))
    (loop for (predicate . children) across (clauses c)
          do (let ((markless::*level* (1- markless::*level*)))
               (markless:output-component (format NIL "-- ~s" predicate) s f))
             (loop for child across children
                   do (markless:output-component child s f)))))

(defclass source (components:blockquote-header)
  ((name :initarg :name :initform (error "NAME required") :accessor name)))

(defclass placeholder (components:inline-component)
  ((form :initarg :form :initform (error "FORM required") :accessor form)))

(defclass emote (components:inline-component)
  ((emote :initarg :emote :initform (error "EMOTE required") :accessor emote)))

(defclass conditional-part (components:inline-component)
  ((form :initarg :form :initform (error "FORM required") :accessor form)
   (choices :initform (make-array 0 :adjustable T :fill-pointer T) :accessor choices)))

(defmethod components:children ((_ conditional-part))
  (aref (choices _) (1- (length (choices _)))))

(defmethod markless:output-component ((c conditional-part) (s stream) (f markless:debug))
  (format s "/~a" (type-of c))
  (let ((markless::*level* (1+ markless::*level*)))
    (loop for children across (choices c)
          do (loop for child across children
                   do (markless:output-component child s f))
             (let ((markless::*level* (1- markless::*level*)))
               (markless:output-component "--" s f)))))

(defclass fake-instruction (components:instruction) ())

(defclass go (fake-instruction)
  ((target :initarg :target :initform (error "TARGET required") :accessor components:target)))

(defclass speed (fake-instruction)
  ((speed :initarg :speed :initform (error "SPEED required") :accessor speed)))

(defclass camera (fake-instruction)
  ((action :initarg :action :initform (error "ACTION required") :accessor action)
   (arguments :initarg :arguments :initform () :accessor arguments)))

(defclass move (fake-instruction)
  ((entity :initarg :entity :initform (error "ENTITY required") :accessor entity)
   (target :initarg :target :initform (error "TARGET required") :accessor components:target)))

(defclass setf (fake-instruction)
  ((place :initarg :place :initform (error "PLACE required") :accessor place)
   (form :initarg :form :initform (error "FORM required") :accessor form)))

(defclass eval (fake-instruction)
  ((form :initarg :form :initform (error "FORM required") :accessor form)))
