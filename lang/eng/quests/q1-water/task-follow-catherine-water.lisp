;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-task (kandria q1-water follow-catherine-water)
  :title "Follow Catherine"
  :condition all-complete
  :on-activate (leak1)
  :on-complete (task-return-home)

  ;; using inner monologue to depict and pass the time for action taking place
  (:interaction leak1
   :interactable main-leak-1
   :dialogue "
~ catherine
| Alright, here's a leak...
| That's strange, the pipe is cracked.
~ player
- Can you fix it?
  ~ catherine
  | I wouldn't be much of an engineer if I couldn't.
- What caused this?
  ~ catherine
  | Subsidence, probably. Though there's no sign of a landslide.
- Why is it strange?
  ~ catherine
  | Well, cracks are usually the result of subsidence. But there's no sign of a landslide.
~ catherine
| Oh well, here goes. I'm gonna weld it, so best not look at the arc - don't want to fry your cameras!
~ player
| //Catherine puts on her goggles and welds the crack with steady hands.//
- //Enable UV filters//
  | //I see the dull glow, and hear sparks crackle and spit.//
- //Don't enable filters//
  | //It's like staring into the sun. Into the centre of a catacylsm.//
  ! eval (when (< 5 (health player)) (hurt player 5))
  ! eval (setf (var 'weld-burn) T)
  | (:embarassed)//I think that damaged my cameras a little...//
~ catherine
| That should hold it.
~ catherine
| Jack, I've fixed the leak - the pipe was cracked. How's the water pressure? Over.
~ jack
| Weak as shit. There must be another leak. Over.
~ catherine
| Alright - we'll keep looking. Over and out.
| Come on... Er - you really need a name.
| You really don't remember it?
~ player
- Why do I need a name?
  ~ catherine
  | I don't know. Everyone has a name. It's you, it's personal. And it makes it easier to have a conversation.
- No.
- Is this really the time?
  ~ catherine
  | You're right - sorry.
~ catherine
| Well, until it comes back to you, or you decide what you'd like to be called, I'm gonna call you Stranger.
! eval (setf (nametag player) \"Stranger\")
| Pretty cool, huh?
| (:excited)Let's go, Stranger!
! eval (activate 'leak2)
! eval (lead 'player 'main-leak-2 (unit 'catherine))
")
  ;; health decrement without stagger: ! eval (when (< 5 (health player)) (decf (health player) 5))
  ;; TODO when can rename player nametag: ! eval (setf (var 'player-nametag) \"Stranger\") - re-inflects the narrative tone. Does PC adopt this name, or not?
  ;; TODO catherine confused - I don't know. Everyone has a name. 
  ;; TODO catherine giggle - What's right with it?

  #| ^ DIALOGUE REMOVED FOR TESTING
                                        ; ;
                                        ; ;
                                        ; ;
  |#

  (:interaction leak2
   :interactable main-leak-2
   :dialogue "
~ catherine
| (:concerned)Look - the same cracks as we saw on the last pipe. This isn't right.
| (:normal)Jack, I think we've got trouble. Over.
~ jack
| What is it?
~ catherine
| We're in the Midwest Market - just like before, the pipe is cracked. And no sign of a cave-in. Over.
~ jack
| ...
| (:annoyed)It's sabotage. I knew it.
| (:normal)Alright, Cathy, you stay put. I'm coming down. Over.
~ catherine
| No! I'm alright. I can fix it. Over.
~ jack
| Okay... just be careful. I'll tell Fi what's going on.
| Also the pressure is still screwed. You'd better follow the pipe right down to the pump, just to be sure you got all the leaks.
| The walkie won't work down there, but there's a telephone near the pump. Use that when you're done.
| And keep your wits about you. Over and out.
~ catherine
| Alright, let me seal this one up.
| (:concerned)Wait... Who's there?
! eval (walk-n-talk 'catherine-fighttalk1)
! eval (spawn 'q1-wolf-spawn 'wolf)
")

  #|
  ! eval (spawn 'q1-wolf-spawn 'wolf :count 2) ; ;
                                        ; ;
                                        ; ;
  |#

  ;; TODO: allow player to collect "wolf meat" as currency?
  (:interaction catherine-fighttalk1
   :interactable catherine
   :dialogue "
! eval (complete 'catherine-fighttalk1)
~ catherine
| (:shout)Look out!
| Keep it busy while I finish up here.
| --
! eval (activate 'leak2-done)
")

  ;; TODO: has catherine seen the stranger in action in the prologue? If so, her reaction here would be less emphatic
  ;; REMARK: ^ yes. The tutorial will include a brief fight section.
  (:interaction leak2-done
   :interactable main-leak-2
   :dialogue "
~ catherine
| I've done the weld - good as new.
| Let's get down to the pump room.
! eval (spawn 'main-leak-3 'zombie)
! eval (spawn 'main-leak-3 'zombie)
! eval (spawn 'main-leak-3 'zombie)
! eval (spawn 'main-leak-3 'zombie)
! eval (activate (unit 'rogues))
! eval (lead 'player 'leak-3-standoff (unit 'catherine))
")
  #|
  ! eval (spawn 'main-leak-3 'zombie :count 3) ; ;
                                        ; ;
  |#
  #| cut in case dialogue prompted during fight:
  | Are you okay?                       ; ;
  | Wow - you're a real badass!         ; ;
  |#

  ;; trigger volume
  (:interaction rogues
   :interactable catherine
   :dialogue "
~ catherine
| What the hell?!- Rogues? Here?
~ player
- I think we found the saboteurs.
  ~ catherine
  | Do your thing!
- You know these srakas?
  ~ catherine
  | No time to explain! Take them out!
- What's a rogue?
  ~ catherine
  | No time to explain! Take them out!
! eval (walk-n-talk 'catherine-fighttalk2)
")
  ;; sraka = asshole (Russian)
  ;; TODO catherine shocked - What the hell?!- Rogues? Here?
  ;; plus all sub choices
  ;; 
  #|
                                        ; ;
                                        ; ;
  |#

  (:interaction catherine-fighttalk2
   :interactable catherine
   :dialogue "
! eval (complete 'catherine-fighttalk2)
~ catherine
| (:shout)Smash 'em!
| ---
! eval (activate 'leak3-fight-done)
")

  ;; TODO: spawn spare parts for the player to collect (barter currency) - would need to integrate with the zombies' death scripts?
  ;; TODO: sometimes doesn't activate?
  (:interaction leak3-fight-done
   :interactable leak-3-standoff
   :dialogue "
~ catherine
| What have they done?
! eval (activate 'leak3)
! eval (lead 'player 'main-leak-3 (unit 'catherine))
")
  ;; TODO catherine shocked - What have they done?
  #|
                                        ; ;
                                        ; ;
  |#

  #| cut in case dialogue prompted during fight:
  | That was sooo cool!                 ; ;
  | I hate to see them go down like that, but there's no reasoning with them. ; ;
  | We could sure use their spare parts too - grab what you can. ; ;
  |#

  (:interaction leak3
   :interactable main-leak-3
   :dialogue "
~ catherine
| (:disappointed)Oh man, we got here just in time. They were gonna dismantle the turbine...
| Give me a minute.
| ...
| (:normal)There, got it.
| Now, where is that telephone?
! eval (activate 'phone)
! eval (lead 'player 'q1-phone (unit 'catherine))
")
  ;; TODO Catherine relieved - Oh man, we got here just in time.

  #|
                                        ; ;
                                        ; ;
                                        ; ;
  |#

  (:interaction phone
   :interactable q1-phone
   :dialogue "
~ catherine
| Jack, it's me.
~ jack
| Thank Christ. Good work, Cathy - the water's back on.
~ catherine
| (:disappointed)We found the saboteurs - rogue robots from God knows where.
~ jack
| (:annoyed)Those motherfuckers...
~ catherine
| Stranger dealt with them though.
~ jack
| (:annoyed)Did they?... Look, Cathy, get your ass back here on the double.
| And bring the android - Fi's on the warpath.
~ catherine
| (:concerned)What does that mean?...
| Jack?... He hung up.
| (:normal)Well, whatever it is it doesn't sound good.
| Seems we'll have to wait a little longer for that welcome home we deserve.
~ player
- Lead the way.
  ~ catherine
  | You got it, partner!
- Who's Fi?
  ~ catherine
  | She's our leader. You'll see for yourself soon enough.
  | She'll be glad to meet you, I'm sure of it.
  | I'm gonna head back to camp, find out what's going on. Take your time - I'll meet you there when you're ready. Then we can talk to Fi.
- Can I go now?
  ~ catherine
  | Go? Go where?
  ~ player
  - I want to explore.
    ~ catherine
    | Sure, of course. I mean, it's been a little mad since we got back, hasn't it?
    | Yeah, definitely - take some time, explore the caves, get to know the lay of the land.
    | Just don't be too long - Fi will want us both to debrief her.
    | I'm heading back now. Be careful - though I know you can handle yourself.
    | Seeya later!
  - Home.
    ~ catherine
    | Oh...
    | Maybe, in time, I'll be able to help you with that. I intend to learn all there is to know about androids. About you, I mean.
    | I'm gonna head back to camp now. But take your time - I'll meet you there when you're ready. Then we can talk to Fi.
    | Seeya in a little while.
  - Anywhere that's not here.
    ~ catherine
    | Um, sure. I get that - you want to look around. It's been a little mad since we got back, hasn't it?
    | Yeah, definitely - take some time, explore the caves, get to know the lay of the land.
    | Just don't be too long - Fi will want us both to debrief her.
    | I'm heading back now. Be careful - though I know you can handle yourself.
    | Seeya later!
! eval (setf (location 'fi) 'fi-group)
! eval (setf (location 'jack) 'jack-group)
! eval (move-to 'catherine-group (unit 'catherine))
"))
;; TODO catherine confused - What does that mean?...
#|
! eval (setf (location 'catherine) 'catherine-group)
! eval (move-to 'catherine-group (unit 'catherine))
|#
;; TODO: player could beat catherine back if they're quick, then destination convo don't make sense without Catherine there - only allow convo to play once catherine's back? Or once move-to takes her outside the current chunk, teleport her?
