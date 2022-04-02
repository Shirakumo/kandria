(in-package #:org.shirakumo.fraf.kandria)

(defstruct (stats
            (:copier NIL)
            (:predicate NIL))
  (distance 0d0 :type double-float)
  (play-time 0d0 :type double-float)
  (kills 0 :type (unsigned-byte 32))
  (deaths 0 :type (unsigned-byte 32))
  (longest-session 0 :type (unsigned-byte 32))
  (secrets-found 0 :type (unsigned-byte 32))
  (money-accrued 0 :type (unsigned-byte 32)))

(defclass stats-entity ()
  ((stats :initform (make-stats) :accessor stats)))

;; FIXME: track longest-session

(defmethod hurt :after ((animatable animatable) (attacker stats-entity))
  (when (<= (health animatable) 0)
    (incf (stats-kills (stats attacker)))))

(defmethod kill :after ((entity stats-entity))
  (incf (stats-deaths (stats entity))))

(defmethod handle :after ((ev tick) (entity stats-entity))
  (let ((stats (stats entity)))
    (incf (stats-play-time stats) (dt ev))
    (incf (stats-distance stats) (vlength (velocity entity)))))

(defmethod store :after ((item scrap) (entity stats-entity) &optional (count 1))
  (incf (stats-money-accrued (stats entity)) count))
