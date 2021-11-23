;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria q5-intro)
  :author "Tim White"
  :title "Talk to Innis"
  :description "Islay said she can give me more information about the trapped engineers and downed CCTV."
  (:interact (innis)
   :title "Speak with Innis in the Semi Sisters housing complex"
 "
~ innis
| (:angry)What is it, android?
~ player
- Islay sent me.
  ~ innis
  | (:sly)Good. Then I'll assume she filled you in about the jobs.
- I'm here to help with the engineers and CCTV.
  ~ innis
  | (:pleased)Now that's more like it.
- I found Alex.
  ~ innis
  | (:sly)Aye. It was hardly a challenge though really, was it?
  | I take it Islay filled you in about the jobs? Those are real challenges.
~ innis
| (:angry)They'd have been sorted ages ago if Alex wasn't propping up the bar.
| (:normal)Don't get me wrong, I like a drink as much as the next lass. But you Noka really canna hold ya booze.
| I hope you're a tad more reliable.
~ player
- I am.
  ~ innis
  | (:sly)We'll see.
- I can't get inebriated.
  ~ innis
  | Your programming prevents you from drinking alcohol, or you just physically canna get drunk?
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
  | Look, life's harder than it used to be. People don't live in happy little bubbles any more, where survival's an afterthought.
  | There's no empathy 'cause everyone's too busy trying not to die.
~ innis
| So how much did my esteemed sister say? You know what needs doing?
? (not (active-p (unit 'blocker-engineers)))
| ~ innis
| | Oh: about the trapped engineers - don't worry about them.
| | The last report shows they've been freed - by whom I don't know.
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
| - Why was Islay's intel out of date?
|   ~ innis
|   | We might have the technological edge 'round here, but out in the sticks news travels slowly.
|   | I only just got word o' this change myself.
| ~ innis
| | The good news for you is that it means our engineering works are back on schedule.
| | You see, my sister, in her infinite wisdom, thought it might be a nice gesture if we... (:awkward)//if I// officially grant you access to the metro.
| | ... In the interests of good relations, between the Semi Sisters and yourself. (:normal)\"It will certainly speed up your errands.\"(orange)
| ? (var 'metro-used)
| | | (:sly)I know you've been using it already, and that's alright. But now it's official. I'll send out word, so you won't be... apprehended.
| | | (:normal)The stations run throughout our territory and beyond. Though not all are operational while we expand the network.
| |?
| | | (:normal)You'll find the stations run throughout our territory and beyond. Though not all are operational while we expand the network.
| | | \"Simply open the blast doors and call a train.\"(orange)
! label questions
~ player
- [(active-p (unit 'blocker-engineers)) Tell me about the trapped engineers.|]
  ~ innis
  | There were ten of them, working in the \"upper-west of our territory\"(orange).
  | We're slowly digging out the old maglev metro system. (:pleased)We've got a basic electrified railway going.
  | (:angry)But it's dangerous work. They didn't report in, and our hunters found the tunnel collapsed.
  | The hunters canna go any further. But you can.
  < questions
- [(not (active-p (unit 'blocker-engineers))) So the engineers were working on the metro?|]
  ~ innis
  | Correct. We're slowly digging out the old maglev system. (:pleased)We've got a basic electrified railway going.
  | (:angry)But it's dangerous work.
  < questions
- Tell me about the downed CCTV.
  ~ innis
  | We monitor the surrounding area, immediately above and below.
  | (:angry)Our cameras on the Cerebat border have gone down, at the \"bottom of our territory\"(orange).
  | It's probably just an electrical fault - unfortunately the way we daisy-chain them together means when one goes, they all go.
  | (:normal)They're spread out across the access points along our border - well-suited to an android's agility, I'd wager.
  < questions
- I've got it.
~ innis
| \"Report back\"(orange) when you have news.
? (active-p (unit 'blocker-engineers))
| ! eval (activate 'q5a-rescue-engineers)
! eval (activate 'q5b-repair-cctv)
"))
;; TODO add fast travel tutorial pop-up if not already encountered the pop-up via a station