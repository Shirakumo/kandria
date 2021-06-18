;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria tutorial)
  :author "Nicolas Hafner"
  :title "Intro"
  :visible NIL
  (:eval
   (setf (location 'player) (location 'tutorial-start))
   (setf (location 'catherine) (location 'walk-start)))
  (:go-to (walk-start))
  (:go-to (jump-start :lead catherine))
  (:go-to (climb-start :lead catherine))
  (:go-to (rope-start :lead catherine))
  (:go-to (dash-start :lead catherine))
  (:eval
   (move 'null 'player)
   (move :left 'catherine))
  (:nearby (dash-end catherine)
           (stop 'catherine)
           (stop 'player))
  (:go-to (dash-end))
  (:go-to (platform-start :lead catherine))
  (:go-to (platform-end :lead catherine))
  (:go-to (tutorial-end :lead catherine)))
