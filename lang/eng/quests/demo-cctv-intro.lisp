;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria demo-cctv-intro)
  :author "Tim White"
  :title "Talk to Islay"
  :description "The Semi in charge (I didn't catch her name) said I should talk to her sister, Islay, about what I can do for them, in exchange for turning the water back on."
  (:interact (islay)
   :title "Talk to Islay in the Semi Sisters base"
  "
~ islay
| Hello, Stranger. (:happy)It's an honour to meet you in person.
| (:unhappy)I'm sorry about my sister.
~ player
- What do I need to do for you?
  ~ islay
  | (:expectant)Right, yes. The sooner we get started, the sooner we can turn your water back on.
- What's her problem?
  ~ islay
  | (:happy)How long have you got? Let's just say diplomacy isn't one of Innis' strengths.
  | (:expectant)Anyway, about the job. The sooner we get started, the sooner we can turn your water back on.
- Can't you just turn the water back on?
  | (:nervous)I'm afraid not. Much as I sympathise with your predicament.
  | (:normal)Innis is at least right about that - we need that water too.
  | (:expectant)But a trade is acceptable. And the sooner we get started, the sooner we can turn it back on for you.
~ islay
| (:nervous)Four of our cameras on the \"Cerebat\"(red) border have gone down, in the \"low-eastern region\"(orange).
| (:normal)It's probably just an electrical fault. Unfortunately the way we daisy-chain them together means when one goes, they all go.
| (:expectant)We've seen what you can do - you could reach them much faster than our hunters.
| (:nervous)Just don't tell Innis I said that. She'll think I've gone soft for androids.
| (:normal)Go to the \"low-eastern region\"(orange) and check the cameras.
| \"Report back to Innis\"(orange) when you have news - by then we'll probably be \"up in the control room\"(orange).
| Good luck.
! eval (setf (nametag (unit 'innis)) (@ innis-nametag))
! eval (activate (unit 'demo-move-semis-1))
! eval (activate (unit 'demo-move-semis-2))
")
  (:eval
   :on-complete (demo-cctv)))
   
;; also use a trigger mid-explore to move Innis and Islay back to control room