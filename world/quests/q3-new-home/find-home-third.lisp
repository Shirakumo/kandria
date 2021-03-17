(:name find-home-third
 :title "Find the third location"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (new-home-site-3)
 :on-complete NIL
)

; enemies on this quest will be world NPCs, not spawned for the quest
(quest:interaction :name new-home-site-3 :interactable new-home-3 :dialogue "
~ player
| //It's site 3.//
? (complete-p 'find-home-first)
| ? (complete-p 'find-home-second)
| | ? (complete-p 'find-home-fourth)
| | | ! eval (activate 'return-new-home)
")
