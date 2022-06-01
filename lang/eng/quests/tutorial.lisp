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
   (dolist (unit '(catherine fi jack trader alex innis islay zelah semi-engineer-chief cerebat-trader-quest soldier-1 soldier-2 soldier-3))
     (setf (nametag (unit unit)) (@ unknown-nametag)))
   (setf (nametag player) (@ player-name-0)))
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
| (:excited)Yes!
| (:concerned)Uh, \"can you walk\"(orange)?")
  (:go-to (walk-start) :marker NIL)
  (:interact (catherine :now T)
   "~ catherine
| (:excited)No way! Looks like \"most of your systems are still working\"(orange).
| (:normal)My name's \"Catherine\"(yellow). Come on, \"let's get out of here\"(orange).
! eval (setf (nametag (unit 'catherine)) (@ catherine-nametag))")
  (:go-to (jump-start :lead catherine) :marker NIL)
  (:go-to (climb-start :with catherine) :marker NIL)
  (:go-to (rope-start :with catherine) :marker NIL
  "~ catherine
| \"Try not to fall.\"(orange)")
  (:go-to (dash-start :with catherine) :marker NIL)
  (:eval
   (ensure-nearby 'dash-start 'catherine)
   (move :freeze player)
   (move :left 'catherine))
  (:nearby (dash-end catherine)
           (stop 'catherine)
           (setf (direction 'catherine) +1)
           (stop 'player))
  (:go-to (dash-end) :marker NIL
  "~ catherine
| <-Shit!->... (:disappointed)Umm, \"now what\"(orange)?...
  ")
  (:go-to (platform-start :with catherine) :marker NIL
  "~ catherine
| (:cheer)That was __AMAZING!!__ Is that some kind of booster module?
  ")  
  (:go-to (platform-end :with catherine) :marker NIL
  "~ catherine
| We're almost there - it's \"just through here\"(orange).
  ")
  (:go-to (tutorial-end :with catherine) :marker NIL))
