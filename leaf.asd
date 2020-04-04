(asdf:defsystem leaf
  :build-operation "deploy-op"
  :build-pathname #+linux "kandria-linux.run"
                  #+darwin "kandria-macos"
                  #-(or linux darwin) "kandria-windows"
  :entry-point "org.shirakumo.fraf.leaf:launch"
  :components ((:file "package")
               (:file "helpers")
               (:file "animation")
               (:file "color-temperature")
               (:file "auto-fill")
               (:file "layered-container")
               (:file "serialization")
               (:file "packet")
               (:file "region")
               (:file "keys")
               (:file "textbox")
               (:file "surface")
               (:file "shadow-map")
               (:file "lighting")
               (:file "background")
               (:file "chunk")
               (:file "moving-platform")
               (:file "moving")
               (:file "move-to")
               (:file "interactable")
               (:file "animatable")
               (:file "enemy")
               (:file "player")
               (:file "world")
               (:file "save-state")
               (:file "versions/v0")
               (:file "versions/world-v0")
               (:file "versions/save-v0")
               (:file "camera")
               (:file "main")
               (:file "effects")
               (:module "ui"
                :components ((:file "general")))
               (:module "editor"
                :components ((:file "history")
                             (:file "tool")
                             (:file "browser")
                             (:file "paint")
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
               (:feature :steam :trial-steam)
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
               :file-select))
