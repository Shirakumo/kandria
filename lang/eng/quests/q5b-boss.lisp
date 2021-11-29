;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria q5b-boss)
  :author "Tim White"
  :title "Find the Saboteurs"
  :description "Innis wants me to find those responsible for sabotaging their CCTV cameras along the Cerebat border."
  (:go-to (q5b-boss-loc)
   :title "Find the nearby saboteurs")  
  (:interact (innis :now T)
"~ player
| (:skeptical)Innis, I found the saboteur. Singular.
| (:embarassed)They're quite big. And they look pissed.
~ innis
| (:pleased)Then might I suggest you defend your wee self.
| (:angry)And don't interrupt me again unless it's something important.
  ")
  (:complete (q5b-boss-fight)
   :title "Defeat the saboteur robot"
   "~ player
| Alright big boy, let's dance.
  "))