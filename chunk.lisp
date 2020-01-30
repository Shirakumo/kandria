(in-package #:org.shirakumo.fraf.leaf)

(define-asset (leaf debug) image
    #p"debug.png"
  :min-filter :nearest
  :mag-filter :nearest)

(defclass chunk (sized-entity lit-entity shadow-caster shader-entity layered-container solid resizable )
  ((vertex-array :initform (asset 'trial:trial 'trial::fullscreen-square) :accessor vertex-array)
   (texture :accessor texture)
   (layers :accessor layers)
   (tileset :initarg :tileset :initform (asset 'leaf 'debug) :accessor tileset
            :type asset :documentation "The tileset texture for the chunk.")
   (absorption-map :initarg :absorption-map :initform (asset 'leaf 'debug) :accessor absorption-map
                   :type asset :documentation "The absorption map for the chunk.")
   (size :initarg :size :initform +tiles-in-view+ :accessor size
         :type vec2 :documentation "The size of the chunk in tiles.")
   (node-graph :accessor node-graph)
   (target-layer :initform NIL :accessor target-layer))
  (:metaclass shader-entity-class)
  (:inhibit-shaders (shader-entity :fragment-shader)))

(defmethod initargs append ((_ chunk))
  `(:size :tileset))

(defmethod initialize-instance :after ((chunk chunk) &key (layers +layer-count+))
  (let* ((size (size chunk)))
    (etypecase layers ;; We add one layer for the solids.
      (list)
      ((integer 1) (setf layers (loop repeat (1+ layers)
                                      collect (make-array (floor (* (vx size) (vy size) 2))
                                                          :element-type '(unsigned-byte 8))))))
    (setf (layers chunk) (coerce layers 'vector))
    (setf (bsize chunk) (v* size +tile-size+ .5))
    (setf (texture chunk) (make-instance 'texture :target :texture-2d-array
                                                  :width (floor (vx size))
                                                  :height (floor (vy size))
                                                  :depth (length layers)
                                                  :pixel-data layers
                                                  :pixel-type :unsigned-byte
                                                  :pixel-format :rg-integer
                                                  :internal-format :rg8ui
                                                  :min-filter :nearest
                                                  :mag-filter :nearest))
    (setf (node-graph chunk) (make-instance 'node-graph :size size
                                                        :solids (car (last layers))
                                                        :offset (v- (location chunk) (bsize chunk))))
    (compute-shadow-map chunk)))

(defmethod register-object-for-pass :after (pass (chunk chunk))
  (register-object-for-pass pass (node-graph chunk)))

(defmethod clone ((chunk chunk))
  (make-instance (class-of chunk)
                 :size (clone (size chunk))
                 :tileset (tileset chunk)))

(defmethod entity-at-point (point (chunk chunk))
  (or (call-next-method)
      (when (contained-p point chunk)
        chunk)))

(defmethod paint :around ((chunk chunk) target)
  (call-next-method)
  (when (< *current-layer* (length (objects chunk)))
    (loop for unit across (aref (objects chunk) *current-layer*)
          do (paint unit target)))
  (when (and (target-layer chunk)
             (= *current-layer* (1- +layer-count+)))
    (let ((*current-layer* +layer-count+))
      (call-next-method))))

(defmethod paint ((chunk chunk) (pass shader-pass))
  (let ((program (shader-program-for-pass pass chunk))
        (vao (vertex-array chunk)))
    (setf (uniform program "layer") *current-layer*)
    (setf (uniform program "target_layer") (or (target-layer chunk) -1))
    (setf (uniform program "tile_size") +tile-size+)
    (setf (uniform program "view_size") (vec2 (width *context*) (height *context*)))
    (setf (uniform program "map_size") (size chunk))
    (setf (uniform program "map_position") (location chunk))
    (setf (uniform program "view_matrix") (minv *view-matrix*))
    (setf (uniform program "model_matrix") (minv *model-matrix*))
    (setf (uniform program "tileset") 0)
    (setf (uniform program "tilemap") 1)
    (setf (uniform program "absorption") 2)
    (gl:active-texture :texture0)
    (gl:bind-texture :texture-2d (gl-name (tileset chunk)))
    (gl:active-texture :texture1)
    (gl:bind-texture :texture-2d-array (gl-name (texture chunk)))
    (gl:active-texture :texture2)
    (gl:bind-texture :texture-2d (gl-name (absorption-map chunk)))
    (gl:bind-vertex-array (gl-name vao))
    (unwind-protect
         (%gl:draw-elements :triangles (size vao) :unsigned-int 0)
      (gl:bind-vertex-array 0))))

(define-class-shader (chunk :vertex-shader)
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

(define-class-shader (chunk :fragment-shader)
  "
uniform usampler2DArray tilemap;
uniform sampler2D tileset;
uniform sampler2D absorption;
uniform vec2 map_size;
uniform vec2 map_position;
uniform int tile_size;
uniform int layer;
uniform int target_layer = -1;
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
  uvec2 tile = texelFetch(tilemap, ivec3(tile_xy, layer), 0).rg;
  tile_xy = ivec2(tile)*tile_size+pixel_xy;
  color = texelFetch(tileset, tile_xy, 0);
  float absor = texelFetch(absorption, tile_xy, 0).r;
  color = apply_lighting(color, vec2(0), 1-absor);
  if(0 <= target_layer && layer != target_layer)
    color *= 0.25;
}")

(defmethod resize ((chunk chunk) w h)
  (let ((size (vec2 (floor w +tile-size+) (floor h +tile-size+))))
    (unless (v= size (size chunk))
      (setf (size chunk) size))))

(defmethod (setf size) :around (value (chunk chunk))
  ;; Ensure the size is never lower than a screen.
  (call-next-method (vmax value +tiles-in-view+) chunk))

(defmethod (setf size) :before (value (chunk chunk))
  ;; FIXME: Check that all entities are within new chunk bounds and shift if necessary.
  (let* ((nw (floor (vx2 value)))
         (nh (floor (vy2 value)))
         (ow (floor (vx2 (size chunk))))
         (oh (floor (vy2 (size chunk))))
         (layers (layers chunk))
         (texture (texture chunk))
         (new-layers (make-array (length layers))))
    ;; Allocate resized and copy data over. Slow!
    (loop for old across layers
          for i from 0
          for tilemap = (make-array (* 4 nw nh) :element-type '(unsigned-byte 8)
                                                :initial-element 0)
          do (setf (aref new-layers i) tilemap)
             (dotimes (y (min nh oh))
               (dotimes (x (min nw ow))
                 (let ((npos (* 2 (+ x (* y nw))))
                       (opos (* 2 (+ x (* y ow)))))
                   (dotimes (c 2)
                     (setf (aref tilemap (+ npos c)) (aref old (+ opos c))))))))
    ;; Resize the texture. Internal mechanisms should take care of re-mapping the pixel data.
    (when (gl-name texture)
      (setf (pixel-data texture) (coerce new-layers 'list))
      (setf (layers chunk) new-layers)
      (resize texture nw nh))))

(defmethod (setf size) :after (value (chunk chunk))
  (setf (bsize chunk) (v* value +tile-size+ .5)))

(defmacro %with-chunk-xy ((chunk location) &body body)
  `(let ((x (floor (+ (- (vx ,location) (vx2 (location ,chunk))) (vx2 (bsize ,chunk))) +tile-size+))
         (y (floor (+ (- (vy ,location) (vy2 (location ,chunk))) (vy2 (bsize ,chunk))) +tile-size+)))
     (when (and (< -1.0 x (vx2 (size chunk)))
                (< -1.0 y (vy2 (size chunk))))
       ,@body)))

(defmethod tile ((location vec2) (chunk chunk))
  (tile (vec3 (vx2 location) (vy2 location) 3) chunk))

(defmethod tile ((location vec3) (chunk chunk))
  (%with-chunk-xy (chunk location)
    (let* ((z (+ (truncate (vz location))
                 (floor +layer-count+ 2)))
           (layer (aref (layers chunk) z))
           (pos (* 2 (+ x (* y (truncate (vx (size chunk))))))))
      (vec2 (aref layer pos) (aref layer (1+ pos))))))

(defmethod (setf tile) (value (location vec2) (chunk chunk))
  (setf (tile (vec3 (vx2 location) (vy2 location) 0) chunk) value))

(defmethod (setf tile) (value (location vec3) (chunk chunk))
  (%with-chunk-xy (chunk location)
    (let* ((z (+ (truncate (vz location))
                 (floor +layer-count+ 2)))
           (layer (aref (layers chunk) z))
           (pos (* 2 (+ x (* y (truncate (vx (size chunk))))))))
      (when (or (/= (vx value) (aref layer (+ 0 pos)))
                (/= (vy value) (aref layer (+ 1 pos))))
        (setf (aref layer (+ 0 pos)) (truncate (vx2 value)))
        (setf (aref layer (+ 1 pos)) (truncate (vy2 value)))
        (sb-sys:with-pinned-objects (layer)
          (let ((texture (texture chunk)))
            (gl:bind-texture :texture-2d-array (gl-name texture))
            (%gl:tex-sub-image-3d :texture-2d-array 0 x y z 1 1 1 (pixel-format texture) (pixel-type texture)
                                  (cffi:inc-pointer (sb-sys:vector-sap layer) pos)))))
      value)))

(defmethod clear :after ((chunk chunk))
  (dotimes (l (1+ +layer-count+))
    (let ((layer (aref (layers chunk) l))
          (width (truncate (vx (size chunk))))
          (height (truncate (vy (size chunk)))))
      (dotimes (i (* 2 width height))
        (setf (aref layer i) 0))
      (compute-shadow-map chunk)
      (sb-sys:with-pinned-objects (layer)
        (let ((texture (texture chunk)))
          (gl:bind-texture :texture-2d-array (gl-name texture))
          (%gl:tex-sub-image-3d :texture-2d-array 0 0 0 l width height 1
                                (pixel-format texture) (pixel-type texture)
                                (sb-sys:vector-sap layer)))))))

(defmethod flood-fill ((chunk chunk) (location vec3) fill)
  (%with-chunk-xy (chunk location)
    (let* ((z (+ (truncate (vz location))
                 (floor +layer-count+ 2)))
           (layer (aref (layers chunk) z))
           (width (truncate (vx (size chunk))))
           (height (truncate (vy (size chunk)))))
      (%flood-fill layer width height x y fill)
      (sb-sys:with-pinned-objects (layer)
        (let ((texture (texture chunk)))
          (gl:bind-texture :texture-2d-array (gl-name texture))
          (%gl:tex-sub-image-3d :texture-2d-array 0 0 0 z width height 1
                                (pixel-format texture) (pixel-type texture)
                                (sb-sys:vector-sap layer)))))))

(defmethod auto-tile ((chunk chunk) (location vec3))
  (%with-chunk-xy (chunk location)
    (let* ((z (floor +layer-count+ 2))
           (layer (aref (layers chunk) z))
           (width (truncate (vx (size chunk))))
           (height (truncate (vy (size chunk)))))
      (%auto-tile (aref (layers chunk) +layer-count+)
                  (aref (layers chunk) z)
                  width height x y)
      (sb-sys:with-pinned-objects (layer)
        (let ((texture (texture chunk)))
          (gl:bind-texture :texture-2d-array (gl-name texture))
          (%gl:tex-sub-image-3d :texture-2d-array 0 0 0 z width height 1
                                (pixel-format texture) (pixel-type texture)
                                (sb-sys:vector-sap layer)))))))

(defmethod compute-shadow-map ((chunk chunk))
  (let* ((w (truncate (vx (size chunk))))
         (h (truncate (vy (size chunk))))
         (layer (aref (layers chunk) +layer-count+))
         (vbo (caar (bindings (shadow-geometry chunk))))
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
                     (add-shadow-line chunk loc (v+ loc (vec +tile-size+ 0)))
                     (add-shadow-line chunk (v+ loc (vec 0 +tile-size+)) (v+ loc (vec +tile-size+ +tile-size+))))
                    ((and (= 1 (sfaref x (1+ y)))
                          (= 1 (sfaref x (1- y))))
                     (add-shadow-line chunk loc (v+ loc (vec 0 +tile-size+)))
                     (add-shadow-line chunk (v+ loc (vec +tile-size+ 0)) (v+ loc (vec +tile-size+ +tile-size+))))
                    ((and (= 1 (sfaref (1+ x) y))
                          (= 1 (sfaref x (1- y))))
                     (add-shadow-line chunk (v+ loc (vec 0 +tile-size+)) (v+ loc (vec +tile-size+ +tile-size+)))
                     (add-shadow-line chunk loc (v+ loc (vec 0 +tile-size+))))
                    ((and (= 1 (sfaref (1- x) y))
                          (= 1 (sfaref x (1- y))))
                     (add-shadow-line chunk (v+ loc (vec 0 +tile-size+)) (v+ loc (vec +tile-size+ +tile-size+)))
                     (add-shadow-line chunk (v+ loc (vec +tile-size+ 0)) (v+ loc (vec +tile-size+ +tile-size+))))
                    ((and (= 1 (sfaref (1+ x) y))
                          (= 1 (sfaref x (1+ y))))
                     (add-shadow-line chunk loc (v+ loc (vec +tile-size+ 0)))
                     (add-shadow-line chunk loc (v+ loc (vec 0 +tile-size+))))
                    ((and (= 1 (sfaref (1- x) y))
                          (= 1 (sfaref x (1+ y))))
                     (add-shadow-line chunk loc (v+ loc (vec +tile-size+ 0)))
                     (add-shadow-line chunk loc (v+ loc (vec 0 +tile-size+)))))))))
      (when (allocated-p vbo)
        (resize-buffer vbo (* (length data) 4) :data data)))))

(defmethod shortest-path ((chunk chunk) start goal)
  (flet ((local-pos (pos)
           (vfloor (nv+ (v- pos (location chunk)) (bsize chunk)) +tile-size+)))
    (shortest-path (node-graph chunk) (local-pos start) (local-pos goal))))

(defmethod contained-p ((location vec2) (chunk chunk))
  (%with-chunk-xy (chunk location)
    chunk))

(defmethod scan ((chunk chunk) (target vec2))
  (let ((tile (tile target chunk)))
    (if (and tile (= 0 (vy tile)) (< 0 (vx tile)))
        (aref +surface-blocks+ (truncate (vx tile)))
        (do-layered-container (entity chunk)
          (when (and (typep entity 'solid)
                     (scan entity target))
            (return entity))))))

(defmethod scan ((chunk chunk) (target vec4))
  (let* ((tilemap (aref (layers chunk) +layer-count+))
         (w (truncate (vx (size chunk))))
         (h (truncate (vy (size chunk))))
         (lloc (nv+ (nv- (vxy target) (location chunk)) (bsize chunk)))
         (x- (floor (- (vx lloc) (vz target)) +tile-size+))
         (x+ (ceiling (+ (vx lloc) (vz target)) +tile-size+))
         (y- (floor (- (vy lloc) (vw target)) +tile-size+))
         (y+ (ceiling (+ (vy lloc) (vw target)) +tile-size+)))
    (loop for x from (max 0 x-) below (min w x+)
          do (loop for y from (max 0 y-) below (min h y+)
                   for idx = (* (+ x (* y w)) 2)
                   for tile = (aref tilemap (+ 0 idx))
                   do (when (< 0 tile)
                        (return-from scan (aref +surface-blocks+ tile)))))
    (do-layered-container (entity chunk)
      (when (and (typep entity 'solid)
                 (scan entity target))
        (return entity)))))

(defmethod scan ((chunk chunk) (target game-entity))
  (let* ((tilemap (aref (layers chunk) +layer-count+))
         (t-s +tile-size+)
         (x- 0) (y- 0) (x+ 0) (y+ 0)
         (w (truncate (vx (size chunk))))
         (h (truncate (vy (size chunk))))
         (size (v+ (bsize target) (/ t-s 2)))
         (pos (location target))
         (lloc (nv+ (v- (location target) (location chunk)) (bsize chunk)))
         (vel (velocity target))
         (result))
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
                          (when (and hit
                                     (collides-p target (aref +surface-blocks+ tile) hit)
                                     (or (not result)
                                         (< (hit-time hit) (hit-time result))
                                         (and (= (hit-time hit) (hit-time result))
                                              (< (vsqrdist2 loc (hit-location hit))
                                                 (vsqrdist2 loc (hit-location result))))))
                            (setf (hit-object hit) (aref +surface-blocks+ tile))
                            (setf result hit))))))
    ;; Scan through entities
    (do-layered-container (entity chunk)
      (when (and (not (eq entity target))
                 (typep entity 'solid))
        (let ((hit (scan entity target)))
          (when (and hit
                     (collides-p target entity hit)
                     (or (null result)
                         (< (vsqrdist2 pos (hit-location hit))
                            (vsqrdist2 pos (hit-location result)))))
            (setf result hit)))))
    (when result
      (collide target (hit-object result) result)
      result)))
