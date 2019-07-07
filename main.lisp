(in-package #:org.shirakumo.fraf.leaf)

(define-asset (leaf player) image
    #p"player.png"
  :min-filter :nearest
  :mag-filter :nearest)

(define-asset (leaf profile) image
    #p"profile.png"
  :min-filter :nearest
  :mag-filter :nearest)

(define-asset (leaf ice) image
    #p"ice.png"
  :min-filter :nearest
  :mag-filter :nearest)

(define-asset (leaf icey-mountains) image
    #p "icey-mountains.png"
  :min-filter :nearest
  :mag-filter :nearest)

(defclass empty-level (level)
  ()
  (:default-initargs :name :untitled))

(defmethod initialize-instance :after ((level empty-level) &key)
  (let ((region (make-instance 'region))
        (chunk (make-instance 'chunk :tileset (asset 'leaf 'ice))))
    (enter region level)
    (enter chunk region)
    (enter (make-instance 'point-light :radius 64.0) chunk)
    (enter (make-instance 'elevator :texture (asset 'leaf 'ice)) chunk)
    (enter (make-instance 'player :location (vec 64 64)) region)))

(defclass main (trial:main)
  ((scene :initform NIL)
   (save :initform (make-instance 'save :name "test") :accessor save))
  (:default-initargs :clear-color (vec 2/17 2/17 2/17)
                     :title "Leaf - 0.0.0"
                     :width 1280
                     :height 720))

(defmethod initialize-instance ((main main) &key map)
  (call-next-method)
  (setf (scene main)
        (if map
            (make-instance 'level :file (pool-path 'leaf map))
            (make-instance 'empty-level))))

(defmethod setup-rendering :after ((main main))
  (disable :cull-face)
  (disable :scissor-test)
  (disable :depth-test))

(defmethod update ((main main) tt dt)
  (issue (scene main) 'trial:tick :tt tt :dt dt)
  (process (scene main)))

(defmethod save-state ((main main) (_ (eql T)))
  (save-state main (save main)))

(defmethod load-state ((main main) (_ (eql T)))
  (load-state main (save main)))

(defmethod (setf scene) :after (scene (main main))
  (setf +level+ scene))

(defmethod finalize :after ((main main))
  (setf +level+ NIL))

(defun launch (&rest initargs)
  (apply #'trial:launch 'main initargs))

(defmethod setup-scene ((main main) scene)
  (enter (make-instance 'textbox) scene)
  (enter (make-instance 'inactive-pause-menu) scene)
  (enter (make-instance 'inactive-editor) scene)
  (enter (make-instance 'camera) scene)
  (let* ((render (make-instance 'render-pass))
         (blink-pass (make-instance 'blink-pass))
         (bokeh-pass (make-instance 'hex-bokeh-pass)))
    (enter render scene)
    ;(connect (flow:port render 'color) (flow:port blink-pass 'previous-pass) scene)
    ;(connect (flow:port blink-pass 'color) (flow:port bokeh-pass 'previous-pass) scene)
    ))

