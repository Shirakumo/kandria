(in-package #:org.shirakumo.fraf.kandria)

;; TODO: compress world in a zip
;; TODO: run oxping/optipng/pngcrush to compress pngs
(deploy:define-hook (:deploy kandria -1) (directory)
  (deploy:copy-directory-tree (pathname-utils:subdirectory (root) "world") directory))

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
