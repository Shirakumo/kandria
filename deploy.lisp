(in-package #:org.shirakumo.fraf.kandria)

(defmethod trial:report-on-error ((error org.shirakumo.fraf.mixed.wav:wave-format-error))
  (trial:emessage "The file ~a is corrupted and could not be read. Please verify your installation."
                  (org.shirakumo.fraf.mixed.wav:file error)))

(defmethod trial:report-on-error ((error org.shirakumo.fraf.vorbis:vorbis-error))
  (trial:emessage "An audio file is corrupted and could not be read. Please verify your installation."))

(deploy:define-hook (:deploy kandria -1) (directory)
  (org.shirakumo.zippy:compress-zip
   (pathname-utils:subdirectory (data-root) "world")
   (make-pathname :name "world" :type "zip" :defaults directory)
   :strip-root T :if-exists :supersede))

#+linux
(trial::dont-deploy
 org.shirakumo.file-select.gtk::gmodule
 org.shirakumo.file-select.gtk::gio
 org.shirakumo.file-select.gtk::gtk
 org.shirakumo.file-select.gtk::glib)
#+darwin
(trial::dont-deploy
 org.shirakumo.file-select.macos::foundation
 org.shirakumo.file-select.macos::appkit
 org.shirakumo.file-select.macos::cocoa)

(deploy:remove-hook :deploy 'org.shirakumo.fraf.trial.alloy::alloy)

(depot:with-depot (depot (find-world))
  (v:info :kandria.quest "Setting up default world, this can take a bit...")
  (setup-world NIL depot))
