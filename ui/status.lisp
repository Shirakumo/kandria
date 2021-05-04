(in-package #:org.shirakumo.fraf.kandria)

(defclass status-line (alloy:label*)
  ((timeout :initarg :timeout :accessor timeout)
   (importance :initarg :importance :initform :normal :accessor importance)))

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

(defmethod presentations:update-shape :around ((ui ui) (line status-line) shape))

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
    (make-instance 'status-line :value string :timeout (+ (clock +world+) 4.0)
                                :importance importance :layout-parent layout)))

(defun status (importance &optional string &rest args)
  (when (stringp importance)
    (push string args)
    (setf string importance)
    (setf importance :normal))
  (when +main+
    (flet ((thunk ()
             (let ((panel (find-panel 'status-lines)))
               (when panel
                 (alloy:enter (format NIL "~?" string args) panel :importance importance)))))
      (if *scene*
          (thunk)
          (with-eval-in-render-loop (+world+)
            (thunk))))))

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
