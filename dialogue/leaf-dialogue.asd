(asdf:defsystem leaf-dialogue
  :components ((:file "package")
               (:file "components")
               (:file "syntax")
               (:file "vm"))
  :depends-on (:cl-markless
               :3d-vectors))
