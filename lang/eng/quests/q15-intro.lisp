;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q15-intro)
  :author "Tim White"
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

;; chat to NPCs (short again), with one giving quest (Islay - force interrupt)
;; go through reasons why might not have detonated, from design doc, but also signal interference?