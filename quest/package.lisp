(defpackage #:org.shirakumo.fraf.kandria.quest.graph
  (:use #:cl)
  (:shadow #:condition)
  (:export
   #:describable
   #:name
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
   #:quest
   #:end
   #:connect))

(defpackage #:org.shirakumo.fraf.kandria.quest
  (:use #:cl)
  (:shadow #:condition)
  (:import-from #:org.shirakumo.fraf.kandria.quest.graph
                #:describable #:name #:title #:description)
  (:local-nicknames
   (#:graph #:org.shirakumo.fraf.kandria.quest.graph)
   (#:dialogue #:org.shirakumo.fraf.kandria.dialogue))
  (:export
   #:storyline
   #:quests
   #:known-quests
   #:find-quest
   #:make-storyline
   #:activate
   #:complete
   #:try
   #:quest
   #:name
   #:title
   #:description
   #:status
   #:storyline
   #:effects
   #:tasks
   #:find-task
   #:active-tasks
   #:active-p
   #:make-task
   #:make-assembly
   #:task
   #:status
   #:quest
   #:causes
   #:effects
   #:triggers
   #:invariant
   #:condition
   #:trigger
   #:interaction
   #:interactable
   #:dialogue))
