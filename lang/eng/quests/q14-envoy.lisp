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
| Ah, ' guest of honour. We've bin waitin' for ya.
~ player
- Who are you?
  ~ zelah
  | (:jovial)A'm your worst nightmare, love.
  | But ya can call mi Zelah.
- Let me guess: Zelah.
  ~ zelah
  | Got it in one.
- So you lead the Wraw?
  ~ zelah
  | A do. An' everyone else 'round 'ere.
  | Ya can call mi Zelah.
! eval (setf (nametag (unit 'zelah)) \"Zelah\")
~ fi
| (:annoyed)What do you want?
~ zelah
| You 'ave a traitor in ya midst. A'm 'ere for ' android.
~ fi
| (:annoyed)I see only one traitor here.
~ alex
| (:angry)You betrayed me first.
| An' maybe I wouldn't o' done it, if you hadn't sent this thing after me.
~ fi
| (:annoyed)...
~ zelah
| Ya betrayed us all Fi, when ya took this android in.
| Androids are why we're in this mess o' a world in ' first place.
| They wa wiped out, but clearly not all.
| A'm 'ere t' finish ' job.
~ fi
| (:annoyed)Touch her and you're dead.
~ zelah
| A won't be touchin' no one. Ma army will though.
| There'll be touchin' all o' ya by ' time this day is done.
| Androids an' android lovers - you're all same t' them.
| O' course, there don't 'av to be any dyin' o' people.
| 'And this one over an' we'll be on our way.
~ fi
| She's not going anywhere.
~ jack
| (:shocked)Fi...
~ innis
| (:angry)He's giving us a way out.
~ islay
| (:unhappy)You really believe that?
~ catherine
| (:concerned)Don't go, {(nametag player)}.
~ zelah
| 'Ow nice, it 'as a name.
~ player
- I'm staying right here.
  ~ zelah
  | (:jovial)A was 'oping ya'd say that.
- I should go. It's for the best.
  ~ catherine
  | (:concerned)...
  ~ islay
  | (:expectant)It's not for the best.
  ~ fi
  | We're staying with you.
- How about I kill you right now?
  ~ zelah
  | (:jovial)This is an envoy. Kill mi, an' ma army'll slaughter you all.
~ islay
| {(nametag player)}, we don't know what androids did or didn't do during the Calamity. No one does.
~ fi
| It doesn't matter anyway. You've shown us who you really are.
~ zelah
| (:jovial)It's ya last chance... {(nametag player)}. Come with me, or ya friends'll die.
~ player
- Nice try.
- Fuck you.
- You'll be dead soon.
~ zelah
| Well in that case, a'll be off then.
| Seeya on ' battlefield.
")
  (:eval
    :on-complete (q15-engineering)
    (move-to (unit 'leader-rally) 'zelah)
    (move-to (unit 'alex-rally) 'alex)))

;; TODO why are we entertaining this person, kill them? - special ending?
;; TODO Zelah got to move away to a surface location - walk him to an army, spawned offscreen at end of this quest