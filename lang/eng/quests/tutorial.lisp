;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria tutorial)
  :author "Nicolas Hafner"
  :title "Intro"
  :visible NIL
  (:eval
   (activate (unit 'dash-prompt))
   (setf (location 'player) (location 'tutorial-start))
   (setf (location 'catherine) (location 'walk-start)))
  (:go-to (walk-start))
  (:go-to (jump-start :lead catherine)
   "~ catherine
| My name's Catherine. You can follow me, it's okay.
  ")   
  (:go-to (climb-start :lead catherine)
  "~ catherine
| Right, here we go.
  ")  
  (:go-to (rope-start :lead catherine)
  "~ catherine
| (:excited)You're doing great!
  ")
  (:go-to (dash-start :lead catherine)
  "~ catherine
| Not too talkative though... Don't worry - (:excited)I can talk enough for both of us!
  ")
  (:eval
   (move :freeze 'player)
   (move :left 'catherine))
  (:nearby (dash-end catherine)
           (stop 'catherine)
           (stop 'player))
  (:go-to (dash-end)
  "~ catherine
| Shit!... (:disappointed)Umm, now what?...
  ")
  (:go-to (platform-start :lead catherine)
  "~ catherine
| (:cheer)That was AMAZING!!
  ")  
  (:go-to (platform-end :lead catherine)
  "~ catherine
| We're almost home - it's just ahead.
  ")
  (:go-to (tutorial-end :lead catherine)
   :on-complete (q0-settlement-emergency)
  )
  )

;; TODO when name vars persist across saves, init Catherine's name to "Woman", and then set it to Catherine here via: ! eval (setf (nametag player) \"Catherine\") once Catherine has introduced herself
;; SCRATCH You're doing great, to say you've been sat on your ass for what? Decades?