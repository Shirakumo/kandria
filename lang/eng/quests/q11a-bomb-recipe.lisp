;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q11a-bomb-recipe)
  :author "Tim White"
  :title "Bomb Components"
  :description "Islay needs certain components for an improvised explosive, which could slow down the Wraw advance. They can only be found in Wraw territory."
  :variables ((blasting-cap-count 10) (charge-pack-count 20))
  :on-activate (task-reminder task-blasting task-charge task-deliveries task-trigger-move-semis)

 (task-reminder
   :title ""
   :condition (complete-p 'task-return)
   :on-activate T
   :visible NIL

   (:interaction interact-reminder-innis
    :interactable innis
    :title "About the bomb components."
    :repeatable T
    :dialogue "
~ innis
| (:angry)You'd better shake a leg. Altogether Islay needs \"10 blasting caps\"(orange) and \"20 charge packs\"(orange) for the bomb.
| (:sly)Have fun in \"Wraw territory\"(orange).
"))

  (task-blasting
   :title "Collect 10 blasting caps in total"
   :condition (complete-p 'task-deliveries)
   :on-complete NIL)

  (task-charge
   :title "Collect 20 charge packs in total"
   :condition (complete-p 'task-deliveries)
   :on-complete NIL)

 (task-deliveries
   :title "Deliver the components to Islay on the surface"
   :marker '(islay 500)
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
| | Hurry, {(nametag player)} - I still need: [(< 0 (var 'blasting-cap-count)) \"Blasting caps: {(var 'blasting-cap-count)}\"(orange).|] [(< 0 (var 'charge-pack-count)) \"Charge packs: {(var 'charge-pack-count)}\"(orange).]
|?
| ~ islay
| | Good. I'll see these are passed to Catherine and fitted right away.
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
| | Hurry though, {(nametag player)} - I still need: [(< 0 (var 'blasting-cap-count)) \"Blasting caps: {(var 'blasting-cap-count)}\"(orange).|] [(< 0 (var 'charge-pack-count)) \"Charge packs: {(var 'charge-pack-count)}\"(orange).]
"))
  
 ;; move all the Semi Sisters to the surface
 (task-trigger-move-semis
   :title ""
   :condition (or (have 'item:blasting-cap 1) (have 'item:charge-pack 1))
   :on-complete (task-move-semis task-return-fi)
   :visible NIL)

 (task-move-semis
   :title ""
   :condition all-complete
   :on-complete ()
   :on-activate T
   :visible NIL
   (:action functions
    (deactivate (unit 'entity-4686))
    (deactivate (unit 'entity-4687))
    (deactivate (unit 'entity-4688))
    (deactivate (unit 'entity-4689))
    (deactivate (unit 'entity-4690))
    (deactivate (unit 'entity-4691))
    (deactivate (unit 'spawner-5767))
    (activate (unit 'semi-surface-spawner-1))
    (activate (unit 'semi-surface-spawner-2))
    (activate (unit 'semi-surface-spawner-3))
    (activate (unit 'semi-surface-spawner-4))
    (activate (unit 'semi-surface-spawner-5))
    (activate (unit 'bar-surface-spawner-1))
    (ensure-nearby 'semi-surface-spawner-2 'semi-engineer-chief 'semi-engineer-1 'semi-engineer-2 'semi-engineer-3 'semi-engineer-4 'semi-engineer-5)
    (deactivate (find-task 'world 'task-world-engineers))
    (activate (find-task 'world 'task-engineers-surface))
    (setf (location 'islay) (location 'shutter-2))
    (setf (direction 'islay) 1)
    (setf (location 'innis) (location 'shutter-1))
    (setf (direction 'innis) -1)
    (setf (location 'fi) (location 'shutter-3))
    (setf (direction 'fi) -1)
    (setf (location 'jack) (location 'shutter-4))
    (setf (direction 'jack) -1)
    (setf (location 'catherine) 'eng-cath)
    (setf (direction 'catherine) -1)
    ))
;; TODO position islay further from the others - easier to clarify hand-in NPC, and the trials of leadership etc.
;; TODO also deactivate semis world NPC spawners (deletes all Semis NPCs?) and instead activate smaller Semis spawners on surface

  ;; optional dialogue - symbolic that Fi is kinda sidelined now, as Islay takes charge with the bomb. Not adding a marker, since it would trigger a distracting quest arrow while collecting bomb parts
  (task-return-fi
   :title ""
   :visible NIL
   :invariant (not (complete-p 'task-return))
   :condition all-complete
   :on-activate T
   (:interaction fi-return-recruit
    :title "What did I miss?"
    :interactable fi
    :dialogue "
~ fi
| (:happy)Well done with the Semi Sisters.
~ player
- Thanks.
  ~ fi
  | (:happy)I'm glad you're safe.
- Islay did most of the convincing.
  ~ fi
  | Well, she knows Innis the best I suppose.
  | But without you speaking with them, none of this would've happened.
  ~ player
  - I guess I played my part.
    ~ fi
    | (:happy)An important part. And on dangerous roads.
  - Just doing my job.
    ~ fi
    | (:happy)More than that I think. Especially with how dangerous the roads are now.
  - This was your idea though.
    ~ fi
    | Yes, but you had their ear - and took the journey on dangerous roads.
- It was your idea.
  ~ fi
  | Yes, but you had their ear - and took the journey on dangerous roads.
~ fi
| Islay told me everything, about why you couldn't call.
| All things considered, it's surprisingly calm around here.
| (:unsure)Everyone's buying into Islay's story that we can stop the Wraw. I suppose this bomb is a convincing statement.
| (:normal)She's been working Catherine hard to build it, that much I know. (:happy)At least our weapons are ready.
! label questions
~ player
- You don't think we can win?
  ~ fi
  | Islay says we have good numbers. (:unsure)But she also says she doesn't know how many the Wraw are.
  | It doesn't fill me with confidence, bomb or no bomb.
  < questions
- What weapons do we have?
  ~ fi
  | We've got some old, pre-Calamity guns that Catherine and Jack got working. The Semi Sisters have some too, but in better condition.
  | I don't remember the Wraw having anything like that - they're more into swords and spears, so they can watch you die up close.
  | (:unsure)We've also got scythes, shears, and other sharp farming tools.
  | (:happy)And we've got you.
  ~ player
  - I'll do my best.
    ~ fi
    | (:happy)I know you will.
  - You know it.
    ~ fi
    | (:happy)More than most, I think.
  - [(var 'fight-army) I still can't fight an army.| I can't fight an army.]
    ~ fi
    | You might not have to. (:unsure)I think Islay has something special planned for you.
  < questions
- What do you think about the bomb?
  ~ fi
  | It's a bold idea, and it might work.
  | (:unsure)But I can't help but worry about the devastation it might cause to this whole area. To our way of life.
  | Though I suppose the Wraw tearing through us would be even worse...
  | (:normal)And I can't say I'm comfortable having a huge explosive assembled in the middle of our camp.
  < questions
- Who's in charge now?
  ~ fi
  | Islay has the plan, but she's quite diplomatic. (:happy)It feels like a partnership.
  | (:annoyed)I'm not sure Innis sees it that way though.
  < questions
- I have to go.
  ~ fi
  | If you've got \"components for the bomb, take them to Islay\"(orange).
  | We'll talk again soon.
"))

  (task-return
   :title "Return to Islay on the surface and deliver the last of the bomb components"
   :marker '(islay 500)
   :on-complete (q13-intro)
   :on-activate T
   (:interaction components-return
    :title "(Deliver final bomb components)"
    :interactable islay
    :dialogue "
! eval (setf (var 'blasting-cap-count) (- (var 'blasting-cap-count) (item-count 'item:blasting-cap)))
! eval (setf (var 'charge-pack-count) (- (var 'charge-pack-count) (item-count 'item:charge-pack)))
~ islay
| [(>= -3 (+ (var 'blasting-cap-count) (var 'charge-pack-count))) That's the last of the components we needed, and then some! | That's the last of the components we needed.]
| Thank you, {(nametag player)}. \"Here's your payment as promised\"(orange).
? (< 0 (item-count 'item:blasting-cap))
| ! eval (store 'item:parts (* (item-count 'item:blasting-cap) (var 'bomb-fee)))
| ! eval (retrieve 'item:blasting-cap T)
? (< 0 (item-count 'item:charge-pack))
| ! eval (store 'item:parts (* (item-count 'item:charge-pack) (var 'bomb-fee)))
| ! eval (retrieve 'item:charge-pack T)
  
~ islay
| I'll take the parts to Catherine so she can finish the bomb.
| Fi, would you join Catherine and I in Engineering?
~ fi
| If you insist.
| And what about {(nametag player)}? Since she's the one that brought us together - and brought the components for your bomb.
~ islay
| I was about to add... could you join us as well, {(nametag player)}? This concerns you.
| Innis, keep an eye on things here.
~ innis
| (:angry)Aye, alright.
! eval (complete task)
! eval (reset* interaction)
! eval (activate 'q13-intro)
! eval (clear-pending-interactions)
")))
