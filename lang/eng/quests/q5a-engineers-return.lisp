;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria q5a-engineers-return)
  :author "Tim White"
  :title "Engineers Return"
  :visible NIL
  (:wait 1.5)
  (:interact (NIL :now T)
  "
~ player
| \"That's the \"tunnel cleared\"(orange). Now the Semis can reach their engineers.\"(light-gray, italic)
| \"I should \"report back to Innis in the Semis control room\"(orange).\"(light-gray, italic)
? (not (complete-p (find-task 'q5a-rescue-engineers 'task-engineers)))
| | \"Although I've not found the engineers yet - I could \"look for them nearby, or trust they'll be okay\"(orange).\"(light-gray, italic)
  
! eval (move-to 'engineer-home-1 'semi-engineer-1)
! eval (move-to 'engineer-home-2 'semi-engineer-2)
! eval (move-to 'engineer-home-3 'semi-engineer-3)
! eval (activate (find-task 'q5a-rescue-engineers 'task-return-engineers))
! eval (deactivate (find-task 'q5a-rescue-engineers 'task-reminder))
? (active-p (find-task 'q5a-rescue-engineers 'task-wall-location))
| ! eval (complete (find-task 'q5a-rescue-engineers 'task-wall-location))
"))