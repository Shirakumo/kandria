(:name race-one-return
 :title "Return item X to Catherine ASAP"
 :description NIL
 :invariant T
 :condition NIL
 :on-activate (activate-chat)
 :on-complete NIL
)

; activating trigger this way so it works with repeat plays of the quest and task; using :on-activate in the task meta above to go straight to race-one-chat works first time only
(quest:action :name activate-chat :on-activate (progn                                             											 
											 (setf (quest:status (thing 'race-one-chat)) :inactive)
											 (activate 'race-one-chat)
											 )
)

(quest:interaction :name race-one-chat :title "I've done race 1" :interactable catherine :dialogue "
! eval (hide-panel 'timer)
~ catherine
| You're back. Stop the clock!
| You got the item X from nearby, cool.
! eval (retrieve 'can)
| It took you {(format-relative-time (clock quest))}!
  
? (< (clock quest) 10)
| | How did you do that so fast? That's gold bracket.
| ? (not (var 'race-1-gold))
| | | I've logged your time - your first one in the gold bracket.
| | ! eval (setf (var 'race-1-gold) (clock quest))
| |?
| | ? (< (clock quest) (var 'race-1-gold))
| | | | You beat your gold score, wait a go!
| | |? (= (clock quest) (var 'race-1-gold))
| | | | You equalled your gold score, what are the chances?!
| | |?
| | | | You didn't beat your best gold score though, but it's still good!
|? (< (clock quest) 30)
| | That's pretty quick! Silver bracket.
| ? (not (var 'race-1-silver))
| | | I've logged your time - your first one in the silver bracket.
| | ! eval (setf (var 'race-1-silver) (clock quest))
| |?
| | ? (< (clock quest) (var 'race-1-silver))
| | | | You beat your silver score, wait a go!
| | |? (= (clock quest) (var 'race-1-silver))
| | | | You equalled your silver score, what are the chances?!
| | |?
| | | | You didn't beat your best silver score though, but it's still good!
|? (< (clock quest) 60)
| | Not bad.
| ? (not (var 'race-1-bronze))
| | | I've logged your time - your first one in the bronze bracket.
| | ! eval (setf (var 'race-1-bronze) (clock quest))
| |?
| | ? (< (clock quest) (var 'race-1-bronze))
| | | | You beat your bronze score, wait a go!
| | |? (= (clock quest) (var 'race-1-bronze))
| | | | You equalled your bronze score, what are the chances?!
| | |?
| | | | You didn't beat your best bronze score though, but it's still good!
|?
| | I think you can do better than that.
? (not (var 'race-1-pb))
| | I've also logged your time as your personal best.
| ! eval (setf (var 'race-1-pb) (clock quest))
|?
| ? (< (clock quest) (var 'race-1-pb))
| | | You beat your personal best too!
| | ! eval (setf (var 'race-1-pb) (clock quest))
| |? (= (clock quest) (var 'race-1-pb))
| | | You equalled your personal best too! What are the chances?!
| |?
| | | Unfortunately you didn't beat your personal best.
! eval (complete 'race-one-return)
")
; todo rewards
; todo replace bracket numbers with global quest vars, initiated at quest start
; todo log times to tenth of a second, not whole numbers?