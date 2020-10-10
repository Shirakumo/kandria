(asdf:defsystem kandria-quest
  :components ((:file "package")
               (:file "nodes")
               (:file "quest"))
  :depends-on (:flow
               :kandria-dialogue
               :verbose))
