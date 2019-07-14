(defpackage #:org.shirakumo.fraf.leaf.quest.graph
  (:use #:cl)
  (:shadow #:condition)
  (:export
   #:describable
   #:title
   #:description
   #:causes
   #:effects
   #:triggers
   #:tasks
   #:task
   #:invariant
   #:condition
   #:trigger
   #:interaction
   #:interactable
   #:dialogue
   #:start
   #:end
   #:connect))

(defpackage #:org.shirakumo.fraf.leaf.quest
  (:use #:cl)
  (:shadow #:condition)
  (:import-from #:org.shirakumo.fraf.leaf.quest.graph
                #:describable #:title #:description)
  (:local-nicknames
   (#:graph #:org.shirakumo.fraf.leaf.quest.graph)
   (#:dialogue #:org.shirakumo.fraf.leaf.dialogue))
  (:export))
