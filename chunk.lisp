(in-package #:org.shirakumo.fraf.leaf)

(define-shader-entity chunk ()
  ((flare:name :initform :surface)
   (vertex-array :initform (asset 'trial:trial 'trial::fullscreen-square) :accessor vertex-array)
   (location :initarg :location :initform (vec 0 0) :accessor location)
   (tileset :initarg :tileset :accessor tileset)
   (tilemap :accessor tilemap)
   (texture :accessor texture)
   (size :initarg :size :accessor size)
   (bsize :accessor bsize)
   (tile-size :initarg :tile-size :accessor tile-size))
  (:default-initargs
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
    (setf (uniform program "view_offset") (nv+ (v- (location camera) (location chunk))
                                               (bsize chunk)))
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
  gl_Position = vec4(vertex, 1.0f);
}")

(define-class-shader (chunk :fragment-shader)
  "
uniform sampler2D tileset;
uniform usampler2D tilemap;
uniform int tile_size = 8;
in vec2 map_coord;
out vec4 color;

void main(){
  ivec2 map_xy = ivec2(floor(map_coord));
  ivec4 layers = ivec4(0);
  if(0 <= map_xy.x && 0 <= map_xy.y)
    layers = ivec4(texelFetch(tilemap, map_xy/tile_size, 0));
  ivec2 set_xy = ivec2(mod(map_xy.x, tile_size), mod(map_xy.y, tile_size));
  vec4 l__ = texelFetch(tileset, set_xy+ivec2(layers.r, 2)*tile_size, 0);
  vec4 ln1 = texelFetch(tileset, set_xy+ivec2(layers.g, 1)*tile_size, 0);
  vec4 l_0 = texelFetch(tileset, set_xy+ivec2(layers.b, 0)*tile_size, 0);
  vec4 lp1 = texelFetch(tileset, set_xy+ivec2(layers.a, 1)*tile_size, 0);
  color = mix(ln1, l_0, l_0.a);
  color = mix(color, lp1, lp1.a);
  color = mix(color, l__, l__.a);
}")

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
         (loc (location target))
         (vel (velocity target))
         (declined ()) (result))
    ;; Figure out bounding region
    (if (< 0 (vx vel))
        (setf x- (floor (- (vx loc) (vx size)) t-s)
              x+ (ceiling (+ (vx loc) (vx vel)) t-s))
        (setf x- (floor (- (+ (vx loc) (vx vel)) (vx size)) t-s)
              x+ (ceiling (vx loc) t-s)))
    (if (< 0 (vy vel))
        (setf y- (floor (- (vy loc) (vy size)) t-s)
              y+ (ceiling (+ (vy loc) (vy vel)) t-s))
        (setf y- (floor (- (+ (vy loc) (vy vel)) (vy size)) t-s)
              y+ (ceiling (vy loc) t-s)))
    ;; Sweep AABB through tiles
    (loop
       (loop for x from (max x- 0) to (min x+ (1- w))
             do (loop for y from (max y- 0) to (min y+ (1- h))
                      for tile = (aref tilemap (* (+ x (* y w)) 4))
                      for hit = (when (/= 0 tile) (aabb loc vel (vec (+ (/ t-s 2) (* t-s x)) (+ (/ t-s 2) (* t-s y))) size))
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
