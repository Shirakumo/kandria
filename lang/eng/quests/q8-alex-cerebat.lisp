;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria q8-alex-cerebat)
  :author "Tim White"
  :title "Alex"
  :visible NIL
  (:interact (alex) :repeatable T
  "
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
"))