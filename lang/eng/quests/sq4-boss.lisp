;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria sq4-boss)
  :author "Tim White"
  :title NIL
  :visible NIL
  (:eval
    (deactivate (unit 'spawner-7608))
    (activate (unit 'sq4-boss-fight)))
  (:go-to (sq4-servos) :marker NIL)
  (:eval
   (override-music 'battle))
  (:complete (sq4-boss-fight))
  (:eval
   (override-music NIL))
   (:wait 1)
   (:interact (NIL :now T)
  "
~ player
| \"Did I notice anything unusual about those Servos?\"(light-gray, italic)
| \"I should \"get back to the roboticist and deliver my findings\"(orange).\"(light-gray, italic)
"))