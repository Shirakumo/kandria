(define-module 6632CE56-9F1B-6EB3-712D-CC0ED9083E62)

(in-package #:org.shirakumo.fraf.kandria.mod.6632CE56-9F1B-6EB3-712D-CC0ED9083E62)

(defmethod load-module ((module module))
  (if *context*
      (show-panel 'info-panel :text "Hello world!")
      (v:info :kandria.mod.hello-world "Hello world!")))

