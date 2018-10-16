(asdf:defsystem leaf
  :components ((:file "package")
               (:file "layer")
               (:file "main"))
  :depends-on (:trial-glfw))
