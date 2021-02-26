(asdf:defsystem kandria-dialogue
  :components ((:file "package")
               (:file "components")
               (:file "syntax")
               (:file "instructions")
               (:file "compiler")
               (:file "optimizers")
               (:file "vm")
               (:file "documentation"))
  :depends-on (:cl-markless
               :documentation-utils))
