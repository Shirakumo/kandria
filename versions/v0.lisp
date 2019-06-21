(in-package #:org.shirakumo.fraf.leaf)

(defclass v0 (version) ())

(define-decoder (region v0) (info packet)
  (let* ((region (apply #'make-instance 'region info))
         (data (zip:get-zipfile-entry "data" packet))
         (content (parse-sexp-vector (zip:zipfile-entry-contents data))))
    (loop for (type . initargs) in content
          do (enter (decode type initargs) region))
    region))

(define-encoder (region v0) (_b packet)
  (let ((data (apply #'make-sexp-stream
               (for:for ((entity over region)
                         (_ collecting (encode entity)))))))
    (zip:write-zipentry packet "data" data :file-write-data (get-universal-time)))
  (list :name (name region)
        :author (author region)
        :version (version region)
        :description (description region)))

(define-decoder (player v0) (initargs _p)
  (destructuring-bind (x y) (getf initargs :location)
    (make-instance 'player :location (vec2 x y))))

(define-encoder (player v0) (_b _p)
  `(player :location ,(encode (location player))))

(define-decoder (chunk v0) (initargs packet)
  (destructuring-bind (&key name location size background tileset layers) initargs
    (make-instance 'chunk :name name
                          :location (decode 'vec2)
                          :size (decode 'vec2)
                          :tileset (decode 'asset)
                          :layers (loop for file in layers collect (load-packet-file packet file T)))))

(define-encoder (chunk v0) (_b packet)
  (let ((layers (loop for i from 0
                      for layer in (layers chunk)
                      ;; KLUDGE: no png saving lib handy. Hope ZIP compression is Good Enough
                      for path = (format NIL "resources/~a-~d.raw" (name chunk) i)
                      do (zip:write-zipentry packet path layer :file-write-date (get-universal-time))
                      collect path))))
  `(chunk :name ,(name chunk)
          :location ,(encode (location chunk))
          :size ,(encode (size chunk))
          :tileset ,(encode (tileset chunk))
          :layers layers))

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
