;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria q11-intro)
  :author "Tim White"
  :title ""
  :visible NIL
  (:interact (fi)
  "
~ player
- What can I do?
  ~ fi
  | (:happy)I'm glad you asked.
- I think you forgot about me.
  ~ fi
  | (:happy)On the contrary.
- Am I a free agent now?
  ~ fi
  | (:happy)You're always a free agent. (:normal)But I have an important mission for you.
~ fi
| Innis was right about the Cerebat takeover, and you've come to know her better than anyone.
| (:thinking)And if the Wraw have marched as far as the Cerebats, then the Semi Sisters are next.
| (:normal)Now is not the time for division - the Wraw are a threat to them as much as they are to us.
| Use whatever sway you have with \"Innis and Islay\"(orange) and \"ask them to stand with us\"(orange).
~ player
- Got it.
- I wouldn't count on it.
- What if they join the Wraw?
- [(var 'semis-weapons) They have weapons.]
  ~ fi
  | (:unsure)So they say, although I've never seen any.
  | But I'll take what we can get.
~ fi
| Innis is a lot of things but she isn't stupid.
| Just make sure you get to them first.
| I'm going to see Sahil.
~ player
| \"Fi looks like she wants to say something else, but then the moment passes.\"(light-gray, italic)
- Are you okay?
  ~ fi
  | (:happy)I'm fine. Be safe.
- I'll be fine.
  ~ fi
  | (:happy)I know you will. Be safe.
- See you soon.
  ~ fi
  | (:happy)Be safe.
- Goodbye.
  ~ fi
  | (:unsure)You say that with such finality.
  | Please be safe.
~ player
- I will.
- You too.
- Be safe yourself.
! eval (setf (walk 'fi) T)
! eval (move-to 'loc-trader (unit 'fi))
")
  (:eval
   :on-complete (q11-recruit-semis)))
;; TODO hide Sahil at this stage, as if he's moved on