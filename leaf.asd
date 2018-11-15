(asdf:defsystem leaf
  :components ((:file "package")
               (:file "helpers")
               (:file "keys")
               (:file "dialog")
               (:file "textbox")
               (:file "parallax")
               (:file "surface")
               (:file "chunk")
               (:file "moving-platform")
               (:file "moving")
               (:file "player")
               (:file "level")
               (:file "editor")
               (:file "camera")
               (:file "main")
               (:file "effects"))
  :depends-on (:trial-glfw
               :fast-io
               :ieee-floats
               :babel
               :form-fiddle
               :lambda-fiddle
               :trivial-arguments))
