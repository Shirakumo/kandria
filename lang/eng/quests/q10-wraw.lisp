;; -*- mode: poly-dialog; -*-
(in-package #:org.shirakumo.fraf.kandria)

(quest:define-quest (kandria q10-wraw)
  :author "Tim White"
  :title "The Wraw"
  :description "Fi wants me to go deep into Wraw territory itself, to try and determine what their leader, Zelah, is planning."
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
| Oh, you're back... I still need you to \"go into Wraw territory\"(orange) and \"find out what Zelah is up to\"(orange).
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
? (complete-p 'wraw-mechs)
| ~ player
| | (:embarassed)\"It's at a scale to manufacture enough mechs and weapons for an \"invasion of the entire valley\"(orange)...\"(light-gray, italic)
| | (:normal)\"I need to \"contact Fi\"(orange).\"(light-gray, italic)
| | \"... \"FFCS can't punch through\"(orange) - whether it's magnetic interference from the magma, or the Wraw themselves I'm not sure.\"(light-gray, italic)
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
   :marker '(chunk-6041 1800)
   :invariant T
   :condition all-complete
   :on-activate (mechs)
   :on-complete NIL
   :visible NIL

   ;; TODO fix markless formatting for Genera line, so escaped quotes can be part of the light-gray and italic wrapper
   (:interaction mechs
    :interactable q10-mechs
    :dialogue "
~ player
| \"This mech was built from drills and turbines. They all were, these power suits too.\"(light-gray, italic)
| \"This one has an interface port, which could forcibly extract data from an android.\"(light-gray, italic)
| (:thinking)\"Perhaps I can check what this mech's purpose is...\"(light-gray, italic)
| (:normal)\"Just gotta stick my finger in here...\"(light-gray, italic) (:giggle)\"Pardon me.\"(light-gray, italic)
| (:normal)\"Yep, designed to subdue an android.\"(light-gray, italic)
| (:thinking)\"Make that\"(light-gray, italic)  \"androids\"(light-gray)\", judging from these weapon configurations.\"(light-gray, italic)
| (:normal)\"Hang on, what's this?\"(light-gray, italic)
| \"\"... Neutralise additional android targets: \"Genera\"(red) in the \"western mountains\"(red). Targets unknown.\"(light-gray, italic)\"
| (:thinking)\"... A faction of androids? In the mountains?\"(light-gray, italic)
| \"I'm not alone?\"(light-gray, italic)
? (complete-p 'wraw-warehouse)
| | (:embarassed)\"Given the raw materials I saw in the warehouse, their manufacturing ambitions are __HUGE__.\"(light-gray, italic)
| | (:normal)\"As in,\"(light-gray, italic) \"\"invading the entire valley\"(orange, italic)\" \"huge.\"(light-gray, italic)
  
~ player
| (:embarassed)Ouch!... Power surge from the mech.
| (:normal)This one is activating...
! eval (activate 'q10-boss)
")))
