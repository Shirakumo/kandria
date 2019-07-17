(in-package #:org.shirakumo.fraf.leaf)

(defclass v0 (version) ())

(define-decoder (world v0) (info packet)
  (let ((world (apply #'make-instance 'world info)))
    ;; FIXME: this
    world))

(define-encoder (world v0) (_b packet)
  ;; FIXME: this
  (list :name (name world)
        :author (author world)
        :version (version world)
        :description (description world)))

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
