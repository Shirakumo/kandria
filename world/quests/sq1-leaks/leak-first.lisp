(:name leak-first
 :title "Find the first leak"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (leak-1)
 :on-complete NIL
)

; enemies on this quest will be world NPCs, not spawned for the quest
(quest:interaction :name leak-1 :interactable leak-1 :dialogue "
~ player
| //It's leak site 1.//
? (complete-p 'leak-second)
| ? (complete-p 'leak-third)
| | ! eval (activate 'return-leaks)
")