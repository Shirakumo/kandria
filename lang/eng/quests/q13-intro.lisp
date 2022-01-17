;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria q13-intro)
  :author "Tim White"
  :title "Name"
  :description "Desc."
  ;; TODO only allow interact when Islay has arrived in Engineering
  (:interact (islay)
   :title "Meet Islay and Fi in Engineering"
  "
~ islay
| also summarise war prep, in case not spoke to Fi (optional)
| bombs plural reveal - surprise to Fi too
| bit of rivalry between Fi and Islay, bit pointed, implication they've talked about having you plant the bomb before now.
| will be dangerous, premature detonation risk, etc. foreboding for player's end...
| Add conditional dialogue snippet if know about Alex not coming back x2 outcomes possible (vars) - IF spoken to Fi about it
| Android will need to plant it, is that okay Fi?
~ fi
| Ask her.
! eval (setf (location 'innis) 'innis-intercept)
")
  (:eval
   :on-complete (qx-xxxx)))