(:name find-home-second
 :title "Scout location Gamma"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (new-home-site-2)
 :on-complete NIL)

;; enemies on this quest will be world NPCs, not spawned for the quest
(quest:interaction :name new-home-site-2 :interactable new-home-2 :dialogue "
~ player
| //It's new-home candidate site Gamma.//
| //This position is favourably elevated and well-concealed, offering a vantage point from which to spy intruders.//
| //The building's foundations appear strong, but the rest is a sand-blasted shell.//
? (complete-p 'find-home-first 'find-home-third 'find-home-fourth)
| | I should return to Jack with the bad news.
| ! eval (activate 'return-new-home)
")

#| original placeholder location desc:
| //It's new-home site Gamma.//
| //This position is favourable and well-concealed.//
| //The ground is secure, but limited in footprint - and there's no shelter from the weather.//
|#
