;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria q15-catherine)
  :author "Tim White"
  :title "Talk to Catherine"
  :description "Islay needs to talk to Catherine in Engineering about checking why the bombs didn't explode."
  (:go-to (catherine)
   :title "Talk to Catherine")
  (:interact (catherine :now T)
    "
~ catherine
| Hey, {#@player-nametag}.
~ player
- Islay needs to talk to you urgently.
  ~ catherine
  | (:concerned)Oh, okay.
- You ready for another adventure?
  ~ catherine
  | (:excited)With you? Always!
- Looks like the old team is getting back together.
  ~ catherine
  | What, you and I?
  | (:excited)What's the plan?
~ player
| \"I lower my vocal volume so only Catherine can hear.\"(light-gray, italic)
| (:embarassed)The bombs didn't detonate.
~ catherine
| (:shout)<-WHAT?!->
~ player
| Come with me to \"Engineering\"(orange).
")
  (:eval
   (ensure-nearby 'bomb-1 'islay)
   :on-complete (q15-start)))