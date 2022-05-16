;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria demo-cctv)
  :author "Tim White"
  :title "Investigate CCTV"
  :description "The Semi Sisters' CCTV cameras along their distant low eastern border have gone down. I need to investigate them and report back to Innis, before she'll turn our water back on."
  :on-activate (task-reminder task-cctv-1 task-cctv-2 task-cctv-3 task-cctv-4)
  :variables (first-cctv)
 
  (task-reminder
   :title NIL
   :visible NIL
   :condition (complete-p 'task-return-cctv)
   :on-activate T
   (:interaction reminder
    :title "(CCTV reminder)"
    :interactable islay
    :repeatable T
    :dialogue "
~ islay
? (complete-p 'task-cctv-1 'task-cctv-2 'task-cctv-3 'task-cctv-4)
| ? (complete-p 'demo-boss)
| | | Saboteurs, huh? You'd better \"deliver your report to Innis\"(orange).
| |?
| | | You might've found all the CCTV sites, but you need to \"bring Innis the saboteur from the distant low eastern region\"(orange).
|?
| ? (complete-p 'demo-boss)
| | | Go to the \"distant low eastern region\"(orange) along the Cerebat border, and \"investigate the remaining down CCTV cameras\"(orange).
| | | Then \"return to Innis\"(orange). Hopefully you won't encounter any more saboteurs.
| |? (active-p 'demo-boss)
| | | Go to the \"distant low eastern region\"(orange) along the Cerebat border, and \"investigate the remaining down CCTV cameras\"(orange).
| | | And don't forget to \"bring Innis that saboteur\"(orange).
| |?
| | | Go to the \"distant low eastern region\"(orange) along the Cerebat border, and \"find out what's wrong with the 4 down CCTV cameras\"(orange).
| | | Then \"return to Innis\"(orange).
"))

;; NARRATIVE: the saboteur has been destroying the cameras in ways to avoid arousing suspicion, so they seem like electrical fires, poor maintenance, etc. However, by the fourth one, once the sabotage is clearly known, it recasts these descriptions of damage as likely sabotage.
  (task-cctv-1
   :title "Find CCTV camera 1"
   :marker '(chunk-5373 800)
   :condition all-complete
   :on-activate T
   (:interaction cctv-1
    :interactable cctv-1
    :dialogue "
~ player
| \"Here's \"CCTV camera 1\"(red).\"(light-gray, italic)
| \"The lens is smashed, and judging from the charring on the case there's been a fire.\"(light-gray, italic)
? (complete-p 'task-cctv-2 'task-cctv-3 'task-cctv-4)
| ? (complete-p 'demo-boss)
| | | \"That was the last of the down cameras. I'd better get \"back to Innis\"(orange) and report on the saboteurs.\"(light-gray, italic)
| | | (:thinking)\"Then again, I could also make the most of being out this way, and \"map more of the area\"(orange).\"(light-gray, italic)
| | ! eval (activate 'task-return-cctv)
| |?
| | | \"That was the last down camera. But I still need to \"find the nearby saboteur\"(orange) before I \"return to Innis\"(orange).\"(light-gray, italic)
|? (not (var 'first-cctv))
| | \"I need to \"find the other CCTV sites\"(orange), as recorded in my \"Log Files\"(orange) and on my \"Map\"(orange) \"< {(prompt-char 'open-map)} >\"(gold).\"(light-gray, italic)
| ! eval (setf (var 'first-cctv) T)
| ! eval (setf (location 'innis) (location 'innis-main-loc))
| ! eval (setf (direction 'innis) 1)
"))

  (task-cctv-2
   :title "Find CCTV camera 2"
   :marker '(chunk-5683 1200)
   :condition all-complete
   :on-activate T
   (:interaction cctv-2
    :interactable cctv-2
    :dialogue "
~ player
| \"Here's \"CCTV camera 2\"(red).\"(light-gray, italic)
| \"The outer case is missing - it's on the ground beneath the camera. It looks like moisture has shorted out the circuit board.\"(light-gray, italic)
? (complete-p 'task-cctv-1 'task-cctv-3 'task-cctv-4)
| ? (complete-p 'demo-boss)
| | | \"That was the last of the down cameras. I'd better get \"back to Innis\"(orange) and report on the saboteurs.\"(light-gray, italic)
| | | (:thinking)\"Then again, I could also make the most of being out this way, and \"map more of the area\"(orange).\"(light-gray, italic)
| | ! eval (activate 'task-return-cctv)
| |?
| | | \"That was the last down camera. But I still need to \"find the nearby saboteur\"(orange) before I \"return to Innis\"(orange).\"(light-gray, italic)
|? (not (var 'first-cctv))
| | \"I need to \"find the other CCTV sites\"(orange), as recorded in my \"Log Files\"(orange) and on my \"Map\"(orange) \"< {(prompt-char 'open-map)} >\"(gold).\"(light-gray, italic)
| ! eval (setf (var 'first-cctv) T)
| ! eval (setf (location 'innis) (location 'innis-main-loc))
| ! eval (setf (direction 'innis) 1)
"))

  (task-cctv-3
   :title "Find CCTV camera 3"
   :marker '(chunk-5681 1600)
   :condition all-complete
   :on-activate T
   (:interaction cctv-3
    :interactable cctv-3
    :dialogue "
~ player
| \"Here's \"CCTV camera 3\"(red).\"(light-gray, italic)
| \"It's mostly in pieces on the floor, surrounded by rocks and stones.\"(light-gray, italic)
? (complete-p 'task-cctv-1 'task-cctv-2 'task-cctv-4)
| ? (complete-p 'demo-boss)
| | | \"That was the last of the down cameras. I'd better get \"back to Innis\"(orange) and report on the saboteurs.\"(light-gray, italic)
| | | (:thinking)\"Then again, I could also make the most of being out this way, and \"map more of the area\"(orange).\"(light-gray, italic)
| | ! eval (activate 'task-return-cctv)
| |?
| | | \"That was the last down camera. But I still need to \"find the nearby saboteur\"(orange) before I \"return to Innis\"(orange).\"(light-gray, italic)
|? (not (var 'first-cctv))
| | \"I need to \"find the other CCTV sites\"(orange), as recorded in my \"Log Files\"(orange) and on my \"Map\"(orange) \"< {(prompt-char 'open-map)} >\"(gold).\"(light-gray, italic)
| ! eval (setf (var 'first-cctv) T)
| ! eval (setf (location 'innis) (location 'innis-main-loc))
| ! eval (setf (direction 'innis) 1)
"))

  (task-cctv-4
   :title "Find CCTV camera 4"
   :marker '(chunk-5685 1600)
   :condition all-complete
   :on-activate T
   (:interaction cctv-4
    :interactable cctv-4-trigger
    :dialogue "
~ player
| \"It's \"CCTV camera 4\"(red)... The wiring has been cut.\"(light-gray, italic)
| \"Innis needs to know about this. Accessing FFCS protocols...\"(light-gray, italic)
| Hello, Innis.
~ innis
| (:angry)You! How did you reach me?...
| (:sly)This is an FFCS broadcast, isn't it. Clever android.
| (:angry)Look, now isn't a good time. What do you want?
~ player
- This is important.
  ~ innis
  | (:angry)It'd better be. Get on with it then.
- Sorry to interrupt.
  ~ innis
  | (:angry)I'll accept that apology if you have something useful to say.
- How do you know about FFCS?
  ~ innis
  | (:sly)I wouldnae have been very good at my old job if I didnae ken it.
  | (:angry)Get on with it then.
~ player
| The power line to one of the cameras has been cut by hand.
~ innis
| (:angry)... Then we have a \"saboteur\"(orange). (:sly)Maybe a sly Cerebat spy, watching you right now.
? (complete-p (unit 'q5b-boss-fight))
| ~ player
| - I think I killed them already.
|   ~ innis
|   | Go on.
| - They were \"saboteurs\". Plural.
|   ~ innis
|   | What do you mean?
| - Way ahead of you.
|   ~ innis
|   | Explain.
| ~ player
| | I came this way before and was attacked by a gang. I dispatched them.
| ~ innis
| | (:sly)Is that so?
| | (:angry)Well in that case I'll await your report in the flesh-
| | ... You know what I mean.
| ! eval (complete 'demo-boss)
|?
| ~ innis
| | (:angry)\"Find them and bring them to me.\"(orange)
| ! eval (activate 'demo-boss)
  
~ player
? (complete-p 'task-cctv-1 'task-cctv-2 'task-cctv-3)
| ? (not (complete-p 'demo-boss))
| | | \"That was also the last of the down cameras. I'd better \"find the nearby saboteur and then return to Innis\"(orange).\"(light-gray, italic)
| |?
| | | \"That was also the last of the down cameras. I'd better get \"back to Innis\"(orange), on the double.\"(light-gray, italic)
| | | (:thinking)\"Then again, I could also make the most of being out this way, and \"map more of the area\"(orange).\"(light-gray, italic)
| | ! eval (activate 'task-return-cctv)
|? (not (var 'first-cctv))
| | \"I also need to \"find the other CCTV sites\"(orange), as recorded in my \"Log Files\"(orange) and on my \"Map\"(orange) \"< {(prompt-char 'open-map)} >\"(gold).\"(light-gray, italic)
| ! eval (setf (var 'first-cctv) T)
| ! eval (setf (location 'innis) (location 'innis-main-loc))
| ! eval (setf (direction 'innis) 1)
|? (complete-p 'demo-boss)
| | \"I'd better \"check out the last of the CCTV cameras around here\"(orange), then \"get back to Innis\"(orange) on the double.\"(light-gray, italic)
"))
;; wouldnae = wouldn't (Scottish)
;; didnae = didn't (Scottish)
;; ken = know (Scottish)

   ;; sense: Cerebats wouldn't typically take down CCTV (despite what Innis said in cctv-4), nor employ rogues... The Wraw would do both though.
  (task-return-cctv
   :title "Return to Innis in the Semi Sisters control room to discuss the saboteurs"
   :marker '(innis 500)
   :condition all-complete
   :on-activate T
   (:interaction return-cctv
    :title "(Report on the sabotaged CCTV)"
    :interactable innis
    :dialogue "
~ innis
| (:sly)I'm glad you survived the saboteurs.
| (:normal)So what are we dealing with?
~ player
- It was a band of rogues.
  ~ innis
  | ... Rogues? They're no' who the Cerebats would employ.
- Wannabe samurais and their pet dogs.
  ~ innis
  | Rogues then, with wolf packs. They're no' who the Cerebats would employ.
- Do the Cerebats have a K-9 unit?
  ~ innis
  | (:angry)...
  | (:normal)Rogues then, with wolf packs. They're no' who the Cerebats would employ.
~ innis
| They're no' the kind who would cross our border neither.
| ...
| (:angry)I think we might have a problem. A mutual problem:
| The \"Wraw\"(red).
| There've been other signs lately. Islay warned me about this.
| Dammit.
| (:normal)I need to speak with my sister.
? (complete-p 'demo-engineers)
| ~ innis
| | Still, you've done what we asked.
| | Islay, \"turn the water back on\"(orange).
| ~ islay
| | Right away.
| | Pump room - open the valve to the surface.
| | ...
| | It's done.
| ~ innis
| | Now your friends can have a nice long drink.
| | (:sly)For what good it will do them.
| | If the Wraw are coming for us, they'll be \"coming for them too\"(orange).
| | (:normal)You should \"return to the surface\"(orange).
| | So long... //Stranger//.
| | (:sly)Maybe I'll see you on the battlefield.
| ! eval (activate 'demo-end-prep)
")))
;; dinnae = don't / do not (Scottish)
;; doesnae = does not / doesn't (Scottish)