(in-package #:org.shirakumo.fraf.kandria)

(defmacro define-pixel (name &body args)
  `(define-asset (kandria ,name) image
       ,(make-pathname :name (string-downcase name) :type "png")
     :min-filter :nearest
     :mag-filter :nearest
     ,@args))

(defmacro define-sprite (name &body args)
  `(define-asset (kandria ,name) sprite-data
       ,(make-pathname :name (string-downcase name) :type "lisp")
     ,@args))

(defmacro define-tileset (name &body args)
  `(define-asset (kandria ,name) tile-data
       ,(make-pathname :name (string-downcase name) :type "lisp")
     ,@args))

(defmacro define-sound (name &body args)
  `(define-asset (kandria ,name) sound
       ,(make-pathname :name (string-downcase name) :type "wav" :directory `(:relative "sound"))
     ,@args))

(defmacro define-music (name &body args)
  `(define-asset (kandria ,name) sound
       ,(make-pathname :name (string-downcase name) :type "mp3" :directory `(:relative "sound"))
     :repeat T
     :mixer :music
     ,@args))

(defmacro define-bg (name &body args)
  (let ((wrapping (getf args :wrapping))
        (args (remf* args :wrapping))
        (texture (intern (format NIL "~a-BG" (string name)))))
    `(progn
       (define-pixel ,texture :wrapping ,wrapping)
       (define-background ,name
         :texture (// 'kandria ',texture)
         ,@args))))

(define-asset (kandria noise) image
    #p"noise.png"
  :wrapping :repeat)

(define-asset (kandria noise-cloud) image
    #p"noise-cloud.png"
  :wrapping :repeat)

(define-asset (kandria shockwave) image
  #p"shockwave-2.png")

(define-asset (kandria heatwave) image
  #p"heatwave.png"
  :wrapping :repeat)

(define-asset (kandria scanline) image
  #p"scanline.png"
  :wrapping :clamp-to-edge)

(define-pixel lights)
(define-pixel particles)
(define-pixel items)
(define-pixel pixelfont)
(define-pixel ball)
(define-pixel grass)
(define-pixel logos)
(define-pixel elevator)
(define-pixel player-palette)
(define-pixel block-transition
  :wrapping :repeat)
(define-pixel plain-transition
  :wrapping :repeat)

(define-sprite box)
(define-sprite player)
(define-sprite fi)
(define-sprite catherine)
(define-sprite jack)
(define-sprite sahil)
(define-sprite wolf)
(define-sprite zombie)
(define-sprite ruddydrone)
(define-sprite dummy)
(define-sprite player-profile)
(define-sprite fi-profile)
(define-sprite catherine-profile)
(define-sprite jack-profile)
(define-sprite sahil-profile)
(define-sprite balloon)
(define-sprite debug-door)
(define-sprite passage)
(define-sprite effects)

(define-tileset tundra)
(define-tileset debug)
(define-tileset camp)
(define-tileset region1)

(define-music music :volume 0.3)

(define-sound dash :volume 0.1)
(define-sound dialogue-advance :volume 0.1)
(define-sound dialogue-scroll :volume 0.2 :repeat T)
(define-sound die-zombie :volume 0.1)
(define-sound die-box :volume 0.05)
(define-sound die-player :volume 0.1)
(define-sound earthquake :volume 0.5)
(define-sound enter-water :volume 0.1)
(define-sound hit-zombie :volume 0.1)
(define-sound hit-box :volume 0.1)
(define-sound hit-ground :volume 0.1)
(define-sound jump :volume 0.025)
(define-sound land-normal :volume 0.05)
(define-sound notice-zombie :volume 0.05)
(define-sound rope-extend :volume 0.1)
(define-sound sandstorm :volume 0.5 :repeat T)
(define-sound slash :volume 0.05)
(define-sound slide :volume 0.075 :repeat T)
(define-sound step-dirt :volume 0.025 :effects '((mixed:pitch :name pitch :wet 0.1)))

(define-gi none
  :location NIL
  :light (vec 0 0 0)
  :ambient (vec 2.5 2.5 2.5))

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

(define-gi extradark
  :attenuation 2.0
  :location 'player
  :light-multiplier 0.5
  :light (vec 1.5 1 0.5)
  :ambient-multiplier 0.001
  :ambient (vec 0.5 0.4 0.4))

(define-gi dark
  :attenuation 0.8
  :location 'player
  :light-multiplier 1.5
  :light (vec 1.5 1 0.5)
  :ambient-multiplier 0.2
  :ambient (vec 0.5 0.4 0.4))

(define-gi medium
  :attenuation 0.3
  :location 'player
  :light-multiplier 1.0
  :light (vec 1.5 1 0.5)
  :ambient-multiplier 0.2
  :ambient (vec 0.5 0.4 0.4))

(define-gi desert
  :location :sun
  :light '(6 (0 0 0)
           9 (6 5 4)
           15 (6 5 4)
           18 (0 0 0))
  :light-multiplier 1.0
  :ambient '(0 (0.1 0.1 4.0)
             6 (1 0.5 0.6)
             9 (1 0.6 0.6)
             15 (1 0.6 0.6)
             18 (1 0.5 0.6)
             24 (0.1 0.1 4.0))
  :ambient-multiplier 0.5)

(define-bg tundra
  :wrapping '(:repeat :clamp-to-edge :clamp-to-edge)
  :parallax (vec 2.0 1.0)
  :scaling (vec 1.5 1.5)
  :offset (vec 0.0 0.0))

(define-bg desert
  :wrapping '(:repeat :clamp-to-edge :clamp-to-edge)
  :parallax (vec 2.0 5.0)
  :scaling (vec 1.5 1.5)
  :offset (vec 0.0 2000.0))

(define-bg debug
  :wrapping '(:repeat :clamp-to-edge :clamp-to-edge)
  :parallax (vec 2.0 1.0)
  :scaling (vec 1.5 1.5)
  :offset (vec 0.0 0.0))

(define-bg black
  :wrapping '(:clamp-to-edge :clamp-to-edge :clamp-to-edge))

(define-bg caves
  :wrapping '(:repeat :repeat :clamp-to-edge)
  :parallax (vec 2.0 1.0)
  :scaling (vec 1.5 1.5)
  :offset (vec 0.0 100.0))

(define-bg editor
  :wrapping '(:repeat :repeat :repeat)
  :parallax (vec 1.0 1.0)
  :scaling (vec 0.5 0.5)
  :offset (vec 0 0))

(define-bg hub
  :wrapping '(:clamp-to-edge :clamp-to-edge :clamp-to-edge)
  :offset (vec -800 4220)
  :parallax (vec 1.0 1.0)
  :lighting-strength 0.75)
