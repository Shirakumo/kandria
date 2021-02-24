(in-package #:org.shirakumo.fraf.kandria)

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
   :shift (alloy:px-point (first alloy:value) (second alloy:value))))

(defmethod simple:icon ((renderer ui) bounds (image texture) &rest initargs)
  (apply #'make-instance 'simple:icon :image image initargs))

(defclass tile-info (alloy:label)
  ())

(defmethod alloy:text ((info tile-info))
  (format NIL "~3d / ~3d"
          (floor (first (alloy:value info)))
          (floor (second (alloy:value info)))))

(defclass tile-picker (alloy:structure)
  ())

(defmethod initialize-instance :after ((structure tile-picker) &key widget)
  (let* ((tileset (albedo (entity widget)))
         (layout (make-instance 'alloy:grid-layout :cell-margins (alloy:margins 1)
                                                   :col-sizes (loop repeat (/ (width tileset) +tile-size+) collect 18)
                                                   :row-sizes (loop repeat (/ (height tileset) +tile-size+) collect 18)))
         (focus (make-instance 'alloy:focus-list))
         (scroll (make-instance 'alloy:scroll-view :scroll T :layout layout :focus focus)))
    (dotimes (y (/ (height tileset) +tile-size+))
      (dotimes (x (/ (width tileset) +tile-size+))
        (let* ((tile (list x (- (/ (height tileset) +tile-size+) y 1)))
               (element (make-instance 'tile-button :data (make-instance 'alloy:value-data :value tile)
                                                    :tileset tileset :layout-parent layout :focus-parent focus)))
          (alloy:on alloy:activate (element)
            (if (retained :shift)
                (let ((xd (- (first tile) (first (tile-to-place widget))))
                      (yd (- (second tile) (second (tile-to-place widget)))))
                  (setf (place-width widget) (1+ (floor xd)))
                  (setf (place-height widget) (1+ (floor yd)))
                  (setf (third (tile-to-place widget)) (place-width widget))
                  (setf (fourth (tile-to-place widget)) (place-height widget)))
                (progn
                  (setf (place-width widget) 1)
                  (setf (place-height widget) 1)
                  (setf (tile-to-place widget) (append tile (list 1 1)))))))))
    (alloy:finish-structure structure scroll scroll)))

(alloy:define-widget chunk-widget (sidebar)
  ((layer :initform +base-layer+ :accessor layer :representation (alloy:ranged-slider :range '(0 . 4) :grid 1))
   (tile :initform (list 1 0 1 1) :accessor tile-to-place)
   (tile-set :accessor tile-set)
   (place-width :initform 1 :accessor place-width :representation (alloy:ranged-wheel :grid 1 :range '(1)))
   (place-height :initform 1 :accessor place-height :representation (alloy:ranged-wheel :grid 1 :range '(1)))))

(defmethod initialize-instance :before ((widget chunk-widget) &key editor)
  (setf (tile-set widget) (caar (tile-types (tile-data (entity editor))))))

(defmethod (setf tile-to-place) :around ((tile vec2) (widget chunk-widget))
  (let* ((w (/ (width (albedo (entity widget))) +tile-size+))
         (h (/ (height (albedo (entity widget))) +tile-size+))
         (x (mod (vx tile) w))
         (y (mod (+ (vy tile) (floor (vx tile) w)) h)))
    (call-next-method (list x y (place-width widget) (place-height widget)) widget)))

(alloy:define-subcomponent (chunk-widget show-solids) ((show-solids (entity chunk-widget)) alloy:switch))
(alloy:define-subcomponent (chunk-widget tile-set-list) ((slot-value chunk-widget 'tile-set) alloy:combo-set :value-set (mapcar #'first (tile-types (tile-data (entity chunk-widget))))))
(alloy:define-subobject (chunk-widget tiles) ('tile-picker :widget chunk-widget))
(alloy:define-subcomponent (chunk-widget albedo) ((slot-value chunk-widget 'tile) tile-button :tileset (albedo (entity chunk-widget))))
(alloy:define-subcomponent (chunk-widget absorption) ((slot-value chunk-widget 'tile) tile-button :tileset (absorption (entity chunk-widget))))
(alloy:define-subcomponent (chunk-widget normal) ((slot-value chunk-widget 'tile) tile-button :tileset (normal (entity chunk-widget))))
(alloy:define-subcomponent (chunk-widget tile-info) ((slot-value chunk-widget 'tile) tile-info))
(alloy::define-subbutton (chunk-widget pick) ()
  (setf (state (editor chunk-widget)) :picking))
(alloy::define-subbutton (chunk-widget clear) ()
  ;; FIXME: add confirmation
  (clear (entity chunk-widget)))
(alloy::define-subbutton (chunk-widget compute) ()
  (recompute (entity chunk-widget))
  (setf (chunk-graph (region +world+)) (make-chunk-graph (region +world+)))
  (when (typep (tool (editor chunk-widget)) 'move-to)
    (setf (tool (editor chunk-widget)) (tool (editor chunk-widget)))))

(alloy:define-subcontainer (chunk-widget layout)
    (alloy:grid-layout :col-sizes '(T) :row-sizes '(30 30 T 30 60))
  (alloy:build-ui
   (alloy:grid-layout
    :col-sizes '(T 30)
    :row-sizes '(30)
    layer show-solids))
  tile-set-list
  tiles
  (alloy:build-ui
   (alloy:grid-layout
    :col-sizes '(T T)
    :row-sizes '(30)
    place-width place-height))
  (alloy:build-ui
   (alloy:grid-layout
    :col-sizes '(64 64 64 T)
    :row-sizes '(64)
    albedo absorption normal tile-info))
  (alloy:build-ui
   (alloy:grid-layout
    :col-sizes '(T T T)
    :row-sizes '(30)
    pick clear compute)))

(alloy:define-subcontainer (chunk-widget focus)
    (alloy:focus-list)
  layer show-solids tile-set-list tiles place-width place-height pick clear compute)

(defmethod (setf entity) :after ((chunk chunk) (editor editor))
  (setf (sidebar editor) (make-instance 'chunk-widget :editor editor :side :east)))

(defmethod applicable-tools append ((_ chunk))
  '(paint line move-to))

(defmethod default-tool ((_ chunk))
  'freeform)
