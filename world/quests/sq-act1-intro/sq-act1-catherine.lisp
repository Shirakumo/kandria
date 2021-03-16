(:name sq-act1-catherine
 :title "Talk to Catherine"
 :description NIL
 :invariant T
 :condition NIL
 :on-activate (talk-catherine)
 :on-complete NIL
)

;(and((not (active-p 'sq1-leaks)) (not (complete-p 'sq1-leaks))))
; (if(and((not (active-p 'sq1-leaks)) (not (complete-p 'sq1-leaks)))))
;(and (not (active-p 'sq1-leaks)) (not (complete-p 'sq1-leaks)))

(quest:interaction :name talk-catherine :title "Let's chat" :interactable catherine :repeatable T :dialogue "
~ catherine
| Hey there
~ player
- [(and (not (active-p 'sq1-leaks)) (not (complete-p 'sq1-leaks))) leaks begin|]
  ~ catherine
  | Things are leaking again... Saboteurs back?...
  | Bye
  ! eval (activate 'sq1-leaks)
- [(and (not (active-p 'sq2-mushrooms)) (not (complete-p 'sq2-mushrooms))) mushrooms begin|]
  ~ catherine
  | Food running low. Mushrooms edible and can sustain us. All we used to eat before we moved to the surface.
  ! eval (activate 'sq2-mushrooms)
- [(not (active-p 'sq3-race)) race begin|]
  ~ catherine
  | So you want to race? Let me think about some routes and plant some objects. Come back soon.
  ? (not (active-p 'sq3-race))
  | ! eval (activate 'sq3-race)
- more info
  ~ catherine
  | let's chat about sidequests
- bye
  ~ catherine
  | bye
")
; todo bug when re-activating sq3-race for another race, it doesn't add it to the active quest log in the journal, so it remains logged as completed
; todo complete this quest manually when final side quest is complete? Or whenever race is not meant to be available anymore

#|
MUSHROOMS temp cut todo

  | I figure we can help Fi if you bring some back. 
  | I know it's not the coolest hunter duty around, but hey.
  | Bring as many as you can find, though 25 would be great.
  
  

|#