(:name return-mushrooms
 :title "I've collected enough mushrooms for Catherine"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (mushrooms-return)
 :on-complete NIL)

(quest:interaction :name mushrooms-return :title "Return the mushrooms" :interactable catherine :dialogue "
~ catherine
| How was your mushrooming? Let's see what you've got.
? (= 25 (+ (item-count 'mushroom-good-1) (item-count 'mushroom-good-2)) )
| | Wow, you got exactly what I asked for. I guess I shouldn't be surprised that you're so precise.
|? (< 25 (+ (item-count 'mushroom-good-1) (item-count 'mushroom-good-2)) )
| | Wow, you got even more than I asked for!
? (have 'mushroom-good-1)
| | Flower fungus, nice. I'll get these to Fi and straight into the cooking pot.
| | Apparently if you eat them raw they'll give you the skitters. One day I'll test that theory.
| ! eval (retrieve 'mushroom-good-1 (item-count 'mushroom-good-1))
? (have 'mushroom-good-2)
| | Rusty puffball, great. These are my favourite - I made my neckerchief from them, believe or not.
| | Though that was just so I had a mask so their spores wouldn't give me lung disease.
| ! eval (retrieve 'mushroom-good-2 (item-count 'mushroom-good-2))
? (have 'mushroom-bad-1)
| | Oh, you got some black knights, huh? Not a lot I can do with them.
| | Don't worry, I'll burn them later - don't want anyone eating them by accident.
| ! eval (retrieve 'mushroom-bad-1 (item-count 'mushroom-bad-1))
  
| You know, it might not seem like much, but hauls like these could be the different between us making it and not making it.
| We owe you big time. Here, take these parts, you've definitely earned them.
| See you around, Stranger!
! eval (store 'parts 10)
! eval (deactivate 'mushrooms-return)
? (not (complete-p 'mushroom-sites))
| ! eval (complete 'mushroom-sites)
")
;; TODO: rewards - fixed, not based on ratio of good/bad mushrooms?

#|



|#
