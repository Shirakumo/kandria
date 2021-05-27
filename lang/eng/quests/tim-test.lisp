;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria tim-test)
  :title "Tim Test"
  :description "Tim Test desc"
  (:interact (catherine)
   :title "Talk to Catherine"
   "~ catherine
| Hi you.")
  (:go-to (farm-view :lead catherine)
   :title "Go to farm"
   "~ catherine
| Off to the farm we go!")
  (:interact (catherine :now T)
   "~ catherine
| Interact instant, will cause spawner, look out!")
  (:complete (test-spawner-1)
   :title "Defeat the enemies"
   "~ catherine
| Smash 'em!")
  (:go-to (lore-farm :lead catherine)
   :title "Go to edge of field"
   "~ catherine
| We're going to the edge of the field.")
  (:complete (test-spawner-2)
   :title "Defeat the enemies again")
  (:interact (catherine :now T)
   "~ catherine
| You did it"))