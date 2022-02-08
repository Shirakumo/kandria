;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

;; TODO replace with proper arena boss fight, leashed to this location (preferable) or in a plausibly-enclosed arena
;; TODO fix it so that running away (thus despawning the boss when chunk deletes) doesn't complete the fight - assuming we go with the leash solution and not the enclosed arena
(define-sequence-quest (kandria demo-boss)
  :author "Tim White"
  :title "Find the Saboteur"
  :description "Innis wants me to find the Cerebat saboteur responsible for destroying their CCTV, and bring them in."
  (:go-to (q5b-boss-loc)
   :title "Find the saboteur in the Semis low-eastern region, along the Cerebat border")
  (:interact (innis :now T)
"~ player
| (:skeptical)Innis, I found the saboteur. I don't think they're a Cerebat.
| (:embarassed)They're quite big. And I don't think they'll come quietly.
~ innis
| (:pleased)Then might I suggest you defend your wee self.
| (:sly)If you survive I'll be happy to \"hear your report in person\"(orange).
| (:angry)Now don't interrupt me again.
  ")
  (:complete (q5b-boss-fight)
   :title "Defeat the saboteur robot in the Semis low-eastern region, along the Cerebat border"
   "~ player
| Alright big boy, let's dance.
| (:giggle)You know the robot, right?
  ")
   (:eval
    (when (complete-p (find-task 'demo-cctv 'task-cctv-1) (find-task 'demo-cctv 'task-cctv-2) (find-task 'demo-cctv 'task-cctv-3))
     (activate (find-task 'demo-cctv 'task-return-cctv))
     (deactivate (find-task 'demo-cctv 'task-reminder)))))