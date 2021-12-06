;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q4-find-alex)
  :author "Tim White"
  :title "Find Alex"
  :description "Fi wants me to find Alex and bring them back to camp for debriefing, to see if they know anything about the Wraw's plans."
  :on-activate (find-alex)

  (find-alex
   :title "Travel down to the Cerebats township, but avoid the Semi Sisters en route"
   :description NIL
   :invariant T
   :condition (complete-p 'innis-stop)
   :on-activate (q4-reminder innis-stop)
   :on-complete (find-alex-semis)

   (:interaction q4-reminder
    :interactable fi
    :repeatable T
    :dialogue "
~ fi
| Go to the \"Cerebats township deep underground, find Alex and bring them back\"(orange) for debriefing.
| Watch out for the Semi Sisters on your way. They're not our enemies, but they are unpredictable.
")

   (:interaction innis-stop
    :interactable innis
    :dialogue "
! eval (setf (nametag (unit 'innis)) \"???\")
! eval (setf (nametag (unit 'islay)) \"???\")
! eval (setf (nametag (unit 'alex)) \"???\")
~ innis
| (:angry)<-STOP-> WHERE YOU ARE!!
| Did you think ya could just waltz right through here?
| (:sly)We've been watching you, android. You and your little excursions with Catherine.
| And now you've come to visit us. How thoughtful.
| (:normal)What //should// we do with you? I bet your \"Genera\"(red) core could run our entire operation.
| What do you think, sister?
~ islay
| (:unhappy)I think you should leave her alone.
~ innis
| (:angry)...
| (:normal)Come now, Islay - the pinnacle of human engineering is standing before you, and that's all you can say?
! eval (setf (nametag (unit 'islay)) (@ islay-nametag))
| (:sly)That wasn't a compliment by the way, android. (:normal)But let's not get off on the wrong foot now.
~ player
- (Keep quiet)
  ~ innis
  | (:sly)Why are you are here? I know lots about you, but I want to know more.
- My name's Stranger.
  ~ innis
  | This I know, android. (:sly)Tell me, why are you here?
- What do you want?
  ~ innis
  | (:sly)I'll ask the questions if you dinnae mind. Why are you here?
~ innis
| (:sly)What //does// Fi send her robot dog to do?
| To prove her loyalty, I think.
~ player
- My business is my business.
  ~ innis
  | If that's your prerogative.
  | But you'll be pleased to know that \"Alex is here\"(orange).
- I'm looking for someone called Alex, have you seen them?
  ~ innis
  | (:pleased)You see, sister. The direct approach once again yields results, and confirms my information.
  | (:normal)You'll be pleased to know that \"Alex is here\"(orange).
- Go fuck yourself.
  ~ islay
  | (:happy)...
  ~ innis
  | (:angry)...
  | I remember your kind! You think you're clever just 'cause you can mimic us.
  | You're a machine. And if I wished it I could have you pulled apart and scattered to the four corners of this desert.
  | (:normal)Now, let's try again.
  | You'll be pleased to know that the one you seek, \"Alex, is here\"(orange).
~ innis
| Indulge me, would you? I want to see how smart you are.
| See if you can \"find them\"(orange) for yourself.
! eval (deactivate 'q4-reminder)
"))

#|
dinnae = don't (Scottish)
|#

#|
TODO: IDEA: while find-alex-semis is active, enable NPCs in the Semis area to be questionined if they are Alex, as a variant on their world-building dialogue.
|#
  (find-alex-semis
   :title "Search Semi Sisters territory for any sign of Alex"
   :description NIL
   :invariant T
   :condition (complete-p 'alex-meet)
   :on-activate (islay-hint alex-meet)
   :on-complete (q5-run-errands)

   (:interaction islay-hint
    :interactable islay
    :repeatable T
    :dialogue "
~ islay
| (:unhappy)Hello, Stranger. I'm sorry about my sister.
| (:nervous)If you're looking for \"Alex, try the bar\"(orange). It's \"on the level above us\"(orange).
| Just don't tell Innis I told you.
! eval (setf (nametag (unit 'innis)) (@ innis-nametag))
")


   (:interaction alex-meet
    :interactable alex
    :dialogue "
~ alex
| (:unhappy)What you looking at? <-Hic->.
~ player
| \"//Their breath smells like seaweed mixed with diesel.//\"(light-gray)
~ player
- Alex?  
- I wasn't looking at you as it happens.
  ~ alex
  | (:unhappy)Goes away then.
  ~ player
  | Are you Alex?
- A drunk in a bar.
  ~ alex
  | (:angry)'Ow dare you.
  ~ player
  | Are you Alex?
~ alex
| (:unhappy)I ain't Ali.
~ player
| I said \"Alex\" not \"Ali\".
~ alex
| (:confused)<-Hic->. That's what I said.
~ player
| (:skeptical)Oh boy.
| (:normal)Are you Alex from the Noka? Do you know Fi?
~ alex
| (:confused)...
| (:normal)Yeah that's me. <-Hic->.
! eval (setf (nametag (unit 'alex)) (@ alex-nametag))
~ player
- My name is... Stranger.
  ~ alex
  | (:unhappy)<-Hic->. I know. You're the new hunter.
  | The android.
- I'm an android.
  ~ alex
  | (:unhappy)<-Hic->. I know. You're the new hunter.
- Fi sent me.
  ~ alex
  | (:unhappy)<-Hic->. I know. You're the new hunter.
  | The android.
~ player
| Correct.
~ alex
| (:unhappy)Lemme save you some trouble. I ain't going back.
~ player
- Why not?
  ~ alex
  | (:unhappy)You really gotta ask that?
  | ...
  | Alright, you asked for it: <-Hic->. You're the reason.
- It's important that you do.
  ~ alex
  | No it ain't. Far from it.
~ alex
| (:angry)I've 'eard about you, doing my job- <-Hic->. Innis even showed me the CCCTV.
! eval (setf (nametag (unit 'innis)) (@ innis-nametag))
| So why would Fi need little ol' me any more?
| So run along matey - <-hic-> - an' tell her to spin on that, why dontcha?
~ player
| (:thinking)Do you know about the Wraw's plan to attack?
~ alex
| They're always planning to attack. <-Hic->. Prolly just Fi getting her knickers in a twist.
| (:unhappy)<-Hic->. Speaking o' twists, can't a geezer get a refill 'round 'ere? __BARKEEP!__
~ player
| \"//Alex looks around, but doesn't notice the barkeep scowling from a dark corner. The barkeep meets my eye.//\"(light-gray)
~ player
- (Buy Alex another drink - 40)
  ? (<= 40 (item-count 'parts))
  | ! eval (retrieve 'parts 40)
  | ~ alex
  | | (:confused)Ugh, thansssks. <-Hic->.
  |? (> 40 (item-count 'parts))
  | ~ player
  | | (:embarassed)\"//I don't have enough scrap for that. Now the barkeep's scowling at me too.//\"(light-gray)
- (Buy Alex a soft drink - 20)
  ? (<= 20 (item-count 'parts))
  | ! eval (retrieve 'parts 20)
  | ~ alex
  | | (:confused)This ain't booze! What am I meant to do wiv that? <-Hic->. 
  |? (> 20 (item-count 'parts))
  | ~ player
  | | (:embarassed)\"//I don't have enough scrap for that. Now the barkeep's scowling at me too.//\"(light-gray)
- (Leave them be)
~ player
| \"//Alex looks me up and down, though seems to lose sight of me for a moment, before squinting and settling on me again. They seem surprised I'm still here.//\"(light-gray)
~ alex
| You're a stenacious bunch aren't ya, you androids. <-Hic->.
~ player
- Did you learn anything at all from the Cerebats?
  ~ alex
  | (:proud)I learned where all the tunnels go. <-Hic->. Mapped this whole area, an' the one below that.
- Where have you been all this time?
  ~ alex
  | (:confused)'Ere, mostly.
  | (:proud)Oh, an' I mapped this whole area, an' the one below that.
~ player
| Those maps could really help me.
~ alex
| (:angry)You mad? I give you these and I really would have nuffin'. <-Hic->.
| Now get lost.
| (:normal)Actually, before you go: Did you know it was me that found you? <-Hic->. I told Catherine about you.
| (:confused)I was just walking along, and there you were. <-Hic->. Exposed by an earthquake, I reckon.
| (:angry)Now I wish I'd kept my mouth shut and smashed you up instead.
! eval (deactivate 'islay-hint)
")))