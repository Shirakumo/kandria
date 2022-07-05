;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria sq6-deliver-letter)
  :author "Tim White"
  :title "Deliver the Letter"
  :description "Tobias, a member of the Semi Sisters, wants me to deliver a letter to his girlfriend, Kacey, who's a Cerebat. I don't have a visual description, so I'll have to search."
  :on-activate (reminder deliver-letter)

  (reminder
   :title NIL
   :visible NIL
   :invariant (not (complete-p 'q10-wraw))
   :condition (complete-p 'deliver-letter)
   :on-activate T

   (:interaction interact-reminder
    :interactable semi-partner
    :title "About delivering the letter."
    :repeatable T
    :dialogue "
~ semi-partner
| \"You're looking for Kacey in Cerebats territory\"(orange). I'm sorry I can't tell you what she looks like - you'll have to \"ask around\"(orange).
| The downside of a long distance relationship... Not that I care what she looks like.
"))

  (read-letter
   :title NIL
   :visible NIL
   :invariant (not (complete-p 'q10-wraw))
   :condition (complete-p 'deliver-letter)
   :on-activate T

   (:interaction interact-read
    :interactable semi-partner
    :title "You're breaking up with her?"
    :dialogue "
~ semi-partner
| __You read the letter?__ I don't believe it...
| Maybe it's true what they say about androids.
| ...
| Just deliver it, alright. I need to know she's safe.
| Can you do that?
! eval (complete task)
! eval (reset* interaction)
"))
  
  (deliver-letter
   :title "Find Kacey in Cerebats territory and deliver the letter"
   :marker '(chunk-5529 1200)
   :invariant (not (complete-p 'q10-wraw))
   :condition all-complete
   :on-activate T

   (:interaction deliver-chat
    :interactable cerebat-partner
    :dialogue "
~ cerebat-partner
| Who are you?
~ player
| Kacey?
~ cerebat-partner
| Who wants to know?
~ player
- My name's {(nametag player)}.
  ~ cerebat-partner
  | Are you an android?
  ~ player
  - How did you know?
    ~ cerebat-partner
    | You're insignia. I've heard about androids.
  - Yes.
    ~ cerebat-partner
    | Wow. I guess I should be amazed. There was a time when I would've been.
  - It's not important.
    ~ cerebat-partner
    | That's a yes.
  ~ cerebat-partner
  | Let me guess: Tobias. This reeks of his overzealousness.
- Tobias sent me.
  ~ cerebat-partner
  | Shit. He shouldn't have done that.
- I was sent by a Semi, who's looking for their girlfriend.
  ~ cerebat-partner
  | Let me guess: Tobias. This reeks of his overzealousness.
~ cerebat-partner
| Yes, \"I'm Kacey\"(orange). Is he alright?
! eval (setf (nametag (unit 'cerebat-partner)) (@ cerebat-partner-nametag))
? (var 'read-letter)
| ~ player
| - (Give her the letter)
|   < given
| - (Keep the letter)
|   < withheld
|?
| ~ player
| | He gave me this to give to you.
| < given

# withheld
~ cerebat-partner
| Well?
~ player
- He thought something bad had happened to you.
  ~ cerebat-partner
  | That's sweet. But no, nothing worse than usual.
  | Except having to break up with my boyfriend...
  < breakup
- He misses you.
  ~ cerebat-partner
  | I miss him. And I really wish things could've worked out.
  < breakup
- He wants to break up.
  ~ cerebat-partner
  | He does? Well at least we agree about that. Maybe we do still have something in common.
  < breakup

# given
! eval (retrieve 'item:love-letter 1)
~ cerebat-partner
| A letter? Classic Tobias. Let me see.
| ...
| Heh, well at least we agree about this. Maybe we do still have something in common.
! label breakup
| I thought he might get the message, if I stopped answering his calls. Save him the pain of having to do this.
| He knows it couldn't work out, if it ever could.
| I don't know if you're up on the politics around here, but the Semis and the Cerebats... it's not a good combination.
~ player
- Why didn't you just tell him?
  ~ cerebat-partner
  | Maybe I should have. I didn't want to hurt him.
- I think ignoring him made it worse.
  ~ cerebat-partner
  | Do you?
  | And what are you, a therapist? You look more like a creepy-ass detective.
- Are you sure you can't work things out?
  ~ cerebat-partner
  | No, I don't think so. Not now.
  | And besides, he doesn't want to.
~ cerebat-partner
| Look, I appreciate your android postal service, or whatever this is.
| \"I'll call him\"(orange), alright. Set things straight.
| Thank you, but it's not your problem any more.
")))