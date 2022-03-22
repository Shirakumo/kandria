;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

;; TODO replace with proper arena boss fight, leashed to this location (preferable) or in a plausibly-enclosed arena
;; TODO fix it so that running away (thus despawning the boss when chunk deletes) doesn't complete the fight - assuming we go with the leash solution and not the enclosed arena
(define-sequence-quest (kandria q5b-boss)
  :author "Tim White"
  :title "Find the Saboteur"
  :description "Innis wants me to find the Cerebat responsible for sabotaging at least one of their CCTV cameras, and bring them in."
  (:go-to (q5b-boss-loc)
   :title "Find the saboteur in the Semis' low eastern region, along the Cerebat border")
  (:interact (innis :now T)
"~ player
| (:embarassed)Innis, I found the <-saboteurs->. Plural.
| (:skeptical)I don't think they'll come quietly.
~ innis
| (:pleased)Then might I suggest you defend ya wee self.
| (:sly)If you survive ya can \"bring me your report in person\"(orange).
| (:angry)Now don't interrupt me again.
  ")
  (:complete (q5b-boss-fight)
   :title "Defeat the saboteurs"
   "~ player
| Good doggy.
  ")
   (:eval
    (when (complete-p (find-task 'q5b-investigate-cctv 'q5b-task-cctv-1) (find-task 'q5b-investigate-cctv 'q5b-task-cctv-2) (find-task 'q5b-investigate-cctv 'q5b-task-cctv-3))
     (activate (find-task 'q5b-investigate-cctv 'q5b-task-return-cctv))
     (deactivate (find-task 'q5b-investigate-cctv 'q5b-task-reminder))))
   (:wait 1)
   (:interact (player :now T)
  "
~ player
? (complete-p (find-task 'q5b-investigate-cctv 'q5b-task-cctv-1) (find-task 'q5b-investigate-cctv 'q5b-task-cctv-2) (find-task 'q5b-investigate-cctv 'q5b-task-cctv-3))
| | I'd better \"get back to Innis\"(orange), on the double.
|?
| | I'd better \"check out the last of the CCTV cameras\" around here, then \"get back to Innis\"(orange) on the double.
"))