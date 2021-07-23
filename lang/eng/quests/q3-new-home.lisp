;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q3-new-home)
  :author "Tim White"
  :title "Find a New Home"
  :description "I need to find a new home for the settlement, across the surface and beneath the Ruins to the east. My FFCS indicates four candidate locations."
  :on-activate (find-home-first find-home-second find-home-third find-home-fourth task-q3-reminder)

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
| //Jack said \"I should search across the surface and down into the Ruins to the east\"(orange). My FFCS indicates \"four candidate locations\"(orange).//
")
)

  (find-home-first
   :title "Scout location Beta"
   :condition all-complete
   :on-activate T   
   (:interaction new-home-site-1
    :interactable new-home-1
    :dialogue "
~ player
| //It's new-home candidate site \"Beta\"(red).//
| (:thinking)//There could be shelter inside this building.//
| (:normal)//Scanning the interior...//
| //Dirt and sand has intruded through almost every crack.//
| //It's a quicksand deathtrap.//
? (complete-p 'find-home-second 'find-home-third 'find-home-fourth)
| | (:normal)//That's the last site surveyed. I should \"return to Jack\"(orange) with the bad news.//
| ! eval (activate 'return-new-home)
| ! eval (deactivate 'task-q3-reminder)
|?
| | (:normal)//I should keep looking, and consult my \"Log Files\" for how many sites remain.//
"))
;; SCRATCH | Structural integrity can be described as \"may collapse at any moment\". ;; restore italics to "Structural integrity..." once back slashes don't impede
  (find-home-second
   :title "Scout location Gamma"
   :condition all-complete
   :on-activate T

   (:interaction new-home-site-2
    :interactable new-home-2
    :dialogue "
~ player
| //It's new-home candidate site Gamma.//
| (:thinking)//This position is favourably elevated and well-concealed, offering a vantage point from which to spot intruders.//
| //The building's foundations appear strong, but the rest is a sand-blasted shell.//
| //It's a no go.//
? (complete-p 'find-home-first 'find-home-third 'find-home-fourth)
| | (:normal)//That's the last site surveyed. I should \"return to Jack\"(orange) with the bad news.//
| ! eval (activate 'return-new-home)
| ! eval (deactivate 'task-q3-reminder)
|?
| | (:normal)//I should keep looking, and consult my \"Log Files\" for how many sites remain.//
"))

  (find-home-third
   :title "Scout location Delta"
   :condition all-complete
   :on-activate T

   (:interaction new-home-site-3
    :interactable new-home-3
    :dialogue "
~ player
| //It's new-home candidate site Delta.//
| (:thinking)//It's secure and concealed, and sheltered from the weather.//
| (:skeptical)//But the foot of a cliff face is perhaps not the wisest choice in an area prone to earthquakes.//
? (complete-p 'find-home-first 'find-home-second 'find-home-fourth)
| | (:normal)//That's the last site surveyed. I should \"return to Jack\"(orange) with the bad news.//
| ! eval (activate 'return-new-home)
| ! eval (deactivate 'task-q3-reminder)
|?
| | (:normal)//I should keep looking, and consult my \"Log Files\" for how many sites remain.//
"))

  (find-home-fourth
   :title "Scout location Epsilon"
   :condition all-complete
   :on-activate T

   (:interaction new-home-site-4
    :interactable new-home-4
    :dialogue "
~ player
| //It's new-home candidate site Epsilon.//
| (:thinking)//These factory cubicles would make for excellent storage, and perhaps even a base for Engineering.//
| //I could clear the barbed wire so children, and the elderly and infirm could navigate the area.//
? (or (complete-p 'q2-seeds) (have 'item:seeds))
| | (:skeptical)//But its proximity to the soiled seed cache is problematic. And that's before they even consider the earthquakes.//
|?
| | (:skeptical)//But the factory offers little structural protection against the earthquakes, and many gruesome ways to impale oneself.//
? (complete-p 'find-home-first 'find-home-second 'find-home-third)
| | (:normal)//That's the last site surveyed. I should \"return to Jack\"(orange) with the bad news.//
| ! eval (activate 'return-new-home)
| ! eval (deactivate 'task-q3-reminder)
|?
| | (:normal)//I should keep looking, and consult my \"Log Files\" for how many sites remain.//
"))

  (return-new-home
   :title "Return to Jack in Engineering"
   :condition all-complete
   :on-activate T
   ;; enemies on this quest will be world NPCs, not spawned for the quest
   ;; REMARK: The mansplain part feels like it touches on current real-life political commentary and sticks out too much to me.
   (:interaction new-home-return
    :interactable jack
    :dialogue "
~ jack
| You're back. How'd it go?
~ player
- How do you think it went?
  ~ jack
  | I admit it was a thankless task, but I thought there might at least be somewhere we could go.
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
  | Figures. Here ya go.
  ! eval (store 'item:parts 10)
  < explain
- That's the normal etiquette, isn't it?
  ~ jack
  | I guess so. Here ya go.
  ! eval (store 'item:parts 10)
  < explain
- Not from you.
  ~ jack
  | Suit yerself.
  < continue
- No thanks.
  ~ jack
  | Suit yerself.
  < continue

# explain
~ jack
| You can trade with those spare parts.
~ player
- Thanks for the mansplain.
  ~ jack
  | You're welcome. (:thinking)Wait what?...
- Understood.
< continue

# continue
? (complete-p 'q2-seeds)
| ~ jack
| | (:normal)Oh, \"Cathy wants a word too.\"(orange)
| | (:annoyed)Know that my threat still stands if you touch her.
| ! eval (activate 'sq-act1-intro)
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
;; TODO task order, as shown on UI, does not follow activation order
