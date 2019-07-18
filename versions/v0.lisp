(in-package #:org.shirakumo.fraf.leaf)

(defclass v0 (version) ())

(define-decoder (world v0) (info packet)
  (let ((world (apply #'make-instance 'world :packet packet info)))
    ;; Load world extensions
    (destructuring-bind (&key sources initial-state)
        (parse-sexps (packet-entry "system.lisp" packet :element-type 'character))
      (dolist (source sources)
        (with-packet-entry (stream source packet)
          ;; FIXME: Compile sources somehow (write out to disk first?)
          (cl:load stream :verbose NIL :print NIL)))
      ;; Load storyline
      (let ((storyline (parse-sexps (packet-entry "storyline.lisp" packet :element-type 'character))))
        (setf (storyline world) (decode 'quest:storyline storyline)))
      ;; Load save to set up initial state
      ;; FIXME: How do we know what to restore if we're loading a save?
      (with-packet-entry (stream initial-state packet)
        (load-state world stream)))
    world))

(define-encoder (world v0) (_b packet)
  ;; KLUDGE: Can't save any more than this as we lost the info during compilation.
  ;;         External tools are necessary to edit the source.
  (list :author (author world)
        :version (version world)))

(define-decoder (quest:storyline v0) (info _p)
  (destructuring-bind (&key quests triggers) (first info)
    (let ((trigger-table (make-hash-table :test 'eq)))
      (loop for info in triggers
            for trigger = (decode 'quest:trigger info)
            do (setf (gethash (quest:name trigger) trigger-table) trigger))
      ;; Compile storyline
      (let ((quests (loop for info in quests
                          ;; KLUDGE: We substitute the packet for the triggers table here so we can
                          ;;         resolve triggers in the task decoder.
                          collect (decode-payload info (type-prototype 'quest:quest) trigger-table v0))))
        (quest:make-storyline quests :quest-type 'quest)))))

(define-decoder (quest:quest v0) (info _p)
  (destructuring-bind (&key name title description effects tasks) info
    (let ((quest (make-instance 'quest-graph:quest :name name :title title :description description))
          (task-table (make-hash-table :test 'eq)))
      (setf (gethash :end tasks) (make-instance 'quest-graph:end))
      (loop for (name . info) in tasks
            do (setf (gethash name task-table) (decode 'quest:task info)))
      ;; Connect effects together
      (dolist (effect effects)
        (quest-graph:connect quest (gethash effect tasks)))
      (loop for (name . info) in tasks
            for task = (gethash name task-table)
            do (dolist (effect (getf info :effects))
                 (quest-graph:connect task (gethash effect tasks))))
      quest)))

(define-decoder (quest:task v0) (info triggers)
  (destructuring-bind (&key name title description invariant condition triggers &allow-other-keys) info
    (let ((task (make-instance 'quest-graph:task :name name :title title :description description
                                                 :invariant invariant :condition condition)))
      (loop for name in triggers
            for trigger = (gethash name triggers)
            do (quest-graph:connect task trigger))
      task)))

(define-decoder (quest:trigger v0) (info packet)
  (destructuring-bind (&key name interactable dialogue) info
    (let ((dialogue (packet-entry dialogue packet :element-type 'character)))
      (make-instance 'quest-graph:interaction :name name :interactable interactable :dialogue dialogue))))

(define-decoder (region v0) (info packet)
  (let* ((region (apply #'make-instance 'region info))
         (content (parse-sexps (packet-entry "data" packet))))
    (loop for (type . initargs) in content
          do (enter (decode type initargs) region))
    region))

(define-encoder (region v0) (_b packet)
  (let ((entities ()))
    (for:for ((entity over region))
      (unless (typep entity 'chunk)
        (push (encode entity) entities)))
    (for:for ((entity across (aref (objects region) 0)))
      (when (typep entity 'chunk)
        (push (encode entity) entities)))
    (let ((data (apply #'princ-to-string* entities)))
      (setf (packet-entry "data" packet) data))
    (list :name (name region)
          :author (author region)
          :version (version region)
          :description (description region))))

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
                      for path = (format NIL "resources/~a-~d.raw" (name chunk) i)
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

(define-decoder (vec2 v0) (data _p)
  (destructuring-bind (x y) data
    (vec2 x y)))

(define-encoder (vec2 v0) (_b _p)
  (list (vx vec2)
        (vy vec2)))

(define-decoder (asset v0) (data _p)
  (destructuring-bind (pool name) data
    (asset pool name)))

(define-encoder (asset v0) (_b _p)
  (list (name (pool asset))
        (name asset)))
