(define-sequence-quest (kandria q0-surface)
  :author "Tim White"
  :title ""
  :visible NIL
  (:eval (complete 'tutorial)
         (stop-following 'catherine)
         (ensure-nearby 'tutorial-end 'catherine))
  ;; TODO: the last player emotion in the choices is the one that will render; have it change per highlighted choice?
  ;; TODO: replace (Lie) with [Lie] as per RPG convention, and to save parenthetical expressions for asides - currently square brackets not rendering correctly though
  ;; REMARK: ^ Does \[Lie\] not work?
  (:interact (catherine :now T)
             "~ catherine
| (:cheer)__Tada!__ Here we are.
| What do you think...?
~ player
- The city was destroyed.
  ~ catherine
  | (:excited)Yay, your voice box works too.
  | Yep. This is home.
- It's nice.
  ~ catherine
  | (:excited)Yay, your voice box works too.
  | I knew you'd love our home.
- (Lie) It's nice.
  ~ catherine
  | (:excited)Yay, your voice box works too.
  | Really? You like it? I knew you'd love our home.
- You live here?
  ~ catherine
  | (:excited)Yay, your voice box works too.
  | Yep. Pretty amazing home, huh?
~ catherine
| And come look at this - I guarantee you won't have ever seen anything like it.
! eval (complete 'tutorial)
! eval (activate 'q0-settlement-arrive)
  "))