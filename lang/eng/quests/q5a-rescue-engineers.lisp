;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q5a-rescue-engineers)
  :author "Tim White"
  :title "Rescue Engineers"
  :description "Semi Sisters engineers are stuck in a collapsed rail tunnel in the upper-west of their territory. I can help while Islay talks to Alex."
  :on-activate (task-reminder task-engineers task-return-engineers)
 
 (task-reminder
   :title NIL
   :visible NIL
   :condition (complete-p 'task-return-engineers)
   :on-activate T
   (:interaction reminder
    :title "Remind me about the trapped engineers."
    :interactable innis
    :repeatable T
    :dialogue "
~ innis
? (active-p (unit 'blocker-engineers))
| | (:angry)You forgot already? (:normal)\"Find the engineers\"(orange) in the collapsed rail tunnel, do what you can for them, and report back.
| | It's in the \"upper-west of our territory\"(orange).
|?
| | (:sly)There's news on the engineers - care to \"deliver your report\"(orange)?
"))

;; TODO Semi Engineers nametag completion doesn't update live on next chat line, though does in next convo selected. Worth fixing?
  (task-engineers
   :title "Find the trapped engineers"
   :marker '(semi-engineer-mark 2500)
   :condition (complete-p 'task-return-engineers)
   :on-activate T   
   (:interaction engineers
    :interactable semi-engineer-chief
    :title "Innis sent me. Are you the Semis engineers?"
    :dialogue "
? (active-p (unit 'blocker-engineers))
| ? (not (var 'engineers-first-talk))
| | ~ semi-engineer-chief
| | | (:weary)How in God's name did you get in here?
| | ~ player
| | | There's a tunnel above this shaft - though it's not something a human could navigate.
| | ~ semi-engineer-chief
| | | ... A //human//? So you're...
| | ~ player
| | - Not human, yes.
| |   ~ semi-engineer-chief
| |   | (:shocked)... An android, as I live and breathe.
| | - An android.
| |   ~ semi-engineer-chief
| |   | (:shocked)... As I live and breathe.
| | - What are you doing in here?
| | ~ semi-engineer-chief
| | | (:weary)We're the engineers you're looking for. Thank God for Innis.
| | ! eval (setf (nametag (unit 'semi-engineer-chief)) (@ semi-engineer-nametag))
| | | The tunnel collapsed; we lost the chief and half the company.
| | | We \"can't break through\"(orange) - can you? Can androids do that?
| | | \"The collapse is just ahead.\"(orange)
| | ! eval (setf (var 'engineers-first-talk) T)
| |?
| | ~ semi-engineer-chief
| | | (:weary)How'd it go with the \"collapsed wall\"(orange)? We can't stay here forever.
|?
| ? (not (var 'engineers-first-talk))
| | ~ semi-engineer-chief
| | | (:weary)Who are you? How did you break through the collapsed tunnel?
| | ~ player
| | - I'm... not human.
| |   ~ semi-engineer-chief
| |   | (:shocked)... An android, as I live and breathe.
| | - I'm an android.
| |   ~ semi-engineer-chief
| |   | (:shocked)... As I live and breathe.
| | - What are you doing in here?
| | ~ semi-engineer-chief
| | | (:weary)We're the engineers you're looking for. Thank God for Innis.
| | ! eval (setf (nametag (unit 'semi-engineer-chief)) (@ semi-engineer-nametag))
| | | We lost the chief and half the company when the tunnel collapsed.
| | | (:weary)We'll send someone for help now the route is open.
| | | Thank you.
| | ! eval (setf (var 'engineers-first-talk) T)
| |?
| | ~ semi-engineer-chief
| | | I don't believe you got through... Now food and medical supplies can get through too. Thank you.
| | | We can resume our excavations. It'll be slow-going, but we'll get it done.
! eval (deactivate 'task-reminder)
! eval (complete task)
"))

  (task-return-engineers
   :title "Once you've helped the engineers, return to Innis in the Semi Sisters control room"
   :marker '(innis 500)
   :condition NIL
   :on-activate T
   (:interaction return-engineers
    :title "(Report on the engineers)"
    :interactable innis
    :repeatable T
    :dialogue "
? (active-p (unit 'blocker-engineers))
| ~ innis
| | (:angry)The engineers aren't back yet - you need to help them. They're in the \"upper-west of our territory\"(orange).
|?
| ~ innis
| | (:pleased)The hurt engineers are already on their way back - I've sent hunters to guide them.
| | (:normal)How did you clear that debris? Is there something I dinnae ken about androids?
| ~ player
| - I found a weak point and pushed.
|   ~ innis
|   | That sounds plausible. Your fusion reactor would generate the necessary force, and your nanotube muscles could withstand the impact.
| - I just smashed through.
|   ~ innis
|   | I believe you did. Your fusion reactor would generate the necessary force, and your nanotube muscles could withstand the impact.
| - I pulled a hidden lever and said, \"Open sesame!\"
|   ~ innis
|   | (:angry)...
|   | Funny. (:sly)I suspect it has more to do with your formidable combination of fusion reactor and nanotube muscles.
| - Wouldn't you like to know.
|   ~ innis
|   | (:sly)I would indeed. Dinnae worry, things dinnae remain secret 'round here very long.
|   | I expect the combination of fusion reactor and nanotube muscles makes you quite formidable.
| ~ innis
| | There's something else as well...
| | My sister, in her infinite wisdom, thought it might be a nice gesture if we-... well, //if I// officially grant you access to the metro.
| | ... In the interests of good relations, between the Semi Sisters and yourself. (:normal)It'll certainly \"speed up your errands\"(orange).
| ? (or (unlocked-p (unit 'station-surface)) (unlocked-p (unit 'station-east-lab)) (unlocked-p (unit 'station-semi-sisters)) (unlocked-p (unit 'station-cerebats)) (unlocked-p (unit 'station-wraw)))
| | | (:sly)I ken you know about the metro already. But now it's official. I'll send out word so you won't be... apprehended.
| | | (:normal)\"The stations run throughout our territory and beyond\"(orange). Though \"no' all are operational\"(orange) while we expand the network.
| |?
| | | (:normal)You'll find \"the stations run throughout our territory and beyond\"(orange). Though \"no' all are operational\"(orange) while we expand the network.
| | | Just \"choose your destination from the route map\"(orange) and board the train.
| ? (not (unlocked-p (unit 'station-semi-sisters)))
| | | \"Our station is beneath this central block.\"(orange)
| ? (complete-p 'q5b-investigate-cctv)
| | ~ innis
| | | You've proven your worth to us. I might have to call on your services again.
| | | But now you should \"return to Fi\"(orange).
| | | It's a pity you couldnae persuade Alex to come home. (:sly)I'd love to see the look on Fi's face when you tell her.
| | | I suppose androids canna do everything.
| | | (:angry)And tell her we want Catherine back too. We need her now more than ever.
| | | (:sly)If she disagrees tell her I'll shut the water off.
| | ! eval (activate 'q6-return-to-fi)
| | ! eval (activate (unit 'fi-ffcs-1))
| | ! eval (activate (unit 'fi-ffcs-2))
| | < end
| ~ innis
| | I'll be seeing you.
| ! label end
| ! eval (complete task)
| ! eval (deactivate interaction)
")))
;; dinnae = don't (Scots)
;; ken = know (Scots)
;; couldnae = couldn't (Scots)
;; canna = cannot (Scottish)