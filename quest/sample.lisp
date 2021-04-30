;; -*- mode: poly-dialog; -*-

(define-storyline storyline
  :bindings (global)
  (quest-1
   :title "Test quest"
   :author "Some guy"
   :on-activate (task-1)
   (task-1
    :title "Do the test"
    :on-activate (interaction-1)
    (:interaction interaction-1 "
~ player
| Hey man"))))

(define-quest (storyline quest-2)
  :title "Other quest"
  :author "Some guy"
  :on-activate (task-1))

(define-task (storyline quest-2 task-1)
  :title "Do some other test"
  :on-activate (action-1))

(define-action (storyline quest-2 task-1 action-1)
  (spawn 'wolf))

(define-interaction a "
# Section 1
~ Okey, nice!
| a
! eval something
- test this
  | bla bla
- okey
  ! very niceau
")
