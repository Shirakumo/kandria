(in-package #:org.shirakumo.fraf.kandria)

(define-global +tile-history+
    (make-array 16 :initial-element '(0 0 1 1)))

(defclass tile-button (alloy:button)
  ((tileset :initarg :tileset :accessor tileset)
   (tile-size :initarg :tile-size :initform #.(vec +tile-size+ +tile-size+) :accessor tile-size)))

(presentations:define-realization (ui tile-button)
  ((:icon simple:icon)
   (alloy:margins 1)
   (tileset alloy:renderable)))

(presentations:define-update (ui tile-button)
  (:icon
   :size (alloy:px-size (/ (width (tileset alloy:renderable)) (vx (tile-size alloy:renderable)) (max 1 (third alloy:value)))
                        (/ (height (tileset alloy:renderable)) (vy (tile-size alloy:renderable)) (max 1 (fourth alloy:value))))
   :shift (alloy:px-point (* (first alloy:value) (/ (vx (tile-size alloy:renderable)) (width (tileset alloy:renderable))))
                          (* (second alloy:value) (/ (vy (tile-size alloy:renderable)) (height (tileset alloy:renderable)))))))

(defclass tile-info (alloy:label)
  ())

(defmethod alloy:text ((info tile-info))
  (format NIL "~3d / ~3d"
          (floor (first (alloy:value info)))
          (floor (second (alloy:value info)))))

(defclass tile-history (alloy:structure)
  ())

(defmethod initialize-instance :after ((structure tile-history) &key widget)
  (let* ((tileset (albedo (entity widget)))
         (layout (make-instance 'alloy:grid-layout :cell-margins (alloy:margins 1)
                                                   :col-sizes (map 'list (constantly 32) +tile-history+)
                                                   :row-sizes '(32)))
         (focus (make-instance 'alloy:focus-list)))
    (dotimes (i (length +tile-history+))
      (let ((element (alloy:represent (aref +tile-history+ i) 'tile-button
                                      :tileset tileset :layout-parent layout :focus-parent focus
                                      :ideal-size (alloy:size 64 64))))
        (alloy:on alloy:activate (element)
          (setf (tile-to-place widget) (alloy:value element)))))
    (alloy:observe 'tile widget (lambda (value object)
                                  (when value
                                    (let ((pos (or (position value +tile-history+ :test #'equal) (1- (length +tile-history+)))))
                                      (loop for i downfrom pos above 0
                                            do (setf (aref +tile-history+ i) (aref +tile-history+ (1- i))))
                                      (setf (aref +tile-history+ 0) value)
                                      (alloy:do-elements (element layout)
                                        (alloy:refresh (alloy:data element)))))))
    (alloy:finish-structure structure layout focus)))

(defclass tile-picker (alloy:structure)
  ())

(defmethod initialize-instance :after ((structure tile-picker) &key widget (tile-size +tile-size+))
  (let* ((tileset (albedo (entity widget)))
         (tile-size (if (realp tile-size) (vec tile-size tile-size) tile-size))
         (ratio (/ (vx tile-size) (vy tile-size)))
         (layout (make-instance 'alloy:grid-layout :cell-margins (alloy:margins 0)
                                                   :col-sizes (loop repeat (/ (width tileset) (vx tile-size)) collect (* 18 ratio))
                                                   :row-sizes (loop repeat (/ (height tileset) (vy tile-size)) collect 18)))
         (focus (make-instance 'alloy:focus-list))
         (scroll (make-instance 'alloy:scroll-view :scroll T :layout layout :focus focus)))
    (dotimes (y (floor (height tileset) (vy tile-size)))
      (dotimes (x (floor (width tileset) (vx tile-size)))
        (let* ((tile (list x (- (floor (height tileset) (vy tile-size)) y 1) 1 1))
               (element (make-instance 'tile-button :data (make-instance 'alloy:value-data :value tile)
                                                    :tileset tileset :layout-parent layout :focus-parent focus
                                                    :tile-size tile-size)))
          (alloy:on alloy:activate (element)
            (unless (typep (tool (editor widget)) 'painter-tool)
              (setf (tool (editor widget)) 'paint))
            (if (retained :shift)
                (let* ((x1 (first (tile-to-place widget)))
                       (y1 (second (tile-to-place widget)))
                       (x2 (first tile))
                       (y2 (second tile))
                       (xmin (min x1 x2)) (xmax (max x1 x2))
                       (ymin (min y1 y2)) (ymax (max y1 y2))
                       (tile (tile-to-place widget)))
                  (setf (nth 0 tile) xmin)
                  (setf (nth 1 tile) ymin)
                  (setf (nth 2 tile) (1+ (- xmax xmin)))
                  (setf (nth 3 tile) (1+ (- ymax ymin)))
                  (setf (tile-to-place widget) tile))
                (progn
                  (setf (place-width widget) 1)
                  (setf (place-height widget) 1)
                  (setf (tile-to-place widget) tile)))))))
    (alloy:finish-structure structure scroll scroll)))

(alloy:define-widget chunk-widget (sidebar)
  ((layer :initform +base-layer+ :accessor layer :representation (alloy:ranged-slider :range '(0 . 4) :grid 1 :tooltip "Active Layer"))
   (tile :initform (list 1 0 1 1) :accessor tile-to-place)
   (tile-set :accessor tile-set)
   (place-width :initform 1 :accessor place-width :representation (alloy:ranged-wheel :grid 1 :range '(1) :tooltip "Stamp Width"))
   (place-height :initform 1 :accessor place-height :representation (alloy:ranged-wheel :grid 1 :range '(1) :tooltip "Stamp Height"))))

(defmethod initialize-instance :before ((widget chunk-widget) &key editor)
  (setf (tile-set widget) (caar (tile-types (tile-data (entity editor))))))

(defmethod initialize-instance :after ((widget chunk-widget) &key)
  (alloy:on alloy:value (value (alloy:representation 'layer widget))
    (setf (alloy:value (slot-value widget 'show-solids)) NIL)))

(defmethod (setf tile-to-place) :around ((tile vec2) (widget chunk-widget))
  (let* ((w (/ (width (albedo (entity widget))) +tile-size+))
         (h (/ (height (albedo (entity widget))) +tile-size+))
         (x (mod (vx tile) w))
         (y (mod (+ (vy tile) (floor (vx tile) w)) h)))
    (call-next-method (list x y (place-width widget) (place-height widget)) widget)))

(defmethod (setf tile-to-place) :around ((tile cons) (widget chunk-widget))
  (destructuring-bind (x y &optional (w 1) (h 1)) tile
    (call-next-method (list x y w h) widget)))

(defmethod (setf tile-to-place) :after ((tile cons) (widget chunk-widget))
  (unless (and (= 0 (first tile)) (= 0 (second tile)))
    (setf (alloy:value (slot-value widget 'show-solids)) (= 0 (second tile)))))

(defmethod show-solids ((layer layer)) NIL)
(defmethod (setf show-solids) (value (layer layer)) value)

(alloy:define-subcomponent (chunk-widget show-solids) ((show-solids (entity chunk-widget)) alloy:switch :tooltip "Use Solids Layer"))
(alloy:define-subcomponent (chunk-widget tile-set-list) ((slot-value chunk-widget 'tile-set) alloy:combo-set :value-set (mapcar #'first (tile-types (tile-data (entity chunk-widget))))
                                                                                                             :tooltip "Auto-Tile Set"))
(alloy:define-subobject (chunk-widget tile-history) ('tile-history :widget chunk-widget))
(alloy:define-subobject (chunk-widget tiles) ('tile-picker :widget chunk-widget))
(alloy:define-subcomponent (chunk-widget albedo) ((slot-value chunk-widget 'tile) tile-button :tileset (albedo (entity chunk-widget)) :tooltip "Albedo Map"))
(alloy:define-subcomponent (chunk-widget absorption) ((slot-value chunk-widget 'tile) tile-button :tileset (absorption (entity chunk-widget)) :tooltip "Absorption Map"))
(alloy:define-subcomponent (chunk-widget normal) ((slot-value chunk-widget 'tile) tile-button :tileset (normal (entity chunk-widget)) :tooltip "Normal Map"))
(alloy:define-subcomponent (chunk-widget tile-info) ((slot-value chunk-widget 'tile) tile-info))
(alloy::define-subbutton (chunk-widget clear) ()
  (if (retained :control)
      (clear (aref (layers (entity chunk-widget)) +base-layer+))
      (alloy:with-confirmation ("Are you sure you want to clear the chunk?" :ui (node 'ui-pass T))
        (clear (entity chunk-widget)))))

(alloy:define-subcontainer (chunk-widget layout)
    (alloy:grid-layout :col-sizes '(T) :row-sizes '(30 30 34 T 30 60))
  (alloy:build-ui
   (alloy:grid-layout
    :col-sizes '(T 30)
    :row-sizes '(30)
    layer show-solids))
  tile-set-list
  tile-history
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
    :col-sizes '(T)
    :row-sizes '(30)
    clear)))

(alloy:define-subcontainer (chunk-widget focus)
    (alloy:focus-list)
  layer show-solids tile-set-list tile-history tiles place-width place-height clear)

(defmethod (setf entity) :after ((layer layer) (editor editor))
  (setf (sidebar editor) (make-instance 'chunk-widget :editor editor :side :east)))

(defmethod applicable-tools append ((_ layer))
  '(paint rectangle drag))

(defmethod applicable-tools append ((_ chunk))
  '(line auto-tile move-to))

(defmethod default-tool ((_ chunk))
  'freeform)
