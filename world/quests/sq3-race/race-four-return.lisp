(:name race-four-return
 :title "Return item Z to Catherine ASAP"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (race-four-chat)
 :on-complete NIL
)

(quest:interaction :name race-four-chat :title "I've done race 4" :interactable catherine :dialogue "
! eval (hide-panel 'timer)
~ catherine
| You're back. Stop the clock!
| You got the item Z from far distance, cool.
! eval (retrieve 'can)
| It took you {(format-relative-time (clock quest))}!
  
? (< (clock quest) 40)
| | How did you do that so fast? That's gold bracket.
| ? (not (var 'race-4-gold))
| | | I've logged your time - your first one in the gold bracket.
| | ! eval (setf (var 'race-4-gold) (clock quest))
| |?
| | ? (< (clock quest) 'race-4-gold)
| | | | You beat your gold score, wait a go!
| | |? (= (clock quest) 'race-4-gold)
| | | | You equalled your gold score, what are the chances?!
| | |?
| | | | You didn't beat your best gold score though, but it's still good!
|? (< (clock quest) 120)
| | That's pretty quick! Silver bracket.
| ? (not (var 'race-4-silver))
| | | I've logged your time - your first one in the silver bracket.
| | ! eval (setf (var 'race-4-silver) (clock quest))
| |?
| | ? (< (clock quest) 'race-4-silver)
| | | | You beat your silver score, wait a go!
| | |? (= (clock quest) 'race-4-silver)
| | | | You equalled your silver score, what are the chances?!
| | |?
| | | | You didn't beat your best silver score though, but it's still good!
|? (< (clock quest) 240)
| | Not bad.
| ? (not (var 'race-4-bronze))
| | | I've logged your time - your first one in the bronze bracket.
| | ! eval (setf (var 'race-4-bronze) (clock quest))
| |?
| | ? (< (clock quest) 'race-4-bronze)
| | | | You beat your bronze score, wait a go!
| | |? (= (clock quest) 'race-4-bronze)
| | | | You equalled your bronze score, what are the chances?!
| | |?
| | | | You didn't beat your best bronze score though, but it's still good!
|?
| | I think you can do better than that.
? (not (var 'race-4-pb))
| | I've also logged your time as your personal best.
| ! eval (setf (var 'race-4-pb) (format-relative-time (clock quest)))
|?
| ? (< (clock quest) 'race-4-pb)
| | | You beat your personal best too!
| | ! eval (setf (var 'race-4-pb) (clock quest))
| |? (= (clock quest) 'race-4-pb)
| | | You equalled your personal best too! What are the chances?!
")
; todo rewards
; todo replace bracket numbers with global quest vars, initiated at quest start