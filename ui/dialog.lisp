(in-package #:org.shirakumo.fraf.leaf)

(defclass dialog-look-and-feel (presentations:renderer) ())

(defmethod presentations:update-shape progn ((renderer dialog-look-and-feel) thing shape))

(presentations:define-update (dialog-look-and-feel alloy:label)
  (:label :text alloy:text))

(define-shader-entity profile-picture (trial:animated-sprite alloy:layout-element)
  ()
  (:default-initargs :sprite-data (asset 'leaf 'player-profile)))

(defmethod alloy:render (target (picture profile-picture))
  (let* ((pass (unit 'ui-pass T))
         (program (shader-program-for-pass pass picture))
         (extent (alloy:bounds picture)))
    (with-pushed-matrix ((view-matrix :identity)
                         (model-matrix :identity))
      (translate-by (+ 128 (alloy:pxx extent)) (alloy:pxy extent) 0)
      (scale-by (/ (alloy:pxw extent) 128) (/ (alloy:pxh extent) 128) 1)
      (prepare-pass-program pass program)
      (render picture program))))

(defclass nametag (alloy:label) ())

(presentations:define-realization (dialog-look-and-feel nametag)
  ((:background simple:rectangle)
   (alloy:margins)
   :pattern (colored:color 0 136/255 238/255))
  ((:label simple:text)
   (alloy:margins 10 0 10 0)
   alloy:text
   :valign :bottom
   :font "PromptFont"
   :size (alloy:un 20)
   :pattern colors:white))

(defclass textbox (alloy:label) ())

(presentations:define-realization (dialog-look-and-feel textbox)
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

(presentations:define-realization (dialog-look-and-feel advance-prompt)
  ((:background simple:rectangle)
   (alloy:margins)
   :pattern (colored:color 0 136/255 238/255))
  ((:label simple:text)
   (alloy:margins 1)
   alloy:text
   :valign :middle
   :halign :right
   :font "PromptFont"
   :size (alloy:ph 0.8)
   :pattern colors:white))

(presentations:define-update (dialog-look-and-feel advance-prompt)
  (:background
   :hidden-p (null alloy:value))
  (:label
   :text alloy:text
   :hidden-p (null alloy:value)))

(defclass dialog-choice (alloy:button) ())

(presentations:define-realization (dialog-look-and-feel dialog-choice)
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

(presentations:define-update (dialog-look-and-feel dialog-choice)
  (:label
   :pattern colors:white
   :offset (alloy:point (if alloy:focus 10 0) 0))
  (:indicator
   :pattern (case alloy:focus
              (:strong colors:white)
              (:weak (colored:color 0 136/255 238/255))
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

(defclass dialog (dialog-look-and-feel ui entity renderable listener alloy:observable-object)
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
   (active-p :initform NIL :accessor active-p)))

(defmethod initialize-instance :after ((dialog dialog) &key)
  (let ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout :layout-parent (alloy:layout-tree dialog)))
        (textbox (alloy:represent (slot-value dialog 'text) 'textbox))
        (nametag (alloy:represent (slot-value dialog 'source) 'nametag))
        (prompt (alloy:represent (slot-value dialog 'prompt) 'advance-prompt))
        (choices (setf (choices dialog) (make-instance 'dialog-choice-list :focus-parent (alloy:focus-tree dialog)))))
    (alloy:enter textbox layout :constraints `((:left 20) (:right 20) (:bottom 20) (:height 200)))
    (alloy:enter (profile dialog) layout :constraints `((:left 80) (:above ,textbox) (:width 400) (:height 400)))
    (alloy:enter nametag layout :constraints `((:left 30) (:above ,textbox -10) (:height 30) (:width 300)))
    (alloy:enter choices layout :constraints `((:right 50) (:above ,textbox 10) (:width 400)))
    (alloy:enter prompt layout :constraints `((:right 20) (:bottom 20) (:size 100 30)))
    (alloy:register dialog dialog)))

(defmethod (setf active-p) :after (value (dialog dialog))
  (setf (prompt dialog) NIL)
  (setf (pending dialog) NIL)
  (setf (text dialog) (clear-text-string))
  (if value
      (pause-game T dialog)
      (unpause-game T dialog)))

(defmethod at-end-p ((dialog dialog))
  (<= (array-total-size (text dialog))
      (fill-pointer (text dialog))))

(defmethod register-object-for-pass :after ((dialog dialog) (pass ui-pass))
  (register-object-for-pass (profile pass) dialog))

(defmethod stage :after ((dialog dialog) (area staging-area))
  (stage (profile dialog) area))

(defmethod alloy:render ((renderer dialog) (dialog dialog))
  (when (active-p dialog)
    (call-next-method)))

(defmethod handle ((ev interaction) (dialog dialog))
  (let ((interaction (first (interactions (with ev)))))
    (when interaction
      (setf (active-p interaction) T)
      (dialogue:reset (vm dialog))
      (dialogue:run interaction (vm dialog))
      (advance dialog))))

(defmethod scroll-text ((dialog dialog) to)
  (when (<= to (array-total-size (text dialog)))
    (setf (fill-pointer (text dialog)) to)
    (setf (text dialog) (text dialog))))

(defmethod handle ((ev tick) (dialog dialog))
  (when (active-p dialog)
    (handle ev (unit :camera +world+))
    (handle ev (profile dialog))
    (cond ((and (at-end-p dialog)
                (not (prompt dialog)))
           (cond ((< 0 (pause-timer dialog))
                  (decf (pause-timer dialog) (dt ev)))
                 ((pending dialog)
                  (ecase (first (pending dialog))
                    (:emote (setf (animation (profile dialog)) (second (pending dialog))))
                    (:prompt (setf (prompt dialog) (second (pending dialog))))
                    (:end (setf (active-p dialog) NIL)))
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
                      ((#\. #\! #\? #\: #\;) 5)
                      ((#\,) 2.5)
                      (T 1))))))))

(defmethod handle ((ev advance) (dialog dialog))
  (when (active-p dialog)
    (cond ((/= 0 (alloy:element-count (choices dialog)))
           (setf (prompt dialog) NIL)
           (alloy:activate (choices dialog)))
          ((prompt dialog)
           (setf (prompt dialog) NIL)
           (setf (text dialog) (clear-text-string))
           (advance dialog))
          (T
           (loop until (prompt dialog)
                 do (advance dialog))
           (scroll-text dialog (array-total-size (text dialog)))))))

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
