;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria demo-cctv)
  :author "Tim White"
  :title "Investigate CCTV"
  :description "The Semi Sisters' CCTV cameras along their low-eastern border have gone down. I need to investigate them and report back to Innis in the control room, before they'll turn our water back on."
  :on-activate (task-reminder task-cctv-1 task-cctv-2 task-cctv-3 task-cctv-4)
  :variables (first-cctv)
 
  (task-reminder
   :title NIL
   :visible NIL
   :on-activate T
   (:interaction reminder
    :title "Remind me about the downed CCTV cameras."
    :interactable islay
    :repeatable T
    :dialogue "
~ islay
? (complete-p 'task-cctv-1 'task-cctv-2 'task-cctv-3 'task-cctv-4)
| ? (not (complete-p 'q5b-boss))
| | | You've found all the CCTV sites, but you need to \"bring Innis the saboteur from the low-eastern region\"(orange).
|?
| ? (complete-p 'q5b-boss)
| | | Go to the \"low-eastern region\"(orange) along the Cerebat border, and \"investigate the remaining downed CCTV cameras\"(orange).
| | | Then \"return to Innis\"(orange). Hopefully you won't encounter any more saboteurs.
| |? (active-p 'q5b-boss)
| | | Go to the \"low-eastern region\"(orange) along the Cerebat border, and \"investigate the remaining downed CCTV cameras\"(orange).
| | | And don't forget to \"bring Innis that saboteur\"(orange).
| |?
| | | Go to the \"low-eastern region\"(orange) along the Cerebat border, and \"find out what's wrong with the 4 downed CCTV cameras\"(orange).
| | | Then \"return to Innis\"(orange) in the \"control room\"(orange).
"))

;; NARRATIVE: the saboteur has been destroying the cameras in ways to avoid arousing suspicion, so they seem like electrical fires, poor maintenance, etc. However, by the fourth one, once the sabotage is clearly known, it recasts these descriptions of damage as likely sabotage.
  (task-cctv-1
   :title "Find CCTV camera 1"
   :condition all-complete
   :on-activate T
   (:interaction cctv-1
    :interactable cctv-1
    :dialogue "
~ player
| \"Here's the \"first\"(red) CCTV camera.\"(light-gray, italic)
| \"The lens is smashed and the casing is charred from a fire.\"(light-gray, italic)
? (complete-p 'task-cctv-2 'task-cctv-3 'task-cctv-4)
| ? (complete-p 'q5b-boss)
| | | (:normal)\"That was the last of the downed cameras. I should \"return to Innis\"(orange) and report on the saboteur.\"(light-gray, italic)
| | ! eval (deactivate 'task-reminder)
| | ! eval (activate 'task-return-cctv)
| |?
| | | (:normal)\"That was the last downed camera. But I still need to \"find the saboteur in the low-eastern area\"(orange), before I \"return to Innis\"(orange).\"(light-gray, italic)
|? (not (var 'first-cctv))
| | (:normal)\"This doesn't bode well. I need to \"find the other CCTV sites\"(orange), as recorded in my \"Log Files\"(orange) and on my \"Map\"(orange).\"(light-gray, italic)
| ! eval (setf (var 'first-cctv) T)
| ! eval (setf (location 'innis) (location 'innis-main-loc))
| ! eval (setf (direction 'innis) 1)
| ! eval (setf (location 'islay) (location 'islay-main-loc))
| ! eval (setf (direction 'islay) 1)
"))

  (task-cctv-2
   :title "Find CCTV camera 2"
   :condition all-complete
   :on-activate T
   (:interaction cctv-2
    :interactable cctv-2
    :dialogue "
~ player
| \"Here's the \"second\"(red) CCTV camera.\"(light-gray, italic)
| \"The outer case is missing - it's on the ground beneath the camera. It looks like moisture has shorted out the circuit boards.\"(light-gray, italic)
? (complete-p 'task-cctv-1 'task-cctv-3 'task-cctv-4)
| ? (complete-p 'q5b-boss)
| | | (:normal)\"That was the last of the downed cameras. I should \"return to Innis\"(orange) and report on the saboteur.\"(light-gray, italic)
| | ! eval (deactivate 'task-reminder)
| | ! eval (activate 'task-return-cctv)
| |?
| | | (:normal)\"That was the last downed camera. But I still need to \"find the saboteur in the low-eastern area\"(orange), before I \"return to Innis\"(orange).\"(light-gray, italic)
|? (not (var 'first-cctv))
| | (:normal)\"This doesn't bode well. I need to \"find the other CCTV sites\"(orange), as recorded in my \"Log Files\"(orange) and on my \"Map\"(orange).\"(light-gray, italic)
| ! eval (setf (var 'first-cctv) T)
| ! eval (setf (location 'innis) (location 'innis-main-loc))
| ! eval (setf (direction 'innis) 1)
| ! eval (setf (location 'islay) (location 'islay-main-loc))
| ! eval (setf (direction 'islay) 1)
"))

  (task-cctv-3
   :title "Find CCTV camera 3"
   :condition all-complete
   :on-activate T
   (:interaction cctv-3
    :interactable cctv-3
    :dialogue "
~ player
| \"Here's the \"third\"(red) CCTV camera.\"(light-gray, italic)
| \"It's in pieces on the floor, surrounded by rocks and stones.\"(light-gray, italic)
? (complete-p 'task-cctv-1 'task-cctv-2 'task-cctv-4)
| ? (complete-p 'q5b-boss)
| | | (:normal)\"That was the last of the downed cameras. I should \"return to Innis\"(orange) and report on the saboteur.\"(light-gray, italic)
| | ! eval (deactivate 'task-reminder)
| | ! eval (activate 'task-return-cctv)
| |?
| | | (:normal)\"That was the last downed camera. But I still need to \"find the saboteur in the low-eastern area\"(orange), before I \"return to Innis\"(orange).\"(light-gray, italic)
|? (not (var 'first-cctv))
| | (:normal)\"This doesn't bode well. I need to \"find the other CCTV sites\"(orange), as recorded in my \"Log Files\"(orange) and on my \"Map\"(orange).\"(light-gray, italic)
| ! eval (setf (var 'first-cctv) T)
| ! eval (setf (location 'innis) (location 'innis-main-loc))
| ! eval (setf (direction 'innis) 1)
| ! eval (setf (location 'islay) (location 'islay-main-loc))
| ! eval (setf (direction 'islay) 1)
"))

  (task-cctv-4
   :title "Find CCTV camera 4"
   :condition all-complete
   :on-activate T
   (:interaction cctv-4
    :interactable cctv-4
    :dialogue "
~ player
| \"Here's the \"fourth\"(red) CCTV camera.\"(light-gray, italic)
| (:thinking)\"The wiring has been cut, but otherwise it seems in good working order.\"(light-gray, italic)
| (:skeptical)\"But without the others daisy-chained in sequence, it still wouldn't work.\"(light-gray, italic)
| (:normal)\"I should tell Innis about the cut wires. Accessing FFCS protocols...\"(light-gray, italic)
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
| (:angry)Then we have a \"saboteur\"(orange). (:sly)Maybe a sly Cerebat spy, watching you right now.
| (:angry)\"Find them and bring them to me.\"(orange)
! eval (activate 'demo-boss)
~ player
? (complete-p 'task-cctv-1 'task-cctv-2 'task-cctv-3)
| | (:normal)\"That was also the last of the downed cameras. I should \"find the nearby saboteur and then return to Innis\"(orange).\"(light-gray, italic)
|? (not (var 'first-cctv))
| | (:normal)\"I also need to \"find the other CCTV sites\"(orange), as recorded in my \"Log Files\"(orange) and on my \"Map\"(orange).\"(light-gray, italic)
| ! eval (setf (var 'first-cctv) T)
| ! eval (setf (location 'innis) (location 'innis-main-loc))
| ! eval (setf (direction 'innis) 1)
| ! eval (setf (location 'islay) (location 'islay-main-loc))
| ! eval (setf (direction 'islay) 1)
"))
;; wouldnae = wouldn't (Scottish)
;; didnae = didn't (Scottish)
;; ken = know (Scottish)

  (task-return-cctv
   :title "Return to Innis in the Semi Sisters control room to discuss the saboteur"
   :condition all-complete
   :on-activate T
   (:interaction return-cctv
    :title "(Report on the sabotaged CCTV)"
    :interactable innis
    :dialogue "
~ innis
| (:pleased)I'm glad you survived.
| (:sly)So what are we dealing with?
~ player
- It was a big, badass robot.
  ~ innis
  | ... That's no' something the Cerebats would use.
- I don't know. It's in pieces if you want to go look.
  ~ innis
  | The Cerebats don't use robots. And no thank you.
- Do the Cerebats use robots?
  ~ innis
  | No.
~ innis
| (:thinking)They also don't make aggressive moves like crossing our border.
| ...
| (:angry)I think we might have a problem. A mutual problem:
| The \"Wraw\"(red).
| There've been other signs lately. Islay warned me about this.
| Dammit.
| ...
| (:normal)I need to speak with my sister.
? (complete-p 'demo-engineers)
| | You should return to the surface.
| | Don't worry, I've turned the water back on. Your friends can have a nice long drink.
| | (:sly)For what good it will do them.
| | If the Wraw are coming for us, they'll be coming for them too.
| | (:normal)So long... //Stranger//.
| | Maybe I'll see you on the battlefield.
| ! eval (activate 'demo-end-prep)
")))