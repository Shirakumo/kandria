;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)
(quest:update trader-arrive :active)
(quest:define-quest (kandria trader-arrive)
  :author "Tim White"
  :title "Find the Trader"
  :description "Sahil the trader has arrived. I should speak with him."
  :on-activate (talk-trader)
  (talk-trader
   :title "Talk to Sahil in the Midwest Market, beneath the Zenith Hub"
   :condition (complete-p 'talk-to-trader)
   :on-activate (spawn-in talk-to-trader)
   :on-complete (trader-repeat)
   (:action spawn-in
    (setf (location 'trader) 'loc-trader))
   (:interaction talk-to-trader
    :interactable trader
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
  | But it's __YOUR__ name. Now I think about it, I'm sure it was Stranger.
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
- What do I need?
  ~ trader
  | I don't know. What kind of work are you doing?
  | Catherine said you helped her out down here - kicked some rogue ass by the sounds of things!
- I think I can manage on my own.
  ~ trader
  | Nonsense! You helped Catherine out - kicked some rogue ass by the sounds of things!

| The least I can do is help keep you in tip-top condition.
| I've read about androids - under the hood you're pretty much the same as those rogues. No offence.
| Thankfully you've got much more going on up here.
~ player
| \"//Sahil taps his fingers on his left temple.//\"(light-gray)
~ trader
| Here, I can assemble some useful bits and pieces into a handy repair pack for you.
~ player
| \"//He turns to the stacks of shelves behind him and rummages around.//\"(light-gray)
| \"//Tools, screws and jury-rigged contraptions roll off and clatter to the floor.//\"(light-gray)
| \"//He crams old circuit boards, clipped wires, and rolls of solder into several tins of different sizes.//\"(light-gray)
~ trader
| Voila! I give you: \"The Android Health Pack\"(orange). Custom made just for you!
~ player
| \"//It's crude, but I'm sure I can do something with it. If only poke my lenses out.//\"(light-gray)
~ trader
| Go on, take look - don't be shy.
")))

(quest:define-quest (kandria trader-repeat)
  :title "Trade"
  :visible NIL
  :on-activate T
  (trade-trader
   :title "Trade"
   :on-activate T
   (:interaction buy
    :interactable trader
    :repeatable T
    :title (@ shop-buy-items)
    :dialogue "! eval (show-sales-menu :buy 'trader)")
   (:interaction sell
    :interactable trader
    :repeatable T
    :title (@ shop-sell-items)
    :dialogue "! eval (show-sales-menu :sell 'trader)")))
