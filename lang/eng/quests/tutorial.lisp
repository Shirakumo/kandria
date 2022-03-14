;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria tutorial)
  :author "Nicolas Hafner"
  :title "Intro"
  :visible NIL
  (:eval
   (activate (unit 'dash-prompt))
   (setf (location 'player) (location 'tutorial-start))
   (setf (direction player) 1)
   (setf (state (unit 'player)) :animated)
   (ensure-nearby 'walk-start 'catherine)
   (dolist (unit '(catherine fi jack trader alex innis islay zelah semi-engineer-chief cerebat-trader-quest))
     (setf (nametag (unit unit)) "???"))
   (setf (nametag player) "Android"))
  ;; KLUDGE: we have to do this wait 0 business here to defer the next few statements.
  ;;         the reason for this being that setting stuff like the animation on the player
  ;;         requires the player to have been fully loaded, which is not necessarily the
  ;;         the case when this quest is activated, as this happens during initial state
  ;;         load, but before asset load. The wait sufficiently defers the next stuff
  ;;         until after the load has completed.
  (:wait 0.0)
  (:eval
   (setf (clock (progression 'start-game +world+)) 0)
   (start (progression 'start-game +world+))
   (harmony:play (// 'sound 'player-awaken))
   (start-animation 'laying player))
  (:wait 1)
  (:animate (player wake-up)
            (save-state +main+ T))
  (:interact (catherine :now T)
   "
   ~ catherine
| (:excited)Woah...
| (:concerned)Uh, can you walk?")
  (:go-to (walk-start))
  (:interact (catherine :now T)
   "~ catherine
| (:excited)No way! Looks like most of your systems are still working.
| (:normal)My name's \"Catherine\"(yellow). Come on, let's get out of here.
! eval (setf (nametag (unit 'catherine)) (@ catherine-nametag))")
  (:go-to (jump-start :lead catherine))
  (:go-to (climb-start :with catherine))
  (:go-to (rope-start :with catherine)
  "~ catherine
| Try not to fall.")
  (:go-to (dash-start :with catherine))
  (:eval
   (ensure-nearby 'dash-start 'catherine)
   (move :freeze player)
   (move :left 'catherine))
  (:nearby (dash-end catherine)
           (stop 'catherine)
           (setf (direction 'catherine) +1)
           (stop 'player))
  (:go-to (dash-end)
  "~ catherine
| <-Shit!->... (:disappointed)Umm, now what?...
  ")
  (:go-to (platform-start :with catherine)
  "~ catherine
| (:cheer)That was __AMAZING!!__ Is that some kind of booster module?
  ")  
  (:go-to (platform-end :with catherine)
  "~ catherine
| We're almost there - it's just through here.
  ")
  (:go-to (tutorial-end :with catherine)))

;; TODO when name vars persist across saves, init Catherine's name to "Woman" or "???" (VN style), and then set it to Catherine here via: ! eval (setf (nametag player) \"Catherine\") once Catherine has introduced herself
;; SCRATCH Not too talkative though... Don't worry - (:excited)I can talk enough for both of us!

#|

|#

#|
Tutorial/prologue mission beats that must occur:
- Android has memory/function issues, and has been offline for an unknown number of years, probably decades
- Catherine has determined android is a "she" - or assumed...
- Catherine introduced herself by name, but hasn't asked the android's name

|#
