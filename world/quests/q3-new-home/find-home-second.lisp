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
| //It's new-home site Gamma.//
| //This position is favourable and well-concealed.//
| //The ground is secure, but limited in footprint - and there's no shelter from the weather.//
? (complete-p 'find-home-first 'find-home-third 'find-home-fourth)
| ! eval (activate 'return-new-home)
")
