(asdf:defsystem leaf
  :components ((:file "package")
               (:file "helpers")
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
               (:file "player")
               (:file "world")
               (:file "versions/v0")
               (:file "editor")
               (:file "camera")
               (:file "main")
               (:file "save-state")
               (:file "versions/save-v0")
               (:file "effects")
               (:module "ui"
                :components ((:file "general")
                             (:file "editmenu")
                             (:file "chunk")
                             (:file "entity"))))
  :depends-on (:trial-glfw
               :trial-alloy
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
