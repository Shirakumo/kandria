(:name race-hub
 :title "Talk to Catherine to start a race"
 :description NIL
 :invariant T
 :condition NIL
 :on-activate (start-race)
 :on-complete NIL
)

; enemies on this quest will be world NPCs, not spawned for the quest
(quest:interaction :name start-race :title "I want to race" :interactable catherine :repeatable T :dialogue "
? (or (active-p 'race-one) (active-p 'race-two) (active-p 'race-three) (active-p 'race-four))
| ~ catherine
| | A race is in progress, get going!
|?
| ~ catherine
| | Alright, it's race time!
| ? (not (complete-p 'race-one))
| | | Let's start with an easy one.
| | < race-1
| |?
| | ~ player
| | - Race 1
| |   < race-1
| | - Race 2
| |   < race-2
| | - [(complete-p 'race-two) Race 3|]
| |   < race-3
| | - [(complete-p 'race-three) Race 4|]
| |   < race-4
| | - No race for me right now
# race-1
~ catherine
| I planted an X nearby. Time starts now!
? (not (complete-p 'race-one))
| ! eval (activate 'race-one)
|?
| ! eval (setf (quest:status (thing 'race-one)) :inactive)
| ! eval (setf (quest:status (thing 'race-one-return)) :inactive)
| ! eval (activate 'race-one)
# race-2
~ catherine
| I planted an W at some distance. Time starts now!
? (not (complete-p 'race-two))
| ! eval (activate 'race-two)
|?
| ! eval (setf (quest:status (thing 'race-two)) :inactive)
| ! eval (setf (quest:status (thing 'race-two-return)) :inactive)
| ! eval (activate 'race-two)
# race-3
~ catherine
| I planted an Y at some distance. Time starts now!
? (not (complete-p 'race-three))
| ! eval (activate 'race-three)
|?
| ! eval (setf (quest:status (thing 'race-three)) :inactive)
| ! eval (setf (quest:status (thing 'race-three-return)) :inactive)
| ! eval (activate 'race-three)
# race-4
~ catherine
| I planted an Z a long way away. Time starts now!
? (not (complete-p 'race-four))
| ! eval (activate 'race-four)
|?
| ! eval (setf (quest:status (thing 'race-four)) :inactive)
| ! eval (setf (quest:status (thing 'race-four-return)) :inactive)
| ! eval (activate 'race-four)
")
; todo allow play to opt out of first race encountered, not forced
; todo lock out later races based on whether you have gold or not on previous one, rather than merely whether you've attempted the previous one or not
; //NA - todo bug deactivating this task causes it's title to appear as another bullet point in the journal
; todo plant multiple objects, encouraging cheating
; todo add player queries for: best times in each bracket, pbs in each bracket, overall pb
; todo for bracket numbers use global quest vars, initiated at quest start
; ! eval (activate 'race-one)
; ! eval (setf (quest:status task) :unresolved)
; ! eval (setf (quest:status 'race-one) :unresolved)
; ! eval (setf (quest:status task ('race-one)) :unresolved)
; ! eval (setf (quest:status (thing 'race-one)) :unresolved)
#|



|#

#|



|#