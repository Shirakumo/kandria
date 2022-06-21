;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q5a-rescue-engineers)
  :author "Tim White"
  :title "Rescue Engineers"
  :description "Semi Sisters engineers are stuck in a collapsed rail tunnel in the far upper-west of their territory. I can help while Islay talks to Alex."
  :on-activate (task-reminder task-wall task-engineers)
  :variables (engineers-intro)
 
 (task-reminder
   :title NIL
   :visible NIL
   :condition (complete-p 'task-return-engineers)
   :on-activate T
   (:interaction reminder
    :title "(Engineers reminder)"
    :interactable innis
    :repeatable T
    :dialogue "
~ innis
| (:angry)You forgot already? (:normal)\"Find the engineers\"(orange) in the collapsed rail tunnel, do what you can for them, and report back.
| It's in the \"far upper-west of our territory\"(orange).
"))

  (task-wall
   :title NIL
   :visible NIL
   :condition (not (active-p (unit 'blocker-engineers)))
   :on-complete (q5a-engineers-return))

;; TODO Semi Engineers nametag completion doesn't update live on next chat line, though does in next convo selected. Worth fixing?
  (task-engineers
   :title "Find the trapped engineers and check that they're okay"
   :marker '(chunk-5676 1200)
   :condition (complete-p 'task-return-engineers)
   :on-activate T   
   (:interaction engineers
    :interactable semi-engineer-chief
    :title ""
    :dialogue "
? (not (var 'engineers-intro))
| ~ player
| | Innis sent me. Are you the missing Semis engineers?
| ! eval (setf (var 'engineers-intro) T)
? (active-p (unit 'blocker-engineers))
| ? (not (var 'engineers-first-talk))
| | ~ semi-engineer-chief
| | | How in God's name did you get in here?
| | ~ player
| | | There's a tunnel above this shaft - though it's not something a human could navigate.
| | ~ semi-engineer-chief
| | | ... A //human//? So you're...
| | ~ player
| | - Not human, yes.
| |   ~ semi-engineer-chief
| |   | ... An android, as I live and breathe.
| | - An android.
| |   ~ semi-engineer-chief
| |   | ... As I live and breathe.
| | - What are you doing in here?
| | ~ semi-engineer-chief
| | | \"We're the engineers you're looking for\"(orange). Thank God for Innis.
| | ! eval (setf (nametag (unit 'semi-engineer-chief)) (@ semi-engineer-nametag))
| | ~ semi-engineer-chief
| | | The tunnel collapsed; we lost the chief and half the company.
| | | We \"can't break through\"(orange) - can you? Can androids do that?
| | | \"The collapse is just ahead.\"(orange)
| | ! eval (setf (var 'engineers-first-talk) T)
| | ! eval (activate 'task-wall-location)
| |?
| | ~ semi-engineer-chief
| | | How'd it go with the \"collapsed wall\"(orange)? We can't stay here forever.
| | ! eval (activate 'task-wall-location)
|?
| ? (not (var 'engineers-first-talk))
| | ~ semi-engineer-chief
| | | Who are you? How did you break through the collapsed tunnel?
| | ~ player
| | - I'm... not human.
| |   ~ semi-engineer-chief
| |   | ... An android, as I live and breathe.
| | - I'm an android.
| |   ~ semi-engineer-chief
| |   | ... As I live and breathe.
| | - What are you doing in here?
| | ~ semi-engineer-chief
| | | \"We're the engineers you're looking for\"(orange). Thank God for Innis.
| | ! eval (setf (nametag (unit 'semi-engineer-chief)) (@ semi-engineer-nametag))
| | ~ semi-engineer-chief
| | | We lost the chief and half the company when the tunnel collapsed.
| | | But things are looking up now the route is open.
| | | Thank you.
| | ! eval (setf (var 'engineers-first-talk) T)
| |?
| | ~ semi-engineer-chief
| | | I can't believe you got through... Now food and medical supplies can get through too. Thank you.
| | | We can resume our excavations. It'll be slow-going, but we'll get it done.
  
! eval (reset (find-task 'world 'task-world-engineers))
! eval (activate (find-task 'world 'task-world-engineers))
! eval (complete task)
"))

  (task-wall-location
   :title "Clear the collapsed tunnel to free the engineers"
   :marker '(chunk-6034 2200)
   :condition (not (active-p (unit 'blocker-engineers)))
   :on-complete NIL)

  (task-return-engineers
   :title "Return to Innis in the Semi Sisters control room"
   :marker '(innis 500)
   :condition NIL
   :on-activate T
   (:interaction return-engineers
    :title "(Report on the engineers)"
    :interactable innis
    :repeatable T
    :dialogue "
~ innis
| The hurt engineers are already on their way back - I've sent hunters to guide them.
? (complete-p 'task-engineers)
| | They appreciated you checking in on them as well - thank you.
|?
| | (:angry)A shame you didnae speak to them though - they could have really used someone to talk to, to let them know what was happening.
  
~ innis
| It's tough that we lost people, but sometimes that's the price of progress. I'll get Islay to notify their families.
| More importantly: How did you clear that debris? Is there something I dinnae ken about androids?
~ player
- I found a weak point and pushed.
  ~ innis
  | That sounds plausible. (:sly)Your fusion reactor would generate the necessary force, and your nanotube muscles could withstand the impact.
- I cut through with my sword.
  ~ innis
  | I believe you did. Your fusion reactor would generate the necessary force, and your nanotube muscles could withstand the impact.
  | (:sly)Not to mention the inherent strength of your Artemis blade.
- (Lie) I pulled a hidden lever and said, \"Open sesame!\"
  ~ innis
  | (:angry)...
  | Funny. (:sly)I suspect it has more to do with your formidable combination of fusion reactor and nanotube muscles.
- Wouldn't you like to know.
  ~ innis
  | (:sly)I would indeed. Dinnae worry, things dinnae remain secret 'round here very long.
  | I expect the combination of fusion reactor and nanotube muscles makes you quite formidable.
~ innis
| This does mean our engineering works are back on schedule. With that in mind...
| My sister, in her infinite wisdom, thought it might be a nice gesture if we-... (:angry)well, //if I// officially grant you access to the metro.
| ... In the interests of good relations, between the Semi Sisters and yourself.
| (:normal)It'll certainly \"speed up your errands - once you've found the other stations\"(orange).
? (or (unlocked-p (unit 'station-surface)) (unlocked-p (unit 'station-east-lab)) (unlocked-p (unit 'station-semi-sisters)) (unlocked-p (unit 'station-cerebats)) (unlocked-p (unit 'station-wraw)))
| | (:sly)You ken about the metro already. But now it's official. I'll send out word so you won't be... apprehended.
| | (:normal)\"The stations run throughout the valley\"(orange). Though \"no' all are operational\"(orange) while we expand the network.
|?
| | (:normal)\"They run throughout the valley\"(orange), though \"no' all are operational\"(orange) while we expand the network.
| | Just \"choose your destination from the route map\"(orange) and board the train.
? (not (unlocked-p (unit 'station-semi-sisters)))
| | (:normal)\"Our station is beneath this central block.\"(orange)
| ! eval (activate 'semi-station-marker)
|?
| ! eval (complete 'semi-station-marker)
? (complete-p 'q5b-investigate-cctv)
| ~ innis
| | You've proven your worth to us. I might have to call on your services again.
| | But now you should \"return to Fi\"(orange).
| | It's a pity you couldnae persuade Alex to come home. (:sly)I'd love to see the look on Fi's face when you tell her.
| | I suppose androids canna do everything.
| | (:angry)And tell her \"we want Catherine back\"(orange) too. We need her now more than ever.
| | (:sly)If she disagrees tell her I'll \"shut the water off\"(orange).
| ! eval (activate 'q6-return-to-fi)
| ! eval (activate (unit 'fi-ffcs-1))
| ! eval (activate (unit 'fi-ffcs-2))
|?
| ~ innis
| | I'll be seeing you.
? (not (active-p (find-task 'world 'task-world-engineers)))
| ! eval (activate (find-task 'world 'task-world-engineers))
  
! eval (complete task)
! eval (reset* interaction)
")))
;; dinnae = don't (Scots)
;; didnae = didn't (Scottish)
;; ken = know (Scots)
;; couldnae = couldn't (Scots)
;; canna = cannot (Scottish)