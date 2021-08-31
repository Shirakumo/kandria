;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria trader-arrive)
  :author "Tim White"
  :title "Find the Trader"
  :description "Sahil the trader has arrived. I should speak with him."
  :on-activate (talk-trader)
  (talk-trader
   :title "Talk to Sahil in the Midwest Market, beneath the Zenith Hub"
   :condition all-complete
   :on-activate T
   :on-complete (trader-chat trader-shop)
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
| I've heard about androids - under the hood you're pretty much the same as those rogues. No offence.
| Thankfully you've got much more going on up here.
~ player
| \"//Sahil taps his fingers on his temple.//\"(light-gray)
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
| Just \"let me know when you want to buy one\"(orange), okay?
| You take it easy, habibti."
)))
;; habibti = dear, my love, buddy (Arabic)

(quest:define-quest (kandria trader-chat)
  :author "Tim White"
  :title "Trader Chat"
  :description "If I want to trade items, I should find Sahil in the Midwest Market, beneath the Zenith Hub."
  :visible NIL
  :on-activate T  
  (chat-trader
   :title "Talk to Sahil"
   :on-activate T
   (:interaction chat-with-trader
    :title "Can we talk?"
    :interactable trader
    :repeatable T
    :dialogue "
~ trader
| Assalam alaikum! Let's talk.
? (< 80  (health player))
| | [? You look well, Stranger! | And how robust you're looking! | I don't think I've seen you looking better.]
|? (< 50  (health player))
| | [? Have you been fighting, Stranger? | Are you alright? You look a little... worse for wear. | You've been pounding rogues, haven't you?]
|?
| | [? Though I think you've seen better days. | You look like you could really use my help. | You look like you've been dragged through the desert backwards. | Forgive me for prying, but you're all scratched and scuffed - anything I can do?]
! label talk
? (not (complete-p 'q4-find-allies))
| ~ player
| - What's your story?
|   ~ trader
|   | A long and sad one I'm afraid... Like most people's.
|   | I used to hang with the Wraw too, just like the \"Noka\"(red) did.
|   | I got out too, only with my caravan instead of a vendetta.
|   | And now I tour the settlements, trading, making ends meet - and making things too!
|   < talk
| - What do you make of this place?
|   ~ trader
|   | The \"Noka\"(red)? They're a nice bunch, what can I say?
|   | Fi's a good person, which is rare in these parts.
|   | They broke out all on their own, had enough of that Wraw bullshit.
|   | Can't blame 'em. It was brave. It might also prove stupid. We'll see.
|   < talk
| - Catherine said you were later than expected.
|   ~ trader
|   | Yeah, those damn rogues prowling about.
|   | Don't get me wrong, I can handle myself.
|   | But it's not easy when you're pulling your own caravan.
|   ~ player
|   | You pull your own caravan?
|   ~ trader
|   | Well no other nadhil is going to do it for me.
|   | I used to have an ox, believe it or not. Ha, an ox, in these parts! It's hard to imagine.
|   | Didn't last long after the wolves got at her throat though. Poor Celina.
|   < talk
| - That'll do.
|   < leave

# leave
~ trader
| [? See you later habibti. | You take it easy. | Goodbye for now. | Take care. Masalamah!]")))
;; nadhil = bastard (Arabic)

(quest:define-quest (kandria trader-shop)
  :title "Trade"
  :visible NIL
  :on-activate T
  (trade-shop
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

#| TODO restore Sahil comment about the sword? Could be an NPC agency question he asks you, during chatting when asking him stuff; on first parting, have the dialogue trigger, then set a var so it doesn't happen again.
Prev dialogue referece:

~ trader
| Say, I don't suppose you'd like to trade that sword of yours? I've never seen anything like it.
~ player
- It's an electronic stun blade. And I need it.
  ~ trader
  | Electronic?... That's downright incredible. And it transforms from your hand?
  < sword-explain
- It's paired to my NFCS. It'd just be a big stick to anyone else.
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
| You take it easy, habibti.

And then also add to the chatting sign off random selection: Goodbye! And if you ever change your mind about that sword of yours... I know, I know. 

|#


#| TODO when get scrolling options, restore to talk menu (or add as replacement talking points, once the narrative has moved onto act 2)

| - Do you know about finding a computer?
|   ~ trader
|   | A computer? Now there's a word you don't hear anymore.
|   | Does Catherine want to play one of those video games from the old world I was telling her about?
|   | You remember them, right?
|   ~ player
|   - Sure, games were fun.
|     ~ trader
|     | You betcha! Boy do I miss the internet.
|   - They were a new artform, sadly lost.
|     ~ trader
|     | Well said, Stranger. Well said.
|   - They used similar technology to my own. I admired that.
|     ~ trader
|     | Indeed, there was a lot to admire - especially for a tech-head like me.
|   ~ trader
|   | But no, no one told me anything about a computer. Which is good, because working ones are impossible to find.
|   < talk
| - Do you like androids?
|   ~ trader
|   | Ah, you've had a warm welcome, have you?
|   | Listen, it's nothing personal. It's just everyone has heard the stories, you know?
|   | It's always androids this, androids that... Like a race of servile machines could destroy the world!
|   | No offence. It's haraa, that's what it is.
|   ~ player
|   | So what did destroy the world?
|   ~ trader
|   | I don't know...
|   | But what I do know is humanity could stand to take a good long look in the mirror.
|   < talk

|#

#| TODO:
later talks with trader:
- ask specifically about each faction member
- get into his own history more
- why don't you join up? - reveal he doesn't visit the enemy faction
|#