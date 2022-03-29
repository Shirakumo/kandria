;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria demo-start)
  :author "Tim White"
  :title NIL
  :visible NIL
  (:eval    
   (setf (location 'player) 'demo-start)
   (setf (direction player) 1)
   (setf (location 'innis) (location 'innis-intercept))
   (setf (direction 'innis) -1)
   (setf (location 'islay) (location 'islay-intercept))
   (setf (direction 'islay) 1)
   (setf (location 'catherine) (location 'eng-cath))
   (setf (direction 'catherine) -1)
   (deactivate (unit 'tutorial-end))
   (dolist (unit '(innis islay zelah semi-engineer-chief cerebat-trader-quest))
     (setf (nametag (unit unit)) "???"))
   (setf (state (unit 'player)) :animated))
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
  (:interact (player :now T)
  "
~ player
| (:embarassed)... __OUCH__. Stupid rock slide.
| (:thinking)\"There are \"voices up ahead\"(orange). I hope that's the \"Semi Sisters\"(red).\"(light-gray, italic)
| \"My friends back on the surface \"won't last much longer without water\"(orange).\"(light-gray, italic)
| (:skeptical)\"Hopefully the rumours about them being tech witches are false...\"(light-gray, italic)
| (:normal)\"My \"Map\"(orange) should help me \"hone in on their position\"(orange).\"(light-gray, italic)
! eval (activate (unit 'innis-stop-1))
")
  (:eval
   :on-complete (demo-semis)))