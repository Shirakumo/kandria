(:name sq-act1-catherine
 :title "Talk to Catherine"
 :description NIL
 :invariant T
 :condition NIL
 :on-activate (talk-catherine)
 :on-complete NIL)

(quest:interaction :name talk-catherine :title "Talk to Catherine" :interactable catherine :repeatable T :dialogue "
~ catherine
| [? Hey, Stranger. How are you? | Hey you, how's it going? | So, how's you?]
~ player
- Can I help you with anything?
  < choices
- I'm good thank you.
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
| ? (and (not (active-p 'sq3-race)) (not (complete-p 'sq3-race)))
| | | Oh, I've been talking to my friends - we're all eager to see what you're really capable of. How do time trial sweepstakes sound, eh?
| |?
| | | Remember, any time you want to race we've got the time trial sweepstake too!
| ~ player
| - [(and (not (active-p 'sq1-leaks)) (not (complete-p 'sq1-leaks))) //Fix the leaks//|]
|   ~ catherine
|   | Great! Hopefully the saboteurs aren't back - but you know what to do if they are.
|   | Just follow the pipe down like we did before. And you can already weld from your fingertips, right? So you should be good to go.
|   | These leaks aren't too far away, so you'll be within radio range. You want to take a walkie, or just use your FFCS?
|   - I'll take a walkie.
|     ~ catherine
|     | You got it - take this one.
|     ! eval (store 'walkie-talkie 1)
|   - My FFCS will suffice.
|     ~ catherine
|     | You got it.
|   ~ catherine
|   | Let me know what you find. Good luck!
|   ! eval (activate 'sq1-leaks)
| - [(and (not (active-p 'sq2-mushrooms)) (not (complete-p 'sq2-mushrooms))) //Forage for mushrooms//|]
|   ~ catherine
|   | Awesome! They grow in the caves below the settlement, in the dim light and moisture there.
|   | Edible mushrooms like the flower fungus can sustain us even if the crop fails. They're all we used to eat before we moved to the surface.
|   | Fibrous ones like the rusty puffball can be used to weave clothing. 
|   | We combine them with recycled synthetic clothes from the old world - like yours - and scraps of leather from animals we hunt.
|   | Just don't breathe in their spores - though I guess that won't affect you.
|   | Other kinds are deadly poisonous though, like the black knight. Avoid those if you can.
|   | Happy mushrooming, Stranger!
|   ! eval (activate 'sq2-mushrooms)
| - [(not (active-p 'sq3-race)) //Time trials//|]
|   ~ catherine
|   | Heh, I knew that would intrigue you. I can't wait to see what an almost fully-functional android can do in anger!
|   | I'll record your results for posterity too! This is anthropology!
|   | Come back soon, once I've talked to the gang. We need to plan the routes, and organise the sweepstake.
|   | This is sooo exciting!
|   ! eval (activate 'sq3-race)
| - //Nothing for now//
|   ~ catherine
|   | That's cool. Just let me know if you want something to do.
|?
| ~ catherine
| | I wish I had something for you, but there's nothing right now. That's a first round here!
- I'll get going.
  ~ catherine
  | You take it easy. See you soon.
- How are you Catherine?
  ~ catherine
  | Me? Oh, same as usual. Jack's as overbearing as always. But you know me - there's always a bright side.
  | I think if I can just keep my head down and keep doing something, then I won't worry about the future. Or the past.
  | Just take it day by day, you know?
  | Look, I should get back to my work. Hope to see you soon!
")
;; TODO: complete this quest manually when final side quest is complete? Or whenever race is not meant to be available anymore
#|
  
  

|#

#|
| |? (or (active-p 'race-one) (active-p 'race-two) (active-p 'race-three) (active-p 'race-four))
| | | Don't forget your on a time trial right now - the clock is ticking!
|#
