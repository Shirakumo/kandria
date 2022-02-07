;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria demo-cctv-intro)
  :author "Tim White"
  :title "Name"
  :description "Description."
  (:interact (fi :now T :repeatable T)
   :title "Bullet"
  "
~ fi
| Dialogue
")
  (:eval
   :on-complete (qx-xxxx)))
   
;; islay gives quest, and reminder, but innis is the hand in destination (clarify - and say they'll be moving back to the control room shortly)
;; also use a trigger mid-explore to move Innis and Islay back to control room