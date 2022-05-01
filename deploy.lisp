(in-package #:org.shirakumo.fraf.kandria)

(deploy:define-hook (:deploy kandria -1) (directory)
  (org.shirakumo.zippy:compress-zip
   (pathname-utils:subdirectory (root) "world")
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
