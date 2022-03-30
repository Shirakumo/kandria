;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria q15-intro)
  :author "Tim White"
  :title "Go to Engineering"
  :description "Islay wants to meet Fi and I in Engineering."
  (:eval
   (setf (walk 'islay) T)
   (setf (walk 'fi) T)
   (move-to 'eng-cath (unit 'fi)))
  (:go-to (eng-cath :with islay)
   :title "Meet Islay in Engineering")
  (:interact (islay :now T)
    "
~ islay
| We should detonate the bombs now.
~ fi
| But Zelah's still on the surface.
~ islay
| We do it now, bury the army, then clean up the rest.
~ fi
| Shouldn't we tell the others?
~ islay
| No. We do it while we still have the element of surprise.
~ fi
| If you're sure.
~ islay
| I'm sure.
| (:expectant)Alright, here goes. Sending the signals...
| ...
~ fi
| ...
~ islay
| (:nervous)It didn't work.
~ fi
| (:annoyed)What?... Why?
~ islay
| I don't know.
~ fi
| (:unsure)Could they have defused them?
~ islay
| I don't think so. Not this quickly.
| And I think the signal is getting through; their comms interference isn't running yet - Zelah's probably talking to his own people.
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
| No. You don't know enough about the bombs. (:nervous)It has to be \"Catherine\"(orange)...
~ fi
| (:unsure)... There must be another way.
~ player
- Some of the bombs are hard to reach.
  ~ islay
  | Then we need to find a way.
- Teach me how to check them.
  ~ islay
  | (:nervous)There's no time. And it's too risky if you can't figure it out.
- What about Jack?
  ~ fi
  | ...
  ~ islay
  | He doesn't know anything about the bombs.
~ islay
| You can go with her though, {(nametag player)}. To protect her.
~ fi
| ...
~ islay
| Please \"go and fetch her\"(orange).
")
  (:eval
   :on-complete (q15-catherine)
   (ensure-nearby 'wraw-rally 'zelah 'alex)))
   
;; TODO move rest of Wraw envoy entourage down to this position too