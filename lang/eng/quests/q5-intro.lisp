;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q5-intro)
  :author "Tim White"
  :title "Talk to Innis"
  :description "Islay said she can give me more information about the trapped engineers and downed CCTV."
  :on-activate (q5a-task-overview)

 (q5a-task-overview
   :title "Speak with Innis in the Semi Sisters housing complex"
   :condition all-complete
   :on-activate T
   (:interaction q5a-overview
    :title "Hello again."
    :interactable innis
    :dialogue "
~ innis
| (:angry)What is it, android?
~ player
- I found Alex.
  ~ innis
  | (:sly)Aye. It was hardly a challenge though really, was it?
  | I take it Islay filled you in about the jobs? Those are challenges.
- Islay sent me.
  ~ innis
  | (:sly)Good. Then I take it she filled you in about the jobs.
~ innis
| (:angry)They'd be done already if Alex wasn't propping up the bar.
| (:normal)Don't get me wrong, I like a drink as much as the next lass. But you Noka really can't hold ya booze.
| I hope you're a tad more reliable.
~ player
- I am.
  ~ innis
  | (:sly)We'll see.
- I can't get inebriated.
  ~ innis
  | Your programming prevents you from drinking alcohol, or you just physically can't get drunk?
  ~ player
  - The latter.
    ~ innis
    | Makes sense. Though you haven't tried what passes for beer these days.
    | It would rot your systems from the inside, I guarantee it.
  - Nothing prevents me, I just don't drink.
    ~ innis
    | Each to their own.
  ~ innis
  | I suppose there was never a case for androids getting pissed.
  | (:sly)War zones, ghettos, hospitals - even sweeping the streets. Not the kind of places you want inefficiency.
- It's not Alex's fault.
  ~ innis
  | Then whose fault is it?
  | Life's harder than it used to be. It gets harder every year.
  | People don't live in happy little bubbles anymore, where survival's an afterthought.
  | There's no empathy because everyone's too busy trying not to die themselves.
  | It's simple natural selection. You'd do okay if you could reproduce.
  | And if you weren't the world's most powerful walking battery.
~ innis
| So how much did my esteemed sister say? You know what needs doing?
! label questions
~ player
- I've got it.
  < end
- Tell me about the trapped engineers.
  ~ innis
  | There were ten of them, working in the \"upper-west of our territory\"(orange).
  | We're slowly digging out parts of the old maglev metro system. (:pleased)We've got a basic electrified rails system going.
  | (:angry)But it's dangerous work. They didn't report in, and our hunters found the tunnel collapsed.
  | They can't go any further. But you can.
  < questions
- Tell me about the downed CCTV.
  | We monitor the surrounding area, immediately above and below.
  | (:angry)Our cameras on the Cerebat border have gone down, at the \"bottom of our territory\"(orange).
  | It's probably just an electrical fault - unfortunately the way we daisy-chain them together means when one goes, they all go.
  | (:normal)They're quite spread out across the various access point along the border - well-suited to an android's speed, I'd wager.
  < questions

# end
~ innis
| \"Report back to me\"(orange) about either job when you know what's happening.
! eval (activate 'q5a-rescue-engineers)
! eval (activate (unit 'semi-engineers))
! eval (activate 'q5b-repair-cctv)
")))