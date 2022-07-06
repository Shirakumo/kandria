(quest:define-quest (kandria sq5-race)
  :author "Tim White"
  :title "Barkeep's Time Trials"
  :description "A Semi Sisters barkeep and their clientele are bored; they're organising a sweepstake to see if (when) I can beat the item retrieval times set by their best hunters. They're going to plant... broken Genera cores, of all things, for me to find and bring back. The faster I do it, the bigger my cut from the sweepstake."
  :on-activate T
  :variables (gold silver bronze pb start-task active-race)
  (race-hub
   :title "Talk to the barkeep in the Semi Sisters Central Block to start a race"
   :marker '(semi-barkeep 500)
   :invariant (not (complete-p 'q10-wraw))
   :condition all-complete
   :on-activate T
   :on-complete (sq5-race-1)
   (:interaction about-races
    :title "About the races."
    :interactable semi-barkeep
    :source '("barkeep-race" "hub"))))

(define-races sq5-race
  :npc semi-barkeep
  :item item:semi-genera-core
  :source "barkeep-race"
  :return "Return the broken Genera core to the barkeep in the Semi Sisters Central Block - ASAP"
  ((sq5-race-1-site 63 79 124)
   :marker (chunk-5602 1000)
   :description "Retrieve the broken Genera core near the Semi sign, to the high west of the Central Block")
  
  ((sq5-race-2-site 122 139 183)
   :marker (chunk-5677 1000)
   :description "Retrieve the broken Genera core from the engineers' camp, in the far high west of Semi Sisters territory")

  ((sq5-race-3-site 135 148 187)
   :marker (chunk-5681 1600)
   :description "Retrieve the broken Genera core from the old android factory, in the far east of Semi Sisters territory")

  ((sq5-race-4-site 134 146 193)
   :marker (sq5-race-4-site 800)
   :description "Retrieve the broken Genera core from the crevice in the high east of Semi Sisters territory, beneath the old Semi factory in the Ruins")

  ((sq5-race-5-site 221 239 282)
   :marker (chunk-5675 1000)
   :description "Retrieve the broken Genera core from a cave in the high east of Semi Sisters territory, beneath the unstable bridge")
   
  ((sq5-race-6-site 199 214 246)
   :marker (chunk-5641 1200)
   :description "Retrieve the broken Genera core from near the Cerebats sign - the second one en route to their land, via the Semi Sisters' low-western border"))

;; more organic/dynamic par times here than with Catherine's sq3 races, since they are meant to be records set by real people, rather than neat brackets
;; however, they are still too fast for real people versus an android - but that's so there's still a challenge to get gold (we could imagine the barkeep is artificially contracting the hunter times)
