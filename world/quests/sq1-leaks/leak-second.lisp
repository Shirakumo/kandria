(:name leak-second
 :title "Find the second leak"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (leak-2)
 :on-complete NIL)

(quest:interaction :name leak-2 :interactable leak-2 :dialogue "
~ player
| //The pipe is cracked.//
| //There's no subsidence, but I think movement in the surrounding rocks wrenched the pipe clean open.//
? (not (var 'first-leak))
| | //I ignite the torch from the index finger on my right hand.//
| | //[(var 'q1-weld-burn) This time |]I enable the UV filters on my cameras.//
| | //Weld complete.//
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
? (complete-p 'leak-first 'leak-third)
| ~ player
| | Catherine, I've sealed the last leak. [(have 'walkie-talkie) Over.|]
| ~ catherine
| | I hear ya! That's a job well done! [(have 'walkie-talkie) Over.|]
| | Any sign of saboteurs? [(have 'walkie-talkie) Over.|]
| - No, all clear.
|   ~ catherine
|   | That's what I like to hear.
| - They were all caused by subsidence.
|   ~ catherine
|   | Oh man, you could probably stand not to hear more about landslides... Sorry!
| ~ catherine
| | Hurry back, I've got a little something for you to say thank you. [(have 'walkie-talkie) Over and out.|]
| ! eval (activate 'return-leaks)
")

#|
todo might not be good for localisation:
| | [(var 'q1-weld-burn) This time |]I enable the UV filters on my cameras.
replace with structure
| | [(var 'q1-weld-burn) //This time I enable the UV filters on my cameras.// | //I enable the UV filters on my cameras.//]
|#
