;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria q10-boss)
  :author "Tim White"
  :title "Destroy the Mech"
  :description "A Wraw mech has activated while I was examining it."
  (:eval
   (override-music 'battle))
  (:complete (q10-boss-fight)
   :title "Defeat the mech"
   "~ player
| (:giggle)... Oh, hello.
  ")
  (:eval
   (override-music NIL))
  (:wait 1)
  (:interact (NIL :now T)
  "
~ player
? (complete-p (find-task 'q10-wraw 'wraw-warehouse))
| | \"That's one less mech to worry about. Not that it will make much difference.\"(light-gray, italic)
| | \"I need to \"contact Fi\"(orange).\"(light-gray, italic)
| | \"... \"FFCS can't punch through\"(orange) - whether it's magnetic interference from the magma, or the Wraw themselves I'm not sure.\"(light-gray, italic)
| | \"I'd better \"get out of here\"(orange) and \"deliver my report\"(orange).\"(light-gray, italic)
| ! eval (complete (find-task 'q10-wraw 'wraw-objective))
| ! eval (activate 'q10a-return-to-fi)
| ! eval (activate (unit 'wraw-border-1))
| ! eval (activate (unit 'wraw-border-2))
| ! eval (activate (unit 'wraw-border-3))
| ! eval (activate (unit 'station-east-lab-trigger))
| ! eval (activate (unit 'station-cerebat-trigger))
| ! eval (activate (unit 'station-semi-trigger))
| ! eval (activate (unit 'station-surface-trigger))
|?
| | \"That's one less mech to worry about. Not that it will make much difference.\"(light-gray, italic)
| | \"I'd better \"finish exploring this region\"(orange). Hopefully there'll be no more surprises.\"(light-gray, italic)
"))