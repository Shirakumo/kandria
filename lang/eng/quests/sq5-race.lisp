;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

;; TODO: remove duplication in race choice, factor out into define-race, possibly by allowing you to branch out into separate interactions directly from another interaction.

;; uses walkie-talkie when talking to hunters, since these poorer Semis don't have access to the FFCS tech. Though they are more powerful walkie-talkies, able to cover larger distances than the Noka's
(quest:define-quest (kandria sq5-race)
  :author "Tim White"
  :title "Barkeep's Time Trials"
  :description "A Semi Sisters barkeep and their clientele are bored; they're organising a sweepstake to see if (when) I can beat the item retrieval times set by their best hunters. They're going to plant... broken Genera cores, of all things, for me to find and bring back. The faster I do it, the bigger my cut from the sweepstake."
  :on-activate (race-hub)
  (race-hub
   :title "Talk to the barkeep in the Semi Sisters Central Block to start a race"
   :marker '(semi-barkeep 500)
   :invariant (not (complete-p 'q10-wraw))
   :on-activate T
   (:interaction start-race
    :title "About the race."
    :interactable semi-barkeep
    :repeatable T
    :dialogue "
? (or (active-p 'race-1-start) (active-p 'race-1))
| ~ semi-barkeep
| | You're in the middle of \"Route 1\"(orange)!
| | \"Find the Genera core\"(orange) near the \"Semi sign, to the high west of the Central Block\"(orange), then return it to me.
| | Our best hunter times are: \"Gold:\"(orange) {(format-relative-time (var-of 'race-1 'gold))} - \"Silver:\"(orange) {(format-relative-time (var-of 'race-1 'silver))} - \"Bronze:\"(orange) {(format-relative-time (var-of 'race-1 'bronze))}.
| < quit
|? (or (active-p 'race-2-start) (active-p 'race-2))
| ~ semi-barkeep
| | You're in the middle of \"Route 2\"(orange)!
| | \"Find the Genera core\"(orange) in the \"engineers' camp, to the far high west of our territory\"(orange), then return it to me.
| | Our best hunter times are: \"Gold:\"(orange) {(format-relative-time (var-of 'race-2 'gold))} - \"Silver:\"(orange) {(format-relative-time (var-of 'race-2 'silver))} - \"Bronze:\"(orange) {(format-relative-time (var-of 'race-2 'bronze))}.
| < quit
|? (or (active-p 'race-3-start) (active-p 'race-3))
| ~ semi-barkeep
| | You're in the middle of \"Route 3\"(orange)!
| | \"Find the Genera core\"(orange) in the \"old android factory, to the far east of our territory\"(orange), then return it to me.
| | Our best hunter times are: \"Gold:\"(orange) {(format-relative-time (var-of 'race-3 'gold))} - \"Silver:\"(orange) {(format-relative-time (var-of 'race-3 'silver))} - \"Bronze:\"(orange) {(format-relative-time (var-of 'race-3 'bronze))}.
| < quit
|? (or (active-p 'race-4-start) (active-p 'race-4))
| ~ semi-barkeep
| | You're in the middle of \"Route 4\"(orange)!
| | \"Find the Genera core\"(orange) in a \"crevice to the high east of our territory, beneath the old Semi factory in the Ruins\"(orange) - then return it to me.
| | Our best hunter times are: \"Gold:\"(orange) {(format-relative-time (var-of 'race-4 'gold))} - \"Silver:\"(orange) {(format-relative-time (var-of 'race-4 'silver))} - \"Bronze:\"(orange) {(format-relative-time (var-of 'race-4 'bronze))}.
| < quit
|? (or (active-p 'race-5-start) (active-p 'race-5))
| ~ semi-barkeep
| | You're in the middle of \"Route 5\"(orange)!
| | \"Find the Genera core\"(orange) in a \"cave to the high east of our territory, beneath the old Rootless hospital apartments\"(orange) - then return it to me.
| | Our best hunter times are: \"Gold:\"(orange) {(format-relative-time (var-of 'race-5 'gold))} - \"Silver:\"(orange) {(format-relative-time (var-of 'race-5 'silver))} - \"Bronze:\"(orange) {(format-relative-time (var-of 'race-5 'bronze))}.
| < quit
|? (or (active-p 'race-6-start) (active-p 'race-6))
| ~ semi-barkeep
| | You're in the middle of \"Route 6\"(orange)!
| | \"Find the Genera core\"(orange) near the \"Cerebats sign - the second one en route to their land, via our low-western border\"(orange). Then return it to me.
| | \"Beware\"(orange): it's foreign territory.
| | Our best hunter times are: \"Gold:\"(orange) {(format-relative-time (var-of 'race-6 'gold))} - \"Silver:\"(orange) {(format-relative-time (var-of 'race-6 'silver))} - \"Bronze:\"(orange) {(format-relative-time (var-of 'race-6 'bronze))}.
| < quit
~ semi-barkeep
| Is it show time? You ready to race?
~ player
- I'm ready.
- Not now.
  ~ semi-barkeep
  | You got it - just say the word. But the stash is getting fat!
  < quit
~ semi-barkeep
| Très bien! Then all that remains is for you to choose your route:
~ player
- Route 1.
  < race-1
- Route 2.
  < race-2
- Route 3.
  < race-3
- Route 4.
  < race-4
- Route 5.
  < race-5
- Route 6.
  < race-6
- (Back out for now)

# race-1
~ semi-barkeep
| \"Route 1\"(orange): You'll \"find the Genera core\"(orange) near the \"Semi sign, to the high west of the Central Block\"(orange).
| Hunter, did you overhear that? Drop the core at this location. Over and out.
| Our best hunter times for this route are: \"Gold:\"(orange) {(format-relative-time (var-of 'race-1 'gold))} - \"Silver:\"(orange) {(format-relative-time (var-of 'race-1 'silver))} - \"Bronze:\"(orange) {(format-relative-time (var-of 'race-1 'bronze))}.
? (var-of 'race-1 'pb)
| | Your personal best for this route is \"{(format-relative-time (var-of 'race-1 'pb))}\"(orange).
! eval (reset* 'race-1 'race-1-start)
! eval (activate 'race-1-start)
< end

# race-2
~ semi-barkeep
| \"Route 2\"(orange): You'll \"find the Genera core\"(orange) in the \"engineers' camp, to the far high west of our territory\"(orange).
? (active-p (unit 'blocker-engineers))
| | I know for a fact that the engineers have some cores - but they're trapped. You might want to \"help them as well\"(orange), if you have time.
|?
| | Now the tunnel is cleared - well done, by the way - the hunters can get through.
| | Hunter, did you overhear that? Drop the core at the engineers' camp. Over and out.
  
| Our best hunter times for this route are: \"Gold:\"(orange) {(format-relative-time (var-of 'race-2 'gold))} - \"Silver:\"(orange) {(format-relative-time (var-of 'race-2 'silver))} - \"Bronze:\"(orange) {(format-relative-time (var-of 'race-2 'bronze))}.
? (active-p (unit 'blocker-engineers))
| | Admittedly, these were set when the tunnel was clear.
? (var-of 'race-2 'pb)
| | Your personal best for this route is \"{(format-relative-time (var-of 'race-2 'pb))}\"(orange).
! eval (reset* 'race-2 'race-2-start)
! eval (activate 'race-2-start)
< end

# race-3
~ semi-barkeep
| \"Route 3\"(orange): You'll \"find the Genera core\"(orange) in the \"old android factory, to the far east of our territory\"(orange).
| Hunter, did you overhear that? Drop the core at this location. Over and out.
| Our best hunter times for this route are: \"Gold:\"(orange) {(format-relative-time (var-of 'race-3 'gold))} - \"Silver:\"(orange) {(format-relative-time (var-of 'race-3 'silver))} - \"Bronze:\"(orange) {(format-relative-time (var-of 'race-3 'bronze))}.
? (var-of 'race-3 'pb)
| | Your personal best for this route is \"{(format-relative-time (var-of 'race-3 'pb))}\"(orange).
! eval (reset* 'race-3 'race-3-start)
! eval (activate 'race-3-start)
< end

# race-4
~ semi-barkeep
| \"Route 4\"(orange): You'll \"find the Genera core\"(orange) in a \"crevice to the high east of our territory, beneath the old Semi factory in the Ruins\"(orange).
| Hunter, did you overhear that? Drop the core at this location. Over and out.
| Our best hunter times for this route are: \"Gold:\"(orange) {(format-relative-time (var-of 'race-4 'gold))} - \"Silver:\"(orange) {(format-relative-time (var-of 'race-4 'silver))} - \"Bronze:\"(orange) {(format-relative-time (var-of 'race-4 'bronze))}.
? (var-of 'race-4 'pb)
| | Your personal best for this route is \"{(format-relative-time (var-of 'race-4 'pb))}\"(orange).
! eval (reset* 'race-4 'race-4-start)
! eval (activate 'race-4-start)
< end

# race-5
~ semi-barkeep
| \"Route 5\"(orange): You'll \"find the Genera core\"(orange) in a \"cave to the high east of our territory, beneath the old Rootless hospital apartments\"(orange).
| Hunter, did you overhear that? Drop the core at this location. Over and out.
| Our best hunter times for this route are: \"Gold:\"(orange) {(format-relative-time (var-of 'race-5 'gold))} - \"Silver:\"(orange) {(format-relative-time (var-of 'race-5 'silver))} - \"Bronze:\"(orange) {(format-relative-time (var-of 'race-5 'bronze))}.
? (var-of 'race-5 'pb)
| | Your personal best for this route is \"{(format-relative-time (var-of 'race-5 'pb))}\"(orange).
! eval (reset* 'race-5 'race-5-start)
! eval (activate 'race-5-start)
< end

# race-6
~ semi-barkeep
| \"Route 6\"(orange): You'll \"find the Genera core\"(orange) near the \"Cerebats sign - the second one en route to their land, via our low-western border\"(orange).
| Hunter, did you overhear that? Drop the core at this location. Over and out.
| Our best hunter times for this route are: \"Gold:\"(orange) {(format-relative-time (var-of 'race-6 'gold))} - \"Silver:\"(orange) {(format-relative-time (var-of 'race-6 'silver))} - \"Bronze:\"(orange) {(format-relative-time (var-of 'race-6 'bronze))}.
? (var-of 'race-6 'pb)
| | Your personal best for this route is \"{(format-relative-time (var-of 'race-6 'pb))}\"(orange).
! eval (reset* 'race-6 'race-6-start)
! eval (activate 'race-6-start)
< end

# end
| ~ semi-barkeep
| Commencer!
! eval (clear-pending-interactions)
# quit
")))
;; the barkeep knows about the trapped engineers, more so than Innis (they have radio contact) - hence what they say, and the mention of rescue; they're still more interested in the races though
;; this is also how they know the tunnel got cleared soon after you clear it
;; they speak using "our" a lot, despite being disparaging towards Innis and Islay, because they still view themselves as part of the Semi Sisters - just a different faction within them

(defmacro define-race (name &key site site-mark mark-size title-start title-complete title-cancel bronze silver gold)
  (let ((name-start (trial::mksym #.*package* name '-start)))
    `(progn
       (quest:define-task (kandria sq5-race ,name-start)
         :title ,title-start
         :marker '(,site-mark ,mark-size)
         :invariant (not (complete-p 'q10-wraw))
         :condition (have 'item:semi-genera-core)
         :on-activate T
         :on-complete (,name)
         (:action spawn-can
                  (setf (clock quest) 0)
                  (show-timer quest)
                  (spawn ',site 'item:semi-genera-core)
                  (setf (quest:status (thing ',name)) :inactive))
                  
         (:interaction speech
          :interactable ,site
          :repeatable T
          :dialogue "
~ player
| \"This is the right place for the race - \"the broken Genera core must be close by\"(orange).\"(light-gray, italic)
")
                  
         (:interaction cancel
          :title ,title-cancel
          :interactable semi-barkeep
          :repeatable T
          :dialogue "
~ semi-barkeep
| \"You want to stop the race?\"(orange) There's no reward if you do that - and you'll be making everyone very sad.
~ player
- No, I'll continue the race.
  ~ semi-barkeep
  | Good. Now get going. Time is money.
- Yes, end it.
  ! eval (hide-timer)
  ~ semi-barkeep
  | If you insist. But you'll be back, I just know it.
  ! eval (reset* task)
  ! eval (leave 'item:semi-genera-core)
"))

       (quest:define-task (kandria sq5-race ,name)
         :title "Return the broken Genera core to the barkeep in the Semi Sisters Central Block"
         :marker '(semi-barkeep 500)
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
          :interactable semi-barkeep
          :repeatable T
          :dialogue "
~ semi-barkeep
| \"You want to stop the race?\"(orange) There's no reward if you do that - and you'll be making everyone very sad.
~ player
- No, I'll continue the race.
  ~ semi-barkeep
  | Good. Now get going. Time is money.
- Yes, end it.
  ! eval (hide-timer)
  ~ semi-barkeep
  | If you insist. But you'll be back, I just know it.
  ! eval (reset* task)
  ? (have 'item:semi-genera-core)
  | ! eval (retrieve 'item:semi-genera-core T)
")
         
         (:interaction chat
          :title ,title-complete
          :interactable semi-barkeep
          :dialogue "
! eval (hide-timer)
~ semi-barkeep
| Stop the clock!
| Let me see the serial number on that Genera core. Yes, that's the right one. Now then...
! eval (retrieve 'item:semi-genera-core T)
| Your time was: \"{(format-relative-time (clock quest))}\"(orange).
? (and pb (< pb (clock quest)))
| | I'm afraid that's \"no improvement\"(orange) on your record of \"{(format-relative-time pb)}\"(orange).
|?
| ? (not (null pb))
| | | That's a \"new personal best\"(orange) for you.
| ! eval (setf pb (clock quest))
| ? (< pb gold)
| | | That was faster than the \"gold\"(orange) hunter.
| | ~ semi-patron-1
| | | Holy shite...
| | ~ semi-barkeep
| | | It's impressive, though not unexpected. Still, here's your cut from the sweepstake: \"500 scrap parts\"(orange).
| | | The question is, do you have more in the tank?
| | ! eval (store 'item:parts 500)
| |? (< pb silver)
| | | That was faster than the \"silver\"(orange) hunter. Not bad. Though we think you can do better.
| | ~ semi-patron-2
| | | You're just getting warmed up - <-hic-> - right?
| | ~ semi-barkeep
| | | Here's your cut from the sweepstake: \"300 scrap parts\"(orange).
| | ! eval (store 'item:parts 300)
| |? (< pb bronze)
| | | That was faster than the \"bronze\"(orange) hunter. Not bad.
| | ~ semi-patron-1
| | | Not good either, especially for an android!
| | ~ semi-barkeep
| | | Here's your cut from the sweepstake, as promised: \"200 scrap parts\"(orange).
| | ! eval (store 'item:parts 200)
| |?
| | | But it's \"slower than the bronze\"(orange) hunter, I'm sorry to say.
| | ~ semi-patron-2
| | | Pitiful is what that was. <-Hic->. Pitifu-fu-ful.
| | ~ semi-barkeep
| | | \"Nothing for you from the sweepstake\"(orange) this time. But will you come back stronger?
  
~ semi-barkeep
| Until next time.
! eval (complete task)
! eval (clear-pending-interactions)
")))))

;; more organic/dynamic par times here than with Catherine's sq3 races, since they are meant to be records set by real people, rather than neat brackets
(define-race race-1
  :site sq5-race-1-site
  :site-mark chunk-5602
  :mark-size 1000
  :title-start "Retrieve the broken Genera core near the Semi sign, to the high west of the Central Block"
  :title-complete "(Complete Race Route 1)"
  :title-cancel "(Cancel Race Route 1)"
  :gold 63
  :silver 79
  :bronze 124)

(define-race race-2
  :site sq5-race-2-site
  :site-mark chunk-5677
  :mark-size 1000
  :title-start "Retrieve the broken Genera core from the engineers' camp, in the far high west of Semi Sisters territory"
  :title-complete "(Complete Race Route 2)"
  :title-cancel "(Cancel Race Route 2)"
  :gold 122
  :silver 139
  :bronze 163)

(define-race race-3
  :site sq5-race-3-site
  :site-mark chunk-2482
  :mark-size 1600
  :title-start "Retrieve the broken Genera core from the old android factory, in the far east of Semi Sisters territory"
  :title-complete "(Complete Race Route 3)"
  :title-cancel "(Cancel Race Route 3)"
  :gold 135
  :silver 148
  :bronze 187)

(define-race race-4
  :site sq5-race-4-site
  :site-mark chunk-2019
  :mark-size 2600
  :title-start "Retrieve the broken Genera core from the crevice in the high east of Semi Sisters territory, beneath the old Semi factory in the Ruins"
  :title-complete "(Complete Race Route 4)"
  :title-cancel "(Cancel Race Route 4)"
  :gold 134
  :silver 146
  :bronze 173)

(define-race race-5
  :site sq5-race-5-site
  :site-mark chunk-5426
  :mark-size 1600
  :title-start "Retrieve the broken Genera core from a cave in the high east of Semi Sisters territory, beneath the old Rootless hospital apartments"
  :title-complete "(Complete Race Route 5)"
  :title-cancel "(Cancel Race Route 5)"
  :gold 151
  :silver 176
  :bronze 221)
  
(define-race race-6
  :site sq5-race-6-site
  :site-mark chunk-2019
  :mark-size 2600
  :title-start "Retrieve the broken Genera core from near the Cerebats sign - the second one en route to their land, via the Semi Sisters' low-western border"
  :title-complete "(Complete Race Route 6)"
  :title-cancel "(Cancel Race Route 6)"
  :gold 135
  :silver 150
  :bronze 180)
