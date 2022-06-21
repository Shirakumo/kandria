;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

;; delay the moving of the engineers, to allow time for the wall to clear
(define-sequence-quest (kandria world-move-engineers)
  :title NIL
  :visible NIL
  (:eval
    (move-to 'engineer-home-1 'semi-engineer-1)
    (move-to 'engineer-home-2 'semi-engineer-2)
    (move-to 'engineer-home-3 'semi-engineer-3)))