;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria demo-engineers)
  :author "Tim White"
  :title "Rescue Engineers"
  :description "Semi Sisters engineers are stuck in a collapsed rail tunnel in the far upper-west of their territory. I need to free them so Innis will turn our water back on."
  :on-activate (task-reminder task-wall task-engineers)
  :variables (engineers-intro)
 
 (task-reminder
   :title NIL
   :visible NIL
   :condition (complete-p 'task-return-engineers)
   :on-activate T
   (:interaction reminder
    :title "(Engineers reminder)"
    :interactable islay
    :repeatable T
    :dialogue (find-mess "demo-engineers" "task-reminder")))

  (task-wall
   :title NIL
   :visible NIL
   :condition (not (active-p (unit 'blocker-engineers)))
   :on-complete (demo-engineers-return))
   

;; TODO Semi Engineers nametag completion doesn't update live on next chat line, though does in next convo selected. Worth fixing?
  (task-engineers
   :title "Find the trapped engineers and check that they're okay"
   :marker '(chunk-5676 1200)
   :condition (complete-p 'task-return-engineers)
   :on-activate T   
   (:interaction engineers
    :interactable semi-engineer-chief
    :title ""
    :dialogue (find-mess "demo-engineers" "task-reminder")))

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
    :dialogue (find-mess "demo-engineers" "task-reminder"))))
;; dinnae = don't (Scots)
;; didnae = didn't (Scottish)
;; ken = know (Scots)
;; couldnae = couldn't (Scots)
