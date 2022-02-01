;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria q15-start)
  :author "Tim White"
  :title "Return With Catherine to Engineering"
  :description "Return with Catherine to Engineering, to speak with Islay about checking why the bombs didn't explode."
  (:eval
   (setf (walk 'catherine) NIL))
  (:go-to (eng-cath :with catherine)
   :title "Talk to Islay in Engineering")
  (:interact (fi :now T)
    "
~ fi
| (:annoyed)Islay's gone. I couldn't stop her.
| She said the only way to be sure was if she checked the bombs herself.
~ player
- What?!
- She's too old.
  ~ fi
  | She might surprise you.
- She's dead.
  ~ fi
  | She might surprise you.
~ catherine
| (:concerned)Islay...
~ fi
| She did design the bombs, so if anyone can fix them it's her.
~ player
- We should go after her.
  ~ fi
  | I'm afraid I agree. She'll have better luck solving it with your help, Catherine.
  | Even though she said not to follow.
- Did she say anything else?
  ~ fi
  | She said for no one to follow.
  | But I think she'll have better luck solving it with your help, Catherine.
  | I'm afraid you both need to go after her.
- What now?
  ~ fi
  | I'm afraid you both need to go after here - even though she said for no one to follow.
  | She'll have better luck solving it with your help, Catherine.
~ catherine
| (:shout)I agree. Let's go!
~ fi
| Is your FFCS working?
~ player
| \"Checking FFCS...\"(light-gray, italic)
| (:skeptical)No. Wraw interference.
~ fi
| Then take this walkie.
! eval (store 'item:walkie-talkie-2 1)
| Stay in touch. And keep your eyes open down there.
")
  (:eval
   :on-complete (q15-unexploded-bomb)
   (activate (unit 'islay-bomb-1))
   (activate (unit 'islay-bomb-2))
   (activate (unit 'islay-bomb-3))
   (activate (unit 'islay-bomb-4)))
  (:go-to (islay-bomb :follow catherine)))

;; Islay felt guilty about sending someone so young as Catherine too