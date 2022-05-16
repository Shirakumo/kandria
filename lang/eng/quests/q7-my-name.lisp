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
  | (:happy)No, thank you. Thank you for everything you've done.
- It's true.
  ~ fi
  | (:happy)...
- About time.
  ~ fi
  | Yes, sorry about that. Things don't always happen the fastest around here.
~ fi
| I've been thinking about your name too. Do you still not remember it?
~ player
| (:thinking)No. At least not completely.
| There are corrupted data strings in my matrix - one of them could be my name, but I'd have to guess at exactly what it was.
~ fi
| Well, I think Catherine was sincere when she called you Stranger; but I wonder if that's the name you'd really choose for yourself.
| You're not a stranger any more.
| Do you want to change your name?
! label name
~ player
- (Keep name as {#@player-name-1})
  ~ fi
  | Are you sure? You want us to continue to call you \"{#@player-name-1}\"(yellow)?
  ~ player
  - (No - choose a different name)
    < name
  - (Yes - confirm name as \"{#@player-name-1}\")
    ~ fi
    | (:happy)If you like it, I like it.
- (Choose a new name)
  ~ player
  | \"From the corrupted strings in my registry, I'd guess my name was one of these three:\"(light-gray, italic)
  ! label old-names
  ~ player
  - ({#@player-name-2})
    ~ fi
    | Are you sure? You want us to call you \"{#@player-name-2}\"(yellow)?
    ~ player
    - (No - choose a different name)
      < old-names
    - (Yes - confirm name as \"{#@player-name-2}\")
      ! eval (setf (nametag player) (@ player-name-2))
      ~ fi
      | (:happy)I like it. Especially since it might have been your old name.
  - ({#@player-name-3})
    ~ fi
    | Are you sure? You want us to call you \"{#@player-name-3}\"(yellow)?
    ~ player
    - (No - choose a different name)
      < old-names
    - (Yes - confirm name as \"{#@player-name-3}\")
      ! eval (setf (nametag player) (@ player-name-3))
      ~ fi
      | (:happy)I like it. Especially since it might have been your old name.
  - ({#@player-name-4})
    ~ fi
    | Are you sure? You want us to call you \"{#@player-name-4}\"(yellow)?
    ~ player
    - (No - choose a different name)
      < old-names
    - (Yes - confirm name as \"{#@player-name-4}\")
      ! eval (setf (nametag player) (@ player-name-4))
      ~ fi
      | (:happy)I like it. Especially since it might have been your old name.
  - (Go back)
    < name
- (Let Fi choose your name)
  ~ fi
  | (:unsure)You'd let me do that? I thought you might want to choose a name for yourself.
  ~ player
  - On second thoughts...
    < name
  - You can choose.
    ~ fi
    | (:unsure)Okay, no pressure then...
    | (:normal)I guess to me you seem like... \"{#@player-name-fi}\"(yellow). What do you think?
    ~ player
    - (No - choose a different name)
      < name
    - (Yes - confirm name as \"{#@player-name-fi}\")
      ! eval (setf (nametag player) (@ player-name-fi))
      ~ player
      | (:giggle)I like it.
      ~ fi
      | (:happy)Thank you. It means a lot that you let me do that.
~ fi
| (:happy)That's settled then, \"{(nametag player)}\"(yellow). Welcome to the Noka.
| (:normal)I wish we could talk, but I really need you to take this next assignment.
| (:happy)Your first \"official\" one, no less.
| (:unsure)It's just... I can't get what Innis said out of my head. We need to talk to the Cerebats.
| (:normal)\"Go and see the Cerebat Council\"(orange) in the heart of their territory, \"beneath the Semi Sisters\"(orange).
| \"See what you can learn\"(orange). If they've been invaded by the Wraw, I think you'll know soon enough.
~ player
- I will.
- I don't think there's anything to worry about.
  ~ fi
  | I hope you're right.
- So you're sending me into the lion's den?
  ~ fi
  | I hope not.
~ fi
| Just don't get caught - by the Wraw //or// the Semi Sisters.
| And \"please stay in touch\"(orange).
| Good luck, {(nametag player)}.
! eval (setf (location 'alex) 'alex-cerebat-loc)
! setf (direction 'alex) 1
! eval (setf (location 'islay) 'islay-main-loc)
! setf (direction 'islay) 1
")
   (:eval
   :on-complete (q8-meet-council cerebat-trader-arrive q8-alex-cerebat)))

;; this could be a ceremony with Jack and Catherine in attendance, but it feels more personal with just you and Fi. Also, the others will acknowledge your new name later, the next time you speak to them, to suggest that word has travelled