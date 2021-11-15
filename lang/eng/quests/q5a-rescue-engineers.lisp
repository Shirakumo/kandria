;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q5a-rescue-engineers)
  :author "Tim White"
  :title "Rescue Engineers"
  :description "Semi Sisters railway engineers are stuck in a tunnel after a cave in."
  :on-activate (q5a-task-overview)

 (q5a-task-overview
   :title "Speak with Innis for more information, in the Semi Sisters housing complex."
   :condition all-complete
   :on-activate T
   (:interaction q5a-overview
    :title "Islay told me about the trapped engineers."
    :interactable innis
    :dialogue "
~ innis
| Engineers overview.
! eval (activate 'q5a-task-reminder)
! eval (activate 'q5a-task-engineers)
! eval (activate (unit 'semi-engineers))
"))
 
 (q5a-task-reminder
   :title NIL
   :visible NIL
   :on-activate T
   (:interaction q5a-reminder
    :title "About the trapped engineers."
    :interactable innis
    :repeatable T
    :dialogue "
~ innis
| Repeatable clue.
"))

  (q5a-task-engineers
   :title "Find the trapped railway engineers in the caves to the west of Semi Sisters territory."
   :condition all-complete
   :on-activate T   
   (:interaction q5a-engineers
    :interactable semi-engineers-loc
    :dialogue "
~ player
| Here be engineers.
! eval (activate 'q5a-task-return-engineers)
! eval (deactivate 'q5a-task-reminder)
"))


  (q5a-task-return-engineers
   :title "Return to Innis in the Semi Sisters housing complex."
   :condition all-complete
   :on-activate T
   (:interaction q5a-return-engineers
    :title "The engineers are freed."
    :interactable innis
    :dialogue "
~ player
| Engineers saved.
~ innis
| So I heard. Remind me not to get on your bad side.
? (complete-p 'q5b-repair-cctv)
| ~ innis
| | You can go.
| ! eval (activate 'q6-return-to-fi)
")))
