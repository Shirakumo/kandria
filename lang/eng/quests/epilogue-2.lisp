;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria epilogue-2)
  :author "Tim White"
  :title ""
  :visible NIL
  (:eval
   (move :freeze player))
  (:wait 5.0)
  (:eval
    (transition :kind :black (show-panel 'credits))))