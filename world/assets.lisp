(in-package #:org.shirakumo.fraf.leaf)

(defmacro define-sprite (name path &body args)
  `(define-asset (world ,name) image
       ,path
     :min-filter :nearest
     :mag-filter :nearest
     ,@args))

(define-sprite lights
  #p"lights.png")

(define-sprite player
  #p"player.png")

(define-sprite wolf
  #p"wolf.png")

(define-sprite player-profile
  #p"player-profile.png")

(define-sprite ice
  #p"ice.png")

(define-sprite icey-mountains
  #p "icey-mountains.png")

(define-sprite tundra
  #p"tundra.png")

(define-sprite tundra-bg
  #p"tundra-bg.png")

(define-sprite tundra-absorption
    #p"tundra-absorption.png"
  :internal-format :red)

(define-sprite debug
  #p"debug.png")

(define-sprite debug-bg
  #p"debug-bg.png")

(define-sprite debug-absorption
  #p"debug-absorption.png")

(define-sprite fi
  #p"fi.png")

(define-sprite fi-profile
  #p "fi-profile.png")
