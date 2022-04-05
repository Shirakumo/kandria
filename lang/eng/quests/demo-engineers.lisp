;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria demo-engineers)
  :author "Tim White"
  :title "Rescue Engineers"
  :description "Semi Sisters engineers are stuck in a collapsed rail tunnel in the upper-west of their territory. I need to find them so Innis will turn our water back on."
  :on-activate (task-reminder task-wall task-engineers)
 
 (task-reminder
   :title NIL
   :visible NIL
   :condition (complete-p 'task-return-engineers)
   :on-activate T
   (:interaction reminder
    :title "(Engineers reminder)"
    :interactable islay
    :repeatable T
    :dialogue "
~ islay
? (active-p (unit 'blocker-engineers))
| | \"Find our engineers\"(orange) in the collapsed rail tunnel. It's in the \"upper-west of our territory\"(orange).
| | Do what you can for them, then \"report back to Innis\"(orange).
|?
| | (:expectant)I heard there's news on the engineers - you should \"talk to Innis\"(orange).
"))

  (task-wall
   :title NIL
   :visible NIL
   :condition (not (active-p (unit 'blocker-engineers)))
   :on-complete (demo-engineers-return))
   

;; TODO Semi Engineers nametag completion doesn't update live on next chat line, though does in next convo selected. Worth fixing?
  (task-engineers
   :title "Find the trapped engineers"
   :marker '(chunk-5676 1200)
   :condition (complete-p 'task-return-engineers)
   :on-activate T   
   (:interaction engineers
    :interactable semi-engineer-chief
    :title "Islay sent me. Are you the Semis engineers?"
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
| | | (:weary)We're the rail engineers you're looking for. Thank God for Islay.
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
| | | (:weary)We're the rail engineers you're looking for. Thank God for Islay.
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
| (:pleased)The hurt engineers are already on their way back - I've sent hunters to guide them.
| (:normal)It's tough that we lost people, but sometimes that's the price of progress. I'll have Islay notify their families.
| More importantly: How did you clear that debris? Is there something I dinnae ken about androids?
~ player
- I found a weak point and pushed.
  ~ innis
  | That sounds plausible. Your fusion reactor would generate the necessary force, and your nanotube muscles could withstand the impact.
- I just smashed through.
  ~ innis
  | I believe you did. Your fusion reactor would generate the necessary force, and your nanotube muscles could withstand the impact.
- I pulled a hidden lever and said, \"Open sesame!\"
  ~ innis
  | (:angry)...
  | Funny. (:sly)I suspect it has more to do with your formidable combination of fusion reactor and nanotube muscles.
- Wouldn't you like to know.
  ~ innis
  | (:sly)I would indeed. Dinnae worry, things dinnae remain secret 'round here very long.
  | I expect the combination of fusion reactor and nanotube muscles makes you quite formidable.
~ innis
| There's something else as well...
| My sister, in her infinite wisdom, thought it might be a nice gesture if we-... well, //if I// officially grant you \"access to the metro\"(orange).
| ... In the interests of good relations, between the Semi Sisters and yourself. (:normal)It'll certainly \"speed up your errands\"(orange).
? (or (unlocked-p (unit 'station-surface)) (unlocked-p (unit 'station-semi-sisters)))
| | (:sly)I ken you know about the metro already. But now it's official. I'll send out word so you won't be... apprehended.
| | (:normal)\"The stations run throughout our territory and beyond\"(orange). Though \"no' all are operational\"(orange) while we expand the network.
|?
| | (:normal)You'll find \"the stations run throughout our territory and beyond\"(orange). Though \"no' all are operational\"(orange) while we expand the network.
| | Just \"choose your destination from the route map\"(orange) and board the train.
? (not (unlocked-p (unit 'station-semi-sisters)))
| | \"Our station is beneath this central block.\"(orange)
? (complete-p 'demo-cctv)
| ~ innis
| | But now you should \"return to the surface\"(orange).
| | Dinnae worry, I've \"turned the water back on\"(orange). Your friends can have a nice long drink.
| | (:sly)For what good it will do them.
| | If the Wraw are coming for us, they'll be \"coming for them too\"(orange).
| | (:normal)So long... //Stranger//.
| | Maybe I'll see you on the battlefield.
| ! eval (activate 'demo-end-prep)
| < end
~ innis
| I'll be seeing you.
! label end
! eval (complete task)
! eval (reset* interaction)
")))
;; dinnae = don't (Scots)
;; ken = know (Scots)
;; couldnae = couldn't (Scots)