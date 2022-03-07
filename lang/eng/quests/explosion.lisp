;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

;; TODO explosion sound and VFX
(define-sequence-quest (kandria explosion)
  :author "Tim White"
  :title ""
  :visible NIL
  (:eval
   (move :freeze player))
  (:wait 3.0)
  (:eval
   (transition
   (setf (location 'player) (location 'epilogue-player))
   (setf (direction player) -1)
   (setf (location 'catherine) (location 'epilogue-catherine))
   (setf (direction 'catherine) 1)))
  (:eval
   :on-complete (epilogue-talk)))