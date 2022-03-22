;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria q5-intro)
  :author "Tim White"
  :title "Talk to Innis"
  :description "Islay said she can give me more information about the trapped engineers and down CCTV cameras."
  (:interact (innis)
   :title "Speak with Innis in the Semi Sisters control room"
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
  | (:sly)Aye. It was hardly a challenge though, was it?
  | I take it Islay filled you in about the jobs? Those are real challenges.
~ innis
| (:angry)They'd have been sorted ages ago if Alex wasn't propping up the bar.
| (:normal)Dinnae get me wrong, I like a drink as much as the next lass. But you Noka really canna hold ya booze.
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
  | Look, life's harder than it used to be. People dinnae live in happy wee bubbles any more.
  | There's no empathy 'cause everyone's too busy trying not to die.
~ innis
| So how much did my esteemed sister say? You ken what needs doing?
? (not (active-p (unit 'blocker-engineers)))
| ~ innis
| | Oh: about the trapped engineers - dinnae worry about them.
| | The last report shows they've been freed - by whom I dinnae ken.
| ~ player
| - It was me.
|   ~ innis
|   | (:sly)Oh really? You just helped us outta the goodness of your heart?
|   ~ player
|   - What's wrong with that?
|   - That's what I do.
|   - I was exploring, so figured why not.
|   ~ innis
|   | Well if that's true - and I'll ken soon enough - then thanks.
|   | But there's more to do.
| - Your guardian angel.
|   ~ innis
|   | If only that were true.
|   | (:sly)Wait - are you trying to tell me something?
|   ~ player
|   - Yes.
|     ~ innis
|     | Well if you're saying what I think you're saying - and I'll ken soon enough - then thanks.
|     | But there's more to do.
|   - No.
|     ~ innis
|     | (:angry)Well shut up then.
|   - I don't know.
|     ~ innis
|     | (:angry)Well shut up then.
| - Why was Islay's intel out of date?
|   ~ innis
|   | We might have the technological edge 'round here, but out in the sticks news travels slowly.
|   | I only just got word of this change myself.
| ~ innis
| | The good news for you is that it means our engineering works are back on schedule.
| | You see, my sister, in her infinite wisdom, thought it might be a nice gesture if we-... //if I// officially grant you \"access to the metro\"(orange).
| | ... In the interests of good relations, between the Semi Sisters and yourself. (:normal)It'll certainly \"speed up your errands\"(orange).
| ? (or (unlocked-p (unit 'station-surface)) (unlocked-p (unit 'station-semi-sisters)) (unlocked-p (unit 'station-cerebats)) (unlocked-p (unit 'station-wraw)))
| | | (:sly)I ken you've seen the metro already, and that's alright. But now it's official. I'll send out word so you won't be... apprehended.
| | | (:normal)\"The stations run throughout our territory and beyond\"(orange). Though \"not all are operational\"(orange) while we expand the network.
| |?
| | | (:normal)You'll find \"the stations run throughout our territory and beyond\"(orange). Though \"no' all are operational\"(orange) while we expand the network.
| | | \"Just choose your destination from the route map and board the train.\"(orange)
! label questions
~ player
- [(active-p (unit 'blocker-engineers)) Tell me about the trapped engineers.|]
  ~ innis
  | There were ten of them, working in the \"high west of our territory\"(orange).
  | We're slowly digging out the old maglev metro system. (:pleased)We've got a basic electrified railway going.
  | (:angry)But it's dangerous work. They didnae report in, and our hunters found the tunnel collapsed.
  | The hunters canna go any further. But you can.
  < questions
- [(not (active-p (unit 'blocker-engineers))) So the engineers were working on the metro?|]
  ~ innis
  | Correct. We're slowly digging out the old maglev system. (:pleased)We've got a basic electrified railway going.
  | (:angry)But it's dangerous work.
  < questions
- Tell me about the down CCTV cameras.
  ~ innis
  | We monitor the surrounding areas, immediately above and below.
  | (:angry)Basically \"4 of our cameras\"(orange) on the Cerebat border have gone down, in the \"low eastern region\"(orange).
  | (:normal)It's probably just an electrical fault. Unfortunately the way we daisy-chain them together, when one goes they all go.
  | I want you to check them out.
  < questions
- I've got it.
~ innis
| \"Report back\"(orange) when you have news.
! eval (activate 'q5b-investigate-cctv)
! eval (activate (unit 'cctv-4-trigger))
? (active-p (unit 'blocker-engineers))
| ! eval (activate 'q5a-rescue-engineers)
"))
;; ken = know (Scottish)
;; didnae = didn't (Scottish)
;; dinnae = don't (Scottish)
;; canna = cannot (Scottish)
;; TODO add fast travel tutorial pop-up if not already encountered the pop-up via a station