(in-package #:org.shirakumo.fraf.leaf)

(defclass v0 (version) ())

(defvar *load-world*)

(define-decoder (world v0) (info packet)
  (let* ((world (apply #'make-instance 'world :packet packet info))
         (*load-world* world))
    ;; Load world extensions
    (destructuring-bind (&key sources initial-state)
        (first (parse-sexps (packet-entry "system.lisp" packet :element-type 'character)))
      ;; Fixup world pool
      (reinitialize-instance (find-pool 'world) :base (entry-path "data/" packet))
      ;; Register regions
      (dolist (entry (list-entries "regions/" packet))
        (with-packet (packet packet :offset entry)
          (let ((name (getf (second (parse-sexps (packet-entry "meta.lisp" packet :element-type 'character)))
                            :name)))
            (setf (gethash name (regions world)) entry))))
      ;; Load sources
      (dolist (source sources)
        (with-packet-entry (stream source packet :element-type 'character)
          ;; FIXME: Compile sources somehow (write out to disk first?)
          (cl:load stream :verbose NIL :print NIL)))
      ;; Load storyline
      (let ((storyline (parse-sexps (packet-entry "storyline.lisp" packet :element-type 'character))))
        (setf (storyline world) (decode 'quest:storyline storyline)))
      ;; Set initial state without loading it
      (setf (initial-state world)
            (minimal-load-state (entry-path initial-state packet))))
    world))

(define-encoder (world v0) (_b packet)
  ;; KLUDGE: Can't save any more than this as we lost the info during compilation.
  ;;         External tools are necessary to edit the source.
  (list :author (author world)
        :version (version world)))

(define-decoder (quest:storyline v0) (info _p)
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

(define-decoder (quest-graph:quest v0) (info _p)
  (destructuring-bind (&key name title description &allow-other-keys) info
    (make-instance 'quest-graph:quest :name name :title title :description description)))

(define-decoder (quest-graph:task v0) (info _p)
  (destructuring-bind (&key name title description invariant condition &allow-other-keys) info
    (make-instance 'quest-graph:task :name name :title title :description description
                                     :invariant invariant :condition condition)))

(define-decoder (quest-graph:interaction v0) (info packet)
  (destructuring-bind (&key name interactable dialogue) info
    (let ((dialogue (packet-entry dialogue packet :element-type 'character)))
      (make-instance 'quest-graph:interaction :name name :interactable interactable :dialogue dialogue))))

(define-decoder (region v0) (info packet)
  (let* ((region (apply #'make-instance 'region info))
         (content (parse-sexps (packet-entry "data.lisp" packet :element-type 'character))))
    (loop for (type . initargs) in content
          do (enter (decode type initargs) region))
    region))

(define-encoder (region v0) (_b packet)
  (with-packet-entry (stream "data.lisp" packet :element-type 'character)
    (for:for ((entity over region))
      (princ* (encode entity) stream)))
  (list :name (name region)
        :author (author region)
        :version (version region)
        :description (description region)))

(define-decoder (player v0) (initargs _p)
  (destructuring-bind (&key location) initargs
    (make-instance 'player :location (decode 'vec2 location))))

(define-encoder (player v0) (_b _p)
  `(player :location ,(encode (location player))))

(define-decoder (chunk v0) (initargs packet)
  (destructuring-bind (&key name location size tileset layers children) initargs
    (let ((chunk (make-instance 'chunk :name name
                                       :location (decode 'vec2 location)
                                       :size (decode 'vec2 size)
                                       :tileset (decode 'asset tileset)
                                       :layers (loop for file in layers
                                                     collect (packet-entry file packet)))))
      (loop for (type . initargs) in children
            do (enter (decode type initargs) chunk))
      chunk)))

(define-encoder (chunk v0) (_b packet)
  (let ((layers (loop for i from 0
                      for layer across (layers chunk)
                      ;; KLUDGE: no png saving lib handy. Hope ZIP compression is Good Enough
                      for path = (format NIL "data/~a-~d.raw" (name chunk) i)
                      do (setf (packet-entry path packet) layer)
                      collect path))
        (children (for:for ((entity over chunk)
                            (_ collect (encode entity))))))
    `(chunk :name ,(name chunk)
            :location ,(encode (location chunk))
            :size ,(encode (size chunk))
            :tileset ,(encode (tileset chunk))
            :layers ,layers
            :children ,children)))

(define-decoder (background v0) (initargs _)
  (destructuring-bind (&key texture) initargs
    (make-instance 'background :texture (decode 'asset texture))))

(define-encoder (background v0) (_b _p)
  `(background :texture ,(encode (texture background))))

(define-decoder (falling-platform v0) (initargs _)
  (destructuring-bind (&key texture acceleration location) initargs
    (make-instance 'falling-platform
                   :texture (decode 'asset texture)
                   :acceleration (decode 'vec2 acceleration)
                   :location (decode 'vec2 location))))

(define-encoder (falling-platform v0) (_b _p)
  `(falling-platform :texture ,(encode (texture falling-platform))
                     :acceleration ,(encode (acceleration falling-platform))
                     :location ,(encode (location falling-platform))))

(define-decoder (basic-light v0) (initargs _)
  (destructuring-bind (&key color data) initargs
    (make-instance 'basic-light
                   :color (decode 'vec4 color)
                   :data data)))

(define-encoder (basic-light v0) (_b _p)
  `(basic-light :color ,(encode (color basic-light))
                :data ,(buffer-data (caar (bindings (vertex-array light))))))

(define-decoder (vec2 v0) (data _p)
  (destructuring-bind (x y) data
    (vec2 x y)))

(define-encoder (vec2 v0) (_b _p)
  (list (vx vec2)
        (vy vec2)))

(define-decoder (vec3 v0) (data _p)
  (destructuring-bind (x y z) data
    (vec3 x y z)))

(define-encoder (vec3 v0) (_b _p)
  (list (vx vec3)
        (vy vec3)
        (vz vec3)))

(define-decoder (vec4 v0) (data _p)
  (destructuring-bind (x y z w) data
    (vec4 x y z w)))

(define-encoder (vec4 v0) (_b _p)
  (list (vx vec4)
        (vy vec4)
        (vz vec4)
        (vw vec4)))

(define-decoder (asset v0) (data _p)
  (destructuring-bind (pool name) data
    (asset pool name)))

(define-encoder (asset v0) (_b _p)
  (list (name (pool asset))
        (name asset)))
