;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria q15-boss)
  :author "Tim White"
  :title "Destroy the Bomb Defusal Mechs"
  :description "Islay thinks Wraw mechs are defusing the bombs. I must stop them."
  (:go-to (q15-boss-loc)
    :title "Destroy the bomb defusal mechs in the Zenith Hub")
  (:eval
   (stop-following 'catherine)
   (move-to 'catherine-boss (unit 'catherine))
   (override-music 'battle))
  (:complete (q15-boss-fight)
   :title "Destroy the bomb defusal mechs in the Zenith Hub"
   "~ player
| Stay back Catherine.
~ catherine
| Holy shit!
  ")
  (:eval
   (override-music NIL))
  (:wait 1)
  (:eval
   (move-to 'player 'catherine))
  (:go-to (catherine)
   :title "Return to Catherine in the Zenith Hub")
  (:interact (catherine :now T)
  "
~ catherine
| (:concerned)Are you okay? (:excited)That was incredible.
~ player
- I had it under control.
  ~ catherine
  | (:excited)I could tell.
- That was harder than I expected.
  ~ catherine
  | Well it's all over now. (:concerned)Assuming there aren't any more.
- I need a vacation.
  ~ catherine
  | (:excited)Me too! Somewhere without sand or killer robots.
~ catherine
| Alright, let's \"get to that mushroom cave to the west\"(orange) and \"see about that bomb\"(orange).
! eval (follow 'player 'catherine)
! eval (activate 'q15-target-bomb)
! eval (activate (unit 'bomb-explode-1))
! eval (activate (unit 'bomb-explode-2))
! eval (activate (unit 'bomb-explode-3))
! eval (activate (unit 'bomb-explode-4))
"))
