;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria tutorial)
  :author "Nicolas Hafner"
  :title "Intro"
  :visible NIL
  (:eval
   (activate (unit 'dash-prompt))
   (setf (location 'player) (location 'tutorial-start))
   (ensure-nearby 'walk-start 'catherine))
  (:wait 0.0)
  (:eval
   (setf (direction player) 1)
   (start-animation 'laying player))
  (:wait 1)
  (:animate (player wake-up))
  (:go-to (walk-start))
  (:go-to (jump-start :lead catherine)
  ;; acknowledgement that the android's brain, memory, and faculties might not all be present and correct
   "~ catherine
| My name's Catherine. You can follow me, it's okay.
  ")   
  (:go-to (climb-start :lead catherine)
  "~ catherine
| Right, here we go.
  ")  
  (:go-to (rope-start :lead catherine)
  "~ catherine
| (:excited)I hope you like heights.
  ")
  (:go-to (dash-start :lead catherine))
  (:eval
   (ensure-nearby 'dash-start 'catherine)
   (move :freeze 'player)
   (move :left 'catherine))
  (:nearby (dash-end catherine)
           (stop 'catherine)
           (setf (direction 'catherine) +1)
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
| We're almost home - it's just up here.
  ")
  (:go-to (tutorial-end :lead catherine))
    ;; TODO: the last player emotion in the choices is the one that will render; have it change per highlighted choice?
  ;; TODO: replace (Lie) with [Lie] as per RPG convention, and to save parenthetical expressions for asides - currently square brackets not rendering correctly though
  ;; REMARK: ^ Does \[Lie\] not work?
  (:interact (catherine :now T)
   :title "Talk to Catherine"
   :on-complete (q0-settlement-arrive)
   "
~ catherine
| (:cheer)Tada! Here we are!
| What do you think...?
~ player
- It's a ruined city.
  ~ catherine
  | (:excited)Yep! It's home.
- It's nice.
  ~ catherine
  | (:excited)I knew you'd love it!
- (Lie) It's nice.
  ~ catherine
  | (:excited)Really? I knew you'd love it!
- You live here?
  ~ catherine
  | (:excited)Yep! Pretty amazing, huh?
~ catherine
| And come look at this - I guarantee you won't have ever seen anything like it!
  ")
)

;; TODO when name vars persist across saves, init Catherine's name to "Woman" or "???" (VN style), and then set it to Catherine here via: ! eval (setf (nametag player) \"Catherine\") once Catherine has introduced herself
;; SCRATCH Not too talkative though... Don't worry - (:excited)I can talk enough for both of us!

#|

|#

#|
Tutorial/prologue mission beats that must occur:
- Android has memory/function issues, and has been offline for an unknown number of years, probably decades
- Catherine has determined android is a "she" - or assumed...
- Catherine introduced herself by name, but hasn't asked the android's name

Backstory beats:
- Alex planted the android there on behalf of the enemy faction (traitor), knowing that Catherine could repair it for them
- Rogue robots on behalf of the enemy faction then attack the settlement via the water supply, eventually hoping to capture the android in the confusion (but you beat them off - q1)
- Catherine, non-the-wiser to Alex's betrayal, returns to the settlement with the android
(Meanwhile Alex has gone off doing hunter duties)
(The enemy faction timed the android planting with their sabotage of the water pipes, so that Catherine would be away at a critical time)
|#
