(asdf:defsystem kandria-quest
  :components ((:file "package")
               (:file "describable")
               (:file "scope")
               (:file "storyline")
               (:file "quest")
               (:file "task")
               (:file "trigger"))
  :depends-on (:speechless
               :verbose
               :form-fiddle))
