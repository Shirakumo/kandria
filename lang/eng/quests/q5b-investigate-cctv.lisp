;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q5b-investigate-cctv)
  :author "Tim White"
  :title "Investigate CCTV"
  :description "The Semi Sisters' CCTV cameras along their low eastern border have gone down. It's something I can help with while Islay talks to Alex."
  :on-activate (q5b-task-reminder q5b-task-cctv-1 q5b-task-cctv-2 q5b-task-cctv-3 q5b-task-cctv-4)
  :variables (first-cctv)
 
 
 (q5b-task-reminder
   :title NIL
   :visible NIL
   :on-activate T
   (:interaction q5b-reminder
    :title "Remind me about the down CCTV cameras."
    :interactable innis
    :repeatable T
    :dialogue "
~ innis
? (complete-p 'q5b-task-cctv-1 'q5b-task-cctv-2 'q5b-task-cctv-3 'q5b-task-cctv-4)
| | (:angry)You might've found all the CCTV sites, but I want you to \"bring me back that saboteur from the low eastern region\"(orange).
|?
| ? (complete-p 'q5b-boss)
| | | Go to the \"low eastern region\"(orange) along the Cerebat border, and \"investigate the remaining down CCTV cameras\"(orange).
| | | Then \"return to me\"(orange). (:sly)Hopefully you won't encounter any more saboteurs.
| |? (active-p 'q5b-boss)
| | | Go to the \"low eastern region\"(orange) along the Cerebat border, and \"investigate the remaining down CCTV cameras\"(orange).
| | | (:angry)And dinnae forget to \"bring me back that saboteur\"(orange).
| |?
| | | Go to the \"low eastern region\"(orange) along the Cerebat border, and \"find out what's wrong with the 4 down CCTV cameras\"(orange).
| | | Then \"return to me\"(orange).
"))
;; dinnae = don't (Scottish)

;; NARRATIVE: the saboteur has been destroying the cameras in ways to avoid arousing suspicion, so they seem like electrical fires, poor maintenance, etc. However, by the fourth one, once the sabotage is clearly known, it recasts these descriptions of damage as likely sabotage.
  (q5b-task-cctv-1
   :title "Find CCTV camera 1"
   :marker '(chunk-5373 800)
   :condition all-complete
   :on-activate T   
   (:interaction cctv-1
    :interactable cctv-1
    :dialogue "
~ player
| \"Here's \"CCTV camera 1\"(red).\"(light-gray, italic)
| \"The lens is smashed, and judging by the charring on the case there's been a fire.\"(light-gray, italic)
? (complete-p 'q5b-task-cctv-2 'q5b-task-cctv-3 'q5b-task-cctv-4)
| ? (complete-p 'q5b-boss)
| | | (:normal)\"That was the last of the down cameras. I should \"return to Innis\"(orange) and report on the saboteurs.\"(light-gray, italic)
| | ! eval (deactivate 'q5b-task-reminder)
| | ! eval (activate 'q5b-task-return-cctv)
| |?
| | | (:normal)\"That was the last down camera. But I still need to \"find the saboteur in the low eastern area\"(orange), before I \"return to Innis\"(orange).\"(light-gray, italic)
|? (not (var 'first-cctv))
| | (:normal)\"I need to \"find the other CCTV sites\"(orange), as recorded in my \"Log Files\"(orange) and on my \"Map\"(orange).\"(light-gray, italic)
| ! eval (setf (var 'first-cctv) T)
"))

  (q5b-task-cctv-2
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
? (complete-p 'q5b-task-cctv-1 'q5b-task-cctv-3 'q5b-task-cctv-4)
| ? (complete-p 'q5b-boss)
| | | (:normal)\"That was the last of the down cameras. I should \"return to Innis\"(orange) and report on the saboteurs.\"(light-gray, italic)
| | ! eval (deactivate 'q5b-task-reminder)
| | ! eval (activate 'q5b-task-return-cctv)
| |?
| | | (:normal)\"That was the last down camera. But I still need to \"find the saboteur in the low eastern area\"(orange), before I \"return to Innis\"(orange).\"(light-gray, italic)
|? (not (var 'first-cctv))
| | (:normal)\"I need to \"find the other CCTV sites\"(orange), as recorded in my \"Log Files\"(orange) and on my \"Map\"(orange).\"(light-gray, italic)
| ! eval (setf (var 'first-cctv) T)
"))

  (q5b-task-cctv-3
   :title "Find CCTV camera 3"
   :marker '(chunk-5685 1600)
   :condition all-complete
   :on-activate T   
   (:interaction cctv-3
    :interactable cctv-3
    :dialogue "
~ player
| \"Here's \"CCTV camera 3\"(red).\"(light-gray, italic)
| \"It's mostly in pieces on the floor, surrounded by rocks and stones.\"(light-gray, italic)
? (complete-p 'q5b-task-cctv-1 'q5b-task-cctv-2 'q5b-task-cctv-4)
| ? (complete-p 'q5b-boss)
| | | (:normal)\"That was the last of the down cameras. I should \"return to Innis\"(orange) and report on the saboteurs.\"(light-gray, italic)
| | ! eval (deactivate 'q5b-task-reminder)
| | ! eval (activate 'q5b-task-return-cctv)
| |?
| | | (:normal)\"That was the last down camera. But I still need to \"find the saboteur in the low eastern area\"(orange), before I \"return to Innis\"(orange).\"(light-gray, italic)
|? (not (var 'first-cctv))
| | (:normal)\"I need to \"find the other CCTV sites\"(orange), as recorded in my \"Log Files\"(orange) and on my \"Map\"(orange).\"(light-gray, italic)
| ! eval (setf (var 'first-cctv) T)
"))

  (q5b-task-cctv-4
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
~ player
| The power line to one of the cameras has been cut by hand.
~ innis
| (:angry)... Then we have a \"saboteur\"(orange). (:sly)Maybe a sly Cerebat spy, watching you right now.
| (:angry)\"Find them and bring them to me.\"(orange)
! eval (activate 'q5b-boss)
~ player
? (complete-p 'q5b-task-cctv-1 'q5b-task-cctv-2 'q5b-task-cctv-3)
| | (:normal)\"That was also the last of the down cameras. I should \"find the nearby saboteur and then return to Innis\"(orange).\"(light-gray, italic)
|? (not (var 'first-cctv))
| | (:normal)\"I also need to \"find the other CCTV sites\"(orange), as recorded in my \"Log Files\"(orange) and on my \"Map\"(orange).\"(light-gray, italic)
| ! eval (setf (var 'first-cctv) T)
"))
;; wouldnae = wouldn't (Scottish)
;; didnae = didn't (Scottish)
;; ken = know (Scottish)

  ;; sense: Cerebats wouldn't typically take down CCTV (despite what Innis said in cctv-4 - it was logical though), nor employ rogues... The Wraw would do both though. And nor would rogues attack CCTV alone
  (q5b-task-return-cctv
   :title "Return to Innis in the Semi Sisters control room to discuss the saboteur"
   :marker '(innis 500)
   :condition all-complete
   :on-activate T
   (:interaction q5b-return-cctv
    :title "(Report on the sabotaged CCTV)"
    :interactable innis
    :dialogue "
~ innis
| (:pleased)I'm glad you survived.
| (:sly)So what are we dealing with?
~ player
- It was a band of rogues.
  ~ innis
  | ... Rogues? They're no' the kind who would sabotage.
- Wannabe samurais and their pet dogs.
  ~ innis
  | Rogues then, with wolf packs. They're no' the kind who would sabotage.
- Do the Cerebats have a K-9 unit?
  ~ innis
  | (:angry)...
  | (:normal)Rogues then, with wolf packs. They're no' the kind who would sabotage.
~ innis
| They're no' the kind who would cross our border neither.
| ...
| (:angry)I think we might have a problem. A mutual problem:
| The Wraw.
| There've been other signs lately. Islay warned me about this.
| Fuck.
| (:normal)I need to speak with my sister.
? (complete-p 'q5a-rescue-engineers)
| ~ innis
| | You've proven your worth to us. I might have to call on your services again.
| | But now you should \"return to Fi\"(orange).
| | It's a pity you couldnae persuade Alex to come home. (:sly)I'd love to see the look on Fi's face when you tell her.
| | I suppose androids canna do everything.
| | (:angry)And tell her we want Catherine back too. We need her now more than ever.
| | (:sly)If she disagrees tell her I'll shut the water off.
| ! eval (activate 'q6-return-to-fi)
| ! eval (activate (unit 'fi-ffcs-1))
| ! eval (activate (unit 'fi-ffcs-2))
")))
;; couldnae = couldn't (Scots)
;; dinnae = don't / do not (Scottish)
;; doesnae = does not / doesn't (Scottish)
;; canna = cannot (Scottish)
