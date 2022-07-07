(defpackage #:org.shirakumo.fraf.kandria.quest
  (:use #:cl)
  (:shadow #:condition)
  (:local-nicknames
   (#:dialogue #:org.shirakumo.fraf.speechless)
   (#:components #:org.shirakumo.markless.components))
  ;; scope
  (:export
   #:scope
   #:initial-bindings
   #:bindings
   #:reset
   #:parent
   #:binding
   #:merge-bindings
   #:var
   #:list-variables)
  ;; describable
  (:export
   #:describable
   #:name
   #:title
   #:description
   #:active-p
   #:activate
   #:deactivate
   #:complete
   #:fail
   #:try
   #:find-named)
  ;; storyline
  (:export
   #:storyline
   #:quests
   #:known-quests
   #:find-quest
   #:class-for
   #:define-storyline
   #:print-storyline
   #:update)
  ;; quest
  (:export
   #:quest
   #:status
   #:author
   #:storyline
   #:tasks
   #:on-activate
   #:active-tasks
   #:make-assembly
   #:compile-form
   #:find-task
   #:define-quest)
  ;; task
  (:export
   #:task
   #:quest
   #:causes
   #:triggers
   #:all-complete
   #:on-complete
   #:on-activate
   #:invariant
   #:condition
   #:find-trigger
   #:define-task)
  ;; trigger
  (:export
   #:trigger
   #:task
   #:action
   #:define-action
   #:interaction
   #:interactable
   #:dialogue
   #:define-interaction))
