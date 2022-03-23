;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria q7-my-name)
  :author "Tim White"
  :title "My Name"
  :visible NIL
  (:interact (fi)
  "
~ fi
| (:happy)I think it's high time that I formally welcomed you into the Noka.
| You've more than earned it.
~ player
- Thank you.
  ~ fi
  | No, thank you. Thank you for everything you've done.
- It's true.
  ~ fi
  | (:happy)...
- About time.
  ~ fi
  | Yes, sorry about that. Things don't always happen the fastest around here.
  | And speaking from personal experience, I take a long time to trust someone.
~ fi
| But there's something else.
| It's about your name. Do you still not remember it?
~ player
| (:thinking)I don't. At least not completely.
| There are corrupted data strings in my matrix - one of them could be my name, but I'd have to guess at exactly what it was.
~ fi
| Well, I think Catherine was sincere when she called you Stranger, but I wonder if that's really the name you'd choose for yourself.
| You're no longer a stranger to us, after all.
| Do you want to change your name?
! label name
~ player
- (Keep name as Stranger)
  ~ fi
  | Are you sure? You want us to continue to call you Stranger?
  ~ player
  - (No - choose a different name)
    < name
  - (Yes - confirm name as \"Stranger\")
    ~ fi
    | (:happy)If you like it, I like it.
- (Choose a new name)
  ~ player
  | \"From the corrupted strings in my registry, I'd guess my name was one of these three:\"(light-gray, italic)
  ! label old-names
  ~ player
  - (Andréa)
    ~ fi
    | Are you sure? You want us to call you Andréa?
    ~ player
    - (No - choose a different name)
       < old-names
    - (Yes - confirm name as \"Andréa\")
      ! eval (setf (nametag player) \"Andréa\")
      ~ fi
      | (:happy)I like it.
  - (Katriona)
    ~ fi
    | Are you sure? You want us to call you Katriona?
    ~ player
    - (No - choose a different name)
       < old-names
    - (Yes - confirm name as \"Katriona\")
      ! eval (setf (nametag player) \"Katriona\")
      ~ fi
      | (:happy)I like it.
  - (Nadia)
    ~ fi
    | Are you sure? You want us to call you Nadia?
    ~ player
    - (No - choose a different name)
      < old-names
    - (Yes - confirm name as \"Nadia\")
      ! eval (setf (nametag player) \"Nadia\")
      ~ fi
      | (:happy)I like it.
  - (None of these)
    < name
- (Let Fi choose your name)
  ~ fi
  | (:shocked)What? You'd let me do that? I thought you might want to choose a name for yourself.
  ~ player
  - On second thoughts...
    < name
  - You can choose.
    ~ fi
    | (:thinking)Okay, no pressure. Let me think...
    | I think to me you've always felt like a Chiyo. What do you think?
    ~ player
    - (No - choose a different name)
       < name
    - (Yes - confirm name as \"Chiyo\")
      ! eval (setf (nametag player) \"Chiyo\")
      ~ player
      | (:giggle)I like it.
      ~ fi
      | (:happy)Thank you. It means a lot that you let me do that.
~ fi
| (:happy)That's settled then, {#@player-nametag}. And once again, welcome to the Noka.
| (:normal)I wish we could talk, but I really need you to take this next assignment.
| (:happy)Your first \"official\" one, no less.
| (:thinking)I can't get what Innis said out of my head. We need to talk to the Cerebats.
| (:normal)\"Go and see the Cerebat Council\"(orange) in the heart of their territory, \"beneath the Semi Sisters\"(orange), and \"see what you can learn\"(orange).
| If they've been invaded by the Wraw, I think you'll know soon enough.
| Just don't get caught - by the Wraw //or// the Semi Sisters - and hurry back.
| Good luck, {#@player-nametag}.
! eval (setf (location 'alex) 'alex-cerebat-loc)
! setf (direction 'alex) 1
")
   (:eval
   :on-complete (q8-meet-council cerebat-trader-arrive q8-alex-cerebat)))

;; this could be a ceremony with Jack and Catherine in attendance, but it feels more personal with just you and Fi. Also, the others will acknowledge your new name later, the next time you speak to them, to suggest that word has travelled