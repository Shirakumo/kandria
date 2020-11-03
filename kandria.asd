(asdf:defsystem kandria
  :version "0.0.4"
  :build-operation "deploy-op"
  :build-pathname #+linux "kandria-linux.run"
                  #+darwin "kandria-macos"
                  #+win32 "kandria-windows"
                  #+(and bsd (not darwin)) "kandria-bsd.run"
                  #-(or linux bsd win32) "kandria"
  :entry-point "org.shirakumo.fraf.kandria:launch"
  :components ((:file "package")
               (:file "toolkit")
               (:file "helpers")
               (:file "settings")
               (:file "animation")
               (:file "gradient")
               (:file "auto-fill")
               (:file "serialization")
               (:file "packet")
               (:file "quest")
               (:file "region")
               (:file "actions")
               (:file "surface")
               (:file "lighting")
               (:file "shadow-map")
               (:file "background")
               (:file "tile-data")
               (:file "assets")
               (:file "effect")
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
               (:file "npc")
               (:file "world")
               (:file "save-state")
               (:file "versions/v0")
               (:file "versions/world-v0")
               (:file "versions/save-v0")
               (:file "camera")
               (:file "main")
               (:file "deploy")
               (:file "effects")
               (:module "ui"
                :components ((:file "general")
                             (:file "dialog")
                             (:file "report")
                             (:file "prompt")
                             (:file "status")
                             (:file "diagnostics")))
               (:module "editor"
                :components ((:file "history")
                             (:file "tool")
                             (:file "browser")
                             (:file "paint")
                             (:file "line")
                             (:file "freeform")
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
               :trial-steam
               :trial-notify
               :alloy-constraint
               :zip
               :fast-io
               :ieee-floats
               :babel
               :form-fiddle
               :array-utils
               :lambda-fiddle
               :trivial-arguments
               :trivial-indent
               :kandria-dialogue
               :kandria-quest
               :alexandria
               :file-select
               :feedback-client
               :cl-mixed-wav
               :cl-mixed-mpg123
               :zpng))
