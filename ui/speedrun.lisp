(in-package #:org.shirakumo.fraf.kandria)

(defclass quest-timer (alloy:label)
  ((quest :initarg :quest :accessor quest)))

(defmethod alloy:text ((timer quest-timer))
  (let ((clock (alloy:value timer)))
    (multiple-value-bind (ts ms) (floor clock)
      (multiple-value-bind (tm s) (floor ts 60)
        (format NIL "~2,'0d:~2,'0d.~2,'0d"
                tm s (floor (* 100 ms)))))))

(presentations:define-realization (ui quest-timer)
  ((:quest simple:text)
   (alloy:margins 0 -10 100 -10)
   (quest:title (quest alloy:renderable))
   :font "PromptFont"
   :size (alloy:un 10)
   :pattern colors:white
   :wrap T
   :halign :start
   :valign :middle)
  ((:label simple:text)
   (alloy:margins 0 0 5 0)
   alloy:text
   :font "PromptFont"
   :size (alloy:un 12)
   :pattern colors:white
   :halign :end
   :valign :middle))

(presentations:define-update (ui quest-timer)
  (:quest
   :pattern (if (eql :active (quest:status (quest alloy:renderable)))
                colors:white
                colors:gray))
  (:label
   :pattern (if (eql :active (quest:status (quest alloy:renderable)))
                colors:white
                colors:gray)))

(defun split< (a b)
  (let ((a (quest a))
        (b (quest b)))
    (if (eql (quest:active-p a) (quest:active-p b))
        (if (= (start-time a) (start-time b))
            (text< (quest:title a) (quest:title b))
            (< (start-time a) (start-time b)))
        (not (quest:active-p a)))))

(defclass split-total (timer-line)
  ())

(presentations:define-realization (ui split-total)
  ((background simple:rectangle)
   (alloy:margins)
   :pattern (colored:color 0 0 0 0.8))
  ((:label simple:text)
   (alloy:margins 0 0 5 0) alloy:text
   :font "PromptFont"
   :valign :middle
   :halign :end
   :size (alloy:un 26)))

(presentations:define-update (ui split-total)
  (:label :pattern colors:white))

(defclass splits-layout (alloy:vertical-linear-layout)
  ((cell-margins :initform (alloy:margins 10 2))))

(presentations:define-realization (ui splits-layout)
  ((:bg simple:rectangle)
   (alloy:margins)
   :pattern (colored:color 0 0 0 0.5)))

(defmethod alloy:enter ((element alloy:element) (container splits-layout) &key)
  (call-next-method)
  (sort (alloy:elements container) #'split<)
  element)

(defclass splits (panel)
  ((list :initform (make-instance 'splits-layout))
   (timer)))

(defmethod initialize-instance :after ((panel splits) &key (player (unit 'player +world+)))
  (let ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout))
        (clipper (make-instance 'alloy:clip-view)))
    (alloy:enter (slot-value panel 'list) clipper)
    (loop for quest in (quest:known-quests (storyline +world+))
          do (alloy:enter quest panel))
    (alloy:enter clipper layout :constraints `((:left 0) (:top 0) (:width 300) (:height 150)))
    (setf (slot-value panel 'timer) (alloy:represent (stats-play-time (stats player)) 'split-total))
    (alloy:enter (slot-value panel 'timer) layout :constraints `((:left 0) (:below ,clipper 0) (:width 300) (:height 50)))
    (alloy:finish-structure panel layout NIL)))

(defmethod handle ((ev tick) (panel splits))
  (alloy:refresh (slot-value panel 'timer)))

(defmethod handle ((ev quest-started) (panel splits))
  (alloy:enter (quest ev) panel))

(defmethod handle ((ev quest-completed) (panel splits))
  (sort (alloy:elements (slot-value panel 'list)) #'split<)
  (setf (alloy:bounds (slot-value panel 'list)) (alloy:bounds (slot-value panel 'list))))

(defmethod handle ((ev quest-failed) (panel splits))
  (sort (alloy:elements (slot-value panel 'list)) #'split<)
  (setf (alloy:bounds (slot-value panel 'list)) (alloy:bounds (slot-value panel 'list))))

(defmethod alloy:enter ((quest quest) (panel splits) &key)
  (when (and (visible-p quest) (quest:title quest)
             (null (find quest (alloy:elements (slot-value panel 'list)) :key #'quest)))
    (alloy:enter (alloy:represent (slot-value quest 'clock) 'quest-timer :quest quest) (slot-value panel 'list))))

(define-setting-observer show-splits :gameplay :show-splits (value)
  (when (and +world+ (unit 'player +world+))
    (if value
        (show-panel 'splits)
        (hide-panel 'splits))))
