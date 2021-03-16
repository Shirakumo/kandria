(:name trade-trader
 :title "Talk to Sahil"
 :description NIL
 :invariant T
 :condition NIL
 :on-activate (trade-with-trader)
 :on-complete NIL
)
 
(quest:interaction :name trade-with-trader :interactable trader :repeatable T :dialogue "
~ trader
| Assalam Alaikum! Are you well today?
! label main
~ player
- I'd like to trade.
  ~ trader
  | [? That's what I like to hear! | Yes, sir! | And so would I! | That's the spirit! | You got it.]
  | p/h Open shop UI
  < main
- Can we talk.
  ~ trader
  | [? Of course, habeebti - always. | We can indeed. | What's on your mind? | I love to chat.]
  ~ player
  ? (not (complete-p 'q4-find-allies))
  | - What's your story?
  |   ~ trader
  |   | A long and sad one I'm afriad... Like most people's.
  |   | I used to hang with the Wraw too, believe it or not.
  |   | I got out too, only with my caravan rather than a vendetta.
  |   | And now I tour the settlements, trading, making ends meet - and making things too!
  |   < main
  | - What do you make of this place?
  |   ~ trader
  |   | The Noka? They're a good bunch, what can I say?
  |   | Fi's a good person, which is rare in these parts.
  |   | They broke out on their own, had enough of that Wraw bullshit.
  |   | Can't blame 'em. It was brave. It might also prove stupid though, we'll see.
  |   < main
  | - Catherine said you were later than expected...
  |   ~ trader
  |   | Yeah, those damn rogues were prowling about.
  |   | Don't get me wrong, I can handle myself.
  |   | But it's not easy when you're pulling your own caravan.
  |   ~ player
  |   | You pull your own caravan?
  |   ~ trader
  |   | Well no other alugud is going to do it for me!
  |   | I used to have an ox, believe or not... Ha, an ox, in these parts! It's hard to imagine.
  |   | Didn't last long after the wolves got at her throat though. Poor Celina.
  |   < main
  | - Do you like androids?
  |   ~ trader
  |   | Ah, you had a warm welcome, have you?
  |   | Listen, it's nothing personal. It's just everyone has heard the stories, you know?
  |   | It's always androids this, androids that... Like a race of servile machine could destroy the world!
  |   | It's haraa is what it is.
  |   ~ player
  |   | So what did destroy the world?
  |   ~ trader
  |   | I don't know...
  |   | But what I do know is humanity could stand to take a good long look in the mirror.
  |   < main
  | - I changed my mind.
  |   < changed-mind
- I need to go.
~ trader
| [? See you later habeebti. | You take it easy. | Goodbye for now. | Take care. Masalamah! | Goodbye! And if you ever change your mind about parting with that sword of yours... I know, I know.]
# changed-mind
~ trader
| [? Happens to the best of us. | As you wish. | Don't worry about it.]
< main
")
; todo open shop UI
#| todo use shuffle syntax in some trader responses, e.g. when player says they changed their mind
! eval ({(alexandria:random-elt '("Happens to the best of us." "Don't worry about it."))})
or new syntax to achieve? [? Happens to the best of us. | Don't worry about it.]
|#
; todo flesh out with Sahil questions relevant to current plot points - confidente, as a fellow outsider?


#| todo
later talks with trader:
- ask specifically about each faction member
- get into his own history more
- why don't you join up? - reveal he doesn't visit the enemy faction
|#