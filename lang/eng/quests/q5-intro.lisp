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
- Islay sent me.
  ~ innis
  | (:sly)Good. Then I take it she filled you in about the jobs.
- I'm here to help with the engineers and CCTV.
  ~ innis
  | (:pleased)Now that's more like it.
- I found Alex.
  ~ innis
  | (:sly)Aye. It was hardly a challenge though really, was it?
  | I take it Islay filled you in about the jobs? Those are real challenges.
~ innis
| (:angry)They'd have been sorted ages ago if Alex wasn't propping up the bar.
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
? (not (active-p (unit 'engineers-wall)))
| ~ innis
| | Oh: she might have mentioned something about trapped railway engineers - don't worry about that.
| | The latest report shows they've been freed - by whom I don't know.
| ~ player
| - It was me.
|   ~ innis
|   | (:sly)Oh really? You just helped us outta the goodness o' your heart?
|   ~ player
|   - That's what I do.
|   - I was exploring, so figured why not.
|   - I was bored.
|   ~ innis
|   | Well if that's true - and I'll know soon enough - then thanks.
|   | But there's more to do.
| - Your guardian angel.
|   ~ innis
|   | If only that were true.
|   | (:sly)Wait- Are you trying to tell me something?
|   ~ player
|   - Yes.
|     ~ innis
|     | Well if you're saying what I think you're saying - and I'll know soon enough - then thanks.
|     | But there's more to do.
|   - No.
|     ~ innis
|     | (:angry)Well shut up then.
|   - I don't know.
|     | (:angry)Well shut up then.
| - Why was her intel out of date?
|   ~ innis
|   | We might have the technological edge 'round here, but out in the sticks news travels slowly.
|   | I only just got word o' this change.
! label questions
~ player
- [(not (active-p (unit 'engineers-wall))) Tell me about the trapped engineers.|]
  ~ innis
  | There were ten of them, working in the \"upper-west of our territory\"(orange).
  | We're slowly digging out parts of the old maglev metro system. (:pleased)We've got a basic electrified rails system going.
  | (:angry)But it's dangerous work. They didn't report in, and our hunters found the tunnel collapsed.
  | The hunters can't go any further. But you can.
  < questions
- Tell me about the downed CCTV.
  | We monitor the surrounding area, immediately above and below.
  | (:angry)Our cameras on the Cerebat border have gone down, at the \"bottom of our territory\"(orange).
  | It's probably just an electrical fault - unfortunately the way we daisy-chain them together means when one goes, they all go.
  | (:normal)They're spread out across the various access point along the border - well-suited to an android's speed, I'd wager.
  < questions
- I've got it.
~ innis
| \"Report back to me\"(orange) about either job when you have something to report.
? (not (active-p (unit 'engineers-wall)))
| ! eval (activate 'q5a-rescue-engineers)
! eval (activate 'q5b-repair-cctv)
")))