;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria demo-end)
  :author "Nicolas Hafner"
  :title "Demo end"
  :visible NIL
  (:complete (q2-seeds q3-new-home)
             :activate NIL)
  (:wait 5.0)
  (:eval
   (setf (music-state 'region1) :normal)
   (show-panel 'end-screen)))
