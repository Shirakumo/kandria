(:name race-two-return
 :title "Return item W to Catherine ASAP"
 :description NIL
 :invariant T
 :condition NIL
 :on-activate (activate-chat)
 :on-complete NIL
)

(quest:action :name activate-chat :on-activate (progn                                             											 
											 (setf (quest:status (thing 'race-two-chat)) :inactive)
											 (activate 'race-two-chat)
											 )
)

(quest:interaction :name race-two-chat :title "I've done race 2" :interactable catherine :dialogue "
! eval (hide-panel 'timer)
~ catherine
| You're back. Stop the clock!
| You got the item W from nearby, cool.
! eval (retrieve 'can)
| It took you {(format-relative-time (clock quest))}!
  
? (< (clock quest) 20)
| | How did you do that so fast? That's gold bracket.
| ? (not (var 'race-2-gold))
| | | I've logged your time - your first one in the gold bracket.
| | ! eval (setf (var 'race-2-gold) (clock quest))
| |?
| | ? (< (clock quest) (var 'race-2-gold))
| | | | You beat your gold score, wait a go!
| | |? (= (clock quest) (var 'race-2-gold))
| | | | You equalled your gold score, what are the chances?!
| | |?
| | | | You didn't beat your best gold score though, but it's still good!
|? (< (clock quest) 60)
| | That's pretty quick! Silver bracket.
| ? (not (var 'race-2-silver))
| | | I've logged your time - your first one in the silver bracket.
| | ! eval (setf (var 'race-2-silver) (clock quest))
| |?
| | ? (< (clock quest) (var 'race-2-silver))
| | | | You beat your silver score, wait a go!
| | |? (= (clock quest) (var 'race-2-silver))
| | | | You equalled your silver score, what are the chances?!
| | |?
| | | | You didn't beat your best silver score though, but it's still good!
|? (< (clock quest) 120)
| | Not bad.
| ? (not (var 'race-2-bronze))
| | | I've logged your time - your first one in the bronze bracket.
| | ! eval (setf (var 'race-2-bronze) (clock quest))
| |?
| | ? (< (clock quest) (var 'race-2-bronze))
| | | | You beat your bronze score, wait a go!
| | |? (= (clock quest) (var 'race-2-bronze))
| | | | You equalled your bronze score, what are the chances?!
| | |?
| | | | You didn't beat your best bronze score though, but it's still good!
|?
| | I think you can do better than that.
? (not (var 'race-2-pb))
| | I've also logged your time as your personal best.
| ! eval (setf (var 'race-2-pb) (clock quest))
|?
| ? (< (clock quest) (var 'race-2-pb))
| | | You beat your personal best too!
| | ! eval (setf (var 'race-2-pb) (clock quest))
| |? (= (clock quest) (var 'race-2-pb))
| | | You equalled your personal best too! What are the chances?!
| |?
| | | Unfortunately you didn't beat your personal best.
! eval (complete 'race-two-return)
")
; todo rewards
; todo replace bracket numbers with global quest vars, initiated at quest start
; todo log times to tenth of a second, not whole numbers?