(asdf:defsystem kandria-quest
  :components ((:file "package")
               (:file "quest"))
  :depends-on (:kandria-dialogue
               :verbose))
