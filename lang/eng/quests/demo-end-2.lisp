;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria demo-end-2)
  :author "Tim White"
  :title "Demo End"
  :visible NIL
  (:eval
   (setf (location 'fi) (location 'wraw-leader))
   (setf (direction 'fi) 1)
   (setf (location 'catherine) (location 'fi-wraw))
   (setf (direction 'catherine) 1)
   (setf (location 'jack) (location 'islay-wraw))
   (setf (direction 'jack) -1))
  (:wait 5.0)
  (:eval (show-panel 'end-screen)))
