;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

;; character voice: London cockney
(quest:define-quest (kandria cerebat-trader-arrive)
  :author "Tim White"
  :title ""
  :visible NIL
  :on-activate T
  (talk-trader
   :title NIL
   :condition all-complete
   :on-complete (q8a-secret-supplies)
   :on-activate T
   (:interaction talk-to-trader
    :interactable cerebat-trader-quest
    :dialogue "
~ cerebat-trader-quest
| You 'ere to trade?
~ player
| Where is the Cerebat Council?
~ cerebat-trader-quest
| ...
| Keep ya voice down, will ya!
| What ya wanna see them for?
~ player
- It's private.
  ~ cerebat-trader-quest
  | That so. Well just make sure it stays that way.
- I want to ask them some questions.
  ~ cerebat-trader-quest
  | Piece o' friendly advice: Now is not a good time to be asking questions.
  ~ player
  | \"He touches his nose with a dirty forefinger.\"(light-gray, italic)
- I come from the Noka.
  ~ cerebat-trader-quest
  | The Noka? That the new faction on the surface?
  | Bunch o' crazy bastards if you ask me. No offence.
~ cerebat-trader-quest
| Anyway, you can't see the council - they won't see anyone.
| But lucky for you I'm a purveyor o' fine information, as just demonstrated.
| And I 'ave more to share.
| But it's not all free. A trader gotta make a livin', especially in these times.
~ player
- What times are those?
  ~ cerebat-trader-quest
  | ...
  | Ah, good one! You nearly 'ad me there, matey!
  | But I want something first before I tell you anything.
- What do you want?
  ~ cerebat-trader-quest
  | Oh nothing much. Nothing much at all, really. It's just...
- I understand.
  ~ cerebat-trader-quest
  | Good. It's a simple matter o' economics, innit?
~ cerebat-trader-quest
| If I'm gonna risk my neck, you gotta risk yours.
| See, the usual caravans aren't getting through, so it's kinda hard to get supplies.
| I'm talking mushrooms (poisonous ones o' course), purified water, and pearls - you know, the essentials.
| Might as well throw in some thermal fluid and coolant liquid while you're at it.
| A couple o' each should do nicely, just to get me back on my feet. Then I'll spill the beans.
| \"You shouldn't need to look too far away\"(orange) - what can I say, I'm lazy.
| Don't be a stranger!
~ player
| \"Indeed. Alright, unpicking that conversation, my grocery list is at least \"2 each\"(orange) of : \"black cap mushrooms\"(orange), \"purified water\"(orange), \"pearls\"(orange), \"thermal fluid\"(orange), \"coolant liquid\"(orange).\"(light-gray, italic)
| \"The //essentials//...\"(light-gray, italic)
")))

;; short and sweet questions and answers here, as this guy isn't really your friend. Also no need to conditional the questions, as he'll be gone before long
(quest:define-quest (kandria trader-cerebat-chat)
  :author "Tim White"
  :title "Trader Chat"
  :visible NIL
  :on-activate T
  (chat-trader
   :title "Talk to trader"
   :on-activate T
   (:interaction chat-with-trader
    :title "I have some questions."
    :interactable cerebat-trader-quest
    :repeatable T
    :dialogue "
~ cerebat-trader-quest
| Shoot.
! label questions
~ player
- Why are you helping the Wraw?
  ~ cerebat-trader-quest
  | I know how it looks.
  | But they pay well, and that's all I care about. A man's gotta make a living.
  < questions
- What happened to the Cerebat Council?
  ~ cerebat-trader-quest
  | Like I said, they're gone.
  | Some might still be alive though, rotting in some Wraw jail.
  < questions
- What's your name?
  ~ cerebat-trader-quest
  | Do you fink I got this far in business by sharing my name?
  | You can call me... Stranger.
  ! eval (setf (nametag (unit 'cerebat-trader-quest)) \"Stranger\")
  ~ player
  - Are you for real?
    ~ cerebat-trader-quest
    | You don't like it?
  - Okay, Stranger.
  - Why did you pick that name?
    ~ cerebat-trader-quest
    | Do you like it? I just made it up.
  ~ cerebat-trader-quest
  | What's your name?
  ~ player
  - Nice try.
    ~ cerebat-trader-quest
    | It was wasn't it.
  - Not Stranger.
    ~ cerebat-trader-quest
    | Well that would be a turn up for the books if it was.
  - (Lie) I don't remember my name.
    ~ cerebat-trader-quest
    | I don't remember mine neither.
  < questions
- I'm done.
~ cerebat-trader-quest
| See you around.
")))

(quest:define-quest (kandria trader-cerebat-shop)
  :title "Trade"
  :visible NIL
  :on-activate T
  (trade-shop
   :title "Trade"
   :on-activate T
   (:interaction buy
    :interactable cerebat-trader-quest
    :repeatable T
    :title (@ shop-buy-items)
    :dialogue "! eval (show-sales-menu :buy 'cerebat-trader-quest)")
   (:interaction sell
    :interactable cerebat-trader-quest
    :repeatable T
    :title (@ shop-sell-items)
    :dialogue "! eval (show-sales-menu :sell 'cerebat-trader-quest)")))
