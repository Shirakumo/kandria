;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria q15-engineering)
  :author "Tim White"
  :title ""
  :visible NIL
  (:go-to (fi-wraw))
  (:interact (islay :now T)
    "
~ islay
| Fi, {(nametag player)} - \"come to Engineering\"(orange).
| We \"need to talk\"(orange).
")
  (:eval
   :on-complete (q15-intro)))