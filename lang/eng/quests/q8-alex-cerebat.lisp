;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q8-alex-cerebat)
  :author "Tim White"
  :title ""
  :visible NIL
  :on-activate (task-1)

  (task-1
   :title ""
   :condition all-complete
   :on-activate (interact)

   (:interaction interact
    :interactable alex
    :repeatable T
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
! eval (setf (var 'alex-cerebat) T)
")))