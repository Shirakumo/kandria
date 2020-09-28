(asdf:defsystem leaf
  :version "0.0.3"
  :build-operation "deploy-op"
  :build-pathname #+linux "kandria-linux.run"
                  #+darwin "kandria-macos"
                  #+win32 "kandria-windows"
                  #+(and bsd (not darwin)) "kandria-bsd.run"
                  #-(or linux bsd win32) "kandria"
  :entry-point "org.shirakumo.fraf.leaf:launch"
  :components ((:file "package")
               (:file "toolkit")
               (:file "helpers")
               (:file "animation")
               (:file "assets")
               (:file "color-temperature")
               (:file "auto-fill")
               (:file "serialization")
               (:file "packet")
               (:file "region")
               (:file "actions")
               (:file "surface")
               (:file "shadow-map")
               (:file "lighting")
               (:file "background")
               (:file "chunk")
               (:file "interactable")
               (:file "moving-platform")
               (:file "medium")
               (:file "water")
               (:file "moving")
               (:file "move-to")
               (:file "animatable")
               (:file "rope")
               (:file "player")
               (:file "enemy")
               (:file "world")
               (:file "save-state")
               (:file "versions/v0")
               (:file "versions/world-v0")
               (:file "versions/save-v0")
               (:file "camera")
               (:file "main")
               (:file "effects")
               (:module "ui"
                :components ((:file "general")
                             (:file "dialog")
                             (:file "report")))
               (:module "editor"
                :components ((:file "history")
                             (:file "tool")
                             (:file "browser")
                             (:file "paint")
                             (:file "line")
                             (:file "freeform")
                             (:file "base")
                             (:file "editor")
                             (:file "editmenu")
                             (:file "toolbar")
                             (:file "chunk")
                             (:file "entity")
                             (:file "creator")
                             (:file "animation"))))
  :serial T
  :defsystem-depends-on (:deploy)
  :depends-on (:trial-glfw
               :trial-alloy
               :trial-harmony
               :alloy-constraint
               (:feature (:not :darwin) :trial-steam)
               :zip
               :fast-io
               :ieee-floats
               :babel
               :form-fiddle
               :array-utils
               :lambda-fiddle
               :trivial-arguments
               :trivial-indent
               :leaf-dialogue
               :leaf-quest
               :alexandria
               :file-select
               :feedback-client
               :cl-mixed-wav
               :cl-mixed-mpg123
               :zpng))
