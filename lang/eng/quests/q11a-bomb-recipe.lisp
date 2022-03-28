;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q11a-bomb-recipe)
  :author "Tim White"
  :title "Bomb Recipe"
  :description "Islay needs certain components to assemble an improvised explosive, which could slow down the Wraw advance."
  :variables ((blasting-cap-count 10) (charge-pack-count 20))
  :on-activate (task-reminder task-deliveries task-border)

 (task-reminder
   :title ""
   :on-activate T
   :visible NIL

   (:interaction interact-reminder-innis
    :interactable innis
    :title "About the bomb components."
    :repeatable T
    :dialogue "
~ innis
| You'd better shake a leg. Altogether Islay needs \"10 blasting caps\"(orange) and \"20 charge packs\"(orange) for the bomb.
"))

 (task-deliveries
   :title "Search Wraw territory for 10 blasting caps and 20 charge packs, then return to Islay on the surface"
   :on-activate T
   :condition (and (>= 0 (- (var 'blasting-cap-count) (item-count 'item:blasting-cap))) (>= 0 (- (var 'charge-pack-count) (item-count 'item:charge-pack))))
   :on-complete (task-return)
   :on-activate T
   (:interaction interact-islay
    :interactable islay
    :title "(Deliver bomb components)"
    :repeatable T
    :dialogue "
~ islay
| Did you get the components for the bomb?
? (= 0 (+ (item-count 'item:blasting-cap) (item-count 'item:charge-pack)))
| ~ islay
| | Hurry, {#@player-nametag} - I still need: [(< 0 (var 'blasting-cap-count)) \"blasting caps: {(var 'blasting-cap-count)}\"(orange) |] [(< 0 (var 'charge-pack-count)) ; \"charge packs: {(var 'charge-pack-count)}\"(orange)].
|?
| ~ islay
| | Ah, good. I'll see these are passed to Catherine and installed right away.
| | \"Here's your payment.\"(orange)
| ? (< 0 (item-count 'item:blasting-cap))
| | ! eval (setf (var 'blasting-cap-count) (- (var 'blasting-cap-count) (item-count 'item:blasting-cap)))
| | ! eval (store 'item:parts (* (item-count 'item:blasting-cap) (var 'bomb-fee)))
| | ! eval (retrieve 'item:blasting-cap T)
| ? (< 0 (item-count 'item:charge-pack))
| | ! eval (setf (var 'charge-pack-count) (- (var 'charge-pack-count) (item-count 'item:charge-pack)))
| | ! eval (store 'item:parts (* (item-count 'item:charge-pack) (var 'bomb-fee)))
| | ! eval (retrieve 'item:charge-pack T)
|  
| | Hurry though, {#@player-nametag} - I still need: [(< 0 (var 'blasting-cap-count)) \"blasting caps: {(var 'blasting-cap-count)}\"(orange) |] [(< 0 (var 'charge-pack-count)) ; \"charge packs: {(var 'charge-pack-count)}\"(orange)].
"))

  ;; TODO this stops the player when they hit the trigger? Need to find another way
 (task-border
   :title ""
   :on-activate T
   :visible NIL

   ;; move all the Semis to the surface
   ;; TODO move all Semis world NPCs to the surface when we have them
   (:interaction wraw-border
    :interactable NIL
    :dialogue "
! eval (setf (location 'islay) (location 'shutter-2))
! eval (setf (location 'innis) (location 'shutter-1))
! setf (direction 'islay) 1
! setf (direction 'innis) -1
! eval (setf (location 'fi) (location 'shutter-3))
! eval (setf (location 'jack) (location 'shutter-4))
! setf (direction 'fi) -1
! setf (direction 'jack) -1
! eval (setf (location 'catherine) 'eng-cath)
! setf (direction 'catherine) -1
! eval (deactivate (unit 'wraw-border-1))
! eval (deactivate (unit 'wraw-border-2))
! eval (activate 'task-return-fi)
? (complete-p (find-task 'q12-help-alex 'alex-task))
| ! eval (activate (find-task 'q12-help-alex 'fi-task))
"))
;; TODO position islay further from the others - easier to clarify hand-in NPC, and the trials of leadership etc.
;; if you've already spoken to alex in q12, then when you cross the border, activate the fi return task, since it's now safe to talk to her about alex, as she will be on the surface with the others
;; TODO also need to move semi engineers (and other world NPCs?) to surface, and change the status of their world-state quest(s) so they can no longer be spoken too / updated dialogue

  ;; optional dialogue - symbolic that Fi is kinda sidelined now, as Islay takes charge with the bomb
  (task-return-fi
   :title ""
   :visible NIL
   :on-activate T
   (:interaction fi-return-recruit
    :title "What did I miss?"
    :interactable fi
    :dialogue "
~ fi
| (:happy)Welcome back, and well done with the Semi Sisters.
~ player
- Thanks.
  ~ fi
  | (:happy)I'm glad you're safe.
- Islay did most of the convincing.
  ~ fi
  | Well, she knows Innis the best I suppose.
  | But without you going and speaking with them, none of this would've happened.
  ~ player
  - I guess I played my part.
    ~ fi
    | (:happy)An important part.
  - Just doing my job.
    ~ fi
    | (:happy)It's not more to you than that?
  - This was your idea though.
    ~ fi
    | Yes, but you had their ear - and took the journey to reach them on dangerous roads.
- It was your idea.
  ~ fi
  | Yes, but you had their ear - and took the journey to reach them on dangerous roads.
~ fi
| Islay told me everything by the way, and why you couldn't call.
| All things considered, things are surprisingly calm around here.
| (:unsure)Everyone's buying into Islay's story that we can defeat the Wraw. I suppose this bomb is a convincing statement.
| (:normal)She's had Catherine working on it for a while, that much I know. At least our weapons are ready.
! label questions
~ player
- You don't think we can win?
  ~ fi
  | Islay says we have the numbers. (:unsure)But she also says she doesn't know how many the Wraw are.
  | It doesn't fill me with confidence, bomb or no bomb.
  < questions
- What weapons do we have?
  ~ fi
  | We've got some old, pre-Calamity guns that Catherine and Jack managed to get working. The Semi Sisters have some too, but in better condition.
  | I don't remember the Wraw having anything like that - they're more into swords and spears, so they can watch you die up close.
  | We've also got scythes, shears, and other sharp farming tools.
  | (:happy)And we've got you.
  ~ player
  - I'll do my best.
    ~ fi
    | (:happy)I know you will.
  - You know it.
    ~ fi
    | (:happy)More than most, I think.
  - [(var 'fight-army) I still can't fight an army. | I can't fight an army.]
    ~ fi
    | You might not have to. I think Islay has something special planned for you.
  < questions
- What do you think about the bomb?
  ~ fi
  | It's a bold idea, and it might work.
  | (:thinking)But I can't help but worry about the devastation it might cause to this whole area. To our way of life.
  | (:unsure)And I can't say I'm comfortable having a huge explosive assembled in the middle of our camp. 
  < questions
- Who's in charge now?
  ~ fi
  | Islay has the plan, but she's quite diplomatic. It feels like a partnership between me, Islay, and Innis.
  | (:happy)I'm not so sure Innis sees it that way though.
  < questions
- I have to go.
  ~ fi
  | If you've got \"components for the bomb, I'd get them to Islay ASAP\"(orange).
  | We'll talk again soon.
"))

  (task-return
   :title "Return to Islay on the surface and deliver the bomb components"
   :on-complete (q13-intro)
   :on-activate T
   (:interaction components-return
    :title "(Deliver bomb components)"
    :interactable islay
    :repeatable T
    :dialogue "
! eval (setf (var 'blasting-cap-count) (- (var 'blasting-cap-count) (item-count 'item:blasting-cap)))
! eval (setf (var 'charge-pack-count) (- (var 'charge-pack-count) (item-count 'item:charge-pack)))
~ islay
| [(> -5 (+ (var 'blasting-cap-count) (var 'charge-pack-count))) (:happy)That's the last of the components we needed, and then some! | (:happy)That's the last of the components we needed.]
| Thank you, {#@player-nametag}. \"Here's your payment as promised\"(orange).
? (< 0 (item-count 'item:blasting-cap))
| ! eval (store 'item:parts (* (item-count 'item:blasting-cap) (var 'bomb-fee)))
| ! eval (retrieve 'item:blasting-cap T)
? (< 0 (item-count 'item:charge-pack))
| ! eval (store 'item:parts (* (item-count 'item:charge-pack) (var 'bomb-fee)))
| ! eval (retrieve 'item:charge-pack T)
  
| (:normal)I'll take the parts to Catherine so she can complete the bomb.
| Fi, would you join Catherine and I in Engineering?
~ fi
| If you insist.
| And what about {#@player-nametag}? Since she's the one that brought us together - and brought the components for your bomb.
~ islay
| I was about to add... could you join us as well, {#@player-nametag}. This concerns you.
| Innis, keep an eye on things here.
~ innis
| Aye, alright.
! eval (complete task)
! eval (setf (quest:status (thing 'task-return)) :inactive)
! eval (deactivate interaction)
! eval (deactivate 'task-return-fi)
! eval (deactivate 'task-reminder)
! eval (complete 'q12-help-alex)
! eval (activate 'q13-intro)
")))
;; TODO need to space fi, catherine, islay further apart here, for different chats once q13 starts