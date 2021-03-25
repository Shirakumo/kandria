(:name mushroom-sites
 :title "Find mushrooms"
 :description NIL
 :invariant T
 :condition NIL
 :on-activate (mushrooms1 mushrooms2 mushrooms3 mushrooms4 mushrooms5)
 :on-complete NIL
)
; //[? Here's a mushroom patch. | Found you, mushrooms. | Mushrooms located. | Mushrooms identified.] [? They look much more appetising on a plate. | People eat this stuff? | It looks and smells like mould. I suppose it's the same thing, more or less. | It looks like someone's insides if they were on the outside.]//
(quest:interaction :name mushrooms1 :interactable shrooms1 :repeatable T :variables (batch1 batch2) :dialogue "
~ player
| //[? It's a mushroom patch. | Found you, mushrooms. | Mushrooms located. | Mushrooms identified.]//
- [(not (var 'batch1)) //Take 6 flower fungi//|]
  | I pick 6 flower fungi and stow them in my internal compartment.
  | They're quite pretty. It seems a shame to eat them.
  ! eval (store 'mushroom-good-1 6)
  ! eval (setf (var 'batch1) T)
  < ending
- [(not (var 'batch2)) //Take 1 rusty puffball//|]
  | I pick 1 rusty puffball.
  | They makes clothes from these? Call me a fashion victim but I wouldn't be seen dead in them.
  ! eval (store 'mushroom-good-2 1)
  ! eval (setf (var 'batch2) T)
  < ending
- Take none
# ending
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
| //[? It's a mushroom patch. | Found you, mushrooms. | Mushrooms located. | Mushrooms identified.]//
- [(not (var 'batch1)) //Take 3 flower fungi//|]
  | I pick 3 flower fungi.
  | People eat this stuff?
  ! eval (store 'mushroom-good-1 3)
  ! eval (setf (var 'batch1) T)
  < ending
- [(not (var 'batch2)) //Take 7 rusty puffballs//|]
  | I pick 7 rusty puffballs.
  | They look and smell like mould. I suppose it's the same thing, more or less.
  ! eval (store 'mushroom-good-2 7)
  ! eval (setf (var 'batch2) T)
  < ending
- [(not (var 'batch3)) //Take 2 black knights//|]
  | I pick 2 black knights and stow them in my compartment.
  | They remind me of decaying frogspawn. Yet I've never seen decaying frogspawn...
  ! eval (store 'mushroom-bad-1 2)
  ! eval (setf (var 'batch3) T)
  < ending
- Take none
# ending
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
| //[? It's a mushroom patch. | Found you, mushrooms. | Mushrooms located. | Mushrooms identified.]//
- [(not (var 'batch1)) //Take 4 rusty puffballs//|]
  | I pick 4 rusty puffballs and stow them in my compartment.
  ! eval (store 'mushroom-good-2 4)
  ! eval (setf (var 'batch1) T)
  < ending
- [(not (var 'batch2)) //Take 5 flower fungi//|]
  | I pick 5 flower fungi.
  ! eval (store 'mushroom-good-1 5)
  ! eval (setf (var 'batch2) T)
  < ending
- Take none
# ending
? (var 'batch1)
| ? (var 'batch2)
| | ! eval (deactivate 'mushrooms3)
? (<= 25 (+ (item-count 'mushroom-good-1) (item-count 'mushroom-good-2)) )
| ? (not (active-p 'return-mushrooms))
| | ! eval (activate 'return-mushrooms)
")

(quest:interaction :name mushrooms4 :interactable shrooms4 :repeatable T :variables (batch1 batch2 batch3) :dialogue "
~ player
| //[? It's a mushroom patch. | Found you, mushrooms. | Mushrooms located. | Mushrooms identified.]//
- [(not (var 'batch1)) //Take 4 flower fungi//|]
  | I pick 4 flower fungus.
  ! eval (store 'mushroom-good-1 4)
  ! eval (setf (var 'batch1) T)
  < ending
- [(not (var 'batch2)) //Take 10 black knights//|]
  | I pick 10 black knights.
  ! eval (store 'mushroom-bad-1 10)
  ! eval (setf (var 'batch2) T)
  < ending
- [(not (var 'batch3)) //Take 5 rusty puffballs//|]
  | I pick 5 rusty puffballs and stow them in my compartment.
  | I suppose truffles would be too much to ask for.
  ! eval (store 'mushroom-good-2 5)
  ! eval (setf (var 'batch3) T)
  < ending
- Take none
# ending
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
| //[? It's a mushroom patch. | Found you, mushrooms. | Mushrooms located. | Mushrooms identified.]//
- [(not (var 'batch1)) //Take 8 black knights//|]
  | I pick 8 black knights and stow them in my compartment.
  | They look like someone's insides if they were on the outside. That's probably what they'd do to you too.
  ! eval (store 'mushroom-bad-1 8)
  ! eval (setf (var 'batch1) T)
  < ending
- [(not (var 'batch2)) //Take 9 rusty puffballs//|]
  | I pick 9 rusty puffballs.
  | Why do they look like an alien parasite from an ancient B-movie?
  ! eval (store 'mushroom-good-2 9)
  ! eval (setf (var 'batch2) T)
  < ending
- [(not (var 'batch3)) //Take 6 flower fungi//|]
  | I pick 6 flower fungi.
  ! eval (store 'mushroom-good-1 6)
  ! eval (setf (var 'batch3) T)
  < ending
- Take none
# ending
? (var 'batch1)
| ? (var 'batch2)
| | ? (var 'batch3)
| | | ! eval (deactivate 'mushrooms5)
? (<= 25 (+ (item-count 'mushroom-good-1) (item-count 'mushroom-good-2)) )
| ? (not (active-p 'return-mushrooms))
| | ! eval (activate 'return-mushrooms)
")

#|
  
  
|#