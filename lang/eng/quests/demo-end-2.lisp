;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria demo-end-2)
  :author "Tim White"
  :title "Demo End"
  :visible NIL
  :on-activate (show-screen)
  (show-screen
   :title ""
   :on-activate (activate)
   (:action activate (show-panel 'end-screen))))