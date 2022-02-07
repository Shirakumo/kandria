;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

;; TODO transition cutscene scripting here in the header
;; No need to be visible, since the player will find their way to the destination through the altered level design
(quest:define-quest (kandria epilogue)
  :author "Tim White"
  :visible NIL
  :title "Name"
  :description "Description"
  :on-activate (task-1)

  (task-1
   :title "Bullet point"
   :invariant T
   :condition all-complete
   :on-activate (interact-reminder interact-1)
   :on-complete ()

   (:interaction interact-reminder
    :interactable npc-giver
    :title "Reminder."
    :repeatable T
    :dialogue "
")

   (:interaction interact-1
    :interactable npc-1
    :dialogue "
")))

;; TODO mention no water too