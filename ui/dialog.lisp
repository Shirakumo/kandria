(in-package #:org.shirakumo.fraf.kandria)

(defclass dialog-textbox (alloy:label)
  ((markup :initarg :markup :initform () :accessor markup)))

(presentations:define-realization (ui dialog-textbox)
  ((:background simple:rectangle)
   (alloy:margins)
   :pattern (colored:color 0.15 0.15 0.15))
  ((:label simple:text)
   (alloy:margins 30 40 60 30)
   alloy:text
   :valign :top
   :halign :left
   :wrap T
   :font (setting :display :font)
   :size (alloy:un 25)
   :pattern colors:white))

(presentations:define-update (ui dialog-textbox)
  (:label
   :markup (markup alloy:renderable)))

(defclass dialog (pausing-panel textbox)
  ((interactions :initarg :interactions :initform () :accessor interactions)
   (interaction :initform NIL :accessor interaction)
   (one-shot :initform NIL :accessor one-shot)))

(defmethod initialize-instance :after ((dialog dialog) &key)
  (let ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout))
        (textbox (alloy:represent (slot-value dialog 'text) 'dialog-textbox))
        (nametag (alloy:represent (slot-value dialog 'source) 'nametag))
        (prompt (alloy:represent (slot-value dialog 'prompt) 'advance-prompt)))
    (setf (textbox dialog) textbox)
    (alloy:enter (choices dialog) layout :constraints `((:left 20) (:bottom 20) (:height 200)))
    (alloy:enter textbox layout :constraints `((:right-of ,(choices dialog) 0) (:right 20) (:bottom 20) (:height 200)))
    (alloy:enter (profile dialog) layout :constraints `((:left 80) (:above ,textbox) (:width 400) (:height 400)))
    (alloy:enter nametag layout :constraints `((:left 20) (:above ,textbox 0) (:height 30) (:width 300)))
    (alloy:enter prompt layout :constraints `((:right 20) (:bottom 20) (:size 100 30)))
    (alloy:finish-structure dialog layout (choices dialog))
    (setf (interactions dialog) (interactions dialog))))

(defmethod show :after ((dialog dialog) &key)
  (when (= 1.0 (intended-zoom (unit :camera T)))
    (setf (intended-zoom (unit :camera T)) 1.5))
  (setf (clock-scale +world+) (/ (clock-scale +world+) 2))
  (interrupt-walk-n-talk NIL)
  (walk-n-talk NIL)
  (setf (animation (unit 'player T)) 'stand)
  (pause-game T (unit 'ui-pass T)))

(defmethod hide :after ((dialog dialog))
  (when (= 1.5 (intended-zoom (unit :camera T)))
    (setf (intended-zoom (unit :camera T)) 1.0))
  (setf (clock-scale +world+) (* (clock-scale +world+) 2))
  (clear-retained)
  (discard-events +world+)
  (unpause-game T (unit 'ui-pass T)))

(defmethod (setf interaction) :after ((interaction interaction) (dialog dialog))
  (dialogue:run (quest:dialogue interaction) (vm dialog)))

(defmethod (setf interactions) :after (list (dialog dialog))
  ;; If we only have one, activate "one shot mode"
  (cond ((and list (null (rest list)))
         (setf (quest:status (first list)) :active)
         (setf (interaction dialog) (first list))
         (setf (one-shot dialog) T))
        (T
         (setf (one-shot dialog) NIL))))

(defmethod next-interaction ((dialog dialog))
  (when (interaction dialog)
    (quest:complete (interaction dialog)))
  (setf (ip dialog) 0)
  (let ((interactions (loop for interaction in (interactions dialog)
                            when (or (repeatable-p interaction)
                                     (quest:active-p interaction))
                            collect interaction)))
    (cond ((or (null interactions)
               (and (one-shot dialog)
                    (loop for interaction in interactions
                          always (eql :complete (quest:status interaction)))))
           ;; If we have no interactions anymore, or we started
           ;; out with one and now only have dones, hide.
           (hide dialog))
          (T
           ;; If we have multiple show choice.
           (setf (source dialog) (nametag (unit 'player T)))
           (setf (choices dialog)
                 (cons (mapcar #'quest:title interactions) interactions))
           (let* ((label (string (prompt-char :left :bank :keyboard)))
                  (button (alloy:represent label 'dialog-choice)))
             (alloy:on alloy:activate (button)
               (hide dialog))
             (alloy:enter button (choices dialog)))))))

(defmethod handle ((ev advance) (dialog dialog))
  (cond ((/= 0 (alloy:element-count (choices dialog)))
         (setf (prompt dialog) NIL)
         (alloy:activate (choices dialog)))
        ((prompt dialog)
         (setf (prompt dialog) NIL)
         (harmony:play (// 'kandria 'dialogue-advance))
         (advance dialog))
        (T
         (loop until (or (pending dialog) (prompt dialog))
               do (advance dialog))
         (scroll-text dialog (array-total-size (text dialog))))))

(defmethod handle ((ev next) (dialog dialog))
  (alloy:focus-next (choices dialog)))

(defmethod handle ((ev previous) (dialog dialog))
  (alloy:focus-prev (choices dialog)))

(defmethod (setf choices) :after ((choices cons) (dialog dialog))
  (org.shirakumo.alloy.layouts.constraint:suggest
   (alloy:layout-element dialog) (choices dialog) :w (alloy:un 400)))

(defmethod (setf choices) :after ((choices null) (dialog dialog))
  (org.shirakumo.alloy.layouts.constraint:suggest
   (alloy:layout-element dialog) (choices dialog) :w (alloy:un 0)))

(defmethod interact ((string string) target)
  (interact (make-instance 'stub-interaction :dialogue string) target))

(defmethod interact ((interaction interaction) target)
  (let ((dialog (or (find-panel 'dialog)
                    (show (make-instance 'dialog)))))
    (setf (interactions dialog) (list interaction))))
