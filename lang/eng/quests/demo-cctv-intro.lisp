;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria demo-cctv-intro)
  :author "Tim White"
  :title "Talk to Islay"
  :description "The Semi in charge (I didn't get her name) said I should talk to her sister, about what I can do for them, in exchange for them turning the water back on."
  (:interact (islay)
   :title "Find the sister in the Semis base"
  "
~ islay
| Hello, Stranger. (:happy)It's an honour to meet you in person.
| (:unhappy)I'm sorry about my sister.
~ player
- What do I need to do for you?
  ~ islay
  | (:expectant)Right, yes. The sooner we get started, the sooner we can turn your water back on.
- What's her problem?
- Can't you just turn the water back on?
~ islay
| We monitor the surrounding area, immediately above and below.
| (:nervous)Four of our cameras on the Cerebat border have gone down, in the \"low-eastern region\"(orange).
| (:normal)It's probably just an electrical fault. Unfortunately the way we daisy-chain them together means when one goes, they all go.
| (:expectant)We've seen what you can do - you'll be able to reach them much faster than our hunters could.
| (:nervous)Just don't tell Innis I said that. She'll think I've gone soft for androids.
| (:normal)\"Report back to Innis\"(orange) when you have news - by then we'll probably be back \"up in the control room\"(orange).
! eval (setf (nametag (unit 'innis)) (@ innis-nametag))
")
  (:eval
   :on-complete (demo-cctv)))
   
;; also use a trigger mid-explore to move Innis and Islay back to control room