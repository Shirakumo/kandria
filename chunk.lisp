(in-package #:org.shirakumo.fraf.leaf)

(define-shader-entity layer (lit-entity sized-entity resizable ephemeral)
  ((vertex-array :initform (// 'trial 'fullscreen-square) :accessor vertex-array)
   (tilemap :accessor tilemap)
   (layer-index :initarg :layer-index :initform 0 :accessor layer-index)
   (albedo :initarg :albedo :initform (// 'leaf 'debug) :accessor albedo)
   (absorption :initarg :absorption :initform (// 'leaf 'debug) :accessor absorption)
   (size :initarg :size :initform +tiles-in-view+ :accessor size
         :type vec2 :documentation "The size of the chunk in tiles."))
  (:inhibit-shaders (shader-entity :fragment-shader)))

(defmethod initialize-instance :after ((layer layer) &key pixel-data tile-data)
  (let* ((size (size layer))
         (data (or pixel-data
                   (make-array (floor (* (vx size) (vy size) 2))
                               :element-type '(unsigned-byte 8)))))
    (setf (bsize layer) (v* size +tile-size+ .5))
    (setf (tilemap layer) (make-instance 'texture :target :texture-2d
                                                  :width (floor (vx size))
                                                  :height (floor (vy size))
                                                  :pixel-data data
                                                  :pixel-type :unsigned-byte
                                                  :pixel-format :rg-integer
                                                  :internal-format :rg8ui
                                                  :min-filter :nearest
                                                  :mag-filter :nearest))
    (setf (albedo layer) (resource tile-data 'albedo))
    (setf (absorption layer) (resource tile-data 'absorption))))

(defmethod stage ((layer layer) (area staging-area))
  (stage (vertex-array layer) area)
  (stage (tilemap layer) area)
  (stage (albedo layer) area)
  (stage (absorption layer) area))

(defmethod pixel-data ((layer layer))
  (pixel-data (tilemap layer)))

(defmethod resize ((layer layer) w h)
  (let ((size (vec2 (floor w +tile-size+) (floor h +tile-size+))))
    (unless (v= size (size layer))
      (setf (size layer) size))))

(defmethod (setf size) :around (value (layer layer))
  ;; Ensure the size is never lower than a screen.
  (call-next-method (vmax value +tiles-in-view+) layer))

(defmethod (setf size) :before (value (layer layer))
  (let* ((nw (floor (vx2 value)))
         (nh (floor (vy2 value)))
         (ow (floor (vx2 (size layer))))
         (oh (floor (vy2 (size layer))))
         (tilemap (pixel-data layer))
         (new-tilemap (make-array (* 4 nw nh) :element-type '(unsigned-byte 8)
                                              :initial-element 0)))
    ;; Allocate resized and copy data over. Slow!
    (dotimes (y (min nh oh))
      (dotimes (x (min nw ow))
        (let ((npos (* 2 (+ x (* y nw))))
              (opos (* 2 (+ x (* y ow)))))
          (dotimes (c 2)
            (setf (aref new-tilemap (+ npos c)) (aref tilemap (+ opos c)))))))
    ;; Resize the tilemap. Internal mechanisms should take care of re-mapping the pixel data.
    (when (gl-name (tilemap layer))
      (setf (pixel-data (tilemap layer)) new-tilemap)
      (resize (tilemap layer) nw nh))))

(defmethod (setf size) :after (value (layer layer))
  (setf (bsize layer) (v* value +tile-size+ .5)))

(defmacro %with-layer-xy ((layer location) &body body)
  `(let ((x (floor (+ (- (vx ,location) (vx2 (location ,layer))) (vx2 (bsize ,layer))) +tile-size+))
         (y (floor (+ (- (vy ,location) (vy2 (location ,layer))) (vy2 (bsize ,layer))) +tile-size+)))
     (when (and (< -1.0 x (vx2 (size ,layer)))
                (< -1.0 y (vy2 (size ,layer))))
       ,@body)))

(defmethod tile ((location vec2) (layer layer))
  (%with-layer-xy (layer location)
    (let ((pos (* 2 (+ x (* y (truncate (vx (size layer))))))))
      (vec2 (aref (pixel-data layer) pos) (aref (pixel-data layer) (1+ pos))))))

(defmethod (setf tile) (value (location vec2) (layer layer))
  (%with-layer-xy (layer location)
    (let ((dat (pixel-data layer))
          (pos (* 2 (+ x (* y (truncate (vx (size layer)))))))
          (texture (tilemap layer)))
      (when (or (/= (vx value) (aref dat (+ 0 pos)))
                (/= (vy value) (aref dat (+ 1 pos))))
        (setf (aref dat (+ 0 pos)) (truncate (vx2 value)))
        (setf (aref dat (+ 1 pos)) (truncate (vy2 value)))
        (sb-sys:with-pinned-objects (dat)
          (gl:bind-texture :texture-2d (gl-name texture))
          (%gl:tex-sub-image-2d :texture-2d 0 x y 1 1 (pixel-format texture) (pixel-type texture)
                                (cffi:inc-pointer (sb-sys:vector-sap dat) pos))
          (gl:bind-texture :texture-2d 0)))
      value)))

(defun update-layer (layer)
  (let ((dat (pixel-data layer)))
    (sb-sys:with-pinned-objects (dat)
      (let ((texture (tilemap layer))
            (width (truncate (vx (size layer))))
            (height (truncate (vy (size layer)))))
        (gl:bind-texture :texture-2d (gl-name texture))
        (%gl:tex-sub-image-2d :texture-2d 0 0 0 width height
                              (pixel-format texture) (pixel-type texture)
                              (sb-sys:vector-sap dat))
        (gl:bind-texture :texture-2d 0)))))

(defmethod clear :after ((layer layer))
  (let ((dat (pixel-data layer)))
    (dotimes (i (truncate (* 2 (vx (size layer)) (vy (size layer)))))
      (setf (aref dat i) 0))
    (update-layer layer)))

(defmethod flood-fill ((layer layer) (location vec2) fill)
  (%with-layer-xy (layer location)
    (let* ((width (truncate (vx (size layer))))
           (height (truncate (vy (size layer)))))
      (%flood-fill (pixel-data layer) width height x y fill)
      (update-layer layer))))

(defmethod render ((layer layer) (program shader-program))
  (setf (uniform program "view_size") (vec2 (width *context*) (height *context*)))
  (setf (uniform program "map_size") (size layer))
  (setf (uniform program "map_position") (location layer))
  (setf (uniform program "view_matrix") (minv *view-matrix*))
  (setf (uniform program "model_matrix") (minv *model-matrix*))
  (setf (uniform program "tilemap") 0)
  (setf (uniform program "albedo") 1)
  (setf (uniform program "absorption") 2)
  (gl:active-texture :texture0)
  (gl:bind-texture :texture-2d (gl-name (tilemap layer)))
  (gl:active-texture :texture1)
  (gl:bind-texture :texture-2d (gl-name (albedo layer)))
  (gl:active-texture :texture2)
  (gl:bind-texture :texture-2d (gl-name (absorption layer)))
  (gl:bind-vertex-array (gl-name (vertex-array layer)))
  (unwind-protect
       (%gl:draw-elements :triangles (size (vertex-array layer)) :unsigned-int 0)
    (gl:bind-vertex-array 0)))

(define-class-shader (layer :vertex-shader)
  "layout (location = 0) in vec3 vertex;
layout (location = 1) in vec2 vertex_uv;
uniform mat4 view_matrix;
uniform mat4 model_matrix;
uniform vec2 view_size;
out vec2 map_coord;

void main(){
  // We start in view-space, so we have to inverse-map to world-space.
  map_coord = (model_matrix * (view_matrix * vec4(vertex_uv*view_size, 0, 1))).xy;
  gl_Position = vec4(vertex, 1);
}")

(define-class-shader (layer :fragment-shader)
  "
uniform usampler2D tilemap;
uniform sampler2D albedo;
uniform sampler2D absorption;
uniform vec2 map_size;
uniform vec2 map_position;
uniform int tile_size = 16;
in vec2 map_coord;
out vec4 color;

void main(){
  ivec2 map_wh = ivec2(map_size)*tile_size;
  ivec2 map_xy = ivec2(map_coord+map_wh/2.);
  
  // Bounds check to avoid bad lookups
  if(map_xy.x < 0 || map_xy.y < 0 || map_wh.x <= map_xy.x || map_wh.y <= map_xy.y){
    color = vec4(0);
    return;
  }

  // Calculate tilemap index and pixel offset within tile.
  ivec2 tile_xy  = ivec2(map_xy.x / tile_size, map_xy.y / tile_size);
  ivec2 pixel_xy = ivec2(map_xy.x % tile_size, map_xy.y % tile_size);

  // Look up tileset index from tilemap and pixel from tileset.
  uvec2 tile = texelFetch(tilemap, tile_xy, 0).rg;
  tile_xy = ivec2(tile)*tile_size+pixel_xy;
  color = texelFetch(albedo, tile_xy, 0);
  float absor = texelFetch(absorption, tile_xy, 0).r;
  color = apply_lighting(color, vec2(0), 1-absor);
}")

(define-shader-entity chunk (layer solid shadow-caster)
  ((layer-index :initform 0)
   (layers :accessor layers)
   (node-graph :accessor node-graph)
   (show-solids :initform NIL :accessor show-solids)
   (shadow-caster :initform (make-instance 'shadow-caster) :accessor shadow-caster)
   (tile-data :initarg :tile-data :accessor tile-data
              :type tile-data :documentation "The tile data used to display the chunk.")))

(defmethod initialize-instance :after ((chunk chunk) &key (layers (make-list +layer-count+)) tile-data)
  (let* ((size (size chunk))
         (layers (loop for i from 0
                       for data in layers
                       collect (make-instance 'layer :size size
                                                     :location (location chunk)
                                                     :tile-data tile-data
                                                     :pixel-data data
                                                     :layer-index i))))
    (setf (layers chunk) (coerce layers 'vector))
    (setf (node-graph chunk) (make-instance 'node-graph :size size
                                                        :solids (pixel-data chunk)
                                                        :offset (v- (location chunk) (bsize chunk))))
    (compute-shadow-geometry chunk T)))

(defmethod render :around ((chunk chunk) target)
  (when (show-solids chunk)
    (call-next-method)))

(defmethod enter :after ((chunk chunk) (container container))
  (loop for layer across (layers chunk)
        do (enter layer container)))

(defmethod leave :after ((chunk chunk) (container container))
  (loop for layer across (layers chunk)
        do (leave layer container)))

(defmethod register-object-for-pass :after (pass (chunk chunk))
  (register-object-for-pass pass (node-graph chunk)))

(defmethod clone ((chunk chunk))
  (make-instance (class-of chunk)
                 :size (clone (size chunk))
                 :tile-data (tile-data chunk)
                 :pixel-data (clone (pixel-data chunk))
                 :layers (mapcar #'clone (map 'list #'pixel-data (layers chunk)))))

(defmethod (setf tile-data) :after ((data tile-data) (chunk chunk))
  (trial:commit data (loader (handler *context*)) :unload NIL)
  (flet ((update-layer (layer)
           (setf (albedo layer) (resource data 'albedo))
           (setf (absorption layer) (resource data 'absorption))))
    (update-layer chunk)
    (map NIL #'update-layer (layers chunk))))

(defmethod tile ((location vec3) (chunk chunk))
  (if (= (vz location) 0)
      (tile (vxy location) chunk)
      (tile (vxy location) (aref (layers chunk) (floor (vz location))))))

(defmethod (setf tile) (value (location vec3) (chunk chunk))
  (if (= (vz location) 0)
      (setf (tile (vxy location) chunk) value)
      (setf (tile (vxy location) (aref (layers chunk) (floor (vz location)))) value)))

(defmethod entity-at-point (point (chunk chunk))
  (or (call-next-method)
      (when (contained-p point chunk)
        chunk)))

(defmethod auto-tile ((chunk chunk) (location vec3))
  (%with-layer-xy (chunk location)
    (let* ((z (truncate (vz location)))
           (width (truncate (vx (size chunk))))
           (height (truncate (vy (size chunk)))))
      (%auto-tile (pixel-data chunk)
                  (pixel-data (aref (layers chunk) z))
                  width height x y (tile-types (tile-data chunk)))
      (update-layer (aref (layers chunk) z)))))

(defmethod compute-shadow-geometry ((chunk chunk) (vbo vertex-buffer))
  (let* ((w (truncate (vx (size chunk))))
         (h (truncate (vy (size chunk))))
         (layer (pixel-data chunk))
         (data (buffer-data vbo)))
    (flet ((sfaref (x y)
             (if (and (<= 0 x (1- w))
                      (<= 0 y (1- h)))
                 (aref layer (+ 0 (* 2 (+ x (* y w)))))
                 1)))
      (setf (fill-pointer data) 0)
      (dotimes (y h)
        (dotimes (x w)
          (when (= 1 (sfaref x y))
            (let ((loc (vec (* (- x (/ w 2)) +tile-size+)
                            (* (- y (/ h 2)) +tile-size+))))
              (cond ((and (= 1 (sfaref (1+ x) y))
                          (= 1 (sfaref (1- x) y)))
                     (add-shadow-line vbo loc (v+ loc (vec +tile-size+ 0)))
                     (add-shadow-line vbo (v+ loc (vec 0 +tile-size+)) (v+ loc (vec +tile-size+ +tile-size+))))
                    ((and (= 1 (sfaref x (1+ y)))
                          (= 1 (sfaref x (1- y))))
                     (add-shadow-line vbo loc (v+ loc (vec 0 +tile-size+)))
                     (add-shadow-line vbo (v+ loc (vec +tile-size+ 0)) (v+ loc (vec +tile-size+ +tile-size+))))
                    ((and (= 1 (sfaref (1+ x) y))
                          (= 1 (sfaref x (1- y))))
                     (add-shadow-line vbo (v+ loc (vec 0 +tile-size+)) (v+ loc (vec +tile-size+ +tile-size+)))
                     (add-shadow-line vbo loc (v+ loc (vec 0 +tile-size+))))
                    ((and (= 1 (sfaref (1- x) y))
                          (= 1 (sfaref x (1- y))))
                     (add-shadow-line vbo (v+ loc (vec 0 +tile-size+)) (v+ loc (vec +tile-size+ +tile-size+)))
                     (add-shadow-line vbo (v+ loc (vec +tile-size+ 0)) (v+ loc (vec +tile-size+ +tile-size+))))
                    ((and (= 1 (sfaref (1+ x) y))
                          (= 1 (sfaref x (1+ y))))
                     (add-shadow-line vbo loc (v+ loc (vec +tile-size+ 0)))
                     (add-shadow-line vbo loc (v+ loc (vec 0 +tile-size+))))
                    ((and (= 1 (sfaref (1- x) y))
                          (= 1 (sfaref x (1+ y))))
                     (add-shadow-line vbo loc (v+ loc (vec +tile-size+ 0)))
                     (add-shadow-line vbo loc (v+ loc (vec 0 +tile-size+))))))))))))

(defmethod shortest-path ((chunk chunk) start goal)
  (flet ((local-pos (pos)
           (vfloor (nv+ (v- pos (location chunk)) (bsize chunk)) +tile-size+)))
    (shortest-path (node-graph chunk) (local-pos start) (local-pos goal))))

(defmethod contained-p ((entity located-entity) (chunk chunk))
  (contained-p (location entity) chunk))

(defmethod contained-p ((location vec2) (chunk chunk))
  (%with-layer-xy (chunk location)
    chunk))

(defmethod scan ((chunk chunk) (target vec2) on-hit)
  (let ((tile (tile target chunk)))
    (when (and tile (= 0 (vy tile)) (< 0 (vx tile)))
      (let ((hit (make-hit (aref +surface-blocks+ (truncate (vx tile))) target)))
        (unless (funcall on-hit hit)
          hit)))))

(defmethod scan ((chunk chunk) (target vec4) on-hit)
  (let* ((tilemap (pixel-data chunk))
         (t-s +tile-size+)
         (w (truncate (vx (size chunk))))
         (h (truncate (vy (size chunk))))
         (lloc (nv+ (nv- (vxy target) (location chunk)) (bsize chunk)))
         (x- (floor (- (vx lloc) (vz target)) t-s))
         (x+ (ceiling (+ (vx lloc) (vz target)) t-s))
         (y- (floor (- (vy lloc) (vw target)) t-s))
         (y+ (ceiling (+ (vy lloc) (vw target)) t-s)))
    (loop for x from (max 0 x-) below (min w x+)
          do (loop for y from (max 0 y-) below (min h y+)
                   for idx = (* (+ x (* y w)) 2)
                   for tile = (aref tilemap (+ 0 idx))
                   do (when (< 0 tile)
                        (let* ((loc (vec2 (+ (* x t-s) (/ t-s 2) (- (vx (location chunk)) (vx (bsize chunk))))
                                          (+ (* y t-s) (/ t-s 2) (- (vy (location chunk)) (vy (bsize chunk))))))
                               (hit (make-hit (aref +surface-blocks+ tile) loc)))
                          (unless (funcall on-hit hit)
                            (return-from scan hit))))))))

(defmethod scan ((chunk chunk) (target game-entity) on-hit)
  (let* ((tilemap (pixel-data chunk))
         (t-s +tile-size+)
         (x- 0) (y- 0) (x+ 0) (y+ 0)
         (w (truncate (vx (size chunk))))
         (h (truncate (vy (size chunk))))
         (size (v+ (bsize target) (/ t-s 2)))
         (pos (location target))
         (lloc (nv+ (v- (location target) (location chunk)) (bsize chunk)))
         (vel (velocity target)))
    ;; Figure out bounding region
    (if (< 0 (vx vel))
        (setf x- (floor (- (vx lloc) (vx size)) t-s)
              x+ (ceiling (+ (vx lloc) (vx vel) (vx size)) t-s))
        (setf x- (floor (- (+ (vx lloc) (vx vel)) (vx size)) t-s)
              x+ (ceiling (+ (vx lloc) (vx size)) t-s)))
    (if (< 0 (vy vel))
        (setf y- (floor (- (vy lloc) (vy size)) t-s)
              y+ (ceiling (+ (vy lloc) (vy vel) (vy size)) t-s))
        (setf y- (floor (- (+ (vy lloc) (vy vel)) (vy size)) t-s)
              y+ (ceiling (+ (vy lloc) (vy size)) t-s)))
    ;; Sweep AABB through tiles
    (loop for x from (max x- 0) to (min x+ (1- w))
          do (loop for y from (max y- 0) to (min y+ (1- h))
                   for idx = (* (+ x (* y w)) 2)
                   for tile = (aref tilemap (+ 0 idx))
                   do (when (and (= 0 (aref tilemap (+ 1 idx)))
                                 (< 0 tile))
                        (let* ((loc (vec2 (+ (* x t-s) (/ t-s 2) (- (vx (location chunk)) (vx (bsize chunk))))
                                          (+ (* y t-s) (/ t-s 2) (- (vy (location chunk)) (vy (bsize chunk))))))
                               (hit (aabb pos vel loc size)))
                          (when hit
                            (setf (hit-object hit) (aref +surface-blocks+ tile))
                            (unless (funcall on-hit hit)
                              (return-from scan hit)))))))))
