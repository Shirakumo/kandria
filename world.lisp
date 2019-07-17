(in-package #:org.shirakumo.fraf.leaf)

(defclass world (pipelined-scene)
  ((name :accessor name)
   (author :initform "Anonymous" :initarg :author :accessor author)
   (version :initform "0.0.0" :initarg :version :accessor version)
   (storyline :initarg :storyline :accessor storyline)
   (maps :initarg :maps :accessor maps)
   (pause-stack :initform () :accessor pause-stack)))

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

(defmethod enter :after ((region region) (world world))
  (issue world 'switch-region :region region))

(defmethod handle :after ((ev trial:tick) (world world))
  (when (= 0 (mod (fc ev) 10))
    (quest:try (storyline world))))

(defmethod handle :after ((ev interaction) (world world))
  (when (typep (with ev) 'interactable)
    (setf (current-dialog (unit :textbox +world+))
          (quest:dialogue (first (interactions (with ev)))))))

(defmethod handle :after ((ev request-region) (world world))
  (let ((map (or (gethash (region ev) (maps world))
                 (error "Cannot switch to unknown world ~s" world))))
    ;; FIXME: think about this, it's broken.
    (load-region (pool-path 'leaf map) world)
    (change-scene (handler *context*) world)))

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

(defmethod save-world ((world world) target &rest args)
  (apply #'save-world (unit 'world world) target args))

(defmethod save-world :around (world target &rest args &key (version T))
  (apply #'call-next-method world target :version (ensure-version version) args))

(defmethod save-world (world (pathname pathname) &key version (if-exists :supersede))
  (with-packet (packet pathname :direction :output :if-exists if-exists)
    (save-world world packet :version version)))

(defmethod save-world (world (packet packet) &key version)
  (let ((meta (princ-to-string* (list :identifier 'world
                                      :version (type-of version))
                                (encode-payload world NIL packet version))))
    (setf (packet-entry "meta.lisp" packet) meta)))

(defmethod load-world ((world world))
  (load-world (pool-path 'leaf (string-downcase (name world)))))

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
