(:name find-home-third
 :title "Scout location Delta"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (new-home-site-3)
 :on-complete NIL)

;; enemies on this quest will be world NPCs, not spawned for the quest
(quest:interaction :name new-home-site-3 :interactable new-home-3 :dialogue "
~ player
| //It's new-home candidate site Delta.//
| (:thinking) //It's secure and concealed, and sheltered from the weather.//
| (:skeptical) //But the foot of a cliff face is perhaps not the wisest choice in an area prone to quakes.//
? (complete-p 'find-home-first 'find-home-second 'find-home-fourth)
| | (:normal) I should return to Jack with the bad news.
| ! eval (activate 'return-new-home)
")
