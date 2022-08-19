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
  (money-accrued 0 :type (unsigned-byte 32))
  (chunks-uncovered 0 :type (unsigned-byte 32))
  (secrets-total 0 :type (unsigned-byte 32))
  (chunks-total 0 :type (unsigned-byte 32)))

(defclass stats-entity ()
  ((stats :initform (make-stats) :reader stats)))

(defmethod (setf stats) ((stats stats) (entity stats-entity))
  (let ((orig (stats entity)))
    (macrolet ((transfer (&rest fields)
                 `(progn
                    ,@(loop for field in fields
                            collect `(setf (,field orig) (,field stats))))))
      (transfer stats-distance stats-play-time stats-kills stats-deaths stats-longest-session stats-secrets-found stats-money-accrued stats-chunks-uncovered))))

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

(defmethod handle :before ((ev switch-chunk) (entity stats-entity))
  (when (and (not (unlocked-p (chunk ev)))
             (visible-on-map-p (chunk ev)))
    (incf (stats-chunks-uncovered (stats entity)))))

(defmethod handle :after ((ev switch-region) (entity stats-entity))
  (let ((stats (stats entity))
        (chunks 0)
        (secrets 0))
    (for:for ((entity over (region +world+)))
      (typecase entity
        (hider (incf secrets))
        (chunk (incf chunks))))
    (setf (stats-secrets-total stats) secrets)
    (setf (stats-chunks-total stats) chunks)))

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
  (values (stats-chunks-total (stats player))
          (stats-chunks-uncovered (stats player))))

(defmethod secret-find-rate ((player player))
  (values (stats-secrets-total (stats player))
          (stats-secrets-found (stats player))))

(defmethod lore-find-rate ((player player))
  (let ((count 0)
        (found 0))
    (dolist (item (c2mop:class-direct-subclasses (find-class 'fish)))
      (incf count)
      (when (item-unlocked-p (c2mop:class-prototype item) player)
        (incf found)))
    (dolist (item (c2mop:class-direct-subclasses (find-class 'lore-item)))
      (incf count)
      (when (item-unlocked-p (c2mop:class-prototype item) player)
        (incf found)))
    (values count found)))

(defmethod completion ((player player))
  ;; FIXME: Include quest completion count
  (let ((count 0)
        (found 0))
    (dolist (func '(chunk-find-rate secret-find-rate lore-find-rate))
      (multiple-value-bind (c f) (funcall func player)
        (incf count c)
        (incf found f)))
    (float (/ found count))))

(defmethod compute-rank ((player player))
  (cond ((= 1.0 (completion player))
         'rank-boss)
        ((multiple-value-bind (c f) (secret-find-rate player) (= c f))
         'rank-magpie)
        ((multiple-value-bind (c f) (lore-find-rate player) (= c f))
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
