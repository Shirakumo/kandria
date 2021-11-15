;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q5b-repair-cctv)
  :author "Tim White"
  :title "Investigate CCTV"
  :description "The Semi Sisters' CCTV network along their lower border with the Cerebats has stopped transmitting."
  :on-activate (q5b-task-overview)
  :variables (first-cctv)

 (q5b-task-overview
   :title "Speak with Innis for more information, in the Semi Sisters housing complex."
   :condition all-complete
   :on-activate T
   (:interaction q5b-overview
    :title "Islay said the CCTV has gone down."
    :interactable innis
    :dialogue "
~ innis
| CCTV overview.
! eval (activate 'q5b-task-reminder)
! eval (activate 'q5b-task-cctv-1)
! eval (activate 'q5b-task-cctv-2)
! eval (activate 'q5b-task-cctv-3)
! eval (activate 'q5b-task-cctv-4)
"))
 
 (q5b-task-reminder
   :title NIL
   :visible NIL
   :on-activate T
   (:interaction q5b-reminder
    :title "About the CCTV repairs."
    :interactable innis
    :repeatable T
    :dialogue "
~ innis
| Repeatable clue.
"))

  (q5b-task-cctv-1
   :title "Find CCTV camera 1."
   :condition all-complete
   :on-activate T   
   (:interaction q5b-cctv-1
    :interactable cctv-1
    :dialogue "
~ player
| Here be CCTV 1.
? (complete-p 'q5b-task-cctv-2 'q5b-task-cctv-3 'q5b-task-cctv-4)
| | (:normal)\"That's the last CCTV repair. I should \"return to Innis\"(orange).\"(light-gray, italic)
| ! eval (activate 'q5b-task-return-cctv)
| ! eval (deactivate 'q5b-task-reminder)
|? (not (var 'first-cctv))
| | (:normal)\"I should keep looking, and consult my \"Log Files\"(orange) for the remaining CCTV sites.\"(light-gray, italic)
| ! eval (setf (var 'first-cctv) T)
"))

  (q5b-task-cctv-2
   :title "Find CCTV camera 2."
   :condition all-complete
   :on-activate T   
   (:interaction q5b-cctv-2
    :interactable cctv-2
    :dialogue "
~ player
| Here be CCTV 2.
? (complete-p 'q5b-task-cctv-1 'q5b-task-cctv-3 'q5b-task-cctv-4)
| | (:normal)\"That's the last CCTV repair. I should \"return to Innis\"(orange).\"(light-gray, italic)
| ! eval (activate 'q5b-task-return-cctv)
| ! eval (deactivate 'q5b-task-reminder)
|? (not (var 'first-cctv))
| | (:normal)\"I should keep looking, and consult my \"Log Files\"(orange) for the remaining CCTV sites.\"(light-gray, italic)
| ! eval (setf (var 'first-cctv) T)
"))

  (q5b-task-cctv-3
   :title "Find CCTV camera 3."
   :condition all-complete
   :on-activate T   
   (:interaction q5b-cctv-3
    :interactable cctv-3
    :dialogue "
~ player
| Here be CCTV 3.
? (complete-p 'q5b-task-cctv-1 'q5b-task-cctv-2 'q5b-task-cctv-4)
| | (:normal)\"That's the last CCTV repair. I should \"return to Innis\"(orange).\"(light-gray, italic)
| ! eval (activate 'q5b-task-return-cctv)
| ! eval (deactivate 'q5b-task-reminder)
|? (not (var 'first-cctv))
| | (:normal)\"I should keep looking, and consult my \"Log Files\"(orange) for the remaining CCTV sites.\"(light-gray, italic)
| ! eval (setf (var 'first-cctv) T)
"))

  (q5b-task-cctv-4
   :title "Find CCTV camera 4."
   :condition all-complete
   :on-activate T   
   (:interaction q5b-cctv-4
    :interactable cctv-4
    :dialogue "
~ player
| Here be CCTV 4.
? (complete-p 'q5b-task-cctv-1 'q5b-task-cctv-2 'q5b-task-cctv-3)
| | (:normal)\"That's the last CCTV repair. I should \"return to Innis\"(orange).\"(light-gray, italic)
| ! eval (activate 'q5b-task-return-cctv)
| ! eval (deactivate 'q5b-task-reminder)
|? (not (var 'first-cctv))
| | (:normal)\"I should keep looking, and consult my \"Log Files\"(orange) for the remaining CCTV sites.\"(light-gray, italic)
| ! eval (setf (var 'first-cctv) T)
"))


  (q5b-task-return-cctv
   :title "Return to Innis in the Semi Sisters housing complex."
   :condition all-complete
   :on-activate T
   (:interaction q5b-return-cctv
    :title "The CCTV is repaired."
    :interactable innis
    :dialogue "
~ player
| CCTV done saved.
~ innis
| So I saw.
? (complete-p 'q5a-rescue-engineers)
| ~ innis
| | You can go.
| ! eval (activate 'q6-return-to-fi)
")))
