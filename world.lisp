(in-package #:org.shirakumo.fraf.kandria)

(defclass world (pipelined-scene)
  ((packet :initarg :packet :accessor packet)
   (storyline :initarg :storyline :initform (make-instance 'quest:storyline) :accessor storyline)
   (regions :initarg :regions :initform (make-hash-table :test 'eq) :accessor regions)
   (handler-stack :initform () :accessor handler-stack)
   (initial-state :initform NIL :accessor initial-state)
   (time-scale :initform 1.0 :accessor time-scale))
  (:default-initargs
   :packet (error "PACKET required.")))

(defmethod initialize-instance :after ((world world) &key packet)
  (enter (progression-instance 'death) world)
  (enter (progression-instance 'hurt) world)
  (enter (progression-instance 'transition) world)
  (dolist (entry (list-entries "regions/" packet))
    (with-packet (packet packet :offset entry)
      (let ((name (getf (second (parse-sexps (packet-entry "meta.lisp" packet :element-type 'character)))
                        :name)))
        (setf (gethash name (regions world)) entry))))
  (dolist (entry (list-entries "quests/" packet))
    (with-packet (packet packet :offset entry)
      (load-quest packet (storyline world))))
  (setf (initial-state world) (minimal-load-state (entry-path "init/" packet))))

(defmethod start :after ((world world))
  (harmony:play (// 'kandria 'music)))

(defmethod hour ((world world))
  (+ (/ (clock world) 20) 7))

;; TODO: use spatial acceleration data structure instead.
(defmethod scan ((world world) target on-hit)
  (scan (region world) target on-hit))

(defmethod pause-game ((_ (eql T)) pauser)
  (pause-game +world+ pauser))

(defmethod unpause-game ((_ (eql T)) pauser)
  (unpause-game +world+ pauser))

(defmethod pause-game ((world world) pauser)
  (unless (handler-stack world)
    (setf (mixed:bypass (harmony:segment 'low-pass T)) NIL)
    (setf (mixed:volume :master) (/ (mixed:volume :master) 4)))
  (push pauser (handler-stack world)))

(defmethod unpause-game ((world world) pauser)
  (loop for handler = (pop (handler-stack world))
        until (eq handler pauser))
  (unless (handler-stack world)
    (setf (mixed:bypass (harmony:segment 'low-pass T)) T)
    (setf (mixed:volume :master) (setting :audio :volume :master))))

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

;; Preloading
(defmethod stage :after ((world world) (area staging-area))
  (stage (// 'kandria 'music) area)
  (stage (// 'kandria 'effects 'texture) area)
  (stage (// 'kandria 'effects 'vertex-array) area))

(defmethod compile-to-pass :after ((world world) (pass render-pass))
  (register-object-for-pass pass (c2mop:ensure-finalized (find-class 'sprite-effect))))

(defmethod region ((world world))
  (gethash 'region (name-map world)))

(defmethod handle ((event event) (world world))
  (let ((handler (car (handler-stack world))))
    (cond (handler
           (handle event (controller (handler *context*)))
           (handle event (unit :camera world))
           (handle event handler))
          (T
           (call-next-method)))))

(defmethod handle :after ((ev quicksave) (world world))
  (save-state world :quick))

(defmethod handle :after ((ev quickload) (world world))
  (load-state :quick world))

(defmethod handle ((ev report-bug) (world world))
  (toggle-panel 'report-panel))

(defmethod handle ((ev toggle-editor) (world world))
  (toggle-panel 'editor))

(defmethod handle ((ev toggle-diagnostics) (world world))
  (toggle-panel 'diagnostics))

(defmethod handle :after ((ev trial:tick) (world world))
  (when (= 0 (mod (fc ev) 10))
    (issue world 'change-time :hour (hour world))
    (quest:try (storyline world))))

(defmethod handle :after ((ev keyboard-event) (world world))
  (setf +input-source+ :keyboard))

(defmethod handle :after ((ev gamepad-event) (world world))
  (setf +input-source+ :gamepad))

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
  (let ((old-region (unit 'region world)))
    (restart-case
        (prog1 (call-next-method)
          (when old-region
            (leave old-region world))
          ;; KLUDGE: Re-activate quests to populate interactions
          (loop for quest being the hash-values of (quest:quests (storyline world))
                do (when (quest:active-p quest)
                     (quest:activate quest))))
      (abort ()
        :report "Give up changing the region and continue with the old."
        (when old-region
          (enter old-region world))))))
