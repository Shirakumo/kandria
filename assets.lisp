(in-package #:org.shirakumo.fraf.kandria)

(defmacro define-sprite (name path &body args)
  `(define-asset (kandria ,name) image
       ,path
     :min-filter :nearest
     :mag-filter :nearest
     ,@args))

(define-sprite palette
    #p"palette.png")

(define-sprite lights
    #p"lights.png")

(define-sprite pixelfont
    #p"pixelfont.png")

(define-sprite tundra-bg
    #p"tundra-bg.png"
  :wrapping '(:repeat :clamp-to-edge :clamp-to-edge))

(define-sprite debug-bg
    #p"debug-bg.png"
  :wrapping '(:repeat :clamp-to-edge :clamp-to-edge))

(define-sprite ball
    #p"ball.png")

(define-asset (kandria box) sprite-data
    #p"box.lisp")

(define-asset (kandria player) sprite-data
    #p"player.lisp")

(define-asset (kandria player-profile) trial:sprite-data
    #p"player-profile.json")

(define-asset (kandria fi) sprite-data
    #p"fi.lisp")

(define-asset (kandria fi-profile) trial:sprite-data
    #p"fi-profile.json")

(define-asset (kandria wolf) sprite-data
    #p"wolf.lisp")

(define-asset (kandria zombie) sprite-data
    #p"zombie.lisp")

(define-asset (kandria dummy) sprite-data
    #p"dummy.lisp")

(define-asset (kandria balloon) trial:sprite-data
    #p"balloon.json")

(define-asset (kandria debug-door) trial:sprite-data
    #p"debug-door.json")

(define-asset (kandria passage) trial:sprite-data
    #p"passage.json")

(define-asset (kandria effects) trial:sprite-data
    #p"effects.json")

(define-asset (kandria tundra) tile-data
    #p"tundra.lisp")
 
(define-asset (kandria debug) tile-data
    #p"debug.lisp")

(define-asset (kandria music) sound
    #p"sound/music.mp3"
  :volume 0.3
  :repeat T
  :mixer :music)

(define-asset (kandria dash) sound
    #p"sound/dash.wav"
  :volume 0.1)

(define-asset (kandria jump) sound
    #p"sound/jump.wav"
  :volume 0.025)

(define-asset (kandria land) sound
    #p"sound/land.wav"
  :volume 0.05)

(define-asset (kandria slide) sound
    #p"sound/slide.wav"
  :volume 0.075
  :repeat T)

(define-asset (kandria step) sound
    #p"sound/step.wav"
  :volume 0.025
  :effects '((mixed:pitch :name pitch)))

(define-asset (kandria death) sound
    #p"sound/death.wav"
  :volume 0.1)

(define-asset (kandria box-break) sound
    #p"sound/box-break.wav"
  :volume 0.05)

(define-asset (kandria box-damage) sound
    #p"sound/box-damage.wav"
  :volume 0.1)

(define-asset (kandria slash) sound
    #p"sound/slash.wav"
  :volume 0.05)

(define-asset (kandria rope) sound
    #p"sound/rope.wav"
  :volume 0.1)

(define-gi none
  :location NIL
  :light (vec 0 0 0)
  :ambient (vec 5 5 5))

(define-gi tundra
  :location :sun
  :light '(6 (0 0 0)
           9 (2.6588235 3.0 2.929412)
           10 (4.4313726 5.0 4.8823533)
           14 (4.4313726 5.0 4.882353)
           15 (2.964706 3.0 2.3294117)
           18 (0 0 0))
  :ambient '(0  (0.0627451 0.0 0.23921569)
             1  (0.21568628 0.24705882 0.3882353)
             5  (1.0 0.47843137 0.47843137)
             7  (0.9882353 1.0 0.7764706)
             9  (0.8862745 1.0 0.9764706)
             14 (0.8862745 1.0 0.9764706)
             16 (0.9882353 1.0 0.7764706)
             18 (1.0 0.67058825 0.20784314)
             19 (0.8980392 0.35686275 0.35686275)
             20 (0.21568628 0.24705882 0.3882353)
             24 (0.0627451 0.0 0.23921569)))

(define-gi dark
  :attenuation 1.6
  :location 'player
  :light-multiplier 1.0
  :light (vec 2 1 0.5)
  :ambient-multiplier 0.1
  :ambient (vec 0.3 0.1 0.1))

(define-background tundra
  :texture (// 'kandria 'tundra-bg)
  :parallax (vec 2.0 1.0)
  :scaling (vec 1.5 1.5)
  :offset (vec 0.0 0.0))

(define-background debug
  :texture (// 'kandria 'debug-bg)
  :parallax (vec 2.0 1.0)
  :scaling (vec 1.5 1.5)
  :offset (vec 0.0 0.0))
