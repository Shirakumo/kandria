(in-package #:org.shirakumo.fraf.kandria)

(define-shader-entity layer (lit-entity sized-entity resizable ephemeral)
  ((vertex-array :initform (// 'trial 'fullscreen-square) :accessor vertex-array)
   (tile-data :initarg :tile-data :accessor tile-data :type tile-data
              :documentation "The tileset to render with")
   (tilemap :accessor tilemap)
   (layer-index :initarg :layer-index :initform 0 :accessor layer-index)
   (visibility :initform 1.0 :accessor visibility)
   (albedo :initarg :albedo :initform (// 'kandria 'debug) :accessor albedo)
   (absorption :initarg :absorption :initform (// 'kandria 'debug) :accessor absorption)
   (normal :initarg :normal :initform (// 'kandria 'debug) :accessor normal)
   (size :initarg :size :initform +tiles-in-view+ :accessor size
         :type vec2 :documentation "The size of the chunk in tiles."))
  (:inhibit-shaders (shader-entity :fragment-shader))
  (:default-initargs :tile-data (asset 'kandria 'debug)))

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
    (setf (absorption layer) (resource tile-data 'absorption))
    (setf (normal layer) (resource tile-data 'normal))))

(defmethod stage ((layer layer) (area staging-area))
  (stage (vertex-array layer) area)
  (stage (tilemap layer) area)
  (stage (albedo layer) area)
  (stage (absorption layer) area)
  (stage (normal layer) area))

(defmethod pixel-data ((layer layer))
  (pixel-data (tilemap layer)))

(defmethod (setf pixel-data) ((data vector) (layer layer))
  (replace (pixel-data (tilemap layer)) data)
  (update-layer layer))

(defmethod resize ((layer layer) w h)
  (let ((size (vec2 (floor w +tile-size+) (floor h +tile-size+))))
    (unless (v= size (size layer))
      (setf (size layer) size))))

(defmethod resize-layer ((layer layer) w h &optional xanchor yanchor)
  (let* ((nw (floor w +tile-size+))
         (nh (floor h +tile-size+))
         (ow (floor (vx2 (size layer))))
         (oh (floor (vy2 (size layer))))
         (ox (ecase xanchor
               (:left 0)
               (:right (- nw ow))))
         (oy (ecase yanchor
               (:bottom 0)
               (:top (- nh oh)))))
    (when (or (/= nw ow) (/= nh oh))
      (let ((tilemap (pixel-data layer))
            (new-tilemap (make-array (* 2 nw nh) :element-type '(unsigned-byte 8)
                                                 :initial-element 0)))
        ;; KLUDGE: this is obviously really inefficient, lol
        (let ((stencil (stencil-from-map tilemap ow oh 0 0 ow oh)))
          (set-tile-stencil new-tilemap nw nh ox oy stencil))
        (setf (pixel-data (tilemap layer)) new-tilemap)
        (when (gl-name (tilemap layer))
          (resize (tilemap layer) nw nh)))
      (setf (vx (size layer)) nw)
      (setf (vy (size layer)) nh)
      (setf (vx (bsize layer)) (* nw +tile-size+ .5))
      (setf (vy (bsize layer)) (* nh +tile-size+ .5)))))

(defmethod commit-resize-data ((layer layer))
  (list (vx (size layer)) (vy (size layer)) (copy-seq (pixel-data layer))))

(defmethod restore-resize-data ((layer layer) data)
  (destructuring-bind (nw nh data) data
    (setf (vx (size layer)) nw)
    (setf (vy (size layer)) nh)
    (setf (vx (bsize layer)) (* nw +tile-size+ .5))
    (setf (vy (bsize layer)) (* nh +tile-size+ .5))
    (setf (pixel-data (tilemap layer)) (copy-seq data))
    (resize (tilemap layer) nw nh)))

(defmethod (setf size) (value (layer layer))
  (resize-layer layer (vx2 value) (vy2 value) :left :bottom))

(defmacro %with-layer-xy ((layer location) &body body)
  `(let ((x (floor (+ (- (vx ,location) (vx2 (location ,layer))) (vx2 (bsize ,layer))) +tile-size+))
         (y (floor (+ (- (vy ,location) (vy2 (location ,layer))) (vy2 (bsize ,layer))) +tile-size+)))
     (when (and (< -1.0 x (vx2 (size ,layer)))
                (< -1.0 y (vy2 (size ,layer))))
       ,@body)))

(defmethod contained-p ((a layer) (b layer))
  (and (< (abs (- (vx (location a)) (vx (location b)))) (+ (vx (bsize a)) (vx (bsize b))))
       (< (abs (- (vy (location a)) (vy (location b)))) (+ (vy (bsize a)) (vy (bsize b))))))

(defmethod contained-p ((a vec4) (b layer))
  (and (< (abs (- (vx a) (vx (location b)))) (+ (vz a) (vx (bsize b))))
       (< (abs (- (vy a) (vy (location b)))) (+ (vw a) (vy (bsize b))))))

(defmethod contained-p ((entity located-entity) (layer layer))
  (contained-p (location entity) layer))

(defmethod contained-p ((location vec2) (layer layer))
  (%with-layer-xy (layer location)
    layer))

(defun find-ground (layer location)
  (let* ((w (truncate (vx (size layer))))
         (h (truncate (vy (size layer))))
         (size (* 2 (* w h)))
         (data (pixel-data (tilemap layer))))
    (%with-layer-xy (layer location)
      (let ((i (or (loop for i downfrom (* 2 (+ x (* y w))) to 0 by (* 2 w)
                         for above = (+ i (* 2 w))
                         do (when (and (< 0 (aref data i))
                                       (< above size)
                                       (= 0 (aref data above)))
                              (return (+ i (* 2 w)))))
                   (loop for i upfrom (* 2 (+ x (* y w))) below size by (* 2 w)
                         for above = (+ i (* 2 w))
                         do (when (and (< 0 (aref data i))
                                       (< above size)
                                       (= 0 (aref data above)))
                              (return (+ i (* 2 w)))))
                   (* 2 (+ x (* y w))))))
        (vec (vx location)
             (+ (* +tile-size+ (floor i (* 2 w))) (- (vy2 (location layer)) (vy2 (bsize layer)))))))))

(defmethod tile ((location vec2) (layer layer))
  (%with-layer-xy (layer location)
    (let ((pos (* 2 (+ x (* y (truncate (vx (size layer))))))))
      (list (aref (pixel-data layer) pos) (aref (pixel-data layer) (1+ pos))))))

(defmethod (setf tile) (value (location vec2) (layer layer))
  (let ((dat (pixel-data layer))
        (texture (tilemap layer)))
    (%with-layer-xy (layer location)
      (set-tile dat (truncate (vx2 (size layer))) (truncate (vy2 (size layer))) x y value))
    (update-layer layer)
    #++ ;; TODO: Optimize
    (sb-sys:with-pinned-objects (dat)
      (gl:bind-texture :texture-2d (gl-name texture))
      (%gl:tex-sub-image-2d :texture-2d 0 x y 1 1 (pixel-format texture) (pixel-type texture)
                            (cffi:inc-pointer (sb-sys:vector-sap dat) pos))
      (gl:bind-texture :texture-2d 0)))
  value)

(defmethod tile ((location vec3) (layer layer))
  (tile (vxy location) layer))

(defmethod (setf tile) (value (location vec3) (layer layer))
  (setf (tile (vxy location) layer) value))

(defmethod layers ((layer layer))
  (make-array +layer-count+ :initial-element layer))

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

(defmethod clear ((layer layer))
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

(defmethod flood-fill ((layer layer) (location vec3) fill)
  (flood-fill layer (vxy location) fill))

(defmethod (setf tile-data) :after ((data tile-data) (layer layer))
  (unless (allocated-p (resource data 'albedo))
    (let ((area (make-instance 'staging-area)))
      (stage (resource data 'albedo) area)
      (stage (resource data 'absorption) area)
      (stage (resource data 'normal) area)
      (trial:commit area (loader +main+) :unload NIL)))
  (setf (albedo layer) (resource data 'albedo))
  (setf (absorption layer) (resource data 'absorption))
  (setf (normal layer) (resource data 'normal))
  ;; KLUDGE: This sucks lmao. Refresh entity here to regen the tilemap sidebar.
  (let ((editor (find-panel 'editor)))
    (when (and editor (eq (entity editor) layer))
      (setf (sidebar editor) NIL)
      (setf (sidebar editor) (make-instance 'chunk-widget :editor editor :side :east)))))

(defmethod render ((layer layer) (program shader-program))
  (when (< 0.0 (visibility layer))
    (setf (uniform program "visibility") (visibility layer))
    (setf (uniform program "map_size") (size layer))
    (setf (uniform program "projection_matrix") *projection-matrix*)
    (setf (uniform program "view_matrix") *view-matrix*)
    (setf (uniform program "model_matrix") *model-matrix*)
    (setf (uniform program "tilemap") 0)
    ;; TODO: Could optimise by merging absorption with normal, absorption being in the B channel.
    ;;       Then could merge albedo and absorption into one texture array to minimise draw calls.
    (setf (uniform program "albedo") 1)
    (setf (uniform program "absorption") 2)
    (setf (uniform program "normal") 3)
    (gl:active-texture :texture0)
    (gl:bind-texture :texture-2d (gl-name (tilemap layer)))
    (gl:active-texture :texture1)
    (gl:bind-texture :texture-2d (gl-name (albedo layer)))
    (gl:active-texture :texture2)
    (gl:bind-texture :texture-2d (gl-name (absorption layer)))
    (gl:active-texture :texture3)
    (gl:bind-texture :texture-2d (gl-name (normal layer)))
    (gl:bind-vertex-array (gl-name (vertex-array layer)))
    (unwind-protect
         (%gl:draw-elements :triangles (size (vertex-array layer)) :unsigned-int 0)
      (gl:bind-vertex-array 0))))

(define-class-shader (layer :vertex-shader)
  "layout (location = 0) in vec3 vertex;
layout (location = 1) in vec2 vertex_uv;
uniform mat4 view_matrix;
uniform mat4 model_matrix;
uniform mat4 projection_matrix;
uniform vec2 map_size;
uniform usampler2D tilemap;
out vec2 pix_uv;
out vec2 world_pos;
const int tile_size = 16;

void main(){
  vec2 vert = (vertex.xy*map_size*tile_size*0.5);
  vec4 temp = model_matrix * vec4(vert, 0, 1);
  gl_Position = projection_matrix * view_matrix * temp;
  world_pos = temp.xy;
  pix_uv = vertex_uv * map_size;
}")

(define-class-shader (layer :fragment-shader)
  "
uniform usampler2D tilemap;
uniform sampler2D albedo;
uniform sampler2D absorption;
uniform sampler2D normal;
uniform float visibility = 1.0;
const int tile_size = 16;
in vec2 pix_uv;
in vec2 world_pos;
out vec4 color;

void main(){
  // Calculate tilemap index and pixel offset within tile.
  ivec2 pixel_xy = ivec2((pix_uv-floor(pix_uv)) * tile_size);
  ivec2 map_xy = ivec2(pix_uv);

  // Look up tileset index from tilemap and pixel from tileset.
  uvec2 tile = texelFetch(tilemap, map_xy, 0).rg;
  ivec2 tile_xy = ivec2(tile)*tile_size+pixel_xy;
  color = texelFetch(albedo, tile_xy, 0);
  float a = texelFetch(absorption, tile_xy, 0).r;
  vec2 n = texelFetch(normal, tile_xy, 0).rg-0.5;
  if(abs(n.x) < 0.1 && abs(n.y) < 0.1)
    color = apply_lighting_flat(color, vec2(0), 1-a, world_pos);
  else
    color = apply_lighting(color, vec2(0), 1-a, normalize(n), world_pos);
  color.a *= visibility;
}")

(define-shader-entity bg-layer (layer)
  ((overlay :initarg :overlay :initform (// 'kandria 'placeholder) :accessor overlay :type texture
            :documentation "The overlay texture that replaces pink spots"))
  (:inhibit-shaders (layer :fragment-shader)))

(defmethod stage :after ((layer bg-layer) (area staging-area))
  (stage (overlay layer) area))

(defmethod render :before ((layer bg-layer) (program shader-program))
  (setf (uniform program "overlay") 4)
  (gl:active-texture :texture4)
  (gl:bind-texture :texture-2d (gl-name (overlay layer))))

(define-class-shader (bg-layer :fragment-shader)
  "
uniform usampler2D tilemap;
uniform sampler2D albedo;
uniform sampler2D absorption;
uniform sampler2D normal;
uniform sampler2D overlay;
uniform float visibility = 1.0;
const int tile_size = 16;
in vec2 pix_uv;
in vec2 world_pos;
out vec4 color;

void main(){
  // Calculate tilemap index and pixel offset within tile.
  ivec2 pixel_xy = ivec2((pix_uv-floor(pix_uv)) * tile_size);
  ivec2 map_xy = ivec2(pix_uv);

  // Look up tileset index from tilemap and pixel from tileset.
  uvec2 tile = texelFetch(tilemap, map_xy, 0).rg;
  ivec2 tile_xy = ivec2(tile)*tile_size+pixel_xy;
  color = texelFetch(albedo, tile_xy, 0);
  float a = texelFetch(absorption, tile_xy, 0).r;
  vec2 n = texelFetch(normal, tile_xy, 0).rg-0.5;

  if(color.rgb == vec3(1,0,1))
    color = texture(overlay, world_pos/textureSize(overlay, 0), 0);

  if(abs(n.x) < 0.1 && abs(n.y) < 0.1)
    color = apply_lighting_flat(color, vec2(0), 1-a, world_pos);
  else
    color = apply_lighting(color, vec2(0), 1-a, normalize(n), world_pos);
  color.a *= visibility;
}")

(define-shader-entity chunk (shadow-caster layer solid ephemeral collider creatable)
  ((layer-index :initform (1- +layer-count+))
   (layers :accessor layers)
   (visibility :initform 0.0)
   (node-graph :initform NIL :initarg :node-graph :accessor node-graph)
   (show-solids :initform NIL :accessor show-solids)
   (tile-data :initarg :tile-data :accessor tile-data
              :type tile-data :documentation "The tile data used to display the chunk")
   (background :initform (background 'debug) :initarg :background :accessor background
               :type background-info :documentation "The background to show in the chunk")
   (bg-overlay :initform (// 'kandria 'placeholder) :initarg :bg-overlay :accessor bg-overlay
               :type texture :documentation "The texture to merge with pink pixels on layer 0")
   (gi :initform (gi 'none) :initarg :gi :accessor gi
       :type gi-info :documentation "The lighting to show in the chunk")
   (name :initform (generate-name "CHUNK"))
   (chunk-graph-id :initform NIL :accessor chunk-graph-id)
   (environment :initform NIL :initarg :environment :accessor environment
                :type environment :documentation "The music environment to use")
   (visible-on-map-p :initform T :initarg :visible-on-map-p :accessor visible-on-map-p
                     :type boolean :documentation "Whether the chunk is visible on the map or not
Useful for interiors")
   (unlocked-p :initform NIL :initarg :unlocked-p :accessor unlocked-p))
  (:default-initargs :tile-data (asset 'kandria 'debug)))

(defmethod initialize-instance :after ((chunk chunk) &key (layers (make-list +layer-count+)) tile-data)
  (let* ((size (size chunk))
         (layers (list* (make-instance 'bg-layer :size (vcopy size) :location (location chunk) :layer-index 0
                                                 :tile-data tile-data :pixel-data (first layers)
                                                 :overlay (bg-overlay chunk))
                  (loop for i from 1
                        for data in (rest layers)
                        collect (make-instance 'layer :size (vcopy size) :location (location chunk) :layer-index i
                                                      :tile-data tile-data :pixel-data data)))))
    (setf (layers chunk) (coerce layers 'vector))
    (register-generation-observer chunk tile-data)))

(defmethod print-object ((chunk chunk) stream)
  (print-unreadable-object (chunk stream :type T)
    (format stream "~s" (name chunk))))

(defmethod observe-generation ((chunk chunk) (data tile-data) result)
  (compute-shadow-geometry chunk T)
  (unless (node-graph chunk)
    (setf (node-graph chunk) (make-node-graph chunk (or *region* (region +world+))))))

(defmethod recompute ((chunk chunk))
  (compute-shadow-geometry chunk T)
  (setf (node-graph chunk) (make-node-graph chunk)))

(defmethod (setf size) :around (value (chunk chunk))
  ;; Ensure the size is never lower than a screen.
  (call-next-method (vmax value +tiles-in-view+) chunk))

(defmethod (setf bg-overlay) :after (value (chunk chunk))
  (setf (overlay (aref (layers chunk) 0)) value))

(defmethod experience-reward ((chunk chunk))
  100)

(defmethod (setf show-solids) :after (value (chunk chunk))
  (setf (visibility chunk) (cond (value 1.0)
                                 ((find-panel 'editor) 0.3)
                                 (T 0.0))))

(defmethod enter :after ((chunk chunk) (container container))
  (loop for layer across (layers chunk)
        do (enter layer container)))

(defmethod leave :after ((chunk chunk) (container container))
  (loop for layer across (layers chunk)
        do (leave layer container)))

(defmethod stage :after ((chunk chunk) (area staging-area))
  (loop for layer across (layers chunk)
        do (stage layer area))
  (when (environment chunk)
    (stage (environment chunk) area))
  (stage (background chunk) area))

(defmethod clone ((chunk chunk) &rest initargs)
  (apply #'make-instance (class-of chunk)
         (append initargs
                 (list
                  :size (clone (size chunk))
                  :tile-data (tile-data chunk)
                  :pixel-data (clone (pixel-data chunk))
                  :layers (mapcar #'clone (map 'list #'pixel-data (layers chunk)))
                  :background (background chunk)
                  :gi (gi chunk)))))

(defmethod resize-layer :after ((chunk chunk) w h &optional (xanchor :left) (yanchor :bottom))
  (loop for layer across (layers chunk)
        do (resize-layer layer w h xanchor yanchor)))

(defmethod commit-resize-data ((chunk chunk))
  (list* (call-next-method)
         (loop for layer across (layers chunk)
               collect (commit-resize-data layer))))

(defmethod restore-resize-data ((chunk chunk) data)
  (destructuring-bind (data . layers) data
    (call-next-method chunk data)
    (loop for layer across (layers chunk)
          for data in layers
          do (restore-resize-data layer data))))

(defmethod (setf location) :around (location (chunk chunk))
  (let ((diff (v- location (location chunk))))
    ;; NOTE: Can't use region bvh here as we want to reach everything even things that aren't colliders
    (for:for ((entity over (region +world+)))
      (when (and (not (eql 'layer (type-of entity)))
                 (not (eql 'bg-layer (type-of entity)))
                 (not (eql 'chunk (type-of entity)))
                 (contained-p entity chunk))
        (setf (location entity) (v+ (location entity) diff))))
    (call-next-method)))

(defmethod (setf location) :after (location (chunk chunk))
  (loop for layer across (layers chunk)
        do (setf (location layer) location)
           (bvh:bvh-update (bvh (region +world+)) layer)))

(defmethod clear :after ((chunk chunk))
  (loop for layer across (layers chunk)
        do (clear layer)))

(defmethod (setf tile-data) :after ((data tile-data) (chunk chunk))
  (flet ((update-layer (layer)
           (setf (albedo layer) (resource data 'albedo))
           (setf (absorption layer) (resource data 'absorption))
           (setf (normal layer) (resource data 'normal))))
    (map NIL #'update-layer (layers chunk))))

(defmethod (setf background) :after ((data background-info) (chunk chunk))
  (trial:commit data (loader +main+) :unload NIL))

(defmethod solid ((location vec2) (chunk chunk))
  (%with-layer-xy (chunk location)
    (aref (pixel-data chunk) (* 2 (+ x (* y (truncate (vx (size chunk)))))))))

(defmethod tile ((location vec3) (chunk chunk))
  (tile (vxy location) (aref (layers chunk) (floor (vz location)))))

(defmethod (setf tile) :around ((value vec2) (location vec2) (chunk chunk))
  (when (and value (= 0 (vy value)))
    (call-next-method)))

(defmethod (setf tile) (value (location vec3) (chunk chunk))
  (setf (tile (vxy location) (aref (layers chunk) (floor (vz location)))) value))

(defmethod flood-fill ((chunk chunk) (location vec3) fill)
  (flood-fill (aref (layers chunk) (floor (vz location))) (vxy location) fill))

(defmethod entity-at-point (point (chunk chunk))
  (or (call-next-method)
      (when (contained-p point chunk)
        chunk)))

(defmethod auto-tile ((chunk chunk) (location vec2) types)
  (%with-layer-xy (chunk location)
    (let* ((width (truncate (vx (size chunk))))
           (height (truncate (vy (size chunk)))))
      (when (= 0 (aref (pixel-data chunk) (* (+ x (* y width)) 2)))
        (%flood-fill (pixel-data chunk) width height x y (list 22 0)))
      (%auto-tile (pixel-data chunk)
                  (pixel-data (aref (layers chunk) +base-layer+))
                  width height types)
      (update-layer (aref (layers chunk) +base-layer+))
      (update-layer chunk))))

(defmethod auto-tile ((chunk chunk) (region vec4) types)
  (%with-layer-xy (chunk region)
    (let* ((width (truncate (vx (size chunk))))
           (height (truncate (vy (size chunk)))))
      (%auto-tile (pixel-data chunk)
                  (pixel-data (aref (layers chunk) +base-layer+))
                  width height types x y (floor (vz region) +tile-size+) (floor (vw region) +tile-size+))
      (update-layer (aref (layers chunk) +base-layer+)))))

(defmethod auto-tile ((chunk chunk) (location vec3) types)
  )

(defmethod compute-shadow-geometry ((chunk chunk) (vbo vertex-buffer))
  (let* ((w (truncate (vx (size chunk))))
         (h (truncate (vy (size chunk))))
         (layer (pixel-data (aref (layers chunk) +base-layer+)))
         (info (tile-types (generator (albedo chunk))))
         (data (buffer-data vbo)))
    ;; TODO: Optimise the lines by merging them together whenever possible
    (labels ((map-tile-types (fun x y)
               (let ((x (aref layer (+ 0 (* 2 (+ x (* y w))))))
                     (y (aref layer (+ 1 (* 2 (+ x (* y w)))))))
                 (loop for (name . set) in info
                       thereis
                       (loop for (type . tiles) in set
                             for found = (loop for (_x _y) in tiles
                                               thereis (and (= x _x) (= y _y)))
                             do (when found
                                  (funcall fun type)))))))
      (setf (fill-pointer data) 0)
      (dotimes (y h)
        (dotimes (x w)
          (labels ((line (xa ya xb yb)
                     (let ((x (+ 8 (* (- x (/ w 2)) +tile-size+)))
                           (y (+ 8 (* (- y (/ h 2)) +tile-size+))))
                       (add-shadow-line vbo (vec (+ x xa) (+ y ya)) (vec (+ x xb) (+ y yb)))))
                   (tile (tile)
                     ;; Surface tiles
                     (case* tile
                       ((:t :vt :h :hl :hr :tl> :tr> :bl< :br<) (line -8 +8 +8 +8))
                       ((:r :v :vt :vb :hr :tr> :br> :tl< :bl<) (line +8 -8 +8 +8))
                       ((:b :vb :h :hl :hr :br> :bl> :tl< :tr<) (line -8 -8 +8 -8))
                       ((:l :v :vt :vb :hl :tl> :bl> :tr< :br<) (line -8 -8 -8 +8))
                       (:cr (line -8 -8 +8 0) (line -8 +8 +8 0))
                       (:cl (line +8 -8 -8 0) (line +8 +8 -8 0))
                       (:ct (line -8 -8 0 +8) (line +8 -8 0 +8))
                       (:cb (line -8 +8 0 -8) (line +8 +8 0 -8))
                       (:h (line -8 0 +8 0))
                       (:v (line 0 -8 0 +8)))
                     ;; Slopes
                     (when (and (listp tile) (eql :slope (first tile)))
                       (let ((t-info (aref +surface-blocks+ (+ 4 (second tile)))))
                         (line (vx (slope-l t-info)) (vy (slope-l t-info)) (vx (slope-r t-info)) (vy (slope-r t-info)))))
                     ;; Edge caps
                     (when tile
                       (cond ((= x 0)      (line -8 -8 -8 +8))
                             ((= x (1- w)) (line +8 -8 +8 +8)))
                       (cond ((= y 0)      (line -8 -8 +8 -8))
                             ((= y (1- h)) (line -8 +8 +8 +8))))))
            (map-tile-types #'tile x y)))))))

(defmethod scan ((chunk chunk) (target vec2) on-hit)
  (%with-layer-xy (chunk target)
    (let* ((pos (* 2 (+ x (* y (truncate (vx (size chunk)))))))
           (u (aref (pixel-data chunk) pos))
           (v (aref (pixel-data chunk) (1+ pos))))
      (when (and (= 0 v) (< 0 u))
        (let* ((bsize (bsize chunk))
               (loc (location chunk))
               (hit (make-hit (aref +surface-blocks+ u)
                              (nv+ (nv- (nv* (tvec (+ 0.5 x) (+ 0.5 y)) +tile-size+) bsize) loc))))
          (unless (funcall on-hit hit)
            hit))))))

(defmethod scan ((chunk chunk) (target vec4) on-hit)
  (let* ((tilemap (pixel-data chunk))
         (t-s +tile-size+)
         (w (truncate (vx (size chunk))))
         (h (truncate (vy (size chunk))))
         (x (+ (- (vx target) (vx (location chunk))) (vx (bsize chunk))))
         (y (+ (- (vy target) (vy (location chunk))) (vy (bsize chunk))))
         (x- (floor (- x (vz target)) t-s))
         (x+ (ceiling (+ x (vz target)) t-s))
         (y- (floor (- y (vw target)) t-s))
         (y+ (ceiling (+ y (vw target)) t-s)))
    (loop for x from (max 0 x-) below (min w x+)
          do (loop for y from (max 0 y-) below (min h y+)
                   for idx = (* (+ x (* y w)) 2)
                   for tile = (aref tilemap (+ 0 idx))
                   do (when (< 0 tile 17)
                        (let* ((loc (vec2 (+ (* x t-s) (/ t-s 2) (- (vx (location chunk)) (vx (bsize chunk))))
                                          (+ (* y t-s) (/ t-s 2) (- (vy (location chunk)) (vy (bsize chunk))))))
                               (hit (make-hit (aref +surface-blocks+ tile) loc)))
                          (unless (funcall on-hit hit)
                            (return-from scan hit))))))))

(defmethod closest-acceptable-location ((entity chunk) location)
  (loop for i from 0
        for closest = NIL
        do (bvh:do-fitting (other (bvh (region +world+)) (vec4 (- (vx location) (vx (bsize entity)))
                                                               (- (vy location) (vy (bsize entity)))
                                                               (+ (vx location) (vx (bsize entity)))
                                                               (+ (vy location) (vy (bsize entity)))))
             (when (and (typep other 'chunk)
                        (not (eq other entity))
                        (contained-p (vec4 (vx location) (vy location) (vx (bsize entity)) (vy (bsize entity))) other))
               (setf closest other)))
           (when closest
             (setf location (closest-external-border (location closest) (bsize closest) location (bsize entity))))
           (when (= i 10)
             (return (location entity)))
        while closest
        finally (return location)))

(defun clear-chunk-cache (&key dry-run)
  (dolist (path (directory (merge-pathnames (make-pathname :name :wild :type "graph")
                                            (pathname-utils:subdirectory (data-root) "world" "region" "data"))))
    (v:info :kandria.chunk "Deleting ~a" path)
    (unless dry-run
      (delete-file path))))

(defun delete-unlinked-chunk-data (&key dry-run)
  (let ((chunks (make-hash-table :test 'equal)))
    (handler-bind ((error #'continue))
      (for:for ((entity over (load-region (pathname-utils:subdirectory (data-root) "world" "region") NIL)))
        (when (and (typep entity 'layer)
                   (not (eql 'layer (type-of entity)))
                   (not (eql 'bg-layer (type-of entity))))
          (setf (gethash (format NIL "~a" (name entity)) chunks) T)
          (dotimes (i +layer-count+)
            (setf (gethash (format NIL "~a-~d" (name entity) i) chunks) T)))))
    (dolist (path (directory (merge-pathnames (make-pathname :name :wild :type "raw")
                                              (pathname-utils:subdirectory (data-root) "world" "region" "data"))))
      (unless (gethash (pathname-name path) chunks)
        (v:info :kandria.chunk "Deleting ~a" path)
        (unless dry-run
          (delete-file path))))))

(defun find-illegal-chunks (&key)
  (let ((chunks (make-hash-table :test 'equal)))
    (handler-bind ((error #'continue))
      (for:for ((entity over (load-region (pathname-utils:subdirectory (data-root) "world" "region") NIL)))
        (when (typep entity 'chunk)
          (push entity (gethash (list (vx (location entity)) (vy (location entity))) chunks)))))
    (loop for key being the hash-keys of chunks
          for val being the hash-values of chunks
          do (when (rest val)
               (format T "Duplicate: ~{~a~^, ~}~%" (mapcar #'name val))))))

(define-shader-entity stuffer (layer creatable)
  ((name :initform (generate-name "STUFFER"))))

(defmethod closest-acceptable-location ((stuffer stuffer) loc) loc)

(defmethod layer-index ((stuffer stuffer)) (1+ +base-layer+))

(defmethod clone ((stuffer stuffer) &rest initargs)
  (apply #'make-instance (class-of stuffer)
         (append initargs
                 (list
                  :size (clone (size stuffer))
                  :tile-data (tile-data stuffer)
                  :pixel-data (clone (pixel-data stuffer))))))
