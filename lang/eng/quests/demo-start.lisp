;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria demo-start)
  :author "Tim White"
  :title "Find the Semi Sisters"
  :description "I need to find the tech-witch Semi Sisters, so they can restore the water supply for my friends on the surface."
  (:eval    
   (setf (location 'player) 'demo-start)
   (setf (direction player) 1)
   (setf (location 'innis) (location 'innis-intercept))
   (setf (direction 'innis) -1)
   (setf (location 'islay) (location 'islay-intercept))
   (setf (direction 'islay) 1)
   (setf (nametag (unit 'innis)) "???")
   (setf (nametag (unit 'islay)) "???")
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
  (:animate (player wake-up))
  (:interact (player :now T)
  "
~ player
| (:embarassed)... Ouch. Stupid rock slide.
| (:thinking)Huh?
| \"I can hear voices up ahead. I hope that's the Semi Sisters.\"(light-gray, italic)
| \"My friends on the surface won't last much longer without water.\"(light-gray, italic)
| (:skeptical)\"Hopefully the rumours about them being tech witches are false.\"(light-gray, italic)
")
  (:go-to (innis)
   :title "Find the Semi Sisters")
  (:interact (innis :now T)
    "
~ innis
| (:angry)<-STOP-> WHERE YOU ARE!!
| Did you think ya could just waltz right through here?
| (:sly)We've been watching you, android.
~ player
- Who are you?
  ~ innis
  | Alas, no' too smart...
- What do you want?
  ~ innis
  | (:sly)I'll ask the questions, if you dinnae mind.
| (:normal)What //should// we do with you? I bet your \"Genera\"(red) core could run our entire operation.
| What do you think, sister?
~ islay
| (:unhappy)I think you should leave her alone.
~ innis
| (:angry)...
| (:normal)Come now, Islay - the pinnacle of human engineering is standing before you, and that's all you can say?
! eval (setf (nametag (unit 'islay)) (@ islay-nametag))
| (:sly)That wasn't a compliment by the way, android. (:normal)But let's no' get off on the wrong foot now.
~ player
- (Keep quiet)
  ~ innis
  | (:sly)Why are you are here? I ken lots about you, but I wanna ken more.
- My name's Stranger.
  ~ innis
  | This I ken, android. (:sly)Tell me, why are you here?
~ player
- My business is my business.
  ~ innis
  | If that's your prerogative.
  | But you'll be pleased to ken that we can turn the water back on for you.
- I need your help.
  ~ innis
  | (:pleased)You see, sister, the direct approach once again yields results - and confirms my info.
  | (:normal)Well you'll be pleased to ken that we can turn the water back on for you.
- Screw you!
  ~ islay
  | (:happy)...
  ~ innis
  | (:angry)...
  | I remember your kind! You think you're clever just 'cause you can mimic us.
  | You're a machine. And if I wished it I could have you pulled apart and scattered to the four corners of this valley.
  | (:normal)Now, let's try again.
  | You'll be pleased to ken that we can turn the water back on for you.
~ innis
| (:sly)Once you've done something for us.
| (:angry)Did your \"friends\" honestly think they could siphon it off forever?
| That's no' how the world works.
| (:normal)And I don't know why you bother - you don't need to drink. You should sack them off.
| Anyway, my \"sister\"(orange) knows what we need. \"Talk to her.\"(orange)
  ")
  (:eval
   :on-complete (demo-cctv-intro)))
   
#|
dinnae = don't (Scottish)
ken = know (Scottish)
|#