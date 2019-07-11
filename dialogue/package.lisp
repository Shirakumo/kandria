(defpackage #:org.shirakumo.fraf.leaf.dialogue.components
  (:use #:cl #:org.shirakumo.markless.components)
  (:shadowing-import-from #:cl #:list #:number #:set #:variable #:warning #:error #:float #:labels)
  (:shadow #:setf #:go #:speed #:map #:eval)
  (:local-nicknames
   (#:markless #:org.shirakumo.markless))
  (:export
   #:jump
   #:placeholder
   #:form
   #:emote
   #:conditional-part
   #:choices
   #:conditional
   #:clauses
   #:clue
   #:go
   #:speed
   #:camera-instruction
   #:duration
   #:shake
   #:move
   #:location
   #:zoom
   #:roll
   #:angle
   #:show
   #:map
   #:location
   #:setf
   #:place
   #:eval))

(defpackage #:org.shirakumo.fraf.leaf.dialogue.syntax
  (:use #:cl)
  (:local-nicknames
   (#:components #:org.shirakumo.fraf.leaf.dialogue.components)
   (#:markless #:org.shirakumo.markless))
  (:export
   #:parser
   #:jump
   #:conditional
   #:placeholder
   #:emote
   #:part-separator
   #:conditional-part
   #:clue))

(defpackage #:org.shirakumo.fraf.leaf.dialogue.vm
  (:use #:cl)
  (:shadow #:compile #:eval)
  (:local-nicknames
   (#:components #:org.shirakumo.fraf.leaf.dialogue.components))
  (:export))
