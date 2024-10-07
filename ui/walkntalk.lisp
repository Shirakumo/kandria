(in-package #:org.shirakumo.fraf.kandria)

(defclass walk-textbox (alloy:label)
  ((markup :initarg :markup :initform () :accessor markup)))

(presentations:define-realization (ui walk-textbox)
  ((:bg simple:rectangle)
   (alloy:margins)
   :pattern (colored:color 0 0 0 0.8))
  ((:label simple:text)
   (alloy:margins 20 20 40 20)
   alloy:text
   :valign :top
   :halign :left
   :wrap T
   :font (setting :display :font)
   :size (alloy:un 25)
   :pattern colors:white))

(presentations:define-update (ui walk-textbox)
  (:label
   :markup (markup alloy:renderable)))

(defclass profile-background (alloy:layout-element alloy:renderable) ())

(presentations:define-realization (ui profile-background)
  ((:bg simple:rectangle)
   (alloy:margins)
   :pattern (colored:color 0 0 0 0.8)
   :z-index -10))

;; KLUDGE: this sucks.
(defclass walkntalk-layout (org.shirakumo.alloy.layouts.constraint:layout)
  ((walkntalk :initarg :walkntalk)))

(defclass walkntalk (panel textbox entity)
  ((name :initform 'walkntalk)
   (interaction :initform NIL :accessor interaction)
   (interrupt :initform NIL :accessor interrupt)
   (interrupt-ip :initform 0 :accessor interrupt-ip)))

(defmethod initialize-instance :after ((walkntalk walkntalk) &key)
  (let ((layout (make-instance 'walkntalk-layout :walkntalk walkntalk))
        (textbox (alloy:represent (slot-value walkntalk 'text) 'walk-textbox))
        (nametag (alloy:represent (slot-value walkntalk 'source) 'nametag))
        (background (make-instance 'profile-background)))
    (setf (textbox walkntalk) textbox)
    (alloy:enter background layout :constraints `((:left 60) (:top 60) (:width 150) (:height 150)))
    (alloy:enter (profile walkntalk) layout :constraints `((:left 90) (:top 0) (:width 200) (:height 200)))
    (alloy:enter textbox layout :constraints `((:align :bottom ,background) (:right-of ,background 0) (:height 120) (:right 60)))
    ;; KLUDGE: for whatever fucking reason trying to use teh relative constraints here results in unsolvable expressions.
    (alloy:enter nametag layout :constraints `((:top 60) (:left 210) (:height 30) (:right 60)))
    (alloy:finish-structure walkntalk layout (choices walkntalk))))

(defmethod show :before ((textbox walkntalk) &key)
  (setf (text textbox) (clear-text-string)))

(defmethod hide :after ((textbox walkntalk))
  (harmony:stop (// 'sound 'ui-scroll-dialogue)))

(defmethod interactions ((textbox walkntalk))
  (when (interaction textbox)
    (list (interaction textbox))))

(defmethod handle ((ev tick) (textbox walkntalk))
  (when (shown-p textbox)
    (call-next-method)))

(defmethod (setf interaction) :after (value (textbox walkntalk))
  (cond ((null value)
         (when (shown-p textbox)
           (hide textbox)))
        ((interrupt textbox)
         (setf (interrupt-ip textbox) 0))
        (T
         (reset textbox)
         (setf *current-task* (quest:task value))
         (setf *current-interaction* value)
         (dialogue:run (quest:dialogue value) (vm textbox))
         (when (and (not (shown-p textbox))
                    (not (find-panel 'dialog)))
           (show textbox)))))

(defmethod (setf interrupt) :before (value (textbox walkntalk))
  (cond (value
         (when (null (interrupt textbox))
           (setf (interrupt-ip textbox) (ip textbox)))
         (reset textbox)
         (setf *current-task* (quest:task value))
         (setf *current-interaction* value)
         (dialogue:run (quest:dialogue value) (vm textbox))
         (when (and (not (shown-p textbox))
                    (not (find-panel 'dialog)))
           (show textbox)))
        ((and (interaction textbox) (interrupt-ip textbox))
         (shiftf (ip textbox) (interrupt-ip textbox) NIL)
         (setf *current-task* (quest:task (interaction textbox)))
         (setf *current-interaction* (interaction textbox))
         (dialogue:run (quest:dialogue (interaction textbox)) (vm textbox)))
        ((shown-p textbox)
         (hide textbox))))

(defmethod (setf prompt) :after (value (textbox walkntalk))
  (when value
    (setf (pause-timer textbox) (setting :gameplay :auto-advance-after))))

(defmethod next-interaction ((textbox walkntalk))
  (cond ((interrupt textbox))
        (T
         (when (interaction textbox)
           (quest:complete (interaction textbox)))
         (setf (interaction textbox) NIL))))

(defmethod handle ((ev tick) (textbox walkntalk))
  (cond ((prompt textbox)
         (decf (pause-timer textbox) (dt ev))
         (when (<= (pause-timer textbox) 0)
           (setf (text textbox) (clear-text-string))
           (setf (prompt textbox) NIL)))
        ((or (interrupt textbox) (interaction textbox))
         (call-next-method))))

(defmethod interrupt-walk-n-talk ((string string))
  ;; KLUDGE: only avoid recaching if we're already displaying the same string.
  (unless (interrupt (node 'walkntalk +world+))
    (setf (interrupt (node 'walkntalk +world+))
          (make-instance 'stub-interaction :dialogue string))))

(defmethod interrupt-walk-n-talk ((null null))
  (setf (interrupt (node 'walkntalk +world+)) null))

(defmethod walk-n-talk ((string string))
  (walk-n-talk (make-instance 'stub-interaction :dialogue string)))

(defmethod walk-n-talk ((cons cons))
  (walk-n-talk (make-instance 'stub-interaction :source cons)))

(defmethod walk-n-talk ((interaction interaction))
  (setf (interaction (node 'walkntalk +world+)) interaction))

(defmethod walk-n-talk ((null null))
  (setf (interaction (node 'walkntalk +world+)) null))

(defmethod alloy:render :around ((ui ui) (textbox walkntalk-layout))
  (when (< 0 (length (text (slot-value textbox 'walkntalk))))
    (call-next-method)))
