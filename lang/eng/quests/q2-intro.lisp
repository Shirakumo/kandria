;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q2-intro)
  :author "Tim White"
  :title "Query Fi"
  :description "Catherine said Fi would like to talk to me."
  :on-activate (talk-to-fi)

  (talk-to-fi
   :title "Talk to Fi on the Farm"
   :condition all-complete
   :on-activate (talk-fi)
   :on-complete (q2-seeds)
   ;; TODO eliminate already chosen choices via local var checks
   (:interaction talk-fi
    :interactable fi
    :dialogue "
~ fi
| Greetings, Stranger.
~ player
- Catherine said you might want to talk.
  ~ fi
  | Yes, I do. She is quite perceptive.
- So you're the leader around here?
  ~ fi
  | Something like that, anyway.
- How's the water supply?
  ~ fi
  | Fully restored, thanks to yours and Catherine's efforts.
  | We might well owe you our lives.
~ fi
| I wanted to apologise for Jack's behaviour - and my own short-sightedness. You are our guest, and you have helped us.
| But you must also understand that as chieftain, I have responsibilities to keep. I must be diligent.
| But I think I have a way that you can help us again, and for you to further earn my trust.
| Although the water is back, our crops are unlikely to survive much longer.
| I knew coming here would be hard, but we are on the brink - if we don't starve, then it seems the Wraw will get us in the end.
| They'll be coming, sooner or later - no one escapes them and lives very long.
! label questions
~ player
- What's next?
- Who are the Wraw?
  ~ fi
  | Another faction, deep underground. We were part of them.
  | Let's just say they have the monopoly on what's left of the geothermal power generators. And they don't like to share.
  < questions
- Can't you move back underground?
  ~ fi
  | The levels below us are unstable. And if we go even lower we'd enter the territory of other factions.
  | We came to the surface because we honestly thought we could grow food, like people used to.
  | But we also thought the Wraw wouldn't follow.
  | (:annoyed)I guess we were wrong. Well, I was wrong.
  < questions
- Why am I suddenly your confidante?
  ~ fi
  | I don't know. You're a stranger, if you'll pardon the pun. But you've helped us.
  | And I value fresh perspective. I don't get much of that around here.
  < questions
~ fi
| I haven't told the others about the harvest, but they aren't blind. I'm telling you because I think you can help.
| There's a place beneath the Ruins to the east, where we first discovered the seeds that you see growing before you.
| Alex found it, our hunter. I want you to retrace their steps, find the cache, and if it's intact recover all the seeds that remain.
| If we can sow enough of them, and soon enough, then...
| Well, let's not get ahead of ourselves, shall we.
~ player
- You can rely on me.
  ~ fi
  | Thank you.
- I'll retrieve what I can.
  ~ fi
  | That's all I am asking.
- What if I fail?
  ~ fi
  | I don't know about the world you came from, but I discovered long ago that it's better to make one plan at a time.
  | This world tries to pull you down, but you have to act quickly, and roll with the punches.
~ fi
| Whether you succeed or not, your efforts will help to earn my trust.
| Alex has been our sole hunter for some time. You could be a hunter too, and more besides I think.
| Good luck.
")))
