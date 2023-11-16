(in-package #:org.shirakumo.fraf.kandria)

(defclass diagnostics-label (alloy:label)
  ())

(presentations:define-realization (ui diagnostics-label)
  ((:label simple:text)
   (alloy:margins)
   alloy:text
   :pattern (colored:color 1 1 1)
   :size (alloy:un 18)
   :halign :start :valign :top
   :font "NotoSansMono"))

(defclass diagnostics (panel alloy:observable-object)
  ((fps :initform (make-array 600 :initial-element 0.0 :element-type 'single-float))
   (ram :initform (make-array 600 :initial-element 0.0 :element-type 'single-float))
   (vram :initform (make-array 600 :initial-element 0.0 :element-type 'single-float))
   (io :initform (make-array 600 :initial-element 0.0 :element-type 'single-float))
   (gc :initform (make-array 600 :initial-element 0.0 :element-type 'single-float))
   (info :initform "")
   (qinfo :initform "")
   (last-io :initform 0)
   (last-gc :initform 0)))

(defun machine-info ()
  (with-output-to-string (stream)
    (format stream "~
Version:            ~a
Implementation:     ~a ~a
Machine:            ~a ~a (~aGB heap)
SWANK:              ~a"
            (version :app)
            (lisp-implementation-type) (lisp-implementation-version)
            (machine-type) (machine-version) (floor (nth-value 1 (trial:cpu-room)) (* 1024 1024))
            (setting :debugging :swank))
    (context-info *context* :stream stream :show-extensions NIL)))

(defun runtime-info ()
  (let ((player (unit 'player T)))
    (if player
        (format NIL "~
Region:             ~a
Chunk:              ~a
Location:           ~7,2f ~7,2f
Velocity:           ~7,2f ~7,2f
Direction:         ~@d
State:              ~a
Animation:          ~a
Health:             ~d
Stun:               ~7,2f
Iframes:            ~d
Interactable:       ~a
Spawn:              ~7,2f ~7,2f
Collisions:
  T: ~a
  R: ~a
  B: ~a
  L: ~a"
                (name (region +world+))
                (name (chunk player))
                (vx (location player)) (vy (location player))
                (vx (velocity player)) (vy (velocity player))
                (direction player)
                (state player)
                (name (animation player))
                (health player)
                (stun-time player)
                (iframes player)
                (interactable player)
                (vx (spawn-location player)) (vy (spawn-location player))
                (svref (collisions player) 0)
                (svref (collisions player) 1)
                (svref (collisions player) 2)
                (svref (collisions player) 3))
        "")))

(defmethod initialize-instance :after ((panel diagnostics) &key)
  (let ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout))
        (fps (alloy:represent (slot-value panel 'fps) 'alloy:plot
                              :y-range '(1 . 60) :style `((:curve :line-width ,(alloy:un 2)))))
        (ram (alloy:represent (slot-value panel 'ram) 'alloy:plot
                              :y-range `(0 . ,(nth-value 1 (cpu-room))) :style `((:curve :line-width ,(alloy:un 2)))))
        (vram (alloy:represent (slot-value panel 'vram) 'alloy:plot
                               :y-range `(0 . ,(nth-value 1 (gpu-room))) :style `((:curve :line-width ,(alloy:un 2)))))
        (io (alloy:represent (slot-value panel 'io) 'alloy:plot
                             :y-range `(0 . 1024) :style `((:curve :line-width ,(alloy:un 2)))))
        (gc (alloy:represent (slot-value panel 'gc) 'alloy:plot
                             :y-range `(0 . 100) :style `((:curve :line-width ,(alloy:un 2)))))
        (machine-info (alloy:represent (machine-info) 'diagnostics-label))
        (info (alloy:represent (slot-value panel 'info) 'diagnostics-label)))
    (alloy:enter fps layout :constraints `((:size 300 120) (:left 10) (:top 10)))
    (alloy:enter ram layout :constraints `((:size 300 120) (:left 10) (:below ,fps 10)))
    (alloy:enter vram layout :constraints `((:size 300 120) (:left 10) (:below ,ram 10)))
    (alloy:enter io layout :constraints `((:size 300 120) (:left 10) (:below ,vram 10)))
    (alloy:enter gc layout :constraints `((:size 300 120) (:left 10) (:below ,io 10)))
    (alloy:enter "FPS" layout :constraints `((:size 100 20) (:inside ,fps :halign :left :valign :top :margin 5)))
    (alloy:enter "RAM" layout :constraints `((:size 100 20) (:inside ,ram :halign :left :valign :top :margin 5)))
    (alloy:enter "VRAM" layout :constraints `((:size 100 20) (:inside ,vram :halign :left :valign :top :margin 5)))
    (alloy:enter "IO" layout :constraints `((:size 100 20) (:inside ,io :halign :left :valign :top :margin 5)))
    (alloy:enter "GC Pause" layout :constraints `((:size 100 20) (:inside ,gc :halign :left :valign :top :margin 5)))
    (alloy:enter machine-info layout :constraints `((:right-of ,fps 10) (:top 10) (:right 10) (:height 300)))
    (alloy:enter info layout :constraints `((:right-of ,fps 10) (:below ,machine-info 10) (:right 10) (:bottom 10)))
    (alloy:finish-structure panel layout NIL)))

(defmethod handle ((ev tick) (panel diagnostics))
  (with-slots (fps ram vram io last-io gc last-gc info qinfo) panel
    (flet ((push-value (value array)
             (declare (type (simple-array single-float (*)) array))
             (loop for i from 1 below (length array)
                   do (setf (aref array (1- i)) (aref array i)))
             (setf (aref array (1- (length array))) (float value 1f0))))
      (let ((frame-time (frame-time +main+)))
        (push-value (if (= 0 frame-time) 1 (/ frame-time)) fps))
      (alloy:notify-observers 'fps panel fps panel)
      (multiple-value-bind (free total) (cpu-room)
        (push-value (- total free) ram))
      (alloy:notify-observers 'ram panel ram panel)
      (multiple-value-bind (free total) (gpu-room)
        (push-value (- total free) vram))
      (alloy:notify-observers 'vram panel vram panel)
      (let ((total (io-bytes)))
        (when (< 0 last-io)
          (push-value (- total last-io) io))
        (setf last-io total))
      (alloy:notify-observers 'io panel io panel)
      (let ((total sb-ext:*gc-run-time*))
        (when (< 0 last-gc)
          (push-value (- total last-gc) gc))
        (setf last-gc total))
      (alloy:notify-observers 'gc panel gc panel)
      (setf info (runtime-info)))))
