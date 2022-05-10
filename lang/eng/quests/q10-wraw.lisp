;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q10-wraw)
  :author "Tim White"
  :title "The Wraw"
  :description "Fi wants me to go deep into Wraw territory itself, to try and determine exactly what their leader, Zelah, is planning."
  :on-activate (wraw-objective wraw-warehouse wraw-mechs)

  (wraw-objective
   :title "Explore Wraw territory, beneath the Cerebat area"
   :invariant T
   :condition all-complete
   :on-complete NIL
   :on-activate T
   
  (:interaction reminder
    :interactable fi
    :repeatable T
    :dialogue "
~ fi
| Oh, you're back... I still need you to \"go into Wraw territory\"(orange) and \"find out exactly what Zelah is up to\"(orange).
| Be safe, and \"contact me as soon as you can\"(orange).
"))

  (wraw-warehouse
   :title ""
   :marker '(chunk-6031 1800)
   :invariant T
   :condition all-complete
   :on-activate (warehouse)
   :on-complete NIL
   :visible NIL

   ;; player will be collecting lots of these supplies themselves, so no need to over-explain them in the quest
   (:interaction warehouse
    :interactable q10-supplies
    :dialogue "
~ player
| \"This warehouse has plentiful supplies.\"(light-gray, italic)
| (:thinking)\"The coal and vats of oil indicate \"mass production\"(orange), on top of their already-considerable geothermal reserves.\"(light-gray, italic)
? (complete-p 'q10-boss)
| ~ player
| | (:embarassed)\"It's at a scale to manufacture enough mechs and weapons for an \"invasion of the entire valley\"(orange) - from the mountains to the coast...\"(light-gray, italic)
| | (:normal)\"I need to \"contact Fi\"(orange).\"(light-gray, italic)
| | \"... \"FFCS can't punch through\"(orange) - it's either magnetic interference from the magma, or the \"Wraw are on the move\"(orange).\"(light-gray, italic)
| | \"I'd better \"get out of here\"(orange) and \"deliver my report\"(orange).\"(light-gray, italic)
| ! eval (complete 'wraw-objective)
| ! eval (activate 'q10a-return-to-fi)
| ! eval (activate (unit 'wraw-border-1))
| ! eval (activate (unit 'wraw-border-2))
| ! eval (activate (unit 'wraw-border-3))
| ! eval (activate (unit 'station-east-lab-trigger))
| ! eval (activate (unit 'station-cerebat-trigger))
| ! eval (activate (unit 'station-semi-trigger))
| ! eval (activate (unit 'station-surface-trigger))
|?
| ~ player
| | I need to \"keep looking for more signs of their activity\"(orange).
"))

  (wraw-mechs
   :title ""
   :visible NIL
   :marker '(chunk-6041 1800)
   :invariant T
   :condition (complete-p 'q10-boss)))
