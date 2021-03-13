(asdf:defsystem kandria
  :version "0.1.0"
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
               (:file "language")
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
               (:file "background")
               (:file "tile-data")
               (:file "assets")
               (:file "shadow-map")
               (:file "particle")
               (:file "effect")
               (:file "chunk")
               (:file "interactable")
               (:file "moving-platform")
               (:file "medium")
               (:file "water")
               (:file "grass")
               (:file "moving")
               (:file "move-to")
               (:file "animatable")
               (:file "inventory")
               (:file "rope")
               (:file "trigger")
               (:file "player")
               (:file "toys")
               (:file "ai")
               (:file "enemy")
               (:file "npc")
               (:file "cheats")
               (:file "world")
               (:file "save-state")
               (:file "camera")
               (:file "main")
               (:file "deploy")
               (:file "effects")
               (:file "displacement")
               (:module "versions"
                :components ((:file "v0")
                             (:file "binary-v0")
                             (:file "world-v0")
                             (:file "save-v0")))
               (:module "ui"
                :components ((:file "general")
                             (:file "components")
                             (:file "textbox")
                             (:file "dialog")
                             (:file "walkntalk")
                             (:file "report")
                             (:file "prompt")
                             (:file "status")
                             (:file "diagnostics")
                             (:file "hud")
                             (:file "timer")
                             (:file "quick-menu")
                             (:file "menu")))
               (:module "editor"
                :components ((:file "history")
                             (:file "tool")
                             (:file "browser")
                             (:file "paint")
                             (:file "line")
                             (:file "rectangle")
                             (:file "freeform")
                             (:file "editor")
                             (:file "editmenu")
                             (:file "toolbar")
                             (:file "chunk")
                             (:file "remesh")
                             (:file "entity")
                             (:file "creator")
                             (:file "animation")
                             (:file "move-to"))))
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
               :speechless
               :kandria-quest
               :alexandria
               :file-select
               :feedback-client
               :cl-mixed-wav
               :cl-mixed-mpg123
               :zpng))
