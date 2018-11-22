(in-package #:org.shirakumo.fraf.leaf)

(define-shader-entity chunk (sized-entity)
  ((vertex-array :initform (asset 'trial:trial 'trial::fullscreen-square) :accessor vertex-array)
   (tileset :initarg :tileset :accessor tileset)
   (tilemap :accessor tilemap)
   (texture :accessor texture)
   (size :initarg :size :accessor size)
   (tile-size :initarg :tile-size :accessor tile-size))
  (:default-initargs
   :size (cons 4 4)
   :tileset (asset 'leaf 'ground)
   :tile-size *default-tile-size*))

(defmethod initialize-instance :after ((chunk chunk) &key size tilemap tile-size)
  (setf (bsize chunk) (v* (vec (car size) (cdr size)) tile-size .5))
  (setf (tilemap chunk) (make-array (round (* (car size) (cdr size) 4)) :element-type '(unsigned-byte 8)))
  (etypecase tilemap
    (null
     (fill (tilemap chunk) 0))
    ((or string pathname)
     (with-open-file (stream tilemap :element-type '(unsigned-byte 8))
       (read-sequence (tilemap chunk) stream)))
    (vector
     (replace (tilemap chunk) tilemap)))
  (setf (texture chunk) (make-instance 'texture :width (car size)
                                                :height (cdr size)
                                                :pixel-data (tilemap chunk)
                                                :pixel-type :unsigned-byte
                                                :pixel-format :rgba-integer
                                                :internal-format :rgba8ui
                                                :min-filter :nearest
                                                :mag-filter :nearest)))

(defmethod paint ((chunk chunk) (pass shader-pass))
  (let ((program (shader-program-for-pass pass chunk))
        (vao (vertex-array chunk))
        (camera (unit :camera T)))
    (setf (uniform program "tile_size") (tile-size chunk))
    (setf (uniform program "view_size") (vec2 (width *context*) (height *context*)))
    (setf (uniform program "view_scale") (/ (view-scale camera)))
    (setf (uniform program "view_offset") (nv+ (v- (location camera) (location chunk)
                                                   (v/ (target-size camera) (zoom camera)))
                                               (bsize chunk)))
    (setf (uniform program "surface_visible") (if (active-p (unit :editor T)) 1 0))
    (setf (uniform program "tileset") 0)
    (setf (uniform program "tilemap") 1)
    (gl:active-texture :texture0)
    (gl:bind-texture :texture-2d (gl-name (tileset chunk)))
    (gl:active-texture :texture1)
    (gl:bind-texture :texture-2d (gl-name (texture chunk)))
    (gl:bind-vertex-array (gl-name vao))
    (%gl:draw-elements :triangles (size vao) :unsigned-int 0)))

(define-class-shader (chunk :vertex-shader)
  "
layout (location = 0) in vec3 vertex;
layout (location = 1) in vec2 vertex_uv;
uniform vec2 view_size;
uniform vec2 view_offset;
uniform float view_scale;
out vec2 map_coord;

void main(){
  map_coord = vertex_uv * view_size * view_scale + view_offset;
  gl_Position = vec4(vertex.xy, -1.0f, 1.0f);
}")

(define-class-shader (chunk :fragment-shader)
  "
uniform sampler2D tileset;
uniform usampler2D tilemap;
uniform int tile_size = 8;
uniform int surface_visible = 0;
in vec2 map_coord;
out vec4 color;

void main(){
  ivec2 map_wh = textureSize(tilemap, 0)*tile_size;
  ivec2 map_xy = ivec2(floor(map_coord));
  ivec4 layers = ivec4(0);
  if(0 <= map_xy.x && 0 <= map_xy.y && map_xy.x < map_wh.x && map_xy.y < map_wh.y)
    layers = ivec4(texelFetch(tilemap, map_xy/tile_size, 0));
  ivec2 set_xy = ivec2(mod(map_xy.x, tile_size), mod(map_xy.y, tile_size));
  vec4 l_s = texelFetch(tileset, set_xy+ivec2(layers.r, 0)*tile_size, 0);
  vec4 ln1 = texelFetch(tileset, set_xy+ivec2(layers.g, 1)*tile_size, 0);
  vec4 l_0 = texelFetch(tileset, set_xy+ivec2(layers.b, 2)*tile_size, 0);
  vec4 lp1 = texelFetch(tileset, set_xy+ivec2(layers.a, 3)*tile_size, 0);
  color = mix(ln1, l_0, l_0.a);
  color = mix(color, lp1, lp1.a);
  if(surface_visible != 0)
    color = mix(color, l_s, l_s.a);
}")

(defmethod resize ((chunk chunk) w h)
  (setf (size cuhnk) (cons w h)))

(defmethod (setf size) :before (value (chunk chunk))
  (let* ((nw (car value))
         (nh (cdr value))
         (ow (car (size chunk)))
         (oh (cdr (size chunk)))
         (tilemap (tilemap chunk))
         (texture (texture chunk))
         (new (make-array (* 4 nw nh) :element-type (array-element-type tilemap))))
    (dotimes (y (min nh oh))
      (dotimes (x (min nw ow))
        (let ((npos (* 4 (+ x (* y nw))))
              (opos (* 4 (+ x (* y ow)))))
          (dotimes (c 4)
            (setf (aref new (+ npos c)) (aref tilemap (+ opos c)))))))
    (when (gl-name texture)
      (sb-sys:with-pinned-objects (tilemap)
        (gl:tex-image-2d :texture-2d 0 (internal-format texture) nw nh 0 (pixel-format texture) (pixel-type texture)
                         (sb-sys:vector-sap tilemap))))
    (setf (pixel-data texture) new)
    (setf (tilemap chunk) new)))

(defmethod (setf size) :after (value (chunk chunk))
  (setf (width (texture chunk)) (car value))
  (setf (height (texture chunk)) (cdr value))
  (setf (bsize chunk) (v* (vec (car value) (cdr value)) (tile-size chunk) .5)))

(defmacro %with-chunk-xy ((chunk location) &body body)
  `(let ((x (floor (+ (- (vx ,location) (vx2 (location ,chunk))) (vx2 (bsize ,chunk))) (tile-size ,chunk)))
         (y (floor (+ (- (vy ,location) (vy2 (location ,chunk))) (vy2 (bsize ,chunk))) (tile-size ,chunk))))
     (when (and (< -1 x (car (size chunk)))
                (< -1 y (cdr (size chunk))))
       ,@body)))

(defmethod tile ((location vec2) (chunk chunk))
  (tile (vec3 (vx2 location) (vy2 location) 0) chunk))

(defmethod tile ((location vec3) (chunk chunk))
  (%with-chunk-xy (chunk location)
    (let ((pos (+ (* (+ x (* y (car (size chunk)))) 4)
                  (floor (vz location)))))
      (aref (tilemap chunk) pos))))

(defmethod (setf tile) (value (location vec2) (chunk chunk))
  (setf (tile (vec3 (vx2 location) (vy2 location) 0) chunk) value))

(defmethod (setf tile) (value (location vec3) (chunk chunk))
  (%with-chunk-xy (chunk location)
    (let ((pos (+ (* (+ x (* y (car (size chunk)))) 4)
                  (floor (vz location))))
          (tilemap (tilemap chunk)))
      (setf (aref tilemap pos) value)
      (sb-sys:with-pinned-objects (tilemap)
        (let ((texture (texture chunk)))
          (gl:bind-texture :texture-2d (gl-name texture))
          (%gl:tex-sub-image-2d :texture-2d 0 x y 1 1 (pixel-format texture) (pixel-type texture)
                                (cffi:inc-pointer (sb-sys:vector-sap tilemap)
                                                  (* (+ x (* y (car (size chunk)))) 4)))))
      value)))

(defmethod flood-fill ((chunk chunk) (location vec3) fill)
  (%with-chunk-xy (chunk location)
    (let ((tilemap (tilemap chunk))
          (width (car (size chunk)))
          (height (cdr (size chunk))))
      (labels ((pos (x y) (floor (+ (* (+ x (* y width)) 4) (vz location))))
               (tile (x y) (aref tilemap (pos x y)))
               ((setf tile) (f x y) (setf (aref tilemap (pos x y)) f)))
        (let ((q ()) (find (tile x y)))
          (unless (= fill find)
            (push (cons x y) q)
            (loop while q for (n . y) = (pop q)
                  for w = n for e = n
                  do (loop until (or (= w 0) (/= (tile (1- w) y) find))
                           do (decf w))
                     (loop until (or (= e (1- width)) (/= (tile (1+ e) y) find))
                           do (incf e))
                     (loop for i from w to e
                           do (setf (tile i y) fill)
                              (when (and (< y (1- height)) (= (tile i (1+ y)) find))
                                (push (cons i (1+ y)) q))
                              (when (and (< 0 y) (= (tile i (1- y)) find))
                                (push (cons i (1- y)) q))))
            (sb-sys:with-pinned-objects (tilemap)
              (let ((texture (texture chunk)))
                (gl:bind-texture :texture-2d (gl-name texture))
                (%gl:tex-sub-image-2d :texture-2d 0 0 0 width height (pixel-format texture) (pixel-type texture)
                                      (sb-sys:vector-sap tilemap))))))))))

(defmethod flood-fill ((chunk chunk) (location vec2) fill)
  (flood-fill chunk (vec3 (vx2 location) (vy2 location) 0) fill))

(defmethod contained-p ((location vec2) (chunk chunk))
  (%with-chunk-xy (chunk location)
    chunk))

(defmethod scan ((chunk chunk) (target vec2))
  (let ((tile (tile target chunk)))
    (when (and tile (or (= tile 1) (= tile 2)))
      (aref +surface-blocks+ tile))))

(defmethod scan ((chunk chunk) (target game-entity))
  (let* ((tilemap (tilemap chunk))
         (t-s (tile-size chunk))
         (x- 0) (y- 0) (x+ 0) (y+ 0)
         (w (car (size chunk)))
         (h (cdr (size chunk)))
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
                      for tile = (aref tilemap (* (+ x (* y w)) 4))
                      for loc = (vec2 (+ (* x t-s) (/ t-s 2) (- (vx (location chunk)) (vx (bsize chunk))))
                                      (+ (* y t-s) (/ t-s 2) (- (vy (location chunk)) (vy (bsize chunk)))))
                      for hit = (when (/= 0 tile) (aabb pos vel loc size))
                      do (when (and hit
                                    (not (find (hit-location hit) declined :test #'v=))
                                    (or (not result)
                                        (< (hit-time hit) (hit-time result))
                                        (and (= (hit-time hit) (hit-time result))
                                             (< (vsqrdist2 loc (hit-location hit))
                                                (vsqrdist2 loc (hit-location result))))))
                           (setf (hit-object hit) (aref +surface-blocks+ tile))
                           (setf result hit))))
       (unless result (return))
       (restart-case
           (progn (collide target (hit-object result) result)
                  (return result))
         (decline ()
           :report "Decline handling the hit."
           (push (hit-location result) declined)
           (setf result NIL))))))
