(in-package #:org.shirakumo.fraf.kandria)

(define-shader-entity profile-picture (trial:animated-sprite standalone-shader-entity alloy:layout-element)
  ()
  (:default-initargs :sprite-data (asset 'kandria 'player-profile)))

(defmethod alloy:render ((pass ui-pass) (picture profile-picture))
  (let ((extent (alloy:bounds picture)))
    (with-pushed-matrix ((view-matrix :identity)
                         (model-matrix :identity))
      (translate-by (+ 128 (alloy:pxx extent)) (alloy:pxy extent) -100)
      (scale-by (/ (alloy:pxw extent) 128) (/ (alloy:pxh extent) 128) 1)
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

(defclass textbox (alloy:label) ())

(presentations:define-realization (ui textbox)
  ((:background simple:rectangle)
   (alloy:margins)
   :pattern (colored:color 0.15 0.15 0.15))
  ((:label simple:text)
   (alloy:margins 30 40 60 30)
   alloy:text
   :valign :top
   :halign :left
   :wrap T
   :font "PromptFont"
   :size (alloy:un 25)
   :pattern colors:white))

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

(defclass dialog-choice-list (alloy:grid-layout alloy:focus-chain)
  ((alloy:cell-margins :initform (alloy:margins 0)))
  (:default-initargs :col-sizes '(T) :row-sizes '(30)))

(defun clear-text-string ()
  (make-array 0 :fill-pointer 0 :element-type 'character))

(defclass dialog (pausing-panel alloy:observable-object)
  ((vm :initform (make-instance 'dialogue:vm) :reader vm)
   (ip :initform 0 :accessor ip)
   (char-timer :initform 0.1 :accessor char-timer)
   (pause-timer :initform 0 :accessor pause-timer)
   (choices :initform NIL :accessor choices)
   (prompt :initform NIL :accessor prompt)
   (text :initform (clear-text-string) :accessor text)
   (source :initform 'player :accessor source)
   (pending :initform NIL :accessor pending)
   (profile :initform (make-instance 'profile-picture) :accessor profile)
   (per-letter-tick :initform 0.02 :accessor per-letter-tick)
   (interactions :initarg :interactions :accessor interactions)))

(defmethod initialize-instance :after ((dialog dialog) &key interactions)
  (let ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout))
        (textbox (alloy:represent (slot-value dialog 'text) 'textbox))
        (nametag (alloy:represent (slot-value dialog 'source) 'nametag))
        (prompt (alloy:represent (slot-value dialog 'prompt) 'advance-prompt))
        (choices (setf (choices dialog) (make-instance 'dialog-choice-list))))
    (alloy:enter textbox layout :constraints `((:left 20) (:right 20) (:bottom 20) (:height 200)))
    (alloy:enter (profile dialog) layout :constraints `((:left 80) (:above ,textbox) (:width 400) (:height 400)))
    (alloy:enter nametag layout :constraints `((:left 30) (:above ,textbox -10) (:height 30) (:width 300)))
    (alloy:enter choices layout :constraints `((:right 50) (:above ,textbox 10) (:width 400)))
    (alloy:enter prompt layout :constraints `((:right 20) (:bottom 20) (:size 100 30)))
    (alloy:finish-structure dialog layout choices)
    (dialogue:run (quest:dialogue (first interactions)) (vm dialog))))

(defmethod show :after ((dialog dialog) &key)
  (pause-game T (unit 'ui-pass T)))

(defmethod hide :after ((dialog dialog))
  (unpause-game T (unit 'ui-pass T)))

(defmethod at-end-p ((dialog dialog))
  (<= (array-total-size (text dialog))
      (fill-pointer (text dialog))))

(defmethod scroll-text ((dialog dialog) to)
  (when (<= to (array-total-size (text dialog)))
    (setf (fill-pointer (text dialog)) to)
    (setf (text dialog) (text dialog))))

(defmethod interaction ((dialog dialog))
  (first (interactions dialog)))

(defmethod handle ((ev tick) (dialog dialog))
  (handle ev (profile dialog))
  (cond ((and (at-end-p dialog)
              (not (prompt dialog)))
         (cond ((< 0 (pause-timer dialog))
                (decf (pause-timer dialog) (dt ev)))
               ((pending dialog)
                (ecase (first (pending dialog))
                  (:emote
                   (setf (animation (profile dialog)) (second (pending dialog))))
                  (:prompt
                   (setf (prompt dialog) (second (pending dialog))))
                  (:end
                   (setf (quest:status (interaction dialog)) :done)
                   (pop (interactions dialog))
                   (setf (ip dialog) 0)
                   (if (interaction dialog)
                       (dialogue:run (quest:dialogue (interaction dialog)) (vm dialog))
                       (hide dialog))))
                (setf (pending dialog) NIL))
               (T
                (advance dialog))))
        ((< 0 (char-timer dialog))
         (decf (char-timer dialog) (dt ev)))
        ((< 0 (array-total-size (text dialog)))
         (scroll-text dialog (1+ (fill-pointer (text dialog))))
         (setf (char-timer dialog)
               (* (per-letter-tick dialog)
                  (case (char (text dialog) (1- (length (text dialog))))
                    ((#\. #\! #\? #\: #\;) 7.5)
                    ((#\,) 2.5)
                    (T 1)))))))

(defmethod handle ((ev advance) (dialog dialog))
  (cond ((/= 0 (alloy:element-count (choices dialog)))
         (setf (prompt dialog) NIL)
         (alloy:activate (choices dialog)))
        ((prompt dialog)
         (setf (prompt dialog) NIL)
         (setf (text dialog) (clear-text-string))
         (advance dialog))
        (T
         (loop until (or (pending dialog) (prompt dialog))
               do (advance dialog))
         (scroll-text dialog (array-total-size (text dialog))))))

(defmethod advance ((dialog dialog))
  (handle (dialogue:resume (vm dialog) (ip dialog)) dialog))

(defmethod handle ((rq dialogue:request) (dialog dialog)))

(defmethod handle ((rq dialogue:end-request) (dialog dialog))
  (setf (pending dialog) (list :end)))

(defmethod handle ((rq dialogue:choice-request) (dialog dialog))
  (loop for choice in (dialogue:choices rq)
        for target in (dialogue:targets rq)
        do (let* ((choice choice) (target target)
                  (button (alloy:represent choice 'dialog-choice)))
             (alloy:on alloy:activate (button)
               (setf (ip dialog) target)
               (setf (text dialog) (clear-text-string))
               (alloy:clear (choices dialog))
               (advance dialog))
             (alloy:enter button (choices dialog))))
  (setf (prompt dialog) (string (prompt-char :right :bank :keyboard))))

(defmethod handle ((rq dialogue:confirm-request) (dialog dialog))
  (setf (pending dialog) (list :prompt (string (prompt-char :right :bank :keyboard)))))

(defmethod handle ((rq dialogue:source-request) (dialog dialog))
  (let ((unit (unit (dialogue:name rq) T)))
    (setf (source dialog) (nametag unit))
    (setf (trial:sprite-data (profile dialog)) (profile-sprite-data unit))))

(defmethod handle ((rq dialogue:emote-request) (dialog dialog))
  (setf (pending dialog) (list :emote (dialogue:emote rq))))

(defmethod handle ((rq dialogue:pause-request) (dialog dialog))
  (setf (pause-timer dialog) (dialogue:duration rq)))

(defmethod handle :after ((rq dialogue:text-request) (dialog dialog))
  (let ((s (make-array (+ (array-total-size (text dialog))
                          (array-total-size (dialogue:text rq)))
                       :fill-pointer (fill-pointer (text dialog))
                       :element-type 'character)))
    (loop for i from 0 below (array-total-size (text dialog))
          do (setf (aref s i) (aref (text dialog) i)))
    (loop for i from 0 below (array-total-size (dialogue:text rq))
          do (setf (aref s (+ i (array-total-size (text dialog)))) (aref (dialogue:text rq) i)))
    (setf (text dialog) s)))

(defmethod handle :after ((rq dialogue:target-request) (dialog dialog))
  (setf (ip dialog) (dialogue:target rq)))
