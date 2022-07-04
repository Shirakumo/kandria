;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

;; TODO: remove duplication in race choice, factor out into define-race, possibly by allowing you to branch out into separate interactions directly from another interaction.

(quest:define-quest (kandria sq3-race)
  :author "Tim White"
  :title "Catherine's Time Trials"
  :description "Catherine and her friends want to see what I'm capable of. They've planted cans for me to find and bring back. The faster I can do it, the more parts I'll get."
  :on-activate (race-hub)
  (race-hub
   :title "Talk to Catherine in Engineering to start a race"
   :marker '(catherine 500)
   :invariant (not (complete-p 'q10-wraw))
   :on-activate T
   (:interaction start-race
    :title "About the race."
    :interactable catherine
    :repeatable T
    :dialogue "
? (or (active-p 'race-1-start) (active-p 'race-1))
| ~ catherine
| | (:cheer)You're on the clock for \"Route 1\"(orange).
| | (:excited)The can is at... \"a literal high point of EASTERN civilisation, now long gone\"(orange).
| | (:normal)The time brackets are: \"Gold:\"(orange) {(format-relative-time (var-of 'race-1 'gold))} - \"Silver:\"(orange) {(format-relative-time (var-of 'race-1 'silver))} - \"Bronze:\"(orange) {(format-relative-time (var-of 'race-1 'bronze))}.
| < quit
|? (or (active-p 'race-2-start) (active-p 'race-2))
| ~ catherine
| | (:cheer)You're on the clock for \"Route 2\"(orange).
| | (:excited)The can is... \"where a shallow grave marks the end of the line at Zenith Crossing Station, East\"(orange).
| | (:normal)The time brackets are: \"Gold:\"(orange) {(format-relative-time (var-of 'race-2 'gold))} - \"Silver:\"(orange) {(format-relative-time (var-of 'race-2 'silver))} - \"Bronze:\"(orange) {(format-relative-time (var-of 'race-2 'bronze))}.
| < quit
|? (or (active-p 'race-3-start) (active-p 'race-3))
| ~ catherine
| | (:cheer)You're on the clock for \"Route 3\"(orange).
| | (:excited)The can is... \"beneath where we first ventured together, and got our feet wet\"(orange).
| | (:normal)The time brackets are: \"Gold:\"(orange) {(format-relative-time (var-of 'race-3 'gold))} - \"Silver:\"(orange) {(format-relative-time (var-of 'race-3 'silver))} - \"Bronze:\"(orange) {(format-relative-time (var-of 'race-3 'bronze))}.
| < quit
|? (or (active-p 'race-4-start) (active-p 'race-4))
| ~ catherine
| | (:cheer)You're on the clock for \"Route 4\"(orange).
| | (:excited)The can is... \"deep in the west, where we first met\"(orange).
| | (:normal)The time brackets are: \"Gold:\"(orange) {(format-relative-time (var-of 'race-4 'gold))} - \"Silver:\"(orange) {(format-relative-time (var-of 'race-4 'silver))} - \"Bronze:\"(orange) {(format-relative-time (var-of 'race-4 'bronze))}.
| < quit
|? (or (active-p 'race-5-start) (active-p 'race-5))
| ~ catherine
| | (:cheer)You're on the clock for \"Route 5\"(orange).
| | (:excited)The can is at... \"the furthest edge of the deepest cave in this region - there isn't //much-room//\"(orange).
| | (:normal)The time brackets are: \"Gold:\"(orange) {(format-relative-time (var-of 'race-5 'gold))} - \"Silver:\"(orange) {(format-relative-time (var-of 'race-5 'silver))} - \"Bronze:\"(orange) {(format-relative-time (var-of 'race-5 'bronze))}.
| < quit
~ catherine
| (:cheer)Alright, race time!
? (not (var-of 'race-1 'pb))
| | (:excited)You ready for this?
| ~ player
| - Let's go.
| - Not right now.
|   ~ catherine
|   | No worries. (:excited)Let's do this soon!
|   < quit
| ~ catherine
| | (:normal)So remember: \"Find the can\"(orange) that we've planted.
| | (:normal)\"Grab it, bring it back here, and I'll stop the clock.\"(orange)
| | We'll start you off with \"Route 1\"(orange), which is easy.
| | \"Finish this one and I'll tell you about the next route.\"(orange)
| | You can try routes as many times as you want, but you'll \"only get a reward on later runs if you beat your previous best time\"(orange).
| | We've also got some \"riddles\"(orange) for each location, to give you a clue. Figuring these out might slow you down at first.
| | But once you know where they are, (:excited)you'll be clocking even faster times I'm sure. So...
| < race-1
|?
| | (:normal)Which route do you wanna do?
| ~ player
| - Route 1.
|   < race-1
| - [(var-of 'race-1 'pb) Route 2.|]
|   < race-2
| - [(var-of 'race-2 'pb) Route 3.|]
|   < race-3
| - [(var-of 'race-3 'pb) Route 4.|]
|   < race-4
| - [(var-of 'race-4 'pb) Route 5.|]
|   < race-5
| - (Back out for now)

# race-1
~ catherine
| (:cheer)\"Route 1\"(orange)! The beer can is at... \"a literal high point of EASTERN civilisation, now long gone\"(orange).
| (:normal)The time brackets are: \"Gold:\"(orange) {(format-relative-time (var-of 'race-1 'gold))} - \"Silver:\"(orange) {(format-relative-time (var-of 'race-1 'silver))} - \"Bronze:\"(orange) {(format-relative-time (var-of 'race-1 'bronze))}.
? (var-of 'race-1 'pb)
| | Your personal best for this route is \"{(format-relative-time (var-of 'race-1 'pb))}\"(orange).
! eval (reset* 'race-1 'race-1-start)
! eval (activate 'race-1-start)
< end

# race-2
~ catherine
| (:cheer)\"Route 2\"(orange)! The beer can is... \"where a shallow grave marks the end of the line at Zenith Crossing Station, East\"(orange).
| (:normal)The time brackets are: \"Gold:\"(orange) {(format-relative-time (var-of 'race-2 'gold))} - \"Silver:\"(orange) {(format-relative-time (var-of 'race-2 'silver))} - \"Bronze:\"(orange) {(format-relative-time (var-of 'race-2 'bronze))}.
? (var-of 'race-2 'pb)
| | Your personal best for this route is \"{(format-relative-time (var-of 'race-2 'pb))}\"(orange).
! eval (reset* 'race-2 'race-2-start)
! eval (activate 'race-2-start)
< end

# race-3
~ catherine
| (:cheer)\"Route 3\"(orange)! The beer can is... \"beneath where we first ventured together, and got our feet wet\"(orange).
| (:normal)The time brackets are: \"Gold:\"(orange) {(format-relative-time (var-of 'race-3 'gold))} - \"Silver:\"(orange) {(format-relative-time (var-of 'race-3 'silver))} - \"Bronze:\"(orange) {(format-relative-time (var-of 'race-3 'bronze))}.
? (var-of 'race-3 'pb)
| | Your personal best for this route is \"{(format-relative-time (var-of 'race-3 'pb))}\"(orange).
! eval (reset* 'race-3 'race-3-start)
! eval (activate 'race-3-start)
< end

# race-4
~ catherine
| (:cheer)\"Route 4\"(orange)! The beer can is... \"deep in the west, where we first met\"(orange).
| (:normal)The time brackets are: \"Gold:\"(orange) {(format-relative-time (var-of 'race-4 'gold))} - \"Silver:\"(orange) {(format-relative-time (var-of 'race-4 'silver))} - \"Bronze:\"(orange) {(format-relative-time (var-of 'race-4 'bronze))}.
? (var-of 'race-4 'pb)
| | Your personal best for this route is \"{(format-relative-time (var-of 'race-4 'pb))}\"(orange).
! eval (reset* 'race-4 'race-4-start)
! eval (activate 'race-4-start)
< end

# race-5
~ catherine
| (:cheer)\"Route 5\"(orange)! The beer can is at... \"the furthest edge of the deepest cave in this region - there isn't //much-room//\"(orange).
| (:normal)The time brackets are: \"Gold:\"(orange) {(format-relative-time (var-of 'race-5 'gold))} - \"Silver:\"(orange) {(format-relative-time (var-of 'race-5 'silver))} - \"Bronze:\"(orange) {(format-relative-time (var-of 'race-5 'bronze))}.
? (var-of 'race-5 'pb)
| | Your personal best for this route is \"{(format-relative-time (var-of 'race-5 'pb))}\"(orange).
! eval (reset* 'race-5 'race-5-start)
! eval (activate 'race-5-start)
< end

# end
| ~ catherine
| (:excited)[? Time starts... Now! | Ready?... Set... Go! | Three... Two... One... Go Stranger! | Sync your chronometer and... Go!]
! eval (clear-pending-interactions)
# quit
")))

(defmacro define-race (name &key site site-mark mark-size title-start title-complete title-cancel bronze silver gold)
  (let ((name-start (trial::mksym #.*package* name '-start)))
    `(progn
       (quest:define-task (kandria sq3-race ,name-start)
         :title ,title-start
         :marker '(,site-mark ,mark-size)
         :invariant (not (complete-p 'q10-wraw))
         :condition (have 'item:can)
         :on-activate T
         :on-complete (,name)
         :variables ((gold ,gold)
                     (silver ,silver)
                     (bronze ,bronze)
                     pb)
         (:action spawn-can
                  (setf (clock quest) 0)
                  (show-timer quest)
                  (spawn ',site 'item:can)
                  (setf (quest:status (thing ',name)) :inactive))
                  
         (:interaction speech
          :interactable ,site
          :repeatable T
          :source '("catherine-race" "site"))
                  
         (:interaction cancel
          :title ,title-cancel
          :interactable catherine
          :repeatable T
          :source '("catherine-race" "cancel")))

       (quest:define-task (kandria sq3-race ,name)
         :title "Return the can to Catherine in Engineering ASAP"
         :marker '(catherine 500)
         :invariant (not (complete-p 'q10-wraw))
         :on-activate T
         :condition all-complete
         :on-complete (race-hub)
         :variables ((gold ,gold)
                     (silver ,silver)
                     (bronze ,bronze)
                     pb)
         (:action activate
                  (setf (quest:status (thing 'chat)) :inactive)
                  (activate 'cancel 'chat))
         
         (:interaction cancel
          :title ,title-cancel
          :interactable catherine
          :repeatable T
          :source '("catherine-race" "cancel"))
         
         (:interaction chat
          :title ,title-complete
          :interactable catherine
          :source '("catherine-race" "complete"))))))


;; TODO These vars stored in save game? Problematic if we tweak after launch/testing?
(define-race race-1
  :site race-1-site
  :site-mark chunk-1841
  :mark-size 1400
  :title-start "\"The can is at... a literal high point of EASTERN civilisation, now long gone.\""
  :title-complete "(Complete Race Route 1)"
  :title-cancel "(Cancel Race Route 1)"
  :gold 60
  :silver 80
  :bronze 120)

(define-race race-2
  :site race-2-site
  :site-mark chunk-2480
  :mark-size 3000
  :title-start "\"The can is... where a shallow grave marks the end of the line at Zenith Crossing Station, East.\""
  :title-complete "(Complete Race Route 2)"
  :title-cancel "(Cancel Race Route 2)"
  :gold 60
  :silver 80
  :bronze 120)

(define-race race-3
  :site race-3-site
  :site-mark chunk-2482
  :mark-size 1600
  :title-start "\"The can is... beneath where we first ventured together, and got our feet wet.\""
  :title-complete "(Complete Race Route 3)"
  :title-cancel "(Cancel Race Route 3)"
  :gold 105
  :silver 120
  :bronze 150)

(define-race race-4
  :site race-4-site
  :site-mark chunk-5426
  :mark-size 1600
  :title-start "\"The can is... deep in the west, where we first met.\""
  :title-complete "(Complete Race Route 4)"
  :title-cancel "(Cancel Race Route 4)"
  :gold 90
  :silver 105
  :bronze 135)

(define-race race-5
  :site race-5-site
  :site-mark chunk-2019
  :mark-size 2600
  :title-start "\"The can is at... the furthest edge of the deepest cave in this region - there isn't \"much-room\".\""
  :title-complete "(Complete Race Route 5)"
  :title-cancel "(Cancel Race Route 5)"
  :gold 135
  :silver 150
  :bronze 180)
