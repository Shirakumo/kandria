(in-package #:org.shirakumo.fraf.leaf)

(defclass v0 (version) ())

(define-decoder (region v0) (buffer)
  (destructuring-bind (&key name entities) (first (parse-sexp-vector buffer))
    (setf (slot-value region 'name) name)
    (loop for (type . initargs) in entities
          do (enter (decode type initargs) region))
    region))

(define-encoder (region v0) (stream)
  (with-leaf-io-syntax
    (write (list :name (name region)
                 :entities (for:for ((entity over region)
                                     (_ collecting (encode entity)))))
           :stream stream)))

(define-decoder (player v0) (initargs)
  (destructuring-bind (x y) (getf initargs :location)
    (make-instance 'player :location (vec2 x y))))

(define-encoder (player v0) (_)
  `(player :location ,(encode (location player))))

(define-decoder (chunk v0) (initargs)
  (destructuring-bind (&key name location size background tileset layers) initargs
    (make-instance 'chunk :name name
                          :location (vec2 (first location) (second location))
                          :size (cons (first size) (second size))
                          :tileset (asset (first tileset) (second tileset))
                          :background (asset (first tileset) (second tileset)))))

(define-encoder (chunk v0) (_)
  `(chunk :name ,(name chunk)
          :location ,(encode (location chunk))
          :size (,(car (size chunk)) ,(cdr (size chunk)))
          :tileset ,(encode (tileset chunk))
          :background ,(encode (background chunk))
          :layers ()))

(define-encoder (vec2 v0) (_)
  (list (vx vec2)
        (vy vec2)))

(define-encoder (asset v0) (_)
  (list (name (pool asset))
        (name asset)))
