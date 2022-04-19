;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q11-recruit-semis)
  :author "Tim White"
  :title "Recruit the Semis"
  :description "Fi wants me to speak with the Semi Sisters, and convince them to join us against the Wraw."
  :on-activate (task-reminder task-destination)

  (task-reminder
   :title ""
   :invariant T
   :condition all-complete
   :visible NIL
   :on-activate T

   ;; TODO if we don't get Fi climb anims etc, she'll have to stay on the surface - which might be better anyway?
   ;; Fi could be running to Sahil's main location when this triggers
   ;; TODO Conditional based on whether she's en route to Sahil, or is nearby Sahil's now empty location? If the latter, leave her there for now, as would look too comical for her to run back.
   (:interaction interact-reminder
    :interactable fi
    :repeatable T
    :dialogue "
~ fi
| \"Go and see the Semi Sisters, and convince them to stand with us.\"(orange)
| (:unsure)As for me, I'm hoping Sahil is still around here somewhere.
"))

  (task-destination
   :title "Talk to Innis in Semi Sisters territory"
   :invariant T
   :condition all-complete
   :on-activate T

   (:interaction interact-innis
    :interactable innis
    :dialogue "
~ innis
| (:angry)Catherine still isn't here. What's the hold up?
~ player
- I thought you'd have bigger things on your plate.
  ~ innis
  | You mean the Wraw? It's in hand.
  | Now run along - I've nothing more to say to you.
- She isn't coming.
  ~ innis
  | (:angry)Then I hope the Noka will enjoy drinking sand instead of water.
- We need to talk.
  ~ innis
  | (:angry)I've nothing more to say to you.
~ islay
| (:unhappy)Sister! She isn't our enemy. The Noka are not our enemy.
~ innis
| (:angry)You speak outta turn, Islay. Remember who's in charge.
| (:normal)And anyway, this time I dinnae ken why you're here, {(nametag player)}.
~ player
- I need your help.
  ~ innis
  | (:sly)What? An all-powerful android needs our help?
  | I don't think so. More like Fi needs our help.
- We need your help.
  ~ innis
  | (:sly)More like Fi needs our help, I bet.
  | You don't need our help - you're an android.
- We can help you.
  ~ innis
  | The Noka? Help us? Don't make me laugh.
~ innis
| (:sly)... Don't tell me you care for the Noka.
| I never understood why they gave androids emotions. Nothing but a distraction.
~ islay
| (:unhappy)Listen to her Innis, for Christ's sake!
~ innis
| ...
~ islay
| (:unhappy)The Wraw are at our doorstep. Somehow they're running interference on our systems.
| We're blind, and it's getting darker!
~ innis
| (:angry)... It's no' your call, Islay.
~ islay
| (:unhappy)Well why don't you ask the people? They see our cameras shutting down one by one, and our guns sat in storage.
| Just what exactly is your plan, sister?
~ innis
| (:angry)Are you saying you could do better?
~ islay
| (:unhappy)I'm saying we need help. We need the Noka - and we need {(nametag player)}.
~ innis
| ...
| ... Alright. Say we ally with the Noka. Then what?
~ islay
| We pool our resources - our weapons and people.
| We don't know the Wraw's exact numbers and capabilities, but I can hazard a guess from the hunters we sent - at least those that returned.
~ player
| I've seen their mechs and supplies too - it's a lot.
~ islay
| Right. It is. But I think we stand a fighting chance if we work together.
| ... And we abandon our home.
~ innis
| (:angry)No. Never.
~ islay
| It's not forever. But the Wraw are already here, and we can't fight them alone.
| We take what we can carry and leave for the surface. Seal the metro tunnels behind us.
| That won't stop them because they have drilling machinery, but it might slow them down.
| Everything we leave behind is something the Wraw could use against us.
~ innis
| And what about the bomb?
~ player
- Bomb?
- Now you're talking.
- We blow up the Wraw!
~ islay
| I've improvised an explosive that could stop their advance. Collapse the tunnels completely.
| We can still use it, but we're missing components to complete it.
~ innis
| Send the android while we evacuate.
~ islay
| (:nervous)Aye, that might work. You'll need to go behind enemy lines.
| In normal times we'd get what we need from the Cerebat markets. But that's obviously not an option any more.
| But \"the Wraw hoard this kind of stuff\"(orange) - they should have plenty lying around.
| (:normal)We need \"blasting caps\"(orange) for the detonators, and \"charge packs\"(orange) for the explosive.
| I think \"10 of each\"(orange) should be enough - always prudent to have a few spares.
| Actually, make it \"20 charge packs\"(orange), just to be sure we have a big enough explosive yield.
| And you'll get paid for your efforts: I'm a trader after all.
! eval (setf (var 'bomb-fee) 25)
~ player
- Thank you.
  ~ islay
  | It's alright - we value your work. I can give you 25 parts per item.
  | But don't thank me yet - this will be dangerous.
- There's no need.
  ~ islay
  | No, I insist. We value your work, and this will be dangerous.
  | I can give you 25 parts per item.
  ~ innis
  | ...
- How much?
  ~ innis
  | (:angry)...
  ~ islay
  | I can give you 25 parts per item.
  ~ player
  - That works.
    ~ islay
    | Okay.
  - Make it 50.
    ~ innis
    | (:angry)Fuck that. And what're ya gonna spend it on when the Wraw have been through here?
    ~ islay
    | If we stop them, life might return to normal.
    | But we can't afford 50 - we need those parts. How about 35? We do value your work, and this will be dangerous.
    ~ player
    - Deal.
      ~ islay
      | Great, 35 it is.
      ! eval (setf (var 'bomb-fee) 35)
      ~ innis
      | (:angry)...
    - Okay I'll be fine with 25.
      ~ innis
      | (:angry)...
      ~ islay
      | Alright then, 25 it is.
    - I've changed my mind: I'll take less than 25.
      ~ islay
      | No, I insist. This won't be easy, and 25 is fair.
      ~ innis
      | (:angry)...
  - I could take a little less, but not much.
    ~ islay
    | No, I insist. We value your work, and this will be dangerous. I think 25 is fair.
    ~ innis
    | ...
~ islay
| (:nervous)But please hurry.
| And remember: we're closing the metro. \"The trains and stations won't be operational.\"(orange)
~ player
| I'll update Fi, then be on my way.
~ innis
| (:sly)That's right, you be a good dog.
~ islay
| (:unhappy)Innis!
| (:nervous)You can't tell Fi - whatever the Wraw are doing to mess with our systems, it affects your FFCS too.
~ player
| \"Checking FFCS...\"(light-gray, italic)
| \"She's right. Shit.\"(light-gray, italic)
~ islay
| I'll explain everything to Fi once we reach the surface. \"Meet us up there once you have the components.\"(orange)
| You got it? This is important.
~ player
- One more time.
  ~ islay
  | Basically we need \"10 blasting caps\"(orange) and \"20 charge packs\"(orange).
  | You should find them in \"Wraw territory\"(orange). Then \"meet us on the surface\"(orange).
- Got it.
  ~ islay
  | Okay.
| Good luck, {(nametag player)}.
! eval (deactivate 'task-reminder)
! eval (activate 'q11a-bomb-recipe)
! eval (activate 'q12-help-alex)
! eval (complete 'trader-semi-chat)
! eval (activate (unit 'wraw-border-1))
! eval (activate (unit 'wraw-border-2))
! eval (activate (unit 'bomb-cap-1))
! eval (activate (unit 'bomb-cap-2))
! eval (activate (unit 'bomb-cap-3))
! eval (activate (unit 'bomb-cap-4))
! eval (activate (unit 'bomb-cap-5))
! eval (activate (unit 'bomb-cap-6))
! eval (activate (unit 'bomb-charge-1))
! eval (activate (unit 'bomb-charge-2))
! eval (activate (unit 'bomb-charge-3))
! eval (activate (unit 'bomb-charge-4))
! eval (activate (unit 'bomb-charge-5))
")))