;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria demo-end-2)
  :author "Tim White"
  :title "Demo End"
  :visible NIL
  (:wait 1.0)
  (:eval
   (:action activate (show-panel 'end-screen))))