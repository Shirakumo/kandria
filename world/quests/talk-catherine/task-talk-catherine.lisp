(:name talk-to-catherine
 :title "Talk to Catherine"
 :description "I should check in with Catherine."
 :invariant T
 :condition NIL
 :on-activate (talk))
(quest:interaction :name talk :interactable catherine :dialogue "
~ fi
| I need you to fix the water supply.
~ player
| Okay I will.
! eval (activate 'q1-water)  
~ fi
| Thanks.")
