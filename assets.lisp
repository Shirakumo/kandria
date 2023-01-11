(in-package #:org.shirakumo.fraf.kandria)

(defmacro define-bg (name &body args)
  (let ((wrapping (getf args :wrapping ''(:repeat :clamp-to-edge :clamp-to-edge)))
        (args (remf* args :wrapping))
        (texture (intern (format NIL "~a-BG" (string name)))))
    `(progn
       (define-asset (kandria ,texture) image
           ,(make-pathname :name (string-downcase name) :type "png" :directory `(:relative "background"))
         :wrapping ,wrapping
         :min-filter :nearest
         :mag-filter :nearest)
       (define-background ,name
         :texture (// 'kandria ',texture)
         ,@args))))

(defmacro define-track (name file &rest args)
  `(define-asset (music ,name) trial-harmony:sound
       ,file
     ,@args
     :name ,(file-namestring file)
     :repeat T
     :mixer :music
     :voice-class 'harmony:music-segment))

(define-track menu #p"menu.oga")
(define-track scare #p"scare.oga")
(define-track credits #p"credits.oga"
  :repeat NIL)
(define-track bar #p"bar.oga")
(define-track battle #p"battle.oga"
  :repeat-start 4.8)

(define-asset (music music/region1) trial-harmony:environment
    '((:normal "region1 medium.oga")
      (:vocal "region1 medium vocal.oga")
      (:quiet "region1 quiet.oga" "region1 quiet vocal.oga")
      (:ambient "region1 ambient.oga" "region1 ambient vocal.oga")))

(define-asset (music music/camp) trial-harmony:environment
    '((:normal "camp medium.oga")
      (:vocal "camp medium vocal.oga")
      (:ambient "camp ambient.oga" "camp ambient vocal.oga")))

(define-asset (music music/desert) trial-harmony:environment
    '((:normal "desert medium.oga")
      (:ambient "desert ambient.oga")))

(define-asset (music music/region2) trial-harmony:environment
    '((:normal "region2 medium.oga")
      (:quiet "region2 quiet.oga")
      (:ambient "region2 ambient.oga")))

(define-asset (music music/region3) trial-harmony:environment
    '((:normal "region3 medium.oga")
      (:quiet "region3 quiet.oga")
      (:ambient "region3 ambient.oga")))

(define-asset (music music/bar) trial-harmony:environment
    '((:normal "bar.oga")))

(define-asset (music music/underground-camp) trial-harmony:environment
    '((:normal "underground camp medium.oga")
      (:ambient "underground camp ambient.oga")))

(define-asset (music ambience/camp) trial-harmony:environment
    '((:normal "ambience track_ camp.ogg")))

(define-asset (music ambience/cave) trial-harmony:environment
    '((:normal "ambience track_ cave.ogg")))

(define-asset (music ambience/desert) trial-harmony:environment
    '((:normal "ambience track_ desert.ogg")))

(define-asset (music ambience/desolate-building) trial-harmony:environment
    '((:normal "ambience track_ desolate building.ogg")))

(define-asset (music ambience/large-underground-hall) trial-harmony:environment
    '((:normal "ambience track_ large underground hall.ogg")))

(define-asset (music ambience/underground-building) trial-harmony:environment
    '((:normal "ambience track_ underground building.ogg")))

(define-asset (music ambience/deep-tunnel) trial-harmony:environment
    '((:normal "ambience track_ deep tunnel.ogg")))

(define-asset (music ambience/magma-cave) trial-harmony:environment
    '((:normal "ambience track_ magma cave.ogg")))

(define-asset (music ambience/water-cave) trial-harmony:environment
    '((:normal "ambience track_ big water cave.ogg")))

(define-asset (music ambience/bar) trial-harmony:environment
    '((:normal "ambience track_ bar.ogg")))

(define-assets-from-path (kandria sprite-data "sprite/*.lisp" :ignore-directory T)
  (player-profile :min-filter :linear :mag-filter :linear)
  (catherine-profile :min-filter :linear :mag-filter :linear)
  (jack-profile :min-filter :linear :mag-filter :linear)
  (fi-profile :min-filter :linear :mag-filter :linear)
  (alex-profile :min-filter :linear :mag-filter :linear)
  (sahil-profile :min-filter :linear :mag-filter :linear)
  (innis-profile :min-filter :linear :mag-filter :linear)
  (islay-profile :min-filter :linear :mag-filter :linear)
  (zelah-profile :min-filter :linear :mag-filter :linear)
  (synthesis-profile :min-filter :linear :mag-filter :linear)
  (cerebat-trader-profile :min-filter :linear :mag-filter :linear)
  (vinny-profile :min-filter :linear :mag-filter :linear))

(define-assets-from-path (kandria tile-data "tileset/*.lisp" :ignore-directory T))

(define-assets-from-path (kandria image "texture/*.png" :ignore-directory T)
  (T :min-filter :nearest :mag-filter :nearest)
  (ui-background :min-filter :linear :mag-filter :linear :wrapping :repeat)
  (sword :min-filter :linear :mag-filter :linear)
  (noise :wrapping :repeat :min-filter :linear :mag-filter :linear)
  (noise-cloud :wrapping :repeat :min-filter :linear :mag-filter :linear)
  (shockwave :min-filter :linear :mag-filter :linear)
  (dashwave :min-filter :linear :mag-filter :linear)
  (heatwave :wrapping :repeat :min-filter :linear :mag-filter :linear)
  (scanline :min-filter :linear :mag-filter :linear)
  (block-transition :wrapping :repeat)
  (plain-transition :wrapping :repeat)
  (main-menu :min-filter :linear :mag-filter :linear)
  (logo :min-filter :linear :mag-filter :linear)
  (dda-logo :min-filter :linear :mag-filter :linear)
  (prohelvetia-logo :min-filter :linear :mag-filter :linear)
  (shirakumo-logo :min-filter :linear :mag-filter :linear)
  (trial-logo :min-filter :linear :mag-filter :linear)
  (wind :wrapping :repeat :min-filter :nearest :mag-filter :nearest)
  (region1-overlay :wrapping :repeat)
  (region2-overlay :wrapping :repeat)
  (region3-overlay :wrapping :repeat)
  (wall-overlay :wrapping :repeat)
  (achievements :min-filter :linear :mag-filter :linear))

(define-assets-from-path (sound trial-harmony:sound "**/*.wav")
  (T :volume (db -8))
  (elevator-start :volume (db -6) :max-distance (* +tile-size+ 32) :min-distance (* +tile-size+ 3))
  (elevator-stop :volume (db -6) :max-distance (* +tile-size+ 32) :min-distance (* +tile-size+ 3))
  (elevator-recall :volume (db -2))
  (ui-transition :volume (db 0))
  (key-activate :volume (db 0))
  (key-complete :volume (db 0))
  (ui-quest-start :volume (db 6))
  (ui-quest-complete :volume (db -6))
  (ui-quest-fail :volume (db -6))
  (ui-scroll-dialogue :volume (db -14) :repeat T :effects '(mixed:speed-change))
  (ui-map-scroll :volume (db 0) :repeat T)
  (ui-no-more-to-focus :volume (db 0))
  (ui-close-menu :volume (db -3))
  (ui-open-menu :volume (db -3))
  (ui-start-dialogue :volume (db -1))
  (ambience-earthquake :volume (db -20) :min-distance 100000000000.0 :max-distance 100000100000.0)
  (sandstorm :volume (db -6) :repeat T :min-distance 100000000000.0 :max-distance 100000100000.0)
  (slash :volume (db -6))
  (rotating-swing :volume (db -6))
  (sword-jab :volume (db -6))
  (sword-small-slash-1 :volume (db -6))
  (sword-small-slash-2 :volume (db -6))
  (sword-small-slash-3 :volume (db -6))
  (sword-air-swing-1 :volume (db -6))
  (sword-air-swing-2 :volume (db -6))
  (sword-air-swing-3-jab :volume (db -6))
  (sword-hammer-swing-1 :volume (db -6))
  (sword-hammer-swing-2 :volume (db -6))
  (sword-overhead-swing-1 :volume (db -6))
  (sword-overhead-swing-2 :volume (db -6))
  (sword-overhead-swing-3-tornado :volume (db -6))
  (slide :volume (db -22) :repeat T)
  (telephone-save :volume (db -3))
  (falling-platform-rattle :volume (db -6))
  (falling-platform-impact :volume (db -6))
  (player-dash :volume (db -6))
  (player-enter-passage :volume (db 0))
  (player-red-flashing :volume (db -14) :repeat T)
  (zombie-notice :volume (db -3))
  (zombie-attack :volume (db -3))
  (zombie-damage :volume (db -3))
  (zombie-die :volume (db -3))
  (elevator-move :volume (db -20) :repeat T)
  (fishing-begin-jingle :volume (db -1))
  (fishing-bad-catch :volume (db -1))
  (fishing-good-catch :volume (db -1))
  (fishing-rare-catch :volume (db 0))
  (gate-lift :volume (db -2))
  (door-open :volume (db -2))
  (door-crash :volume (db 0))
  (door-open-sliding-inside :volume (db -2))
  (door-open-sliding-outside :volume (db -2))
  (enter-water :volume (db -7))
  (fountain-fire :volume (db -6))
  (hit-ground :volume (db -6))
  (sword-hit-ground-hard :volume (db -6))
  (sword-hit-ground-soft :volume (db -6))
  (human-damage-1 :volume (db -7))
  (human-damage-2 :volume (db -7))
  (human-damage-3 :volume (db -7))
  (human-damage-4 :volume (db -7))
  (mech-step-1 :volume (db 0))
  (mech-step-2 :volume (db 0))
  (mech-jump :volume (db 0))
  (mech-bash :volume (db 0))
  (mech-pierce :volume (db 0))
  (mech-land :volume (db 0))
  (mech-stun :volume (db 0))
  (bomb-active :volume (db -6) :max-distance (* +tile-size+ 32) :min-distance (* +tile-size+ 3))
  (blocker-destroy :volume (db -1)))

(define-assets-from-path (sound trial-harmony:sound "**/*.ogg")
  (T :volume 0.4)
  (bomb-explode :volume (db 0.0))
  (ambience-strong-wind :repeat T :min-distance 100000000000.0 :max-distance 100000100000.0)
  (player-low-health :volume 0.1 :min-distance 100000000000.0 :max-distance 100000100000.0)
  (ambience-water-pipe-leak :repeat T :volume 0.2 :max-distance (* +tile-size+ 32) :min-distance (* +tile-size+ 3))
  (ambience-water-dripping :repeat T :volume 1.0 :max-distance (* +tile-size+ 16) :min-distance (* +tile-size+ 3))
  (ambience-bubbling-pot :repeat T :volume 0.2 :max-distance (* +tile-size+ 16) :min-distance (* +tile-size+ 3))
  (ambience-fluorescent-light-1 :repeat T :volume 0.2 :max-distance (* +tile-size+ 16) :min-distance (* +tile-size+ 3))
  (ambience-falling-dust-sand :volume (db -1))
  (ambience-pebbles-fall :volume (db 0.0))
  (ambience-metal-creaking :volume (db -6)))

(define-bg tundra
  :parallax (vec 2.0 1.0)
  :scaling (vec 1.5 1.5)
  :offset (vec 0.0 0.0)
  :lighting-strength 0.0)

(define-bg desert
  :parallax (vec 2.0 5.0)
  :scaling (vec 1.5 1.5)
  :offset (vec 0.0 2000.0)
  :lighting-strength 0.8)

(define-bg desert-destroyed
  :parallax (vec 2.0 1.0)
  :scaling (vec 1.5 1.5)
  :offset (vec 0.0 1920.0)
  :lighting-strength 0.8)

(define-bg debug
  :parallax (vec 2.0 1.0)
  :scaling (vec 1.5 1.5)
  :offset (vec 0.0 10800.0)
  :lighting-strength 0.1)

(define-bg black
  :wrapping '(:clamp-to-edge :clamp-to-edge :clamp-to-edge))

(define-bg caves
  :wrapping '(:repeat :repeat :clamp-to-edge)
  :parallax (vec 2.0 2.0)
  :scaling (vec 1.5 1.5)
  :offset (vec 0.0 100.0)
  :lighting-strength 0.1)

(define-bg editor
  :wrapping '(:repeat :repeat :repeat)
  :parallax (vec 1.0 1.0)
  :scaling (vec 0.5 0.5)
  :offset (vec 0 0)
  :lighting-strength 0.0)

(define-bg hub
  :wrapping '(:clamp-to-edge :clamp-to-edge :clamp-to-edge)
  :offset (vec -800 4220)
  :parallax (vec 1.0 1.0)
  :lighting-strength 0.5)

(define-bg grave
  :wrapping '(:clamp-to-edge :clamp-to-edge :clamp-to-edge)
  :offset (vec 6120 3108)
  :parallax (vec 1.0 1.0)
  :scaling (vec 2.0 2.0)
  :lighting-strength 0.1)

(define-bg mushrooms
  :wrapping '(:repeat :repeat :clamp-to-edge)
  :parallax (vec 2.0 2.0)
  :scaling (vec 1.5 1.5)
  :offset (vec 0.0 0.0)
  :lighting-strength 0.5)

(define-bg mines
  :wrapping '(:repeat :repeat :clamp-to-edge)
  :parallax (vec 2.0 2.0)
  :scaling (vec 1.5 1.5)
  :offset (vec 0.0 0.0)
  :lighting-strength 0.5)

(define-gi one
  :location NIL
  :light (vec 0 0 0)
  :ambient (vec 1.0 1.0 1.0))

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

(define-gi platform-cave
  :attenuation 0.3
  :location 'player
  :light-multiplier 0.1
  :light (vec 1.5 1 0.5)
  :ambient-multiplier 1.0
  :ambient (vec 0.5 0.4 0.4))

(define-gi light
  :attenuation 1.0
  :location 'player
  :light-multiplier 0.2
  :light (vec 1.5 1 0.5)
  :ambient-multiplier 2.0
  :ambient (vec 0.5 0.5 0.6))

(define-gi mushrooms
  :attenuation 0.5
  :location 'player
  :light-multiplier 1.0
  :light (vec 1 1 0.8)
  :ambient-multiplier 2.0 
  :ambient (vec 0.3 0.5 0.4))

(define-gi lava-cave
  :attenuation 0.5
  :location 'player
  :light-multiplier 2.0
  :light (vec 2.0 1 0.5)
  :ambient-multiplier 4.0
  :ambient (vec 0.8 0.4 0.4))

(define-gi lava-interior
  :attenuation 0.5
  :location 'player
  :light-multiplier 4.0
  :light (vec 2.0 1 0.5)
  :ambient-multiplier 2.0
  :ambient (vec 0.8 0.4 0.4))

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

(define-gi grave
  :attenuation 0.2
  :location (vec -6295.0 -2449.0)
  :light-multiplier 1.0
  :light (vec 1.5 1 0.5)
  :ambient-multiplier 0.2
  :ambient (vec 0.5 0.4 0.4))

(define-environment (grave hall)
  :music NIL
  :ambience 'ambience/large-underground-hall)

(define-environment (grave tutorial)
  :music NIL
  :ambience 'ambience/underground-building)

(define-environment (desert surface)
  :music 'music/desert
  :ambience 'ambience/desert)

(define-environment (desert entrance)
  :music NIL
  :ambience 'ambience/desert)

(define-environment (camp entrance)
  :music NIL
  :ambience 'ambience/camp)

(define-environment (camp camp)
  :music 'music/camp
  :ambience 'ambience/camp)

(define-environment (camp building)
  :music 'music/camp
  :ambience 'ambience/desolate-building)

(define-environment (region1 cave)
  :music 'music/region1
  :ambience 'ambience/cave)

(define-environment (region1 hall)
  :music 'music/region1
  :ambience 'ambience/large-underground-hall)

(define-environment (region1 building)
  :music 'music/region1
  :ambience 'ambience/underground-building)

(define-environment (region2 hall)
  :music 'music/region2
  :ambience 'ambience/deep-tunnel)

(define-environment (region2 water)
  :music 'music/region2
  :ambience 'ambience/water-cave)

(define-environment (region3 hall)
  :music 'music/region3
  :ambience 'ambience/deep-tunnel)

(define-environment (region3 magma)
  :music 'music/region3
  :ambience 'ambience/magma-cave)

(define-environment (region2 bar)
  :music 'music/bar
  :ambience 'ambience/bar)

(define-environment (region2 transition)
  :music NIL
  :ambience 'ambience/desolate-building)

(define-environment (region2 camp)
  :music 'music/underground-camp
  :ambience 'ambience/desolate-building)
