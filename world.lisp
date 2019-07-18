(in-package #:org.shirakumo.fraf.leaf)

(defclass world (pipelined-scene)
  ((packet :initarg :packet :accessor packet)
   (author :initform "Anonymous" :initarg :author :accessor author)
   (version :initform "0.0.0" :initarg :version :accessor version)
   (storyline :initarg :storyline :accessor storyline)
   (regions :initarg :regions :accessor regions)
   (pause-stack :initform () :accessor pause-stack))
  (:default-initargs
   :packet (error "PACKET required.")
   :storyline (quest:make-storyline ())
   :regions (make-hash-table :test 'eq)))

(defmethod pause-game ((_ (eql T)) pauser)
  (pause-game +world+ pauser))

(defmethod unpause-game ((_ (eql T)) pauser)
  (unpause-game +world+ pauser))

(defmethod pause-game ((world world) pauser)
  (push (handlers world) (pause-stack world))
  (setf (handlers world) ())
  (for:for ((entity flare-queue:in-queue (objects world)))
    (when (or (typep entity 'unpausable)
              (typep entity 'controller)
              (eq entity pauser))
      (add-handler (handlers entity) world)))
  (for:for ((pass across (passes world)))
    (add-handler (handlers pass) world)))

(defmethod unpause-game ((world world) pauser)
  (when (pause-stack world)
    (setf (handlers world) (pop (pause-stack world)))))

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

(defmethod handle :after ((ev trial:tick) (world world))
  (when (= 0 (mod (fc ev) 10))
    (quest:try (storyline world))))

(defmethod handle :after ((ev interaction) (world world))
  (when (typep (with ev) 'interactable)
    (setf (current-dialog (unit :textbox +world+))
          (quest:dialogue (first (interactions (with ev)))))))

(defmethod handle :after ((ev request-region) (world world))
  (load-region (region ev) world))

(defclass quest (quest:quest)
  ())

(defmethod quest:make-assembly ((_ quest))
  (make-instance 'assembly))

(defclass assembly (dialogue:assembly)
  ())

(defmethod dialogue:wrap-lexenv ((_ assembly) form)
  `(with-memo ((world +world+)
               (player (unit 'player +world+))
               (region (unit 'region +world+))
               (chunk (surface (unit 'player +world+))))
     ,form))

(defgeneric load-world (packet))
(defgeneric save-world (world packet &key version &allow-other-keys))

(defmethod save-world ((world (eql T)) target &rest args)
  (apply #'save-world +world+ target args))

(defmethod save-world :around (world target &rest args &key (version T))
  (apply #'call-next-method world target :version (ensure-version version) args))

(defmethod save-world (world (pathname pathname) &key version (if-exists :supersede))
  (with-packet (packet pathname :direction :output :if-exists if-exists)
    (save-world world packet :version version)))

(defmethod save-world (world (packet packet) &key version)
  (with-packet-entry (stream "meta.lisp" packet :element-type 'character)
    (princ* (list :identifier 'world :version (type-of version)) stream)
    (princ* (encode-payload world NIL packet version) stream)))

(defmethod load-world ((world world))
  (load-world (packet world)))

(defmethod load-world ((pathname pathname))
  (with-packet (packet pathname :direction :input)
    (load-world packet)))

(defmethod load-world ((packet packet))
  (destructuring-bind (header info) (parse-sexps (packet-entry "meta.lisp" packet :element-type 'character))
    (decode-payload
     info (type-prototype 'world) packet
     (destructuring-bind (&key identifier version) header
       (assert (eql 'world identifier))
       (coerce-version version)))))

(defmethod save-region (region (world world) &rest args)
  (with-packet (packet (packet world) :offset (region-entry region world))
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
  (load-region (unit 'region world) world))

(defmethod load-region :around ((packet packet) (world world))
  (let ((old-region (unit 'region world)))
    (restart-case
        (progn
          (load-region packet world)
          (when old-region
            (leave old-region world)))
      (abort ()
        :report "Give up changing the region and continue with the old."
        (when old-region
          (enter old-region world))))
    ;; Force resource update
    (change-scene world world)))
