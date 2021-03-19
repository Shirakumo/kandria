(:name sq-act1-catherine
 :title "Talk to Catherine"
 :description NIL
 :invariant T
 :condition NIL
 :on-activate (talk-catherine)
 :on-complete NIL
)

(quest:interaction :name talk-catherine :title "Can we talk?" :interactable catherine :repeatable T :dialogue "
~ catherine
| [? Hey Stranger! How are you? | Heya! How's it going? | Stranger! How's you?]
~ player
- Can I help you with anything?
  < choices
- I'm good thank you.
  ~ catherine
  | Glad to hear it.
  < continue
- It's nice to see you again.
  ~ catherine
  | [? I wish we could spend more time together. | It's great to see you too.]
  < continue
- I'm feeling low.
  ~ catherine
  | Oh no... I'm sorry. People are mean, I don't understand why.
  | Anyone that's different, they've already made up their minds about them.
  | You just keep being you. I'll talk to them.
  < continue
# continue
~ player
| Can I help you with anything?
! label choices
~ catherine
? (or (and (not (active-p 'sq1-leaks)) (not (complete-p 'sq1-leaks))) (and (not (active-p 'sq2-mushrooms)) (not (complete-p 'sq2-mushrooms))) (and (not (active-p 'sq3-race))))
| | [? You are strangely perceptive... Man I'd love to understand how your core works. | I'm glad you asked! | You sure can! | I was hoping you'd say that.]
| ? (and (not (active-p 'sq1-leaks)) (not (complete-p 'sq1-leaks)))
| | | The water supply is leaking again, so you could help with that.
| |? (not (complete-p 'sq1-leaks))
| | | You know about fixing the new leaks.
| |?
| | | Well, there aren't any new leaks right now, so that's fine.
| ? (and (not (active-p 'sq2-mushrooms)) (not (complete-p 'sq2-mushrooms)))
| | | With food stocks getting low, we really could do with foraging for more mushrooms.
| |? (not (complete-p 'sq2-mushrooms))
| | | You already know about gathering the mushrooms.
| |?
| | | We've got enough mushrooms for the time being, so don't worry about that.
|   
| | [(not (active-p 'sq3-race)) Oh, I've been talking to my friends - we're all eager to see what you're really capable of. How do time trial sweepstakes sound, eh? | Remember, any time you want to race we've got the time trial sweepstake too!]
| ~ player
| - [(and (not (active-p 'sq1-leaks)) (not (complete-p 'sq1-leaks))) leaks begin|]
|   ~ catherine
|   | Things are leaking again... Saboteurs back?...
|   | Bye
|   ! eval (activate 'sq1-leaks)
| - [(and (not (active-p 'sq2-mushrooms)) (not (complete-p 'sq2-mushrooms))) mushrooms begin|]
|   ~ catherine
|   | Food running low. Mushrooms edible and can sustain us. All we used to eat before we moved to the surface.
|   ! eval (activate 'sq2-mushrooms)
| - [(not (active-p 'sq3-race)) race begin|]
|   ~ catherine
|   | So you want to race? Let me think about some routes and plant some objects. Come back soon.
|   ! eval (activate 'sq3-race)
| - I'll pass for now.
|   ~ catherine
|   | That's cool. Just let me know if you want something to do.
|?
| ~ catherine
| | I wish I had something for you, but there's nothing right now. That's a first round here!
~ player 
- I'll get going.
  ~ catherine
  | You take it easy. See you soon.
- How are you Catherine?
  ~ catherine
  | Me? Oh, same as usual. Jack's as overbearing as always. But you know me, there's always a bright side.
  | I think if I can just keep my head down and keep doing something, then I won't worry about the future. Or the past.
  | Just take it day by day, you know?
  | Look, I should get back to my work. Hope to see you soon!
")
; todo complete this quest manually when final side quest is complete? Or whenever race is not meant to be available anymore
; | | [(and (not (active-p 'sq2-mushrooms)) (not (complete-p 'sq2-mushrooms))) With food stocks getting low, we really could do with foraging for more mushrooms. | We've got enough mushrooms for the time being, so don't worry about that.]
#|
  
  

|#