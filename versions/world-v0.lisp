(in-package #:org.shirakumo.fraf.kandria)

(defclass world-v0 (v0) ())

(define-decoder (quest:quest world-v0) (info packet)
  (destructuring-bind (&key name author title description on-activate tasks storyline variables &allow-other-keys) info
    (let ((quest (make-instance 'quest :name name :title title :author author :description description
                                       :storyline storyline :on-activate on-activate :bindings variables)))
      (loop for file in tasks
            for (info . triggers) = (parse-sexps (packet-entry file packet :element-type 'character))
            do (decode 'quest:task (list* :quest quest :triggers triggers info)))
      quest)))

(define-decoder (quest:task world-v0) (info _p)
  (destructuring-bind (&key name quest title description invariant condition on-activate on-complete triggers variables &allow-other-keys) info
    (let ((task (make-instance 'task :name name :quest quest :title title :description description
                                     :invariant invariant :condition condition :bindings variables
                                     :on-activate on-activate :on-complete on-complete)))
      (loop for (type . info) in triggers
            do (decode type (list* :task task info)))
      task)))

(define-decoder (quest:action world-v0) (info _p)
  (destructuring-bind (&key name task on-activate on-deactivate) info
    (make-instance 'quest:action :name name :task task
                                 :on-activate on-activate :on-deactivate on-deactivate)))

(define-decoder (quest:interaction world-v0) (info packet)
  (destructuring-bind (&key name title task interactable dialogue repeatable variables) info
    (let ((dialogue (etypecase dialogue
                      (pathname (packet-entry dialogue packet :element-type 'character))
                      (string dialogue))))
      (make-instance 'interaction :name name :title (or title (string name)) :task task
                                  :bindings variables :interactable interactable
                                  :dialogue dialogue :repeatable repeatable))))

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

(define-decoder (chunk world-v0) (initargs packet)
  (destructuring-bind (&key name location size tile-data pixel-data layers background gi) initargs
    (make-instance 'chunk :name name
                          :location (decode 'vec2 location)
                          :size (decode 'vec2 size)
                          :tile-data (decode 'asset tile-data)
                          :pixel-data (packet-entry pixel-data packet)
                          :layers (loop for file in layers
                                        collect (packet-entry file packet))
                          :background (decode 'background-info background)
                          :gi (decode 'gi-info gi))))

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
            :layers ,layers
            :background ,(encode (background chunk))
            :gi ,(encode (gi chunk)))))

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

(define-slot-coders (background world-v0) ())
(define-slot-coders (game-entity world-v0) ((location vec2) name))
(define-slot-coders (sprite-entity world-v0) ((location vec2) (texture texture) (size vec2) (offset vec2) (layer-index T :layer) name))
(define-slot-coders (rope world-v0) (name (location vec2) (bsize vec2) direction extended))
(define-slot-coders (water world-v0) ((location vec2) (bsize vec2)))
(define-slot-coders (place-marker world-v0) (name (location vec2) (bsize vec2)))
(define-slot-coders (grass-patch world-v0) ((location vec2) (bsize vec2) patches (tile-size vec2) (tile-start vec2) tile-count))
(define-slot-coders (trigger world-v0) (name active-p (location vec2) (bsize vec2)))
(define-additional-slot-coders (story-trigger world-v0) (story-item target-status))
(define-additional-slot-coders (tween-trigger world-v0) (left right))
(define-additional-slot-coders (interaction-trigger world-v0) (interaction))
(define-additional-slot-coders (walkntalk-trigger world-v0) (interaction target))

(define-decoder (basic-light world-v0) (initargs _)
  (destructuring-bind (&key color data) initargs
    (make-instance 'basic-light
                   :color (decode 'vec4 color)
                   :data data)))

(define-encoder (basic-light world-v0) (_b _p)
  `(basic-light :color ,(encode (color basic-light))
                :data ,(buffer-data (caar (bindings (vertex-array basic-light))))))

(define-slot-coders (textured-light world-v0) (multiplier (texture texture) (location vec2) (size vec2) (bsize vec2) (frame vec2)))
