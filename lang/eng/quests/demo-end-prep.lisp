;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria demo-end-prep)
  :author "Tim White"
  :title "Demo End Prep"
  :visible NIL
  (:wait 1.5)
  (:eval
   :on-complete (demo-end-2)))