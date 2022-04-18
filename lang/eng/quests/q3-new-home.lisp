;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q3-new-home)
  :author "Tim White"
  :title "Find a New Home"
  :description "I need to find a new home for the settlement, across the surface in the Ruins to the east. My FFCS indicated 4 candidate locations."
  :on-activate (find-home-first find-home-second find-home-third find-home-fourth task-q3-reminder)
  :variables (first-home)

  (task-q3-reminder
   :title "Talk to Jack if I need a reminder"
   :visible NIL
   :on-activate T
   (:interaction q3-reminder
    :title "Remind me what I'm doing."
    :interactable jack
    :repeatable T
    :dialogue "
~ jack
| (:annoyed)Our new home ain't gonna find itself. Be seein' ya.
~ player
| \"Jack said I should \"search across the surface in the Ruins to the east\"(orange). My FFCS indicated \"4 candidate locations\"(orange).\"(light-gray, italic)
"))

  (find-home-first
   :title "Scout location Beta"
   :marker '(chunk-1831 1200)
   :condition all-complete
   :on-activate T   
   (:interaction new-home-site-1
    :interactable new-home-1
    :dialogue "
~ player
| \"It's new-home candidate site \"Beta\"(red).\"(light-gray, italic)
| (:thinking)\"There could be shelter inside this building.\"(light-gray, italic)
| (:normal)\"Scanning the interior...\"(light-gray, italic)
| \"Dirt and sand has intruded through almost every crack.\"(light-gray, italic)
| \"It's a quicksand deathtrap.\"(light-gray, italic)
? (complete-p 'find-home-second 'find-home-third 'find-home-fourth)
| | (:normal)\"That's the last site surveyed. I should \"return to Jack\"(orange) with the bad news.\"(light-gray, italic)
| ! eval (activate 'return-new-home)
| ! eval (deactivate 'task-q3-reminder)
|? (not (var 'first-home))
| | (:normal)\"I should \"keep looking\"(orange), and consult my \"Log Files\"(orange) and \"Map\"(orange) \"< {(prompt-char 'open-map)} >\"(gold) for the remaining sites.\"(light-gray, italic)
| ! eval (setf (var 'first-home) T)
"))
;; SCRATCH | Structural integrity can be described as \"may collapse at any moment\". ;; restore italics to "Structural integrity..." once back slashes don't impede
  (find-home-second
   :title "Scout location Gamma"
   :marker '(chunk-1841 1400)
   :condition all-complete
   :on-activate T

   (:interaction new-home-site-2
    :interactable new-home-2
    :dialogue "
~ player
| \"It's new-home candidate site \"Gamma\"(red).\"(light-gray, italic)
| (:thinking)\"This position is favourably elevated and well-concealed, offering a vantage point from which to spot intruders.\"(light-gray, italic)
| \"The building's foundations appear strong, but the rest is a sand-blasted shell.\"(light-gray, italic)
| \"It's a no go.\"(light-gray, italic)
? (complete-p 'find-home-first 'find-home-third 'find-home-fourth)
| | (:normal)\"That's the last site surveyed. I should \"return to Jack\"(orange) with the bad news.\"(light-gray, italic)
| ! eval (activate 'return-new-home)
| ! eval (deactivate 'task-q3-reminder)
|? (not (var 'first-home))
| | (:normal)\"I should \"keep looking\"(orange), and consult my \"Log Files\"(orange) and \"Map\"(orange) \"< {(prompt-char 'open-map)} >\"(gold) for the remaining sites.\"(light-gray, italic)
| ! eval (setf (var 'first-home) T)
"))

  (find-home-third
   :title "Scout location Delta"
   :marker '(chunk-1847 1400)
   :condition all-complete
   :on-activate T

   (:interaction new-home-site-3
    :interactable new-home-3
    :dialogue "
~ player
| \"It's new-home candidate site \"Delta\"(red).\"(light-gray, italic)
| (:thinking)\"It's secure and concealed, and sheltered from the weather.\"(light-gray, italic)
| (:normal)\"But the foot of a cliff face is perhaps not the wisest choice in an area prone to earthquakes.\"(light-gray, italic)
? (complete-p 'find-home-first 'find-home-second 'find-home-fourth)
| | \"That's the last site surveyed. I should \"return to Jack\"(orange) with the bad news.\"(light-gray, italic)
| ! eval (activate 'return-new-home)
| ! eval (deactivate 'task-q3-reminder)
|? (not (var 'first-home))
| | \"I should \"keep looking\"(orange), and consult my \"Log Files\"(orange) and \"Map\"(orange) \"< {(prompt-char 'open-map)} >\"(gold) for the remaining sites.\"(light-gray, italic)
| ! eval (setf (var 'first-home) T)
"))

  (find-home-fourth
   :title "Scout location Epsilon"
   :marker '(chunk-2030 1800)
   :condition all-complete
   :on-activate T

   (:interaction new-home-site-4
    :interactable new-home-4
    :dialogue "
~ player
| \"It's new-home candidate site \"Epsilon\"(red).\"(light-gray, italic)
| (:thinking)\"These factory cubicles would make for excellent storage, and perhaps even a base for Engineering.\"(light-gray, italic)
| \"I could clear the barbed wire so children, and the elderly and infirm could get through.\"(light-gray, italic)
? (or (complete-p 'q2-seeds) (have 'item:seeds))
| | (:thinking)\"But its proximity to the soiled seed cache is problematic. And that's before they even consider the earthquakes.\"(light-gray, italic)
|?
| | (:thinking)\"But the factory offers little structural protection against the earthquakes, and many gruesome ways to impale oneself.\"(light-gray, italic)
? (complete-p 'find-home-first 'find-home-second 'find-home-third)
| | (:normal)\"That's the last site surveyed. I should \"return to Jack\"(orange) with the bad news.\"(light-gray, italic)
| ! eval (activate 'return-new-home)
| ! eval (deactivate 'task-q3-reminder)
|? (not (var 'first-home))
| | (:normal)\"I should \"keep looking\"(orange), and consult my \"Log Files\"(orange) and \"Map\"(orange) \"< {(prompt-char 'open-map)} >\"(gold) for the remaining sites.\"(light-gray, italic)
| ! eval (setf (var 'first-home) T)
"))

  (return-new-home
   :title "Return to Jack in Engineering and deliver the bad news"
   :marker '(jack 500)
   :condition all-complete
   :on-activate T
   ;; enemies on this quest will be world NPCs, not spawned for the quest
   ;; REMARK: The mansplain part feels like it touches on current real-life political commentary and sticks out too much to me.
   ;; TW TODO: Seem to have missed this until now (31/8) - yes, I can easily remove this later. It's a minor structural change to the convo, which I'd rather not touch before the Sep 2021 demo, but I'll be going through remaining TODOs soon anyway. I quite like the loaded-ness and sharpness of the comment, and I could imagine the old world's near future politics were not that different to ours; but I'm not super married to it
   (:interaction new-home-return
    :interactable jack
    :dialogue "
~ jack
| You're back. How'd it go?
~ player
- How do you think it went?
  ~ jack
  | I admit it was a thankless task, but I thought there might be at least somewhere we could go.
- Not good news I'm afraid.
  ~ jack
  | Fuck.
- You're stuck here.
  ~ jack
  | Fuck.
~ jack
| (:thinking)Fi ain't gonna like this. I suppose she'd better hear it from me, rather than from some stone-cold android.
| (:annoyed)Thanks for your help, but it's my problem now.
| You want something for your labour?
~ player
- Yes please.
  ~ jack
  | Figures. \"Here ya go\"(orange).
  ! eval (store 'item:parts 100)
  < continue
- That's the normal etiquette, isn't it?
  ~ jack
  | I guess so. \"Here ya go\"(orange).
  ! eval (store 'item:parts 100)
  < continue
- Not from you.
  ~ jack
  | Suit yerself.
  < continue
- No thanks.
  ~ jack
  | Suit yerself.
  < continue

# continue
? (complete-p 'q2-seeds)
| ? (not (find :kandria-demo *features*))
| | ~ jack
| | | (:normal)Oh, \"Cathy wants a word too\"(orange).
| | | (:annoyed)Know that my threat still stands if you touch her.
| | | (:normal)\"Fi's got a new job for you\"(orange) as well. From what I hear, should get you outta our hair for a while. Can't wait.
| | ! eval (activate 'sq-act1-intro)
| | ! eval (activate 'q4-intro)
|?
| ? (not (active-p 'q2-seeds))
| | ~ jack
| | | (:normal)Speaking of \"Fi, she wants to talk to you\"(orange). Not a word about the scouting fail though, alright?
|   
| ~ jack
| | (:normal)Don't let me be the one to help you out, either, but I heard \"Sahil was back\"(orange).
| | His caravan is down in the Midwest Market, beneath the \"Zenith Hub\"(red).
| | I don't know what opposition you've faced scouting around, but you might wanna stock up.
| | (:annoyed)I hear even androids ain't indestructible.
| ! eval (activate 'trader-arrive)
")))
;; TODO task order, as shown on UI, does not follow activation order?
