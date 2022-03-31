(in-package #:org.shirakumo.fraf.kandria)

(defclass dialog-textbox (alloy:label)
  ((markup :initarg :markup :initform () :accessor markup)))

(presentations:define-realization (ui dialog-textbox)
  ((:bg simple:rectangle)
   (alloy:margins)
   :pattern (simple:request-gradient alloy:renderer 'simple:linear-gradient
                                     (alloy:px-point 0 0)
                                     (alloy:px-point 500 0)
                                     #((0.2 #.(colored:color 0.1 0.1 0.1 0.9))
                                       (1.0 #.(colored:color 0.1 0.1 0.1 0.5)))))
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

(defclass dialog (menuing-panel textbox)
  ((interactions :initarg :interactions :initform () :accessor interactions)
   (interaction :initform NIL :accessor interaction)
   (one-shot :initform NIL :accessor one-shot)
   (timeout :initform 0.0 :accessor timeout)))

(defmethod initialize-instance :after ((dialog dialog) &key)
  (let ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout))
        (textbox (alloy:represent (slot-value dialog 'text) 'dialog-textbox))
        (nametag (alloy:represent (slot-value dialog 'source) 'nametag))
        (prompt (alloy:represent (slot-value dialog 'prompt) 'advance-prompt))
        (clip-view (make-instance 'alloy:clip-view :limit :x)))
    (setf (textbox dialog) textbox)
    (alloy:enter (choices dialog) clip-view)
    (alloy:enter textbox layout :constraints `((:required (:max-width 1500) (:center :w))
                                               (:right 20) (:bottom 20) (:height 200)))
    (alloy:enter (profile dialog) layout :constraints `((:required (<= :h (- :rh 250)))
                                                        (:align :left ,textbox 100) (:above ,textbox)
                                                        (:height 700) (= :w :h)))
    (alloy:enter nametag layout :constraints `((:align :left ,textbox) (:above ,textbox 10) (:height 30) (:width 400)))
    (alloy:enter prompt layout :constraints `((:inside ,textbox :halign :right :valign :bottom) (:size 100 30)))
    (alloy:enter clip-view layout :constraints `((:required (<= 5 :x))
                                                 (= :x (- (:x ,textbox) 100)) (:bottom 80) (:height 200)))
    (alloy:finish-structure dialog layout (choices dialog))
    (setf (interactions dialog) (interactions dialog))))

(defmethod show :after ((dialog dialog) &key)
  (when (= 1.0 (intended-zoom (camera +world+)))
    (setf (intended-zoom (camera +world+)) 1.5))
  (setf (clock-scale +world+) (/ (clock-scale +world+) 2))
  (interrupt-walk-n-talk NIL)
  (walk-n-talk NIL)
  (clear-retained)
  (setf (animation (unit 'player T)) 'stand)
  (harmony:play (// 'sound 'ui-start-dialogue)))

(defmethod hide :after ((dialog dialog))
  (when (= 1.5 (intended-zoom (camera +world+)))
    (setf (intended-zoom (camera +world+)) 1.0))
  (setf (clock-scale +world+) (* (clock-scale +world+) 2))
  (clear-retained)
  (discard-events +world+))

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
  (when (and (interaction dialog)
             (not (eql :inactive (quest:status (interaction dialog)))))
    (quest:complete (interaction dialog)))
  (setf (ip dialog) 0)
  (let ((interactions (loop for interaction in (interactions dialog)
                            when (if (repeatable-p interaction)
                                     (not (eql :inactive (quest:status interaction)))
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

(defmethod handle :after ((ev tick) (dialog dialog))
  (decf (timeout dialog) (dt ev)))

(defmethod handle ((ev advance) (dialog dialog))
  (when (<= (timeout dialog) 0.0)
    (cond ((/= 0 (alloy:element-count (choices dialog)))
           (setf (prompt dialog) NIL)
           (alloy:activate (choices dialog)))
          ((prompt dialog)
           (setf (prompt dialog) NIL)
           (harmony:play (// 'sound 'ui-advance-dialogue))
           (advance dialog))
          (T
           (loop until (or (pending dialog) (prompt dialog))
                 do (advance dialog))
           (scroll-text dialog (array-total-size (text dialog)))))))

(defmethod handle ((ev select-right) (dialog dialog))
  (alloy:focus-next (choices dialog)))

(defmethod handle ((ev select-down) (dialog dialog))
  (alloy:focus-next (choices dialog)))

(defmethod handle ((ev select-left) (dialog dialog))
  (alloy:focus-prev (choices dialog)))

(defmethod handle ((ev select-up) (dialog dialog))
  (alloy:focus-prev (choices dialog)))

(defmethod handle ((ev skip) (dialog dialog))
  (let* ((els (alloy:elements (choices dialog)))
         (back (find (string (prompt-char :left :bank :keyboard))
                     els :key #'alloy:value :test #'string=)))
    (cond ((null back))
          ((= (alloy:index (choices dialog)) (position back els))
           (hide dialog))
          (T
           (setf (prompt dialog) T)
           (setf (alloy:index (choices dialog)) (position back els))))))

(defmethod (setf choices) :after ((choices cons) (dialog dialog))
  (setf (timeout dialog) 0.1)
  (org.shirakumo.alloy.layouts.constraint:suggest
   (alloy:layout-element dialog) (alloy:layout-parent (choices dialog)) :w (alloy:un 500)))

(defmethod (setf choices) :after ((choices null) (dialog dialog))
  (org.shirakumo.alloy.layouts.constraint:suggest
   (alloy:layout-element dialog) (alloy:layout-parent (choices dialog)) :w (alloy:un 0)))

(defmethod interact ((string string) target)
  (interact (make-instance 'stub-interaction :dialogue string) target))

(defmethod interact ((interaction interaction) target)
  (let ((dialog (or (find-panel 'dialog)
                    (show (make-instance 'dialog)))))
    (setf (interactions dialog) (list interaction))))
