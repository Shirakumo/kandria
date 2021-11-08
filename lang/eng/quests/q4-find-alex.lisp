;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q4-find-alex)
  :author "Tim White"
  :title "Find Alex"
  :description "Fi wants me to find Alex and bring them back to camp for debriefing, to see if they know anything about the Wraw's plans."
  :on-activate (find-alex)

  (find-alex
   :title "Travel down to the Cerebats township, but avoid the Semi Sisters en route."
   :description NIL
   :invariant T
   :condition all-complete
   :on-activate (q4-reminder innis-stop islay-hint)
   :on-complete (return-seeds)

   (:interaction q4-reminder
    :interactable fi
    :repeatable T
    :dialogue "
~ fi
| Go to the \"Cerebats township deep underground, find Alex and bring them back\"(orange) for debriefing.
| Watch out for the Semi Sisters on your way. They're not our enemies, but they are unpredictable.
")

   (:interaction innis-stop
    :interactable innis
    :dialogue "
~ innis
| (:angry)<-STOP-> WHERE YOU ARE!!
| Did you think ya could just waltz right through here?
| (:sly)We've been watching you, android. You and your little excursions with Catherine.
| And now you've come to visit us. How thoughtful.
| (:normal)What //should// we do with you? I bet your \"Genera\"(red) core could run our entire operation.
| What do you think, sister?
~ islay
| (:unhappy)I think you should leave her alone.
~ innis
| (:exasperated)...
| (:normal)Come now - the pinnacle of human engineering is standing before you, and that's all you can say?
| (:sly)That wasn't a compliment by the way, android.
| (:normal)But let's not get off on the wrong foot now.
~ player
- (Keep quiet)
  ~ innis
  | (:sly)Why are you are here? I know lots about you, but I want to know more.
- My name's Stranger.
  ~ innis
  | This I know, android. (:sly)Tell me, why are you here?
- What do you want?
  ~ innis
  | (:sly)I'll ask the questions if you dinnae mind. Why are you here?
~ innis
| (:sly)What //does// Fi send her robot dog to do?
~ player
- My business is my business.
  ~ innis
  | If that's your prerogative.
  | But you'll be pleased to know that \"Alex is here\"(orange).
- I'm looking for someone called Alex, have you seen them?
  ~ innis
  | (:pleased)You see, sister. The direct approach once again yields results.
  | (:normal)You'll be pleased to know that \"Alex is here\"(orange).
- Go fuck yourself.
  ~ islay
  | (:happy)...
  ~ innis
  | (:angry)...
  | I remember your kind! You think you're clever just 'cause you can mimic us.
  | You're a machine. And if I wished it I could have you pulled apart and scattered to the four corners of this desert.
  | (:normal)Now, let's try again.
  | You'll be pleased to know that the one you seek, \"Alex, is here\"(orange).
~ innis
| Indulge me, would you? I want to see how smart you are.
| See if you can \"find them\"(orange) for yourself.
")

   (:interaction islay-hint
    :interactable islay
    :dialogue "
~ islay
| (:unhappy)I'm sorry about my sister.
| (:nervous)If you're \"looking for Alex, try the bar\"(orange). Just don't tell Innis I told you.
")
))
#|
dinnae = don't (Scottish)
|#

#|
   (:interaction alex-arrive
    :interactable alex
    :dialogue "
~ player
| Yo Alex.
")))
|#