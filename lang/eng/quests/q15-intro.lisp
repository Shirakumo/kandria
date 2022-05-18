;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria q15-intro)
  :author "Tim White"
  :title "Go to Engineering"
  :description "Islay wants to meet Fi and I in Engineering."
  (:eval
   (setf (walk 'islay) T)
   (setf (walk 'fi) T)
   (move-to 'eng-jack (unit 'fi)))
  (:go-to (eng-cath-2 :with islay)
   :title "Meet Islay in Engineering")
  (:interact (islay :now T)
    "
~ islay
| We should \"detonate the bombs now\"(orange).
~ fi
| But Zelah's still on the surface.
~ islay
| We do it now, bury the army, then finish off the rest.
~ fi
| (:unsure)Should we not tell the others first?
~ islay
| No. We do it while we still have the element of surprise.
~ fi
| If you're sure.
~ islay
| I'm sure.
| (:nervous)Alright, here goes. Sending the signals...
| ...
~ fi
| ...
~ islay
| (:unhappy)\"It didn't work.\"(orange)
~ fi
| (:annoyed)What?... Why?
~ islay
| (:nervous)I don't know.
~ fi
| (:unsure)Could they have tampered with them?
~ islay
| I don't think so. Not this quickly.
| And I think \"the signal is getting through\"(orange); their comms interference isn't running yet - Zelah's probably organising his own people.
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
| You could go with Catherine, though, {(nametag player)}. To protect her.
~ islay
| Please \"fetch her\"(orange).
")
  (:eval
   :on-complete (q15-catherine)))
   
;; TODO move rest of Wraw envoy entourage down to this position too