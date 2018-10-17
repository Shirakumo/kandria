(in-package #:org.shirakumo.fraf.leaf)

(define-shader-subject player (vertex-entity located-entity)
  ()
  (:default-initargs
   :vertex-array (asset 'leaf 'player)
   :name :player))
