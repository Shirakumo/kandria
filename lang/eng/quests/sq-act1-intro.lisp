;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

;; TODO update this dialogue with chat options once been to the Semis in act 2? It seems reasonable Catherine would want to catch up (not Jack, and Fi's catchup is handled in the main questline); also the Semis mention Catherine by name...
(quest:define-quest (kandria sq-act1-intro)
  :author "Tim White"
  :title "Talk to Catherine"
  :description "I should catch up with Catherine, see if she needs anything doing."
  :on-activate T
  (sq-act1-catherine
   :title "Talk to Catherine in Engineering"
   :marker '(catherine 500)
   :invariant (not (complete-p 'q10-wraw))
   :on-activate T
   (:interaction talk-catherine
    :title "Hi Catherine."
    :interactable catherine
    :repeatable T
    :dialogue "
~ catherine
| [? Hey, Stranger. How are you? | Hey you, how's it going? | So, how's you?]
~ player
- Can I help out?
  < choices
- It's nice to see you again.
  ~ catherine
  | [? I wish we could spend more time together. | (:excited)It's great to see you too!]
  < continue
- I'm feeling low.
  ~ catherine
  | (:concerned)Oh no... I'm sorry. People are mean, I don't understand why.
  | Anyone that's different, they've already made up their minds about them.
  | (:normal)You just keep being you. I'll talk to them, I promise.
  < continue
- I need to go.
  ~ catherine
  | No worries. Seeya soon!

# continue
~ player
| Can I help out?
! label choices
~ catherine
? (or (and (not (active-p 'sq1-leaks)) (not (complete-p 'sq1-leaks))) (and (not (active-p 'sq2-mushrooms)) (not (complete-p 'sq2-mushrooms))) (and (not (active-p 'sq3-race))))
| | [? You are strangely perceptive... (:excited)Man I'd love to understand how your core works. | (:excited)I'm glad you asked! | (:excited)You sure can! | (:excited)I was hoping you'd ask that!]
| ? (and (not (active-p 'sq1-leaks)) (not (complete-p 'sq1-leaks)))
| | | (:normal)The water supply is leaking again, so you could help with that.
| |? (not (complete-p 'sq1-leaks))
| | | (:normal)You know about \"fixing the new leaks\"(orange) - just \"follow the red pipeline\"(orange) down like we did before.
| |?
| | | (:normal)Well, there aren't any new leaks right now, so that's fine.
| ? (<= 25 (+ (item-count 'item:mushroom-good-1) (item-count 'item:mushroom-good-2)) )
| | | (:normal)I was going to say we need some mushrooms, what with food stocks getting low.
| | | (:excited)But is it me, or are those \"mushrooms you're carrying\"(orange)?
| | | (:excited)You're very proactive, Stranger, I like that! Let's see what you've got.
| | ? (have 'item:mushroom-good-1)
| | | | (:excited)\"Flower fungus\"(red), nice! I'll get these to Fi and straight into the cooking pot.
| | | | (:normal)Apparently if you eat them raw they'll give you the skitters. One day I'll test that theory.
| | | ! eval (retrieve 'item:mushroom-good-1 T)
| | ? (have 'item:mushroom-good-2)
| | | | (:cheer)\"Rusty puffball\"(red), great! These are my favourite - I made my neckerchief from them, believe it or not.
| | | | (:normal)I weaved them together with synthetic scraps; I needed a mask so their spores wouldn't give me lung disease.
| | | ! eval (retrieve 'item:mushroom-good-2 T)
| | ? (have 'item:mushroom-bad-1)
| | | | (:disappointed)Oh, \"black cap\"(red)... Not a lot I can do with poisonous ones.
| | | | (:normal)Don't worry, I'll burn them later - don't want anyone eating them by accident.
| | | ! eval (retrieve 'item:mushroom-bad-1 T)
| |  
| | | (:normal)You know, it might not seem like much, but hauls like these could be the difference between us making it and not making it.
| | | We get birds and fish when we can too, but they're harder to catch. Mushrooms don't run away.
| | | (:cheer)We owe you big time. Here, \"take these parts\"(orange), you've definitely earned them.
| | ! eval (store 'item:parts 300)
| | | (:normal)If you \"find any more mushrooms\"(orange), make sure you grab them.
| | | If we don't need them, the least you could do is \"trade them with Sahil\"(orange).
| | ? (not (complete-p 'sq2-mushrooms))
| | | ! eval (complete 'sq2-mushrooms)
| |? (and (not (active-p 'sq2-mushrooms)) (not (complete-p 'sq2-mushrooms)))
| | | (:normal)With food stocks getting low, Fi wants to forage for more mushrooms.
| |? (not (complete-p 'sq2-mushrooms))
| | | (:normal)You already know about \"gathering the mushrooms\"(orange) - search around, especially \"below ground\"(orange) where the soil is rich.
| |?
| | | (:normal)We've got enough mushrooms for the time being, so don't worry about that.
| ? (and (not (active-p 'sq3-race)) (not (complete-p 'sq3-race)))
| | | (:excited)Oh, I've been speaking with my friends - we're all eager to see what you're really capable of.
| | | How do time trial sweepstakes sound, eh?
| |?
| | | (:excited)Remember, you can tell me later if you want to race in the time trials too.
| ! label task-choice
| ~ player
| - [(and (not (active-p 'sq1-leaks)) (not (complete-p 'sq1-leaks))) (Fix the leaks)|]
|   ~ catherine
|   | (:excited)Great! Hopefully the saboteurs aren't back - but you know what to do if they are.
|   | (:normal)Just \"follow the red pipeline\"(orange) down like we did before.
|   | Androids can weld from their fingertips, right?
|   ~ player
|   - I can do that?
|     ~ catherine
|     | I'm pretty sure you can. Try it out.
|     ~ player
|     | \"I'm not certain how, but when I think about it, a small welding torch ignites from the index finger on my right hand.\"(light-gray, italic)
|     | \"I keep the intensity low, so as not to blind us.\"(light-gray, italic)
|     ~ catherine
|     | (:excited)See!
|     ~ player
|     - Cool!
|     - I guess I forgot I could do that.
|       ~ catherine
|       | Don't worry.
|     - Need a light?
|       ~ catherine
|       | Sorry, I don't smoke.
|   - That's right.
|     ~ catherine
|     | (:excited)Can I see?
|     ~ player
|     | \"I ignite the small welding torch from the index finger on my right hand.\"(light-gray, italic)
|     | \"I keep the intensity low, so as not to blind us.\"(light-gray, italic)
|     ~ catherine
|     | (:excited)That's so cool!
|   - And where did you hear that?
|     ~ catherine
|     | It's just one of those things I know about androids. (:excited)Why? Is it a big secret?
|     | Let me see!
|     ~ player
|     | \"I ignite the small welding torch from the index finger on my right hand.\"(light-gray, italic)
|     | \"I keep the intensity low, so as not to blind us.\"(light-gray, italic)
|     ~ catherine
|     | (:excited)That's so cool!
|   | (:normal)Okay, I think you're good to go.
|   | Based on the pressure drop, these leaks \"aren't too far away\"(orange), so you'll be within radio range.
|   | You want to take a walkie, or just use your FFCS? - It will work with our radios.
|   ~ player
|   - I'll take a walkie.
|     ~ catherine
|     | You got it - take this one.
|     ! eval (store 'item:walkie-talkie 1)
|   - My FFCS will suffice.
|     ~ catherine
|     | You got it.
|   ~ catherine
|   | \"Let me know what you find\"(orange). Good luck!
|   ~ player
|   | \"My FFCS indicates \"3 leaks\"(orange), close to the surface as Catherine said.\"(light-gray, italic)
|   ! eval (activate 'sq1-leaks)
|   < task-choice
| - [(and (not (active-p 'sq2-mushrooms)) (not (complete-p 'sq2-mushrooms))) (Forage for mushrooms)|]
|   ~ catherine
|   | (:excited)Awesome! They grow in the \"caves beneath the camp\"(orange), in the dim light and moisture there.
|   | (:normal)Edible mushrooms like the \"flower fungus\"(orange) can sustain us even if the crop fails.
|   | They're all we used to eat before we moved to the surface.
|   | Fibrous ones like the \"rusty puffball\"(orange) can be used to weave clothing. 
|   | We combine them with recycled synthetic clothes from the old world - like yours - and pelts from animals we hunt.
|   | Just don't breathe in their spores - though I doubt they will affect you.
|   | Other kinds are deadly poisonous, like the \"black cap - avoid those if you can\"(orange).
|   | I think \"25 puffballs or flower fungus\"(orange) should suffice for now. (:excited)Happy mushrooming, Stranger!
|   ! eval (activate 'sq2-mushrooms)
|   < task-choice
| - [(not (active-p 'sq3-race)) (Time trials)|]
|   ~ catherine
|   | (:excited)Heh, I knew that would intrigue you. I can't wait to see what an almost-fully-functional android can do!
|   | (:normal)We've planted some old-world \"beer cans for you to find and return\"(orange).
|   | I'll \"record your times\"(orange) for posterity - this is anthropology! The faster you are, the more parts you'll get from the sweepstake.
|   | Once you've \"completed one I can tell you about the next route\"(orange). Them's the rules.
|   | (:excited)Just \"tell me when you want to start\"(orange), and we'll get this show on the road.
|   | (:cheer)This is sooo exciting!
|   ! eval (activate 'sq3-race)
|   < task-choice
| - (Nothing for now)
|   ~ catherine
|   | (:normal)That's cool. Just \"let me know if you want something to do\"(orange).
|   < end
|?
| ~ catherine
| | (:disappointed)I wish I had something for you, but there's nothing right now. (:normal)That's a first around here!
! label end
~ player
- I'll be going.
  ~ catherine
  | You take it easy. See you soon.
- How are you Catherine?
  ~ catherine
  | Me? Oh, same as usual. (:concerned)Jack's as overbearing as always. But I can take it.
  | (:normal)I think if I can just keep my head down and keep doing something, then I won't worry about the future. Or the past.
  | Just take it day by day, you know?
  | I should get back to my work. Hope to talk soon!
")))
;; TODO "weld from fingertips" too implausible, or Catherine just wouldn't know that?
;; "We get birds and fish when we can too" meaning they hunt them themselves now they can, living on the surface; but they also trade them with sahil from time to time
