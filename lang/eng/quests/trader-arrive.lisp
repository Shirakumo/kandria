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
   :invariant (not (complete-p 'q11-intro))
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
- Most likely.
~ trader
| (:jolly)You're The Stranger!... (:normal)Or was it just Stranger?
? (not (complete-p 'q7-my-name))
| ~ player
| - Technically it's just Stranger.
|   ~ trader
|   | (:jolly)Right you are, Stranger!
| - Take your pick.
|   ~ trader
|   | (:jolly)But it's __YOUR__ name. Now I think about it, I'm sure it was just Stranger.
| - I used to have a different name.
|   ~ trader
|   | Can't remember it though, right?
|   | Don't worry. And speaking of remembering, I'm sure it was just Stranger.
|?
| ? (string= (@ player-name-1) (nametag player))
| | ~ player
| | - It's Stranger.
| |   ~ trader
| |   | (:jolly)Right you are, Stranger!
| | - It's Stranger, but I used to have a different name.
| |   ~ trader
| |   | Can't remember it though, right?
| |   | (:jolly)Well it's nice to meet you, Stranger!
| | - It's Stranger. It was never The Stranger.
| |   ~ trader
| |   | Oh, my bad, habibti.
| |   | (:jolly)Well it's nice to meet you, Stranger!
| |?
| | ~ player
| | - Actually now it's {(nametag player)}.
| |   ~ trader
| |   | Old \"Sahil\"(yellow) got old information, huh? I'm sorry, habibti.
| |   ! eval (setf (nametag (unit 'trader)) (@ trader-nametag))
| |   ~ trader
| |   | (:jolly)Well it's nice to meet you, {(nametag player)}!
| | - It used to be Stranger.
| |   ~ trader 
| |   | Used to be? Old \"Sahil\"(yellow) got old information, huh?
| |   ! eval (setf (nametag (unit 'trader)) (@ trader-nametag))
| |   ~ trader
| |   | Sorry, habibti. What is it now?
| |   ~ player
| |   | {(nametag player)}.
| |   ~ trader
| |   | (:jolly)Well it's nice to meet you, {(nametag player)}!
| | - Now it's {(nametag player)}, which was possibly my original name.
| |   ~ trader
| |   | Right - because you can't remember.
| |   | (:jolly)Well it's nice to meet you, {(nametag player)}!
~ trader
| (:jolly)Word spreads quickly around here. And Catherine couldn't stop talking about you.
| Such a great kid, you know? A talented engineer as well. Reminds me of...
| (:normal)Er-... well, never mind that.
| So you've come to trade with old \"Sahil\"(yellow), eh?
! eval (setf (nametag (unit 'trader)) (@ trader-nametag))
~ player
- What do you sell?
  ~ trader
  | What doesn't old Sahil sell!
  | Listen: Catherine told me how you helped her out down here - kicked some Servo ass by the sounds of things.
- What do I need?
  ~ trader
  | I don't know. What kind of work are you doing?
  | Catherine said you helped her out down here - kicked some Servo ass by the sounds of things.
- I think I can manage on my own.
  ~ trader
  | Nonsense! You helped Catherine out - kicked some Servo ass by the sounds of things.
~ trader
| The least I can do is help keep you in tip-top condition.
| I've heard about androids - you're different to those Servos. You've a lot more going on up here, that's for sure.
~ player
| \"He's tapping his fingers on his temple. Yes, the crystalline matrix is quite sophisticated\"(light-gray, italic) (:embarassed)\"- when it's not corrupting your memories.\"(light-gray, italic)
~ trader
| Though I hear there are some similarities under the hood. No offence.
| Here, I can assemble some useful bits and pieces into a handy repair pack for you.
~ player
| \"Why is he rummaging around on those shelves? Surely there's nothing of value up there, judging by all the crap that's clattering to the floor.\"(light-gray, italic)
| \"Maybe I spoke too soon: he's cramming old circuit boards, clipped wires, and rolls of solder into several tins of different sizes.\"(light-gray, italic)
~ trader
| (:jolly)Voila! I give you: \"The Android Health Pack\"(orange)! Custom made just for you.
~ player
| \"It's crude, but does resemble the ones I used to use.\"(light-gray, italic)
| \"I'm sure I can do something with it - if only poke my lenses out.\"(light-gray, italic)
~ trader
| Just \"let me know when you want to buy one\"(orange), okay?
| You take it easy, habibti."
)))
;; habibti = dear, my love, buddy (Arabic) (female form)

;; If not done Sahil intro (above) by q11-intro complete, it gets voided, and this quest opens up automatically (as do the buy/sell quests); Sahil's name also then gets force set during the only dialogue chat with him, since by that point, even if not chatted to him, it's plausible that you'd know who Sahil is (buy/sell options and hub don't show his name)
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
? (not (string= (@ trader-nametag) (nametag (unit 'trader))))
| ! eval (setf (nametag (unit 'trader)) (@ trader-nametag))
  
~ trader
? (complete-p 'q13-planting-bomb)
| | If we must, habibti.
|? (complete-p 'q11-intro)
| | ... I'm sorry, {(nametag player)}, I can't.
| | I'll still trade though, if you want.
|?
| | (:jolly)Assalam alaikum! Let's talk.
| ? (< 80 (health-percentage player))
| | | (:jolly)[? You look well, {(nametag player)}! | And how robust you're looking! | I don't think I've seen you looking better.]
| |? (< 50 (health-percentage player))
| | | [? Have you been fighting, {(nametag player)}? | Are you alright? You look a little... worse for wear. | You've been hammering Servos again, haven't you?]
| |?
| | | [? Though I think you've seen better days. | You look like you could really use my help. | You look like you've been dragged through the desert backwards. | Forgive me for prying, but you're all scratched and scuffed - anything I can do?]
  
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
|   | Yeah, those damn Servos prowling about.
|   | Don't get me wrong, I can handle myself. But it's not easy when you pull your own caravan.
|   | I used to have an ox, believe it or not. Ha, an ox, in this hellhole! It's hard to imagine.
|   | Didn't last long after the wolves got at her throat though. Poor Celina.
|   < talk
| - Do you know how to examine me?
|   ~ trader
|   | Ah... examine you?
|   | (:jolly)Oh, examine you!
|   | Someone given you a warm welcome, have they?
|   ~ player
|   - Jack and Fi.
|     ~ trader
|     | Oh really? I expected nothing less from Jack. Fi I'm surprised about.
|     | Mind you, she has a lot of alqarf on her plate. Give her some time.
|   - Everyone.
|     ~ trader
|     | People can be the worst. And it's got nothing to do with the apocalypse - they were like that before, as I'm sure you remember.
|     | (:jolly)At least you've got a sword. Anyone that doesn't like you, just wave that in their face and they'll soon come around.
|   - Everyone except you and Catherine.
|     ~ trader
|     | People can be the worst. And it's got nothing to do with the apocalypse - they were like that before, as I'm sure you remember.
|     | I'm glad I could help though. And Catherine, well... like I said, she's a great kid.
|     | (:jolly)At least you've got a sword. Anyone that doesn't like you, just wave that in their face and they'll soon come around.
|   - Let's talk about something else.
|     < talk
|   ~ trader
|   | Yes... trust. It was always a common problem with androids.
|   | But if you want me to look inside you and say if you've been good or bad, I'm afraid I can't.
|   | I can fix superficial damage, but I'm no engineer. Let alone a software one.
|   | Sorry, habibti. It looks like you'll have to change their minds the old-fashioned way.
|   < talk
| - That'll do.
|   < leave
|? (and (or (active-p 'q4-find-alex) (complete-p 'q4-find-alex)) (not (complete-p 'q7-my-name)))
| ~ player
| - When are you moving on?
|   ~ trader
|   | Tired of me already? (:jolly)I'm just kidding.
|   | (:normal)You're right habibti, that is what I do. I'll be gone soon.
|   | If I stayed in one place too long I'd either run out of stock, or get run through by rogues. (:jolly)I'm not sure which is worse.
|   | (:normal)It feels good to have something to look after, you know? Even if a business is no replacement for Khawla.
|   ~ player
|   - Who's Khawla?
|     ~ trader
|     | She was my daughter. She's long dead.
|     ! eval (setf (var 'trader-daughter) T)
|     ~ player
|     - I'm sorry.
|       ~ trader
|       | Me too. It is what it is. Everyone's lost someone.
|     - What happened?
|       ~ trader
|       | I... I'd rather not talk about it, if it's all the same. 
|     - Let's talk about something else.
|   - Let's talk about something else.
|   < talk
| - What do you know of the Semi Sisters?
|   ~ trader
|   | They're our resident tech gurus! (:jolly)Ha, remember those?
|   | (:normal)I remember a presentation from the head of Semi - don't remember his name - unveiling new models of android, just like you.
|   | The sisters used to work on the production line, in the factories down here. Conditions were terrible by all accounts.
|   | I quite like they've adopted the name. It stokes the revolutionary in me. Which don't get stoked very often.
|   | Needless to say they aren't too popular, what with their past associations with androids.
|   < talk
| - That'll do.
|   < leave
|? (and (complete-p 'q7-my-name) (not (complete-p 'q10-wraw)))
| ~ player
| - When are you moving on?
|   ~ trader
|   | (:jolly)What, you don't want to buy supplies?
|   | (:normal)Truth be told, I heard the rumours about the Wraw in Cerebat territory.
|   | I would've moved on already if not for that.
|   | Are they true, the rumours?
|   ~ player
|   - [(complete-p 'q8a-secret-supplies)I'm afraid so.|]
|     ~ trader
|     | Alqarf!
|     | I'd better let you get on. It sounds like you have bigger fish to fry than old Sahil.
|     < talk
|   - [(not (complete-p 'q8a-secret-supplies)) That's what I'm trying to find out.|]
|     ~ trader
|     | Well in that case I'd better not keep you. You have bigger fish to fry than old Sahil.
|     < talk
|   - I'm not sure.
|     ~ trader
|     | Still, I'd rather not risk it. I think I'll stay here a while longer.
|     < talk
|   - I can't say.
|     ~ trader
|     | I understand, habibti.
|     | Still, I think it would be unwise for me to leave your borders right now. I'm staying right here.
|     < talk
|   - Let's talk about something else.
|     < talk
| - What do you know about the Cerebats?
|   ~ trader
|   | Well, they're the self-proclaimed council around here.
|   | But what good's a council that can't enforce its laws?
|   | The only people who can enforce anything around here are the Wraw. Maybe the Semis.
|   | (:jolly)Maybe you, too.
|   < talk
| - Have you seen Alex?
|   ~ trader
|   | I'm afraid not, habibti.
|   < talk
| - [(var 'trader-daughter) What happened to your daughter?|]
|   ~ trader
|   | ...
|   | ... I suppose with everything that's happening, now's as good a time as any to talk about her.
|   | Her name was Khawla - I think I told you that before. She was a great engineer - almost as good as Catherine.
|   | I lost her on the roads, just like Celina, my oxen.
|   | 'Cept it wasn't wolves for her. It was people.
|   | Rogues, I think. Maybe a Wraw hunting pack. I wasn't really in a fit state to see who they were.
|   | They took her, anyway. And I never saw her again.
|   ~ player
|   - I'm so sorry.
|     ~ trader
|     | Thank you, {(nametag player)}.
|     | It's okay. Khawla should be remembered and talked about. I should speak her name like I always did.
|     < talk
|   - Sorry for making you relive it.
|     ~ trader
|     | It's okay, {(nametag player)}.
|     | Khawla should be remembered and talked about. I should speak her name like I always did.
|     < talk
|   - Could she still be alive?
|     ~ trader
|     | No. Khawla's dead. Slaves don't live very long.
|     | Or she met an even worse end.
|     | ... I'd rather not think about that.
|     | Now I remember the good times instead.
|     | Times that should be remembered and talked about. I should speak her name like I always did.
|     < talk
|   - Let's talk about something else.
|     < talk
| - I need to go.
|   < leave
|? (and (complete-p 'q10-wraw) (not (complete-p 'q11-intro)))
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
|   | They've amassed an invasion force, mechs and soldiers, big enough to take the whole valley.
|   ~ trader
|   | You're not joking are you?...
|   | That would explain why traders haven't been allowed on Wraw land for some time.
|   | Thank you for telling me, {(nametag player)}.
|   < talk
| - Do androids live in the mountains?
|   ~ trader
|   | Ha, I wondered when you might hear about that.
|   | I like to think they do - especially since I met you. Lots of other {(nametag player)}s running around like gazelles. A real haven.
|   | Assuming they're friendly, of course.
|   | But I think I'm in the minority on that particular issue.
|   < talk
| - I need to go.
|   < leave
|? (complete-p 'q13-planting-bomb)
| ~ trader
| | Look, I'm not proud that I ran. But I'm here now, and I'm ready to fight.
| | Let's talk later, okay?

# leave
~ trader
| [? See you later habibti. | You take it easy. | Goodbye for now. | Take care. Masalamah!]")))
;; habibti = dear, my love, buddy (Arabic) (female form)
;; nadhil = bastard (Arabic) - unused at the moment
;; alqarf = shit (Arabic), pronounce: al-kara-fu
;; masalamah = goodbye (Arabic)

(quest:define-quest (kandria trader-shop)
  :title ""
  :visible NIL
  :on-activate T
  (trade-shop
   :title ""
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
