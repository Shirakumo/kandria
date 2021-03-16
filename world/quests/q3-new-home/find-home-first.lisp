(:name find-home-first
 :title "Find the first location"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (new-home-site-1)
 :on-complete NIL
)

; enemies on this quest will be world NPCs, not spawned for the quest
(quest:interaction :name new-home-site-1 :interactable new-home-1 :dialogue "
~ player
| //It's site 1.//
? (complete-p 'find-home-second)
| ? (complete-p 'find-home-third)
| | ? (complete-p 'find-home-fourth)
| | | ! eval (activate 'return-new-home)
")
