(in-package #:org.shirakumo.fraf.kandria)

(defclass world (pipelined-scene)
  ((depot :initarg :depot :accessor depot)
   (storyline :initarg :storyline :initform (make-instance 'quest:storyline) :accessor storyline)
   (regions :initarg :regions :initform (make-hash-table :test 'eq) :accessor regions)
   (handler-stack :initform () :accessor handler-stack)
   (initial-state :initform NIL :accessor initial-state)
   (time-scale :initform 1.0 :accessor time-scale)
   (pause-timer :initform 0.0 :accessor pause-timer)
   (clock-scale :initform 60.0 :accessor clock-scale)
   (update-timer :initform 0.2 :accessor update-timer)
   (timestamp :initform (initial-timestamp) :accessor timestamp)
   (camera :initform (make-instance 'camera) :accessor camera))
  (:default-initargs
   :depot (error "DEPOT required.")))

(defmethod initialize-instance :after ((world world) &key depot)
  (enter (make-instance 'environment-controller) world)
  (dolist (progression '(death hurt transition start-game game-end low-health))
    (enter (progression-instance progression) world))
  (let ((sub (depot:ensure-depot (depot:entry "regions" depot))))
    (dolist (entry (depot:list-entries sub))
      (let ((depot (depot:ensure-depot entry)))
        (let ((name (getf (second (parse-sexps (depot:read-from (depot:entry "meta.lisp" depot) 'character)))
                          :name)))
          (setf (gethash name (regions world)) depot)))))
  (setf (initial-state world) (minimal-load-state (depot:entry "init" depot))))

(defmethod finalize :after ((world world))
  (close (depot world) :abort T))

(defmethod hour ((world world))
  (mod (float (/ (nth-value 1 (truncate (+ (timestamp world) 432000) (* 60 60 24 7))) 60 60) 0d0) 24d0))

(defmethod (setf timestamp) :after (timestamp (world world))
  (issue world 'change-time :timestamp timestamp))

(defmethod (setf time-scale) :around (scale (world world))
  (call-next-method (max scale 0.001) world))

(defmethod (setf hour) (hour (world world))
  (multiple-value-bind (ss mm hh d m y) (decode-universal-time (truncate (timestamp world)))
    (declare (ignore hh))
    (setf (timestamp world) (float (encode-universal-time ss mm (truncate (mod hour 24)) d m y 0) 0d0))))

(defmethod scan ((world world) target on-hit)
  (scan (region world) target on-hit))

(defmethod pause-game ((_ (eql T)) pauser)
  (pause-game +world+ pauser))

(defmethod unpause-game ((_ (eql T)) pauser)
  (unpause-game +world+ pauser))

(defmethod pause-game ((world world) pauser)
  (unless (handler-stack world)
    (let ((segment (harmony:segment :music-lowpass T)))
      (when (< 50 (abs (- (mixed:frequency segment) 400)))
        (setf (mixed:frequency segment) 400.0)))
    (harmony:transition (unit 'environment world) 0.2 :in 0.5))
  (push pauser (handler-stack world)))

(defmethod unpause-game ((world world) pauser)
  (let ((found NIL))
    (flet ((test (handler)
             (cond (found
                    NIL)
                   ((eq handler pauser)
                    (setf found T)))))
      (setf (handler-stack world) (remove-if #'test (handler-stack world))))
    (when (and found (null (handler-stack world)))
      (let* ((segment (harmony:segment :music-lowpass T))
             (target (1- (mixed:samplerate segment))))
        (when (< 50 (abs (- (mixed:frequency segment) target)))
          (setf (mixed:frequency segment) target)))
      (harmony:transition (unit 'environment world) 1.0))))

(defmethod region-entry ((name symbol) (world world))
  (or (gethash name (regions world))
      (error "No such region ~s" name)))

(defmethod region-entry ((region region) (world world))
  (region-entry (name region) world))

(defmethod enter :after ((region region) (world world))
  (setf (gethash 'region (name-map world)) region)
  ;; Register region in region table if the region is new.
  (unless (gethash (name region) (regions world))
    (setf (gethash (name region) (regions world))
          (depot:ensure-depot (depot:ensure-entry (format NIL "regions/~a/" (string-downcase (name region)))
                                                  (depot world)))))
  ;; Let everyone know we switched the region.
  (issue world 'switch-region :region region))

(defmethod leave :after ((region region) (world world))
  (when (eq region (gethash 'region (name-map world)))
    (remhash 'region (name-map world))))

(defun saving-possible-p ()
  (let ((player (unit 'player +world+)))
    (and (null (find-panel 'dialog))
         player
         (svref (collisions player) 2)
         (eql :normal (state player))
         (do-visible (entity (camera +world+) (region +world+) T)
           (when (typep entity 'enemy) (return NIL))))))

(defun save-point-available-p ()
  (when (chunk (unit 'player +world+))
    (bvh:do-fitting (object (bvh (region +world+)) (chunk (unit 'player +world+)))
      (when (typep object 'save-point)
        (return T)))))

(defun pausing-possible-p ()
  (let ((player (unit 'player +world+)))
    (and (null (find-panel 'menuing-panel))
         (null (find-panel 'map-panel))
         (null (find-panel 'load-panel))
         player
         (svref (collisions player) 2)
         (not (eql :dying (state player)))
         (not (eql :respawning (state player))))))

;; Preloading
(defmethod stage :before ((world world) (area staging-area))
  (stage (c2mop:ensure-finalized (find-class 'sprite-effect)) (unit 'render world))
  (stage (c2mop:ensure-finalized (find-class 'sting-effect)) (unit 'render world))
  (stage (c2mop:ensure-finalized (find-class 'text-effect)) (unit 'render world)))

(defmethod stage :after ((world world) (area staging-area))
  (stage (// 'kandria 'placeholder) area)
  (stage (// 'kandria 'effects 'texture) area)
  (stage (// 'kandria 'effects 'vertex-array) area)
  (stage (// 'kandria 'items) area)
  (stage (// 'kandria 'particles) area)
  ;; KLUDGE: This suuuuckkkss
  (stage (// 'music 'battle) area))

(defmethod region ((world world))
  (gethash 'region (name-map world)))

(defmethod handle ((event event) (world world))
  (let ((handler (car (handler-stack world))))
    (cond (handler
           (handle event (unit :controller world))
           (handle event (camera +world+))
           (handle event (unit 'fade world))
           (handle event handler))
          (T
           (call-next-method)))))

(defmethod handle :after ((ev key-press) (world world))
  ;; KLUDGE: bind ESC to menu always
  (when (eql :escape (key ev))
    (when (pausing-possible-p)
      (show-panel 'menu)))
  (when (setting :debugging :camera-control)
    (let ((xoff 200)
          (yoff 100))
      (case (key ev)
        (:kp-enter
         (let ((player (unit 'player world))
               (sentinel (unit :sentinel world)))
           (cond ((null player))
                 ((null sentinel)
                  (setf sentinel (make-instance 'sentinel :location (vcopy (location player))))
                  (enter sentinel world)
                  (setf (target (camera +world+)) sentinel))
                 (T
                  (leave sentinel world)
                  (setf (target (camera +world+)) player)))))
        (:kp-multiply
         (setf (game-speed +main+) (* (game-speed +main+) 2.0)))
        (:kp-divide
         (setf (game-speed +main+) (/ (game-speed +main+) 2.0)))
        (:kp-add
         (setf (intended-zoom (camera +world+))
               (clamp 0.1 (expt 2 (+ (log (intended-zoom (camera +world+)) 2) 0.1)) 10.0)))
        (:kp-subtract
         (setf (intended-zoom (camera +world+))
               (clamp 0.1 (expt 2 (- (log (intended-zoom (camera +world+)) 2) 0.1)) 10.0)))
        (:kp-0
         (setf (intended-zoom (camera +world+)) 1.0))
        (:kp-7
         (setf (fix-offset (camera +world+)) T)
         (setf (offset (camera +world+)) (vec (- xoff) (+ yoff))))
        (:kp-8
         (setf (fix-offset (camera +world+)) T)
         (setf (offset (camera +world+)) (vec 0 (+ yoff))))
        (:kp-9
         (setf (fix-offset (camera +world+)) T)
         (setf (offset (camera +world+)) (vec (+ xoff) (+ yoff))))
        (:kp-4
         (setf (fix-offset (camera +world+)) T)
         (setf (offset (camera +world+)) (vec (- xoff) 0)))
        (:kp-5
         (setf (fix-offset (camera +world+)) NIL)
         (setf (offset (camera +world+)) (vec 0 0)))
        (:kp-6
         (setf (fix-offset (camera +world+)) T)
         (setf (offset (camera +world+)) (vec (+ xoff) 0)))
        (:kp-1
         (setf (fix-offset (camera +world+)) T)
         (setf (offset (camera +world+)) (vec (- xoff) (- yoff))))
        (:kp-2
         (setf (fix-offset (camera +world+)) T)
         (setf (offset (camera +world+)) (vec 0 (- yoff))))
        (:kp-3
         (setf (fix-offset (camera +world+)) T)
         (setf (offset (camera +world+)) (vec (+ xoff) (- yoff))))))))

(defmethod handle :after ((ev report-bug) (world world))
  (toggle-panel 'report-panel))

(defmethod handle :after ((ev toggle-fullscreen) (world world))
  (setf (setting :display :fullscreen) (not (setting :display :fullscreen))))

#-kandria-demo
(defmethod handle :after ((ev toggle-editor) (world world))
  (when (and (not (find-panel 'menu))
             (setting :debugging :allow-editor)
             (region world))
    (toggle-panel 'editor)))

(defmethod handle :after ((ev toggle-diagnostics) (world world))
  (cond ((find-panel 'gamepad-diagnostics)
         (hide-panel 'gamepad-diagnostics))
        ((find-panel 'diagnostics)
         (hide-panel 'diagnostics)
         (show-panel 'gamepad-diagnostics))
        (T
         (show-panel 'diagnostics))))

(defmethod handle :after ((ev load-state) (world world))
  (load-state (state +main+) +world+))

(defmethod handle :after ((ev screenshot) (world world))
  (let* ((date (format-absolute-time (get-universal-time) :time-separator #+windows #\- #-windows #\:))
         (file (make-pathname :name (format NIL "kandria ~a" date)
                              :type "png"
                              :defaults (user-homedir-pathname))))
    (capture NIL :file file)
    (status :note (@formats 'screenshot-file-saved file))
    (v:info :kandria "Screenshot saved to ~a" file)))

(defmethod handle :after ((ev toggle-menu) (world world))
  (cond ((typep (first (panels (unit 'ui-pass T))) 'menu)
         (hide-panel 'menu))
        ((pausing-possible-p)
         (show-panel 'menu))
        ((null (or (find-panel 'menu)
                   (find-panel 'main-menu)
                   (find-panel 'quick-menu)))
         (status #@game-pausing-not-allowed))))

(defmethod handle :after ((ev tick) (world world))
  (let ((dt (dt ev)))
    (unless (handler-stack world)
      (unless (find-panel 'dialog)
        (incf (timestamp world) (* (clock-scale world) dt))
        (loop for quest in (quest:known-quests (storyline world))
              while (quest:active-p quest)
              do (incf (clock quest) dt)))
      (when (<= (decf (update-timer world) dt) 0)
        (setf (update-timer world) 0.2)
        (quest:try (storyline world))))))

(defmethod handle :after ((ev switch-chunk) (world world))
  (location-info (language-string (name (chunk ev)) NIL)))

(defmethod save-region (region (world world) &rest args)
  (let ((depot (region-entry region world)))
    (apply #'save-region region depot args)
    (depot:commit depot)))

(defmethod save-region (region (world (eql T)) &rest args)
  (apply #'save-region region +world+ args))

(defmethod save-region ((region (eql T)) (world world) &rest args)
  (apply #'save-region (unit 'region world) world args))

(defmethod load-region ((name symbol) (world world))
  (load-region (region-entry name world) world))

(defmethod load-region (region (world (eql T)))
  (load-region region +world+))

(defmethod load-region ((region (eql T)) (world world))
  (load-region (name (unit 'region world)) world))

(defmethod load-region :around ((depot depot:depot) (world world))
  (let ((old-region (unit 'region world)))
    (restart-case
        (call-next-method)
      (abort ()
        :report "Give up changing the region and continue with the old."
        (when (and old-region (not (eql old-region (unit 'region world))))
          (enter old-region world))))))

(defmethod quest:find-named (name (world world) &optional (error T))
  (quest:find-named name (storyline world) error))

(defmethod quest:find-quest (name (world world) &optional (error T))
  (quest:find-quest name (storyline world) error))

(defmethod quest:find-task (name (world world) &optional (error T))
  (quest:find-task name (storyline world) error))

(defmethod quest:find-trigger (name (world world) &optional (error T))
  (quest:find-trigger name (storyline world) error))
