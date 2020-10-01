(asdf:defsystem leaf-quest
  :components ((:file "package")
               (:file "nodes")
               (:file "quest"))
  :depends-on (:flow
               :leaf-dialogue
               :verbose))
