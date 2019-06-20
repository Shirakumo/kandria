(in-package #:org.shirakumo.fraf.leaf)

(define-shader-entity chunk (sized-entity solid)
  ((vertex-array :initform (asset 'trial:trial 'trial::fullscreen-square) :accessor vertex-array)
   (texture :accessor texture)
   (layers :accessor layers)
   (tileset :initarg :tileset :initform (error "TILESET required.") :accessor tileset
            :type asset :documentation "The tileset texture for the chunk.")
   (size :initarg :size :initform *tiles-in-view* :accessor size
         :type vec2 :documentation "The size of the chunk in tiles."))
  (:inhibit-shaders (shader-entity :fragment-shader)))

(defmethod initargs append ((_ chunk))
  `(:size :tileset))

(defmethod initialize-instance :after ((chunk chunk) &key tilemap)
  (let* ((size (size chunk))
         (layers (loop for path in tilemap
                       for image = (pngload:load-file path :flatten T)
                       do (when (or (/= (pngload:width image) (vx size))
                                    (/= (pngload:height image) (vy size)))
                            (error "Size discrepancy: ~ax~a, expected ~ax~a."
                                   (pngload:width image) (pngload:height image)
                                   (vx size) (vy size)))
                       collect (pngload:data image))))
    (setf (layers chunk) layers)
    (setf (bsize chunk) (v* size *default-tile-size* .5))
    (setf (texture chunk) (make-instance 'texture :target :texture-2d-array
                                                  :width (floor (vx size))
                                                  :height (floor (vy size))
                                                  :depth (length (layers chunk))
                                                  :pixel-data (layers chunk)
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

(defmethod paint ((chunk chunk) (pass shader-pass))
  (let ((program (shader-program-for-pass pass chunk))
        (vao (vertex-array chunk)))
    
    (setf (uniform program "layer") *current-layer*)
    (setf (uniform program "tile_size") *default-tile-size*)
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

  // Invert so that we're looking things up bottom to top.
  map_xy.y = map_wh.y - map_xy.y;
  
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
  (let ((size (vec2 (floor w (tile-size chunk)) (floor h (tile-size chunk)))))
    (unless (v= size (size chunk))
      (setf (size chunk) size))))

(defmethod (setf size) :around (value (chunk chunk))
  ;; Ensure the size is never lower than a screen.
  (call-next-method (vmax value *tiles-in-view*) chunk))

(defmethod (setf size) :before (value (chunk chunk))
  (let* ((nw (vx2 value))
         (nh (vy2 value))
         (ow (vx2 (size chunk)))
         (oh (vy2 (size chunk)))
         (layers (layers chunk))
         (texture (texture chunk))
         (new-layers (make-list (length layers))))
    ;; Allocate resized and copy data over. Slow!
    (loop for old in layers
          for new on new-layers
          for tilemap = (make-array (* 4 nw nh) :element-type '(unsigned-byte 8)
                                                :initial-element 0)
          do (setf (car new) tilemap)
             (dotimes (y (min nh oh))
               (dotimes (x (min nw ow))
                 (let ((npos (* 4 (+ x (* y nw))))
                       (opos (* 4 (+ x (* y ow)))))
                   (dotimes (c 4)
                     (setf (aref tilemap (+ npos c)) (aref old (+ opos c))))))))
    ;; Resize the texture. Internal mechanisms should take care of re-mapping the pixel data.
    (when (gl-name texture)
      (setf (pixel-data texture) new-layers)
      (setf (layers chunk) new-layers)
      (resize texture nw nh))))

(defmethod (setf size) :after (value (chunk chunk))
  (setf (bsize chunk) (v* value *default-tile-size* .5)))
