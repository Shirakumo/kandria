;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q15-unexploded-bomb)
  :author "Tim White"
  :title "Check the Bombs"
  :description "I need to go with Catherine to find Islay at the bomb sites, to help her figure out why the bombs didn't detonate. I should be wary of Wraw soldiers."
  :on-activate (task-reminder check-bomb-1 check-bomb-2 check-bomb-3 islay-call)
  
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
   :title "Check the bomb on the low eastern border, east of the Rootless hospital apartments and below the old Semi factory"
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

  (islay-call
   :title ""
   :visible NIL
   :invariant T
   :condition all-complete
   :on-complete (q15-boss)
   :on-activate (islay-call-bomb)

   (:interaction islay-call-bomb
    :interactable islay
    :dialogue "
! eval (ensure-nearby 'player 'catherine)
~ player
| \"Okay, this should do. Let's find out where she is.\"(light-gray, italic)
~ player
- Islay this is {(nametag player)}. Over.
  ~ islay
  | (:nervous)You shouldn't have come. I can handle it. Over.
  ~ player
  | Catherine's with me. We can help. Over.
  ~ islay
  | (:unhappy)Dammit Fi...
- Islay, I'm here with Catherine. Over.
  ~ islay
  | {(nametag player)}? (:nervous)Dammit... I can handle it. You shouldn't have come.
- Islay, where are you? Over.
  ~ islay
  | {(nametag player)}? (:nervous)Dammit... I can handle it. You shouldn't have come.
  ~ player
  | Catherine's with me. We can help. Over.
~ islay
| Look, I've recovered the bomb from the flooded room - it's been been tampered with.
| They've got some kind of bomb defusal mech - I saw it \"heading towards the Zenith Hub.\"(orange)
| I think I can rewire the receiver on this one.
| Since you're here you can \"destroy that mech\"(orange).
| \"Then go to the bomb in the mushroom cave to the west - have Catherine rewire it.\"(orange) She'll know what to do.
| I'll go to the one beneath the old Semi factory.
| (:nervous)Good luck - over and out.
~ catherine
| I can go to the mushroom cave while you take care of the mech.
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
  | The mushroom cave is a labyrinth - even I can only make it through with my thrusters.
  ~ catherine
  | (:concerned)Then how can I rewire the bomb?
  ~ player
  | (:embarassed)We'll figure it out.
~ catherine
| Okay. Let's go together - after the mech.
! eval (complete 'check-bomb-1 'check-bomb-2 'check-bomb-3)
! eval (deactivate 'task-reminder)
! eval (deactivate (unit 'islay-bomb-1))
! eval (deactivate (unit 'islay-bomb-2))
! eval (deactivate (unit 'islay-bomb-3))
! eval (deactivate (unit 'islay-bomb-4))
! eval (deactivate (unit 'islay-bomb-5))
")))