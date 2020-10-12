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
   #:action
   #:form
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
   #:fail
   #:deactivate
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
   #:make-assembly
   #:class-for
   #:compile-form
   #:task
   #:status
   #:quest
   #:causes
   #:effects
   #:triggers
   #:all-complete
   #:invariant
   #:condition
   #:trigger
   #:interaction
   #:interactable
   #:dialogue
   #:action
   #:effect))
