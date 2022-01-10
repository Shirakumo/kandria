;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q11-recruit-semis)
  :author "Tim White"
  :title "Recruit the Semis"
  :description "Fi wants me to speak with the Semi Sisters, and convince them to join us against the Wraw."
  :on-activate (task-1)

  (task-1
   :title "Talk to Innis"
   :invariant T
   :condition all-complete
   :on-activate (interact-reminder interact-1)

   ;; Fi could be running to Sahil's main location when this triggers
   ;; TODO Conditional based on whether she's en route to Sahil, or is nearby Sahil's now empty location? If the latter, leave her there for now, as would look too comical for her to run back.
   (:interaction interact-reminder
    :interactable fi
    :repeatable T
    :dialogue "
~ fi
| \"Go and see the Semi Sisters, and convince them to stand with us.\"(orange)
| (:unsure)As for me, I'm hoping Sahil is still here somewhere.
")

   (:interaction interact-1
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
| (:angry)You speak out of turn, Islay. Remember who's in charge.
| (:normal)And anyway, this time I dinnae ken why you're here, {#@player-nametag}.
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
  | (:pleased)The Noka? Help us? Don't make me laugh.
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
| (:angry)... It's not your call, Islay.
~ islay
| (:unhappy)Well why don't you ask the people? They see our cameras shutting down one by one, and our guns sat in storage.
| Just what exactly is your plan, sister?
~ innis
| (:angry)Are you saying you could do better?
~ islay
| (:unhappy)I'm saying we need help. We need the Noka - and we need {#@player-nametag}.
~ innis
| ...
| (:thinking)... Alright. Say we ally with the Noka. Then what?
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
| We take what we can carry and leave for the surface.
| Everything we leave behind is something the Wraw could use against us.
~ innis
| And what about the bomb?
~ player
- Bomb?
- Now you're talking.
- We blow up the Wraw!
~ islay
| (:expectant)I've improvised an explosive, which could slow their advance.
| We can still use it, but we're missing a few components to build it.
~ innis
| Send the android while we evacuate.
~ islay
| (:nervous)Aye, that might work. You'll need to go behind enemy lines.
| In normal times we'd get what we need from the Cerebat markets. But that's obviously not an option any more.
| If you can avoid their patrols you might be able to scavenge what we need.
| The only other option is in Wraw territory itself - they hoard this kind of stuff.
| (:normal)We need \"wire rolls\"(orange) to make trip wires, \"blasting caps\"(orange) for the detonator, and \"charge packs\"(orange) for the explosive.
| I think \"10 of each\"(orange) should be enough - always prudent to have a few spares. Except \"charge packs: get 20 of those\"(orange), so we have a big enough explosive yield.
| You got it? This is important.
~ player
- Got it.
  ~ islay
  | Good.
- One more time.
  ~ islay
  | Basically we need: \"10 rolls of wire\"(orange), \"10 blasting caps\"(orange), \"20 charge packs\"(orange).
~ islay
| (:nervous)Please hurry.
~ player
| I'll update Fi, then be on my way.
~ innis
| (:sly)That's right, you be a good dog.
~ islay
| (:unhappy)Innis!
| (:nervous)You can't tell Fi - whatever the Wraw are doing to mess with our systems, it affects your FFCS too.
| (:normal)I'll explain everything to her once we reach \"the surface. Meet us there as soon as you have the components.\"(orange)
| Good luck, {#@player-nametag}.
! eval (deactivate 'interact-reminder)
! eval (activate 'q11a-bomb-recipe)
! eval (activate (unit 'wraw-border-1))
! eval (activate (unit 'wraw-border-2))
")))