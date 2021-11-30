;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q5b-repair-cctv)
  :author "Tim White"
  :title "Investigate CCTV"
  :description "The Semi Sisters' CCTV cameras along their low-eastern border have gone down."
  :on-activate (q5b-task-reminder q5b-task-cctv-1 q5b-task-cctv-2 q5b-task-cctv-3 q5b-task-cctv-4)
  :variables (first-cctv)
 
 ;; Can't use FFCS to indicate sites, nor realise it's block, as narrative device to find out it's blocked later - ofc will still appear on meta map
 (q5b-task-reminder
   :title NIL
   :visible NIL
   :on-activate T
   (:interaction q5b-reminder
    :title "Remind me about the downed CCTV cameras."
    :interactable innis
    :repeatable T
    :dialogue "
~ innis
? (or (active-p 'q5b-boss) (complete-p 'q5b-boss))
| | Go to the \"low-eastern region\"(orange) along the Cerebat border, and \"investigate the remaining downed CCTV cameras\"(orange).
| | Hopefully you won't encounter any more saboteurs.
|?
| | Go to the \"low-eastern region\"(orange) along the Cerebat border, and \"find out what's wrong the four downed CCTV cameras\"(orange).
"))

;; NARRATIVE: the saboteur has been destroying the cameras in ways to avoid arousing suspicion, so they seem like electrical fires, poor maintenance, etc. However, by the fourth one, once the sabotage is clearly known, it recasts these descriptions of damage as likely sabotage.
  (q5b-task-cctv-1
   :title "Find CCTV camera 1"
   :condition all-complete
   :on-activate T   
   (:interaction q5b-cctv-1
    :interactable cctv-1
    :dialogue "
~ player
| \"Here's the \"first\"(red) CCTV camera.\"(light-gray, italic)
| \"The lens is smashed and the casing is charred like there was a fire.\"(light-gray, italic)
? (complete-p 'q5b-task-cctv-2 'q5b-task-cctv-3 'q5b-task-cctv-4)
| ? (complete-p 'q5b-boss)
| | | (:normal)\"That was the last of the downed cameras. I should \"return to Innis\"(orange) and report on the saboteur.\"(light-gray, italic)
| |?
| | | (:normal)\"That was the last downed camera. But I still need to \"find the saboteur in the low-eastern area\"(orange), before I \"return to Innis\"(orange).\"(light-gray, italic)
| ! eval (deactivate 'q5b-task-reminder)
| ! eval (activate 'q5b-task-return-cctv)
|? (not (var 'first-cctv))
| | (:normal)\"I need to find the other CCTV sites, as recorded in my \"Log Files\"(orange).\"(light-gray, italic)
| ! eval (setf (var 'first-cctv) T)
"))

  (q5b-task-cctv-2
   :title "Find CCTV camera 2"
   :condition all-complete
   :on-activate T   
   (:interaction q5b-cctv-2
    :interactable cctv-2
    :dialogue "
~ player
| \"Here's the \"second\"(red) CCTV camera.\"(light-gray, italic)
| \"The outer case is missing - it's on the ground beneath the camera. It looks like moisture has shorted out the circuit boards.\"(light-gray, italic)
? (complete-p 'q5b-task-cctv-1 'q5b-task-cctv-3 'q5b-task-cctv-4)
| ? (complete-p 'q5b-boss)
| | | (:normal)\"That was the last of the downed cameras. I should \"return to Innis\"(orange) and report on the saboteur.\"(light-gray, italic)
| |?
| | | (:normal)\"That was the last downed camera. But I still need to \"find the saboteur in the low-eastern area\"(orange), before I \"return to Innis\"(orange).\"(light-gray, italic)
| ! eval (deactivate 'q5b-task-reminder)
| ! eval (activate 'q5b-task-return-cctv)
|? (not (var 'first-cctv))
| | (:normal)\"I need to find the other CCTV sites, as recorded in my \"Log Files\"(orange).\"(light-gray, italic)
| ! eval (setf (var 'first-cctv) T)
"))

  (q5b-task-cctv-3
   :title "Find CCTV camera 3"
   :condition all-complete
   :on-activate T   
   (:interaction q5b-cctv-3
    :interactable cctv-3
    :dialogue "
~ player
| \"Here's the \"third\"(red) CCTV camera.\"(light-gray, italic)
| \"It's in pieces on the floor, surrounded by rocks and stones.\"(light-gray, italic)
? (complete-p 'q5b-task-cctv-1 'q5b-task-cctv-2 'q5b-task-cctv-4)
| ? (complete-p 'q5b-boss)
| | | (:normal)\"That was the last of the downed cameras. I should \"return to Innis\"(orange) and report on the saboteur.\"(light-gray, italic)
| |?
| | | (:normal)\"That was the last downed camera. But I still need to \"find the saboteur in the low-eastern area\"(orange), before I \"return to Innis\"(orange).\"(light-gray, italic)
| ! eval (deactivate 'q5b-task-reminder)
| ! eval (activate 'q5b-task-return-cctv)
|? (not (var 'first-cctv))
| | (:normal)\"I need to find the other CCTV sites, as recorded in my \"Log Files\"(orange).\"(light-gray, italic)
| ! eval (setf (var 'first-cctv) T)
"))

  (q5b-task-cctv-4
   :title "Find CCTV camera 4"
   :condition all-complete
   :on-activate T   
   (:interaction q5b-cctv-4
    :interactable cctv-4
    :dialogue "
~ player
| \"Here's the \"fourth\"(red) CCTV camera.\"(light-gray, italic)
| (:thinking)\"The wiring has been cut, but otherwise it seems in good working order.\"(light-gray, italic)
| (:skeptical)\"But without the others daisy-chained in sequence, it still won't work.\"(light-gray, italic)
| (:normal)\"I should tell Innis about the cut wires. Accessing FFCS protocols...\"(light-gray, italic)
| Hello, Innis.
~ innis
| (:angry)You! How did you reach me?...
| (:sly)This is an FFCS broadcast, isn't it. Clever android.
| (:angry)But now isn't a good time. What do you want?
~ player
- This is important.
  ~ innis
  | (:angry)It'd better be. Get on with it then.
- Sorry to interrupt.
  ~ innis
  | (:angry)I'll accept that apology if what you have to say has value.
- Is there something wrong with FFCS?
  ~ innis
  | Not at all. (:sly)I think it's a marvellous technology.
  | (:normal)We're just not used to it crossing our airwaves. (:angry)Now what is it?
~ player
| The power line to one of the cameras has been cut. By hand.
~ innis
| (:angry)Then we have a \"saboteur\"(orange). (:sly)Probably a sly Cerebat spy, watching you right now.
| (:angry)\"Find them and bring them to me.\"(orange)
! eval (activate 'q5b-boss)
~ player
? (complete-p 'q5b-task-cctv-1 'q5b-task-cctv-2 'q5b-task-cctv-3)
| | (:normal)\"That was also the last of the downed cameras. I should \"find the nearby saboteur and then return to Innis\"(orange).\"(light-gray, italic)
| ! eval (deactivate 'q5b-task-reminder)
|? (not (var 'first-cctv))
| | (:normal)\"I also need to find the other CCTV sites, as recorded in my \"Log Files\"(orange).\"(light-gray, italic)
| ! eval (setf (var 'first-cctv) T)
"))
   

  (q5b-task-return-cctv
   :title "Return to Innis in the Semi Sisters control room to discuss the saboteur"
   :condition all-complete
   :on-activate T
   (:interaction q5b-return-cctv
    :title "(Report on the sabotaged CCTV)"
    :interactable innis
    :dialogue "
~ innis
| (:pleased)I'm glad you survived.
| (:sly)So tell me, what are we dealing with?
~ player
- It was a big, badass robot.
  ~ innis
  | ... That's not something the Cerebats would use.
- I don't know. It's in pieces if you want to go look.
  ~ innis
  | The Cerebats don't use robots.
- Do the Cerebats use robots?
  ~ innis
  | No.
~ innis
| (:thinking)They also don't make aggressive moves like crossing our border.
| ...
| (:angry)I think we might have a problem. A mutual problem.
| The Wraw.
| They've been other signs lately. Islay warned me about this.
| Fuck.
| ...
| (:normal)I need to speak with my sister.
? (complete-p 'q5a-rescue-engineers)
| ~ innis
| | Perhaps you should \"return to Fi\"(orange).
| ! eval (activate 'q6-return-to-fi)
")))
