(in-package #:org.shirakumo.fraf.kandria)

(defclass trigger (sized-entity resizable ephemeral)
  ((active-p :initarg :active-p :initform T :accessor active-p :type boolean)))

(defmethod interact :around ((trigger trigger) source)
  (when (active-p trigger)
    (call-next-method)))

(defclass one-time-trigger (trigger)
  ())

(defmethod interact :after ((trigger one-time-trigger) source)
  (setf (active-p trigger) NIL))

(defclass checkpoint (trigger)
  ())

(defmethod interact ((checkpoint checkpoint) entity)
  (setf (spawn-location entity)
        (vec (vx (location trigger))
             (+ (- (vy (location trigger))
                   (vy (bsize trigger)))
                (vy (bsize entity))))))

(defclass story-trigger (one-time-trigger)
  ((story-item :initarg :story-item :accessor story-item :type symbol)
   (target-status :initarg :target-status :accessor target-status :type symbol)))

(defmethod interact ((trigger story-trigger) entity)
  (let ((name (story-item trigger)))
    (flet ((finish (thing)
             (setf (quest:status thing) (target-status trigger))
             (return-from interact)))
      (loop for quest in (quest:known-quests (storyline +world+))
            do (loop for task in (quest:active-tasks quest)
                     do (loop for trigger in (quest:triggers task)
                              do (when (eql name (quest:name trigger))
                                   (finish trigger)))
                        (when (eql name (quest:name task))
                          (finish task)))
               (when (eql name (quest:name quest))
                 (finish quest)))
      (v:warn :kandria.quest "Could not find active story-item named ~s when firing trigger ~s"
              name (name trigger)))))

(defclass interaction-trigger (one-time-trigger)
  ((interaction :initarg :interaction :accessor interaction :type symbol)))

(defmethod interact ((trigger interaction-trigger) entity)
  (when (typep entity 'player)
    (show (make-instance 'dialog :interactions (list (quest:find-trigger (interaction trigger) +world+))))))

(defclass walkntalk-trigger (one-time-trigger)
  ((interaction :initarg :interaction :accessor interaction :type symbol)
   (target :initarg :target :accessor target :type symbol)))

(defmethod interact ((trigger interaction-trigger) entity)
  (when (typep (name entity) (target trigger))
    (walk-n-talk (quest:find-trigger (interaction trigger) +world+))))

(defclass tween-trigger (trigger)
  ((left :initarg :left :accessor left :initform 0.0 :type single-float)
   (right :initarg :right :accessor right :initform 1.0 :type single-float)))

(defmethod interact ((trigger tween-trigger) (entity located-entity))
  (let* ((x (+ (/ (- (vx (location entity)) (vx (location trigger)))
                  (* 2.0 (vx (bsize trigger))))
               0.5))
         (v (lerp (left trigger) (right trigger) (clamp 0 x 1))))
    (setf (value trigger) v)))

(defclass sandstorm-trigger (tween-trigger)
  ())

(defmethod (setf value) (value (trigger sandstorm-trigger))
  (setf (strength (unit 'sandstorm T)) value))
