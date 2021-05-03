;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q1-water)
  :author "Tim White"
  :title "Fix the Water Supply"
  :description "The settlement are on the brink of starvation, and will lose their crop if the water supply isn't restored."
  :on-activate (ready-catherine))
