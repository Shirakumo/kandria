;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q13-planting-bomb)
  :author "Tim White"
  :title "Name"
  :description "Description"
  :on-activate (task-1)
  
  ;; plant bombs (moulding into place, then attaching detonators - 2 each bomb)
  ;; when all bombs are planted activated trigger(s)
  ;; when pass through trigger(s) call base
  ;; but there's a problem - return to find Wraw leader there
  
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