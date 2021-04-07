(in-package #:org.shirakumo.fraf.kandria)

(defclass timer-line (alloy:label)
  ((alloy:value :initform "00:00")))

(defmethod alloy:text ((timer timer-line))
  (let ((clock (alloy:value timer)))
    (multiple-value-bind (ts ms) (floor clock)
      (multiple-value-bind (tm s) (floor ts 60)
        (format NIL "~2,'0d:~2,'0d.~2,'0d"
                tm s (floor (* 10 ms)))))))

(presentations:define-realization (ui timer-line)
  ((:label simple:text)
   (alloy:margins) alloy:text
   :font (setting :display :font)
   :valign :middle
   :halign :middle
   :size (alloy:un 26)
   :pattern colors:white))

(presentations:define-update (ui timer-line)
  (:label :pattern colors:white))

(defclass timer (panel)
  ((quest :initarg :quest :accessor quest)))

(defmethod initialize-instance :after ((panel timer) &key quest)
  (let ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout))
        (timer (alloy:represent (clock quest) 'timer-line)))
    (alloy:enter timer layout :constraints `((:center :w) (:top 50) (:size 1920 30)))
    (alloy:finish-structure panel layout NIL)))

(defmethod hide :after ((panel timer))
  (alloy:remove-observers 'clock (quest panel)))

