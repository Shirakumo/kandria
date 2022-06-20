;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria demo-engineers-return)
  :author "Tim White"
  :title "Engineers Return"
  :visible NIL
  (:wait 1.5)
  (:interact (NIL :now T)
  (find-mess "demo-engineers" "engineers-return")))
