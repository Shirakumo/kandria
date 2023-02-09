(defpackage #:org.shirakumo.fraf.kandria.fish)
(defpackage #:org.shirakumo.fraf.kandria.item)

(defpackage #:kandria
  (:nicknames #:org.shirakumo.fraf.kandria)
  (:use #:cl+trial)
  (:shadow #:main #:launch #:tile #:block
           #:located-entity #:sized-entity #:sprite-entity
           #:camera #:light #:shadow-map-pass #:tile-data
           #:shadow-render-pass #:action #:editor-camera
           #:animatable #:sprite-data #:sprite-animation
           #:commit #:prompt #:in-view-p #:layer #:*modules*)
  (:local-nicknames
   (#:fish #:org.shirakumo.fraf.kandria.fish)
   (#:item #:org.shirakumo.fraf.kandria.item)
   (#:dialogue #:org.shirakumo.fraf.speechless)
   (#:quest #:org.shirakumo.fraf.kandria.quest)
   (#:alloy #:org.shirakumo.alloy)
   (#:trial-alloy #:org.shirakumo.fraf.trial.alloy)
   (#:simple #:org.shirakumo.alloy.renderers.simple)
   (#:presentations #:org.shirakumo.alloy.renderers.simple.presentations)
   (#:opengl #:org.shirakumo.alloy.renderers.opengl)
   (#:colored #:org.shirakumo.alloy.colored)
   (#:colors #:org.shirakumo.alloy.colored.colors)
   (#:animation #:org.shirakumo.alloy.animation)
   (#:file-select #:org.shirakumo.file-select)
   (#:gamepad #:org.shirakumo.fraf.gamepad)
   (#:harmony #:org.shirakumo.fraf.harmony.user)
   (#:trial-harmony #:org.shirakumo.fraf.trial.harmony)
   (#:mixed #:org.shirakumo.fraf.mixed)
   (#:steam #:org.shirakumo.fraf.steamworks)
   (#:steam* #:org.shirakumo.fraf.steamworks.cffi)
   (#:notify #:org.shirakumo.fraf.trial.notify)
   (#:bvh #:org.shirakumo.fraf.trial.bvh2)
   (#:markless #:org.shirakumo.markless)
   (#:components #:org.shirakumo.markless.components)
   (#:depot #:org.shirakumo.depot)
   (#:action-list #:org.shirakumo.fraf.action-list)
   (#:sequences #:org.shirakumo.trivial-extensible-sequences)
   (#:filesystem-utils #:org.shirakumo.filesystem-utils)
   (#:promise #:org.shirakumo.promise)
   (#:modio #:org.shirakumo.fraf.modio))
  (:export
   #:launch)
  ;; ui/general.lisp
  (:export
   #:show
   #:show-panel)
  ;; ui/popup.lisp
  (:export
   #:info-panel)
  ;; module.lisp
  (:export
   #:module
   #:name
   #:title
   #:version
   #:author
   #:description
   #:upstream
   #:preview
   #:module-root
   #:module-package
   #:list-worlds
   #:list-modules
   #:load-module
   #:find-module
   #:define-module
   #:register-worlds)
  ;; world.lisp
  (:export
   #:+world+
   #:world-loaded))
