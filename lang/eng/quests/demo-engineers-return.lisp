;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria demo-engineers-return)
  :author "Tim White"
  :title "Engineers Return"
  :visible NIL
  (:wait 1.5)
  (:interact (NIL :now T)
  "
~ player
| \"That's the \"tunnel cleared\"(orange). Now the Semis can reach their engineers.\"(light-gray, italic)
| \"I should \"report to Innis in the Semis control room\"(orange).\"(light-gray, italic)
? (not (complete-p (find-task 'demo-engineers 'task-engineers)))
| | \"Although I've not found the engineers yet - I could \"look for them nearby, or trust they'll be okay\"(orange).\"(light-gray, italic)
  
! eval (setf (location 'innis) (location 'innis-main-loc))
! eval (setf (direction 'innis) 1)
! eval (move-to 'engineer-home-1 'semi-engineer-1)
! eval (move-to 'engineer-home-2 'semi-engineer-2)
! eval (move-to 'engineer-home-3 'semi-engineer-3)
! eval (activate (find-task 'demo-engineers 'task-return-engineers))
? (active-p (find-task 'demo-engineers 'task-wall-location))
| ! eval (complete (find-task 'demo-engineers 'task-wall-location))
"))