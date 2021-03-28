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
| Stop the clock!
| That's the can for Route 2 alright - nice!
! eval (retrieve 'can)
| You did that in: {(format-relative-time (clock quest))}!
  
? (< (clock quest) 60)
| | How did you do that so fast? That's gold bracket.
| | You get the top reward - 30 scrap parts!
| ! eval (store 'parts 30)
| ? (not (var 'race-2-gold))
| | | I've logged your time - your first one in the gold bracket.
| | ! eval (setf (var 'race-2-gold) (clock quest))
| |?
| | ? (< (clock quest) (var 'race-2-gold))
| | | | And you beat your best gold time, way to go!
| | |? (= (clock quest) (var 'race-2-gold))
| | | | You equalled your best gold time as well, what are the chances?!
| | |?
| | | | You didn't beat your best gold time, but it's still good!
|? (< (clock quest) 90)
| | That's pretty quick! Silver bracket.
| | That nets you 15 scrap parts!
| ! eval (store 'parts 15)
| ? (not (var 'race-2-silver))
| | | I've logged your time - your first one in the silver bracket.
| | ! eval (setf (var 'race-2-silver) (clock quest))
| |?
| | ? (< (clock quest) (var 'race-2-silver))
| | | | And you beat your best silver time, way to go!
| | |? (= (clock quest) (var 'race-2-silver))
| | | | You equalled your best silver time as well, what are the chances?!
| | |?
| | | | You didn't beat your best silver time, but it's still good!
|? (< (clock quest) 120)
| | Not bad. That's bronze bracket.
| | That gets you 10 scrap parts.
| ! eval (store 'parts 10)
| ? (not (var 'race-2-bronze))
| | | I've logged your time - your first one in the bronze bracket.
| | ! eval (setf (var 'race-2-bronze) (clock quest))
| |?
| | ? (< (clock quest) (var 'race-2-bronze))
| | | | And you beat your bronze time, way to go!
| | |? (= (clock quest) (var 'race-2-bronze))
| | | | You equalled your best bronze time as well, what are the chances?!
| | |?
| | | | You didn't beat your best bronze time, but it's still good!
|?
| | Hmmm, that's a little slow, Stranger. I think you can do better than that.
| | Don't think I can give you any parts for that, sorry.
? (not (var 'race-2-pb))
| | I've also logged your time as your personal best for this route.
| ! eval (setf (var 'race-2-pb) (clock quest))
|?
| ? (< (clock quest) (var 'race-2-pb))
| | | You beat your personal best too! I'm so proud of you.
| | ! eval (setf (var 'race-2-pb) (clock quest))
| |? (= (clock quest) (var 'race-2-pb))
| | | You equalled your personal best too - that's amazing!
| |?
| | | Alas you didn't beat your personal best. But there's always next time!
! eval (complete 'race-two-return)
  
| Let's do this again soon!
")
