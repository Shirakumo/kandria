(asdf:defsystem kandria-quest
  :components ((:file "package")
               (:file "quest"))
  :depends-on (:speechless
               :verbose))
