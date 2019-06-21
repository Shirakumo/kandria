(in-package #:org.shirakumo.fraf.leaf)

(define-shader-entity chunk (sized-entity solid)
  ((vertex-array :initform (asset 'trial:trial 'trial::fullscreen-square) :accessor vertex-array)
   (texture :accessor texture)
   (layers :accessor layers)
   (tileset :initarg :tileset :initform (error "TILESET required.") :accessor tileset
            :type asset :documentation "The tileset texture for the chunk.")
   (size :initarg :size :initform +tiles-in-view+ :accessor size
         :type vec2 :documentation "The size of the chunk in tiles."))
  (:inhibit-shaders (shader-entity :fragment-shader)))

(defmethod initargs append ((_ chunk))
  `(:size :tileset))

(defmethod initialize-instance :after ((chunk chunk) &key layers)
  (let* ((size (size chunk)))
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
                                                  :mag-filter :nearest))))

(defmethod clone ((chunk chunk))
  (make-instance (class-of chunk)
                 :size (clone (size chunk))
                 :tileset (tileset chunk)
                 :tile-size (tile-size chunk)))

(defmethod enter ((chunk chunk) (region region))
  (dotimes (layer (length (objects region)))
    (vector-push-extend chunk (aref (objects region) layer))))

(defmethod leave ((chunk chunk) (region region))
  (dotimes (layer (length (objects region)))
    (array-utils:vector-pop-position*
     (aref (objects region) layer)
     (position chunk (aref (objects region) layer)))))

(defmethod paint ((chunk chunk) (pass shader-pass))
  (let ((program (shader-program-for-pass pass chunk))
        (vao (vertex-array chunk)))
    (translate (nv- (vxy_ (bsize chunk))))
    (setf (uniform program "layer") *current-layer*)
    (setf (uniform program "tile_size") +tile-size+)
    (setf (uniform program "view_size") (vec2 (width *context*) (height *context*)))
    (setf (uniform program "map_size") (size chunk))
    (setf (uniform program "view_matrix") (minv *view-matrix*))
    (setf (uniform program "model_matrix") (minv *model-matrix*))
    (setf (uniform program "tileset") 0)
    (setf (uniform program "tilemap") 1)
    (gl:active-texture :texture0)
    (gl:bind-texture :texture-2d (gl-name (tileset chunk)))
    (gl:active-texture :texture1)
    (gl:bind-texture :texture-2d-array (gl-name (texture chunk)))
    (gl:bind-vertex-array (gl-name vao))
    (%gl:draw-elements :triangles (size vao) :unsigned-int 0)))

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
uniform vec2 map_size;
uniform int tile_size;
uniform int layer;
in vec2 map_coord;
out vec4 color;

void main(){
  ivec2 map_wh = ivec2(map_size)*tile_size;
  ivec2 map_xy = ivec2(map_coord);
  
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
  color = texelFetch(tileset, ivec2(tile)*tile_size+pixel_xy, 0);
}")

(defmethod resize ((chunk chunk) w h)
  (let ((size (vec2 (floor w +tile-size+) (floor h +tile-size+))))
    (unless (v= size (size chunk))
      (setf (size chunk) size))))

(defmethod (setf size) :around (value (chunk chunk))
  ;; Ensure the size is never lower than a screen.
  (call-next-method (vmax value +tiles-in-view+) chunk))

(defmethod (setf size) :before (value (chunk chunk))
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
     (when (and (< -1.0 x (vx (size chunk)))
                (< -1.0 y (vy (size chunk))))
       ,@body)))

(defmethod tile ((location vec2) (chunk chunk))
  (tile (vec3 (vx2 location) (vy2 location) 0) chunk))

(defmethod tile ((location vec3) (chunk chunk))
  (%with-chunk-xy (chunk location)
    (let ((layer (aref (layers chunk) (truncate (vz location))))
          (pos (* 2 (+ x (* y (truncate (vx (size chunk))))))))
      (vec2 (aref layer pos) (aref layer (1+ pos))))))

(defmethod (setf tile) (value (location vec2) (chunk chunk))
  (setf (tile (vec3 (vx2 location) (vy2 location) 0) chunk) value))

(defmethod (setf tile) (value (location vec3) (chunk chunk))
  (%with-chunk-xy (chunk location)
    (let* ((z (+ (truncate (vz location))
                 (floor (length (layers chunk)) 2)))
           (layer (aref (layers chunk) z))
           (pos (* 2 (+ x (* y (truncate (vx (size chunk))))))))
      (setf (aref layer (+ 0 pos)) (truncate (vx2 value)))
      (setf (aref layer (+ 1 pos)) (truncate (vx2 value)))
      (sb-sys:with-pinned-objects (layer)
        (let ((texture (texture chunk)))
          (gl:bind-texture :texture-2d-array (gl-name texture))
          (%gl:tex-sub-image-3d :texture-2d-array 0 x y z 1 1 1 (pixel-format texture) (pixel-type texture)
                                (cffi:inc-pointer (sb-sys:vector-sap layer) pos))))
      value)))

(defmethod flood-fill ((chunk chunk) (location vec3) fill)
  (%with-chunk-xy (chunk location)
    (let* ((z (+ (truncate (vz location))
                 (floor (length (layers chunk)) 2)))
           (layer (aref (layers chunk) z))
           (width (truncate (vx (size chunk))))
           (height (truncate (vy (size chunk))))
           (tmp (vec2 0 0)))
      (labels ((pos (x y)
                 (* (+ x (* y width)) 2))
               (tile (x y)
                 (vsetf tmp
                        (aref layer (+ 0 (pos x y)))
                        (aref layer (+ 1 (pos x y)))))
               ((setf tile) (f x y)
                 (setf (aref layer (+ 0 (pos x y))) (truncate (vx f))
                       (aref layer (+ 1 (pos x y))) (truncate (vy f)))))
        (let ((q ()) (find (tile x y)))
          (unless (v= fill find)
            (push (cons x y) q)
            (loop while q for (n . y) = (pop q)
                  for w = n for e = n
                  do (loop until (or (= w 0) (v/= (tile (1- w) y) find))
                           do (decf w))
                     (loop until (or (= e (1- width)) (v/= (tile (1+ e) y) find))
                           do (incf e))
                     (loop for i from w to e
                           do (setf (tile i y) fill)
                              (when (and (< y (1- height)) (v= (tile i (1+ y)) find))
                                (push (cons i (1+ y)) q))
                              (when (and (< 0 y) (v= (tile i (1- y)) find))
                                (push (cons i (1- y)) q))))
            (sb-sys:with-pinned-objects (layer)
              (let ((texture (texture chunk)))
                (gl:bind-texture :texture-2d (gl-name texture))
                (%gl:tex-sub-image-2d :texture-2d 0 0 0 width height (pixel-format texture) (pixel-type texture)
                                      (sb-sys:vector-sap layer))))))))))

(defmethod flood-fill ((chunk chunk) (location vec2) fill)
  (flood-fill chunk (vec3 (vx2 location) (vy2 location) 0) fill))

(defmethod contained-p ((location vec2) (chunk chunk))
  (%with-chunk-xy (chunk location)
    chunk))

(defmethod scan ((chunk chunk) (target vec2))
  (let ((tile (tile target chunk)))
    (when (and tile (= 1 (vy tile)))
      (aref +surface-blocks+ (truncate (vx tile))))))

(defmethod scan ((chunk chunk) (target game-entity))
  (let* ((tilemap (aref (layers chunk) (floor (length (layers chunk)) 2)))
         (t-s +tile-size+)
         (x- 0) (y- 0) (x+ 0) (y+ 0)
         (w (truncate (vx (size chunk))))
         (h (truncate (vy (size chunk))))
         (size (v+ (bsize target) (/ t-s 2)))
         (pos (location target))
         (lloc (nv+ (v- (location target) (location chunk)) (bsize chunk)))
         (vel (velocity target))
         (declined ()) (result))
    ;; Figure out bounding region
    (if (< 0 (vx vel))
        (setf x- (floor (- (vx lloc) (vx size)) t-s)
              x+ (ceiling (+ (vx lloc) (vx vel)) t-s))
        (setf x- (floor (- (+ (vx lloc) (vx vel)) (vx size)) t-s)
              x+ (ceiling (vx lloc) t-s)))
    (if (< 0 (vy vel))
        (setf y- (floor (- (vy lloc) (vy size)) t-s)
              y+ (ceiling (+ (vy lloc) (vy vel)) t-s))
        (setf y- (floor (- (+ (vy lloc) (vy vel)) (vy size)) t-s)
              y+ (ceiling (vy lloc) t-s)))
    ;; Sweep AABB through tiles
    (loop
       (loop for x from (max x- 0) to (min x+ (1- w))
             do (loop for y from (max y- 0) to (min y+ (1- h))
                      do (when (= 1 (aref tilemap (+ 1 (* (+ x (* y w)) 2))))
                           (let* ((tile (aref tilemap (* (+ x (* y w)) 2)))
                                  (loc (vec2 (+ (* x t-s) (/ t-s 2) (- (vx (location chunk)) (vx (bsize chunk))))
                                             (+ (* y t-s) (/ t-s 2) (- (vy (location chunk)) (vy (bsize chunk))))))
                                  (hit (aabb pos vel loc size)))
                             (when (and hit
                                        (not (find (hit-location hit) declined :test #'v=))
                                        (or (not result)
                                            (< (hit-time hit) (hit-time result))
                                            (and (= (hit-time hit) (hit-time result))
                                                 (< (vsqrdist2 loc (hit-location hit))
                                                    (vsqrdist2 loc (hit-location result))))))
                               (setf (hit-object hit) (aref +surface-blocks+ tile))
                               (setf result hit))))))
       (unless result (return))
       (restart-case
           (progn (collide target (hit-object result) result)
                  (return result))
         (decline ()
           :report "Decline handling the hit."
           (push (hit-location result) declined)
           (setf result NIL))))))
