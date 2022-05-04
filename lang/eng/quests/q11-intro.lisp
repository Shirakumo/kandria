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
  | (:happy)You're always a free agent. (:normal)But I have an important task for you.
~ fi
| Innis was right about the Cerebat takeover. And if the Wraw have marched that far, then the Semi Sisters are next.
| (:annoyed)Now is no time for division - the Wraw are a threat to them as much as they are to us.
| (:normal)I think you've come to earn \"Innis' trust\"(orange).
| I want you to use whatever sway you have with her and \"ask her to stand with us\"(orange).
~ player
- Got it.
- I wouldn't get your hopes up.
- What if they join the Wraw?
- [(var 'semis-weapons) They also have weapons.]
  ~ fi
  | (:unsure)So they say, though I've never seen any.
  | (:normal)But I'll take what we can get.
~ fi
| Innis is a lot of things but she isn't stupid.
| Just make sure you get to them first.
| I'm going to see Sahil. \"Call me when you have news.\"(orange)
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
- No promises.
! eval (setf (location 'trader) (location 'trader-semi-loc))
! eval (setf (direction 'trader) 1)
! eval (setf (walk 'fi) T)
! eval (move-to 'loc-trader (unit 'fi))
? (not (complete-p 'trader-arrive))
| ! eval (activate 'trader-chat)
| ! eval (activate 'trader-shop)
")
  (:eval
   :on-complete (q11-recruit-semis)))
;; moving Sahil back to his start location in the Semis base. Yes it's arguably closer to the frontline, but he wants strength in numbers, or to hide in a familiar corner maybe