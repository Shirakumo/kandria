(:name leak-third
 :title "Find the third leak"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (leak-3)
 :on-complete NIL
)

; enemies on this quest will be world NPCs, not spawned for the quest
(quest:interaction :name leak-3 :interactable leak-3 :dialogue "
~ player
| //It's leak site 3.//
? (complete-p 'leak-first)
| ? (complete-p 'leak-second)
| | ! eval (activate 'return-leaks)
")