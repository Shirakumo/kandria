;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria demo-start)
  :author "Tim White"
  :title NIL
  :visible NIL
  (:eval
   (setf (location 'player) 'demo-start)
   (setf (direction player) 1)
   (setf (location 'innis) (location 'innis-intercept-demo))
   (setf (direction 'innis) -1)
   (setf (location 'catherine) (location 'eng-cath))
   (setf (direction 'catherine) -1)
   (deactivate (unit 'tutorial-end))
   (dolist (unit '(innis islay zelah semi-engineer-chief cerebat-trader-quest))
     (setf (nametag (unit unit)) (@ unknown-nametag)))
   (setf (nametag player) (@ player-name-1))
   (setf (state (unit 'player)) :animated))
  ;; KLUDGE: we have to do this wait 0 business here to defer the next few statements.
  ;;         the reason for this being that setting stuff like the animation on the player
  ;;         requires the player to have been fully loaded, which is not necessarily the
  ;;         the case when this quest is activated, as this happens during initial state
  ;;         load, but before asset load. The wait sufficiently defers the next stuff
  ;;         until after the load has completed.
  (:wait 0.0)
  (:eval
   (show-panel 'demo-intro-panel))
  (:wait 10.0)
  (:eval
   (transition
     (hide-panel 'demo-intro-panel)))
  (:eval
   (setf (clock (progression 'start-game +world+)) 0)
   (start (progression 'start-game +world+))
   (harmony:play (// 'sound 'player-awaken))
   (start-animation 'laying player))
  (:wait 1)
  (:animate (player wake-up)
    (save-state +main+ T))
  (:interact (NIL :now T) (find-mess "demo-start"))
  (:eval
   :condition (not (find-panel 'fullscreen-prompt))
   (fullscreen-prompt 'open-map))
  (:eval
   :on-complete (demo-semis)))
