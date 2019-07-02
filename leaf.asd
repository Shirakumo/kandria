(asdf:defsystem leaf
  :components ((:file "package")
               (:file "helpers")
               (:file "packet")
               (:file "region")
               (:file "keys")
               (:file "dialog")
               (:file "textbox")
               (:file "surface")
               (:file "lighting")
               (:file "background")
               (:file "chunk")
               (:file "lighted-sprite-entity")
               (:file "moving-platform")
               (:file "moving")
               (:file "interactable")
               (:file "player")
               (:file "level")
               (:file "versions/v0")
               (:file "editor")
               (:file "menu")
               (:file "camera")
               (:file "main")
               (:file "save-state")
               (:file "effects"))
  :depends-on (:trial-glfw
               :zip
               :fast-io
               :ieee-floats
               :babel
               :form-fiddle
               :array-utils
               :lambda-fiddle
               :trivial-arguments
               :trivial-indent))
