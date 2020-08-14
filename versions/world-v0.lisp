(in-package #:org.shirakumo.fraf.leaf)

(defclass world-v0 (v0) ())

(define-decoder (quest:storyline world-v0) (info _p)
  (let ((table (make-hash-table :test 'eq)))
    ;; Read in things
    (loop for (type . initargs) in info
          for entry = (decode type initargs)
          do (setf (gethash (name entry) table) entry))
    ;; Connect them up
    (loop for (type . initargs) in info
          for entry = (gethash (getf initargs :name) table)
          do (etypecase entry
               (quest-graph:quest
                (dolist (effect (getf initargs :effects))
                  (quest-graph:connect entry (gethash effect table))))
               (quest-graph:task
                (dolist (effect (getf initargs :effects))
                  (quest-graph:connect entry (gethash effect table)))
                (dolist (trigger (getf initargs :triggers))
                  (quest-graph:connect entry (gethash trigger table))))
               (quest-graph:trigger)))
    ;; Compile storyline
    ;; TODO: We can do this ahead of time into an optimised format by taking out
    ;;       conditions and invariants into a separate file, giving each a unique
    ;;       name. We can then COMPILE-FILE this and refer directly to the functions
    ;;       in the optimised format.
    (quest:make-storyline
     (loop for entry being the hash-values of table
           when (typep entry 'quest-graph:quest)
           collect entry)
     :quest-type 'quest)))

(define-decoder (quest-graph:quest world-v0) (info _p)
  (destructuring-bind (&key name title description &allow-other-keys) info
    (make-instance 'quest-graph:quest :name name :title title :description description)))

(define-decoder (quest-graph:task world-v0) (info _p)
  (destructuring-bind (&key name title description invariant condition &allow-other-keys) info
    (make-instance 'quest-graph:task :name name :title title :description description
                                     :invariant invariant :condition condition)))

(define-decoder (quest-graph:interaction world-v0) (info packet)
  (destructuring-bind (&key name interactable dialogue) info
    (let ((dialogue (packet-entry dialogue packet :element-type 'character)))
      (make-instance 'quest-graph:interaction :name name :interactable interactable :dialogue dialogue))))

(define-decoder (region world-v0) (info packet)
  (let* ((region (apply #'make-instance 'region info))
         (content (parse-sexps (packet-entry "data.lisp" packet :element-type 'character))))
    (loop for (type . initargs) in content
          do (enter (decode type initargs) region))
    region))

(define-encoder (region world-v0) (_b packet)
  (with-packet-entry (stream "data.lisp" packet :element-type 'character)
    (for:for ((entity over region))
      (handler-case
          (princ* (encode entity) stream)
        (no-applicable-encoder ()))))
  (list :name (name region)
        :author (author region)
        :version (version region)
        :description (description region)))

(define-decoder (door world-v0) (initargs _p)
  (destructuring-bind (&key name location target) initargs
    (make-instance (class-of door) :location (decode 'vec2 location)
                                   :target (decode 'vec2 target)
                                   :name name)))

(define-encoder (door world-v0) (_b _p)
  (if (primary door)
      `(,(type-of door) :location ,(encode (location door))
                        :target ,(encode (location (target door)))
                        :name ,(name door))
      (error 'no-applicable-encoder :source door)))

(define-decoder (game-entity world-v0) (initargs _p)
  (destructuring-bind (&key name location) initargs
    (make-instance (class-of game-entity) :location (decode 'vec2 location) :name name)))

(define-encoder (game-entity world-v0) (_b _p)
  `(,(type-of game-entity) :location ,(encode (location game-entity))
                       :name ,(name game-entity)))

(define-decoder (chunk world-v0) (initargs packet)
  (destructuring-bind (&key name location size tile-data pixel-data layers lighting) initargs
    (make-instance 'chunk :name name
                          :location (decode 'vec2 location)
                          :size (decode 'vec2 size)
                          :tile-data (decode 'asset tile-data)
                          :pixel-data (packet-entry pixel-data packet)
                          :layers (loop for file in layers
                                        collect (packet-entry file packet))
                          :lighting lighting)))

(define-encoder (chunk world-v0) (_b packet)
  (let ((layers (loop for i from 0
                      for layer across (layers chunk)
                      ;; KLUDGE: no png saving lib handy. Hope ZIP compression is Good Enough
                      for path = (format NIL "data/~a-~d.raw" (name chunk) i)
                      do (setf (packet-entry path packet) (pixel-data layer))
                      collect path))
        (pixel-data (format NIL "data/~a.raw" (name chunk))))
    (setf (packet-entry pixel-data packet) (pixel-data chunk))
    `(chunk :name ,(name chunk)
            :location ,(encode (location chunk))
            :size ,(encode (size chunk))
            :tile-data ,(encode (tile-data chunk))
            :pixel-data ,pixel-data
            :lighting ,(lighting chunk)
            :layers ,layers)))

(define-decoder (background world-v0) (initargs _)
  (destructuring-bind (&key texture) initargs
    (make-instance 'background :texture (decode 'resource texture))))

(define-encoder (background world-v0) (_b _p)
  `(background :texture (leaf tundra-bg)
               ;; FIXME: this sucks
               ;;,(encode (texture background))
               ))

(define-decoder (falling-platform world-v0) (initargs _)
  (destructuring-bind (&key texture gravity location bsize frame) initargs
    (make-instance 'falling-platform
                   :texture (decode 'resource texture)
                   :gravity (decode 'vec2 gravity)
                   :location (decode 'vec2 location)
                   :frame-idx (decode 'vec2 frame)
                   :bsize (decode 'vec2 bsize))))

(define-encoder (falling-platform world-v0) (_b _p)
  `(falling-platform :texture ,(encode (texture falling-platform))
                     :gravity ,(encode (gravity falling-platform))
                     :location ,(encode (location falling-platform))
                     :frame ,(encode (frame-idx falling-platform))
                     :bsize ,(encode (bsize falling-platform))))

(define-decoder (rope world-v0) (initargs _)
  (destructuring-bind (&key location bsize) initargs
    (make-instance 'rope
                   :location (decode 'vec2 location)
                   :bsize (decode 'vec2 bsize))))

(define-encoder (rope world-v0) (_b _p)
  `(rope :location ,(encode (location rope))
         :bsize ,(encode (bsize rope))))

(define-decoder (basic-light world-v0) (initargs _)
  (destructuring-bind (&key color data) initargs
    (make-instance 'basic-light
                   :color (decode 'vec4 color)
                   :data data)))

(define-encoder (basic-light world-v0) (_b _p)
  `(basic-light :color ,(encode (color basic-light))
                :data ,(buffer-data (caar (bindings (vertex-array basic-light))))))

(define-decoder (textured-light world-v0) (initargs _)
  (destructuring-bind (&key multiplier texture location size bsize frame) initargs
    (make-instance 'textured-light
                   :multiplier multiplier
                   :texture (decode 'resource texture)
                   :location (decode 'vec2 location)
                   :size (decode 'vec2 size)
                   :bsize (decode 'vec2 bsize)
                   :frame (decode 'vec2 frame))))

(define-encoder (textured-light world-v0) (_b _p)
  `(textured-light :multiplier ,(multiplier textured-light)
                   :texture ,(encode (texture textured-light))
                   :location ,(encode (location textured-light))
                   :size ,(encode (size textured-light))
                   :bsize ,(encode (bsize textured-light))
                   :frame ,(encode (frame-idx textured-light))))
