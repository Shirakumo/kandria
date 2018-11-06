(in-package #:org.shirakumo.fraf.leaf)

(define-asset (leaf ground) image
    #p"ground.png")

(define-asset (leaf decals) image
    #p"decals.png")

(define-asset (leaf surface) image
    #p"surface.png")

(define-asset (leaf player) image
    #p"player.png"
  :min-filter :nearest
  :mag-filter :nearest)

(define-asset (leaf background) image
    #p"background.png"
  :min-filter :nearest
  :mag-filter :nearest
  :wrapping '(:repeat :clamp-to-edge :clamp-to-edge))

(define-asset (leaf particle) mesh
    (make-rectangle 1 1))

(define-asset (leaf player-mesh) mesh
    (make-rectangle 16 16))

(define-asset (leaf big) mesh
    (make-rectangle 64 64))

(define-asset (leaf square) mesh
    (make-rectangle 8 8 :align :topleft))

(defclass main (trial:main)
  ((scene :initform NIL))
  (:default-initargs :clear-color (vec 61/255 202/255 245/255)
                     :title "Leaf - 0.0.0"))

(defmethod initialize-instance ((main main) &key map)
  (call-next-method)
  (setf (scene main)
        (if map
            (make-instance 'level :file (pool-path 'leaf map))
            (make-instance 'empty-level))))

(defmethod setup-rendering :after ((main main))
  (disable :cull-face))

(defmethod update ((main main) tt dt)
  (issue (scene main) 'trial:tick :tt tt :dt dt)
  (issue (scene main) 'post-tick)
  (process (scene main)))

(defmethod (setf scene) :after (scene (main main))
  (setf +level+ scene))

(defmethod finalize :after ((main main))
  (setf +level+ NIL))

(defun launch (&rest initargs)
  (apply #'trial:launch 'main initargs))

(defmethod setup-scene ((main main) scene)
  (enter (make-instance 'inactive-editor) scene)
  (enter (make-instance 'camera) scene)
  (let* ((render (make-instance 'render-pass))
         (blink-pass (make-instance 'blink-pass))
         (bokeh-pass (make-instance 'hex-bokeh-pass)))
    (enter render scene)
    ;(connect (flow:port render 'color) (flow:port blink-pass 'previous-pass) scene)
    ;(connect (flow:port blink-pass 'color) (flow:port bokeh-pass 'previous-pass) scene)
    ))

(defclass empty-level (level)
  ())

(defmethod initialize-instance :after ((level empty-level) &key)
  (let ((size (list 1 1)))
    (enter (make-instance 'chunk :size size) level)))

