(in-package #:org.shirakumo.fraf.kandria)

(defclass walk-textbox (alloy:label) ())

(presentations:define-realization (ui walk-textbox)
  ((:background simple:rectangle)
   (alloy:margins)
   :pattern (colored:color 0.15 0.15 0.15))
  ((:label simple:text)
   (alloy:margins 20 20 40 20)
   alloy:text
   :valign :top
   :halign :left
   :wrap T
   :font "PromptFont"
   :size (alloy:un 25)
   :pattern colors:white))

(defclass profile-background (alloy:layout-element alloy:renderable) ())

(presentations:define-realization (ui profile-background)
  ((:background simple:rectangle)
   (alloy:margins)
   :pattern (colored:color 0.15 0.15 0.15)
   :z-index -10)
  ((:sigh simple:rectangle)
   (alloy:margins 1)
   :line-width (alloy:un 2)
   :pattern colors:accent
   :z-index 10))

(defclass walkntalk (panel textbox unit)
  ((name :initform 'walkntalk)
   (interaction :initform NIL :accessor interaction)
   (interrupt :initform NIL :accessor interrupt)
   (interrupt-ip :initform 0 :accessor interrupt-ip)))

(defmethod initialize-instance :after ((walkntalk walkntalk) &key)
  (let ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout))
        (textbox (alloy:represent (slot-value walkntalk 'text) 'walk-textbox))
        (nametag (alloy:represent (slot-value walkntalk 'source) 'nametag)))
    (alloy:enter (make-instance 'profile-background) layout :constraints `((:left 20) (:top 20) (:width 150) (:height 150)))
    (alloy:enter (profile walkntalk) layout :constraints `((:left 20) (:top 20) (:width 150) (:height 150)))
    (alloy:enter textbox layout :constraints `((:right-of ,(profile walkntalk) 0) (:top 20) (:right 20) (:height 100)))
    (alloy:enter nametag layout :constraints `((:left 20) (:below ,(profile walkntalk) 0) (:height 30) (:width 150)))
    (alloy:finish-structure walkntalk layout (choices walkntalk))))

(defmethod (setf interaction) :after (value (textbox walkntalk))
  (cond (value
         (setf (ip textbox) 0)
         (dialogue:run (quest:dialogue value) (vm textbox))
         (unless (active-p textbox) (show textbox)))
        ((active-p textbox)
         (hide textbox))))

(defmethod (setf interrupt) :before (value (textbox walkntalk))
  (if value
      (when (null (interrupt textbox))
        (setf (interrupt-ip textbox) (ip textbox))
        (setf (ip textbox) 0)
        (dialogue:run (quest:dialogue value) (vm textbox))
        (unless (active-p textbox) (show textbox)))
      (cond ((interaction textbox)
             (setf (ip textbox) (interrupt-ip textbox))
             (dialogue:run (quest:dialogue (interaction textbox)) (vm textbox)))
            ((active-p textbox)
             (hide textbox)))))

(defmethod (setf prompt) :after (value (textbox walkntalk))
  (when value
    (setf (pause-timer textbox) (setting :gameplay :auto-advance-after))))

(defmethod next-interaction ((textbox walkntalk))
  (cond ((interrupt textbox))
        (T
         (setf (interaction textbox) NIL))))

(defmethod handle ((ev tick) (textbox walkntalk))
  (cond ((prompt textbox)
         (decf (pause-timer textbox) (dt ev))
         (when (<= (pause-timer textbox) 0)
           (setf (text textbox) (clear-text-string))
           (setf (prompt textbox) NIL)))
        ((or (interrupt textbox) (interaction textbox))
         (call-next-method))))
