;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

;; TODO replace with proper arena boss fight, leashed to this location (preferable) or in a plausibly-enclosed arena
;; TODO fix it so that running away (thus despawning the boss when chunk deletes) doesn't complete the fight - assuming we go with the leash solution and not the enclosed arena
(define-sequence-quest (kandria demo-boss)
  :author "Tim White"
  :title "Find the Saboteur"
  :description "Innis wants me to find the Cerebat responsible for sabotaging their CCTV cameras, and bring them in."
  (:go-to (q5b-boss-loc)
   :title "Find the saboteur in the Semis' distant low eastern region, along the Cerebat border")
  (:interact (innis :now T) (find-mess "demo-boss" "a"))
  (:complete (q5b-boss-fight)
   :title "Defeat the saboteurs")
  (:eval
   (override-music NIL))
   (:wait 1)
   (:interact (NIL :now T) (find-mess "demo-boss" "b"))
  (:eval
   (when (complete-p (find-task 'demo-cctv 'task-cctv-1) (find-task 'demo-cctv 'task-cctv-2) (find-task 'demo-cctv 'task-cctv-3))
     (activate (find-task 'demo-cctv 'task-return-cctv)))))

