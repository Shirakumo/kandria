;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q10-wraw)
  :author "Tim White"
  :title "The Wraw"
  :description "Spy Wraw"
  :on-activate (spy-wraw)
  
  (spy-wraw
   :title "Go to Wraw territory"
   :invariant T
   :condition all-complete
   :on-activate (warehouse mechs)
   :on-complete NIL

   (:interaction warehouse
    :interactable player
    :repeatable T
    :dialogue "
~ player
| \"Warehouse supplies.\"(light-gray, italic)
")

   (:interaction mechs
    :interactable player
    :repeatable T
    :dialogue "
~ player
| \"Mechs.\"(light-gray, italic)
")))