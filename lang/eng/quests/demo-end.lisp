;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria demo-end)
  :author "Nicolas Hafner"
  :title "Demo end"
  :visible NIL
  :on-activate (wait-for-completion)
  (wait-for-completion
   :title ""
   :condition (complete-p 'sq1-leaks 'sq2-mushrooms 'sq3-race)
   :on-complete (show-screen))
  (show-screen
   :title ""
   :on-activate (activate)
   (:action activate (show-panel 'end-screen))))

