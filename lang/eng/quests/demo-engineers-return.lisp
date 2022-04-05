;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria demo-engineers-return)
  :author "Tim White"
  :title "Demo Engineers Return"
  :visible NIL
  (:wait 1.5)
  (:interact (player :now T)
  "
~ player
| \"That's the \"tunnel cleared\"(orange). I should \"report to Innis in the Semis control room\"(orange).\"(light-gray, italic)
! eval (setf (location 'innis) (location 'innis-main-loc))
! eval (setf (direction 'innis) 1)
! eval (activate (find-task 'demo-engineers 'task-return-engineers))
"))