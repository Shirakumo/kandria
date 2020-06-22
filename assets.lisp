(in-package #:org.shirakumo.fraf.leaf)

(defclass tile-data (multi-resource-asset file-input-asset)
  ((tile-types :initform () :accessor tile-types)))

(defmethod generate-resources ((data tile-data) (path pathname) &key)
  (with-leaf-io-syntax
    (with-open-file (stream path)
      (destructuring-bind (&key albedo absorption tile-types) (read stream)
        (setf (tile-types data) tile-types)
        (generate-resources 'image-loader (merge-pathnames albedo path)
                            :resource (resource data 'albedo))
        (generate-resources 'image-loader (merge-pathnames absorption path)
                            :resource (resource data 'absorption))
        (list (resource data 'albedo)
              (resource data 'absorption))))))

(defmacro define-sprite (name path &body args)
  `(define-asset (leaf ,name) image
       ,path
     :min-filter :nearest
     :mag-filter :nearest
     ,@args))

(define-sprite lights
  #p"lights.png")

(define-sprite tundra-bg
  #p"tundra-bg.png")

(define-asset (leaf player) sprite-data
    #p"player.lisp")

(define-asset (leaf wolf) sprite-data
    #p"wolf.lisp")

(define-asset (leaf tundra) tile-data
    #p"tundra.lisp")
 
(define-asset (leaf debug) tile-data
    #p"debug.lisp")
