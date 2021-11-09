;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria q5-run-errands)
  :author "Tim White"
  :title "Run Errands"
  :visible NIL
  (:eval (setf (location 'islay) (location 'islay-errand-spawn)))
  (:eval (setf (walk 'islay) T))
  (:eval (follow 'player 'islay)) (:nearby (player islay))
  (:interact (islay :now T)
   "
~ islay
| Hello again. You found Alex, I see. How are they?
~ player
- Drunk as a skunk.
- They won't cooperate.
- See for yourself.
~ islay
| (:nervous)I feared as much.
| (:normal)What about if I talk to them?
| If you can give me some time, I could perhaps help them see reason.
~ player
- I'd appreciate that.
  ~ islay
  | (:happy)It's the least I can do.
- What's the catch?
  ~ islay
  | No catch. I just want to help.
- I think they're a lost cause.
  ~ islay
  | Forgive me for saying so, but I don't believe in those.
  | Were you yourself not a lost cause before Alex found you?
~ islay
| You should stay with us a while, give me some time.
| And if you'd like something to do, there are things you could help us with too.
~ player
| (:skeptical)So there is a catch.
~ islay
| No. This isn't a trade. You're free to go and do anything you want.
| I just didn't want you to get bored.
| (:expectant)And it couldn't hurt to show my sister what you can do, could it? Sow some seeds of diplomacy.
~ player
- You're right.
  ~ islay
  | Aye, sometimes I'm right.
- Tell that to your sister.
  ~ islay
  | I do. Frequently. Innis has her qualities - but yeah, diplomacy isn't one of them.
- Diplomacy does not compute.
  ~ islay
  | Come now, you're no mere servo. I know you understand.
~ islay
| (:happy)I can sweeten the deal too.
| (:normal)I suppose I'm what you'd call the chief engineer around here. Just like Jack is for the Noka.
| Which means I stock many things that might be useful to you.
| We get the usual traders visiting too, but I'm giving you another option - and I stock more supplies than most.
| (:unhappy)Anyhow, much as I'd hate to send you back into the jaws of my sister, she's got my report on our most urgent tasks.
| (:happy)I guess you could see her as just another challenge to overcome.
| (:normal)So leave Alex to me, and if you'd like to help, \"speak with Innis\"(orange).
| Ta-ta for now.
! eval (stop-following 'islay)
! eval (move-to 'alex (unit 'islay))
"))
;;TODO different prices for different traders, so write in that Islay gives you a good discount?
