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
           #:commit #:prompt #:in-view-p #:layer #:*modules*
           #:hit #:hit-location #:hit-normal #:make-hit
           #:box)
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
   #:unload-module
   #:find-module
   #:define-module
   #:register-worlds)
  ;; quest.lisp
  (:export
   #:define-sequence-quest)
  ;; world.lisp
  (:export
   #:+world+
   #:world-loaded))

;;; Consistency checks.
#-sbcl (error "You must run SBCL.")
#-x86-64 (error "Platforms other than AMD64 are not supported.")

(when (<= (floor (sb-ext:dynamic-space-size) (* 1024 1024 1024)) 1)
  (error "You must run SBCL with at least 2GB of heap.
Either run the setup.lisp file directly, or start SBCL with
  sbcl --dynamic-space-size 4GB"))

(let ((v (lisp-implementation-version))
      (p 0))
  (flet ((next ()
           (let ((dot (position #\. v :start p)))
             (prog1 (parse-integer v :start p :end dot)
               (setf p (1+ dot))))))
    (when (or (< (next) 2) (< (next) 2))
      (error "Your SBCL version is too old. Please update."))))
