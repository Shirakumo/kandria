(:name leak-second
 :title "Find the second leak"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (leak-2)
 :on-complete NIL
)

; enemies on this quest will be world NPCs, not spawned for the quest
(quest:interaction :name leak-2 :interactable leak-2 :dialogue "
~ player
| //It's leak site 2.//
? (complete-p 'leak-first)
| ? (complete-p 'leak-third)
| | ! eval (activate 'return-leaks)
")