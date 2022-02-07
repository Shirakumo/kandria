;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q15-target-bomb)
  :author "Tim White"
  :title "Rewire the Bomb"
  :description "Islay is working on the other bombs - she needs Catherine and I to go the mushroom cave in the west to reactivate the bomb there."
  :on-activate (bomb-explode)

(bomb-explode
   :title "Help Catherine rewire the bomb in the mushroom cave to the west of the old Dreamscape apartments"
   :invariant T
   :condition all-complete
   :on-complete (epilogue)

   (:interaction call-explode
    :interactable islay
    :title ""
    :dialogue "
~ islay
| {#@player-nametag}, the bomb at the pump room is rewired.
| I've planted it back underwater. How'd you get on with the mech? Over.
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
! eval (activate 'epilogue)
")))