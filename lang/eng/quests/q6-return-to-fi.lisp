;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q6-return-to-fi)
  :author "Tim White"
  :title "Return to Fi"
  :description "I should contact Fi and tell her about Alex."
  :on-activate (leave-semis)
  
  (leave-semis
   :title "Head out of Semi Sisters territory and contact Fi"
   :invariant T
   :condition all-complete
   :on-activate NIL
   :on-complete NIL

   (:interaction fi-ffcs
    :interactable fi
    :dialogue "
~ player
| \"I might as well call Fi from here. There's nowhere the Semis don't have eyes and ears.\"(light-gray, italic)
| (:normal)Hello Fi, it's me.
| (:skeptical)... Fi?
| (:thinking)\"Something's interfering with my FFCS signal.\"(light-gray, italic)
| \"I probably have Innis to thank for that.\"(light-gray, italic)
| (:normal)\"Alright, if they don't want me calling home, \"I'll go on foot\"(orange).\"(light-gray, italic)
| (:giggle)\"Or maybe I'll take the train.\"(light-gray, italic)
! eval (activate 'return-fi)
! eval (deactivate (unit 'fi-ffcs-1))
! eval (deactivate (unit 'fi-ffcs-2))
"))

  (return-fi
   :title "Return to the Noka camp and speak with Fi"
   :invariant T
   :condition all-complete
   :on-complete (q7-my-name)
   :on-activate T

   (:interaction talk-fi
    :interactable fi
    :dialogue "
~ fi
| (:annoyed)I was starting to get worried. Why didn't you call?
~ player
- I got sidetracked.
  ~ fi
  | (:annoyed)Sidetracked? And what may I ask was more important than getting Alex's intel on the Wraw?
- Alex isn't coming back.
  ~ fi
  | (:unsure)Are they okay? What happened?
- My FFCS couldn't cut through.
  ~ fi
  | (:annoyed)... I'm waiting for a good explanation.
  ~ player
  | The Semis are running some kind of interference, which blocked the signal.
  ~ fi
  | The Semis? You were meant to go and see the Cerebats.
~ player
| I found Alex in the Semi Sisters bar. Drunk.
| They aren't happy about me becoming a hunter. They think I've taken their job.
~ fi
| Oh...
~ player
| They did say they'd mapped the regions beneath the Semi Sisters territory, so there might be something in that.
| But they weren't exactly clear, or forthcoming. I let Islay talk to them while I ran some errands, but it didn't help.
~ fi
| (:annoyed)Damn it. This is not the time for this.
| Alex has had this problem before.
| (:unsure)So you met Islay. What about Innis?
~ player
- I met them both.
- She's almost as bad as Jack.
- How could I forget.
~ fi
| I'm sorry you had to meet them.
~ player
| Innis also thinks the Wraw are on the move. That they're in Cerebats territory.
~ fi
| (:annoyed)Does she. And what proof is there of that?
~ player
| A Wraw robot took down the CCTV along the Semi-Cerebat border. Then I took //it// down.
~ fi
| I'm sure you did.
| Did she say anything else?
~ player
- You won't like it.
  ~ fi
  | (:annoyed)I'm certain I won't. But I want to hear it all the same.
  ~ player
  | She said she wants Catherine back or she'll shut the water off.
  ~ fi
  | (:shocked)...
- Nothing of consequence.
  ~ fi
  | I'll be the judge of that.  
  ~ player
  | She said she wants Catherine to return to them, or she'll turn the water off.
  ~ fi
  | (:shocked)...
- She wants Catherine back or she's shutting off the water.
  ~ fi
  | (:shocked)...
~ fi
| (:shocked)I ...
| Do you think she meant it?
~ player
- You know her better than I do.
  ~ fi
  | I wouldn't go that far. But...
- I think we have to assume that she did.
- Knowing Innis, that's a big YES.
~ fi
| (:annoyed)Kuso.
| Catherine was born in the Semi Sisters, as you might have guessed from her skills.
| But she came with us when we left the Wraw.
| She doesn't want to go back, even though she'd do it in a heartbeat to help us.
~ player
- Are you sure?
  ~ fi
  | (:annoyed)They treated her like shit. Just like they did you, I think.
- Have you asked her?
  ~ fi
  | I don't need to. (:annoyed)They treated her like shit. Just like they did you, I think.
- She doesn't want to go back, or you don't want her to go back?
  ~ fi
  | Catherine is an asset, obviously she is.
  | But she's also our friend.
  | (:annoyed)The Semis treated her like shit. Just like they did you, I think.
~ fi
| (:annoyed)Innis is bluffing. She's a spy, a technocrat, a fuheiwoiu! But she's not a killer. She won't turn the water off.
| (:normal)And as for the Wraw-Cerebat takeover: I know you fought their robot, but that's not proof.
| The Wraw want us, not the Cerebats - and certainly not the Semi Sisters.
| Their leader, \"Zelah\"(yellow), takes the easy route, not the hard. He doesn't fight battles, he goes after the little guy.
| Especially when the little guy has pissed him off.
~ fi
| Well I'm glad your back safe and sound. (:happy)At least that's something.
~ player
- I'm glad to see you too.
- I feel better now I'm back with you.
  ~ fi
  | (:happy)As do I.
- It's good to be back.
~ fi
| Take these parts too - you've more than earned them.
! eval (store 'item:parts 600)
| (:happy)Goodbye \"for now\"(orange), Stranger.
")))
;; TODO it would make sense to allow talking to Catherine about going back to the Semis and her backstory there, at the next available opportunity, if only to corroborate what Fi has said.
;; kuso = shit (Japanese)
;; fuheiwoiu = grouch (Japanese)