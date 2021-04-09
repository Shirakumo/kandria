(:name race-two-return
 :title "Return the can to Catherine ASAP"
 :description NIL
 :invariant T
 :condition NIL
 :on-activate (activate-chat)
 :on-complete NIL)

(quest:action :name activate-chat :on-activate (progn
                                                 (setf (quest:status (thing 'race-two-chat)) :inactive)
                                                 (activate 'race-two-chat)))

(quest:interaction :name race-two-chat :title "Complete Route 2" :interactable catherine :dialogue "
! eval (hide-panel 'timer)
~ catherine
| (:cheer) Stop the clock!
| (:excited) That's the can for Route 2 alright - nice!
! eval (retrieve 'can)
| (:normal) You did that in: {(format-relative-time (clock quest))}.
  
? (< (clock quest) (var 'race-2-gold-goal))
| | (:cheer) How did you do that so fast? That's gold bracket.
| | You get the top reward - 30 scrap parts!
| ! eval (store 'parts 30)
| ? (not (var 'race-2-gold))
| | | (:excited) I've logged your time - your first one in the gold bracket.
| | ! eval (setf (var 'race-2-gold) (clock quest))
| |?
| | ? (< (clock quest) (var 'race-2-gold))
| | | | (:excited) And you beat your best gold time, way to go!
| | |? (= (clock quest) (var 'race-2-gold))
| | | | (:excited) You equalled your best gold time as well, what are the chances?!
| | |?
| | | | (:excited) You didn't beat your best gold time, but it's still good!
|? (< (clock quest) (var 'race-2-silver-goal))
| | (:excited) That's pretty quick! Silver bracket.
| | That nets you 15 scrap parts!
| ! eval (store 'parts 15)
| ? (not (var 'race-2-silver))
| | | (:excited) I've logged your time - your first one in the silver bracket.
| | ! eval (setf (var 'race-2-silver) (clock quest))
| |?
| | ? (< (clock quest) (var 'race-2-silver))
| | | | (:excited) And you beat your best silver time, way to go!
| | |? (= (clock quest) (var 'race-2-silver))
| | | | (:excited) You equalled your best silver time as well, what are the chances?!
| | |?
| | | | (:excited) You didn't beat your best silver time, but it's still good!
|? (< (clock quest) (var 'race-2-bronze-goal))
| | (:excited) Not bad! That's bronze bracket.
| | That gets you 10 scrap parts.
| ! eval (store 'parts 10)
| ? (not (var 'race-2-bronze))
| | | (:excited) I've logged your time - your first one in the bronze bracket.
| | ! eval (setf (var 'race-2-bronze) (clock quest))
| |?
| | ? (< (clock quest) (var 'race-2-bronze))
| | | | (:excited) And you beat your bronze time, way to go!
| | |? (= (clock quest) (var 'race-2-bronze))
| | | | (:excited) You equalled your best bronze time as well, what are the chances?!
| | |?
| | | | (:excited) You didn't beat your best bronze time, but it's still good!
|?
| | (:disappointed) Hmmm, that seems a little slow, Stranger. I think you can do better than that.
| | Don't think I can give you any parts for that, sorry.
? (not (var 'race-2-pb))
| | (:normal) I've also logged your time as your personal best for this route.
| ! eval (setf (var 'race-2-pb) (clock quest))
|?
| ? (< (clock quest) (var 'race-2-pb))
| | | (:excited) That's a new personal best! I'm so proud of you.
| | ! eval (setf (var 'race-2-pb) (clock quest))
| |? (= (clock quest) (var 'race-2-pb))
| | | (:excited) You equalled your personal best too - that's amazing!
| |?
| | | (:normal) Alas you didn't beat your personal best. But there's always next time!
! eval (complete 'race-two-return)
  
| (:excited) Let's do this again soon!
")
