(:name find-home-fourth
 :title "Scout location Delta"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (new-home-site-4)
 :on-complete NIL)

;; enemies on this quest will be world NPCs, not spawned for the quest
(quest:interaction :name new-home-site-4 :interactable new-home-4 :dialogue "
~ player
| //It's new-home site Delta.//
| //This would be perfect - sheltered, while also offering a vantage point from which to spy intruders.//
| //They could also dig back through the wall here for more space.//
| //But it's not possible for a human to reach here easily - especially not children, nor the elderly or infirm.//
? (complete-p 'find-home-first 'find-home-second 'find-home-third)
| ! eval (activate 'return-new-home)
")
