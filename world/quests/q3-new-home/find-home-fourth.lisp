(:name find-home-fourth
 :title "Scout location Epsilon"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (new-home-site-4)
 :on-complete NIL)

;; enemies on this quest will be world NPCs, not spawned for the quest
(quest:interaction :name new-home-site-4 :interactable new-home-4 :dialogue "
~ player
| //It's new-home candidate site Epsilon.//
| //These factory cubicles would make for excellent storage, and perhaps even a base for Engineering.//
| //I could clear the barbed wire so children, and the elderly and infirm could navigate this area.//
? (or (complete-p 'q2-seeds) (have 'seeds))
| | //But its proximity to the soiled seed cache is problematic. And that's before they even consider the earthquakes.//
|?
| | //The factory does offer some structural protection against the earthquakes, but this would not be easy living.//
? (complete-p 'find-home-first 'find-home-second 'find-home-third)
| | I should return to Jack with the bad news.
| ! eval (activate 'return-new-home)
")

#| original placeholder location desc:
| //This would be perfect - sheltered, while also offering a vantage point from which to spy intruders.//
| //They could also dig back through the wall here for more space.//
| //Unfortunately a human couldn't climb up here easily - especially not children, nor the elderly or infirm.//
|#
