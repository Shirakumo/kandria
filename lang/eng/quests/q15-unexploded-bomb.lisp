;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q15-unexploded-bomb)
  :author "Tim White"
  :title "Find Islay at the Bomb Sites"
  :description "I need to go with Catherine to find Islay at the bomb sites, to help her figure out why the bombs didn't detonate. I should be wary of Wraw soldiers."
  :on-activate (task-reminder check-bomb-1 check-bomb-2 check-bomb-3 islay-person)
  
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
   :title "Look for Islay at the bomb on the low eastern border, east of the Rootless hospital apartments and below the old Semi factory"
   :marker '(chunk-2041 1400)
   :invariant T
   :condition all-complete
   :on-activate (interact-bomb)

   (:interaction interact-bomb
    :interactable bomb-1
    :dialogue ""))
    
  (check-bomb-2
   :title "Look for Islay at the bomb in the flooded room beside the pump room"
   :marker '(chunk-2482 1600)
   :invariant T
   :condition all-complete
   :on-activate (interact-bomb)

   (:interaction interact-bomb
    :interactable bomb-2
    :dialogue ""))
    
 (check-bomb-3
   :title "Look for Islay at the bomb in the mushroom cave to the west of the old Dreamscape apartments"
   :marker '(chunk-1979 2400)
   :invariant T
   :condition all-complete
   :on-activate (interact-bomb)

   (:interaction interact-bomb
    :interactable bomb-3
    :dialogue ""))

  (islay-person
   :title "We're here to help."
   :visible NIL
   :invariant T
   :condition all-complete
   :on-complete (q15-boss)
   :on-activate (islay-talk-bomb)

   (:interaction islay-talk-bomb
    :title "We're here to help."
    :interactable islay
    :dialogue "
! eval (ensure-nearby 'player 'catherine)
~ catherine
| (:concerned)Islay, you're soaking wet.
~ islay
| (:nervous)Dammit... You shouldn't have come. I can handle this.
~ player
- Let us help.
  ~ catherine
  | We can do this together. (:excited)And save time.
- We're more efficient together.
  ~ catherine
  | (:excited)Right. What she said.
- The hell you can.
  ~ catherine
  | (:concerned){(nametag player)}'s right. Let us help you.
~ islay
| (:unhappy)...
| This is the \"bomb from the flooded room - (:unhappy)it's been defused\"(orange)...
| (:nervous)But I think \"I can rewire its receiver\"(orange).
| (:normal)I think they've got a \"bomb defusal mech\"(orange) - I saw \"one heading towards the pump room\"(orange).
| Since you're here now you can \"destroy the mech\"(orange).
| Do that \"then go to the bomb in the mushroom cave to the west. Catherine, you can rewire it\"(orange).
~ catherine
| (:excited)Got it.
~ islay
| (:nervous)\"I'll go to the one beneath the old Semi factory.\"(orange)
| (:normal)And {(nametag player)}, for what it's worth: I don't think you're a traitor.
| Now, please: I need to work.
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
- You'll never get through there on your own.
  ~ catherine
  | What do you mean?
  ~ player
  | The mushroom cave is a labyrinth - even I can only make it through with my thrusters.
  ~ catherine
  | (:concerned)Then how can I rewire the bomb?
  ~ player
  | (:embarassed)We'll figure it out.
~ catherine
| Okay. Let's go together - \"after the mech\"(orange).
! eval (complete 'check-bomb-1 'check-bomb-2 'check-bomb-3)
! eval (deactivate 'task-reminder)
! eval (activate (unit 'q15-boss-fight))
! eval (clear-pending-interactions)
")))