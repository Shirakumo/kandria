;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria q0-find-jack)
  :author "Tim White"
  :title "Find Jack"
  :description "Catherine is concerned about where everyone is. She wants to find someone called Jack in Engineering."
  (:go-to (eng-cath-2 :lead catherine)
  :title "Follow Catherine to Engineering and find Jack"
  )
    ;; meet Jack for the first time - Stranger already presumes this is Jack
  ;; REMARK: Maybe keep the swears out for now, or at least change them to be softer variants.
  ;; TIM REPLY: Toned some of it down. I think most swears should be okay for 16+, and they help give the gritty tone which is in the pillars. Played start of Last of Us part 2 recently, and this is very swear heavy (more than we need), but I think it works - it's more honest to the ravaged setting. Of course Last of Us is 18+, but I think that is more down to the violence than the swearing
  ;; REMARK: Maybe add a snarky greeting choice like "- Well aren't you the charmer
  ;; TIM REPLY: Hmm, not feeling this one. I think initially I want the Stranger to be on the backfoot in the conversation as well, whereas this sarcastic reply would put them on the front put. At least for the moment, they are at the mercy of Jack's ramblings
  (:interact (catherine :now T)
   "
~ jack
| (:annoyed)... Don't give me that bullshit. Where the hell have you been? And who's this?
~ catherine
| (:cheer)What do you mean? I've brought back the android. I got her working.
~ jack
| (:annoyed)Jesus... this is all we need.
~ player
- Pleased to meet you.
- Jack, I presume.
- What's your problem? I'm here to help.
~ jack
| (:shocked)Fuck me it speaks...
~ catherine
| (:disappointed)Jack, what's wrong? Talk to me.
! eval (setf (nametag (unit 'jack)) (@ jack-nametag))
~ jack
| The water has failed again, and this time I don't think it's the pump. Must be a leak somewhere.
| If we don't get it back soon we're screwed. We'll lose the whole goddamn crop.
~ catherine
| (:disappointed)Shit!... I should have been here.
~ jack
| Yeah you should.
~ catherine
| Well I'm here now. What can I do?
~ jack
| You can stay put and man Engineering. The others might need you.
| I'm goin' down there to check the supply pipe.
~ catherine
| You can't - not with your leg. And you know there's nothing I can't fix.
~ jack
| No way. It's too dangerous.
~ catherine
| (:excited)The android can come with me. You should see what she can do.
~ jack
| (:annoyed)Have you lost your mind? An android ain't no toy!
| You'd be safer walking straight into \"Wraw territory\"(red) than you would goin' anywhere with that thing.
~ player
- I can protect her.
  ~ jack
  | (:annoyed)The hell you can.
  | Androids don't exactly grow on trees 'round here. And some say you're the reason there ain't no trees any more. Or buildings.
  | Or people.
- Why are you afraid of me?
  ~ jack
  | (:annoyed)Androids don't exactly grow on trees. And some say you're the reason there ain't no trees any more. Or buildings.
  | Or people.
- You're right to be afraid.
  ~ catherine
  | (:disappointed)She's kidding... Aren't you?!
  ~ jack
  | (:shocked)I ain't so sure...
  | (:annoyed)Androids don't exactly grow on trees. And you know what they say - they're the reason there ain't no trees any more. Or buildings.
  | Or people.
~ catherine
| Look, we need to fix the water right now or we're goners. And I'm your best shot.
| Me AND my android buddy.
~ jack
| (:annoyed)Shit...
| (:normal)Alright. You'd better not let me down.
~ catherine
| (:cheer)Yes!!
~ jack
| (:annoyed)But I'm warning you android: Touch one hair on her head and I'll bury you for another thirty years!
~ catherine
| (:disappointed)Thanks \"<-Dad->\". We'll be going then.
~ jack
| Hold on Cathy - take this walkie. \"Radio if you have any trouble\"(orange).
~ catherine
| I will. And don't worry - we'll be back before you know it.
| Alright, android - \"let me know when you're ready to go\"(orange).
! eval (activate 'q1-ready)
  ")
  (:eval
   :condition (not (find-panel 'fullscreen-prompt))
   (fullscreen-prompt 'toggle-menu))
  (:eval
   :condition (not (find-panel 'fullscreen-prompt))
   (fullscreen-prompt 'interact :title 'save)))
;; The mission here is too urgent for Catherine to think, oh, let's establish the android's name