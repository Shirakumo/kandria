;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

;; Semi Sisters robotics engineer, female, strong empathy for machines, talky scientist
(quest:define-quest (kandria sq4-intro)
  :author "Tim White"
  :visible NIL
  :title NIL
  :on-activate (intro)

  (intro
   :title NIL
   :invariant (not (complete-p 'q10-wraw))
   :condition NIL
   :on-activate T

;; "more to those Servos than meets the eye", "And I don't mean they turn into cars and helicopters" - referring to a popular old-world toy line ;)
;; I'm not normally one for pop culture references, but hey the game has robots, and I did work on transformers once so I couldn't resist this
   (:interaction intro-chat
    :interactable semi-roboticist
    :repeatable T
    :dialogue "
~ semi-roboticist
| Hey, you're the android!
| You want to help a roboticist out? It's important work: \"investigating Servo robots for sapience. And even sentience\"(orange).
! eval (setf (nametag (unit 'semi-roboticist)) (@ semi-roboticist-nametag))
~ player
- You've got my attention.
  ~ semi-roboticist
  | Good. A little background to my research:
- I thought they were automatons.
  ~ semi-roboticist
  | Ex-automatons. But yeah, you're right, for the most part.
  | However, there's more to those Servos than meets the eye. And I don't mean they turn into cars and helicopters.
  ~ player
  - Tell me more.
  - Maybe later.
    < leave
- Maybe later.
  < leave
~ semi-roboticist
| Before the Calamity, Servos were just that - service robots.
| By all accounts you'd find them doing everything from vacuuming your apartment, to waiting tables in your favourite restaurant.
| I think androids did some of those jobs too, right? In fact, some think Servos are what's left of androids.
| They're not though, despite the superficial similarities.
| But I digress: What I'm talking about is personality, emotion, feelings. Higher intelligence than we give Servos credit for.
| I've seen it myself, and so have several of my colleagues. But I need more data.
| I'm liable to get my head lopped off if I get too close - and who can blame them for the way we've treated them.
| But you can get close. You can \"study them\"(orange). At least in the only language they understand: \"violence\"(orange).
! label questions
~ player
- You want me to study them by killing them?
  ~ semi-roboticist
  | If you don't kill them, they'll kill you. Besides, it's the only way to generate the data I need.
  < questions
- I've fought Servos already, won't that help?
  ~ semi-roboticist
  | Not really. I'm studying a specific group at a specific time - I need to compare their results, see how they've changed.
  < questions
- I've destroyed a lot of them...
  ~ semi-roboticist
  | I think \"killed\" is the word you're looking for.
  | But hey, don't sweat it. I'm sure it was in self-defence, right?
  < questions
- Can't you study them remotely?
  ~ semi-roboticist
  | Sometimes, although we don't have cameras in that area. There's also the small matter of... bait.
  < questions
- Where are the targets?
~ semi-roboticist
| The \"group I'm studying\"(orange) right now are in the \"far east of our territory\"(orange). It's kinda hard to reach, but I think you'll be fine.
| I can \"compensate you for your work\"(orange), of course: \"400 scrap parts\"(orange). Islay generously funds this kind of research.
| \"I'll be waiting for you.\"(orange)
| Don't get killed.
! eval (activate 'sq4-analyse-robots 'sq4-boss)
! eval (complete task)
! eval (reset* interaction)
# leave
~ semi-roboticist
| Suit yourself. But you're missing out - and I'm not just talking about scrap parts.
| You \"know where to find me if you change your mind\"(orange).
")))