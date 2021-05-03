;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-task (kandria q1-water task-return-home)
  :title "Return to camp and talk to Catherine"
  :condition all-complete
  :on-activate (catherine-return)
  :on-complete NIL

  ;; REMARK: I don't like the examination part. I don't think it's reasonable to assume that Catherine
  ;;         would know how to scan through those logs, given that she didn't even grow up before the calamity,
  ;;         and there's very little if any information on them out there, let alone how to maintain them.
  ;;         I think it would be much more reasonable if Catherine starts looking around for a way to interface
  ;;         with her, perhaps referencing something like "If we had a functioning computer maybe we could
  ;;         connect to her through some kinda data port..." but then fails to even find such a port.
  ;;         
  ;;         As for how she reactivated the stranger, I think something simple like applying pressure on her
  ;;         earlobe would work, rather than requiring any deep interfacing, and the way she discovered that
  ;;         was mostly dumb luck and curiosity, more than anything.
  ;; TIM REPLY - good points, adapted as directed
  (:interaction catherine-return
   :interactable catherine-group
   :dialogue "
~ catherine
| Hey, Stranger - see, what'd I tell you?
| Jack here didn't think you'd come back.
~ jack
| (:annoyed)This don't prove a thing.
~ fi
| You've done well, Catherine. An android is a great asset for us.
| Assuming it can be trusted.
~ catherine
| (:concerned)I don't understand...
~ fi
| Is it not coincidental that you discovered it at the same time our water supply was sabotaged?
~ catherine
| But we saw the rogues - they were dismantling the pump!
~ jack
| Maybe this android can control them? Did you think of that?
~ catherine
| (:concerned)...
| (:concerned)Androids did have FFCS - er, far-field comms systems.
| I guess something like that could penetrate deeper underground than our radios.
| (:normal)But no, it's not that. She was offline for decades - there's no way she could have done that.
| And since I brought her online, she's been with me the whole time! She can't have done this.
~ jack
| But what do we really know about androids, Cathy? Fuck all, that's what.
~ catherine
| Well, ask her. Have you betrayed us, Stranger?
~ player
- No I have not.
  ~ catherine
  | There, see.
  ~ fi
  | (:unsure)Alright, well - let's hope it's telling the truth. If not, then the Wraw know our location, and their hunting packs are already on their way.
- I don't think I have.
  ~ catherine
  | Her memories are all muddled from before I brought her online. She hasn't, trust me.
  ~ fi
  | (:unsure)Alright, well - let's hope that's true. If not, then the Wraw know our location, and their hunting packs are already on their way.
- I suppose I could have.
  ~ catherine
  | She doesn't know what she's saying - her memories are all screwed up till the point I brought her online.
  ~ fi
  | (:unsure)Alright - it's hardly conclusive, but for now we'd better hope Catherine's right.
  | If not, then the Wraw know our location, and their hunting packs are already on their way.
~ jack
| (:annoyed)Jesus, Fi... you're just gonna take that at face value?
~ fi
| What choice do I have?
~ jack
| Examine the thing, find out for sure.
~ fi
| Catherine, don't androids have a black box? Could that show us if the... FFCS was it, was active lately?
~ catherine
| Well... I guess we'd need to find some kind of interface port.
| Oh, and we'd need a working computer, which we don't have.
| (:disappointed)Anyway, even if we did, don't you think you should ask HER if taking her apart is okay?
~ fi
| You're right, Catherine.
| I'm sorry... Stranger, wasn't it?
~ jack
| (:annoyed)...
~ fi
| Would you permit Catherine to examine you, assuming we can source a computer?
~ player
- I'd rather she didn't.
  ~ fi
  | It's your choice, of course.
  ~ jack
  | (:annoyed)Really? You're gonna let this thing call the shots?
  ~ fi
  | This \"thing\" is a person, Jack. And I expect you to treat her as such.
  | I trust Catherine's judgement. For now, Stranger is our guest.
  | Still, a computer may be useful to help maintain Stranger.
  | Jack, speak with Sahil when he arrives, see what he can do for us.
  ~ jack
  | (:annoyed)If you insist.
- Sure, why not.
  ~ fi
  | Good. Jack, speak with Sahil when he arrives, see what he can do for us.
  ~ jack
  | (:annoyed)If you insist.
- As long as I'm still online afterwards.
  ~ catherine
  | Don't worry, I wouldn't let them switch you off.
  ~ fi
  | That's settled then. Jack, speak with Sahil when he arrives, see what he can do for us.
  ~ jack
  | (:annoyed)If you insist.
~ fi
| (:annoyed)But irrespective of all this, I am certain that the Wraw are our attackers, one way or another.
| Which means they're close to discovering our location.
| (:normal)I must consider our next course of action.
~ catherine
| Well, if there's nothing else, I'll see you both later.
| Hey Stranger, wait here - I want to talk.
~ fi
| Sayonara Catherine, Stranger.
~ jack
| You take care, Cathy.
! eval (activate 'catherine-trader)
! eval (setf (walk 'fi) T)
! eval (move-to 'fi-farm (unit 'fi))
---
! eval (setf (walk 'jack) T)
! eval (move-to 'eng-jack (unit 'jack))
")
  ;; sayonara = goodbye (Japanese)
  ;; TODO catherine pleading - But no, it's not that. She was offline for decades - there's no way she could have done that.
  ;; and others
  ;; TODO fi thinking - Catherine, don't androids have a black box?
  ;; TODO fi firm -  This \"thing\" is a person, Jack. And I expect you to treat her as such.

  ;; TODO future quest/plot point: find a working computer
  #| TODO temp removal of moving jack and fi, as causes crash
  ! eval (move-to 'fi-farm (unit 'fi))  ; ;
  ! eval (move-to 'eng-jack (unit 'jack)) ; ;
  ! eval (setf (location 'fi) 'fi-farm) ; ;
  ! eval (setf (location 'jack) 'eng-jack) ; ;
  |#

  #| DIALOGUE REMOVED FOR THE EXAMINATION - COULD BE REUSED LATER
  ~ fi                                  ; ;
  | Thank you. Catherine, if you could proceed. ; ;
  ~ catherine                           ; ;
  | This won't hurt a bit.              ; ;
  ~ player                              ; ;
  | //Catherine takes my right forearm and opens up an access panel. A strange sensation - I can no longer feel my skin in that area.// ; ;
  ~ catherine                           ; ;
  | Nope, just like I said: her log is clean. ; ;
  | If those rogue's were remote-controlled, the signal didn't come from her. ; ;
  ~ jack                                ; ;
  | You sure, Cathy?                    ; ;
  ~ catherine                           ; ;
  | Positive.                           ; ;
  ~ fi                                  ; ;
  | I am satisfied, for now. Thank you Catherine, Stranger. ; ;
  |#
  (:interaction catherine-trader
   :interactable catherine
   :dialogue "
~ catherine
| Urgh, adults. I mean, technically I'm an adult, but not like those dinosaurs.
| Oh! I almost forgot: It's our way to gift something to those that help us out.
| Since those two aren't likely to be feeling generous anytime soon, I'll give you these parts.
! eval (store 'parts 20)
| It's not much, but you can trade them for things you might want. Or you will be able to once Sahil gets here.
| (:concerned)He's overdue, which is not like him at all. Maybe those rogues scared him off.
| (:normal)Anyway, don't worry about them. They'll soon see what I see - a big friendly badass who can protect us.
| Well, I've got work to do. I think Fi might want a private word with you.
| Just something about the way she was looking at you.
| Knowing Jack he'll have something for you as well - if only a mouthful of abuse.
| You take it easy. Seeya later!
! eval (move-to 'eng-cath (unit 'catherine))
! eval (activate 'q2-intro)
! eval (activate 'q3-intro)
"))
;; TODO Catherine contented - Anyway, don't worry about them.

;; TODO: inventory item acquired onscreen pop-up / notification
;; Let's not have catherine go to trader as well - player needs some time away from Catherine (which helps by delaying the trader arrive till after quest 2/3)

;; Catherine got the android online, so she must know the basics about them
;; also, don't want to have to go to the lab and do this, as too much travelling back and fourth (fetch quests) - and besides, player could run off

#| todo too much exposition too soon... This should be at the end of Act 1?...
| Indeed, allow me to formally welcome you to the Noka.
| We don't have much, but we hope you'll be comfortable here.
| Just please understand that times are hard, and
| And please bear with us - it will be more difficult for some of us than others to have an android around the camp.
|#


;; TODO: Explain Wraw yet? Hold off for quest 2/3? Say they have androids for parts/slave labour? Use them as electronic power supplies?)
