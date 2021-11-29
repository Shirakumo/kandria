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
|   ? (and (complete-p 'q5a-rescue-engineers) (complete-p 'q5b-repair-cctv))
|   | ~ alex
|   | | (:angry)What's the matter? Afraid to talk to me yourself, android? <-Hic->.
|   | ~ islay
|   | | (:nervous)The barkeep has stopped serving them, which is something.
|   | ~ alex
|   | | (:angry)Eh, android. <-Hic->. I 'ear you even stole my jobs around 'ere now too.
|   | | Go fuck yourself.
|   | ~ islay
|   | | (:expectant)You could work together Alex, for the Noka. Return to Fi together with Stranger, and get your old life back.
|   | ~ alex
|   | | (:unhappy)\"Stranger\", ha. Don't make me laugh- <-Hic->. I'm the stranger. Stranger to my own people.
|   | | I'm going nowhere. Get lost, both of you.
|   | ~ islay
|   | | (:normal)Perhaps it would be best if we leave them alone for a while.
|   | | I suggest you relay your findings to Fi.
|   | | We'll speak again.
|   | ! eval (setf (walk 'islay) T)
|   | ! eval (move-to 'islay-intercept (unit 'islay))
|   |?
|   | ~ islay
|   | | (:unhappy)Not much better I'm afraid. They're an alcoholic.
|   | | (:normal)I think talking is helping though.
|   | | If I can get them out of this bar it'll be a start.
|   < talk
| - Why spy on the Noka?
|   ~ islay
|   | (:nervous)We spy on everyone. It's just what we do, it's nothing personal.
|   | (:normal)We have the technology, and the motivation. I don't know if you noticed, but most people down here are trying to kill each other.
|   | For what it's worth I value our friendship with the Noka. Innis does too, in her own way.
| - Are you really witches?
|   ~ islay
|   | (:unhappy)I'd have thought you of all people would know the cost of superstition.
|   | We're as much witches as you are a menace.
|   | (:normal)People don't trust what they don't understand. That hasn't changed just 'cause the world fell apart.
|   | And why should they, really? Perhaps it's on people like us to teach them.
|   < talk
| - What do you remember from before the Calamity?
|   ~ islay
|   | (:unhappy)It was another world, another lifetime.
|   | (:normal)If you're wondering whether androids destroyed the world, I can't help you.
|   | I wasn't on the surface - (:unhappy)few of us were, that's why we're still here.
|   | (:normal)But I don't see how that would've been possible.
|   | And even if androids did, I doubt very much it was their own doing. No.
|   | No one destroyed humanity except humanity.
|   < talk
| - That'll do.
|   < leave

# leave
~ islay
| [? Take care, Stranger. | Mind how you go. | I'll be seeing you. | Ta-ta.]")))

(quest:define-quest (kandria trader-shop-semi)
  :title "Trade"
  :visible NIL
  :on-activate T
  (trade-shop-semi
   :title "Trade"
   :on-activate T
   (:interaction buy
    :interactable islay
    :repeatable T
    :title (@ shop-buy-items)
    :dialogue "! eval (show-sales-menu :buy 'islay)")
   (:interaction sell
    :interactable islay
    :repeatable T
    :title (@ shop-sell-items)
    :dialogue "! eval (show-sales-menu :sell 'islay)")))
