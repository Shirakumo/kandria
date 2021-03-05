(in-package #:org.shirakumo.fraf.kandria)

(define-shader-entity profile-picture (trial:animated-sprite standalone-shader-entity alloy:layout-element)
  ()
  (:default-initargs :sprite-data (asset 'kandria 'player-profile)))

(defmethod alloy:render ((pass ui-pass) (picture profile-picture))
  (let ((extent (alloy:bounds picture)))
    (with-pushed-matrix ((view-matrix :identity)
                         (model-matrix :identity))
      (translate-by (alloy:pxx extent) (alloy:pxy extent) -100)
      (scale-by (/ (alloy:pxw extent) 128) (/ (alloy:pxh extent) 128) 1)
      (translate-by 64 0 0)
      (render picture NIL))))

(defclass nametag (alloy:label) ())

(presentations:define-realization (ui nametag)
  ((:background simple:rectangle)
   (alloy:margins))
  ((:label simple:text)
   (alloy:margins 10 0 10 0)
   alloy:text
   :valign :bottom
   :font "PromptFont"
   :size (alloy:un 20)
   :pattern colors:white))

(presentations:define-update (ui nametag)
  (:background :pattern colors:accent))

(defclass advance-prompt (alloy:label) ())

(presentations:define-realization (ui advance-prompt)
  ((:background simple:rectangle)
   (alloy:margins)
   :pattern colors:accent)
  ((:label simple:text)
   (alloy:margins 1)
   alloy:text
   :valign :middle
   :halign :right
   :font "PromptFont"
   :size (alloy:ph 0.8)
   :pattern colors:white))

(presentations:define-update (ui advance-prompt)
  (:background
   :hidden-p (null alloy:value)
   :pattern colors:accent)
  (:label
   :text alloy:text
   :hidden-p (null alloy:value)))

(defclass dialog-choice (alloy:button) ())

(presentations:define-realization (ui dialog-choice)
  ((:background simple:rectangle)
   (alloy:margins)
   :pattern colors:black)
  ((:indicator simple:rectangle)
   (alloy:extent 0 0 10 (alloy:ph))
   :pattern (colored:color 0 0 0 0))
  ((:label simple:text)
   (alloy:margins 5)
   alloy:text
   :valign :middle
   :halign :left
   :wrap T
   :font "PromptFont"
   :size (alloy:un 20)
   :pattern colors:white))

(presentations:define-update (ui dialog-choice)
  (:label
   :pattern colors:white
   :offset (alloy:point (if alloy:focus 10 0) 0))
  (:indicator
   :pattern (case alloy:focus
              (:strong colors:white)
              (:weak colors:accent)
              (T colors:transparent)))
  (:background
   :pattern (case alloy:focus
              (:strong (colored:color 0.3 0.3 0.3))
              (:weak (colored:color 0.1 0.1 0.1))
              (T colors:black))))

(defclass dialog-choice-list (alloy:vertical-linear-layout alloy:focus-chain)
  ((alloy:cell-margins :initform (alloy:margins 0))
   (alloy:min-size :initform (alloy:size 35 35))))

(presentations:define-realization (ui dialog-choice-list)
  ((:bg simple:rectangle)
   (alloy:margins)
   :pattern (colored:color 0 0 0 0.5)))

(defun clear-text-string ()
  (load-time-value (make-array 0 :fill-pointer 0 :element-type 'character)))

(defclass textbox (alloy:observable-object)
  ((vm :initform (make-instance 'dialogue:vm) :reader vm)
   (ip :initform 0 :accessor ip)
   (char-timer :initform 0.1 :accessor char-timer)
   (pause-timer :initform 0 :accessor pause-timer)
   (choices :initform (make-instance 'dialog-choice-list) :reader choices)
   (prompt :initform NIL :accessor prompt)
   (text :initform (clear-text-string) :accessor text)
   (source :initform 'player :accessor source)
   (pending :initform NIL :accessor pending)
   (profile :initform (make-instance 'profile-picture) :accessor profile)))

(defmethod stage :after ((textbox textbox) (area staging-area))
  (stage (// 'kandria 'text) area)
  (stage (// 'kandria 'advance) area))

(defmethod at-end-p ((textbox textbox))
  (<= (array-total-size (text textbox))
      (fill-pointer (text textbox))))

(defmethod scroll-text ((textbox textbox) to)
  (when (<= to (array-total-size (text textbox)))
    (harmony:play (// 'kandria 'text))
    (setf (fill-pointer (text textbox)) to)
    (setf (text textbox) (text textbox))))

(defmethod advance ((textbox textbox))
  (handle (dialogue:resume (vm textbox) (ip textbox)) textbox))

(defmethod (setf choices) ((choices null) (textbox textbox))
  (alloy:clear (choices textbox)))

(defmethod (setf choices) ((choices cons) (textbox textbox))
  (alloy:clear (choices textbox))
  (loop for choice in (car choices)
        for target in (cdr choices)
        do (let* ((choice choice) (target target)
                  (button (alloy:represent choice 'dialog-choice)))
             (alloy:on alloy:activate (button)
               (setf (ip textbox) target)
               (setf (text textbox) (clear-text-string))
               (setf (choices textbox) ())
               (harmony:play (// 'kandria 'advance))
               (advance textbox))
             (alloy:enter button (choices textbox))))
  (setf (alloy:index (choices textbox)) 0)
  (setf (alloy:focus (choices textbox)) :strong)
  (setf (prompt textbox) (string (prompt-char :right :bank :keyboard))))

(defmethod handle ((ev tick) (textbox textbox))
  (handle ev (profile textbox))
  (cond ((and (at-end-p textbox)
              (not (prompt textbox)))
         (harmony:stop (// 'kandria 'text))
         (cond ((< 0 (pause-timer textbox))
                (decf (pause-timer textbox) (dt ev)))
               ((pending textbox)
                (ecase (first (pending textbox))
                  (:emote
                   (setf (animation (profile textbox)) (second (pending textbox))))
                  (:prompt
                   (setf (prompt textbox) (second (pending textbox))))
                  (:end
                   (when (interaction textbox)
                     (quest:complete (interaction textbox)))
                   (next-interaction textbox)))
                (setf (pending textbox) NIL))
               ((dialogue:instructions (vm textbox))
                (advance textbox))
               (T
                (next-interaction textbox))))
        ((< 0 (char-timer textbox))
         (decf (char-timer textbox) (dt ev)))
        ((< 0 (array-total-size (text textbox)))
         (scroll-text textbox (1+ (fill-pointer (text textbox))))
         (setf (char-timer textbox)
               (* (setting :gameplay :text-speed)
                  (case (char (text textbox) (1- (length (text textbox))))
                    ((#\. #\! #\? #\: #\;) 7.5)
                    ((#\,) 2.5)
                    (T 1)))))))

(defmethod handle ((rq dialogue:request) (textbox textbox)))

(defmethod handle ((rq dialogue:end-request) (textbox textbox))
  (setf (pending textbox) (list :end)))

(defmethod handle ((rq dialogue:choice-request) (textbox textbox))
  (setf (choices textbox) (cons (dialogue:choices rq)
                                (dialogue:targets rq))))

(defmethod handle ((rq dialogue:confirm-request) (textbox textbox))
  (setf (pending textbox) (list :prompt (string (prompt-char :right :bank :keyboard)))))

(defmethod handle ((rq dialogue:clear-request) (textbox textbox))
  (setf (text textbox) (clear-text-string)))

(defmethod handle ((rq dialogue:source-request) (textbox textbox))
  (let ((unit (unit (dialogue:name rq) T)))
    (setf (source textbox) (nametag unit))
    (setf (trial:sprite-data (profile textbox)) (profile-sprite-data unit))))

(defmethod handle ((rq dialogue:emote-request) (textbox textbox))
  (setf (pending textbox) (list :emote (dialogue:emote rq))))

(defmethod handle ((rq dialogue:pause-request) (textbox textbox))
  (setf (pause-timer textbox) (dialogue:duration rq)))

(defmethod handle :after ((rq dialogue:text-request) (textbox textbox))
  (let ((s (make-array (+ (array-total-size (text textbox))
                          (array-total-size (dialogue:text rq)))
                       :fill-pointer (fill-pointer (text textbox))
                       :element-type 'character)))
    (loop for i from 0 below (array-total-size (text textbox))
          do (setf (aref s i) (aref (text textbox) i)))
    (loop for i from 0 below (array-total-size (dialogue:text rq))
          do (setf (aref s (+ i (array-total-size (text textbox)))) (aref (dialogue:text rq) i)))
    (setf (text textbox) s)))

(defmethod handle :after ((rq dialogue:target-request) (textbox textbox))
  (setf (ip textbox) (dialogue:target rq)))
