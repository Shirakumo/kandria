(:name find-jack
 :title "Find Jack in Engineering"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (talk-jack)
 :on-complete (q1-water))
 
;; meet Jack for the first time - Stranger already presumes this is Jack
;; REMARK: Maybe keep the swears out for now, or at least change them to be softer variants.
;;; TIM REPLY: Toned some of it down. I think most swears should be okay for 16+, and they help give the gritty tone which is in the pillars. Played start of Last of Us part 2 recently, and this is very swear heavy (more than we need), but I think it works - it's more honest to the ravaged setting. Of course Last of Us is 18+, but I think that is more down to the violence than the swearing
;; REMARK: Maybe add a snarky greeting choice like "- Well aren't you the charmer
;; TIM REPLY: Hmm, not feeling this one. I think initially I want the Stranger to be on the backfoot in the conversation as well, whereas this sarcastic reply would put them on the front put. At least for the moment, they are at the mercy of Jack's ramblings
(quest:interaction :name talk-jack :interactable jack :dialogue "
~ jack
| (:annoyed) ... Don't give me that bullshit. Where the hell have you been? And who's this?
~ catherine
| (:cheer) What do you mean? I've brought back the android... I got her working!
~ jack
| (:annoyed) Jesus... this is all we need.
~ player
- Pleased to meet you.
- Jack, I presume.
- What's your problem? I'm here to help.
~ jack
| (:shocked) Fuck me it speaks... Though what the hell is that accent?
~ Catherine
| (:disappointed) Jack, what's wrong? Talk to me.
~ Jack
| The water has failed again, and this time I don't think it's the pump. Must be a leak somewhere.
| If we don't get it back ASAP we're screwed. We'll lose the whole goddamn crop.
~ Catherine
| (:disappointed) Shit!... I should have been here.
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
| (:excited) The android can come with me. You should see what she can do! She's got a freakin' sword!
~ jack
| (:annoyed) A sword?... Have you lost your goddamn mind? An android ain't no toy!
| You'd be safer walking unarmed straight into Wraw territory than you would goin' anywhere with that thing.
~ player
- I can protect her.
  ~ jack
  | (:annoyed) The hell you can.
- Why are you afraid of me?
  ~ jack
  | (:annoyed) Androids don't exactly grow on trees. And some say you're the reason there aren't no trees anymore. Or buildings.
  | Or people.
- You're right to be afraid.
  ~ catherine
  | (:disappointed) She's kidding... Aren't you?!
~ catherine
| Look, we need to fix the water right now or we're goners. And I'm your best shot.
| Me AND my android buddy.
~ jack
| (:annoyed) Shit...
| (:normal) Alright. You'd better not let me down.
~ catherine
| (:cheer) Yes!!
~ jack
| (:annoyed) But I'm warning you android: Touch one hair on her head and I'll bury you for another fifty years!
~ catherine
| (:disappointed) Thanks \"Dad\". Alright, let's go.
~ jack
| Hold on Cathy - take this walkie. Radio if you have any trouble.
~ catherine
| I will. And don't worry - we'll be back ASAP.
")
;; TODO catherine shocked  Shit!... I should have been here.
;; She's kidding... Aren't you?!


#| DIALOGUE REMOVED FOR TESTING SPEED - talk-jack



|#
