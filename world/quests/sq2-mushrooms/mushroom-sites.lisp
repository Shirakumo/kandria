(:name mushroom-sites
 :title "Find mushrooms"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (mushrooms1 mushrooms2 mushrooms3 mushrooms4 mushrooms5)
 :on-complete NIL
)
; mushrooms-2 mushrooms-3 mushrooms-4 mushrooms-5 mushrooms-6 mushrooms-7 mushrooms-8
; never expires - player needs to decide when to stop looking and head back to Catherine

; - [(not (var 'batch1)) //Take 6 Honey Fungus//|]

(quest:interaction :name mushrooms1 :interactable shrooms1 :repeatable T :variables (batch1 batch2) :dialogue "
~ player
| //Mushrooms site 1//
- [(not (var 'batch1)) Take 6 Honey Fungus|]
  | I take 6 honey fungus
  ! eval (store 'mushroom-good-1 6)
  ! eval (setf (var 'batch1) T)
- [(not (var 'batch2)) //Take 1 Dusky Puffball//]
  | I take 1 dusky puffball
  ! eval (store 'mushroom-good-2 1)
  ! eval (setf (var 'batch2) T)
- Take none
? (var 'batch1)
| ? (var 'batch2)
| | ! eval (deactivate 'mushrooms1)
? (<= 25 (+ (item-count 'mushroom-good-1) (item-count 'mushroom-good-2)) )
| ? (not (active-p 'return-mushrooms))
| | ! eval (activate 'return-mushrooms)
")
; once player has collected some, activate return to Catherine dialogue if not already active
; todo allow player to drop/destroy any they've collected that they don't want? Though that could break the quest if they accidentally drop good ones, and can't pick them up again - would equal auto failure. If always get same reward, doesn't matter either, just affects hand-in dialogue

#|

? (not (active-p 'return-mushrooms))
| ! eval (activate 'return-mushrooms)

|#

(quest:interaction :name mushrooms2 :interactable shrooms2 :repeatable T :variables (batch1 batch2 batch3) :dialogue "
~ player
| //Mushrooms site 2//
- [(not (var 'batch1)) Take 3 Honey Fungus|]
  | I take 3 honey fungus
  ! eval (store 'mushroom-good-1 3)
  ! eval (setf (var 'batch1) T)
- [(not (var 'batch2)) //Take 7 Dusky Puffball//|]
  | I take 7 dusky puffball
  ! eval (store 'mushroom-good-2 7)
  ! eval (setf (var 'batch2) T)
- [(not (var 'batch3)) //Take 2 the grey knight//|]
  | I take 2 the grey knight
  ! eval (store 'mushroom-bad-1 2)
  ! eval (setf (var 'batch3) T)
- Take none
? (var 'batch1)
| ? (var 'batch2)
| | ? (var 'batch3)
| | | ! eval (deactivate 'mushrooms2)
? (<= 25 (+ (item-count 'mushroom-good-1) (item-count 'mushroom-good-2)) )
| ? (not (active-p 'return-mushrooms))
| | ! eval (activate 'return-mushrooms)
")

(quest:interaction :name mushrooms3 :interactable shrooms3 :repeatable T :variables (batch1 batch2) :dialogue "
~ player
| //Mushrooms site 3//
- [(not (var 'batch1)) //Take 4 Dusky Puffball//|]
  | I take 4 dusky puffball
  ! eval (store 'mushroom-good-2 4)
  ! eval (setf (var 'batch1) T)
- [(not (var 'batch2)) Take 5 Honey Fungus|]
  | I take 5 honey fungus
  ! eval (store 'mushroom-good-1 5)
  ! eval (setf (var 'batch2) T)
- Take none
? (var 'batch1)
| ? (var 'batch2)
| | ! eval (deactivate 'mushrooms3)
? (<= 25 (+ (item-count 'mushroom-good-1) (item-count 'mushroom-good-2)) )
| ? (not (active-p 'return-mushrooms))
| | ! eval (activate 'return-mushrooms)
")

(quest:interaction :name mushrooms4 :interactable shrooms4 :repeatable T :variables (batch1 batch2 batch3) :dialogue "
~ player
| //Mushrooms site 4//
- [(not (var 'batch1)) Take 4 Honey Fungus|]
  | I take 4 honey fungus
  ! eval (store 'mushroom-good-1 4)
  ! eval (setf (var 'batch1) T)
- [(not (var 'batch2)) //Take 10 the grey knight//|]
  | I take 10 the grey knight
  ! eval (store 'mushroom-bad-1 10)
  ! eval (setf (var 'batch2) T)
- [(not (var 'batch3)) //Take 5 Dusky Puffball//|]
  | I take 5 dusky puffball
  ! eval (store 'mushroom-good-2 5)
  ! eval (setf (var 'batch3) T)
- Take none
? (var 'batch1)
| ? (var 'batch2)
| | ? (var 'batch3)
| | | ! eval (deactivate 'mushrooms4)
? (<= 25 (+ (item-count 'mushroom-good-1) (item-count 'mushroom-good-2)) )
| ? (not (active-p 'return-mushrooms))
| | ! eval (activate 'return-mushrooms)
")

(quest:interaction :name mushrooms5 :interactable shrooms5 :repeatable T :variables (batch1 batch2 batch3) :dialogue "
~ player
| //Mushrooms site 5//
- [(not (var 'batch1)) //Take 8 the grey knight//|]
  | I take 8 the grey knight
  ! eval (store 'mushroom-bad-1 8)
  ! eval (setf (var 'batch1) T)
- [(not (var 'batch2)) //Take 9 Dusky Puffball//|]
  | I take 9 dusky puffball
  ! eval (store 'mushroom-good-2 9)
  ! eval (setf (var 'batch2) T)
- [(not (var 'batch3)) Take 6 Honey Fungus|]
  | I take 6 honey fungus
  ! eval (store 'mushroom-good-1 6)
  ! eval (setf (var 'batch3) T)
- Take none
? (var 'batch1)
| ? (var 'batch2)
| | ? (var 'batch3)
| | | ! eval (deactivate 'mushrooms5)
? (<= 25 (+ (item-count 'mushroom-good-1) (item-count 'mushroom-good-2)) )
| ? (not (active-p 'return-mushrooms))
| | ! eval (activate 'return-mushrooms)
")
; todo place more lucrative/dangerous ones in harder to reach places

#|
  
  
|#