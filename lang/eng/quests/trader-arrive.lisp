;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria trader-arrive)
  :author "Tim White"
  :title "Find the Trader"
  :description "Sahil the trader has arrived in the Midwest Market, beneath the Hub. I should speak with him."
  :on-activate (talk-trader)
  (talk-trader
   :title "Talk to Sahil"
   :condition all-complete
   :on-activate T
   :on-complete (trader-repeat)
   
   (:interaction talk-to-trader
    :interactable trader
    :variables (small-health medium-health large-health)
    :dialogue "
~ trader
| Well, well... Are you who I think you are?
~ player
- Who do you think I am?
  < identify
- Most likely.
  < identify
- You've been speaking with Catherine.
  < main

# identify
~ trader
| You're The Stranger!... Or is it just Stranger?
~ player
- Technically it's just \"Stranger\".
  ~ trader
  | Right you are, Stranger!
- Take your pick.
  ~ trader
  | But it's YOUR name. Now I think about it, I'm sure it was just Stranger.
~ player
| I see you've been speaking with Catherine.
< main

# main
~ trader
| Haha, yes sir. Guilty as charged.
| She's such a great kid, you know? A talented engineer as well. Reminds me of...
| Er-... well, never mind that.
| So you've come to trade with old Sahil, eh?
~ player
- What do you sell?
  ~ trader
  | What doesn't old Sahil sell!
  | Listen: Catherine told me how you helped her out down here - kicked some rogue ass by the sounds of things!
  < continue
- What do I need?
  ~ trader
  | I don't know. What kind of work are you doing?
  | Catherine said you helped her out down here - kicked some rogue ass by the sounds of things!
  < continue
- I think I can manage on my own.
  ~ trader
  | Nonsense! You helped Catherine out - kicked some rogue ass by the sounds of things!
  < continue

# continue
| The least I can do is help keep you in tip-top condition.
| I've read about androids - under the hood you're pretty much the same as those rogues. No offence.
| Thankfully you've got much more going on up here.
~ player
| //Sahil taps his fingers on his left temple.//
~ trader
| Here, I can probably assemble some useful bits and pieces into a handy repair pack for you.
~ player
| //He turns to the stacks of shelves behind him and rummages around.//
| //Tools, screws and jury-rigged contraptions roll off and clatter to the floor.//
| //He crams old circuit boards, clipped wires, and rolls of solder into several tins of different sizes.//
~ trader
| Voila! I give you: The Android Health Pack. Custom made just for you.
~ player
| //It's crude, but I'm sure I can do something with it. If only poke my eye out.//
~ trader
| Go on, take look - don't by shy. And since this is your first time, you can have them free of charge.
! label shop
~ player
- [(not (var 'small-health)) //Take a small health pack//|]
  ! eval (store 'small-health-pack 1)
  ! eval (setf (var 'small-health) T)
  < shop
- [(not (var 'medium-health)) //Take a medium health pack//|]
  ! eval (store 'medium-health-pack 1)
  ! eval (setf (var 'medium-health) T)
  < shop
- [(not (var 'large-health)) //Take a large health pack//|]
  ! eval (store 'large-health-pack 1)
  ! eval (setf (var 'large-health) T)
  < shop
- I'm done.
  ~ trader
  | You got it.
~ trader
| Say, I don't suppose you'd like to trade that sword of yours? I've never seen anything like it...
~ player
- It's an electronic stun blade. And I need it.
  ~ trader
  | Electronic?... That's downright incredible. And it transforms from your hand?
  < sword-explain
- It is paired via my NFCS. It's useless to anyone else.
  ~ trader
  | It's electronic?... That's downright incredible. And it transforms from your hand?
  < sword-explain
- It's not for sale.
  < end

# sword-explain
~ player
| Correct - it conserves power that way, then auto-unsheathes when I need it.
< end

# end
~ trader
| Well, if you ever change your mind, don't go to anyone else. I'd trade handsomely for it, you can be sure of that.
| You take it easy, habeebti.
")))

;; habeebti = dear, my love, buddy (Arabic)
;; TODO: open shop UI
;; TODO: rename health packs to something more practical and specific for the stranger, that would exist in this world - solder and circuit boards. (Make it clear with the tooltip for the health pack, and even call them something like Repair Packs)
