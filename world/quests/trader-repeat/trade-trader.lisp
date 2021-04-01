(:name trade-trader
 :title "Talk to Sahil"
 :description NIL
 :invariant T
 :condition NIL
 :on-activate (trade-with-trader)
 :on-complete NIL)
 
(quest:interaction :name trade-with-trader :interactable trader :repeatable T :dialogue "
~ trader
| Assalam Alaikum!
? (< 80  (health player))
| | [? You look well, Stranger! | And how robust you're looking today! | I don't think I've seen you looking more radiant.]
|? (< 50  (health player))
| | [? Have you been fighting, Stranger? | Something's different - you're missing your usual refined appearance. | Let me guess - you've been pounding rogues again?]
|?
| | [? Though I think you've seen better days... | You look like you could really use my help today. | You look like you've been dragged throgh the desert backwards... | Forgive me for prying, but you're all scratched and scuffed - anything I can do?]
! label main
- I'd like to trade.
  ~ trader
  | [? That's what I like to hear! | Yes, sir! | And so would I! | That's the spirit! | You got it.]
  | p/h Open shop UI
  < main
- Can we talk.
  ~ trader
  | [? Of course, habeebti - always. | We can indeed. | What's on your mind? | I love to chat.]
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
  | - Do you know about finding a computer?
  |   ~ trader
  |   | A computer? Now there's a word you don't hear anymore.
  |   | Does Catherine want to play one of those video games from the old world I was telling her about?
  |   | You remember them, right?
  |   ~ player
  |   - Sure, games were fun.
  |     ~ trader
  |     | You betcha! Boy do I miss the internet.
  |   - They were a new artform, sadly lost.
  |     ~ trader
  |     | Whoa, were you a game developer in a past life or something?
  |   - They used similar technology to my own. I admired that.
  |     ~ trader
  |     | Indeed, there was a lot to admire - especially for a tech-head like me.
  |   ~ trader
  |   | But no, no one told me anything about a computer. Which is good, because working ones are impossible to find.
  | - Do you like androids?
  |   ~ trader
  |   | Ah, you've had a warm welcome, have you?
  |   | Listen, it's nothing personal. It's just everyone has heard the stories, you know?
  |   | It's always androids this, androids that... Like a race of servile machines could destroy the world!
  |   | No offence. It's haraa, that's what it is.
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
;; TODO: open shop UI
;; TODO: flesh out with Sahil questions relevant to current plot points - confidente, as a fellow outsider?

#| TODO:
later talks with trader:
- ask specifically about each faction member
- get into his own history more
- why don't you join up? - reveal he doesn't visit the enemy faction
|#