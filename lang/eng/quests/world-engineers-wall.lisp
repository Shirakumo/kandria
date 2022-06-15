;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria world-engineers-wall)
  :author "Tim White"
  :title "Clear the Tunnel"
  :description "Engineers from the Semi Sisters are trapped after a cave-in."
  :on-activate (task-wall-location)

  (task-wall-location
   :title "Clear the collapsed tunnel to free the engineers"
   :marker '(chunk-6034 2200)
   :condition (not (active-p (unit 'blocker-engineers)))))