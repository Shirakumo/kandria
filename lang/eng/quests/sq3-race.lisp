;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

;; TODO: remove duplication in race choice, factor out into define-race, possibly by allowing you to branch out into separate interactions directly from another interaction.

(quest:define-quest (kandria sq3-race)
  :author "Tim White"
  :title "Timed Travel"
  :description "Catherine wants to see what I'm capable of. She's had Alex plant cans around the region for me to find and bring back. The faster I can do it, the more parts I'll get."
  :on-activate (race-hub)
  (race-hub
   :title "Talk to Catherine to start a race"
   :on-activate T
   (:interaction start-race
    :title "Race against the clock"
    :interactable catherine
    :repeatable T
    :dialogue "
? (or (active-p 'race-1-start) (active-p 'race-2-start) (active-p 'race-3-start) (active-p 'race-4-start) (active-p 'race-5-start))
| ~ catherine
| | (:cheer)You're already on the clock, get goin'!
| < quit

~ catherine
| (:cheer)Alright, race time!
? (not (complete-p 'race-1-start))
| | (:normal)So remember: Find the cans that Alex has planted.
| | I told them to find devious places, and knowing Alex they won't have disappointed.
| | Grab a can, bring it back here, and I'll stop the clock.
| | We'll start you off with Route 1, which is an easy one.
| | Finish this one and I'll tell you about the next route!
| | Alex also gave me some riddles for each place, to give you a clue. Figuring these out might slow you down at first.
| | But once you know where they are, you'll be clocking even faster times I'm sure! So...
| < race-1
|?
| | (:normal)Which route do you wanna do?
| ~ player
| - Route 1
|   < race-1
| - [(var-of 'race-1 'pb) Route 2|]
|   < race-2
| - [(var-of 'race-2 'pb) Route 3|]
|   < race-3
| - [(var-of 'race-3 'pb) Route 4|]
|   < race-4
| - [(var-of 'race-4 'pb) Route 5|]
|   < race-5
| - Back out for now

# race-1
~ catherine
| (:cheer)Route 1! The can is... at a literal high point of EASTERN civilisation, now long gone.
| (:normal)The time brackets are: Gold: {(format-relative-time (var-of 'race-1 'gold))} - Silver: {(format-relative-time (var-of 'race-1 'silver))} - Bronze: {(format-relative-time (var-of 'race-1 'bronze))}.
? (var-of 'race-1 'pb)
| | Your personal best for this route is {(format-relative-time (var-of 'race-1 'pb))}.
! eval (setf (quest:status (thing 'race-1-start)) :inactive)
! eval (setf (quest:status (thing 'race-1)) :inactive)
! eval (activate 'race-1-start)
< end

# race-2
~ catherine
| (:cheer)Route 2! The can is... where a shallow grave marks the end of the line for the West Crossing - from the east.
| (:normal)The time brackets are: Gold: {(format-relative-time (var-of 'race-2 'gold))} - Silver: {(format-relative-time (var-of 'race-2 'silver))} - Bronze: {(format-relative-time (var-of 'race-2 'bronze))}.
? (var-of 'race-2 'pb)
| | Your personal best for this route is {(format-relative-time (var-of 'race-2 'pb))}.
! eval (setf (quest:status (thing 'race-2-start)) :inactive)
! eval (setf (quest:status (thing 'race-2)) :inactive)
! eval (activate 'race-2-start)
< end

# race-3
~ catherine
| (:cheer)Route 3! The can is... where we first ventured together, and got our feet wet.
| (:normal)The time brackets are: Gold: {(format-relative-time (var-of 'race-3 'gold))} - Silver: {(format-relative-time (var-of 'race-3 'silver))} - Bronze: {(format-relative-time (var-of 'race-3 'bronze))}.
? (var-of 'race-3 'pb)
| | Your personal best for this route is {(format-relative-time (var-of 'race-3 'pb))}.
! eval (setf (quest:status (thing 'race-3-start)) :inactive)
! eval (setf (quest:status (thing 'race-3)) :inactive)
! eval (activate 'race-3-start)
< end

# race-4
~ catherine
| (:cheer)Route 4! The can is... deep to the west, where people once dreamed.
| (:normal)The time brackets are: Gold: {(format-relative-time (var-of 'race-4 'gold))} - Silver: {(format-relative-time (var-of 'race-4 'silver))} - Bronze: {(format-relative-time (var-of 'race-4 'bronze))}.
? (var-of 'race-4 'pb)
| | Your personal best for this route is {(format-relative-time (var-of 'race-4 'pb))}.
! eval (setf (quest:status (thing 'race-4-start)) :inactive)
! eval (setf (quest:status (thing 'race-4)) :inactive)
! eval (activate 'race-4-start)
< end

# race-5
~ catherine
| (:cheer)Route 5! The can is at... the furthest edge of the deepest cave in this region - there isn't \"much-room\".
| (:normal)The time brackets are: Gold: {(format-relative-time (var-of 'race-5 'gold))} - Silver: {(format-relative-time (var-of 'race-5 'silver))} - Bronze: {(format-relative-time (var-of 'race-5 'bronze))}.
? (var-of 'race-5 'pb)
| | Your personal best for this route is {(format-relative-time (var-of 'race-5 'pb))}.
! eval (setf (quest:status (thing 'race-5-start)) :inactive)
! eval (setf (quest:status (thing 'race-5)) :inactive)
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
;; TODO bug - deactivating this task causes it's title to appear as another bullet point in the journal (though not deactivating it anymore)
;; TODO: plant multiple objects, encouraging cheating
;; could explain brackets at the start, or let player figure it out themselves from results? Latter
(defmacro define-race (name &key site title-start title-complete bronze silver gold)
  (let ((name-start (trial::mksym #.*package* name '-start)))
    `(progn
       (quest:define-task (kandria sq3-race ,name-start)
         :title ,title-start
         :condition (have 'can)
         :on-activate T
         :on-complete (,name)
         (:action spawn-can
                  (setf (clock quest) 0)
                  (show (make-instance 'timer :quest quest))
                  (spawn ',site 'can)
                  (setf (quest:status (thing ',name)) :inactive)
                  )
         (:interaction speech
          :interactable ,site
          :repeatable T
          :dialogue "
~ player
| //This is the right place - the can must be close by.//
"))
       (quest:define-task (kandria sq3-race ,name)
         :title "Return the can to Catherine ASAP"
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
! eval (hide-panel 'timer)
~ catherine
| (:cheer)Stop the clock!
| (:excited)That's the correct can alright - nice!
! eval (retrieve 'can)
| (:normal)You did that in: {(format-relative-time (clock quest))}.
? (and pb (< pb (clock quest)))
| | Ah damn, no improvement on your record of {(format-relative-time pb)} this time I'm afraid. Better luck next time though!
| < end
|?
| ? (not (null pb))
| | | (:cheer)That's a new personal best!
| ! eval (setf pb (clock quest))
| ? (< pb gold)
| | | (:cheer)How did you do that so fast? That's gold bracket.
| | | You get the top reward - 30 scrap parts!
| | ! eval (store 'parts 30)
| |? (< pb silver)
| | | (:excited)That's pretty quick! Silver bracket.
| | | That nets you 15 scrap parts!
| | ! eval (store 'parts 15)
| |? (< pb bronze)
| | | (:excited)Not bad! That's bronze bracket.
| | | That gets you 10 scrap parts.
| | ! eval (store 'parts 10)
| |?
| | | (:disappointed)Hmmm, that seems a little slow, Stranger. I think you can do better than that.
| | | Don't think I can give you any parts for that, sorry.
| ! label end
| | (:excited)Let's do this again soon!
| ! eval (complete task)
")))))
;; | ! eval (complete task)
;; ! eval (complete ,name)
;; ! eval (setf (quest:status (thing name)) :complete)

(define-race race-1
  :site race-1-site
  :title-start "The can is... at a literal high point of EASTERN civilisation, now long gone."
  :title-complete "Complete Route 1"
  :gold 60
  :silver 80
  :bronze 100)

(define-race race-2
  :site race-2-site
  :title-start "The can is... where a shallow grave marks the end of the line for the West Crossing - from the east."
  :title-complete "Complete Route 2"
  :gold 90
  :silver 120
  :bronze 150)

(define-race race-3
  :site race-3-site
  :title-start "The can is... where we first ventured together, and got our feet wet."
  :title-complete "Complete Route 3"
  :gold 120
  :silver 150
  :bronze 180)

(define-race race-4
  :site race-4-site
  :title-start "The can is... deep to the west, where people once dreamed."
  :title-complete "Complete Route 4"
  :gold 150
  :silver 210
  :bronze 270)

(define-race race-5
  :site race-5-site
  :title-start "The can is at... the furthest edge of the deepest cave in this region - there isn't much-room."
  :title-complete "Complete Route 5"
  :gold 150
  :silver 210
  :bronze 270)
