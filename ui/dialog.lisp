(in-package #:org.shirakumo.fraf.leaf)

(defclass dialog (ui entity listener alloy:observable)
  ((vm :initform (make-instance 'dialogue:vm) :reader vm)
   (ip :initform 0 :accessor ip)
   (tick :initform 0 :accessor tick)
   (pause :initform 0 :accessor pause)
   (text :initform "" :accessor text)
   (source :initform "" :accessor source)
   (emote :initform NIL :accessor emote)
   (per-letter-tick :initform 0.1 :accessor per-letter-tick)))

(defmethod initialize-instance :after ((dialog dialog) &key)
  (let ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout :layout-parent dialog))
        (focus (make-instance 'alloy:focus-list :focus-parent dialog))
        (choices (make-instance 'alloy:vertical-linear-layout)))
    (alloy:enter (alloy:represent (text dialog) 'alloy:label)
                 :constraints '((:left 10) (:right 10) (:bottom 10) (:height 300)))
    (alloy:enter choices
                 :constraints '((:right 5) (:bottom 300) (:width 100)))))

(defmethod at-end-p ((dialog dialog))
  (<= (array-total-size (text dialog))
      (fill-pointer (text dialog))))

(defmethod handle ((ev interaction) (dialog dialog))
  (let ((interactions (interactions (with ev))))
    (when interactions
      (pause-game T dialog)
      (dialogue:reset (vm dialog))
      (dialogue:run (first interactions) (vm dialog)))))

(defmethod handle ((ev tick) (dialog dialog))
  (if (at-end-p dialog)
      ;; Process pausing
      (when (< 0 (pause dialog))
        (decf (pause dialog) (dt ev))
        (when (<= (pause dialog) 0)
          (advance dialog)))
      ;; Process text scrolling
      (when (< 0 (tick dialog))
        (decf (tick dialog) (dt ev))
        (when (<= (tick dialog) 0)
          (incf (fill-pointer (text dialog)))
          (setf (tick dialog) (per-letter-tick dialog))))))

(defmethod handle ((ev advance) (dialog dialog))
  (if (at-end-p dialog)
      (advance dialog)
      (setf (fill-pointer (text dialog))
            (array-total-size (text dialog)))))

(defmethod advance ((dialog dialog))
  (alloy:clear (choices dialog))
  (handle (dialogue:resume (vm dialog) (ip dialog)) dialog))

(defmethod handle ((rq dialogue:end-request) (dialog dialog))
  (unpause-game T dialog))

(defmethod handle ((rq dialogue:choice-request) (dialog dialog))
  (loop for choice in (dialogue:choices rq)
        for target in (dialogue:targets rq)
        do (let* ((choice choice) (target target)
                  (button (alloy:represent choice 'alloy:button)))
             (alloy:on (alloy:activate button)
               (setf (ip dialog) target)
               (advance dialog))
             (alloy:enter button (choices dialog)))))

(defmethod handle ((rq dialogue:confirm-request) (dialog dialog)))

(defmethod handle ((rq dialogue:source-request) (dialog dialog))
  (setf (source dialog) (dialogue:name rq)))

(defmethod handle ((rq dialogue:emote-request) (dialog dialog))
  (setf (emote dialog) (dialogue:emote rq)))

(defmethod handle ((rq dialogue:pause-request) (dialog dialog))
  (setf (pause dialog) (dialogue:duration rq)))

(defmethod handle :after ((rq dialogue:text-request) (dialog dialog))
  (let* ((orig (dialogue:text rq))
         (text (make-array (length orig) :fill-pointer 0 :element-type 'character :initial-content orig)))
    (setf (alloy:text dialog) text)))

(defmethod handle :after ((rq dialogue:target-request) (dialog dialog))
  (setf (ip dialog) (dialogue:target rq)))
