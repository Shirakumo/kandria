;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

;; TODO replace with proper arena boss fight, leashed to this location (preferable) or in a plausibly-enclosed arena
;; TODO fix it so that running away (thus despawning the boss when chunk deletes) doesn't complete the fight - assuming we go with the leash solution and not the enclosed arena
(define-sequence-quest (kandria q10-boss)
  :author "Tim White"
  :title "Destroy the Mech"
  :description "A Wraw mech has activated while I was examining it. I should destroy it before it destroys me."
  (:complete (q10-boss-fight)
   :title "Defeat the robot mech in the Wraw factory"
   "~ player
| ... That's right I'm an android.
| Do your worst.
  ")
  (:wait 1)
  (:interact (NIL :now T)
  "
~ player
? (complete-p (find-task 'q10-wraw 'wraw-warehouse))
| | (:skeptical)\"That's one less mech to worry about. Not that it will make much difference.\"(light-gray, italic)
| | \"I'd better \"get back to Cerebat territory\"(orange) and call this in.\"(light-gray, italic)
| ! eval (complete (find-task 'q10-wraw 'wraw-objective))
| ! eval (activate 'q10a-return-to-fi)
| ! eval (activate (unit 'wraw-border-1))
| ! eval (activate (unit 'wraw-border-2))
|?
| | (:skeptical)\"That's one less mech to worry about. Not that it will make much difference.\"(light-gray, italic)
| | \"I'd better \"finish exploring this region\"(orange). Hopefully there'll be no more surprises.\"(light-gray, italic)
"))