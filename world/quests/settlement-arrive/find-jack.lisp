(:name find-jack
 :title "Find Jack"
 :description "I should follow Catherine into that building and find Jack."
 :invariant T
 :condition NIL
 :on-activate (talk))
 
(quest:interaction :name talk :interactable jack :dialogue "
~ jack
| Who are you?
~ catherine
| Oh my manners!
")
; ! eval (activate 'q1-water)
; TODO mention stranger's name? Leave for jack to do?