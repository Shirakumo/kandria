(:name return-mushrooms
 :title "I've collected enough mushrooms for Catherine, or I could collect more"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (mushrooms-return)
 :on-complete NIL
)

(quest:interaction :name mushrooms-return :title "I've got mushrooms" :interactable catherine :dialogue "
~ catherine
| How was your mushrooming? Let's see what you've got.
? (= 25 (+ (item-count 'mushroom-good-1) (item-count 'mushroom-good-2)) )
| | Wow you got exactly what I asked for
|? (< 25 (+ (item-count 'mushroom-good-1) (item-count 'mushroom-good-2)) )
| | Wow you got more than what I asked for.
? (have 'mushroom-good-1)
| | These are good for food.
| ! eval (retrieve 'mushroom-good-1 (item-count 'mushroom-good-1))
? (have 'mushroom-good-2)
| | These are good for textiles.
| ! eval (retrieve 'mushroom-good-2 (item-count 'mushroom-good-2))
? (have 'mushroom-bad-1)
| | Oh you got some bad ones too. Oh well.
| ! eval (retrieve 'mushroom-bad-1 (item-count 'mushroom-bad-1))
  
| Here have a reward!
! eval (store 'parts 10)
! eval (deactivate 'mushrooms-return)
? (not (complete-p 'mushroom-sites))
| ! eval (complete 'mushroom-sites)
")
; todo empty inventory - dynamic quantity?
; todo rewards - fixed, not based on ratio of good/bad mushrooms

#|



|#