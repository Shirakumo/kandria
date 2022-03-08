;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria demo-end-2)
  :author "Tim White"
  :title "Demo End"
  :visible NIL
  (:wait 5.0)
  (:eval (show-panel 'end-screen)))
