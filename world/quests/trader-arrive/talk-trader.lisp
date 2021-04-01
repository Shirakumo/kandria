(:name talk-trader
 :title "Talk to Sahil"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (talk-to-trader)
 :on-complete (trader-repeat))
 
(quest:interaction :name talk-to-trader :interactable trader :dialogue "
~ trader
| Well, well... Are you who I think you are?
- Who do you think I am?
  < identify
- Most likely.
  < identify
- You've been speaking with Catherine.
  < main

# identify
~ trader
| You're The Stranger!... Or is it just Stranger?
- Technically it's just \"Stranger\".
  ~ trader
  | Right you are, Stranger!
- Take your pick.
  ~ trader
  | But it's a your name. Now I think about it, I'm sure it was just Stranger.
- Personally I preferred \"android\".
  ~ trader
  | Come now, what kind of a name is that? No, I much prefer Stranger - yes, I'm sure that's what it was.
~ player
| I see you've been speaking with Catherine.
< main

# main
~ trader
| Haha, yes sir. Guilty as charged.
| She's such a great kid, you know? A talented engineer as well. Reminds me of...
| Er-... well, never mind that.
| So you’ve come to trade with old Sahil, eh?
- What do you sell?
  ~ trader
  | What doesn't old Sahill sell!
  | Listen: Catherine told me how you helped her out in the caves - kicked some rogue ass by the sounds of things!
  < continue
- What do I need?
  ~ trader
  | I don't know. What kind of work are you doing?
  | Catherine said you helped her in the caves - kicked some rogue ass by the sounds of things!
  < continue
- I think I can manage on my own.
  ~ trader
  | Nonesense! You helped Catherine in the caves - kicked some rogue ass by the sounds of things!
  < continue

# continue
| The least I can do in thanks is to help you keep yourself in tip-top condition.
| I've read about androids - under the hood you're pretty much the same as those rogues. No offence.
| Thankfully you've got much more going on up here.
~ player
| //Sahil taps his fingers on his left temple.//
~ trader
| Here, I can probably assemble some useful bits and pieces into a handy repair pack for you.
~ player
| //He turns to the stacks of shelves behind him and rummages around.//
| //Tools, screws and jury-rigged contraptions roll off and clatter to the floor.//
| //He crams old circuit boards, clipped wires, and rolls of solder into several small tins.//
~ trader
| Voila! I give you: The Android Repair Pack. Custom made just for you.
| Go on, take look - don't by shy. And since this is your first time, I'll do you a special deal.
| p/h Open shop UI
~ trader
| Say, I don't suppose you'd like to trade that sword of yours? I've never seen anything like it...
- It's an electronic stun blade. And I need it.
  ~ trader
  | Electronic?... That's downright incredible. And it transforms from your arm?
  < sword
- It is paired to me via my Near-Field Communications System. It would be useless to anyone else.
  ~ trader
  | It's electronic?... That's downright incredible. And it transforms from your arm?
  < sword
- It's not for sale.
  < end

# sword
~ player
| Correct - it conserves power that way, then auto-unsheathes when I need it.
< end

# end
~ trader
| Well, if you ever change your mind, don't go to anyone else. I'd trade handsomely for it you can be sure of that.
| You take it easy, habeebti.
")
;; TODO: open shop UI
;; TODO: rename health packs to something more practical and specific for the stranger, that would exist in this world - solder and circuit boards. (Make it clear with the tooltip for the health pack, and even call them something like Repair Packs)


#|



|#
