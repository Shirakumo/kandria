;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

;; forward game clock by 31:43 (1903 seconds) to represent being offline
(define-sequence-quest (kandria epilogue-talk)
  :author "Tim White"
  :title ""
  :visible NIL
  (:eval
   (stop 'player)
   (setf (state (unit 'player)) :animated))
  ;; KLUDGE: we have to do this wait 0 business here to defer the next few statements.
  ;;         the reason for this being that setting stuff like the animation on the player
  ;;         requires the player to have been fully loaded, which is not necessarily the
  ;;         the case when this quest is activated, as this happens during initial state
  ;;         load, but before asset load. The wait sufficiently defers the next stuff
  ;;         until after the load has completed.
  (:wait 0.0)
  (:eval
   (incf (timestamp +world+) 1903)
   (harmony:play (// 'sound 'player-awaken))
   (start-animation 'laying player))
  (:wait 1)
  (:animate (player wake-up))
  (:interact (catherine :now T)
  "
~ catherine
| (:concerned)... Oh man, you had me worried for a second.
| Are you okay?
~ player
- What happened?
  ~ catherine
  | (:concerned)What didn't happen.
  | I don't know how long I was out. \"It's been about fifteen minutes since I woke up\"(orange).
- Not here again.
  ~ catherine
  | (:concerned)We really took a beating to end up over here.
  | I don't know how long I was out. \"It's been about fifteen minutes since I woke up\"(orange).
- How many decades was I out this time?
  ~ catherine
  | None thankfully, \"only about fifteen minutes\"(orange). Well, that's \"after I woke up\"(orange).
  | (:concerned)You must have taken an even bigger bump to the head than I did.
~ catherine
| (:excited)I think the \"bombs exploded\"(orange). Which means we won!
| (:concerned)But \"that blast was bigger than it should've been\"(orange).
| I had a look around - I think it's \"collapsed this whole area\"(orange).
| I hope Islay is okay.
~ player
- She'll be fine.
  ~ catherine
  | (:concerned)I hope so.
- Are you okay?
  ~ catherine
  | (:concerned)My head hurts. I might have a mild concussion, but I'll be okay.
- She was next to a bomb so...
  ~ catherine
  | (:concerned)...
~ catherine
| (:concerned)This place isn't safe. We should \"get back to the surface\"(orange). \"Can you walk\"(orange)?
~ player
- I think so.
- One way to find out.
- If not I don't think you can carry me.
")
  (:eval
   :on-complete (epilogue)))
;; place is unsafe, so even with concussion, it's better for Catherine to leave. You lead the way though