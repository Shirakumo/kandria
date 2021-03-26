(:name return-leaks
 :title "Return to Catherine now the leaks are fixed"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (leaks-return)
 :on-complete NIL)

(quest:interaction :name leaks-return :title "Talk about the leaks" :interactable catherine :dialogue "
~ catherine
| The water pressure is back to what it was. I knew you could do it.
| Here, takes these parts - you've earned them.
! eval (store 'parts 15)
? (have 'walkie-talkie)
| | I'll take the walkie back for now in case someone else needs it.
| ! eval (retrieve 'walkie-talkie 1)
| | Bet it was weird using such archaic technology, right?
| - I liked it.
| - Never again.
|   ~ catherine
|   | Oh, that bad huh?
| - It's beneath me, but it works.
|  
~ catherine
| Well, you can definitely scratch water leaks off your bucket list. Let's talk later!
")
#|
TODO is it okay that Catherine breaks off convo here, and to access more sidequests you need to click on here again? What if on returning to her, you want to discuss another quest before handing this one in? Or you have multiple to hand in?
should be able to choose which ones you want to hand in and in what order? but the necessary var checks to accomodate those options would mean all these sidequests need housing under a single quest folder, and all their tasks list would overlap
- could use var checks? though they only check hierarchical, not between tasks?
Also means that sq return dialogues cannot be repeatable - having to fire once only, to then allow user to get back to sq hub
|#