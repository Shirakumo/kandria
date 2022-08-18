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
  ((stats :initform (make-stats) :reader stats)))

(defmethod (setf stats) ((stats stats) (entity stats-entity))
  (let ((orig (stats entity)))
    (macrolet ((transfer (&rest fields)
                 `(progn
                    ,@(loop for field in fields
                            collect `(setf (,field orig) (,field stats))))))
      (transfer stats-distance stats-play-time stats-kills stats-deaths stats-longest-session stats-secrets-found stats-money-accrued))))

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

(defmethod score ((stats stats))
  (floor
   (+ (/ (stats-distance stats) 16.0 10.0)
      (/ (stats-money-accrued stats) 5.0)
      (* (stats-kills stats) 5.0)
      (* (stats-secrets-found stats) 100.0))))

(defmethod score ((player player))
  (+ (score (stats player))
     (floor (price player) 5)))

(defmethod chunk-find-rate ((player player))
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

(defmethod secret-find-rate ((player player))
  (let ((count 0)
        (found 0))
    (for:for ((entity over (region +world+)))
      (typecase entity
        (hider
         (incf count)
         (unless (active-p entity)
           (incf found)))))
    (values count found)))

(defmethod fish-find-rate ((player player))
  (let ((count 0)
        (found 0))
    (dolist (item (c2mop:class-direct-subclasses (find-class 'fish)))
      (incf count)
      (when (item-unlocked-p (c2mop:class-prototype item) player)
        (incf found)))
    (values count found)))

(defmethod completion ((player player))
  ;; FIXME: Include lore items
  ;; FIXME: Include quest completion count
  (let ((count 0)
        (found 0))
    (dolist (func '(chunk-find-rate secret-find-rate fish-find-rate))
      (multiple-value-bind (c f) (funcall func player)
        (incf count c)
        (incf found f)))
    (float (/ found count))))

(defmethod compute-rank ((player player))
  (cond ((= 1.0 (completion player))
         'rank-boss)
        ((multiple-value-bind (c f) (secret-find-rate player) (= c f))
         'rank-magpie)
        ((multiple-value-bind (c f) (fish-find-rate player) (= c f))
         'rank-coelacanth)
        ((multiple-value-bind (c f) (chunk-find-rate player) (= c f))
         'rank-penguin)
        ((< 1000 (stats-kills (stats player)))
         'rank-bear)
        ((< (stats-kills (stats player)) 10)
         'rank-snake)
        ((< (* 60 60 20) (stats-play-time (stats player)))
         'rank-turtle)
        ((< (stats-play-time (stats player)) (* 60 60 1))
         'rank-hedgehog)
        (T
         'rank-lizard)))
