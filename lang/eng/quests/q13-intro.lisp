;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(define-sequence-quest (kandria q13-intro)
  :author "Tim White"
  :title "Meet in Engineering"
  :description "I need to meet Islay, Fi and Catherine in Engineering, probably to talk about the bomb."
  :variables (brave)
  ;; TODO only allow interact when Islay has arrived in Engineering
  (:go-to (eng-cath :with islay)
   :title "Meet Islay and Fi in Engineering")
  (:interact (islay :now T)
  "
~ islay
| Here's the last of the components.
~ fi
| ... Courtesy of {#@player-nametag}.
~ catherine
| Oh, hey! I didn't see you there. (:excited)I knew you'd come through for us.
| (:normal)Well, the bombs are almost ready.
~ fi
| Bombs? I thought there was only one bomb.
~ islay
| We now think several smaller explosives will be more effective.
| We want to collapse the tunnels they're using to move troops, ahead of where they are now, while minimising damage to our common infrastructure.
~ fi
| Okay, well that sounds good to me.
~ catherine
| And we don't need any more components to do it this way - not now we have this delivery from {#@player-nametag}.
~ islay
| (:expectant)Good...
| ... Well, that just leaves the question of how we plant them.
~ player
| \"//Islay looks at Fi, and some kind of understanding passes between them.//\"(light-gray)
~ islay
| (:expectant)I think you're our best shot, {#@player-nametag}.
~ player
- I agree.
  ~ fi
  | ...
  | You're the best we have for this, much as I hate to admit it.
  ! eval (setf (var 'brave) T)
- I wouldn't have it any other way.
  ~ fi
  | ...
  | You're the best we have for this, much as I hate to admit it.
  ! eval (setf (var 'brave) T)
- A suicide mission, then.
  ~ fi
  | ...
  | I hope not.
  ~ catherine
  | (:concerned)Me too.
  | But you're the best we have for this, much as I hate to admit it.
~ islay
| There's danger yes. But you can fight their soldiers.
| And I'm confident the bombs won't detonate prematurely.
~ player
- [(var 'brave) I said I'll do it. |]
  ~ islay
  | Okay, how are we looking?
- [(not (var 'brave)) It's alright. I know I don't have a choice. |]
  ~ fi
  | But you do.
  ~ player
  | I don't, not really.
  ~ fi
  | ...
  ~ islay
  | Okay, how are we looking?
- I trust your handiwork.
  ~ islay
  | Thank you.
  | Okay, how are we looking?
- I trust Catherine's handiwork.
  ~ islay
  | (:unhappy)...
  ~ catherine
  | I've mostly just been doing what Islay told me.
  ~ islay
  | (:happy)You're a great engineer, Catherine. They're lucky to have you.
  | (:normal)Speaking of which, how are we looking?
~ catherine
| They're ready. Here you go, {#@player-nametag}.
~ player
| \"//Catherine hands me \"3 small parcels\"(orange), each the size of a small brick, but thankfully lighter.//\"(light-gray)
! eval (store 'item:explosive 3)
| \"//They resemble plastic explosives, similar to what I'd seen bomb disposal teams use.//\"(light-gray)
| \"//These ones are dark red courtesy of the charge packs. I take them tentatively.//\"(light-gray)
~ catherine
| Don't worry, they're shock resistant. These babies will only blow when we send the signal.
| \"//Then she gives me a handful of RF receivers attached to blasting caps - the detonators.//\"(light-gray)
! eval (store 'item:receiver 13)
~ catherine
| Just push these into the explosives when they're in position - two in each to be sure.
| I've given you a few spares as well, just in case.
~ islay
| Each receiver is set to an isolated frequency, so only we can trigger them.
~ catherine
| (:excited)When one goes boom, they all go!
~ fi
| And where are they being detonated?
~ islay
| (:nervous)...
~ fi
| (:annoyed)Well?
~ islay
| \"The base of the old Semi factory to the east, near to your seed cache.\"(orange)
| \"The mushroom cave to the west of the old Dreamscape apartments.\"(orange)
| \"The sunken room beside the pump room.\"(orange)
~ fi
| ...
~ fi
| (:shocked)You're not serious?
~ islay
| The Wraw are already here - our monitoring devices at the foot of your territory are going offline.
| We need to stop them here and now.
~ fi
| And exploding our water pump is the way to do that?
~ islay
| It's our pump. We let you use it.
~ fi
| ...
~ islay
| And we're not exploding it, just the room beside it - enough to collapse the tunnels and close access.
| We can repair any damage to the pump and water supply afterwards, but I hope it will be minimal.
~ fi
| Well it sounds like I have no choice.
~ islay
| \"Affix all 3 bombs, then get to a safe distance\"(orange) - at least to the \"Zenith Hub\"(orange) I'd say.
| Then \"contact us on FFCS\"(orange) - this area is still free of the interference they're running.
~ player
| \"Checking FFCS... Confirmed, we're still in business.\"(light-gray, italic)
~ islay
| (:nervous)All the bombs need to be positioned first, because we're detonating them in a precise sequence.
| (:normal)Remember where to \"plant them\"(orange):
| \"The base of the old Semi factory.\"(orange)
| \"The mushroom cave to the west.\"(orange)
| \"The sunken room beside the pump.\"(orange)
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
  | Good luck!
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