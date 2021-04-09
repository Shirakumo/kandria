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
| Stop the clock!
| That's the can for Route 1 alright - nice!
! eval (retrieve 'can)
| You did that in: {(format-relative-time (clock quest))}!
  
? (< (clock quest) (var 'race-1-gold-goal))
| | How did you do that so fast? That's gold bracket.
| | You get the top reward - 20 scrap parts!
| ! eval (store 'parts 20)
| ? (not (var 'race-1-gold))
| | | I've logged your time - your first one in the gold bracket.
| | ! eval (setf (var 'race-1-gold) (clock quest))
| |?
| | ? (< (clock quest) (var 'race-1-gold))
| | | | And you beat your best gold time, way to go!
| | |? (= (clock quest) (var 'race-1-gold))
| | | | You equalled your best gold time as well, what are the chances?!
| | |?
| | | | You didn't beat your best gold time, but it's still good!
|? (< (clock quest) (var 'race-1-silver-goal))
| | That's pretty quick! Silver bracket.
| | That nets you 10 scrap parts!
| ! eval (store 'parts 10)
| ? (not (var 'race-1-silver))
| | | I've logged your time - your first one in the silver bracket.
| | ! eval (setf (var 'race-1-silver) (clock quest))
| |?
| | ? (< (clock quest) (var 'race-1-silver))
| | | | And you beat your best silver time, way to go!
| | |? (= (clock quest) (var 'race-1-silver))
| | | | You equalled your best silver time as well, what are the chances?!
| | |?
| | | | You didn't beat your best silver time, but it's still good!
|? (< (clock quest) (var 'race-1-bronze-goal))
| | Not bad. That's bronze bracket.
| | That gets you 5 scrap parts.
| ! eval (store 'parts 5)
| ? (not (var 'race-1-bronze))
| | | I've logged your time - your first one in the bronze bracket.
| | ! eval (setf (var 'race-1-bronze) (clock quest))
| |?
| | ? (< (clock quest) (var 'race-1-bronze))
| | | | And you beat your bronze time, way to go!
| | |? (= (clock quest) (var 'race-1-bronze))
| | | | You equalled your best bronze time as well, what are the chances?!
| | |?
| | | | You didn't beat your best bronze time, but it's still good!
|?
| | Hmmm, that's a little slow, Stranger. I think you can do better than that.
| | Don't think I can give you any parts for that, sorry.
? (not (var 'race-1-pb))
| | I've also logged your time as your personal best for this route.
| ! eval (setf (var 'race-1-pb) (clock quest))
|?
| ? (< (clock quest) (var 'race-1-pb))
| | | That's a new personal best too! I'm so proud of you.
| | ! eval (setf (var 'race-1-pb) (clock quest))
| |? (= (clock quest) (var 'race-1-pb))
| | | You equalled your personal best too - that's amazing!
| |?
| | | Alas you didn't beat your personal best. But there's always next time!
! eval (complete 'race-one-return)
  
| Let's do this again soon!
")
;; TODO only grant rewards if first time in a new bracket - across all routes - to prevent farming (check quest design doc, but pretty sure that was the design)?
;; - then again, if the player is prepared to put the work in to keep racing, why not reward them?
;; TODO: replace bracket numbers and rewards with global quest vars (including in race hub), stored at quest level and defined there
;; TODO: log times to tenth of a second, not whole numbers?
