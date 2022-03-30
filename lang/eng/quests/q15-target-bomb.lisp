;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q15-target-bomb)
  :author "Tim White"
  :title "Reactivate the Bomb"
  :description "Islay is working on the other bombs - she needs Catherine and I to go the mushroom cave in the west to reactivate the bomb there."
  :on-activate (bomb-explode)

(bomb-explode
   :title "Help Catherine rewire the bomb in the mushroom cave to the west of the old Dreamscape apartments"
   :invariant (not (complete-p 'epilogue-talk))
   :condition NIL
   :on-complete NIL
   :on-activate (call-explode)

   (:interaction call-explode
    :interactable islay
    :title ""
    :dialogue "
! eval (ensure-nearby 'player 'catherine)
~ islay
| {(nametag player)}, the bomb at the pump room is rewired.
| (:unhappy)I'm soaking wet and freezing, but it's rewired and back underwater.
| (:normal)How'd you get on with the mech? Over.
~ player
- It's no longer a threat. Over.
  ~ islay
  | Good.
- I kicked its ass. Over.
  ~ islay
  | Good.
- It's in pieces. Hopefully there aren't any more. Over.
  ~ islay
  | I've not seen any.
~ islay
| You head for the mushroom cave. I'm heading for the-
~ player
| \"Something cut her off. And what's that sound?\"(light-gray, italic)
~ player
- Islay?
- Is that an earthquake?
- GET DOWN!
! eval (deactivate (unit 'bomb-explode-1))
! eval (deactivate (unit 'bomb-explode-2))
! eval (deactivate (unit 'bomb-explode-3))
! eval (deactivate (unit 'bomb-explode-4))
! eval (activate 'explosion)
")))

;; TODO animate player and catherine force crouching if player chooses "Get down"? (lock player controls early in this case, before epilogue script)