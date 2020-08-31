(in-package #:org.shirakumo.fraf.leaf)

(defclass nametag (alloy:label) ())

(presentations:define-realization (presentations:default-look-and-feel nametag)
  ((:background simple:rectangle)
   (alloy:margins))
  ((:label simple:text)
   (alloy:margins 10 0 10 0)
   alloy:text
   :valign :bottom
   :font "PromptFont"
   :size (alloy:un 20)))

(presentations:define-update (presentations:default-look-and-feel nametag)
  (:background
   :pattern (colored:color 0 136/255 238/255))
  (:label
   :pattern (colored:color 0 0 0)))

(defclass textbox (alloy:label) ())

(presentations:define-realization (presentations:default-look-and-feel textbox)
  ((:background simple:rectangle)
   (alloy:margins))
  ((:label simple:text)
   (alloy:margins 30 40 60 30)
   alloy:text
   :valign :top
   :halign :left
   :wrap T
   :font "PromptFont"
   :size (alloy:un 25)))

(defclass combined-list (alloy:vertical-linear-layout alloy:focus-chain)
  ())

(defun fill-pointer-string (string)
  (make-array (length string) :fill-pointer 0 :element-type 'character :initial-contents string))

(defclass dialog (ui entity renderable listener alloy:observable)
  ((vm :initform (make-instance 'dialogue:vm) :reader vm)
   (ip :initform 0 :accessor ip)
   (char-timer :initform 0.1 :accessor char-timer)
   (pause-timer :initform 0 :accessor pause-timer)
   (choices :initform NIL :accessor choices)
   (text :initform (fill-pointer-string "") :accessor text)
   (source :initform "Name" :accessor source)
   (emote :initform NIL :accessor emote)
   (per-letter-tick :initform 0.02 :accessor per-letter-tick)
   (active-p :initform T :accessor active-p)))

(defmethod initialize-instance :after ((dialog dialog) &key)
  (let ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout :layout-parent (alloy:layout-tree dialog)))
        (choices (setf (choices dialog) (make-instance 'combined-list :focus-parent (alloy:focus-tree dialog)))))
    (alloy:enter (alloy:represent (text dialog) 'textbox) layout
                 :constraints '((:left 20) (:right 20) (:bottom 20) (:height 200)))
    (alloy:enter (alloy:represent (source dialog) 'nametag) layout
                 :constraints '((:left 30) (:bottom 210) (:height 30) (:width 300)))
    (alloy:enter choices layout
                 :constraints '((:right 5) (:bottom 300) (:width 100) (:min-height 0) (:max-height 300)))
    (alloy:register dialog dialog)

    (dialogue:run "~ Test
| Hello there." (vm dialog))))

(defmethod (setf active-p) :after (value (dialog dialog))
  (if value
      (pause-game T dialog)
      (unpause-game T dialog)))

(defmethod at-end-p ((dialog dialog))
  (<= (array-total-size (text dialog))
      (fill-pointer (text dialog))))

(defmethod alloy:render ((renderer dialog) (dialog dialog))
  (when (active-p dialog)
    (call-next-method)))

(defmethod handle ((ev interaction) (dialog dialog))
  (let ((interaction (first (interactions (with ev)))))
    (when interaction
      (setf (active-p interaction) T)
      (dialogue:reset (vm dialog))
      (dialogue:run interaction (vm dialog)))))

(defmethod scroll-text ((dialog dialog) to)
  (setf (fill-pointer (text dialog)) to)
  (alloy:do-elements (e (alloy:root (alloy:layout-tree dialog)))
    (when (typep e 'textbox)
      (alloy:mark-for-render e))))

(defmethod handle ((ev tick) (dialog dialog))
  (when (active-p dialog)
    (handle ev (unit :camera +world+))
    (if (at-end-p dialog)
        ;; Process pausing
        (when (< 0 (pause-timer dialog))
          (decf (pause-timer dialog) (dt ev))
          (when (<= (pause-timer dialog) 0)
            (advance dialog)))
        ;; Process text scrolling
        (when (< 0 (char-timer dialog))
          (decf (char-timer dialog) (dt ev))
          (when (<= (char-timer dialog) 0)
            (scroll-text dialog (1+ (fill-pointer (text dialog))))
            (setf (char-timer dialog) (per-letter-tick dialog)))))))

(defmethod handle ((ev advance) (dialog dialog))
  (when (active-p dialog)
    (cond ((null (at-end-p dialog))
           (scroll-text dialog (array-total-size (text dialog))))
          ((/= 0 (alloy:element-count (choices dialog)))
           (alloy:activate (choices dialog)))
          (T
           (advance dialog)))))

(defmethod advance ((dialog dialog))
  (alloy:clear (choices dialog))
  (handle (dialogue:resume (vm dialog) (ip dialog)) dialog))

(defmethod handle ((rq dialogue:end-request) (dialog dialog))
  (setf (active-p dialog) NIL))

(defmethod handle ((rq dialogue:choice-request) (dialog dialog))
  (loop for choice in (dialogue:choices rq)
        for target in (dialogue:targets rq)
        do (let* ((choice choice) (target target)
                  (button (alloy:represent choice 'alloy:button)))
             (alloy:on alloy:activate (button)
               (setf (ip dialog) target)
               (advance dialog))
             (alloy:enter button (choices dialog)))))

(defmethod handle ((rq dialogue:confirm-request) (dialog dialog)))

(defmethod handle ((rq dialogue:source-request) (dialog dialog))
  (setf (source dialog) (dialogue:name rq)))

(defmethod handle ((rq dialogue:emote-request) (dialog dialog))
  (setf (emote dialog) (dialogue:emote rq)))

(defmethod handle ((rq dialogue:pause-request) (dialog dialog))
  (setf (pause-timer dialog) (dialogue:duration rq)))

(defmethod handle :after ((rq dialogue:text-request) (dialog dialog))
  (setf (text dialog) (fill-pointer-string (dialogue:text rq))))

(defmethod handle :after ((rq dialogue:target-request) (dialog dialog))
  (setf (ip dialog) (dialogue:target rq)))
