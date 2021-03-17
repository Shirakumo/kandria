(:name find-home-second
 :title "Find the second location"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (new-home-site-2)
 :on-complete NIL
)

; enemies on this quest will be world NPCs, not spawned for the quest
(quest:interaction :name new-home-site-2 :interactable new-home-2 :dialogue "
~ player
| //It's site 2.//
? (complete-p 'find-home-first)
| ? (complete-p 'find-home-third)
| | ? (complete-p 'find-home-fourth)
| | | ! eval (activate 'return-new-home)
")
