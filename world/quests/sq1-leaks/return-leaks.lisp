(:name return-leaks
 :title "Return to Catherine"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (leaks-return)
 :on-complete NIL)

(quest:interaction :name leaks-return :title "Talk about the leaks" :interactable catherine :dialogue "
~ catherine
| (:cheer) The water pressure is back! I knew you could do it.
| (:normal) Here, takes these parts - you've earned them.
! eval (store 'parts 15)
? (have 'walkie-talkie)
| | I'll take the walkie back for now in case someone else needs it.
| ! eval (retrieve 'walkie-talkie 1)
| | Bet it was weird using such archaic technology, right?
| ~ player
| - I liked it.
| - Never again.
|   ~ catherine
|   | Oh, that bad huh?
| - It's beneath me, but it works.
|  
~ catherine
| Well, you can definitely scratch water leaks off your bucket list, right?
")
;; TODO if don't have the walkie, but you took it (so you've sold it to Sahil), should she say something? Or just not comment or forget? Doing so would get you into hot water about lying, etc. which we might not want in act 1 (we removed similar things from the seed quest). If we did it, would need to set a var during any of the leaks tasks, based on whether you have the walkie or not; can't set on first receiving the walkie, as it's in another quest (act 1 hub), unless used a global var...
#|
TODO is it okay that Catherine breaks off convo here, and to access more sidequests you need to click on here again? What if on returning to her, you want to discuss another quest before handing this one in? Or you have multiple to hand in?
should be able to choose which ones you want to hand in and in what order? but the necessary var checks to accomodate those options would mean all these sidequests need housing under a single quest folder, and all their tasks list would overlap
- could use var checks? though they only check hierarchical, not between tasks?
Also means that sq return dialogues cannot be repeatable - having to fire once only, to then allow user to get back to sq hub
|#