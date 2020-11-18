(in-package #:org.shirakumo.fraf.kandria)

(deploy:define-hook (:deploy kandria -1) (directory)
  (let ((root (root)))
    (labels ((prune (file)
               (cond ((listp file)
                      (mapc #'prune file))
                     ((wild-pathname-p file)
                      (prune (directory file)))
                     ((pathname-utils:directory-p file)
                      (uiop:delete-directory-tree file :validate (constantly T) :if-does-not-exist :ignore))
                     (T
                      (delete-file file))))
             (copy-file (file)
               (uiop:copy-file (merge-pathnames file root)
                               (merge-pathnames file directory))))
      (copy-file "CHANGES.mess")
      (copy-file "README.mess")
      (copy-file "keymap.lisp")
      (deploy:copy-directory-tree (pathname-utils:subdirectory root "world") directory)
      (deploy:status 1 "Pruning assets")
      ;; TODO: compress world in a zip
      ;; TODO: run oxping/optipng/pngcrush to compress pngs
      ;; Prune undesired assets. This sucks, an automated, declarative way would be much better.
      (prune (pathname-utils:subdirectory directory "pool" "EFFECTS"))
      (prune (pathname-utils:subdirectory directory "pool" "WORKBENCH"))
      (prune (pathname-utils:subdirectory directory "pool" "TRIAL" "nissi-beach"))
      (prune (pathname-utils:subdirectory directory "pool" "TRIAL" "masko-naive"))
      (prune (make-pathname :name :wild :type "png" :defaults (pathname-utils:subdirectory directory "pool" "TRIAL")))
      (prune (make-pathname :name :wild :type "svg" :defaults (pathname-utils:subdirectory directory "pool" "TRIAL")))
      (prune (make-pathname :name :wild :type "jpg" :defaults (pathname-utils:subdirectory directory "pool" "TRIAL")))
      (prune (make-pathname :name :wild :type "frag" :defaults (pathname-utils:subdirectory directory "pool" "TRIAL")))
      (prune (make-pathname :name :wild :type "ase" :defaults (pathname-utils:subdirectory directory "pool" "KANDRIA"))))))

#+linux
(trial::dont-deploy
 org.shirakumo.file-select.gtk::gmodule
 org.shirakumo.file-select.gtk::gio
 org.shirakumo.file-select.gtk::gtk
 org.shirakumo.file-select.gtk::glib
 cl+ssl::libssl
 cl+ssl::libcrypto)
#+darwin
(trial::dont-deploy
 org.shirakumo.file-select.macos::foundation
 org.shirakumo.file-select.macos::appkit
 org.shirakumo.file-select.macos::cocoa)
#+windows
(trial::dont-deploy
 org.shirakumo.file-select.win32::ole32)

(deploy:remove-hook :deploy 'org.shirakumo.fraf.trial.alloy::alloy)
