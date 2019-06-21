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

(define-decoder (chunk v0) (initargs _p)
  (destructuring-bind (&key name location size background tileset layers) initargs
    (make-instance 'chunk :name name
                          :location (vec2 (first location) (second location))
                          :size (cons (first size) (second size))
                          :tileset (asset (first tileset) (second tileset))
                          :background (asset (first tileset) (second tileset)))))

(define-encoder (chunk v0) (_b _p)
  `(chunk :name ,(name chunk)
          :location ,(encode (location chunk))
          :size (,(car (size chunk)) ,(cdr (size chunk)))
          :tileset ,(encode (tileset chunk))
          :background ,(encode (background chunk))
          :layers ()))

(define-encoder (vec2 v0) (_b _p)
  (list (vx vec2)
        (vy vec2)))

(define-encoder (asset v0) (_b _p)
  (list (name (pool asset))
        (name asset)))
