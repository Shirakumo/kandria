(define-module hello-world)

(in-package #:org.shirakumo.fraf.kandria.mod.hello-world)

(defmethod load-module ((module hello-world))
  (if *context*
      (show-panel 'info-panel :text "Hello world!")
      (v:info :kandria.mod.hello-world "Hello world!")))
