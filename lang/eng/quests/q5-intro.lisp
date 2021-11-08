;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q5-intro)
  :author "Tim White"
  :title "Run Errands"
  :description "Description"
  :on-activate (task-1)

  (task-1
   :title "Bullet point"
   :description NIL
   :invariant T
   :condition all-complete
   :on-activate (interact-reminder interact-1)
   :on-complete (q5-run-errands)

   (:interaction interact-1
    :interactable islay
    :dialogue "
~ islay
| Test
")))