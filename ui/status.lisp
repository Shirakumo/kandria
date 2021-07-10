(in-package #:org.shirakumo.fraf.kandria)

(defclass status-line (alloy:label*)
  ((timeout :initarg :timeout :accessor timeout)
   (importance :initarg :importance :initform :normal :accessor importance)
   (times :initarg :times :initform 1 :accessor times)))

(defmethod alloy:text ((line status-line))
  (if (<= (times line) 1)
      (alloy:value line)
      (format NIL "~a (x~d)" (alloy:value line) (times line))))

(presentations:define-realization (ui status-line)
  ((:label simple:text)
   (alloy:margins) alloy:text
   :font (setting :display :font)
   :valign :top
   :halign :left
   :size (ecase (importance alloy:renderable)
           (:note (alloy:un 16))
           (:normal (alloy:un 20))
           (:important (alloy:un 26)))
   :pattern (ecase (importance alloy:renderable)
              (:note colors:white)
              (:normal colors:white)
              (:important colors:yellow))))

(presentations:define-update (ui status-line)
  (:label
   :text alloy:text
   :pattern (colored:color 1 1 1 (min 1 (* 2 (- (timeout alloy:renderable) (clock +world+)))))))

(defmethod alloy:render-needed-p ((line status-line)) T)

(defmethod alloy:suggest-bounds ((extent alloy:extent) (element status-line))
  (alloy:extent (alloy:x extent)
                (alloy:y extent)
                500
                (ecase (importance element)
                  (:note 20)
                  (:normal 26)
                  (:important 32))))

(defclass status-lines (panel)
  ())

(defmethod initialize-instance :after ((panel status-lines) &key)
  (let ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout))
        (list (make-instance 'alloy:vertical-linear-layout)))
    (alloy:enter list layout :constraints `((:left 20) (:top 100) (:size 1920 1000)))
    (alloy:finish-structure panel layout NIL)))

(defmethod alloy:enter ((string string) (panel status-lines) &key (importance :normal))
  (let ((layout (alloy:index-element 0 (alloy:layout-element panel))))
    (or (alloy:do-elements (element layout)
          (when (string= (alloy:value element) string)
            (incf (times element))
            (setf (timeout element) (+ (clock +world+) 4.0))
            (alloy:mark-for-render element)
            (return T)))
        (make-instance 'status-line :value string :timeout (+ (clock +world+) 4.0)
                                    :importance importance :layout-parent layout))))

(defun status (importance &optional string &rest args)
  (when (stringp importance)
    (push string args)
    (setf string importance)
    (setf importance :normal))
  (when +main+
    (with-eval-in-render-loop (+world+)
      (let ((panel (find-panel 'status-lines)))
        (when panel
          (alloy:enter (format NIL "~?" string args) panel :importance importance))))))

(defmethod handle ((ev tick) (panel status-lines))
  (let ((layout (alloy:index-element 0 (alloy:layout-element panel)))
        (clock (clock +world+)))
    (alloy:do-elements (element layout)
      (when (< (timeout element) clock)
        (when (slot-boundp element 'alloy:layout-parent)
          (alloy:leave element layout))))))

(defmethod clear ((panel status-lines))
  (let ((layout (alloy:index-element 0 (alloy:layout-element panel))))
    (alloy:do-elements (element layout)
      (when (slot-boundp element 'alloy:layout-parent)
        (alloy:leave element layout)))))
