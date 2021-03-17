(:name find-home-fourth
 :title "Find the fourth location"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (new-home-site-4)
 :on-complete NIL
)

; enemies on this quest will be world NPCs, not spawned for the quest
(quest:interaction :name new-home-site-4 :interactable new-home-4 :dialogue "
~ player
| //It's site 4.//
? (complete-p 'find-home-first)
| ? (complete-p 'find-home-second)
| | ? (complete-p 'find-home-third)
| | | ! eval (activate 'return-new-home)
")
