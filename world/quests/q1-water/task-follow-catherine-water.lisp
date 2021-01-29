(:name follow-catherine-water
 :title "Follow Catherine"
 :description "I should follow Catherine to the location of the leaking water pipes, and protect her so she can repair them."
 :invariant T
 :condition quest:all-complete
 :on-activate (fi-check pot-check tent-check sign-main-check sign-check landslide-check fire-check beacon-check corpse-check cave-in-check android-check home-check home-tent-check))