;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria q0-settlement-emergency)
  :author "Tim White"
  :title "Emergency?"
  :description "Something seems amiss in this settlement."
  ;; TODO: the last player emotion in the choices is the one that will render; have it change per highlighted choice?
  ;; TODO: replace (Lie) with [Lie] as per RPG convention, and to save parenthetical expressions for asides - currently square brackets not rendering correctly though
  ;; REMARK: ^ Does \[Lie\] not work?
  (:interact (catherine)
   :title "Talk to Catherine"
   "
~ catherine
| (:cheer)Tada! Here we are!
| What do you think...?
~ player
- It's a ruined city.
  ~ catherine
  | (:excited)Yep! It's home.
- It's nice.
  ~ catherine
  | (:excited)I knew you'd love it!
- (Lie) It's nice.
  ~ catherine
  | (:excited)I knew you'd love it!
- You live here?
  ~ catherine
  | (:excited)Yep! Pretty amazing, huh?
~ catherine
| And come look at this - I guarantee you won't have ever seen anything like it!
  ")
  (:go-to (farm-view :lead catherine)
  :title "Follow Catherine"
   "~ catherine
| (:normal)Living on the surface is even harder than living in the caves.
  ")
  ;; TODO: force complete 'walk to ensure this whole task completes, even if walk-talk interrupted?
  ;; REMARK: It's confusing that you don't talk to catherine and instead have to find some hidden trigger volume.
  ;;         It would be better if this was activated on catherine as soon as the player walks into the farm
  ;;         by using a story-trigger, or even just directly activating it via an interaction-trigger.
  (:interact (catherine :now T)
   "~ catherine
| (:excited)What'd I tell you? Amazing, right?!
~ player
- What I am looking at?
  ~ catherine
  | (:excited)They're crops! We're growing crops - in the desert!
  | (:normal)...
  | (:disappointed)Well don't look too excited. This is a real feat, believe me.
- How did you manage this?
  ~ catherine
  | (:normal)Don't ask me - I'm just an engineer. Though I did help install the irrigation.
  | Needless to say, growing crops in the desert isn't easy.
  | (:excited)Heh, I knew you'd be impressed.
- I've seen these before. Lots of times.
  ~ catherine
  | (:normal)Oh...? From the old world? Do you remember? I bet they had loads of plantations.
  ~ player
  | (:thinking)I can't recall exactly. But I know I've seen crops like these before.  
  ~ catherine
  | (:excited)Whoa, that's so cool. I wish I could have seen that too.
~ catherine
| (:concerned)Erm... hang on a second. Where is everyone?
| This isn't the welcome I was expecting.
~ player
- Is something wrong?
  ~ catherine
  | (:concerned)Well, I just reactivated an android...
  | I thought they'd all be here to see you.
- What were you expecting?
  ~ catherine
  | (:concerned)I don't know...
  | Though I just reactivated an android... I guess I thought everyone would be here to see you.
- Is it me?
  ~ catherine
  | (:concerned)You?... No of course not.
  | Well... I mean, I think you're amazing - a working android from the old world!
  | But not everyone has fond tales to tell about androids, I guess. Their loss though.
~ catherine
| (:concerned)We'd better find Jack. He'll be in Engineering.
 ")
;; learn Jack's name for the first time
;; TODO catherine confused: Erm... hang on a second. Where is everyone?
  (:go-to (jack :lead catherine)
  :title "Find Jack in Engineering"  
  )
    ;; meet Jack for the first time - Stranger already presumes this is Jack
  ;; REMARK: Maybe keep the swears out for now, or at least change them to be softer variants.
  ;; TIM REPLY: Toned some of it down. I think most swears should be okay for 16+, and they help give the gritty tone which is in the pillars. Played start of Last of Us part 2 recently, and this is very swear heavy (more than we need), but I think it works - it's more honest to the ravaged setting. Of course Last of Us is 18+, but I think that is more down to the violence than the swearing
  ;; REMARK: Maybe add a snarky greeting choice like "- Well aren't you the charmer
  ;; TIM REPLY: Hmm, not feeling this one. I think initially I want the Stranger to be on the backfoot in the conversation as well, whereas this sarcastic reply would put them on the front put. At least for the moment, they are at the mercy of Jack's ramblings
  (:interact (jack :now T)
   :on-complete (q1-ready)
   "~ jack
| (:annoyed)... Don't give me that bullshit. Where the hell have you been? And who's this?
~ catherine
| (:cheer)What do you mean? I've brought back the android... I got her working!
~ jack
| (:annoyed)Jesus... this is all we need.
~ player
- Pleased to meet you.
- Jack, I presume.
- What's your problem? I'm here to help.
~ jack
| (:shocked)Fuck me it speaks... Though what the hell is that accent?
~ Catherine
| (:disappointed)Jack, what's wrong? Talk to me.
~ Jack
| The water has failed again, and this time I don't think it's the pump. Must be a leak somewhere.
| If we don't get it back ASAP we're screwed. We'll lose the whole goddamn crop.
~ Catherine
| (:disappointed)Shit!... I should have been here.
~ jack
| Yeah you should.
~ catherine
| Well I'm here now. What can I do?
~ jack
| You can stay put and man Engineering. Fi and the others might need you.
| I'm goin' down there to check the supply pipe.
~ catherine
| You can't - not with your leg. And you know there's nothing I can't fix. Let me go.
~ jack
| No way. It's too dangerous.
~ catherine
| (:excited)The android can come with me. You should see what she can do! She's got a freakin' sword!
~ jack
| (:annoyed)A sword?... Have you lost your goddamn mind? An android ain't no toy!
| You'd be safer walking straight into Wraw territory than you would goin' anywhere with that thing.
~ player
- I can protect her.
  ~ jack
  | (:annoyed)The hell you can.
- Why are you afraid of me?
  ~ jack
  | (:annoyed)Androids don't exactly grow on trees. And some say you're the reason there ain't no trees anymore. Or buildings.
  | Or people.
- You're right to be afraid.
  ~ catherine
  | (:disappointed)She's kidding... Aren't you?!
~ catherine
| Look, we need to fix the water right now or we're goners. And I'm your best shot.
| Me AND my android buddy.
~ jack
| (:annoyed)Shit...
| (:normal)Alright. You'd better not let me down.
~ catherine
| (:cheer)Yes!!
~ jack
| (:annoyed)But I'm warning you android: Touch one hair on her head and I'll bury you for another fifty years!
~ catherine
| (:disappointed)Thanks \"Dad\". Well, we'll be going.
~ jack
| Hold on Cathy - take this walkie. Radio if you have any trouble.
~ catherine
| I will. And don't worry - we'll be back ASAP.
| Alright, android - let me know when you're ready to go.
  ")
)

;; TODO catherine shocked  Shit!... I should have been here.
;; She's kidding... Aren't you?!

#|
Tutorial/prologue mission beats that have occurred before this scene:
Alex planted the android there on behalf of the enemy faction (traitor), knowing that Catherine could repair it for them
Rogue robots on behalf of the enemy faction then tried to ambush and claim the android, but you beat them off
Catherine, non-the-wiser to Alex's betrayal, returns to the settlement with the android
(Meanwhile Alex has gone off doing hunter duties)
(The enemy faction timed the android planting with their sabotage of the water pipes, so that Catherine would be away at a critical time)
(Catherine has determined android is a "she")
(Catherine introduced herself by name, and established that the android doesn't have a name)
(Catherine learns the stranger doesn't have a home)
|#
