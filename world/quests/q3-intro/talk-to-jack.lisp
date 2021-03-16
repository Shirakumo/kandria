(:name talk-to-jack
 :title "Talk to Jack"
 :description NIL
 :invariant T
 :condition all-complete
 :on-activate (talk-jack)
 :on-complete (q3-new-home)
)

(quest:interaction :name talk-jack :interactable jack :dialogue "
~ jack
| p/h Oh, it's you. Go find us new home
")
; jack: Don't bother to check in with your FFCS or whatever the fuck it's called - I'm busy. Besides, I'm sure you can handle yourself.
#|



|#