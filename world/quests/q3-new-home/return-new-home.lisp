(:name return-new-home
 :title "Return to Jack with the bad news - there is no suitable location"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (new-home-return)
 :on-complete NIL
)

; enemies on this quest will be world NPCs, not spawned for the quest
(quest:interaction :name new-home-return :interactable jack :dialogue "
~ jack
| Thanks for checking for a new home, oh well.
? (complete-p 'q2-seeds)
| | You should check in again with Catherine too - I'm sure she'd like to see you again.
| | And knowing her they'll be some jobs you can help with.
| ! eval (activate 'sq-act1-intro)
|?
| ? (not (active-p 'q2-seeds))
| | | Mention about quest 2
|   
| | I also heard Sahil is here - our trader friend. His caravan is down in the trading hub, below the metro tunnel.
| | It would be wise to make sure you're well-equipped for your work.
| ! eval (setf (location 'trader) 'entity-5627)
| ! eval (activate 'trader-arrive)
")
; todo rewards
; todo bug: it shows "New quest: Talk to Fi" which would be q2-intro...?
; parting words to suggest next quests - could be quest 3 if not done it, or sidequests if have done it
; also unlock trader if not completed quest 3 yet

#|



|#

#|



|#