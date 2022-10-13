(in-package #:org.shirakumo.fraf.kandria)

(defvar *region* NIL)

(defclass world-v0 (v0) ())

(define-decoder (region world-v0) (info depot)
  (let* ((region (apply #'make-instance 'region :depot depot info))
         (content (parse-sexps (depot:read-from (depot:entry "data.lisp" depot) 'character)))
         (data (depot:ensure-depot (depot:entry "data" depot))))
    (let ((*region* region))
      (v:debug :kandria.region "Decoding world.")
      (loop for (type . initargs) in content
            for entity = (decode-payload initargs type data world-v0)
            do #-kandria-release
               (when (name entity)
                 (let ((existing (unit (name entity) region)))
                   (when existing
                     (restart-case (error "Duplicate entity on name ~a:~%~a~%~a" (name entity) entity existing)
                       (use-value (value)
                         :report "Specify a new name for the new entity."
                         (setf (name entity) value))
                       (rename-random ()
                         :report "Give the new entity a randomised name."
                         (setf (name entity) (generate-name)))
                       (clear-name ()
                         :report "Clear the name of both entities."
                         (setf (name entity) NIL)
                         (setf (name existing) NIL))))))
               (enter entity region))
      ;; Load initial state.
      (v:debug :kandria.region "World decoded, loading initial state...")
      (decode-payload (first (parse-sexps (depot:read-from (depot:entry "init.lisp" depot) 'character))) region depot 'save-v0))
    (bvh:bvh-reinsert-all (bvh region) 50)
    region))

(define-encoder (region world-v0) (_b depot)
  (depot:with-open (tx (depot:ensure-entry "data.lisp" depot) :output 'character)
    (let ((stream (depot:to-stream tx))
          (data (depot:ensure-depot (depot:ensure-entry "data" depot :directory T))))
      (for:for ((entity over region))
               (handler-case
                   (when (and (not (spawned-p entity))
                              (not (eql 'layer (type-of entity)))
                              (not (eql 'bg-layer (type-of entity))))
                     (princ* (encode-payload entity _b data world-v0) stream))
                 (no-applicable-encoder ())))))
  (unless (depot:entry-exists-p "init.lisp" depot)
    (depot:with-open (tx (depot:ensure-entry "init.lisp" depot) :output 'character)
      (princ* (encode-payload region NIL depot 'save-v0) (depot:to-stream tx))))
  (list :name (name region)
        :author (author region)
        :version (version region)
        :description (description region)))

(define-decoder (chunk world-v0) (initargs depot)
  (destructuring-bind (&key name location size tile-data pixel-data layers background bg-overlay gi environment (visible-on-map-p T)) initargs
    (let ((graph (if (and (depot:entry-exists-p (format NIL "~a.graph" name) depot)
                          (<= (depot:attribute :write-date (depot:entry (format NIL "~a.graph" name) depot))
                              (depot:attribute :write-date (depot:entry pixel-data depot))))
                     (depot:with-open (tx (depot:entry (format NIL "~a.graph" name) depot) :input '(unsigned-byte 8))
                       (handler-case (decode-payload (depot:to-stream tx) 'node-graph depot 'binary-v0)
                         (error (e)
                           (v:error :kandria.serializer "Failed to read node-graph for ~a" name)
                           (v:info :kandria.serializer e))))
                     (progn (v:info :kandria.serializer "Chunk graph for ~a is out of date. Ignoring." name)
                            NIL))))
      (make-instance 'chunk :name name
                            :location (decode 'vec2 location)
                            :size (decode 'vec2 size)
                            :tile-data (decode 'asset tile-data)
                            :pixel-data (depot:read-from (depot:entry pixel-data depot) 'byte)
                            :layers (loop for file in layers
                                          collect (depot:read-from (depot:entry file depot) 'byte))
                            :background (decode 'background-info background)
                            :bg-overlay (if bg-overlay (decode 'resource bg-overlay) (// 'kandria 'placeholder))
                            :gi (decode 'gi-info gi)
                            :environment (when environment (environment environment))
                            :node-graph graph
                            :visible-on-map-p visible-on-map-p))))

(define-encoder (chunk world-v0) (_b depot)
  (depot:with-open (tx (depot:ensure-entry (format NIL "~a.graph" (name chunk)) depot) :output '(unsigned-byte 8))
    (encode-payload (node-graph chunk) (depot:to-stream tx) depot 'binary-v0))
  (let ((layers (loop for i from 0
                      for layer across (layers chunk)
                      ;; KLUDGE: no png saving lib handy. Hope ZIP compression is Good Enough
                      for path = (format NIL "~a-~d.raw" (name chunk) i)
                      do (depot:write-to (depot:ensure-entry path depot) (pixel-data layer))
                      collect path))
        (pixel-data (format NIL "~a.raw" (name chunk))))
    (depot:write-to (depot:ensure-entry pixel-data depot) (pixel-data chunk))
    `(chunk :name ,(name chunk)
            :location ,(encode (location chunk))
            :size ,(encode (size chunk))
            :tile-data ,(encode (tile-data chunk))
            :pixel-data ,pixel-data
            :layers ,layers
            :background ,(encode (background chunk))
            :bg-overlay ,(encode (bg-overlay chunk))
            :gi ,(encode (gi chunk))
            :environment ,(when (environment chunk) (name (environment chunk)))
            :visible-on-map-p ,(visible-on-map-p chunk))))

(define-decoder (layer world-v0) (initargs depot)
  (destructuring-bind (&key name location size bsize (tile-data '(kandria debug)) pixel-data &allow-other-keys) initargs
    (let ((size (if size
                    (decode 'vec2 size)
                    (v/ (decode 'vec2 bsize) 8))))
      (make-instance (class-of layer)
                     :name (or name (generate-name (type-of layer)))
                     :location (decode 'vec2 location)
                     :size size
                     :tile-data (decode 'asset tile-data)
                     :pixel-data (if pixel-data
                                     (depot:read-from (depot:entry pixel-data depot) 'byte)
                                     (let ((temp (make-array (floor (* (vx size) (vy size) 2))
                                                             :element-type '(unsigned-byte 8))))
                                       (loop for i from 0 below (length temp) by 2
                                             do (setf (aref temp i) 1))
                                       temp))))))

(define-encoder (layer world-v0) (_b depot)
  (let ((pixel-data (format NIL "~a.raw" (name layer))))
    (depot:write-to (depot:ensure-entry pixel-data depot) (pixel-data layer))
    `(,(type-of layer) :name ,(name layer)
                       :location ,(encode (location layer))
                       :size ,(encode (size layer))
                       :tile-data ,(encode (tile-data layer))
                       :pixel-data ,pixel-data)))

(define-additional-slot-coders (blocker world-v0) (weak-side))

(define-decoder (gi-info world-v0) (name _p)
  (gi name))

(define-encoder (gi-info world-v0) (_b _p)
  (or (name gi-info)
      (error "Can't encode GI-INFO without a name.")))

(define-decoder (background-info world-v0) (name _p)
  (background name))

(define-encoder (background-info world-v0) (_b _p)
  (or (name background-info)
      (error "Can't encode BACKGROUND-INFO without a name.")))

(define-decoder (door world-v0) (initargs _p)
  (destructuring-bind (&key name location target target-facing facing &allow-other-keys) initargs
    (make-instance (class-of door) :location (decode 'vec2 location)
                                   :facing-towards-screen-p facing
                                   :target (list :location (decode 'vec2 target) :facing-towards-screen-p target-facing)
                                   :name name)))

(define-encoder (door world-v0) (_b _p)
  (if (primary door)
      `(,(type-of door) :location ,(encode (location door))
                        :facing ,(facing-towards-screen-p door)
                        :target ,(encode (location (target door)))
                        :target-facing ,(facing-towards-screen-p (target door))
                        :name ,(name door))
      (error 'no-applicable-encoder :source door)))

(define-additional-slot-coders (locked-door world-v0) (key unlocked-p))

(define-decoder (teleport-trigger world-v0) (initargs _p)
  (destructuring-bind (&key bsize location target target-bsize) initargs
    (make-instance (class-of teleport-trigger) :location (decode 'vec2 location)
                                               :bsize (decode 'vec2 bsize)
                                               :target (list (decode 'vec2 target)
                                                             (decode 'vec2 target-bsize)))))

(define-encoder (teleport-trigger world-v0) (_b _p)
  (if (primary teleport-trigger)
      `(,(type-of teleport-trigger) :location ,(encode (location teleport-trigger))
                                    :bsize ,(encode (bsize teleport-trigger))
                                    :target ,(encode (location (target teleport-trigger)))
                                    :target-bsize ,(encode (bsize (target teleport-trigger))))
      (error 'no-applicable-encoder :source teleport-trigger)))

(define-slot-coders (spawner world-v0) (name (location :type vec2) (bsize :type vec2) spawn-type spawn-count spawn-args active-p jitter-y-p auto-deactivate))
(define-slot-coders (background world-v0) ())
(define-slot-coders (game-entity world-v0) ((location :type vec2) name))
(define-slot-coders (sprite-entity world-v0) ((location :type vec2) (texture :type texture) (size :type vec2) (bsize :type vec2) (offset :type vec2) (layer-index :initarg :layer) name))
(define-slot-coders (animated-sprite world-v0) (name (location :type vec2) (trial:sprite-data :type asset) (bsize :type vec2) layer-index))
(define-slot-coders (station world-v0) (name (location :type vec2) (train-location :type vec2 :reader (lambda (x) (location (train x))))))
(defmethod encode-payload ((train train) payload depot (version world-v0))
  (error 'no-applicable-encoder :source train))
(define-slot-coders (rope world-v0) (name (location :type vec2) (bsize :type vec2) direction extended))
(define-slot-coders (water world-v0) ((location :type vec2) (bsize :type vec2) fishing-spot))
(define-slot-coders (place-marker world-v0) (name (location :type vec2) (bsize :type vec2)))
(define-slot-coders (audio-marker world-v0) (name (location :type vec2) (bsize :type vec2) (voice :type resource)))
(define-slot-coders (grass-patch world-v0) ((location :type vec2) (bsize :type vec2) patches (tile-size :type vec2) (tile-start :type vec2) tile-count))
(define-slot-coders (trigger world-v0) (name active-p (location :type vec2) (bsize :type vec2)))
(define-slot-coders (spring world-v0) ((location :type vec2) (strength :type vec2)))
(define-slot-coders (fountain world-v0) ((location :type vec2) (strength :type vec2)))
(define-slot-coders (lantern world-v0) ((location :type vec2)))
(define-slot-coders (crumbling-platform world-v0) ((location :type vec2)))
(define-additional-slot-coders (interactable-animated-sprite world-v0) ((pending-animation :initarg :animation)))
(define-additional-slot-coders (story-trigger world-v0) (story-item target-status))
(define-additional-slot-coders (tween-trigger world-v0) (left right ease-fun horizontal))
(define-additional-slot-coders (sandstorm-trigger world-v0) (velocity))
(define-additional-slot-coders (interaction-trigger world-v0) (interaction))
(define-additional-slot-coders (walkntalk-trigger world-v0) (interaction target))
(define-additional-slot-coders (earthquake-trigger world-v0) (duration))
(define-additional-slot-coders (music-trigger world-v0) ((track :type asset)))
(define-additional-slot-coders (audio-trigger world-v0) ((sound :type asset)))
(define-additional-slot-coders (action-prompt world-v0) (action interrupt))
(define-additional-slot-coders (fullscreen-prompt-trigger world-v0) (action title))
(define-additional-slot-coders (wind world-v0) ((max-strength :type vec2 :initarg :strength) period kind))
(define-additional-slot-coders (elevator-recall world-v0) (target))
(define-additional-slot-coders (falling-platform world-v0) ((initial-location :type vec2) (max-speed :type vec2) (fall-direction :type vec2)))
(define-additional-slot-coders (gate world-v0) ((open-location :type vec2) (closed-location :type vec2) state))
(define-additional-slot-coders (paletted-npc world-v0) ((palette-index :default 0)))
(define-slot-coders (basic-light world-v0) ((color :type vec4)
                                            (location :type vec2)
                                            (data :reader (lambda (light) (buffer-data (caar (bindings (vertex-array light))))))))
(define-slot-coders (textured-light world-v0) (multiplier (texture :type texture) (location :type vec2) (size :type vec2) (bsize :type vec2) (offset :type vec2)))
(define-slot-coders (heatwave world-v0) ((location :type vec2) (bsize :type vec2)))
(define-slot-coders (save-point world-v0) ((location :type vec2)))
(define-slot-coders (npc-block-zone world-v0) ((location :type vec2) (bsize :type vec2)))
(define-slot-coders (map-block-zone world-v0) ((location :type vec2) (bsize :type vec2)))
(define-slot-coders (chest world-v0) (name (location :type vec2) item))
(define-slot-coders (shutter world-v0) ((location :type vec2)))
(define-slot-coders (switch world-v0) ((location :type vec2) state))

(define-decoder (node-graph binary-v0) (stream depot)
  (let* ((width (nibbles:read-ub16/le stream))
         (height (nibbles:read-ub16/le stream))
         (grid (make-array (* width height) :initial-element NIL)))
    (dotimes (i (length grid) (%make-node-graph width height grid))
      (dotimes (j (nibbles:read-ub16/le stream))
        (let ((type (read-byte stream))
              (to (nibbles:read-ub32/le stream)))
          (ecase type
            (0)
            (1 (push (make-walk-node to) (svref grid i)))
            (2 (push (make-crawl-node to) (svref grid i)))
            (3 (push (make-climb-node to) (svref grid i)))
            (4 (push (make-fall-node to) (svref grid i)))
            (5 (push (make-jump-node to (decode 'vec2)) (svref grid i)))
            (6 (let* ((name (decode-payload stream 'symbol depot 'binary-v0))
                      (unit (or (unit name *region*) (error "No such unit ~a" name))))
                 (push (make-rope-node to unit) (svref grid i))))
            (7 (push (make-inter-door-node to) (svref grid i)))))))))

(define-encoder (node-graph binary-v0) (stream depot)
  (nibbles:write-ub16/le (node-graph-width node-graph) stream)
  (nibbles:write-ub16/le (node-graph-height node-graph) stream)
  (let ((grid (node-graph-grid node-graph)))
    (loop for nodes across grid
          do (nibbles:write-ub16/le (length nodes) stream)
             (dolist (node nodes)
               (etypecase node
                 (inter-door-node
                  (write-byte 7 stream)
                  (nibbles:write-ub32/le (move-node-to node) stream))
                 (rope-node
                  (write-byte 6 stream)
                  (nibbles:write-ub32/le (move-node-to node) stream)
                  (let ((target (rope-node-rope node)))
                    (encode-payload (etypecase target
                                      (symbol target)
                                      (rope (name target)))
                                    stream depot 'binary-v0)))
                 (jump-node
                  (write-byte 5 stream)
                  (nibbles:write-ub32/le (move-node-to node) stream)
                  (encode (jump-node-strength node)))
                 (fall-node
                  (write-byte 4 stream)
                  (nibbles:write-ub32/le (move-node-to node) stream))
                 (climb-node
                  (write-byte 3 stream)
                  (nibbles:write-ub32/le (move-node-to node) stream))
                 (crawl-node
                  (write-byte 2 stream)
                  (nibbles:write-ub32/le (move-node-to node) stream))
                 (walk-node
                  (write-byte 1 stream)
                  (nibbles:write-ub32/le (move-node-to node) stream)))))))

(define-encoder (parent-entity world-v0) (_b _p)
  (nconc (call-next-method)
         (list :children (loop for child in (children parent-entity)
                               collect (encode child)))))

(define-decoder (parent-entity world-v0) (initargs _)
  (let ((parent-entity (call-next-method)))
    (setf (children parent-entity)
          (loop for (type . data) in (getf initargs :children)
                collect (decode type data)))
    parent-entity))
