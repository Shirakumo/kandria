(:name find-home-first
 :title "Scout location Alpha"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (new-home-site-1)
 :on-complete NIL)

;; enemies on this quest will be world NPCs, not spawned for the quest
;; REMARK: Naming it Alpha seems confusing given the Alpha cafe.
;; REMARK: 'orifice' has a... really bad connotation. Just use 'crack'.
(quest:interaction :name new-home-site-1 :interactable new-home-1 :dialogue "
~ player
| //It's new-home site Alpha.//
| //There could be shelter inside this building.//
| //Scanning the interior...//
| //Dirt and sand has intruded through almost every orifice.//
| //It's a quicksand deathtrap.//
| Structural integrity could be described as \"may collapse at any moment\".
? (complete-p 'find-home-second 'find-home-third 'find-home-fourth)
| ! eval (activate 'return-new-home)
")
;; TODO: using // on the last line, where it also escapes characters, causes the \\ to render as literals
