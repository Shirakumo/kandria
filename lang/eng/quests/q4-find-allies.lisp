;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q4-find-allies)
  :author "Tim White"
  :title "Find Allies"
  :description "The Noka need allies if they are to survive this world, and their old faction the Wraw."
  :on-activate T

  (find-ally
   :title "Find allies in other factions"
   :condition NIL))
