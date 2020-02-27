(in-package #:org.shirakumo.fraf.leaf)

(defclass tile-button (alloy:button)
  ((tileset :initarg :tileset :accessor tileset)))

(presentations:define-realization (ui tile-button)
  ((:icon simple:icon)
   (alloy:margins)
   (tileset alloy:renderable)
   :size (alloy:px-size (/ (width (tileset alloy:renderable)) +tile-size+)
                        (/ (height (tileset alloy:renderable)) +tile-size+))))

(presentations:define-update (ui tile-button)
  (:icon
   :shift (alloy:px-point (vx alloy:value) (vy alloy:value))))

(defmethod simple:icon ((renderer ui) bounds (image texture) &rest initargs)
  (apply #'make-instance 'simple:icon :image image initargs))

(defclass tile-info (alloy:label)
  ())

(defmethod alloy:text ((info tile-info))
  (format NIL "~3d / ~3d"
          (floor (vx (alloy:value info)))
          (floor (vy (alloy:value info)))))

(defclass tile-picker (alloy:structure)
  ())

(defmethod initialize-instance :after ((structure tile-picker) &key widget)
  (let* ((tileset (tileset (entity widget)))
         (layout (make-instance 'alloy:grid-layout :cell-margins (alloy:margins 1)
                                                   :col-sizes (loop repeat (/ (width tileset) +tile-size+) collect 18)
                                                   :row-sizes (loop repeat (/ (height tileset) +tile-size+) collect 18)))
         (focus (make-instance 'alloy:focus-list))
         (scroll (make-instance 'alloy:scroll-view :scroll T :layout layout :focus focus)))
    (dotimes (y (/ (height tileset) +tile-size+))
      (dotimes (x (/ (width tileset) +tile-size+))
        (let* ((tile (vec2 x (- (/ (height tileset) +tile-size+) y 1)))
               (element (make-instance 'tile-button :data (make-instance 'alloy:value-data :value tile)
                                                    :tileset tileset :layout-parent layout :focus-parent focus)))
          (alloy:on alloy:activate (element)
            (setf (tile-to-place widget) tile)))))
    (alloy:finish-structure structure scroll scroll)))

(alloy:define-widget chunk-widget (sidebar)
  ((show-all :initform T :accessor show-all :representation (alloy:switch))
   (layer :initform 0 :accessor layer :representation (alloy:ranged-slider :range '(-2 . +3) :grid 1))
   (tile :initform (vec2 1 0) :accessor tile-to-place)))

(defmethod initialize-instance :after ((widget chunk-widget) &key)
  (alloy:on (setf alloy:value) (value (alloy:representation 'layer widget))
    (unless (show-all widget)
      (setf (target-layer (entity widget)) (+ value 2))))
  (alloy:on (setf alloy:value) (value (alloy:representation 'show-all widget))
    (setf (target-layer (entity widget)) (unless value (+ (layer widget) 2)))))

(alloy:define-subobject (chunk-widget tiles) ('tile-picker :widget chunk-widget))
(alloy:define-subcomponent (chunk-widget albedo) ((slot-value chunk-widget 'tile) tile-button :tileset (tileset (entity chunk-widget))))
(alloy:define-subcomponent (chunk-widget absorption) ((slot-value chunk-widget 'tile) tile-button :tileset (absorption-map (entity chunk-widget))))
(alloy:define-subcomponent (chunk-widget tile-info) ((slot-value chunk-widget 'tile) tile-info))
(alloy::define-subbutton (chunk-widget pick) ()
  (setf (state (editor chunk-widget)) :picking))
(alloy::define-subbutton (chunk-widget clear) ()
  ;; FIXME: add confirmation
  (clear (entity chunk-widget)))
(alloy::define-subbutton (chunk-widget compute) ()
  (let ((chunk (entity chunk-widget)))
    (compute-shadow-map chunk)
    (reinitialize-instance (node-graph chunk) :solids (aref (layers chunk) +layer-count+))))

(alloy:define-subcontainer (chunk-widget layout)
    (alloy:grid-layout :col-sizes '(T) :row-sizes '(30 T 60))
  (alloy:build-ui
   (alloy:grid-layout
    :col-sizes '(T 30)
    :row-sizes '(30)
    layer show-all))
  tiles
  (alloy:build-ui
   (alloy:grid-layout
    :col-sizes '(64 64 T)
    :row-sizes '(64)
    albedo absorption tile-info))
  (alloy:build-ui
   (alloy:grid-layout
    :col-sizes '(T T T)
    :row-sizes '(30)
    pick clear compute)))

(alloy:define-subcontainer (chunk-widget focus)
    (alloy:focus-list)
  layer show-all tiles pick clear compute)

(define-subject chunk-editor (editor)
  ())

(defmethod update-instance-for-different-class :after (previous (editor chunk-editor) &key)
  (setf (sidebar editor) (make-instance 'chunk-widget :editor editor :side :east)))

(defmethod (setf entity) :before (new (editor chunk-editor))
  (setf (target-layer (entity editor)) NIL))

(defmethod editor-class ((_ chunk))
  'chunk-editor)

(defmethod applicable-tools append ((_ chunk))
  '(paint))

(defmethod default-tool ((editor chunk-editor))
  'paint)
