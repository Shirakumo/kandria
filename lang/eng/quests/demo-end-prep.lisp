;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

;; used to update world fallback chat's immediately, since demo-end-2 has a wait delay
(define-sequence-quest (kandria demo-end-prep)
  :author "Tim White"
  :title "Demo End Prep"
  :visible NIL
  (:eval
    :on-complete (demo-end-2)))
