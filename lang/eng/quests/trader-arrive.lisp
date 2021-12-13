;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria trader-arrive)
  :author "Tim White"
  :title "Meet the Trader"
  :description "Sahil the trader has arrived. I should speak with him."
  :on-activate (talk-trader)
  (talk-trader
   :title "Talk to Sahil in the Midwest Market, beneath the Zenith Hub"
   :condition all-complete
   :on-activate T
   :on-complete (trader-chat trader-shop)
   (:action spawn-in
    (setf (location 'trader) 'loc-trader)
    (setf (direction 'trader) 1))
   (:interaction talk-to-trader
    :interactable trader
    :dialogue "
~ trader
| (:jolly)Well well... Are you who I think you are?
~ player
- Who do you think I am?
  < identify
- Most likely.
  < identify
- You've been speaking with Catherine.
  < main

# identify
~ trader
| (:jolly)You're The Stranger!... Or is it just Stranger?
~ player
- Technically it's just \"Stranger\".
  ~ trader
  | (:jolly)Right you are, Stranger!
- Take your pick.
  ~ trader
  | But it's __YOUR__ name. Now I think about it, I'm sure it was Stranger.
~ player
| I see you've been speaking with Catherine.
< main

# main
~ trader
| (:jolly)Haha, yes sir. Guilty as charged.
| She's such a great kid, you know? A talented engineer as well. Reminds me of...
| (:normal)Er-... well, never mind that.
| So you've come to trade with old Sahil, eh?
~ player
- What do you sell?
  ~ trader
  | What doesn't old Sahil sell!
  | Listen: Catherine told me how you helped her out down here - kicked some servo ass by the sounds of things.
- What do I need?
  ~ trader
  | I don't know. What kind of work are you doing?
  | Catherine said you helped her out down here - kicked some servo ass by the sounds of things.
- I think I can manage on my own.
  ~ trader
  | Nonsense! You helped Catherine out - kicked some servo ass by the sounds of things.

~ trader
| The least I can do is help keep you in tip-top condition.
| I've heard about androids - you're different to those servos on pretty much every level.
| You've a lot more going on up here, that's for sure.
~ player
| \"//Sahil taps his fingers on his temple.//\"(light-gray)
~ trader
| Though I hear there are some similarities under the hood. No offence.
| Here, I can assemble some useful bits and pieces into a handy repair pack for you.
~ player
| \"//He turns to the stacks of shelves behind him and rummages around.//\"(light-gray)
| \"//Tools, screws and jury-rigged contraptions roll off and clatter to the floor.//\"(light-gray)
| \"//He crams old circuit boards, clipped wires, and rolls of solder into several tins of different sizes.//\"(light-gray)
~ trader
| (:jolly)Voila! I give you: \"The Android Health Pack\"(orange)! Custom made just for you.
~ player
| \"//It's crude, but I'm sure I can do something with it. If only poke my lenses out.//\"(light-gray)
~ trader
| Just \"let me know when you want to buy one\"(orange), okay?
| You take it easy, habibti."
)))
;; habibti = dear, my love, buddy (Arabic)

;; TODO - added act 3 quest transition check to "|? (or (active-p 'q4-find-alex) (complete-p 'q4-find-alex))" to ensure chat log updates in act 3
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
| (:jolly)Assalam alaikum! Let's talk.
? (< 80  (health player))
| | (:jolly)[? You look well, Stranger! | And how robust you're looking! | I don't think I've seen you looking better.]
|? (< 50  (health player))
| | [? Have you been fighting, Stranger? | Are you alright? You look a little... worse for wear. | You've been hammering servos, haven't you? I can tell.]
|?
| | (:concerned)[? Though I think you've seen better days. | You look like you could really use my help. | You look like you've been dragged through the desert backwards. | Forgive me for prying, but you're all scratched and scuffed - anything I can do?]
! label talk
? (and (not (active-p 'q4-find-alex)) (not (complete-p 'q4-find-alex)))
| ~ player
| - What's your story?
|   ~ trader
|   | A long and sad one I'm afraid... Like most people's.
|   | I used to hang with the Wraw too, just like the \"Noka\"(red) did.
|   | I got out too, only with my caravan instead of a vendetta.
|   | And now I tour the settlements, trade supplies, (:jolly)and try not to get killed, haha.
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
|   | Yeah, those damn servos prowling about.
|   | Don't get me wrong, I can handle myself.
|   | But it's not easy when you pull your own caravan.
|   ~ player
|   | You pull your own caravan?
|   ~ trader
|   | Well no other nadhil is going to do it for me.
|   | I used to have an ox, believe it or not. Ha, an ox, in these parts! It's hard to imagine.
|   | Didn't last long after the wolves got at her throat though. Poor Celina.
|   < talk
| - That'll do.
|   < leave
|? (or (active-p 'q4-find-alex) (complete-p 'q4-find-alex))
| ~ player
| - I thought you might have moved on by now.
|   ~ trader
|   | You tired of me already?- (:jolly)I'm just kidding.
|   | You're right habibti, that is what I do. I'll be moving on soon.
|   | If I stayed in one place too long I'd either run out of stock, or get run through by rogues. (:jolly)I'm not sure which is worse.
|   | It feels good to have something to look after, you know? (:sad)Even if a business is no replacement for Khawla.
|   ~ player
|   - Who's Khawla?
|     ~ trader
|     | (:sad)She was my daughter. She's long dead.
|     ~ player
|     - I'm sorry.
|       ~ trader
|       | (:sad)Me too. It is what it is. Everyone's lost someone.
|     - What happened?
|       ~ trader
|       | (:sad)I... (:normal)I'd rather not talk about it, if it's all the same. 
|     - Let's talk about something else.
|   - Let's talk about something else.
|   < talk
| - What do you know of the Semi Sisters?
|   ~ trader
|   | They're our resident tech gurus! (:jolly)Ha, remember those.
|   | (:normal)I remember a presentation from the head of Semi actually - don't remember his name - unveiling new models of android, just like you.
|   | The sisters used to work on the production line, in the factories deep underground. (:concerned)Conditions were terrible by all accounts.
|   | (:normal)I quite like they've adopted the name. It stokes the revolutionary in me. Which don't get stoked very often.
|   < talk
| - Do you know how to examine me?
|   ~ trader
|   | (:concerned)Ah... examine you?
|   | (:jolly)Oh, examine you!
|   | You've had a warm welcome, have you? Someone don't trust you?
|   ~ player
|   - Jack and Fi.
      ~ trader
|     | (:concerned)Oh really? I expected nothing less from Jack. Fi I'm surprised.
|     | (:normal)Mind you, she has a lot of alqarf on her plate. Give her some time.
|   - Everyone.
|     ~ trader
|     | (:concerned)People can be the worst. And it's got nothing to do with the apocalypse - they were like that before, as I'm sure you remember.
|     | (:jolly)At least you've got a sword. Anyone that doesn't like you, just wave that in their face and they'll soon come around.
|   - Everyone except you and Catherine.
|     ~ trader
|     | (:concerned)People can be the worst. And it's got nothing to do with the apocalypse - they were like that before, as I'm sure you remember.
|     | (:normal)I'm glad I could help though. And Catherine, well... like I said, she's a great kid.
|     | (:jolly)At least you've got a sword. Anyone that doesn't like you, just wave that in their face and they'll soon come around.
|   ~ trader
|   | (:concerned)Yes... trust. It was always a common problem with androids, from what I hear.
|   | But if you want me to look inside you and say if you've been good or bad, I'm afraid I can't.
|   | I can fix superficial damage, but I'm no engineer. Let alone a software one.
|   | Sorry, habibti. It looks like you'll have to change their minds the old-fashioned way.
|   < talk
| - That'll do.
|   < leave

# leave
~ trader
| [? See you later habibti. | You take it easy. | Goodbye for now. | Take care. Masalamah!]")))
;; nadhil = bastard (Arabic)
;; alqarf = shit (Arabic), pronounce: al-kara-fu

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

#| Sahil subplot arc:
1. had some tragedy
2. find out his daughter died
3. find out how his daughter died (link to Wraw/rogues?)

|#

#| TODO:
later talks with trader:
- ask specifically about each faction member
- get into his own history more
- why don't you join up? - reveal he doesn't visit the enemy faction
|#