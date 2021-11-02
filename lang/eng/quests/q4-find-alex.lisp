;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q4-find-alex)
  :author "Tim White"
  :title "Find Alex"
  :description "Fi wants me to find Alex and bring them back to camp for debriefing, to see if they know anything about the Wraw's plans."
  :on-activate (find-alex)

  (find-alex
   :title "Travel down to the Cerebats township, but avoid the Semi Sisters en route."
   :description NIL
   :invariant T
   :condition all-complete
   :on-activate (q4-reminder innis-stop)
   :on-complete (return-seeds)

   (:interaction q4-reminder
    :interactable fi
    :repeatable T
    :dialogue "
~ fi
| Go to the \"Cerebats township deep underground, find Alex and bring them back\"(orange) for debriefing.
| Watch out for the Semi Sisters on your way. They're not our enemies, but they are unpredictable.
")

   (:interaction innis-stop
    :interactable innis
    :dialogue "
~ innis
| Stop right there.
")))

#|
   (:interaction alex-arrive
    :interactable alex
    :dialogue "
~ player
| Yo Alex.
")))
|#