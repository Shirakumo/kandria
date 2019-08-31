(in-package #:org.shirakumo.fraf.leaf)

(define-asset (world player) image
    #p"player.png"
  :internal-format :srgb-alpha
  :min-filter :nearest
  :mag-filter :nearest)

(define-asset (world player-profile) image
    #p"player-profile.png"
  :internal-format :srgb-alpha
  :min-filter :nearest
  :mag-filter :nearest)

(define-asset (world ice) image
    #p"ice.png"
  :min-filter :nearest
  :mag-filter :nearest)

(define-asset (world icey-mountains) image
    #p "icey-mountains.png"
  :min-filter :nearest
  :mag-filter :nearest)

(define-asset (world tundra) image
    #p"tundra.png"
  :internal-format :srgb-alpha
  :min-filter :nearest
  :mag-filter :nearest)

(define-asset (world tundra-bg) image
    #p"tundra-bg.png"
  :internal-format :srgb-alpha
  :min-filter :nearest
  :mag-filter :nearest)

(define-asset (world tundra-absorption) image
    #p"tundra-absorption.png"
  :min-filter :nearest
  :mag-filter :nearest)

(define-asset (world fi) image
    #p"fi.png"
  :min-filter :nearest
  :mag-filter :nearest)

(define-asset (world fi-profile) image
    #p "fi-profile.png"
  :min-filter :nearest
  :mag-filter :nearest)
