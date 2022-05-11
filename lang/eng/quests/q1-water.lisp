;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria q1-water)
  :author "Tim White"
  :title "Fix the Water Supply"
  :description "The settlement are on the brink of starvation, and will lose their crop if the water supply isn't restored."
  (:go-to (main-leak-1 :lead catherine)
   :title "Follow Catherine below ground using the ladder in Engineering, then follow the red pipeline")
  (:interact (catherine :now T)   
  "~ catherine
| Alright, here's a leak.
| That's strange, the pipe is cracked.
~ player
- Can you fix it?
  ~ catherine
  | I wouldn't be much of an engineer if I couldn't.
- What caused this?
  ~ catherine
  | Subsidence, most likely. Though there's no sign of a landslide.
- Why is it strange?
  ~ catherine
  | Cracks are usually the result of subsidence. But there's no sign of a landslide.
~ catherine
| Oh well, here goes. I'm gonna weld it, so best not look at the arc - don't want to fry your cameras.
~ player
| \"Catherine puts her goggles on and welds the cracked pipe with steady hands.\"(light-gray, italic)
- (Enable UV filters)
  | \"I watch the dull glow; sparks crackle and spit.\"(light-gray, italic)
- (Don't enable filters)
  | \"It's like staring into the sun. Into the centre of a cataclysm.\"(light-gray, italic)
  ! eval (setf (var 'q1-weld-burn) T)
  | (:embarassed)\"Oops. I think that damaged my lenses.\"(light-gray, italic)
! eval (setf (animation (unit 'main-leak-1)) 'normal)
~ catherine
| That should hold it.
~ catherine
| Jack, I've fixed the leak - the pipe was cracked. How's the water pressure? Over.
~ jack
| Weak as shit. There must be another leak. Over.
~ catherine
| Alright - we'll keep looking. Over and out.
| Come on... (:disappointed)er - you really need a name.
| Do androids have names?
~ player
- Yes we have names!
  ~ catherine
  | (:concerned)Of course you do, I'm sorry. What's yours?
  ~ player
  | (:thinking)That's the thing: I don't remember my name. I don't remember a lot of things.
  ~ catherine
  | That's okay... Don't worry. It's probably just a little data loss.
- I don't remember my name.
  ~ catherine
  | (:concerned)Oh, really? I'm sorry.
  ~ player
  | (:thinking)I don't remember much else, either.
  ~ catherine
  | I'm sure it's fine. It's probably just a little data loss.
- Is this really the time?
  ~ catherine
  | (:concerned)You're right - sorry.
  ~ player
  | (:thinking)Actually, now that you mention it... I don't remember my name.
  ~ catherine
  | (:concerned)Oh, really? I'm sorry.
  ~ player
  | (:thinking)I don't remember much else, either.
  ~ catherine
  | I'm sure it's fine. It's probably just a little data loss.
~ catherine
| Well, until it comes back to you, or you decide what you'd like to be called, I'm gonna call you (:excited)\"__Stranger__\"(yellow).
! eval (setf (nametag player) (@ player-name-1))
| (:excited)Pretty cool, huh?
| (:normal)Okay, we need to \"follow the pipeline further down\"(orange).
| (:excited)Let's go, Stranger!
  ")
  ;; only hurting player if greater than 20 HP, as at 15 HP the game goes into slow motion damage mode; so lowest health can go here is either 20 HP if no damage levied, or 16 HP if 5 damage done.
  ;; health decrement without stagger: ! eval (when (< 5 (health player)) (decf (health player) 5))
  ;; TODO when can rename player nametag: ! eval (setf (var 'player-nametag) \"Stranger\") - re-inflects the narrative tone. Does PC adopt this name, or not?
  ;; TODO catherine confused - I don't know. Everyone has a name. 
  ;; TODO catherine giggle - What's right with it?

  (:go-to (main-leak-2 :lead catherine)
   :title "Follow Catherine further below ground, staying close to the red pipeline"
   "~ catherine
| (:excited)Catch me if you can!
  ")
  (:interact (catherine :now T)
  "~ catherine
| (:concerned)Look - the same cracks we saw on the last pipe. This isn't right.
| (:normal)Jack, I think we've got trouble. Over.
~ jack
| What is it?
~ catherine
| We're in the \"Midwest Market\"(red) - just like before the pipe is cracked, but there's no sign of a cave-in. Over.
~ jack
| ...
| (:annoyed)It's sabotage. I knew it.
| (:normal)Alright, Cathy, you stay put. I'm coming down. Over.
~ catherine
| No! I'm alright. I can fix it. Over.
~ jack
| Okay, just be careful. I'll tell Fi what's going on.
| You'd better follow the pipe right down to the pump, just to be sure you got all the leaks.
| The walkie won't work down there - use the telephone by the pump when you're done.
| And keep your wits about you. Over and out.
~ catherine
| Alright, let me seal this one up.
| (:concerned)Wait... Who's there?
  ")
  (:eval
   :condition (not (find-panel 'fullscreen-prompt))
   (fullscreen-prompt '(light-attack heavy-attack) :title 'attack))
  (:complete (q1-fight1)
   :title "Defeat the wolf at the leak"
   "
~ catherine
| (:concerned)Look out!
  ")
  (:eval
   :condition (not (find-panel 'fullscreen-prompt))
   (setf (animation (unit 'main-leak-2)) 'normal)
   (move-to 'player 'catherine)
   (activate (unit 'q1-fight2)))
  (:wait 1)
  (:eval
   (fullscreen-prompt 'quickmenu))
  (:go-to (catherine)
   :title "Return to Catherine at the leak")
  (:interact (catherine :now T)
   "~ catherine
| Jeez, I'm glad you came along.
| I've done the weld - good as new.
| \"Let's get down to the pump room.\"(orange)
  ")
  (:go-to (leak-3-standoff :lead catherine)
   :title "Follow Catherine to the pump room, deeper underground"
  )
  (:interact (catherine :now T)   
  "~ catherine
| What the hell?!- Servos? Here?
~ player
- I think we found the saboteurs.
  ~ catherine
  | \"Do your thing!\"(orange)
- Robots with servomechanisms?
  ~ catherine
  | No time to explain! \"Do your thing!\"(orange)
- (Fight)
  ")
  (:complete (q1-fight2)
   :title "Defeat the servo robots"
   "~ catherine
| Smash 'em!
  ")  
  (:eval (move-to 'main-leak-3 'catherine))
  (:nearby (main-leak-3 catherine))
  (:interact (catherine :now T)
   "~ catherine
| (:disappointed)What have they done?...
| (:concerned)Oh man, we got here just in time. They were dismantling the turbine.
| (:normal)I need to fix this. The \"telephone's just over there - call Jack and tell him what happened\"(orange).
~ player
- Okay.
- Do I have to talk to that guy?
  ~ catherine
  | (:concerned)This is important. Please.
- Can I use my FFCS instead?
  ~ catherine
  | Your comms system? I don't doubt that would work, but it would definitely freak Jack out.
  | Use the telephone for now.
  ")
  (:go-to (q1-phone)
   :title "Use the telephone in the pump room to call Jack")
  (:interact (jack :now T)
  "~ jack
| Thank Christ. Good work, Cathy - the water's back on.
~ player
- Hi.
  ~ jack
  | (:shocked)... You?! Where's Cathy?
- It's not Catherine.
  ~ jack
  | (:shocked)... You?! Where's Cathy?
- It's Stranger.
  ~ jack
  | (:annoyed)Who's Stranger?
  | (:shocked)... This is the android, isn't it? Where's Cathy?!
~ player
| She's fixing the pump. It was sabotaged by servo robots.
~ jack
| (:annoyed)Those motherfuckers.
~ jack
| Look, \"tell Cathy to get her ass back here\"(orange) on the double.
| And you need to come too, android - \"Fi's\"(yellow) on the warpath.
~ player
| \"He hung up.\"(light-gray, italic)
  ")
  (:wait 2)
  (:eval
    (setf (animation (unit 'main-leak-3)) 'normal))
  (move-to 'player 'catherine)
  (:interact (catherine :now T)
   :title "Talk to Catherine in the pump room"
  "~ catherine
| I jury-rigged the pump. Should be okay for a while - though it'll need a more permanent fix later.
| What did Jack say?
~ player
- He wants us to go back - Fi's on the warpath.
- He said well done, but...
  ~ catherine
  | But what?
  ~ player
  | But you should go back ASAP, and I should be there - Fi's on the warpath.
- He wasn't happy to hear me.
  ~ catherine
  | (:concerned)I can believe it. (:normal)Did he say anything else?
  ~ player
  | That you should go back ASAP, and I should be there - Fi's on the warpath.
~ catherine
| (:concerned)Well that doesn't sound good.
| (:normal)Seems we'll have to wait a little longer for that welcome home we deserve.
| Why don't \"you lead the way\"(orange)? See if you managed to get your bearings.
~ player
- Sure thing.
  ~ catherine
  | (:excited)Great!
- I didn't get my bearings.
  ~ catherine
  | Oh... I'm sure you'll figure it out though. It's important that you do.
- Who's Fi?
  ~ catherine
  | She's our leader. She'll be glad to meet you, I'm sure of it.
~ catherine
| Let's \"get back to camp\"(orange), find out what's happening.
! eval (setf (location 'fi) (location 'shutter-2))
! setf (direction 'fi) -1
! eval (setf (location 'jack) (location 'shutter-3))
! setf (direction 'jack) -1
  ")
  (:eval
   :condition (not (find-panel 'fullscreen-prompt))
   (fullscreen-prompt 'open-map))
  ;; TODO catherine confused - What does that mean?...
  #|
  ! eval (setf (location 'catherine) 'catherine-group) ;
  ! eval (move-to 'catherine-group (unit 'catherine)) ;
  |#
  (:go-to (shutter-1 :follow catherine)
   :title "Return to camp with Catherine and find Jack and Fi"
   "~ catherine
| (:excited)Take us home, Stranger!
  ")
  (:interact (catherine :now T)
  "
! eval (stop-following 'catherine)
! eval (ensure-nearby 'shutter-1 'catherine)
! eval (setf (nametag (unit 'fi)) (@ fi-nametag))
~ catherine
| (:cheer)We're back! Did you miss us?
~ jack
| (:annoyed)Well I'll be damned.
~ catherine
| What's the matter? Didn't think I'd come home in one piece?
~ jack
| (:annoyed)Something like that.
~ fi
| You've done well, Catherine. An android will be a great asset to us.
| Assuming it can be trusted.
~ catherine
| (:concerned)I don't understand.
~ fi
| Is it not a coincidence that you discovered it at the same time our water supply was sabotaged? Likely by the Wraw.
~ catherine
| But we saw the servos - they were dismantling the pump! It wasn't her.
~ jack
| Maybe this thing can control them? Did you think of that?
~ catherine
| (:concerned)...
| (:concerned)Androids do have an FFCS- er, far-field comms system.
| I guess something like that could penetrate deeper underground than our radios.
| (:normal)But no, it's not that. She's been offline for decades, I'm sure of it.
| And since I brought her online she's been with me the whole time! She can't have done this.
~ jack
| But what do we really know about androids, Cathy? Fuck all, that's what.
~ catherine
| Well, ask her. Have you betrayed us, Stranger?
~ player
- No I have not.
  ~ catherine
  | There, see. I know her memories are all muddled, but that's one thing she is sure about.
  ~ fi
  | Alright. Let's hope it's telling the truth. (:annoyed)If not, then the Wraw know our location, and their hunting packs are already on their way.
- I don't think I have.
  ~ catherine
  | Her memories are all muddled from before I brought her online. She hasn't, trust me.
  ~ fi
  | Alright. Let's hope that's true. (:annoyed)If not, then the Wraw know our location, and their hunting packs are already on their way.
- I suppose I could have.
  ~ catherine
  | (:concerned)She doesn't know what she's saying - her memories are all screwed up till the point I brought her online. She doesn't even remember her name!
  ~ fi
  | Alright. It's hardly conclusive, but for now we'd better hope Catherine's right.
  | (:annoyed)If not, then the Wraw know our location, and their hunting packs are already on their way.
- Yes.
  ~ catherine
  | (:disappointed)...
  | (:excited)Yes, of course she has. She's a traitor.
  | (:concerned)Come on, guys!? I know I can be gullible, but do you really think I would have stuck with her if I thought that?
  | Anyway, her memories are all screwed up till the point I brought her online. She doesn't even remember her name!
  ~ fi
  | Alright. It's hardly conclusive, but for now we'd better hope Catherine's right.
  | (:annoyed)If not, then the Wraw know our location, and their hunting packs are already on their way.
~ jack
| (:annoyed)Jesus, Fi... you're just gonna take that at face value?
~ fi
| What choice do I have?
~ jack
| Examine the thing, find out for sure.
~ fi
| (:unsure)Catherine, don't androids have a black box? Could that show us if the... FFCS was it, was active lately?
~ catherine
| ... I guess we'd need to find some kind of interface port.
| (:concerned)Oh, and we'd need a working computer, which no one's seen since before I was born.
| (:disappointed)But even if we had all that, don't you think you should ask HER if taking her apart is okay?
~ fi
| You're right, Catherine.
| I'm sorry... Stranger, wasn't it?
~ jack
| (:annoyed)...
~ fi
| Would you permit Catherine to examine you, assuming we can find a way?
~ player
- I'd rather she didn't.
  ~ fi
  | It's your choice, of course.
  ~ jack
  | (:annoyed)Really? You're gonna let this thing call the shots?
  ~ fi
  | This \"thing\" is a person. And I expect you to treat her as such.
  | I trust Catherine's judgement. For now, Stranger is our guest.
  | Nevertheless, Jack - speak with \"Sahil\"(yellow) when he arrives, see what he knows about androids.
  | If Stranger is having memory problems, the least we can do is try to help her.
  ~ jack
  | (:annoyed)If you insist.
- Sure, why not.
  ~ fi
  | Good. Jack, speak with \"Sahil\"(yellow) when he arrives, see what he knows about androids.
  ~ jack
  | (:annoyed)If you insist.
- As long as I'm still online afterwards.
  ~ catherine
  | Don't worry, I won't let them switch you off.
  ~ fi
  | That's settled then. Jack, speak with \"Sahil\"(yellow) when he arrives, see what he knows about androids.
  ~ jack
  | (:annoyed)If you insist.
~ fi
| (:annoyed)But irrespective of all this, I am certain the Wraw are our attackers, one way or another.
| Which means they're close to discovering our location.
| (:normal)I must consider our next course of action.
~ catherine
| If there's nothing else, I'll see you both later.
| Hey Stranger, wait here - \"I want to talk\"(orange).
~ fi
| Sayonara Catherine, Stranger.
~ jack
| You take care, Cathy.
! eval (setf (walk 'fi) T)
! eval (setf (walk 'jack) T)
! eval (move-to 'fi-farm (unit 'fi))
! eval (move-to 'eng-jack (unit 'jack))
  ")
  ;; TODO set Catherine facing direction on move-to arrival once got code support; else consider restoring to below, once they don't glitch out and cause Catherine to run to the ruins:
  ;; ! eval (setf (location 'catherine) 'catherine-group)
  ;; ! eval (setf (direction (unit 'catherine)) -1)
  ;; sayonara = goodbye (Japanese)
  ;; TODO catherine pleading - But no, it's not that. She was offline for decades - there's no way she could have done that.
  ;; and others

  ;; REMARK The finding a computer idea has been abandoned, so this uncertainty about the android's motives will hang over the player for the rest of the game. Perhaps the android faction ending hints at this finally being resolved, since they could scan the android - but by that point, the android's friends trust her (even Jack?), so I don't think they'll even need that confirmation.


  (:interact (catherine)
   :title "Talk to Catherine at the camp"
   "~ catherine
| (:disappointed)Urgh, adults. I mean, technically I'm an adult, but not like those dinosaurs.
| (:normal)Oh! I almost forgot: It's our way to gift something to those that help us out.
| Since those two aren't likely to be feeling generous, I'll \"give you these spare parts\"(orange).
! eval (store 'item:parts 200)
| It's not much, but you can \"trade them\"(orange) for things you might want. Or you will be able to \"once Sahil gets here\"(orange).
| (:concerned)He's overdue, which is not like him at all. Maybe those servos scared him off.
| (:normal)Anyway, don't worry about Jack and Fi. They'll soon see what I see: (:excited)a __big__ __friendly__ __badass__ who can protect us!
| (:normal)Well, I've got work to do.
| Couldn't hurt to check in with Fi. I'm sure there's something you could help her with, to show her you can be trusted.
| Knowing Jack he'll have something for you too - (:concerned)if only a mouthful of abuse.
| (:normal)But right now you're a free agent. I doubt that will last very long around here, so make the most of it.
| (:excited)Take a \"look around and explore\"(orange)! (:normal)Though it's probably best not to go too far from the camp.
| Seeya later, Stranger!")
  (:eval
   :on-complete (q2-intro q3-intro)
   (move-to 'eng-cath (unit 'catherine))
   (fullscreen-prompt 'report-bug :input :keyboard)))
;; TODO Catherine contented - Anyway, don't worry about them.
