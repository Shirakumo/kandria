;;; Consistency checks.
#-sbcl (error "You must run SBCL.")
#-(or X86-64 ARM64) (error "Platforms other than AMD64/ARM64 are not supported.")

#+sbcl
(when (<= (floor (sb-ext:dynamic-space-size) (* 1024 1024 1024)) 1)
  (error "You must run SBCL with at least 2GB of heap.
Either run the setup.lisp file directly, or start SBCL with
  sbcl --dynamic-space-size 4GB"))

#+sbcl
(sb-ext:assert-version->= 2 2)

(defpackage #:org.shirakumo.fraf.kandria.fish)
(defpackage #:org.shirakumo.fraf.kandria.item)
(defpackage #:org.shirakumo.fraf.trial.bvh2
  (:use #:cl #:org.shirakumo.fraf.math.vectors)
  (:import-from #:org.shirakumo.fraf.trial #:location #:bsize)
  (:export
   #:bvh
   #:make-bvh
   #:bvh-insert
   #:bvh-remove
   #:bvh-update
   #:bvh-check
   #:bvh-print
   #:bvh-lines
   #:bvh-reinsert-all
   #:call-with-contained
   #:call-with-overlapping
   #:do-fitting))

(defpackage #:kandria
  (:nicknames #:org.shirakumo.fraf.kandria)
  (:use #:cl+trial)
  (:shadow #:main #:launch #:tile #:block
           #:located-entity #:sized-entity #:sprite-entity
           #:camera #:light #:shadow-map-pass #:tile-data
           #:shadow-render-pass #:action #:editor-camera
           #:animatable #:sprite-data #:sprite-animation
           #:commit #:prompt #:in-view-p #:layer #:*modules*
           #:hit #:hit-location #:hit-normal #:make-hit
           #:box #:activate #:deactivate #:rotated-entity
           #:displacement-pass)
  (:import-from #:org.shirakumo.fraf.trial.bvh2 #:do-fitting)
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
   #+trial-steam (#:steam #:org.shirakumo.fraf.steamworks)
   #+trial-steam (#:steam* #:org.shirakumo.fraf.steamworks.cffi)
   (#:notify #:org.shirakumo.fraf.trial.notify)
   (#:bvh #:org.shirakumo.fraf.trial.bvh2)
   (#:markless #:org.shirakumo.markless)
   (#:components #:org.shirakumo.markless.components)
   (#:depot #:org.shirakumo.depot)
   (#:action-list #:org.shirakumo.fraf.action-list)
   (#:sequences #:org.shirakumo.trivial-extensible-sequences)
   (#:filesystem-utils #:org.shirakumo.filesystem-utils)
   (#:promise #:org.shirakumo.promise)
   (#:modio #:org.shirakumo.fraf.modio)
   (#:mem #:org.shirakumo.memory-regions)
   (#:machine-state #:org.shirakumo.machine-state)
   (#:v #:org.shirakumo.verbose))
  ;; ui/general.lisp
  (:export
   #:ui
   #:icon
   #:button
   #:label
   #:deferrer
   #:pane
   #:ui-pass
   #:panels
   #:find-panel
   #:toggle-panel
   #:show-panel
   #:hide-panel
   #:panel
   #:active-p
   #:shown-p
   #:show
   #:hide
   #:popup
   #:fullscreen-panel
   #:action-set-change-panel
   #:menuing-panel
   #:pausing-panel
   #:messagebox
   #:message
   #:with-ui-task)
  ;; ui/popup.lisp
  (:export
   #:popup-layout
   #:popup-button
   #:popup-label
   #:popup-line
   #:popup-panel
   #:info-panel
   #:prompt-panel
   #:prompt
   #:prompt*
   #:query-panel
   #:query
   #:query*
   #:spinner-panel)
  ;; versions/save-v0.lisp
  (:export
   #:save-v2)
  ;; versions/world-v0.lisp
  (:export
   #:world-v0)
  ;; camera.lisp
  (:export
   #:camera
   #:view-scale
   #:intended-view-scale
   #:target-size
   #:target
   #:intended-location
   #:zoom
   #:intended-zoom
   #:shake-timer
   #:shake-intensity
   #:rumble-intensity
   #:offset
   #:fix-offset
   #:snap-to-target
   #:shake-camera
   #:rumble
   #:duck-camera
   #:in-view-p)
  ;; helpers.lisp
  (:export
   #:kandria
   #:sound
   #:music
   #:recompute
   #:1x
   #:16x
   #:placeholder
   #:collider
   #:parent-entity
   #:children
   #:child-count
   #:make-child-entity
   #:base-entity
   #:name
   #:entity-at-point
   #:initargs
   #:located-entity
   #:location
   #:facing-entity
   #:direction
   #:rotated-entity
   #:angle
   #:sized-entity
   #:bsize
   #:resize
   #:sprite-entity
   #:size
   #:offset
   #:layer-index
   #:fit-to-bsize
   #:color-mask
   #:game-entity
   #:velocity
   #:state
   #:frame-velocity
   #:chunk
   #:oob
   #:transition-event
   #:on-complete
   #:kind
   #:transition-active-p
   #:nearby-p)
  ;; interactable.lisp
  (:export
   #:interactable
   #:action
   #:interact
   #:interactable-p
   #:interactable-priority
   #:description
   #:dialog-entity
   #:interactions
   #:default-interaction
   #:interactable-sprite
   #:interactable-animated-sprite
   #:profile
   #:nametag
   #:pitch
   #:basic-door
   #:train-door
   #:passage
   #:locked-door
   #:key
   #:unlocked-p
   #:save-point
   #:station
   #:list-stations
   #:train
   #:place-marker
   #:audio-marker
   #:bomb-marker)
  ;; main.lisp
  (:export
   #:main
   #:scene
   #:state
   #:timestamp
   #:loader
   #:game-speed
   #:changes-saved-p
   #:session-time
   #:total-play-time
   #:load-game
   #:reset
   #:launch
   #:with-saved-changes-prompt)
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
   #:unload-module
   #:find-module
   #:define-module
   #:register-worlds)
  ;; quest.lisp
  (:export
   #:storyline
   #:default-interactions
   #:quest
   #:clock
   #:start-time
   #:visible-p
   #:experience-reward
   #:quest-started
   #:quest-completed
   #:quest-failed
   #:task-completed
   #:game-over
   #:task
   #:marker
   #:interaction
   #:source
   #:repeatable-p
   #:auto-triggerstub-interaction
   #:assembly
   #:load-default-interactions
   #:define-sequence-quest)
  ;; serialization.lisp
  (:export
   #:version
   #:ensure-version
   #:encode-payload
   #:decode-payload
   #:define-encoder
   #:define-decoder
   #:define-slot-coders
   #:define-additional-slot-coders)
  ;; toolkit.lisp
  (:export
   #:+tile-size+
   #:+layer-count+
   #:+base-layer+
   #:+tiles-in-view+
   #:+world+
   #:+settings+
   #:+player-movement-data+
   #:p!
   #:initial-timestamp
   #:format-absolute-time
   #:format-relative-time
   #:unit
   #:random*
   #:damp*
   #:solid
   #:half-solid
   #:resizable
   #:creatable
   #:list-creatable-classes
   #:hit
   #:hit-object
   #:hit-location
   #:hit-time
   #:hit-normal
   #:make-hit
   #:transfer-hit
   #:scan
   #:is-collider-for
   #:collides-p
   #:contained-p
   #:scan-collision-for
   #:collide
   #:entity-at-point
   #:contained-p
   #:within-p
   #:in-bounds-p
   #:find-chunk
   #:closest-acceptable-location
   #:mouse-world-pos
   #:world-screen-pos
   #:mouse-tile-pos
   #:request-region
   #:switch-region
   #:switch-chunk
   #:change-time
   #:force-lighting
   #:load-complete
   #:unpausable
   #:ephemeral
   #:save-p
   #:enemy
   #:error-or
   #:case*
   #:ensure-unit
   #:ensure-location
   #:!
   #:or*
   #:language-string*
   #:u
   #:shorten-text
   #:text<)
  ;; trigger.lisp
  (:export
   #:trigger
   #:active-p
   #:one-time-trigger
   #:checkpoint
   #:story-trigger
   #:story-item
   #:target-status
   #:interaction-trigger
   #:walkntalk-trigger
   #:tween-trigger
   #:left
   #:right
   #:horizontal
   #:ease-fun
   #:sandstorm-trigger
   #:velocity
   #:dust-trigger
   #:zoom-trigger
   #:pan-trigger
   #:teleport-trigger
   #:target
   #:earthquake-trigger
   #:duration
   #:music-trigger
   #:track
   #:audio-trigger
   #:sound
   #:played-p
   #:shutter-trigger
   #:action-prompt
   #:action
   #:interrupt
   #:fullscreen-prompt-trigger
   #:title
   #:wind
   #:strength
   #:max-strength
   #:kind
   #:period)
  ;; world.lisp
  (:export
   #:+world+
   #:world
   #:id
   #:title
   #:author
   #:version
   #:description
   #:depot
   #:storyline
   #:time-scale
   #:clock-scale
   #:timestamp
   #:camera
   #:pause-game
   #:unpause-game
   #:saving-possible-p
   #:save-point-available-p
   #:pausing-possible-p
   #:start-action-list
   #:no-world-found
   #:find-world
   #:load-world
   #:minimal-load-world
   #:save-world
   #:world-loaded))
