;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria demo-semis)
  :author "Tim White"
  :title "Find the Semi Sisters"
  :description "I need to find the Semi Sisters, so they can fix the water supply for my friends on the surface. Hopefully they aren't tech witches."
  :on-activate (find-semis)

  (find-semis
   :title "Find the Semi Sisters"
   :marker '(innis 500)
   :on-activate (innis-stop-local)
   :condition all-complete
   :on-complete (demo-intro)

   (:interaction innis-stop-local
    :interactable innis
    :dialogue "
~ innis
| (:angry)<-STOP-> WHERE YOU ARE!
| (:sly)We've been watching you, android.
| You'll be pleased to ken that \"we can fix the water\"(orange). Or rather, \"turn it back on\"(orange).
| Once you've \"done something for us\"(orange) - \"talk to my sister up in the control room\"(orange). I'm busy.
")))
#|
ken = know (Scottish)
|#