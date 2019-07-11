(asdf:defsystem leaf-dialogue
  :components ((:file "package")
               (:file "components")
               (:file "syntax")
               (:file "instructions")
               (:file "compiler")
               (:file "optimizers")
               (:file "vm"))
  :depends-on (:cl-markless
               :3d-vectors))
