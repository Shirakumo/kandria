;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q6-return-to-fi)
  :author "Tim White"
  :title "Name"
  :description "Description"
  :on-activate (task-1)

  (task-1
   :title "Bullet point"
   :description NIL
   :invariant T
   :condition all-complete
   :on-activate (interact-reminder interact-1)
   :on-complete ()

   (:interaction interact-reminder
    :interactable npc-giver
    :repeatable T
    :dialogue "
")

   (:interaction interact-1
    :interactable npc-1
    :dialogue "
")))