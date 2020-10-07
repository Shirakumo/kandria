(in-package #:org.shirakumo.fraf.leaf)

(defclass diagnostics (panel alloy:observable-object)
  ((fps :initform (make-array 600 :initial-element 0.0 :element-type 'single-float))
   (ram :initform (make-array 600 :initial-element 0.0 :element-type 'single-float))
   (vram :initform (make-array 600 :initial-element 0.0 :element-type 'single-float))))

(defmethod initialize-instance :after ((panel diagnostics) &key)
  (let ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout))
        (fps (alloy:represent (slot-value panel 'fps) 'alloy:plot
                              :y-range '(1 . 60) :style `((:curve :line-width ,(alloy:un 2)))))
        (ram (alloy:represent (slot-value panel 'ram) 'alloy:plot
                              :y-range `(0 . ,(nth-value 1 (cpu-room))) :style `((:curve :line-width ,(alloy:un 2)))))
        (vram (alloy:represent (slot-value panel 'vram) 'alloy:plot
                               :y-range `(0 . ,(nth-value 1 (gpu-room))) :style `((:curve :line-width ,(alloy:un 2))))))
    (alloy:enter fps layout :constraints `((:size 300 150) (:left 10) (:top 10)))
    (alloy:enter ram layout :constraints `((:size 300 150) (:left 10) (:below ,fps 10)))
    (alloy:enter vram layout :constraints `((:size 300 150) (:left 10) (:below ,ram 10)))
    (alloy:enter "FPS" layout :constraints `((:size 100 20) (:inside ,fps :halign :left :valign :top :margin 5)))
    (alloy:enter "RAM" layout :constraints `((:size 100 20) (:inside ,ram :halign :left :valign :top :margin 5)))
    (alloy:enter "VRAM" layout :constraints `((:size 100 20) (:inside ,vram :halign :left :valign :top :margin 5)))
    (alloy:finish-structure panel layout NIL)))

(defmethod handle ((ev tick) (panel diagnostics))
  (let ((fps (slot-value panel 'fps))
        (ram (slot-value panel 'ram))
        (vram (slot-value panel 'vram)))
    (flet ((push-value (value array)
             (declare (type (simple-array single-float (*)) array))
             (loop for i from 1 below (length array)
                   do (setf (aref array (1- i)) (aref array i)))
             (setf (aref array (1- (length array))) (float value 1f0))))
      (let ((frame-time (frame-time (handler *context*))))
        (push-value (if (= 0 frame-time) 1 (/ frame-time)) fps))
      (setf (slot-value panel 'fps) fps)
      (multiple-value-bind (free total) (cpu-room)
        (push-value (- total free) ram))
      (setf (slot-value panel 'ram) ram)
      (multiple-value-bind (free total) (gpu-room)
        (push-value (- total free) vram))
      (setf (slot-value panel 'vram) vram))))
