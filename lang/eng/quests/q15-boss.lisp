;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria q15-boss)
  :author "Tim White"
  :title "Destroy the Bomb Mech"
  :description "Islay thinks a Wraw mech is defusing the bombs. I must stop it."
  (:eval
   (move-to 'catherine-boss (unit 'catherine)))
  (:go-to (q15-boss-loc)
    :title "Destroy the bomb defusal mech in the pump room")
  (:eval
   (override-music 'battle))
  (:complete (q15-boss-fight)
   :title "Destroy the bomb defusal mech in the pump room"
   "~ player
| Stay back Catherine.
~ catherine
| Holy shit!
  ")
  (:eval
   (override-music NIL))
  (:wait 1)
  (:eval
   (setf (location 'islay) (location 'islay-bomb-1-loc))
   (setf (direction 'islay) -1)
   (move-to 'player 'catherine))
  (:go-to (catherine)
   :title "Return to Catherine in the pump room")
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
| \"Islay rewired the bomb and put it back in the flooded room.\"(orange)
| Now she's gone to the one beneath the old Semi factory.
| (:excited)We should \"get to the mushroom cave in the west and see about that last bomb\"(orange).
| She's counting on us.
! eval (follow 'player 'catherine)
! eval (activate 'q15-target-bomb)
! eval (activate (unit 'bomb-explode-1))
! eval (activate (unit 'bomb-explode-2))
"))
