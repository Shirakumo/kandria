(:name talk-to-jack
 :title "Talk to Jack in Engineering"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (talk-jack)
 :on-complete (q3-new-home))

;; could have been sent here by Fi or Catherine
(quest:interaction :name talk-jack :interactable jack :dialogue "
~ jack
| Oh, it's you. Come to kill me?
~ player
- What?
  ~ jack
  | No sense of humour. Figures.
- What do you think?
  ~ jack
  | No. Not while you've got Fi and Cathy wrapped around your fake little finger.
- I wish.
  ~ jack
  | O oh, you keep talking like that and Fi will dismantle you. Wouldn't want that, would ya?
~ jack
| Anyway, you can do something for me.
| Fi wants to scout for a new home - I guess she's worried sick now the Wraw are breathing down our necks.
| Well as you can see, I'm no scout. I guess I just don't have the physique for it.
| Alex is our hunter, but God knows where they are. So it's up to you... Stranger.
~ player
- Lucky me.
  ~ jack
  | Let's hope so.
- What's the plan?
- You got it boss.
  ~ jack
  | Bet your behavioural mechanisms are working overtime, try'na figure out how to get on my good side, huh? Look...
~ jack
| I think the Ruins to the east are your best shot. It keeps us close to the Farm, and still gives us shelter.
| So scout around, climb, do whatever an android does.
| Just remember while you ninja around that we mere mortals gotta follow your path.
| Your android brain might think the top of a toppled skyscraper is the safest place there is.
| But people can't climb there - let alone live up there. You get me?
~ player
- Got it.
- Not really.
  ~ jack
  | Tough titty - I ain't repeating myself.
- Do you think I'm stupid?
  ~ jack
  | I'm yet to see evidence to the contrary. Just do the job, okay?
~ jack
| Well, I guess I should say good luck.
| Don't bother to check in with your FFS or whatever the fuck it's called - I'm busy.
")

#|


|#
