;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

;; TODO replace with proper arena boss fight, leashed to this location (preferable) or in a plausibly-enclosed arena
;; TODO fix it so that running away (thus despawning the boss when chunk deletes) doesn't complete the fight - assuming we go with the leash solution and not the enclosed arena
(define-sequence-quest (kandria q15-boss)
  :author "Tim White"
  :title "Destroy the Bomb Defusal Mech"
  :description "Islay believes a Wraw mech is defusing the bombs. I must destroy it."
  (:eval 
   (move-to 'catherine-boss (unit 'catherine)))
  (:complete (q15-boss-fight)
   :title "Defeat the bomb defusal mech in the Zenith Hub"
   "~ player
| Stay back Catherine.
~ catherine
| (:shout)Smash it!
  ")
  (:wait 1)
  (:interact (player :now T)
  "
~ catherine
| (:concerned)Are you okay? (:excited)That was incredible.
~ player
- I had it under control.
  ~ catherine
  | I could tell.
- That was a harder fight than I expected.
  ~ catherine
  | Well it's all over now. (:concerned)Assuming there's only one of them...
- When this is all over I'm taking a vacation.
  ~ catherine
  | (:excited)Me too! Somewhere without any sand or killer robots.
~ catherine
| Alright, let's \"get to that mushroom cave in the west\"(orange)and see about that bomb.
! eval (activate 'bomb-explode-1)
! eval (activate 'bomb-explode-2)
! eval (activate 'bomb-explode-3)
"))
