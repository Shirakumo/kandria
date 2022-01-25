;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria q14-envoy)
  :author "Tim White"
  :title "Return to the Surface"
  :description "Islay hasn't detonated the bombs and wants me to return to camp immediately. Something's wrong."
  (:go-to (fi-wraw)
   :title "Return to the camp")
  (:interact (fi :now T)
  "
~ fi
| Dialogue
")
  (:eval
   :on-complete (q15-intro)))

;; why are we entertaining this person, kill them? - special ending?
;; TODO Zelah got to move away to a hidden location - move offscreen, then teleport?