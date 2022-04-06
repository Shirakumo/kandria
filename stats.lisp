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

(defmethod score ((stats stats))
  (floor
   (+ (/ (stats-distance stats) 16.0 10.0)
      (/ (stats-money-accrued stats) 5.0)
      (* (stats-kills stats) 5.0)
      (* (stats-secrets-found stats) 100.0))))

(defun chunk-find-rate ()
  (let ((count 0)
        (found 0))
    (for:for ((entity over (region +world+)))
      (typecase entity
        (chunk
         (when (visible-on-map-p entity)
           (incf count)
           (when (unlocked-p entity)
             (incf found))))))
    (values count found)))

(defun secret-find-rate ()
  (let ((count 0)
        (found 0))
    (for:for ((entity over (region +world+)))
      (typecase entity
        (hider
         (incf count)
         (unless (active-p entity)
           (incf found)))))
    (values count found)))

(defun fish-find-rate ()
  (let ((player (unit 'player +world+))
        (count 0)
        (found 0))
    (dolist (item (c2mop:class-direct-subclasses (find-class 'fish)))
      (incf count)
      (when (item-unlocked-p (c2mop:class-prototype item) player)
        (incf found)))
    (values count found)))

(defmethod completion ((stats stats))
  (let ((count 0)
        (found 0))
    (dolist (func '(chunk-find-rate secret-find-rate fish-find-rate))
      (multiple-value-bind (c f) (funcall func)
        (incf count c)
        (incf found f)))
    (float (/ found count))))

(defmethod compute-rank ((stats stats))
  (cond ((= 1.0 (completion stats))
         'rank-boss)
        ((multiple-value-bind (c f) (secret-find-rate) (= c f))
         'rank-magpie)
        ((multiple-value-bind (c f) (fish-find-rate) (= c f))
         'rank-coelacanth)
        ((multiple-value-bind (c f) (chunk-find-rate) (= c f))
         'rank-penguin)
        ((< 1000 (stats-kills stats))
         'rank-bear)
        ((< (stats-kills stats) 10)
         'rank-snake)
        ((< (* 60 60 20) (stats-play-time stats))
         'rank-turtle)
        ((< (stats-play-time stats) (* 60 60 1))
         'rank-hedgehog)
        (T
         'rank-lizard)))
