(:name leak-third
 :title "Find the third leak"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (leak-3)
 :on-complete NIL
)

(quest:interaction :name leak-3 :interactable leak-3 :dialogue "
~ player
| //The pipe is ruptured, like an artery oozing blood.//
| //The ground feels uncannily unstable, like I've been in this situation before.//
? (not (var 'first-leak))
| | //I ignite the torch from the index finger on my right hand.//
| | [(var 'q1-weld-burn) (:embarassed) //This time I enable the UV filters on my cameras.// | (:normal) //I enable the UV filters on my cameras.//]
| | (:normal) //Weld complete.//
| ? (have 'walkie-talkie)
| | | //I turn on the walkie-talkie. It's heavy for such a simple piece of technology.//
|  
| | Catherine, I've sealed one of the leaks. [(have 'walkie-talkie) Over.|]
| ~ catherine
| | Great work - the pressure is much better already.
| | Keep going - let me know if you hit any trouble. [(have 'walkie-talkie) Over and out.|]
| ! eval (setf (var 'first-leak) T)
|?
| | //Weld complete.//
? (complete-p 'leak-first 'leak-second)
| ~ player
| | Catherine, I think I got the last leak. [(have 'walkie-talkie) Over.|]
| ~ catherine
| | (:cheer) You did - pressure is returning! That's a job well done. [(have 'walkie-talkie) Over.|]
| | (:normal) Any sign of saboteurs? [(have 'walkie-talkie) Over.|]
| ~ player
| - No, all clear.
|   ~ catherine
|   | That's what I like to hear.
| - It was all subsidence, or wear and tear.
|   ~ catherine
|   | Oh man, you could probably stand not to hear more about landslides... Sorry!
| ~ catherine
| | (:excited) Hurry back, I've got a little something for you. [(have 'walkie-talkie) Over and out.|]
| ! eval (activate 'return-leaks)
")
