(asdf:defsystem kandria
  :version "1.1.0"
  :build-operation "deploy-op"
  :build-pathname #+linux "kandria-linux.run"
                  #+darwin "kandria-macos.o"
                  #+win32 "kandria-windows"
                  #+(and bsd (not darwin)) "kandria-bsd.run"
                  #-(or linux bsd win32) "kandria"
  :entry-point "org.shirakumo.fraf.kandria::main"
  :components ((:file "package")
               (:file "toolkit")
               (:file "helpers")
               (:file "palette")
               (:file "sprite-data")
               (:file "tile-data")
               (:file "gradient")
               (:file "auto-fill")
               (:file "serialization")
               (:file "region")
               (:file "actions")
               (:file "surface")
               (:file "lighting")
               (:file "background")
               (:file "environment")
               (:file "assets")
               (:file "quest")
               (:file "language")
               (:file "shadow-map")
               (:file "particle")
               (:file "chunk")
               (:file "effect")
               (:file "interactable")
               (:file "moving-platform")
               (:file "medium")
               (:file "water")
               (:file "grass")
               (:file "moving")
               (:file "move-to")
               (:file "animatable")
               (:file "spawn")
               (:file "inventory")
               (:file "rope")
               (:file "fishing")
               (:file "trigger")
               (:file "stats")
               (:file "player")
               (:file "toys")
               (:file "ai")
               (:file "enemy")
               (:file "npc")
               (:file "critter")
               (:file "cheats")
               (:file "sentinel")
               (:file "world")
               (:file "save-state")
               (:file "camera")
               (:file "main")
               (:file "effects")
               (:file "displacement")
               (:file "achievements")
               (:file "module")
               (:module "versions"
                :components ((:file "v0")
                             (:file "binary-v0")
                             (:file "world-v0")
                             (:file "save-v0")
                             (:file "module-v0")))
               (:module "remote"
                :components ((:file "protocol")
                             (:file "modio")
                             (:file "steam")))
               (:module "ui"
                :components ((:file "general")
                             (:file "components")
                             (:file "popup")
                             (:file "textbox")
                             (:file "dialog")
                             (:file "walkntalk")
                             (:file "report")
                             (:file "prompt")
                             (:file "diagnostics")
                             (:file "hud")
                             (:file "quick-menu")
                             (:file "map")
                             (:file "menu")
                             (:file "gameover")
                             (:file "save-menu")
                             (:file "options-menu")
                             (:file "main-menu")
                             (:file "credits")
                             (:file "shop")
                             (:file "load-screen")
                             (:file "pause-screen")
                             (:file "end-screen")
                             (:file "wardrobe")
                             (:file "upgrade")
                             (:file "stats")
                             (:file "fast-travel")
                             (:file "cheats")
                             (:file "demo-intro")
                             (:file "save-icon")
                             (:file "speedrun")
                             (:file "startup")
                             (:file "early-end")
                             (:file "gamepad")
                             (:file "races")
                             (:file "module")))
               (:module "editor"
                :components ((:file "history")
                             (:file "tool")
                             (:file "browser")
                             (:file "paint")
                             (:file "line")
                             (:file "rectangle")
                             (:file "freeform")
                             (:file "editor")
                             (:file "toolbar")
                             (:file "chunk")
                             (:file "remesh")
                             (:file "entity")
                             (:file "selector")
                             (:file "creator")
                             (:file "animation")
                             (:file "move-to")
                             (:file "lighting")
                             (:file "drag")
                             (:file "auto-tile")))
               (:file "deploy"))
  :serial T
  :defsystem-depends-on (:deploy)
  :depends-on (:trial-glfw
               :trial-alloy
               :trial-harmony
               :trial-steam
               :trial-notify
               :trial-feedback
               :trial-png
               :alloy-constraint
               :depot
               :depot-zip
               :zip
               :fast-io
               :ieee-floats
               :babel
               :form-fiddle
               :array-utils
               :lambda-fiddle
               :trivial-arguments
               :filesystem-utils
               :trivial-indent
               :speechless
               :kandria-quest
               :alexandria
               :random-state
               :file-select
               :cl-mixed-wav
               :cl-mixed-vorbis
               :cl-modio
               :zpng
               :jsown
               :swank
               :action-list
               :easing
               :promise))
