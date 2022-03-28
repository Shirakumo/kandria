;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q6-return-to-fi)
  :author "Tim White"
  :title "Return to Fi"
  :description "I should contact Fi and tell her about Alex."
  :on-activate (leave-semis)
  
  (leave-semis
   :title "Head out of Semi Sisters territory and contact Fi via FFCS"
   :invariant T
   :condition all-complete
   :on-activate NIL
   :on-complete NIL

   (:interaction fi-ffcs
    :interactable fi
    :dialogue "
~ player
| \"I might as well call Fi from here. There's nowhere the Semis don't have eyes and ears.\"(light-gray, italic)
| (:normal)Hello, Fi, it's me.
| (:skeptical)... Fi?
| (:thinking)\"Something's interfering with my FFCS signal.\"(light-gray, italic)
| (:normal)\"I probably have Innis to thank for that.\"(light-gray, italic)
| (:normal)\"Alright, if they don't want me calling home, \"I'll go on foot\"(orange).\"(light-gray, italic)
? (unlocked-p (unit 'station-surface))
| | (:giggle)\"Or maybe I'll take the train.\"(light-gray, italic)
! eval (activate 'return-fi)
! eval (deactivate (unit 'fi-ffcs-1))
! eval (deactivate (unit 'fi-ffcs-2))
"))

  (return-fi
   :title "Return to the Noka camp and speak with Fi"
   :marker '(fi 500)
   :invariant T
   :condition all-complete
   :on-complete (q7-my-name)
   :on-activate T

   (:interaction talk-fi
    :interactable fi
    :dialogue "
~ fi
| (:annoyed)I was starting to get worried. Why didn't you call? Where's Alex?
~ player
- I got waylaid.
  ~ fi
  | (:annoyed)Waylaid? What was more important than bringing Alex back?
- Alex isn't coming back.
  ~ fi
  | (:unsure)Are they okay? What happened?
- My FFCS couldn't cut through.
  ~ fi
  | (:annoyed)... Why not?
  ~ player
  | The Semis are running some kind of interference - it blocked the signal.
  ~ fi
  | (:unsure)The Semi Sisters? You were meant to find Alex with the Cerebats.
~ player
| I found them in the Semi Sisters bar. Drunk. They won't budge.
| They aren't happy that I became a hunter. They think I've stolen their job.
~ fi
| Oh...
~ player
| They did say they'd mapped the regions beneath the Semi Sisters, so there might be something in that.
| But they weren't exactly clear, or forthcoming. I let Islay talk to them while I ran some errands, but it didn't help.
~ fi
| (:annoyed)Damn. This is not the time for this.
| Alex has had this problem before. (:normal)Well, we'll just have to leave them for now.
| So, you met Islay. (:unsure)What about Innis?
~ player
- I met them both.
- She's almost as bad as Jack.
- How could I forget.
~ fi
| (:unsure)I'm sorry you had to meet them. (:happy)At least you're still intact.
~ player
| Innis also thinks the Wraw are in Cerebats territory.
~ fi
| (:annoyed)Does she. And what proof does she have of that?
~ player
| A group of rogues crossed the Semi-Cerebat border and took their CCTV down.
| Then I took them down.
~ fi
| I'm sure you did.
| Did she say anything else?
~ player
- You won't like it.
  ~ fi
  | (:annoyed)I don't like anything Innis says. But I still want to hear it.
  ~ player
  | She said she wants Catherine back or she'll turn the water off.
- (Lie) Nothing of consequence.
  ~ fi
  | I'll be the judge of that.  
  ~ player
  | She said she wants Catherine back or she'll turn the water off.
- She wants Catherine back or she's turning the water off.
~ fi
| (:shocked)...
| Do you think she meant it?
~ player
- You know her better than I do.
  ~ fi
  | (:unsure)I wouldn't go that far. But...
- I think we have to assume that she did.
- Knowing Innis, that's a yes.
~ fi
| (:annoyed)Kuso.
| Catherine was born in the Semi Sisters, as you might have guessed from her skills.
| But she came with us when we left the Wraw.
| She doesn't want to go back, even though I know she'd do it to help us.
~ player
- Are you sure?
  ~ fi
  | (:annoyed)They treated her like shit. Just like they did with you.
- Have you asked her?
  ~ fi
  | I don't have to. (:annoyed)They treated her like shit. Just like they did with you.
- She doesn't want to go back, or you don't want her to go back?
  ~ fi
  | Catherine is an asset, obviously she is. But she's also our friend.
  | (:annoyed)The Semi Sisters treated her like shit. Just like they did with you.
~ fi
| (:annoyed)Innis is bluffing. She's a spy, a technocrat - a fuheiwoiu! (:normal)But she's not a killer. She won't turn the water off.
| And as for the Wraw invading the Cerebats: I know you fought rogues, but that's not proof.
| Rogues are many in Cerebats territory - it's a market district!
| The Wraw want us, not the Cerebats - and certainly not the Semi Sisters.
| Their leader, \"Zelah\"(yellow), takes the easy route. He doesn't fight battles, he goes after the little guy.
~ fi
| Well I'm glad your back.
~ player
- I'm glad to see you too.
- I feel better now I'm back with you.
  ~ fi
  | (:happy)Me too.
- It's good to be back.
~ fi
| Take these parts - you've earned them.
! eval (store 'item:parts 600)
| (:happy)Goodbye \"for now\"(orange), Stranger.
")))
;; kuso = shit (Japanese)
;; fuheiwoiu = grouch (Japanese)

;; there are fewer player choices here about the events in Semis territory, as narratively at this stage the PC wants to inform Fi efficiently, and the player already knows what's happened, so there's no fun in jumping through choice hoops in how to report it a second time. However, there are fresh choices about fresh news e.g. Semis wanting Catherine back