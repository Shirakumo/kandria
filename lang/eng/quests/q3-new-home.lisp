;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q3-new-home)
  :author "Tim White"
  :title "Find a New Home"
  :description "I need to find a new home for the settlement, in the Ruins to the east. My FFCS indicates four candidate locations."
  :on-activate (find-home-first find-home-second find-home-third find-home-fourth)

  (find-home-first
   :title "Scout location Beta"
   :condition all-complete
   :on-activate T
   
   (:interaction new-home-site-1
    :interactable new-home-1
    :dialogue "
~ player
| //It's new-home candidate site Beta.//
| (:thinking)//There could be shelter inside this building.//
| (:normal)//Scanning the interior...//
| //Dirt and sand has intruded through almost every crack.//
| //It's a quicksand deathtrap.//
| Structural integrity can be described as \"may collapse at any moment\".
? (complete-p 'find-home-second 'find-home-third 'find-home-fourth)
| | (:normal)I should return to Jack with the bad news.
| ! eval (activate 'return-new-home)
"))

  (find-home-second
   :title "Scout location Gamma"
   :condition all-complete
   :on-activate T

   (:interaction new-home-site-2
    :interactable new-home-2
    :dialogue "
~ player
| //It's new-home candidate site Gamma.//
| (:thinking)//This position is favourably elevated and well-concealed, offering a vantage point from which to spy intruders.//
| //The building's foundations appear strong, but the rest is a sand-blasted shell.//
? (complete-p 'find-home-first 'find-home-third 'find-home-fourth)
| | (:normal)I should return to Jack with the bad news.
| ! eval (activate 'return-new-home)
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
| (:skeptical)//But the foot of a cliff face is perhaps not the wisest choice in an area prone to quakes.//
? (complete-p 'find-home-first 'find-home-second 'find-home-fourth)
| | (:normal)I should return to Jack with the bad news.
| ! eval (activate 'return-new-home)
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
| (:thinking)//These factory cubicles would make for excellent storage, and perhaps even as a base for Engineering.//
| //I could clear the barbed wire so children, and the elderly and infirm could navigate this area.//
? (or (complete-p 'q2-seeds) (have 'seeds))
| | (:skeptical)//But its proximity to the soiled seed cache is problematic. And that's before they even consider the earthquakes.//
|?
| | (:skeptical)//The factory does offer some structural protection against the earthquakes, but this would not be easy living.//
? (complete-p 'find-home-first 'find-home-second 'find-home-third)
| | (:normal)I should return to Jack with the bad news.
| ! eval (activate 'return-new-home)
"))

  (return-new-home
   :title "Return to Jack"
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
  ! eval (store 'parts 10)
  < explain
- That's the normal etiquette, isn't it?
  ~ jack
  | I guess so. Here ya go.
  ! eval (store 'parts 10)
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
  | You're welcome. Wait what?...
- Understood.
< continue

# continue
? (complete-p 'q2-seeds)
| | (:normal)Oh, Cathy wants a word too.
| | (:annoyed)Know that my threat still stands if you touch her.
| ! eval (activate 'sq-act1-intro)
|?
| ? (not (active-p 'q2-seeds))
| | | (:normal)Speaking o' Fi, she wants to talk to you. Not a word about the scouting fail though, alright?
|   
| | (:normal)Don't let me be the one to help you out, either, but I heard Sahil was back.
| | His caravan is down in the Midwest Market, beneath the Hub.
| | I don't know what opposition you've faced scouting around, but you might wanna stock up.
| | I hear even androids ain't indestructible...
| ! eval (setf (location 'trader) 'loc-trader)
| ! eval (activate 'trader-arrive)
")))
;; TODO task order, as shown on UI, does not follow activation order
