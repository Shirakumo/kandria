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
;; TIM REPLY & TODO: Good point. Will leave this comment here as a reminder
;; REMARK: Also as you already mentioned in the other part, would be best if the lie
;;         options were gated behind a variable that is set in the other task if you
;;         don't take anything.
;; TIM REPLY: I thought it could be cool if you can take the seeds from the cache AND lie about it, so keep them for yourself. Perhaps if you later trade them in with Sahil, word gets back to Fi - could be a nice consequence
(quest:interaction :name seeds-return-fi :interactable fi :dialogue "
~ fi
| You're back - did you find the seeds?
~ player
| I've got them right here.
~ fi
! eval (retrieve 'seeds (item-count 'seeds))
| Oh my. There must be... fifty sachets here. All fully stocked.
| You've done well. Very well. I'll see these are sown right away.
| This buys us hope I never thought we'd have.
| Know that you are earning my trust, Stranger. Perhaps you will become a part of the Noka yourself.
| God knows we could use another hunter.
| But for now, please accept this reward as a token of my appreciation.
! eval (store 'parts 20)
~ fi
? (complete-p 'q3-new-home)
| | You should check in with Catherine too - I'm sure she'd like to see you again.
| ! eval (activate 'sq-act1-intro)
|?
| ? (not (active-p 'q3-new-home))
| | | Oh, I've also given Jack a special assignment - something I think you'll be well-suited to help with.
| | | He'll be in Engineering.
|   
| | I also heard Sahil is here - our trader friend. His caravan is down in the Midwest Market, beneath the Hub.
| | It would be wise to be equipped for your work.
| ! eval (setf (location 'trader) 'loc-trader)
| ! eval (activate 'trader-arrive)
")
;; kuso = shit (Japanese)
;; TODO: act 2 prelude too
;; player learns "Noka" for the first time
;; TODO fi happy - | Oh my. There must be... fifty sachets here. All fully stocked.

#| ARCHIVED VERSION before lie options removed - for reference. May be useable in a future act.

(quest:interaction :name seeds-return-fi :interactable fi :dialogue "
~ fi
| You're back - did you find the seeds?
~ player
- [(have 'seeds) I've got them right here.]
  ~ fi
  ? (= 54 (item-count 'seeds))
  | ! eval (retrieve 'seeds 54)
  | | Oh my... there must be... fifty sachets here. All fully stocked.
  | | You've done well. Very well. I'll see these are sown right away.
  | | This buys us hope I never thought we'd have.
  | | Know that you are earning my trust, Stranger. Perhaps in time you will become a part of the Noka yourself.
  | | God knows we could use another hunter.
  | | But for now, please accept this reward as a token of my appreciation.
  | ! eval (store 'parts 20)
  | < end
  |? (= 17 (item-count 'seeds))
  | ! eval (retrieve 'seeds 17)
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
  | | But this has earned some trust - perhaps in time you will become a part of the Noka yourself.
  | | God knows we could use another hunter. But for now, please accept this reward as a token of my appreciation.
  | ! eval (store 'parts 20)
  | < end
- (Lie) I'm afraid there weren't any left.
  ~ fi
  | ...
  | None left... Alex told me there were at least fifty sachets remaining.
  | I knew we should have taken them all when we had the chance.
  | I suppose I was worried they'd be destroyed, if we came under attack.
  < bad-end
- (Lie) There were rogue robots. I think they took them.
  ~ fi
  | Rogues... in the cache?...
  | We've never seen them there before - which means the Wraw must have discovered that as well.
  | Kuso... It seems they have us at a serious disadvantage.
  < bad-end
# bad-end
| Well, thank you for making the journey. This has earned some trust.
| Perhaps in time you will become a part of the Noka yourself. God knows we could use another hunter.
| But for now, please accept this reward as a token of my appreciation.
! eval (store 'parts 20)
| Now I must think about our next move. Whatever it is, I fear it won't be straightforward.
< end
# end
~ fi
? (complete-p 'q3-new-home)
| | You should check in with Catherine too - I'm sure she'd like to see you again.
| ! eval (activate 'sq-act1-intro)
|?
| ? (not (active-p 'q3-new-home))
| | | Oh, I've also given Jack a special assignment - something I think you'll be well-suited to help with.
| | | He'll be in Engineering.
|   
| | I also heard Sahil is here - our trader friend. His caravan is down in the Midwest Market, beneath the Hub.
| | It would be wise to be well-equipped for your work.
| ! eval (setf (location 'trader) 'loc-trader)
| ! eval (activate 'trader-arrive)
")

|#