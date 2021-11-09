;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria trader-semi-chat)
  :author "Tim White"
  :title "Trade With Islay"
  :description NIL
  :visible NIL
  :on-activate T  
  (chat-semi
   :title NIL
   :on-activate T
   (:interaction chat-semi
    :title "Can I talk to you?"
    :interactable islay
    :repeatable T
    :dialogue "
~ islay
| Of course.
! label talk
? (not (complete-p 'q6-return-to-fi))
| ~ player
| - How's Alex?
|   ~ islay
|   | (:unhappy)Not much better I'm afraid. He's an alcoholic. 
|   | (:normal)I think talking is helping though.
|   | If I can get him out of this bar it will be a start.
|   < talk
| - Why do you spy on the Noka?
|   ~ islay
|   | (:nervous)We spy on everyone. It's just what we do, it's nothing personal.
|   | (:normal)We have the technology, and the motivation. I don't know if you noticed, but most people down here are trying to kill each other.
|   | For what it's worth I value our friendship with the Noka. Innis does too, in her own way.
| - Are you really witches?
|   ~ islay
|   | (:unhappy)I'd have thought you of all people would know the cost of believing in superstition.
|   | We're as much witches as you are a menace.
|   | (:normal)People have never trusted what they don't understand. That hasn't changed just 'cause the world fell apart.
|   | And why should they, really? Perhaps it's on people like us to educate them.
|   < talk
| - What do you remember from before the Calamity?
|   ~ islay
|   | (:unhappy)It was another world, another lifetime.
|   | (:normal)If you're wondering whether androids destroyed the world, I can't help you.
|   | I wasn't on the surface - (:unhappy)few of us were, that's why we're still here.
|   | (:normal)But I can't see how that would've been possible.
|   | And even if you did, I doubt very much it was your own doing. No.
|   | No one destroyed humanity except humanity.
|   < talk
| - That'll do.
|   < leave

# leave
~ islay
| [? Take care, Stranger. | Mind how you go. | I'll be seeing you.]")))

(quest:define-quest (kandria trader-semi)
  :title "Trade"
  :visible NIL
  :on-activate T
  (trade-shop
   :title "Trade"
   :on-activate T
   (:interaction buy
    :interactable islay
    :repeatable T
    :title (@ shop-buy-items)
    :dialogue "! eval (show-sales-menu :buy 'trader)")
   (:interaction sell
    :interactable islay
    :repeatable T
    :title (@ shop-sell-items)
    :dialogue "! eval (show-sales-menu :sell 'trader)")))
