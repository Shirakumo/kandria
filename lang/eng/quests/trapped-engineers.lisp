;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria trapped-engineers)
  :author "Tim White"
  :title NIL
  :visible NIL
  :description NIL
  :on-activate (task-engineers-trapped)
  :variables (first-talk)
 
;; Engineer bio: Calm leader, example to the rest (of the leaders in the game), African English, female - never a need to known their name
  (task-engineers-trapped
   :title NIL
   :condition all-complete
   :on-activate T   
   (:interaction talk-engineers-trapped
    :interactable semi-engineer-chief
    :repeatable T
    :dialogue "
! eval (setf (nametag (unit 'semi-engineer-chief)) \"???\")
? (active-p (unit 'engineers-wall))
| ? (not (var 'first-talk))
| | ~ semi-engineer-chief
| | | (:weary)How in God's name did you get in here?
| | ~ player
| | | There's a tunnel above here - though it's not something a human could navigate.
| | ~ semi-engineer-chief
| | | ... A //human//? So you're...
| | ~ player
| | - Not human, yes.
| |   ~ semi-engineer-chief
| |   | (:shocked)... An android, as I live and breathe.
| | - An android.
| |   ~ semi-engineer-chief
| |   | (:shocked)... As I live and breathe.
| | - What are you doing in here?
| | ~ semi-engineer-chief
| | | (:weary)We're glad you showed up. We're engineers from the Semi Sisters.
| | | I can't tell you what we're working on, but I can tell you that the tunnel collapsed. We lost the chief and half the company.
| | | We \"can't break through\"(orange) - can you? Can androids do that?
| | | \"The collapse is just head.\"(orange)
| | ! eval (setf (var 'first-talk) T)
| |?
| | ~ semi-engineer-chief
| | | (:weary)How'd it go with the \"collapsed wall\"(orange)? We can't stay here forever.
|?
| ? (not (var 'first-talk))
| | ~ semi-engineer-chief
| | | (:weary)Who are you? How did you break through the collapsed tunnel?
| | ~ player
| | - I'm... not human.
| |   ~ semi-engineer-chief
| |   | (:shocked)... An android, as I live and breathe.
| | - I'm an android.
| |   ~ semi-engineer-chief
| |   | (:shocked)... As I live and breathe.
| | - It doesn't matter - you need medical attention.
| | ~ semi-engineer-chief
| | | (:weary)We'll send someone for help now the route is open. Our sisters will be here soon to tend to us.
| | | Thank you.
| | ! eval (setf (var 'first-takj) T)
| |?
| | ~ semi-engineer-chief
| | | (:normal)I can't believe you got through... Now food and medical supplies can get through too, and the injured have already made the journey home. Thank you.
| | | And now I have a new team, we can resume our task. It'll be slow-going, but we'll be careful this time.
")))
;; engineer knows better than to send an android into Semis territory for help
;; also, could add a trigger on leaving the chunk to refresh the chat to reflect time has past; with current imp could step back, talk again, and time has moved on (but is plausible in accelerated time of game, and an edge case)