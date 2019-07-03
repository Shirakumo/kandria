(in-package #:org.shirakumo.fraf.leaf)

(define-shader-subject moving-platform (lighted-sprite-entity game-entity solid)
  ())

(defmethod tick ((moving-platform moving-platform) ev)
  (nv+ (location moving-platform) (velocity moving-platform))
  (vsetf (velocity moving-platform)
         0 (/ (sin (tt ev)) 4)))
