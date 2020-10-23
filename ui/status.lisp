(in-package #:org.shirakumo.fraf.kandria)

(defclass status-line (alloy:label*)
  ((timeout :initarg :timeout :accessor timeout)))

(presentations:define-realization (ui status-line)
  ((:label simple:text)
   (alloy:margins) alloy:text
   :font "PromptFont"
   :valign :top
   :halign :left
   :size (alloy:un 12)
   :pattern colors:white))

(defclass status-lines (panel)
  ())

(defmethod initialize-instance :after ((panel status-lines) &key)
  (let ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout))
        (list (make-instance 'alloy:vertical-linear-layout)))
    (alloy:enter list layout :constraints `((:left 10) (:top 100) (:size 500 1000)))
    (alloy:finish-structure panel layout NIL)))

(defmethod alloy:enter ((string string) (panel status-lines) &key)
  (let ((layout (alloy:index-element 0 (alloy:layout-element panel))))
    (make-instance 'status-line :value string :timeout (+ (clock +world+) 4.0) :layout-parent layout)))

(defun status (string &rest args)
  (let ((panel (find-panel 'status-lines)))
    (when panel
      (alloy:enter (format NIL "~?" string args) panel))))

(defmethod handle ((ev tick) (panel status-lines))
  (let ((layout (alloy:index-element 0 (alloy:layout-element panel)))
        (clock (clock +world+)))
    (alloy:do-elements (element layout)
      (when (< (timeout element) clock)
        (alloy:leave element layout)))))
