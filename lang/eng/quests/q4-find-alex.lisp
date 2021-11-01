;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q4-find-alex)
  :author "Tim White"
  :title "Find Alex"
  :description ""
  :on-activate (find-alex)

  (find-alex
   :title ""
   :description NIL
   :invariant T
   :condition all-complete
   :on-activate (q4-reminder alex-arrive)
   :on-complete (return-seeds)

   (:interaction q4-reminder
    :interactable fi
    :repeatable T
    :dialogue "
~ fi
| REMINDER Travel \"across the surface to the east\"(orange) and beneath the \"Ruins there - retrieve whatever seeds remain\"(orange) in the cache.
| Good luck, Stranger.
")


   (:interaction alex-arrive
    :interactable alex
    :dialogue "
~ player
| Yo Alex.
")))
