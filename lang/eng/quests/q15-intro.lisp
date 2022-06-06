;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria q15-intro)
  :author "Tim White"
  :title "Go to Engineering"
  :description "Islay wants to meet Fi and I in Engineering."
  (:eval
   (move-to 'eng-jack (unit 'fi)))
  (:go-to (eng-cath-2 :with islay)
   :title "Meet Islay in Engineering")
  (:interact (islay :now T)
    "
~ fi
| (:unsure)What is it? Should we detonate the bombs now?
~ islay
| (:nervous)Zelah's still on the surface. And what if he knows about them? Won't his army have pulled back?
~ fi
| (:annoyed)He doesn't know about them.
~ islay
| ...
| Alright.
| We'll do it now. Collapse the tunnels, then finish off the rest.
~ fi
| If you're sure.
~ islay
| I'm sure.
| (:nervous)Here goes. Sending the signals...
| ...
~ fi
| ...
~ islay
| (:unhappy)\"It didn't work.\"(orange)
~ fi
| (:annoyed)What?... Why?
~ islay
| (:nervous)I don't know.
| \"The signal is getting through\"(orange); their comms interference isn't running yet - Zelah's probably organising his own people.
~ fi
| (:unsure)Could they have found the bombs?
~ islay
| ... Let's hope not.
| (:unhappy)Fuck.
| Someone needs to go down there.
~ player
- I'll go.
  ~ fi
  | (:happy)...
- That's what I'm here for.
  ~ fi
  | (:happy)...
- I guess that means me.
~ islay
| No. You don't know enough about the bombs. (:nervous)It has to be \"Catherine\"(orange).
~ fi
| (:annoyed)You don't trust {(nametag player)}?
~ islay
| (:nervous)It's not that.
~ player
- Some of the bombs are hard to reach.
  ~ islay
  | Then we need to find a way.
- Teach me how to check them.
  ~ islay
  | (:nervous)There's no time. And it's too risky if you can't figure it out.
- Catherine might get hurt.
  ~ fi
  | (:unsure)She's only a child, Islay.
  ~ islay
  | She isn't. And she knows what she's doing.
~ islay
| You could go with Catherine though, {(nametag player)}. To protect her.
~ islay
| Please \"fetch her\"(orange).
")
  (:eval
   :on-complete (q15-catherine)
   (ensure-nearby 'wraw-rally 'zelah 'alex 'soldier-1 'soldier-2 'soldier-3)))
   
;; TODO move rest of Wraw envoy entourage down to this position too