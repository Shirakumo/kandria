(in-package #:org.shirakumo.fraf.kandria)

(defclass trigger (sized-entity resizable ephemeral collider)
  ((active-p :initarg :active-p :initform T :accessor active-p :type boolean)))

(defmethod initargs append ((trigger trigger)) '(:active-p))

(defmethod interact :around ((trigger trigger) source)
  (when (active-p trigger)
    (call-next-method)))

(defmethod quest:activate ((trigger trigger))
  (setf (active-p trigger) T))

(defmethod quest:deactivate ((trigger trigger))
  (setf (active-p trigger) NIL))

(defclass one-time-trigger (trigger)
  ())

(defmethod interact :after ((trigger one-time-trigger) source)
  (setf (active-p trigger) NIL))

(defclass checkpoint (trigger)
  ())

(defmethod interact ((trigger checkpoint) entity)
  (setf (spawn-location entity)
        (vec (vx (location trigger))
             (+ (- (vy (location trigger))
                   (vy (bsize trigger)))
                (vy (bsize entity))))))

(defclass story-trigger (one-time-trigger)
  ((story-item :initarg :story-item :initform NIL :accessor story-item :type symbol)
   (target-status :initarg :target-status :initform :active :accessor target-status :type symbol)))

(defmethod initargs append ((trigger story-trigger)) '(:story-item :target-status))

(defmethod interact ((trigger story-trigger) entity)
  (let ((name (story-item trigger)))
    (flet ((finish (thing)
             (ecase (target-status trigger)
               (:active (quest:activate thing))
               (:inactive (quest:deactivate thing))
               (:complete (quest:complete thing)))
             (return-from interact)))
      (loop for quest in (quest:known-quests (storyline +world+))
            do (loop for task in (quest:active-tasks quest)
                     do (loop for trigger being the hash-values of (quest:triggers task)
                              do (when (eql name (quest:name trigger))
                                   (finish trigger)))
                        (when (eql name (quest:name task))
                          (finish task)))
               (when (eql name (quest:name quest))
                 (finish quest)))
      (v:warn :kandria.quest "Could not find active story-item named ~s when firing trigger ~s"
              name (name trigger)))))

(defclass interaction-trigger (one-time-trigger)
  ((interaction :initarg :interaction :initform NIL :accessor interaction :type symbol)))

(defmethod initargs append ((trigger interaction-trigger)) '(:interaction))

(defmethod interact ((trigger interaction-trigger) entity)
  (when (typep entity 'player)
    (show (make-instance 'dialog :interactions (list (quest:find-trigger (interaction trigger) +world+))))))

(defclass walkntalk-trigger (one-time-trigger)
  ((interaction :initarg :interaction :initform NIL :accessor interaction :type symbol)
   (target :initarg :target :initform T :accessor target :type symbol)))

(defmethod initargs append ((trigger walkntalk-trigger)) '(:interaction :target))

(defmethod interact ((trigger walkntalk-trigger) entity)
  (when (typep (name entity) (target trigger))
    (walk-n-talk (quest:find-trigger (interaction trigger) +world+))))

(defclass tween-trigger (trigger)
  ((left :initarg :left :accessor left :initform 0.0 :type single-float)
   (right :initarg :right :accessor right :initform 1.0 :type single-float)
   (horizontal :initarg :horizontal :accessor horizontal :initform T :type boolean)
   (ease-fun :initarg :easing :accessor ease-fun :initform 'linear :type symbol)))

(defmethod initargs append ((trigger tween-trigger)) '(:left :right :horizontal :ease-fun))

(defmethod interact ((trigger tween-trigger) (entity located-entity))
  (let* ((x (if (horizontal trigger)
                (+ (/ (- (vx (location entity)) (vx (location trigger)))
                      (* 2.0 (vx (bsize trigger))))
                   0.5)
                (+ (/ (- (vy (location entity)) (vy (location trigger)))
                      (* 2.0 (vy (bsize trigger))))
                   0.5)))
         (v (ease (clamp 0 x 1) (ease-fun trigger) (left trigger) (right trigger))))
    (setf (value trigger) v)))

(defclass sandstorm-trigger (tween-trigger)
  ())

(defmethod stage :after ((trigger sandstorm-trigger) (area staging-area))
  (stage (// 'sound 'sandstorm) area))

(defmethod (setf value) (value (trigger sandstorm-trigger))
  (let ((value (max 0.0 (- value 0.01))))
    (cond ((< 0 value)
           (harmony:play (// 'sound 'sandstorm))
           (setf (mixed:volume (// 'sound 'sandstorm)) (/ value 4)))
          (T
           (harmony:stop (// 'sound 'sandstorm))))
    (setf (strength (unit 'sandstorm T)) value)))

(defclass zoom-trigger (tween-trigger)
  ((easing :initform 'quint-in)))

(defmethod (setf value) (value (trigger zoom-trigger))
  (setf (intended-zoom (unit :camera T)) value))

(defclass pan-trigger (tween-trigger)
  ())

(defmethod (setf value) (value (trigger pan-trigger))
  (setf (offset (unit :camera T)) value))

(defclass teleport-trigger (trigger)
  ((target :initform NIL :initarg :target :accessor target)
   (primary :initform T :initarg :primary :accessor primary)))

(defmethod initargs append ((trigger teleport-trigger)) '(:target))

(defmethod default-tool ((trigger teleport-trigger)) (find-class 'freeform))

(defmethod enter :after ((trigger teleport-trigger) (region region))
  (when (primary trigger)
    (destructuring-bind (&optional (location (vec (+ (vx (location trigger)) (* 2 (vx (bsize trigger))))
                                                  (vy (location trigger))))
                                   (bsize (vcopy (bsize trigger)))) (target trigger)
      (let* ((other (clone trigger :location location :bsize bsize :target trigger :active-p NIL :primary NIL)))
        (setf (target trigger) other)
        (enter other region)))))

(defmethod interact ((trigger teleport-trigger) (entity located-entity))
  (setf (location entity) (target trigger))
  (vsetf (velocity entity) 0 0))

(defclass earthquake-trigger (trigger)
  ((duration :initform 60.0 :initarg :duration :accessor duration)
   (clock :initform 0.0 :accessor clock)))

(defmethod stage :after ((trigger earthquake-trigger) (area staging-area))
  (stage (// 'sound 'earthquake) area))

(defmethod interact ((trigger earthquake-trigger) (player player))
  (decf (clock trigger) 0.01)
  (let* ((max 7.0)
         (hmax (/ max 2.0)))
    (cond ((<= (clock trigger) (- max))
           (shake-camera :duration 0.0 :intensity 0)
           (setf (clock trigger) (+ (duration trigger) (random 10.0))))
          ((<= (clock trigger) -0.1)
           (let ((intensity (* 10 (- 1 (/ (expt 3 (abs (+ hmax (clock trigger))))
                                          (expt 3 hmax))))))
             (shake-camera :duration 7.0 :intensity intensity :controller-multiplier 0.1)))
          ((<= (clock trigger) 0.0)
           (harmony:play (// 'sound 'earthquake))))))
;; TODO: make dust fall down over screen.

(defclass action-prompt (trigger listener)
  ((action :initarg :action :initform NIL :accessor action
           :type symbol)
   (interrupt :initarg :interrupt :initform NIL :accessor interrupt
              :type boolean)
   (prompt :initform (make-instance 'prompt) :reader prompt)
   (triggered :initform NIL :accessor triggered)))

(defmethod initargs append ((prompt action-prompt)) '(:action :interrupt))

(defmethod interactable-p ((prompt action-prompt))
  (active-p prompt))

(defmethod handle ((ev tick) (prompt action-prompt))
  (unless (triggered prompt)
    (when (slot-boundp (prompt prompt) 'alloy:layout-parent)
      (hide (prompt prompt))))
  (setf (triggered prompt) NIL))

(defmethod interact ((prompt action-prompt) (player player))
  (when (interrupt prompt)
    (setf (time-scale +world+) 0.05))
  (let ((loc (vec (vx (location prompt))
                  (+ (vy (location player)) (vy (bsize player))))))
    (show (prompt prompt) :button (action prompt) :location loc)
    (setf (triggered prompt) T)))

(defmethod handle ((ev trial:action) (prompt action-prompt))
  (when (and (interrupt prompt)
             (typep ev (action prompt)))
    (setf (time-scale +world+) 1.0)
    (setf (active-p prompt) NIL)))
