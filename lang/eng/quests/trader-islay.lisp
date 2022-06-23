;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria trader-semi-chat)
  :author "Tim White"
  :title ""
  :visible NIL
  :on-activate T
  (chat-semi
   :title NIL
   :on-activate T
   :condition (complete-p 'q11-recruit-semis)
   
   (:interaction chat-semi
    :title "Can I talk to you?"
    :interactable islay
    :repeatable T
    :dialogue "
~ islay
| Of course.
! label talk
? (not (complete-p 'q7-my-name))
| ~ player
| - Why spy on the Noka?
|   ~ islay
|   | (:nervous)We spy on everyone. It's just what we do, it's nothing personal.
|   | (:normal)We have the technology, and the motivation. I don't know if you noticed, but most people down here are trying to kill one another.
|   | For what it's worth I value our friendship with the Noka. Fi's a good leader.
|   < talk
| - Can you read my black box?
|   ~ islay
|   | You think you might have unwittingly betrayed the Noka.
|   | We know a lot about you - but no, we can't read your black box. No one can any more. (:unhappy)I'm sorry.
|   | (:normal)I saw what happened with the Servos in the pump room - (:nervous)whether they acted independently, or were being controlled, it's hard to say.
|   | An android could certainly do that though.
|   < talk
| - What was it like before the Calamity?
|   ~ islay
|   | (:unhappy)...
|   | It was another world, another lifetime.
|   | (:normal)If you're wondering if androids destroyed the world, I can't help you.
|   | I wasn't on the surface - (:unhappy)few of us were, that's why we're still here.
|   | (:normal)But I don't see how that would've been possible.
|   | And even if androids did, I doubt very much it was their own doing. No.
|   < talk
| - That'll do.
|   < leave
|? (and (complete-p 'q7-my-name) (not (complete-p 'q10-wraw)))
| ~ player
| - What's happening on the Cerebat border?
|   ~ islay
|   | (:nervous)We're still trying to ascertain that - but we've lost more cameras since you left.
|   | (:normal)Innis thinks we're next, but I'm not so sure.
|   | The Wraw are primitive. Maybe they're messing with the Cerebats, but they wouldn't stand a chance against our technology.
|   | And I'm not just talking about surveillance. We have weapons.
|   ! eval (setf (var 'semis-weapons) T)
|   < talk
| - What's it like living underground?
|   ~ islay
|   | (:nervous)You mean apart from not knowing what time of day it is, or the lack of sunlight?
|   | (:normal)At least we get vitamin D from mushrooms like the flower fungus, once we expose them to UV light.
|   | Apart from that it's fine - most of us spent our lives underground even before the Calamity.
|   | (:unhappy)I suppose fresh air is a problem, as you've probably noticed - wind tunnels do help though.
|   | (:normal)Sometimes I envy the Noka. I know living on the surface has it challenges, but it must be nice living under the sky.
|   < talk
| - Why are the Semis mostly women?
|   ~ islay
|   | (:unhappy)Why not?
|   | (:normal)... Most who worked in the factories were women. After the Calamity we just stayed together.
|   | And we've done better than most.
|   | Maybe the world wouldn't have fallen apart if there were more women in charge. Present company included.
|   < talk
| - I need to go.
|   < leave
|? (and (complete-p 'q10-wraw) (not (complete-p 'q11-recruit-semis)))
| ~ player
| - The Wraw are coming for everyone in the valley.
|   ~ islay
|   | Thank you, but we already know about the scale of their operation.
|   | (:nervous)We're making... preparations.
|   ~ player
|   - You've been spying on me again.
|     ~ islay
|     | (:nervous)... I'm afraid so.
|     | (:normal)Good luck, {(nametag player)}.
|   - What preparations?
|     ~ islay
|     | (:nervous)I'm afraid I can't share that. I'm sorry.
|     | (:normal)Good luck, {(nametag player)}.
|   - Good luck.
|     ~ islay
|     | Thank you, {(nametag player)}. To you too.
|   - Let's talk about something else.
|   < talk
| - Do androids live in the mountains?
|   ~ islay
|   | (:nervous)Oh, that old chestnut...
|   | (:normal)Before the Calamity there were hundreds of thousands of androids, and more in production.
|   | Where did they all go? Were they all destroyed? - Present company excepted.
|   | Sometimes we find the occasional Genera core; but the truth is no one knows, and we'll probably never know.
|   | But I doubt any are living in the mountains. We'd have seen or heard something, detected a signal... (:unhappy)But there's nothing.
|   < talk
| - I need to go.
|   < leave

# leave
~ islay
| [? Take care, {(nametag player)}. | Mind how you go, {(nametag player)}. | I'll be seeing you. | Ta-ta.]")))

(quest:define-quest (kandria trader-semi-alex)
  :author "Tim White"
  :title ""
  :visible NIL
  :variables (alex-done alex-fee)
  :on-activate T
  (chat-semi-alex
   :title NIL
   :on-activate T
   :condition (complete-p 'q10-wraw)
   
   (:interaction chat-semi-alex
    :title "How's Alex?"
    :interactable islay
    :repeatable T
    :dialogue "
! label talk
? (not (complete-p 'q7-my-name))
| ? (and (complete-p 'q5a-rescue-engineers) (complete-p 'q5b-investigate-cctv) (not (var 'alex-done)))
| | ~ alex
| | | (:angry)What's the matter? Afraid to talk to me yourself, android? <-Hic->.
| | ~ islay
| | | (:nervous)The barkeep has stopped serving them, which is something.
| | ~ alex
| | | (:angry)Oi, android! <-Hic->. I 'ear you even stole my jobs 'round 'ere now too.
| | ~ islay
| | | You could work together Alex, for the Noka - return to Fi with Stranger and get your old life back.
| | ~ alex
| | | (:unhappy)\"Stranger\", ha. Don't make me laugh- <-Hic->. I'm the stranger. Stranger to my own people. Stranger to myself.
| | | Get lost, both of you.
| | ~ islay
| | | Let's \"leave them in peace for a while\"(orange). They might feel differently once they've sobered up.
| | | You've done a lot for us though, with little to show for it.
| | | \"Take these parts as recompense\"(orange) - though hopefully soon you'll have Alex to show for it as well.
| | ! eval (store 'item:parts 600)
| | ! eval (setf (var 'alex-fee) T)
| | | [(not (complete-p 'q6-return-to-fi)) You should \"get back and update Fi\"(orange). I'll keep an eye on Alex. | Don't worry, I'll keep an eye on them.]
| | | We'll speak again.
| | ! eval (setf (var 'alex-done) T)
| | ! eval (move-to 'islay-main-loc (unit 'islay))
| | ! eval (clear-pending-interactions)
| |? (var 'alex-done)
| | ~ islay
| | | (:nervous)They're still in the bar, (:normal)but I've ordered the barkeeps not to serve them.
| | | I've got a hidden camera trained on them as well - they won't fart without me knowing about it.
| |?
| | ~ islay
| | | (:unhappy)Not much better I'm afraid. (:normal)I think talking is helping though.
| | | If I can get them out of this bar it'll be a start.
|? (and (complete-p 'q7-my-name) (not (complete-p 'q10-wraw)))
| ~ islay
| | (:nervous)\"They've gone. I don't know where\"(orange). They just upped and left. Managed to evade most of our cameras.
| | If they've not returned to the Noka then I don't know.
| | (:normal)I hope they're okay. And sober.
| | (:unhappy)I'm sorry, I should've kept a closer eye.
| ? (not (var 'alex-fee))
| | | You've done a lot for us, with little to show for it.
| | | Please \"take these parts as recompense\"(orange).
| | ! eval (store 'item:parts 600)
| | ! eval (setf (var 'alex-fee) T)
|   
| ~ islay
| | Be careful, {(nametag player)}.
")))

(quest:define-quest (kandria trader-shop-semi)
  :title ""
  :visible NIL
  :on-activate T
  (trade-shop-semi
   :title ""
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
