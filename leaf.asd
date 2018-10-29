(asdf:defsystem leaf
  :components ((:file "package")
               (:file "parallax")
               (:file "layer")
               (:file "surface")
               (:file "player")
               (:file "level")
               (:file "editor")
               (:file "main")
               (:file "effects"))
  :depends-on (:trial-glfw
               :fast-io
               :ieee-floats
               :babel))
