;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria trader-arrive)
  :author "Tim White"
  :title "Meet the Trader"
  :description "Sahil the trader has arrived. I should speak with him and stock up."
  :on-activate (talk-trader)
  (talk-trader
   :title "Talk to Sahil in the Midwest Market, beneath the Zenith Hub"
   :marker '(chunk-1960 2600)
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
! eval (setf (nametag (unit 'trader)) (@ trader-nametag))
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
| I've heard about androids - you're different to those servos. You've a lot more going on up here, that's for sure.
~ player
| \"Sahil taps his fingers on his temple.\"(light-gray, italic)
~ trader
| Though I hear there are some similarities under the hood. No offence.
| Here, I can assemble some useful bits and pieces into a handy repair pack for you.
~ player
| \"He turns to the stacks of shelves behind him and rummages around.\"(light-gray, italic)
| \"Tools, screws and jury-rigged contraptions roll off and clatter to the floor.\"(light-gray, italic)
| \"He crams old circuit boards, clipped wires, and rolls of solder into several tins of different sizes.\"(light-gray, italic)
~ trader
| (:jolly)Voila! I give you: \"The Android Health Pack\"(orange)! Custom made just for you.
~ player
| \"It's crude, but I'm sure I can do something with it. If only poke my lenses out.\"(light-gray, italic)
~ trader
| Just \"let me know when you want to buy one\"(orange), okay?
| You take it easy, habibti."
)))
;; habibti = dear, my love, buddy (Arabic)

;; TODO - add act 3 quest transition check to "|? (or (active-p 'q4-find-alex) (complete-p 'q4-find-alex))" to ensure chat log updates in act 3
(quest:define-quest (kandria trader-chat)
  :author "Tim White"
  :title ""
  :visible NIL
  :on-activate T
  (chat-trader
   :title ""
   :on-activate T
   (:interaction chat-with-trader
    :title "Can we talk?"
    :interactable trader
    :repeatable T
    :dialogue "
~ trader
| (:jolly)Assalam alaikum! Let's talk.
? (< 80  (health player))
| | (:jolly)[? You look well, {#@player-nametag}! | And how robust you're looking! | I don't think I've seen you looking better.]
|? (< 50  (health player))
| | [? Have you been fighting, {#@player-nametag}? | Are you alright? You look a little... worse for wear. | You've been hammering servos, haven't you? I can tell.]
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
|   | Fi's a good person, which is rare these days.
|   | They broke out all on their own, had enough of that Wraw bullshit.
|   | Can't blame 'em. It was brave. It might also prove stupid.
|   < talk
| - Catherine said you were later than expected.
|   ~ trader
|   | Yeah, those damn servos prowling about.
|   | Don't get me wrong, I can handle myself. But it's not easy when you pull your own caravan.
|   | I used to have an ox, believe it or not. Ha, an ox, in this hellhole! It's hard to imagine.
|   | Didn't last long after the wolves got at her throat though. Poor Celina.
|   < talk
| - That'll do.
|   < leave
|? (and (or (active-p 'q4-find-alex) (complete-p 'q4-find-alex)) (not (complete-p 'q7-my-name)))
| ~ player
| - When are you moving on?
|   ~ trader
|   | Tired of me already? (:jolly)I'm just kidding.
|   | You're right habibti, that is what I do. I'll be gone soon.
|   | If I stayed in one place too long I'd either run out of stock, or get run through by rogues. (:jolly)I'm not sure which is worse.
|   | It feels good to have something to look after, you know? (:sad)Even if a business is no replacement for Khawla.
|   ~ player
|   - Who's Khawla?
|     ~ trader
|     | (:sad)She was my daughter. She's long dead.
|     ! eval (setf (var 'trader-daughter) T)
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
|   | They're our resident tech gurus! (:jolly)Ha, remember those?
|   | (:normal)I remember a presentation from the head of Semi - don't remember his name - unveiling new models of android, just like you.
|   | The sisters used to work on the production line, in the factories down here. (:concerned)Conditions were terrible by all accounts.
|   | (:normal)I quite like they've adopted the name. It stokes the revolutionary in me. Which don't get stoked very often.
|   < talk
| - Do you know how to examine me?
|   ~ trader
|   | (:concerned)Ah... examine you?
|   | (:jolly)Oh, examine you!
|   | Had a warm welcome, have you? Someone don't trust you?
|   ~ player
|   - Jack and Fi.
|     ~ trader
|     | (:concerned)Oh really? I expected nothing less from Jack. Fi I'm surprised about.
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
|   - Let's talk about something else.
|     < talk
|   ~ trader
|   | (:concerned)Yes... trust. It was always a common problem with androids.
|   | But if you want me to look inside you and say if you've been good or bad, I'm afraid I can't.
|   | I can fix superficial damage, but I'm no engineer. Let alone a software one.
|   | Sorry, habibti. It looks like you'll have to change their minds the old-fashioned way.
|   < talk
| - That'll do.
|   < leave
|? (and (complete-p 'q7-my-name) (not (complete-p 'q10-wraw)))
| ~ player
| - When are you moving on?
|   ~ trader
|   | (:jolly)What, you don't want to buy supplies?
|   | (:concerned)Truth be told, I heard the rumours about the Wraw in Cerebat territory.
|   | I would've moved on already if not for that.
|   | Are they true, the rumours?
|   ~ player
|   - [(complete-p 'q8a-secret-supplies)I'm afraid so.|]
|     ~ trader
|     | (:concerned)Alqarf!
|     | I'd better let you get on. It sounds like you have bigger fish to fry than old Sahil right now.
|     < talk
|   - [(not (complete-p 'q8a-secret-supplies)) That's what I'm trying to find out.|]
|     ~ trader
|     | (:concerned)Well in that case I'd better not keep you. You have bigger fish to fry than old Sahil right now.
|     < talk
|   - I'm not sure.
|     ~ trader
|     | (:concerned)Still, I'd rather not risk it. I think I'll stay here a while longer.
|     < talk
|   - I can't say.
|     ~ trader
|     | (:concerned)I understand, habibti.
|     | I think it would be unwise for me to leave your borders right now. I'm staying right here.
|   - Let's talk about something else.
|     < talk
| - What do you know about the Cerebats?
|   ~ trader
|   | (:concerned)You mean other than the rumours about Wraw being sighted on their land?
|   | (:normal)Well, they're the self-proclaimed council around here.
|   | (:jolly)But what good's a council that can't enforce its laws?
|   | (:concerned)The only people who can enforce anything around here are the Wraw. Maybe the Semis.
|   < talk
| - [(var 'trader-daughter) What happened to your daughter?|]
|   ~ trader
|   | (:concerned)...
|   | ... I suppose with everything that's happening, now's as good a time as any to talk about her.
|   | (:normal)Her name was Khawla - I think I told you that before. She was a great engineer - almost as good as Catherine.
|   | I lost her on the roads, just like Celina, my oxen.
|   | (:sad)'Cept it wasn't wolves for her. It was people.
|   | Rogues, I think. Maybe a Wraw hunting pack. I wasn't really in a fit state to see who they were.
|   | They took her, anyway. And I never saw her again.
|   ~ player
|   - I'm so sorry.
|     ~ trader
|     | Thank you, habibti.
|     | It's okay. Khawla should be remembered and talked about. I should speak her name like I always did.
|     < talk
|   - Sorry for making you relive it.
|     ~ trader
|     | It's okay, habibti.
|     | Khawla should be remembered and talked about. I should speak her name like I always did.
|     < talk
|   - Could she still be alive?
|     ~ trader
|     | (:sad)No. Khawla's dead. Slaves don't live very long.
|     | Or she met an even worse end.
|     | (:normal)I'd rather not think about that.
|     | Now I remember the good times instead.
|     | Times that should be remembered and talked about. I should speak her name like I always did.
|     < talk
|   - Let's talk about something else.
|     < talk
| - I need to go.
|   < leave
|? (and (complete-p 'q10-wraw) (not (active-p 'q11-recruit-semis)))
| ~ player
| - The Wraw are coming.
|   ~ trader
|   | What, right now?
|   ~ player
|   - I think so.
|     ~ trader
|     | They're coming for the Noka?
|   - Save yourself!
|     ~ trader
|     | (:jolly)Oh, that's a good one!
|   - They're planning to invade the entire valley.
|     ~ trader
|     | (:jolly)Oh, that's a good one!
|   - Let's talk about something else.
|     < talk
|   ~ player
|   | They've amassed an invasion force, mechs and soldiers, big enough to take the entire valley.
|   ~ trader
|   | (:concerned)You're not joking are you?...
|   | That would explain why traders haven't been allowed on their land for some time.
|   | Thank you for telling me, {#@player-nametag}.
|   < talk
| - Do androids live in the mountains?
|   ~ trader
|   | Ha, I wondered when you might hear about that.
|   | I like to think they do - especially since I met you. Lots of other {#@player-nametag}s running around like gazelles. A real haven.
|   | Assuming they're friendly like you, of course.
|   | But I think I'm in the minority.
|   < talk
| - I need to go.
|   < leave

# leave
~ trader
| [? See you later habibti. | You take it easy. | Goodbye for now. | Take care. Masalamah!]")))
;; nadhil = bastard (Arabic) - unused at the moment
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
