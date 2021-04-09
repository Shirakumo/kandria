(:name race-one-return
 :title "Return the can to Catherine ASAP"
 :description NIL
 :invariant T
 :condition NIL
 :on-activate (activate-chat)
 :on-complete NIL)

;; activating trigger this way so it works with repeat plays of the quest and task; using :on-activate in the task meta above to go straight to race-one-chat works first time only
(quest:action :name activate-chat :on-activate (progn
                                                 (setf (quest:status (thing 'race-one-chat)) :inactive)
                                                 (activate 'race-one-chat)))

(quest:interaction :name race-one-chat :title "Complete Route 1" :interactable catherine :dialogue "
! eval (hide-panel 'timer)
~ catherine
| (:cheer) Stop the clock!
| (:excited) That's the can for Route 1 alright - nice!
! eval (retrieve 'can)
| (:normal) You did that in: {(format-relative-time (clock quest))}.
  
? (< (clock quest) (var 'race-1-gold-goal))
| | (:cheer) How did you do that so fast? That's gold bracket.
| | You get the top reward - 20 scrap parts!
| ! eval (store 'parts 20)
| ? (not (var 'race-1-gold))
| | | (:excited) I've logged your time - your first one in the gold bracket.
| | ! eval (setf (var 'race-1-gold) (clock quest))
| |?
| | ? (< (clock quest) (var 'race-1-gold))
| | | | (:excited) And you beat your best gold time, way to go!
| | |? (= (clock quest) (var 'race-1-gold))
| | | | (:excited) You equalled your best gold time as well, what are the chances?!
| | |?
| | | | (:excited) You didn't beat your best gold time, but it's still good!
|? (< (clock quest) (var 'race-1-silver-goal))
| | (:excited) That's pretty quick! Silver bracket.
| | That nets you 10 scrap parts!
| ! eval (store 'parts 10)
| ? (not (var 'race-1-silver))
| | | (:excited) I've logged your time - your first one in the silver bracket.
| | ! eval (setf (var 'race-1-silver) (clock quest))
| |?
| | ? (< (clock quest) (var 'race-1-silver))
| | | | (:excited) And you beat your best silver time, way to go!
| | |? (= (clock quest) (var 'race-1-silver))
| | | | (:excited) You equalled your best silver time as well, what are the chances?!
| | |?
| | | | (:excited) You didn't beat your best silver time, but it's still good!
|? (< (clock quest) (var 'race-1-bronze-goal))
| | (:excited) Not bad! That's bronze bracket.
| | That gets you 5 scrap parts.
| ! eval (store 'parts 5)
| ? (not (var 'race-1-bronze))
| | | (:excited) I've logged your time - your first one in the bronze bracket.
| | ! eval (setf (var 'race-1-bronze) (clock quest))
| |?
| | ? (< (clock quest) (var 'race-1-bronze))
| | | | (:excited) And you beat your bronze time, way to go!
| | |? (= (clock quest) (var 'race-1-bronze))
| | | | (:excited) You equalled your best bronze time as well, what are the chances?!
| | |?
| | | | (:excited) You didn't beat your best bronze time, but it's still good!
|?
| | (:disappointed) Hmmm, that seems a little slow, Stranger. I think you can do better than that.
| | Don't think I can give you any parts for that, sorry.
? (not (var 'race-1-pb))
| | (:normal) I've also logged your time as your personal best for this route.
| ! eval (setf (var 'race-1-pb) (clock quest))
|?
| ? (< (clock quest) (var 'race-1-pb))
| | | (:excited) That's a new personal best! I'm so proud of you.
| | ! eval (setf (var 'race-1-pb) (clock quest))
| |? (= (clock quest) (var 'race-1-pb))
| | | (:excited) You equalled your personal best too - that's amazing!
| |?
| | | (:normal) Alas you didn't beat your personal best. But there's always next time!
! eval (complete 'race-one-return)
  
| (:excited) Let's do this again soon!
")
;; TODO only grant rewards if first time in a new bracket - across all routes - to prevent farming (check quest design doc, but pretty sure that was the design)?
;; - then again, if the player is prepared to put the work in to keep racing, why not reward them?
;; TODO: replace bracket numbers and rewards with global quest vars (including in race hub), stored at quest level and defined there
;; TODO: log times to tenth of a second, not whole numbers?
