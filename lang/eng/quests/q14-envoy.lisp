;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria q14-envoy)
  :author "Tim White"
  :title "Return to the Surface"
  :description "Islay hasn't detonated the bombs and wants me to return to camp immediately. Something's wrong."
  (:go-to (wraw-leader)
   :title "Return to the camp")
  (:interact (zelah :now T)
  "
~ zelah
| Ah, the guest of honour. We've been waitin' for ya.
~ player
- Who are you?
  ~ zelah
  | (:jovial)I'm your worst nightmare, love.
  | But ya can call me Zelah.
- Let me guess: Zelah.
  ~ zelah
  | Got it in one.
- So you lead the Wraw?
  ~ zelah
  | I do. And everyone else 'round here.
  | Ya can call me Zelah.
! eval (setf (nametag (unit 'zelah)) (@ zelah-nametag))
~ fi
| (:annoyed)What do you want?
~ zelah
| I'm here for the android. \"My android\"(orange).
~ jack
| (:shocked)I knew it.
~ zelah
| (:jovial)It's my property. I've been \"usin' it to monitor you all, and plan this attack\"(orange).
~ catherine
| (:concerned)That can't be true...
~ zelah
| Now I \"want it back\"(orange).
~ fi
| (:annoyed)Touch her and you're dead.
~ zelah
| (:jovial)I won't be touchin' no one. My army will though.
| (:normal)Come, android. The masquerade is over. You're a traitor to these people, remember? It's \"time to come home\"(orange).
| \"If you do, I'll even spare the lives of these so-called friends.\"(orange)
~ fi
| (:annoyed)I see only one traitor here.
~ alex
| (:angry)You betrayed me first.
| An' maybe I wouldn't o' done it, if you hadn't sent this thing after me.
~ zelah
| You betrayed your people, Fi, when ya took this android in.
| (:jovial)And now I understand you're quite fond of it.
~ fi
| (:annoyed)She's not going anywhere.
~ jack
| (:shocked)Fi...
~ innis
| (:angry)We dinnae need the android. I kent this alliance was a mistake.
~ islay
| (:unhappy)And having her fight for them, or not at all, would be better?
~ catherine
| (:concerned)Don't go, {(nametag player)}.
~ zelah
| (:jovial)Oh, it has a name. How quaint.
~ player
- I'm staying here.
  ~ zelah
  | (:jovial)I was hopin' ya'd say that.
- Maybe I should go. He could be telling the truth.
  ~ catherine
  | (:concerned)...
  ~ fi
  | (:annoyed)He's not.
- What if I kill you right now?
  ~ zelah
  | (:jovial)This is an envoy. Kill me and you'll sign everyone's death warrant.
  | (:normal)And prove you're a traitor.
~ fi
| It doesn't matter what he says, {(nametag player)}. You've shown us who you really are.
~ zelah
| (:jovial)It's ya last chance... //{(nametag player)}//. Come with me, or ya friends'll die.
~ player
- Nice try.
- Fuck you.
- You'll be dead soon.
~ zelah
| Alright. We'll see ya on the battlefield.
")
  (:eval
    :on-complete (q15-engineering)
    (move-to (unit 'leader-rally) 'zelah)
    (move-to (unit 'alex-rally) 'alex)
    (ensure-nearby 'soldier-rally 'soldier-1 'soldier-2 'soldier-3)))
;; Zelah motivation: greed, resource/people acquisition