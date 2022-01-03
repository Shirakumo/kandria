;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

;; TODO: remove duplication in race choice, factor out into define-race, possibly by allowing you to branch out into separate interactions directly from another interaction.

(quest:define-quest (kandria sq3-race)
  :author "Tim White"
  :title "Timed Travel"
  :description "Catherine and her friends want to see what I'm capable of. They've planted cans around the region for me to find and bring back. The faster I can do it, the more parts I'll get."
  :on-activate (race-hub)
  (race-hub
   :title "Talk to Catherine in Engineering to start a race"
   :on-activate T
   (:interaction start-race
    :title "About the race."
    :interactable catherine
    :repeatable T
    :dialogue "
? (or (active-p 'race-1-start) (active-p 'race-1))
| ~ catherine
| | (:cheer)You're already on the clock for \"Route 1\"(orange).
| | Remember: The can is at... \"a literal high point of EASTERN civilisation, now long gone\"(orange).
| < quit
|? (or (active-p 'race-2-start) (active-p 'race-2))
| ~ catherine
| | (:cheer)You're already on the clock for \"Route 2\"(orange).
| | Remember: The can is... \"where a shallow grave marks the end of the line at Zenith Crossing Station, East\"(orange).
| < quit
|? (or (active-p 'race-3-start) (active-p 'race-3))
| ~ catherine
| | (:cheer)You're already on the clock for \"Route 3\"(orange).
| | Remember: The can is... \"beneath where we first ventured together - you'll get your feet wet\"(orange).
| < quit
|? (or (active-p 'race-4-start) (active-p 'race-4))
| ~ catherine
| | (:cheer)You're already on the clock for \"Route 4\"(orange).
| | Remember: The can is... \"deep in the west, where we first met\"(orange).
| < quit
|? (or (active-p 'race-5-start) (active-p 'race-5))
| ~ catherine
| | (:cheer)You're already on the clock for \"Route 5\"(orange).
| | Remember: The can is at... \"the furthest edge of the deepest cave in this region - there isn't //much-room//\"(orange).
| < quit
~ catherine
| (:cheer)Alright, race time!
? (not (complete-p 'race-1-start))
| | (:excited)You ready for this?
| ~ player
| - Let's go.
| - Not right now.
|   ~ catherine
|   | No worries. (:excited)Let's do this soon!
|   < quit
| ~ catherine
| | (:normal)So remember: \"Find the can\"(orange) that we've planted.
| | (:normal)\"Grab the can, bring it back here, and I'll stop the clock.\"(orange)
| | We'll start you off with \"Route 1\"(orange), which is easy.
| | Finish this one and I'll tell you about the next route.
| | You can try routes as many times as you want, but you'll \"only get a reward if you beat your previous best time\"(orange).
| | We've also got some \"riddles\"(orange) for each place, to give you a clue. Figuring these out might slow you down at first.
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
| (:cheer)\"Route 1\"(orange)! The can is at... \"a literal high point of EASTERN civilisation, now long gone\"(orange).
| (:normal)The time brackets are: \"Gold:\"(orange) {(format-relative-time (var-of 'race-1 'gold))} - \"Silver:\"(orange) {(format-relative-time (var-of 'race-1 'silver))} - \"Bronze:\"(orange) {(format-relative-time (var-of 'race-1 'bronze))}.
? (var-of 'race-1 'pb)
| | Your personal best for this route is \"{(format-relative-time (var-of 'race-1 'pb))}\"(orange).
! eval (reset* 'race-1 'race-1-start)
! eval (activate 'race-1-start)
< end

# race-2
~ catherine
| (:cheer)\"Route 2\"(orange)! The can is... \"where a shallow grave marks the end of the line at Zenith Crossing Station, East\"(orange).
| (:normal)The time brackets are: \"Gold:\"(orange) {(format-relative-time (var-of 'race-2 'gold))} - \"Silver:\"(orange) {(format-relative-time (var-of 'race-2 'silver))} - \"Bronze:\"(orange) {(format-relative-time (var-of 'race-2 'bronze))}.
? (var-of 'race-2 'pb)
| | Your personal best for this route is \"{(format-relative-time (var-of 'race-2 'pb))}\"(orange).
! eval (reset* 'race-2 'race-2-start)
! eval (activate 'race-2-start)
< end

# race-3
~ catherine
| (:cheer)\"Route 3\"(orange)! The can is... \"beneath where we first ventured together - you'll get your feet wet\"(orange).
| (:normal)The time brackets are: \"Gold:\"(orange) {(format-relative-time (var-of 'race-3 'gold))} - \"Silver:\"(orange) {(format-relative-time (var-of 'race-3 'silver))} - \"Bronze:\"(orange) {(format-relative-time (var-of 'race-3 'bronze))}.
? (var-of 'race-3 'pb)
| | Your personal best for this route is \"{(format-relative-time (var-of 'race-3 'pb))}\"(orange).
! eval (reset* 'race-3 'race-3-start)
! eval (activate 'race-3-start)
< end

# race-4
~ catherine
| (:cheer)\"Route 4\"(orange)! The can is... \"deep in the west, where we first met\"(orange).
| (:normal)The time brackets are: \"Gold:\"(orange) {(format-relative-time (var-of 'race-4 'gold))} - \"Silver:\"(orange) {(format-relative-time (var-of 'race-4 'silver))} - \"Bronze:\"(orange) {(format-relative-time (var-of 'race-4 'bronze))}.
? (var-of 'race-4 'pb)
| | Your personal best for this route is \"{(format-relative-time (var-of 'race-4 'pb))}\"(orange).
! eval (reset* 'race-4 'race-4-start)
! eval (activate 'race-4-start)
< end

# race-5
~ catherine
| (:cheer)\"Route 5\"(orange)! The can is at... \"the furthest edge of the deepest cave in this region - there isn't //much-room//\"(orange).
| (:normal)The time brackets are: \"Gold:\"(orange) {(format-relative-time (var-of 'race-5 'gold))} - \"Silver:\"(orange) {(format-relative-time (var-of 'race-5 'silver))} - \"Bronze:\"(orange) {(format-relative-time (var-of 'race-5 'bronze))}.
? (var-of 'race-5 'pb)
| | Your personal best for this route is \"{(format-relative-time (var-of 'race-5 'pb))}\"(orange).
! eval (reset* 'race-5 'race-5-start)
! eval (activate 'race-5-start)
< end

# end
| ~ catherine
| (:shout)[? Time starts... Now! | Ready?... Set... Go! | Three... Two... One... Go Stranger! | Sync your chronometer and... Go!]
# quit
")))

;; TODO different rewards for different routes, without copy-paste?
;; TODO: allow play to opt out of first race encountered, not forced
;; TODO: cancel a race in progress? restart a race that's gone wrong? - not sure; it would have to be done by returning to Catherine, not from the UI, to preserve immersion (death is different, but restarting races from UI is fine in a driving game, not in an RPG?)
;; - in which case if have to return to Catherine anyway, is there much point? Just hand the race in anyway and get the fun poor performance dialogue?
;; TODO: acknowledge in the flow when a new route has unlocked?
;; TODO: have a different item per race, e.g. phone, bottle, etc. Need to render them though?
;; TODO bug - deactivating this task causes it's title to appear as another bullet point in the journal (though not deactivating it any more)
;; TODO: plant multiple objects, encouraging cheating
;; could explain brackets at the start, or let player figure it out themselves from results? Latter
(defmacro define-race (name &key site title-start title-complete bronze silver gold)
  (let ((name-start (trial::mksym #.*package* name '-start)))
    `(progn
       (quest:define-task (kandria sq3-race ,name-start)
         :title ,title-start
         :condition (have 'item:can)
         :on-activate T
         :on-complete (,name)
         (:action spawn-can
                  (setf (clock quest) 0)
                  (show-timer quest)
                  (spawn ',site 'item:can)
                  (setf (quest:status (thing ',name)) :inactive))
         (:interaction speech
          :interactable ,site
          :repeatable T
          :dialogue "
~ player
| \"This is the right place for the race - \"the can must be close by\"(orange).\"(light-gray, italic)
"))
       (quest:define-task (kandria sq3-race ,name)
         :title "Return the can to Catherine in Engineering ASAP"
         :on-activate T
         :condition all-complete
         :on-complete (race-hub)
         :variables ((gold ,gold)
                     (silver ,silver)
                     (bronze ,bronze)
                     pb)
         (:action activate
                  (setf (quest:status (thing 'chat)) :inactive)
                  (activate 'chat))
         (:interaction chat
          :title ,title-complete
          :interactable catherine
          :dialogue "
! eval (hide-timer)
~ catherine
| (:cheer)Stop the clock!
| (:excited)That's the correct can alright - nice.
! eval (retrieve 'item:can)
| (:normal)You did that in: \"{(format-relative-time (clock quest))}\"(orange).
? (and pb (< pb (clock quest)))
| | (:concerned)Ah damn, no improvement on your record of \"{(format-relative-time pb)}\"(orange) this time I'm afraid.
|?
| ? (not (null pb))
| | | (:cheer)\"That's a new personal best\"(orange)!
| ! eval (setf pb (clock quest))
| ? (< pb gold)
| | | (:cheer)How did you do that so fast? That's \"gold bracket\"(orange).
| | | You get the top reward - \"250 scrap parts\"(orange)!
| | ! eval (store 'item:parts 250)
| |? (< pb silver)
| | | (:excited)That was pretty quick! \"Silver bracket\"(orange).
| | | That nets you \"150 scrap parts\"(orange)!
| | ! eval (store 'item:parts 150)
| |? (< pb bronze)
| | | (:excited)That wasn't a bad time at all - \"bronze bracket\"(orange).
| | | That gets you \"100 scrap parts\"(orange).
| | ! eval (store 'item:parts 100)
| |?
| | | (:disappointed)That time was outside bronze. I didn't know artificial muscles could get sore too.
| | | (:normal)Don't worry, you can always try again. (:concerned)But I don't think I can give you any parts for that, sorry.
  
~ catherine
| (:excited)Let's do this again soon!
! eval (complete task)
")))))


;; TODO These vars stored in save game? Problematic if we tweak after launch/testing?
(define-race race-1
  :site race-1-site
  :title-start "The can is at... a literal high point of EASTERN civilisation, now long gone."
  :title-complete "(Complete Route 1)"
  :gold 60
  :silver 80
  :bronze 100)

(define-race race-2
  :site race-2-site
  :title-start "The can is... where a shallow grave marks the end of the line at Zenith Crossing Station, East."
  :title-complete "(Complete Route 2)"
  :gold 60
  :silver 80
  :bronze 100)

(define-race race-3
  :site race-3-site
  :title-start "The can is... beneath where we first ventured together - you'll get your feet wet."
  :title-complete "(Complete Route 3)"
  :gold 105
  :silver 120
  :bronze 135)

(define-race race-4
  :site race-4-site
  :title-start "The can is... deep in the west, where we first met."
  :title-complete "(Complete Route 4)"
  :gold 90
  :silver 105
  :bronze 120)

(define-race race-5
  :site race-5-site
  :title-start "The can is at... the furthest edge of the deepest cave in this region - there isn't \"much-room\"."
  :title-complete "(Complete Route 5)"
  :gold 135
  :silver 150
  :bronze 165)
