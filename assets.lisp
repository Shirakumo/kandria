(in-package #:org.shirakumo.fraf.kandria)

(defun pathname-asset-name (path &key ignore-directory)
  (flet ((rep (regex replace source)
           (cl-ppcre:regex-replace-all regex source replace)))
    (let ((name (rep "-+" "-" (rep "[ _.]" "-" (pathname-name path))))
          (dirs (unless ignore-directory (rest (pathname-directory path)))))
      (format NIL "~:@(~{~a/~}~a~)" dirs name))))

(defun auto-generate-assets (pool type pathname &key attributes ignore-directory debug)
  (let ((base (pool-path pool #p""))
        (default-options (rest (find T attributes :key #'first))))
    (loop for path in (directory (pool-path pool pathname))
          collect (let* ((path (enough-namestring path base))
                         (name (intern (pathname-asset-name path :ignore-directory ignore-directory) #.*package*))
                         (options (append (rest (find name attributes :key #'first)) default-options)))
                    (if debug
                        (print `(define-asset (,pool ,name) ,type
                                    ,(pathname path)
                                  ,@options))
                        (ensure-instance (asset pool name NIL) type
                                         :input (pathname path)
                                         :name name
                                         :pool pool
                                         :generation-arguments options))))))

(defmacro define-assets-from-path ((pool type pathname &rest args) &body attributes)
  `(auto-generate-assets ',pool ',type ,pathname :attributes ',attributes ,@args))

(defmacro define-sound (name &body args)
  `(define-asset (sound ,name) sound
       ,(make-pathname :name (string-downcase name) :type "wav")
     ,@args))

(defmacro define-bg (name &body args)
  (let ((wrapping (getf args :wrapping ''(:repeat :clamp-to-edge :clamp-to-edge)))
        (args (remf* args :wrapping))
        (texture (intern (format NIL "~a-BG" (string name)))))
    `(progn
       (define-asset (kandria ,texture) image
           ,(make-pathname :name (string-downcase name) :type "png" :directory `(:relative "background"))
         :wrapping ,wrapping)
       (define-background ,name
         :texture (// 'kandria ',texture)
         ,@args))))

(define-asset (music region1) environment
    '((:normal "region1 medium.oga")
      (:vocal "region1 medium vocal.oga")
      (:quiet "region1 quiet.oga" "region1 quiet vocal.oga")
      (:ambient "region1 ambient.oga" "region1 ambient vocal.oga")))

(define-assets-from-path (kandria sprite-data "sprite/*.lisp" :ignore-directory T))

(define-assets-from-path (kandria tile-data "tileset/*.lisp" :ignore-directory T))

(define-assets-from-path (kandria image "texture/*.png" :ignore-directory T)
  (T :min-filter :nearest :mag-filter :nearest)
  (noise :wrapping :repeat :min-filter :linear :mag-filter :linear)
  (noise-cloud :wrapping :repeat :min-filter :linear :mag-filter :linear)
  (shockwave :min-filter :linear :mag-filter :linear)
  (dashwave :min-filter :linear :mag-filter :linear)
  (heatwave :wrapping :repeat :min-filter :linear :mag-filter :linear)
  (scanline :min-filter :linear :mag-filter :linear)
  (block-transition :wrapping :repeat)
  (plain-transition :wrapping :repeat))

(define-assets-from-path (sound sound "**/*.wav")
  (T :volume 0.1)
  (dialogue-scroll :repeat T :volume 0.2)
  (die-box :volume 0.05)
  (earthquake :volume 0.5)
  (jump :volume 0.025)
  (land-normal :volume 0.05)
  (notice-zombie :volume 0.05)
  (sandstorm :volume 0.5 :repeat T)
  (slash :volume 0.05)
  (slide :volume 0.075 :repeat T)
  (step-dirt :volume 0.025 :effects ((mixed:pitch :name pitch :wet 0.1))))

(define-bg tundra
  :parallax (vec 2.0 1.0)
  :scaling (vec 1.5 1.5)
  :offset (vec 0.0 0.0))

(define-bg desert
  :parallax (vec 2.0 5.0)
  :scaling (vec 1.5 1.5)
  :offset (vec 0.0 2000.0))

(define-bg debug
  :parallax (vec 2.0 1.0)
  :scaling (vec 1.5 1.5)
  :offset (vec 0.0 -2000.0))

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

(define-bg grave
  :wrapping '(:clamp-to-edge :clamp-to-edge :clamp-to-edge)
  :offset (vec 6120 3108)
  :parallax (vec 1.0 1.0)
  :scaling (vec 2.0 2.0)
  :lighting-strength 0.75)

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

(define-gi grave
  :attenuation 0.2
  :location (vec -6295.0 -2449.0)
  :light-multiplier 1.0
  :light (vec 1.5 1 0.5)
  :ambient-multiplier 0.2
  :ambient (vec 0.5 0.4 0.4))
