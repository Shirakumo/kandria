(in-package #:org.shirakumo.fraf.kandria)

#+windows
(progn
  (cffi:defcstruct (io-counters :conc-name io-counters-)
    (reads :ullong)
    (writes :ullong)
    (others :ullong)
    (read-bytes :ullong)
    (write-bytes :ullong)
    (other-bytes :ullong))
  (cffi:defcfun (current-process "GetCurrentProcess") :pointer)
  (cffi:defcfun (process-io-counters "GetProcessIoCounters") :bool
    (process :pointer)
    (counters :pointer)))

#+linux
(progn
  ;; FIXME: do this with netstat/taskstats at some point.
  #++
  (cffi:defcstruct taskstats
    (version :uint16)
    (exitcode :uint32)
    (flag :uint8)
    (nice :uint8)
    (cpu-count :uint64)
    (cpu-delay :uint64)
    (block-io-iocunt :uint64)
    (block-io-delay :uint64)
    (cpu-run-real :uint64)
    (cpu-run-virt :uint64)
    (command :char :count 32)
    (scheduler :uint8)
    (pad :uint8 :count 3)
    (uid :uint32)
    (gid :uint32)
    (pid :uint32)
    (ppid :uint32)
    (btime :uint32)
    (etime :uint64)
    (utime :uint64)
    (stime :uint64)
    (minflt :uint64)
    (majflt :uint64)
    (core-memory :uint64)
    (virt-memory :uint64)
    (hiwater-rss :uint64)
    (hiwater-vm :uint64)
    (read-char :uint64)
    (write-char :uint64)
    (read-syscalls :uint64)
    (write-syscalls :uint64)
    (read-bytes :uint64)
    (write-bytes :uint64)
    (cancelled-write-bytes :uint64)
    (nvcsw :uint64)
    (nivcsw :uint64)
    (utime-scaled :uint64)
    (stime-scaled :uint64)
    (cpu-scaled-run-real-total :uint64)
    (free-pages-count :uint64)
    (free-pages-delay :uint64)
    (thrashing-count :uint64)
    (thrashing-delay :uint64)
    (btime-64 :uint64))
  
  (cffi:defcstruct timeval
    (a :uint64)
    (b :uint64))
  (cffi:defcstruct (rusage :conc-name rusage-)
    (utime (:struct timeval))
    (stime (:struct timeval))
    (maxrss :long)
    (ixrss :long)
    (idrss :long)
    (isrss :long)
    (minflt :long)
    (majflt :long)
    (nswap :long)
    (inblock :long)
    (oublock :long)
    (msgsnd :long)
    (msgrcv :long)
    (nsignals :long)
    (nvcsw :long)
    (nivcsw :long))
  (cffi:defcfun (rusage "getrusage") :int
    (who :int)
    (struct :pointer)))

(defun io-bytes ()
  0
  #+windows
  (cffi:with-foreign-object (io-counters '(:struct io-counters))
    (process-io-counters (current-process) io-counters)
    (+ (io-counters-read-bytes io-counters)
       (io-counters-write-bytes io-counters)
       (io-counters-other-bytes io-counters)))
  #+linux
  (cffi:with-foreign-object (rusage '(:struct rusage))
    (rusage 0 rusage)
    (+ (rusage-inblock rusage)
       (rusage-oublock rusage))))

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
Machine:            ~a ~a
SWANK:              ~a"
            (version :app)
            (lisp-implementation-type) (lisp-implementation-version)
            (machine-type) (machine-version)
            (setting :debugging :swank))
    (context-info *context* stream :show-extensions NIL)))

(defun runtime-info ()
  (let ((player (unit 'player T)))
    (format NIL "~
Region:             ~a
Chunk:              ~a
Location:           ~7,2f ~7,2f
Velocity:           ~7,2f ~7,2f
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
            (svref (collisions player) 3))))

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
    (alloy:enter machine-info layout :constraints `((:size 600 300) (:right-of ,fps 10) (:top 10)))
    (alloy:enter info layout :constraints `((:size 600 2000) (:right-of ,fps 10) (:below ,machine-info 10)))
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
