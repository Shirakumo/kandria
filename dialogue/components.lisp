(in-package #:org.shirakumo.fraf.leaf.dialogue.components)

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

(defclass clue (components:inline-component components:parent-component)
  ((clue :initarg :clue :initform NIL :accessor clue)))

(defclass fake-instruction (components:instruction) ())

(defclass go (fake-instruction)
  ((target :initarg :target :initform (error "TARGET required") :accessor components:target)))

(defclass speed (fake-instruction)
  ((speed :initarg :speed :initform (error "SPEED required") :accessor speed)))

(defclass camera-instruction (fake-instruction)
  ((duration :initarg :duration :initform (error "DURATION required") :accessor duration)))

(defclass shake (camera-instruction)
  ())

(defclass move (camera-instruction)
  ((location :initarg :location :initform (error "LOCATION required") :accessor location)))

(defclass zoom (camera-instruction)
  ((zoom :initarg :zoom :initform (error "ZOOM required") :accessor zoom)))

(defclass roll (camera-instruction)
  ((angle :initarg :angle :initform (error "ANGLE required") :accessor angle)))

;; TODO: This needs rethinking
(defclass show (roll zoom move)
  ((map :initarg :map :initform (error "MAP required") :accessor map)))

(defclass setf (fake-instruction)
  ((place :initarg :place :initform (error "PLACE required") :accessor place)
   (form :initarg :form :initform (error "FORM required") :accessor form)))

(defclass eval (fake-instruction)
  ((form :initarg :form :initform (error "FORM required") :accessor form)))
