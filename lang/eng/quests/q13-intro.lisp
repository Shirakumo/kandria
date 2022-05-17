;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria q13-intro)
  :author "Tim White"
  :title "Meet in Engineering"
  :description "I need to meet Islay, Fi and Catherine in Engineering, probably to talk about the bomb."
  :variables (brave)
  ;; TODO need to ensure islay in engineering before this triggers, otherwise there's only Catherine there
  ;; TODO - can remove (:interact (islay :now T) and it will still trigger on arrival? To avoid duplicate map markers?
  (:eval
   (setf (walk 'islay) T)
   (setf (walk 'fi) T)
   (move-to 'eng-jack (unit 'fi)))
  (:go-to (eng-cath-2 :with islay)
   :title "Meet Islay in Engineering")
  (:interact (islay :now T)
  "
~ islay
| Here's the last of the components.
~ catherine
| Oh, hey! I didn't see you there {(nametag player)}. (:excited)I knew you'd come through for us.
| (:normal)Well, the bombs are almost ready.
~ fi
| (:unsure)Bombs? I thought there was only one bomb.
~ islay
| We now think several smaller explosives will be more effective.
~ fi
| (:annoyed)And you were going to tell me when?
~ islay
| Now.
| We want to collapse the tunnels they're using to move troops, while minimising damage to our common infrastructure.
~ fi
| Okay, well that sounds good to me.
~ catherine
| And we don't need any more components to do it this way - not now we've got this delivery.
~ islay
| Good. Finish the assembly as quickly as you can.
| (:nervous)... Well, that just leaves the question of how we plant them.
~ player
| \"Islay is looking at Fi. I think an understanding is passing between them.\"(light-gray, italic)
~ islay
| I think you're our best shot, {(nametag player)}.
~ player
- I agree.
  ~ fi
  | (:unsure)...
  | (:normal)You are the best we have for this, as much as I wish you weren't.
  ! eval (setf (var 'brave) T)
- I wouldn't have it any other way.
  ~ fi
  | (:unsure)...
  | (:normal)You are the best we have for this, as much as I wish you weren't.
  ! eval (setf (var 'brave) T)
- It's suicide, then.
  ~ fi
  | (:unsure)...
  | I hope not.
  ~ catherine
  | (:concerned)Me too.
  ~ fi
  | But you are the best we have for this, as much as I wish you weren't.
~ islay
| There's danger yes. But you can defend yourself against their soldiers.
| And I'm confident the bombs won't detonate prematurely.
~ player
- [(var 'brave) I said I'll do it.|]
  ~ islay
  | Alright. How are we looking?
- [(not (var 'brave)) It's alright. I know I don't have a choice.|]
  ~ fi
  | (:unsure)But you do.
  ~ islay
  | Alright. How are we looking?
- How confident?
  ~ islay
  | VERY confident.
  | Catherine, how are we looking?
- I trust Catherine's handiwork.
  ~ catherine
  | Thank you. I've just been doing what Islay told me.
  ~ islay
  | You're a great engineer, Catherine. They're lucky to have you- //We're// lucky to have you.
  | Speaking of which, how are we looking?
~ catherine
| They're ready. Here you go, {(nametag player)}.
~ player
| \"So I've got \"3 bombs\"(orange), each the size of a small brick.\"(light-gray, italic)
! eval (store 'item:explosive 3)
| \"They resemble plastic explosives, similar to what I've seen bomb disposal teams use.\"(light-gray, italic)
~ catherine
| Don't worry, they're shock resistant. These babies will only blow when we send the signal.
~ player
| \"There's also a handful of RF receivers attached to blasting caps - the detonators.\"(light-gray, italic)
! eval (store 'item:receiver 13)
~ catherine
| Just \"push the receivers into the explosives\"(orange) once you've planted them - \"2 in each to be sure\"(orange).
| This will prime the charge packs and activate the receivers.
| I've given you a few spares, just in case.
~ islay
| Each receiver is set to an isolated frequency, so only we can trigger them. And it should cut through the Wraw's interference.
~ fi
| Where are they being detonated?
~ islay
| (:nervous)...
~ fi
| (:unsure)Well?
~ islay
| On your \"low eastern border, beyond the Rootless hospital apartments, beneath the old Semi factory\"(orange);
| In the \"mushroom cave to the west of the old Dreamscape apartments\"(orange);
| (:nervous)In the \"flooded cave beside the pump room\"(orange).
~ fi
| (:unsure)You're not serious?
~ islay
| Our monitoring devices at the foot of your territory are already going offline.
| We need to stop the Wraw here and now.
~ fi
| And exploding our water pump is the way to do that?
~ islay
| It's our pump. We let you use it.
~ fi
| (:annoyed)...
~ islay
| And we're not destroying the pump, just the room beside it - enough to collapse the tunnels and close access.
| The water in the sunken room will help do that.
| We can repair any damage to the pump later, but it will be minimal.
~ fi
| (:unsure)It sounds like I have no choice.
~ islay
| It'll work.
~ islay
| Alright, {(nametag player)}: \"Affix all 3 bombs, then get to a safe distance\"(orange) - at least to the \"Zenith Hub\"(orange) I'd say.
| Your \"FFCS probably won't work at the bomb locations\"(orange), as they're close to the border.
| If it does, \"report in after you've planted each bomb\"(orange). If not, then we'll \"wait for your call from the Zenith Hub\"(orange).
| \"Then we'll detonate them\"(orange) in sequence, and bury the Wraw in one fell swoop.
~ catherine
| (:excited)When one goes boom, they all go boom!
~ islay
| (:normal)Remember where to \"plant them\"(orange):
| \"East of the Rootless hospital apartments, beneath the old Semi factory;\"(orange)
| \"The flooded room beside the pump;\"(orange)
| \"The mushroom cave to the west.\"(orange)
~ player
- Got it.
  ~ islay
  | Travel well.
  ~ catherine
  | Bye {(nametag player)}.
- Wish me luck.
  ~ islay
  | Good luck.
  ~ catherine
  | Good luck {(nametag player)}!
  ~ fi
  | You won't need it.
- I'll be seeing you.
  ~ fi
  | You will.
  ~ islay
  | Travel well.
  ~ catherine
  | Bye {(nametag player)}.
")

  (:eval
    :on-complete (q13-planting-bomb)))