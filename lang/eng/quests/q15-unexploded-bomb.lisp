;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q15-unexploded-bomb)
  :author "Tim White"
  :title "Check the Bombs"
  :description "I need to go with Catherine to find Islay at the bomb sites, to help her figure out why the bombs didn't detonate. I should be wary of Wraw soldiers."
  :on-activate (task-reminder bomb-check-1 bomb-check-2 bomb-check-3 call-bomb)
  
  (task-reminder
   :title ""
   :visible NIL
   :invariant T
   :condition all-complete
   :on-activate (interact-fi)

   (:interaction interact-fi
    :interactable fi
    :title ""
    :repeatable T
    :dialogue "
~ fi
| Hurry - \"find Islay and fix those bombs\"(orange).
"))

 (check-bomb-1
   :title "Check the bomb on the low-eastern border, east of the Rootless apartments and below the old Semi factory"
   :invariant T
   :condition all-complete
   :on-activate (interact-bomb)

   (:interaction interact-bomb
    :interactable bomb-1
    :dialogue ""))
    
  (check-bomb-2
   :title "Check the bomb in the flooded room beside the pump room"
   :invariant T
   :condition all-complete
   :on-activate (interact-bomb)

   (:interaction interact-bomb
    :interactable bomb-2
    :dialogue ""))
    
 (check-bomb-3
   :title "Check the bomb in the mushroom cave to the west of the old Dreamscape apartments"
   :invariant T
   :condition all-complete
   :on-activate (interact-bomb)

   (:interaction interact-bomb
    :interactable bomb-3
    :dialogue ""))

  (call-bomb
   :title ""
   :visible NIL
   :invariant T
   :condition all-complete
   :on-activate (islay-call)

   (:interaction islay-call
    :interactable islay
    :dialogue "
~ islay
| Does anyone read me, over?
~ player
- I do: It's {#@player-nametag}. Over.
  ~ islay
  | (:nervous)You shouldn't have come. I can handle it. Over.
  ~ player
  | Catherine's with me. We can help. Over.
  ~ islay
  | (:unhappy)Dammit Fi...
- Islay, I'm here with Catherine. Over.
  ~ islay
  | {#@player-nametag}? (:nervous)Dammit... I can handle it. You shouldn't have come.
- Islay, where are you? Over.
  ~ islay
  | {#@player-nametag}? (:nervous)Dammit... I can handle it. You shouldn't have come.
~ islay
| Look, I've recovered the bomb from the flooded room - it's been been tampered with.
| They've got some kind of bomb defusal mech - I saw it \"heading towards the Zenith Hub.\"(orange)
| I think I can rewire the receiver on this one.
| But you need to \"destroy that mech\"(orange) - I don't know if it already got to the other bombs yet; it probably did, given they didn't blow.
| \"Once it's down, proceed to the bomb in the mushroom cave to the west.\"(orange) I'll go to the one beneath the old Semi factory.
| (:nervous)Good luck - over and out.
~ catherine
| I can go to the other bomb while you take care of the mech.
~ player
- We should stick together.
  ~ catherine
  | (:concerned)... But I can do it.
  ~ player
  | I know you can, but if you don't make it to the bomb, we're in trouble.
  ~ catherine
  | (:concerned)...
- Getting yourself killed won't help us.
  ~ catherine
  | (:concerned)...
  | I suppose not.
- You'll never get through that area.
  ~ catherine
  | What do you mean?
  ~ player
  | The cave is a labyrinth - I can only just make it through with my thrusters.
  ~ catherine
  | (:concerned)Then how will I be able to rewire the bomb?
  ~ player
  | (:embarassed)You'll have to talk me through how to do it first.
~ catherine
| Okay. Let's go together - after the mech.
! eval (activate 'bomb-explode)
! eval (activate (unit 'bomb-explode-1))
! eval (activate (unit 'bomb-explode-2))
! eval (activate (unit 'bomb-explode-3))
! eval (activate (unit 'bomb-explode-4))
"))

(bomb-explode
   :title ""
   :visible NIL
   :invariant T
   :condition all-complete
   :on-complete (epilogue)

   (:interaction call-bomb
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