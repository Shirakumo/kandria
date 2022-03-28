;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria q13-intro)
  :author "Tim White"
  :title "Meet in Engineering"
  :description "I need to meet Islay, Fi and Catherine in Engineering, probably to talk about the bomb."
  :variables (brave)
  ;; TODO need to ensure islay in engineering before this triggers, otherwise there's only Catherine there
  (:eval
   (setf (walk 'islay) T)
   (setf (walk 'fi) T)
   (move-to 'eng-cath (unit 'fi)))
  (:go-to (eng-cath :with islay)
   :title "Meet Islay in Engineering")
  (:interact (islay :now T)
  "
~ islay
| Here's the last of the components.
~ fi
| ... Courtesy of {#@player-nametag}.
~ catherine
| Oh, hey! I didn't see you there {#@player-nametag}. (:excited)I knew you'd come through for us.
| (:normal)Well, the bombs are almost ready.
~ fi
| Bombs? I thought there was only one bomb.
~ islay
| We now think several smaller explosives will be more effective.
| We want to collapse the tunnels they're using to move troops, ahead of where they are now, while minimising damage to our common infrastructure.
~ fi
| Okay, well that sounds good to me.
~ catherine
| And we don't need any more components to do it this way - not now we've got this delivery.
~ islay
| Good.
| (:expectant)... Well, that just leaves the question of how we plant them.
~ player
| \"Islay looks at Fi, and some kind of understanding passes between them.\"(light-gray, italic)
~ islay
| (:expectant)I think you're our best shot, {#@player-nametag}.
~ player
- I agree.
  ~ fi
  | ...
  | You are the best we have for this, much as I hate to admit it.
  ! eval (setf (var 'brave) T)
- I wouldn't have it any other way.
  ~ fi
  | ...
  | You are the best we have for this, much as I hate to admit it.
  ! eval (setf (var 'brave) T)
- A suicide mission, then.
  ~ fi
  | (:unsure)...
  | I hope not.
  ~ catherine
  | (:concerned)Me too.
  ~ fi
  | But you are the best we have for this, much as I hate to admit it.
~ islay
| There's danger yes. But you can defend yourself against their soldiers.
| And I'm confident the bombs won't detonate prematurely.
~ player
- [(var 'brave) I said I'll do it. |]
  ~ islay
  | Okay, how are we looking?
- [(not (var 'brave)) It's alright. I know I don't have a choice. |]
  ~ fi
  | (:unsure)But you do.
  ~ player
  | (:skeptical)I don't, not really.
  ~ fi
  | (:thinking)...
  ~ islay
  | Okay, how are we looking?
- How confident?
  ~ islay
  | VERY confident.
  | Catherine, how are we looking?
- I trust Catherine's handiwork.
  ~ catherine
  | I've mostly just been doing what Islay told me.
  ~ islay
  | (:happy)You're a great engineer, Catherine. They're lucky to have you- //We're// lucky to have you.
  | (:normal)Speaking of which, how are we looking?
~ catherine
| They're ready. Here you go, {#@player-nametag}.
~ player
| \"Catherine hands me \"3 parcels\"(orange), each the size of a small brick, but thankfully lighter.\"(light-gray, italic)
! eval (store 'item:explosive 3)
| \"They resemble plastic explosives, similar to what I've seen bomb disposal teams use.\"(light-gray, italic)
| \"These ones are dark red courtesy of the charge packs. I take them tentatively.\"(light-gray, italic)
~ catherine
| Don't worry, they're shock resistant. These babies will only blow when we send the signal.
~ player
| \"She also gives me a handful of RF receivers attached to blasting caps - the detonators.\"(light-gray, italic)
! eval (store 'item:receiver 13)
~ catherine
| Just push the receivers into the explosives once you've planted them - two in each to be sure. This will prime the explosive and activate the receiver.
| I've given you a few spares, just in case.
~ islay
| Each receiver is set to an isolated frequency, so only we can trigger them. And it should cut through their interference.
~ fi
| Where are they being detonated?
~ islay
| (:nervous)...
~ fi
| (:unsure)Well?
~ islay
| \"On your low eastern border, beyond the Rootless hospital apartments, beneath the old Semi factory;\"(orange)
| \"In the mushroom cave to the west of the old Dreamscape apartments;\"(orange)
| (:nervous)\"In the flooded cave beside the pump room.\"(orange)
~ fi
| ...
~ fi
| You're not serious?
~ islay
| The Wraw are already here - our monitoring devices at the foot of your territory are going offline.
| We need to stop them here and now.
~ fi
| And exploding our water pump is the way to do that?
~ islay
| It's our pump. We let you use it.
~ fi
| (:annoyed)...
~ islay
| And we're not destroying the pump, just the room beside it - enough to collapse the tunnels and close access. The water in the sunken room will help do that.
| We can repair any damage to the pump later, but it will be minimal.
~ fi
| (:unsure)It sounds like I have no choice.
~ islay
| It'll work.
~ islay
| \"Affix all 3 bombs, then get to a safe distance\"(orange) - at least to the \"Zenith Hub\"(orange) I'd say.
| Your FFCS probably won't work at the bomb locations, as they're so close to the border. But if it does, please report in after you've planted each bomb.
| If not, then we'll wait for your call once you've planted them all and you're in the Zenith Hub.
| (:nervous)All the bombs need to be positioned first, because we're detonating them in a precise sequence. We need to bury the Wraw in one fell swoop.
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
  | Bye {#@player-nametag}.
- Wish me luck.
  ~ islay
  | Good luck.
  ~ catherine
  | Good luck {#@player-nametag}!
  ~ fi
  | (:happy)You won't need it.
- I'll be seeing you.
  ~ fi
  | You will.
    ~ islay
  | Travel well.
  ~ catherine
  | Bye {#@player-nametag}.
")

  (:eval
    :on-complete (q13-planting-bomb)))