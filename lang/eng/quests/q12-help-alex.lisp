;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q12-help-alex)
  :author "Tim White"
  :title ""
  :visible NIL
  :on-activate (alex-task)

  (alex-task
   :title ""
   :invariant T
   :condition all-complete
   :on-activate (alex-interact)

   (:interaction alex-interact
    :interactable alex
    :title ""    
    :dialogue "
! eval (complete 'q8-alex-cerebat)
? (var 'alex-cerebat)
| ~ player
| | You're still here?
| ~ alex
| | (:proud)Not for much longer.
|?
| ~ player
| - Alex?
|   ~ alex
|   | (:proud)Not for much longer.
| - What are you doing here?
|   ~ alex
|   | (:proud)Biding my time.
| - Are you sober?
|   ~ alex
|   | (:proud)As a judge at the Last Judgement.
  
~ alex
| (:proud)I can't wait to see the look on Fi's face when the Wraw come pouring out o' the ground.
~ player
| (:skeptical)...
- What do you mean?
- What have you done?
- Are you saying what I think you're saying?
  ~ alex
  | (:proud)If that's that I've betrayed you to the Wraw, then yeah.
~ alex
| I told them the exact location o' the Noka camp.
| (:angry)It's the least I could do to repay you an' Fi for your loyalty.
| Now if you don't mind, I've got a battle to fight.
| Watch your back, {(nametag player)}.
? (and (not (active-p (unit 'wraw-border-1))) (not (active-p (unit 'wraw-border-2))))
| ! eval (activate 'fi-task)
"))
;; if you've travelled into the Wraw region (i.e. these triggers are not active), then it's safe to activate the Fi return task, since Fi will now be on the surface with the others

  (fi-task
   :title ""
   :invariant T
   :condition all-complete
   :on-activate (fi-interact)

   (:interaction fi-interact
    :interactable fi
    :title "Alex has betrayed us."
    :dialogue "
~ fi
| (:shocked)Alex has... betrayed us? What do you mean?
~ player
| I found them in Cerebat territory. They told the Wraw our location.
| Oh, and they are coming back after all.
~ fi
| (:unsure)They are?
~ player
- Just not how you think.
  ~ fi
  | What do you mean?
  ~ player
  | (:embarassed)They're coming back on the side of the Wraw.
  ~ fi
  | (:shocked)...
- On the side of the Wraw.
  ~ fi
  | (:shocked)...
- We might have to kill them.
  ~ fi
  | What do you mean?
  ~ player
  | (:embarassed)They're coming back on the side of the Wraw.
  ~ fi
  | (:shocked)...
~ jack
| (:annoyed)Why didn't you put 'em outta their misery when you had the chance? Who knows what else they told the Wraw, and how many they might kill.
~ player
- In cold blood?
  ~ jack
  | (:annoyed)Androids don't have blood.
  ~ fi
  | (:annoyed)I beg to differ, Jack.
- I'm not a killer.
  ~ jack
  | (:annoyed)Oh really? What's your body count since you came back online?
  | I bet you've lost count.
  | Not to mention all those you killed before the Calamity.
  ~ fi
  | {(nametag player)} has helped and defended us. And I will not indulge lazy suppositions!
  ~ jack
  | (:normal)...
- Maybe you're right.
  ~ jack
  | ... 
  ~ fi
  | (:annoyed)No, I don't he is.
~ fi
| It was better to know about Alex sooner rather than later.
| Thank you, {(nametag player)}.
")))