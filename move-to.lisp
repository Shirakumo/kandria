(in-package #:org.shirakumo.fraf.leaf)

(defclass move-edge (flow:connection) ())
(defclass walk-edge (move-edge) ())
(defclass crawl-edge (move-edge) ())
(defclass climb-edge (move-edg) ())
(defclass fall-edge (move-edge flow:directed-connection) ())
(defclass jump-edge (move-edge flow:directed-connection)
  ((strength :initarg :strength :accessor strength)))

(defgeneric capable-p (thing edge))

(defmethod capable-p (thing (edge move-edge)) NIL)
(defmethod capable-p (thing (edge walk-edge)) T)
(defmethod capable-p (thing (edge fall-edge)) T)

(defmethod flow:connection= ((a jump-edge) (b jump-edge))
  (and (call-next-method)
       (v= (strength a) (strength b))))

(flow:define-node platform-node ()
  ((options :port-type flow:n-port)
   (location :initarg :location :accessor location)))

(defmethod print-object ((node platform-node) stream)
  (print-unreadable-object (node stream :type T)
    (format stream "~a" (location node))))

(flow:define-node right-edge-node (platform-node) ())
(flow:define-node left-edge-node (platform-node) ())
(flow:define-node both-edge-node (right-edge-node left-edge-node) ())

(defun connect-platforms (a b type &rest initargs)
  (when (and a b)
    (apply #'flow:connect
           (flow:port a 'options)
           (flow:port b 'options)
           type initargs)))

(defmacro %do-grid ((x y w h) &body body)
  `(loop for ,y downfrom (1- ,h) above 0
         do (loop for ,x from 0 below ,w
                  do (progn ,@body))))

(defun create-platform-nodes (solids node-grid width height offset)
  (labels ((tile (x y)
             (aref solids (* (+ x (* y width)) 2)))
           ((setf node) (node x y)
             (setf (aref node-grid (+ x (* y width))) node)))
    (let ((prev-node NIL))
      (%do-grid (x y width height)
        ;; FIXME: clear prev-node on line wrap
        (cond ((and (< 0 (tile x (1- y)))
                    (not (< 0 (tile x y))))
               (let* ((loc (nv+ (nv* (vec2 x y) +tile-size+)
                                (/ +tile-size+ 2)
                                offset))
                      (new (if (or prev-node (= 0 x) (< 1 (tile (1- x) y)))
                               (make-instance 'platform-node :location loc)
                               (make-instance 'left-edge-node :location loc))))
                 (when prev-node
                   (connect-platforms prev-node new
                                      (if (or (< 0 (tile x (1+ y)))
                                              (< 0 (tile (1- x) (1+ y))))
                                          'crawl-edge
                                          'walk-edge)))
                 (setf (node x y) new)
                 (setf prev-node new)))
              ((< 0 (tile x y))
               (setf prev-node NIL))
              ((typep prev-node 'left-edge-node)
               (change-class prev-node 'both-edge-node)
               (setf prev-node NIL))
              ((typep prev-node 'platform-node)
               (change-class prev-node 'right-edge-node)
               (setf prev-node NIL)))))))

(defun create-climb-connections (solids node-grid width height))

(defun create-fall-connections (solids node-grid width height)
  (flet ((node (x y)
           (aref node-grid (+ x (* y width))))
         (tile (x y)
           (aref solids (* (+ x (* y width)) 2))))
    (%do-grid (x y width height)
      ;; FIXME: Slopes at edges
      (let ((node (node x y)))
        (when (or (< 0 (tile x (1- y)) 3))
          (when (and (typep node 'left-edge-node)
                     (= 0 (tile (1- x) y)))
            (loop for yy downfrom y to 0
                  for nnode = (node (1- x) yy)
                  do (when nnode
                       (connect-platforms node nnode 'fall-edge)
                       (return))))
          (when (and (typep node 'right-edge-node)
                     (= 0 (tile (1+ x) y)))
            (loop for yy downfrom y to 0
                  for nnode = (node (1+ x) yy)
                  do (when nnode
                       (connect-platforms node nnode 'fall-edge)
                       (return)))))))))

(defun create-slope-connections (solids node-grid width height)
  (flet ((node (x y)
           (aref node-grid (+ x (* y width))))
         (tile (x y)
           (aref solids (* (+ x (* y width)) 2))))
    (%do-grid (x y width height)
      (case (tile x y)
        ((4 6 10) (connect-platforms (node x (1+ y)) (node (1- x) y) 'walk-edge))
        ((5 9 15) (connect-platforms (node x (1+ y)) (node (1+ x) y) 'walk-edge))))))

(defun reachable-p (nnode node)
  (let ((hash (make-hash-table :test 'eq)))
    (labels ((traverse (node)
               (when (eq node nnode)
                 (return-from reachable-p T))
               (unless (gethash node hash)
                 (setf (gethash node hash) T)
                 (loop for out in (slot-value node 'options)
                       for other = (flow:target-node node out)
                       do (when (and other (not (typep out 'jump-edge)))
                            (traverse other))))))
      (traverse node))))

(defun compute-jump-configurations (&key (vmax (vec 1.9 3.9)))
  (loop for xfrac from -1 to 1 by 0.1d0
        nconc (loop for yfrac from 0.1 to 1 by 0.1d0
                    collect (vec (* xfrac (vx vmax)) (* yfrac (vy vmax))))))

(defun create-jump-connections-at (node ox oy solids node-grid width height)
  (let ((g (v/ +vgrav+ +tile-size+))
        (size (vec width height)))
    (loop for vel in (compute-jump-configurations)
          for prev = 0
          do (loop for tt from 0 by 0.01
                   for pos = (vec ox oy) then (v+ pos acc)
                   for idx = (+ (round (vx pos)) (* width (floor (vy pos))))
                   for acc = (v/ vel +tile-size+) then (v+ acc g)
                   do (when (or (not (v< 0 pos size))
                                (< 0 (aref solids (* 2 idx))))
                        (return))
                      (when (/= prev idx)
                        (setf prev idx)
                        (let ((nnode (aref node-grid idx)))
                          (when (and nnode (not (eq node nnode)) (not (reachable-p nnode node)))
                            (handler-case (connect-platforms node nnode 'jump-edge :strength vel)
                              (flow:connection-already-exists ())))))))))

(defun create-jump-connections (solids node-grid width height)
  (%do-grid (x y width height)
    (let ((node (aref node-grid (+ x (* y width)))))
      (when (typep node 'platform-node)
        (create-jump-connections-at node x y solids node-grid width height)))))

(defun compute-node-grid (solids width height offset)
  (let ((node-grid (make-array (/ (length solids) 2) :initial-element NIL)))
    (create-platform-nodes solids node-grid width height offset)
    (create-fall-connections solids node-grid width height)
    (create-slope-connections solids node-grid width height)
    (create-jump-connections solids node-grid width height)
    node-grid))

;; FIXME: incremental recomputation to account for dynamic changes in level

(defun node-graph-mesh (node-grid width height)
  (with-vertex-filling ((make-instance 'vertex-mesh :vertex-type 'colored-vertex :face-length 2))
    (%do-grid (x y width height)
      (let ((node (aref node-grid (+ x (* y width)))))
        (when node
          (loop for out in (slot-value node 'options)
                for target = (flow:target-node node out)
                for color = (etypecase out
                              (walk-edge (vec 0 1 0 1))
                              (crawl-edge (vec 0.6 0.3 0 1))
                              (jump-edge (vec 1 0 0 1))
                              (fall-edge (vec 0 0 1 1)))
                when target
                do (vertex :position (vxy_ (location node)) :color color)
                   (vertex :position (vxy_ (location target)) :color (v* color 0.1))))))))

(define-shader-entity node-graph (vertex-entity)
  ((node-grid :initarg :node-grid :accessor node-grid)
   (size :initarg :size :accessor size)
   (offset :initarg :offset :accessor offset))
  (:default-initargs
   :offset (vec 0 0)))

(defmethod shared-initialize :after ((graph node-graph) slots &key solids)
  (declare (ignore slots))
  (let ((w (truncate (vx (size graph))))
        (h (truncate (vy (size graph)))))
    (when solids
      (setf (node-grid graph) (compute-node-grid solids w h (offset graph))))))

(defmethod (setf node-grid) :after (node-grid (graph node-graph))
  (let ((w (truncate (vx (size graph))))
        (h (truncate (vy (size graph)))))
    (let ((mesh (node-graph-mesh node-grid w h)))
      (if (slot-boundp graph 'vertex-array)
          (let ((vbo (car (second (bindings (vertex-array graph)))))
                (ebo (first (bindings (vertex-array graph)))))
            (trial::replace-vertex-data (buffer-data vbo) mesh)
            (setf (buffer-data ebo) (faces mesh))
            (trial:resize-buffer vbo (* (length (buffer-data vbo)) (gl-type-size :float))
                                 :data (buffer-data vbo))
            (trial:resize-buffer ebo (* (length (buffer-data ebo)) (gl-type-size :float))
                                 :data (buffer-data ebo))
            (setf (size (vertex-array graph)) (length (faces mesh))))
          (setf (vertex-array graph) (generate-resources 'mesh-loader mesh))))))

(defmethod shortest-path ((graph node-graph) (start vec2) (goal vec2) &key (test (constantly T)))
  (let ((node-grid (node-grid graph))
        (width (floor (vx (size graph)))))
    (labels ((node-at (pos x)
               (loop for y = (round (vy pos)) then (1- y)
                     for idx = (+ x (* y width))
                     while (<= 0 idx (1- (length node-grid)))
                     do (let ((node (aref node-grid idx)))
                          (when node (return node)))))
             (node (pos)
               (loop for off in '(0 1 -2 3 -4)
                     for x = (round (vx pos)) then (+ x off)
                     do (let ((node (node-at pos x)))
                          (when node (return node)))
                     finally (error "Position outside possible node grid!")))
             (cost (a b)
               (vsqrdist2 (location a) (location b))))
      (values (flow:a* (node start) (node goal) #'cost :test test)
              (node start)))))

(define-class-shader (node-graph :vertex-shader)
  "layout (location = 1) in vec4 in_vertexcolor;
out vec4 vertexcolor;

void main(){
  vertexcolor = in_vertexcolor;
}")

(define-class-shader (node-graph :fragment-shader)
  "in vec4 vertexcolor;
out vec4 color;

void main(){
  color = vertexcolor;
}")

(defclass movable (moving)
  ((current-node :initform NIL :accessor current-node)
   (path :initform NIL :accessor path)))

(defgeneric movement-speed (movable))

(defmethod path-available-p ((target vec2) (movable movable))
  (ignore-errors (shortest-path (find-containing target (region +world+)) movable target)))

(defmethod path-available-p ((target located-entity) (movable movable))
  (path-available-p (location target) movable))

(defmethod move-to ((target vec2) (movable movable))
  (multiple-value-bind (path start) (shortest-path (find-containing target (region +world+)) movable target)
    ;; (v:info :trial.move-to "Moving ~a along~{~%  ~a~}" movable path)
    (setf (current-node movable) start)
    (setf (path movable) path)))

(defmethod move-to ((target located-entity) (movable movable))
  (move-to (location target) movable))

(defun moved-beyond-target-p (loc source target)
  ;; FIXME: do this in 2D with ray projection
  (let ((dir (signum (- (vx target) (vx source))))
        (diff (- (vx target) (vx loc))))
    (/= dir (signum diff))))

(defmethod handle :before ((ev tick) (movable movable))
  (when (path movable)
    (let* ((collisions (collisions movable))
           (dt (* 100 (dt ev)))
           (loc (location movable))
           (vel (velocity movable))
           (con (car (path movable)))
           (node (current-node movable))
           (target (flow:target-node node con)))
      (flet ((move-towards (source target)
               (when (and (eql :crawling (state movable))
                          (null (svref collisions 0)))
                 (setf (state movable) :normal))
               (let ((dir (signum (- (vx target) (vx source))))
                     (diff (abs (- (vx target) (vx loc)))))
                 (setf (vx vel) (* dir (max 1 (min diff (movement-speed movable))))))))
        ;; Handle current step
        (typecase con
          (null
           (vsetf vel 0 0))
          (walk-edge
           (move-towards (location node) (location target)))
          (fall-edge
           (if (svref collisions 2)
               (move-towards (location node)
                             (location target))
               (setf (vx vel) 0)))
          (jump-edge
           (if (svref collisions 2)
               (let ((node-dist (vsqrdist2 loc (location node)))
                     (targ-dist (vsqrdist2 loc (location target))))
                 (cond ((<= node-dist (expt 8 2))
                        (vsetf vel
                               (vx (strength con))
                               (vy (strength con))))
                       ((< node-dist targ-dist)
                        (move-towards (location movable) (location node)))
                       (T
                        (move-towards (location node) (location target)))))
               (setf (vx vel) (vx (strength con)))))
          (crawl-edge
           (setf (state movable) :crawling)
           (move-towards (location node) (location target))))
        ;; Check whether to move on to the next step
        (when (moved-beyond-target-p loc (location node) (location target))
          (pop (path movable))
          (setf (current-node movable) target)
          (setf con (car (path movable)))
          (when con
            (shiftf node target (flow:target-node node con)))))
      (when (svref collisions 2)
        (vsetf vel 0 (max 0 (vy vel))))
      (nv+ vel (v* +vgrav+ dt)))))
