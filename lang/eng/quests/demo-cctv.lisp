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
    :dialogue (find-mess "demo-cctv" "task-reminder")))

;; NARRATIVE: the saboteur has been destroying the cameras in ways to avoid arousing suspicion, so they seem like electrical fires, poor maintenance, etc. However, by the fourth one, once the sabotage is clearly known, it recasts these descriptions of damage as likely sabotage.
  (task-cctv-1
   :title "Find CCTV camera 1"
   :marker '(chunk-5373 800)
   :condition all-complete
   :on-activate T
   (:interaction cctv-1
    :interactable cctv-1
    :dialogue (find-mess "demo-cctv" "task-cctv-1")))

  (task-cctv-2
   :title "Find CCTV camera 2"
   :marker '(chunk-5683 1200)
   :condition all-complete
   :on-activate T
   (:interaction cctv-2
    :interactable cctv-2
    :dialogue (find-mess "demo-cctv" "task-cctv-2")))

  (task-cctv-3
   :title "Find CCTV camera 3"
   :marker '(chunk-5681 1600)
   :condition all-complete
   :on-activate T
   (:interaction cctv-3
    :interactable cctv-3
    :dialogue (find-mess "demo-cctv" "task-cctv-3")))

  (task-cctv-4
   :title "Find CCTV camera 4"
   :marker '(chunk-5685 1600)
   :condition all-complete
   :on-activate T
   (:interaction cctv-4
    :interactable cctv-4-trigger
    :dialogue (find-mess "demo-cctv" "task-cctv-4")))
  
  (task-return-cctv
   :title "Return to Innis in the Semi Sisters control room to discuss the saboteurs"
   :marker '(innis 500)
   :condition all-complete
   :on-activate T
   (:interaction return-cctv
    :title "(Report on the sabotaged CCTV)"
    :interactable innis
    :dialogue (find-mess "demo-cctv" "task-return-cctv"))))
