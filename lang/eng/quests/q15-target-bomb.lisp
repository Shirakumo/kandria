;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q15-target-bomb)
  :author "Tim White"
  :title "Rewire the Bomb"
  :description "Islay is working on the other bomb - she needs Catherine and I to go the mushroom cave in the west and reactivate the bomb there."
  :on-activate (bomb-explode)

  (bomb-explode
   :title "Help Catherine rewire the bomb in the mushroom cave to the west of the old Dreamscape apartments"
   :marker '(chunk-1979 2400)
   :invariant (not (complete-p 'epilogue-talk))
   :condition NIL
   :on-complete NIL
   :on-activate (call-explode)

   (:interaction call-explode
    :interactable player
    :title ""
    :dialogue "
! eval (ensure-nearby 'player 'catherine)
~ islay
| {(nametag player)}, Catherine - the \"bomb beneath the old Semi factory is rewired\"(orange).
| (:normal)How'd you get on with that mech? Over.
~ player
- It's no longer a threat. Over.
  ~ islay
  | Good.
- I kicked its ass. Over.
  ~ islay
  | Good.
- Scratch one mech. Hopefully there aren't any more. Over.
  ~ islay
  | I've not seen any.
~ islay
| You \"head for the mushroom cave\"(orange). I'm heading for the-
~ player
| \"Something cut her off. What's that sound?\"(light-gray, italic)
~ player
- Islay?
- Is that an earthquake?
- GET DOWN!
! eval (deactivate (unit 'bomb-explode-1))
! eval (activate 'explosion)
! eval (move :freeze player)
")))

;; TODO animate player and catherine force crouching if player chooses "Get down"? (lock player controls early in this case, before epilogue script)