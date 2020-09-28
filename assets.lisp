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

(define-sprite pixelfont
    #p"pixelfont.png")

(define-sprite tundra-bg
    #p"tundra-bg.png")

(define-sprite debug-bg
    #p"debug-bg.png")

(define-sprite ball
    #p"ball.png")

(define-asset (leaf player) sprite-data
    #p"player.lisp")

(define-asset (leaf player-profile) trial:sprite-data
    #p"player-profile.json")

(define-asset (leaf wolf) sprite-data
    #p"wolf.lisp")

(define-asset (leaf dummy) sprite-data
    #p"dummy.lisp")

(define-asset (leaf balloon) trial:sprite-data
    #p"balloon.json")

(define-asset (leaf debug-door) trial:sprite-data
    #p"debug-door.json")

(define-asset (leaf effects) trial:sprite-data
    #p"effects.json")

(define-asset (leaf tundra) tile-data
    #p"tundra.lisp")
 
(define-asset (leaf debug) tile-data
    #p"debug.lisp")

(define-asset (leaf dash) sound
  #p"sound/dash.wav"
  :volume 0.15)

(define-asset (leaf jump) sound
  #p"sound/jump.wav"
  :volume 0.05)

(define-asset (leaf land) sound
  #p"sound/land.wav"
  :volume 0.075)

(define-asset (leaf slide) sound
  #p"sound/slide.wav"
  :volume 0.1
  :repeat T)

(define-asset (leaf step) sound
  #p"sound/step.wav"
  :volume 0.05)
