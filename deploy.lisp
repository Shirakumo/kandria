(in-package #:org.shirakumo.fraf.kandria)

(defmethod trial:report-on-error ((error org.shirakumo.fraf.mixed.wav:wave-format-error))
  (trial:emessage "The file ~a is corrupted and could not be read. Please verify your installation."
                  (org.shirakumo.fraf.mixed.wav:file error)))

(defmethod trial:report-on-error ((error org.shirakumo.fraf.vorbis:vorbis-error))
  (trial:emessage "An audio file is corrupted and could not be read. Please verify your installation."))

(defmethod trial:report-on-error ((error org.shirakumo.depot:depot-condition))
  (trial:emessage "A game resource file is corrupted and could not be read. Please verify your installation."))

(defmethod trial:report-on-error ((error org.shirakumo.file-select:file-select-error))
  (continue))

(define-as-unused kandria
  "**/*.ase"
  "**/*.kra"
  "**/*.*~"
  "**/#*#")

(define-as-unused music
  "**/*.wav")

(define-as-unused trial
  "")

(deploy:define-hook (:deploy kandria -1) (directory)
  (org.shirakumo.zippy:compress-zip
   (pathname-utils:subdirectory (data-root) "world")
   (make-pathname :name "world" :type "zip" :defaults directory)
   :strip-root T :if-exists :supersede)
  (deploy:copy-directory-tree
   (pathname-utils:subdirectory (data-root) "mods")
   directory)
  (deploy:copy-directory-tree
   org.shirakumo.alloy.renderers.opengl::*shaders-directory*
   (pathname-utils:subdirectory directory "pool" "alloy")
   :copy-root NIL))

#+darwin
(trial::dont-deploy
 org.shirakumo.file-select.macos::foundation
 org.shirakumo.file-select.macos::appkit
 org.shirakumo.file-select.macos::cocoa)

(deploy:remove-hook :deploy 'org.shirakumo.fraf.trial.alloy::alloy)

(load-language :language "eng")

#-(or :nx :trial-release)
(depot:with-depot (depot (find-world))
  (v:info :kandria.quest "Setting up default world, this can take a bit...")
  (setup-world NIL depot))

#+(and (not nx) trial-release)
(dolist (language (languages) (load-language :language "eng"))
  (maybe-init-language-cache language))
