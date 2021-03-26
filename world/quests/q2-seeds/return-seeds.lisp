(:name return-seeds
 :title "Return to Fi"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (seeds-return-fi)
 :on-complete NIL)

;; enemies on this quest will be world NPCs, not spawned for the quest
;; REMARK: It feels a bit too soon for Fi to fully trust the stranger already.
;;         I think it would be better if she remarked positively about it and hinted at
;;         welcoming her into the group, but only making her an actual member in Act 2.
;;         Also gives the player something to look forward to and we can build it up
;;         to be a more impactful and rewarding moment.
;; REMARK: Also as you already mentioned in the other part, would be best if the lie
;;         options were gated behind a variable that is set in the other task if you
;;         don't take anything.
(quest:interaction :name seeds-return-fi :interactable fi :dialogue "
~ fi
| You're back - did you find the seeds?
- ? (have 'seeds)
  ~ player
  | I've got them right here.
  
  ~ fi
  ? (<= 50 (item-count 'seeds))
  | | Oh my... there must be... fifty sachets here. All fully stocked.
  | | You've done well. Very well. I'll see these are sown right away.
  | | This buys us hope I never thought we'd have.
  | | Know that you have earned my trust, Stranger. Welcome to the Noka.
  | | You may now call yourself one of our hunters.
  | ! eval (retrieve 'seeds 54)
  |? (<= 10 (item-count 'seeds))
  | | Oh, is that all that was left?
  | ~ player
  | - I'm afraid so.
  |   ~ fi
  |   | That's... disappointing. But I guess it was a long shot.
  |   | I knew we should have taken them all when we had the chance.
  |   | I suppose I was worried they'd be destroyed, if we came under attack.
  | - Someone must have taken them.
  |   ~ fi
  |   | Perhaps... Though what use they'd be to anyone else, I do not know.
  |   | We're the only ones crazy enough to live on the surface.
  | - The bunker was old and ransacked.
  |   ~ fi
  |   | Yes... Alex had previously reported it as such.
  | ~ fi
  | | Oh well, I suppose this is better than nothing. I just hope it will be enough.
  | | Thank you for you efforts. I'll see these are sown right away.
  | | And welcome to the Noka. You may now call yourself one of our hunters.
  | ! eval (retrieve 'seeds 17)
- (Lie) I'm afraid there weren't any left.
  ~ fi
  | ...
  | None left... Alex told me there were at least fifty sachets remaining.
  | I knew we should have taken them all when we had the chance.
  | I suppose I was worried they'd be destroyed, if we came under attack.
  | Thank you for making the journey - and welcome to the Noka.
  | You may now call yourself one of our hunters.
  | Now I must think about our next move. Whatever it is, I fear it won't be straightforward.
- (Lie) There were rogue robots. I think they took them.
  ~ fi
  | Rogues... in the cache?...
  | We've never seen them there before - which means the Wraw must have discovered that as well.
  | Kuso... It seems they have us at a serious disadvantage.
  | Thank you for making the journey - and welcome to the Noka.
  | You may now call yourself one of our hunters.
  | Now I must think about our next move. Whatever it is, I fear it won't be straightforward.
~ fi
? (complete-p 'q3-new-home)
| | You should check in again with Catherine too - I'm sure she'd like to see you again.
| | And knowing her they'll be some jobs you can help with.
| ! eval (activate 'sq-act1-intro)
|?
| ? (not (active-p 'q3-new-home))
| | | Oh, I've also given Jack a special assignment - something I think you'll be well-suited to help with.
| | | He'll be in engineering.
| | | I also heard Sahil is here - our trader friend. His caravan is down in the trading hub, beneath the metro tunnel.
| | | It would be wise to make sure you're well-equipped for your work.
| | ! eval (setf (location 'trader) 'entity-5627)
| | ! eval (activate 'trader-arrive)
")
;; TODO: rewards
;; TODO: act 2 prelude too
;; player learns "Noka" for the first time

#|



|#

#|


|#
