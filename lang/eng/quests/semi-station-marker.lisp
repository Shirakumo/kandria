;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria semi-station-marker)
  :author "Tim White"
  :title "Access the Semi Sisters Station"
  :description "I can find the Semis train station beneath their central block."
  :on-activate (task-1)

  (task-1
   :title "Access the route map in the Semis station so it becomes a known destination"
   :marker '(chunk-5638 1200)
   :condition (unlocked-p (unit 'station-semi-sisters))))
