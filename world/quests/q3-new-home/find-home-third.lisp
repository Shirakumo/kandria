(:name find-home-third
 :title "Scout location Gamma"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (new-home-site-3)
 :on-complete NIL
)

; enemies on this quest will be world NPCs, not spawned for the quest
(quest:interaction :name new-home-site-3 :interactable new-home-3 :dialogue "
~ player
| //It's new-home site Gamma.//
| //It's secure and concealed, and sheltered from the elements.//
| //But the foot of a cliff face is perhaps not the wisest choice in an area prone to earthquakes.//
? (complete-p 'find-home-first)
| ? (complete-p 'find-home-second)
| | ? (complete-p 'find-home-fourth)
| | | ! eval (activate 'return-new-home)
")
