(:name talk-to-fi
 :title "Talk to Fi"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (talk-fi)
 :on-complete (q2-seeds)
)
;; REMARK: Change "I am. For better or worse." to "Something like that, anyway."
;; REMARK: Change "And if we go lower, then we'd be too close to Wraw territory." to "And if we go lower we'd enter another faction's territory."
;; REMARK: Make the second choice repeatable so that players get the chance to explore all three choices. To do this add a label
;;         and a jump after each choice, and turn the continuation into a choice as well.
(quest:interaction :name talk-fi :interactable fi :dialogue "
~ fi
| Greetings, Stranger.
- Catherine said you might need me.
  ~ fi
  | I do.
- So you're the leader around here.
  ~ fi
  | I am. For better or worse.
- How's the water supply?
  ~ fi
  | Fully restored, thanks to yours and Catherine's efforts.
  | We might well owe you our lives.
~ fi
| I wanted to apologise for Jack's behaviour - and my own short-sightedness. You are our guest, and you have helped us.
| But you must also understand that as chieftain, I have responsibilities to keep. I must be diligent.
| But I think I have a way that you can help us again, and earn my trust.
| Although the water is back on, our crops are unlikely to survive much longer.
| I knew coming here would be hard, but we are on the brink - if we don't starve, then it seems the Wraw will get us in the end.
| They'll be coming, sooner or later, now they know where we are. No one escapes them and lives very long.
- Who are the Wraw?
  ~ fi
  | Another faction, deep underground. We were part of them.
  | Let's just say they have the monopoly on what's left of the geothermal generators. And they don't like to share.
- Can't you move back underground?
  ~ fi
  | The levels below us are seismically unstable. And if we go lower, then we'd be too close to Wraw territory.
  | We came to the surface because we honestly thought we could grow food, like people used to.
  | But we also thought they wouldn't follow.
  | I guess we were wrong. Well, I was wrong.
- Why am I suddenly you confidante?
  ~ fi
  | I don't know. You're a stranger, if you'll pardon the pun. But you've helped us.
  | And I value fresh perspective. I don't get much of that around here.
~ fi
| I haven't told the others about the harvest, but they aren't blind. I'm telling you because I think you can help.
| There's a place beneath the ruins to the east, where we first discovered the seeds that you now see growing before you.
| Alex found it, our hunter. I want you to retrace their steps, find the cache, and if it's intact, recover all the seeds that remain.
| If we can sow enough of them, and soon enough, then...
| Well, let's not get ahead of ourselves, shall we.
- You can rely on me.
  ~ fi
  | Thank you.
- I'll retrieve what I can.
  ~ fi
  | That's all I am asking.
- What if I fail?
  ~ fi
  | I don't know about the world you came from; but I discovered long ago that it's better to make one plan at a time.
  | This world tries to pull you down, but you have to act quickly, and roll with the punches.
~ fi
| Whether you succeed or not, by trying you will earn my trust.
| Alex has been our sole hunter for some time. You could be a hunter too, and more besides I think.
| Good luck.
")

#|



|#
