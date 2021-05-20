(in-package #:org.shirakumo.fraf.kandria)

(defclass world (pipelined-scene)
  ((packet :initarg :packet :accessor packet)
   (storyline :initarg :storyline :initform NIL :accessor storyline)
   (regions :initarg :regions :initform (make-hash-table :test 'eq) :accessor regions)
   (handler-stack :initform () :accessor handler-stack)
   (initial-state :initform NIL :accessor initial-state)
   (time-scale :initform 1.0 :accessor time-scale)
   (pause-timer :initform 0.0 :accessor pause-timer)
   (clock-scale :initform 60.0 :accessor clock-scale)
   (timestamp :initform (initial-timestamp) :accessor timestamp))
  (:default-initargs
   :packet (error "PACKET required.")))

(defmethod initialize-instance :after ((world world) &key packet)
  (enter (progression-instance 'death) world)
  (enter (progression-instance 'hurt) world)
  (enter (progression-instance 'transition) world)
  (enter (progression-instance 'low-health) world)
  (dolist (entry (list-entries "regions/" packet))
    (with-packet (packet packet :offset entry)
      (let ((name (getf (second (parse-sexps (packet-entry "meta.lisp" packet :element-type 'character)))
                        :name)))
        (setf (gethash name (regions world)) entry))))
  (setf (initial-state world) (minimal-load-state (entry-path "init/" packet))))

(defmethod start :after ((world world))
  (harmony:play (// 'kandria 'music)))

(defmethod hour ((world world))
  (mod (float (/ (nth-value 1 (truncate (+ (timestamp world) 432000) (* 60 60 24 7))) 60 60) 0d0) 24d0))

(defmethod (setf timestamp) :after (timestamp (world world))
  (issue world 'change-time :timestamp timestamp))

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
    #++(setf (mixed:bypass (harmony:segment 'low-pass T)) NIL)
    (setf (mixed:volume :music) (/ (mixed:volume :music) 4))
    (hide (prompt (unit 'player world))))
  (push pauser (handler-stack world)))

(defmethod unpause-game ((world world) pauser)
  (loop for handler = (pop (handler-stack world))
        until (or (null handler) (eq handler pauser)))
  (unless (handler-stack world)
    #++(setf (mixed:bypass (harmony:segment 'low-pass T)) T)
    (setf (mixed:volume :music) (setting :audio :volume :music))))

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
          (format NIL "regions/~a/" (string-downcase (name region)))))
  ;; Let everyone know we switched the region.
  (issue world 'switch-region :region region))

(defun saving-possible-p (world)
  (and (null (find-panel 'dialog))
       (unit 'player world)
       (svref (collisions (unit 'player world)) 2)))

(defun pausing-possible-p (world)
  (and (null (find-panel 'menuing-panel))
       (unit 'player world)
       (svref (collisions (unit 'player world)) 2)))

;; Preloading
(defmethod stage :after ((world world) (area staging-area))
  (stage (// 'kandria 'music) area)
  (stage (// 'kandria 'effects 'texture) area)
  (stage (// 'kandria 'effects 'vertex-array) area)
  (stage (// 'kandria 'items) area)
  (stage (// 'kandria 'particles) area))

(defmethod compile-to-pass :after ((world world) (pass render-pass))
  (register-object-for-pass pass (c2mop:ensure-finalized (find-class 'sprite-effect))))

(defmethod region ((world world))
  (gethash 'region (name-map world)))

(defmethod handle ((event event) (world world))
  (let ((handler (car (handler-stack world))))
    (cond (handler
           (handle event (unit :controller world))
           (handle event (unit :camera world))
           (handle event handler))
          (T
           (call-next-method)))))

(defmethod handle ((ev report-bug) (world world))
  (toggle-panel 'report-panel))

(defmethod handle ((ev toggle-editor) (world world))
  (unless (find-panel 'menu)
    (toggle-panel 'editor)))

(defmethod handle ((ev toggle-diagnostics) (world world))
  (toggle-panel 'diagnostics))

(defmethod handle ((ev screenshot) (world world))
  (let* ((date (format-absolute-time (get-universal-time) :time-separator #+windows #\- #-windows #\:))
         (file (make-pathname :name (format NIL "kandria ~a" date)
                              :type "png"
                              :defaults (user-homedir-pathname))))
    (capture NIL :file file)
    (status :note "Screenshot saved to ~a" file)
    (v:info :kandria "Screenshot saved to ~a" file)))

(defmethod handle ((ev quickmenu) (world world))
  (show-panel 'quick-menu))

(defmethod handle ((ev toggle-menu) (world world))
  (if (pausing-possible-p world)
      (show-panel 'menu)
      (status "Can't pause right now.")))

(defmethod handle :after ((ev trial:tick) (world world))
  (unless (handler-stack world)
    (incf (timestamp world) (* (clock-scale world) (dt ev)))
    (loop for quest in (quest:known-quests (storyline world))
          while (quest:active-p quest)
          do (incf (clock quest) (dt ev)))
    (when (= 0 (mod (fc ev) 10))
      (quest:try (storyline world)))))

(defmethod handle :after ((ev keyboard-event) (world world))
  (setf +input-source+ :keyboard))

(defmethod handle :after ((ev gamepad-press) (world world))
  (setf +input-source+ (device ev)))

(defmethod handle :after ((ev gamepad-move) (world world))
  (when (< 0.1 (pos ev))
    (setf +input-source+ (device ev))))

(defmethod save-region (region (world world) &rest args)
  (with-packet (packet (packet world) :offset (region-entry region world)
                                      :direction :output)
    (apply #'save-region region packet args)))

(defmethod save-region (region (world (eql T)) &rest args)
  (apply #'save-region region +world+ args))

(defmethod save-region ((region (eql T)) (world world) &rest args)
  (apply #'save-region (unit 'region world) world args))

(defmethod load-region ((name symbol) (world world))
  (with-packet (packet (packet world) :offset (region-entry name world))
    (load-region packet world)))

(defmethod load-region (region (world (eql T)))
  (load-region region +world+))

(defmethod load-region ((region (eql T)) (world world))
  (load-region (name (unit 'region world)) world))

(defmethod load-region :around ((packet packet) (world world))
  (let ((old-region (unit 'region world))
        (*scene* world))
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
