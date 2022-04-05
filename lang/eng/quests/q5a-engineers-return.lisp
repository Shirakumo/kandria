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
| \"That's the \"tunnel cleared\"(orange). Now the Semis should be able to reach their engineers.\"(light-gray, italic)
| \"I should \"report back to Innis in the Semis control room\"(orange).\"(light-gray, italic)
! eval (activate (find-task 'q5a-rescue-engineers 'task-return-engineers))
! eval (deactivate (find-task 'q5a-rescue-engineers 'task-reminder))
"))