;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria semi-station-marker)
  :author "Tim White"
  :title "Semi Station Marker"
  :visible NIL
  :on-activate (task-1)

  (task-1
   :title ""
   :marker '(chunk-5638 1200)
   :condition all-complete))