(defpackage #:kandria
  (:nicknames #:org.shirakumo.fraf.kandria)
  (:use #:cl+trial)
  (:import-from #:org.shirakumo.fraf.trial.harmony #:sound)
  (:shadow #:main #:launch #:tile #:block
           #:located-entity #:sized-entity #:sprite-entity
           #:camera #:light #:shadow-map-pass
           #:shadow-render-pass #:action #:editor-camera
           #:animatable #:sprite-data #:sprite-animation
           #:commit #:config-directory #:prompt)
  (:local-nicknames
   (#:dialogue #:org.shirakumo.fraf.speechless)
   (#:quest #:org.shirakumo.fraf.kandria.quest)
   (#:alloy #:org.shirakumo.alloy)
   (#:trial-alloy #:org.shirakumo.fraf.trial.alloy)
   (#:simple #:org.shirakumo.alloy.renderers.simple)
   (#:presentations #:org.shirakumo.alloy.renderers.simple.presentations)
   (#:opengl #:org.shirakumo.alloy.renderers.opengl)
   (#:colored #:org.shirakumo.alloy.colored)
   (#:colors #:org.shirakumo.alloy.colored.colors)
   (#:file-select #:org.shirakumo.file-select)
   (#:gamepad #:org.shirakumo.fraf.gamepad)
   (#:harmony #:org.shirakumo.fraf.harmony.user)
   (#:mixed #:org.shirakumo.fraf.mixed)
   (#:steam #:org.shirakumo.fraf.steamworks)
   (#:notify #:org.shirakumo.fraf.trial.notify))
  (:export
   #:launch
   #:launch-animation-editor))
