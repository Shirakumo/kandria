;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q8-alex-cerebat)
  :author "Tim White"
  :title ""
  :visible NIL
  :on-activate T
  (task-1
   :title ""
   :invariant (not (complete-p 'q11-recruit-semis))
   :condition all-complete
   :on-activate T
   (:interaction interact
    :interactable alex
    :dialogue "
~ alex
| (:angry)Get lost.
~ player
- Alex?
- What are you doing here?
- Are you sober?
~ alex
| (:angry)Mind your own business.
| I'm doing my job, just like you. I'm still a hunter, ya know.
| We're done.
")))