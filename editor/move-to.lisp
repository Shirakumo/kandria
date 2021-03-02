(in-package #:org.shirakumo.fraf.kandria)

(define-shader-entity node-graph-visualizer (vertex-colored-entity vertex-entity standalone-shader-entity deferrer)
  ())

(defmethod initialize-instance :after ((visualizer node-graph-visualizer) &key graph)
  (setf (vertex-array visualizer) (generate-resources 'mesh-loader (node-graph-mesh (or graph (make-node-graph #() 0 0))))))

(defmethod apply-transforms progn ((visualizer node-graph-visualizer)))

(defmethod (setf node-graph) ((chunk chunk) (visualizer node-graph-visualizer))
  (let* ((vao (vertex-array visualizer))
         (mesh (node-graph-mesh (node-graph chunk) :offset (location chunk)))
         (mesh (chunk-graph-mesh chunk :mesh mesh)))
    (trial:replace-vertex-data vao mesh :update T)))

(defmethod (setf node-graph) ((graph node-graph) (visualizer node-graph-visualizer))
  (let* ((vao (vertex-array visualizer))
         (mesh (node-graph-mesh graph)))
    (trial:replace-vertex-data vao mesh :update T)))

(defmethod (setf path) (path (visualizer node-graph-visualizer))
  (when path
    (let* ((vao (vertex-array visualizer))
           (mesh (path-mesh path)))
      (trial:replace-vertex-data vao mesh :update T))))

(defun path-mesh (path &key (mesh (make-instance 'vertex-mesh :vertex-type 'colored-vertex :face-length 2)))
  (with-vertex-filling (mesh)
    (loop for prev = (second (first path)) then next
          for node in path
          for next = (second node)
          do (vertex :position (vxy_ prev) :color (vec 1 0 0 1))
             (vertex :position (vxy_ next) :color (vec 1 0 0 1)))))

(defun node-graph-mesh (graph &key (mesh (make-instance 'vertex-mesh :vertex-type 'colored-vertex :face-length 2))
                                   (offset (vec 0 0)))
  (let ((w (node-graph-width graph))
        (h (node-graph-height graph)))
    (flet ((loc (x y)
             (vec (+ (vx offset) (* (- x (/ w 2) -0.5) +tile-size+))
                  (+ (vy offset) (* (- y (/ h 2) -0.5) +tile-size+)) 0)))
      (with-vertex-filling (mesh)
        (do-nodes (x y graph)
          (dolist (node (node graph x y))
            (let ((color (etypecase node
                           (climb-node (vec 0.6 0.3 0 1))
                           (crawl-node (vec 0 0 0 1))
                           (fall-node (vec 0 0 1 1))
                           (jump-node (vec 1 0 0 1))
                           (move-node (vec 0 1 0 1)))))
              (vertex :position (loc x y) :color color)
              (vertex :position (loc (mod (move-node-to node) w) (floor (move-node-to node) w)) :color (v* color 0.1)))))))))

(defun chunk-graph-mesh (chunk &key (mesh (make-instance 'vertex-mesh :vertex-type 'colored-vertex :face-length 2)))
  (let ((graph (chunk-graph (region +world+))))
    (flet ((loc (chunk node)
             (vxy_ (chunk-node-vec chunk node))))
      (with-vertex-filling (mesh)
        (dolist (node (svref graph (chunk-graph-id chunk)))
          (vertex :position (loc (chunk-node-from node) (chunk-node-from-node node)) :color (vec 1 1 0 1))
          (vertex :position (loc (chunk-node-to node) (chunk-node-to-node node)) :color (vec 1 1 0 1)))))))

(defmethod render :before ((viz node-graph-visualizer) (program shader-program))
  (apply-transforms viz))

(defclass move-to (tool)
  ((visualizer :initform (make-instance 'node-graph-visualizer) :accessor visualizer)
   (selected :initform NIL :accessor selected)))

(defmethod label ((tool move-to)) "Movement")

(defmethod (setf tool) :after ((tool move-to) (editor editor))
  (setf (node-graph (visualizer tool)) (entity tool))
  (unless (find (visualizer tool) (alloy:elements (alloy:popups (alloy:layout-tree (unit 'ui-pass T)))))
    (alloy:enter (visualizer tool) (alloy:popups (alloy:layout-tree (unit 'ui-pass T)))
                 :w (width *context*) :h (height *context*))))

(defmethod stage ((tool move-to) (area staging-area))
  (stage (visualizer tool) area))

(defmethod hide :after ((tool move-to))
  (alloy:leave (visualizer tool) (alloy:popups (alloy:layout-tree (unit 'ui-pass T)))))

(defmethod handle ((ev tick) (tool move-to))
  #++
  (when (selected tool)
    (handle ev (selected tool))))

(defmethod handle ((ev mouse-press) (tool move-to))
  (let ((pos (mouse-world-pos (pos ev))))
    (cond ((eql :right (button ev))
           (when (selected tool)
             (move-to pos (selected tool))))
          ((eql :left (button ev))
           (let ((selected (entity-at-point pos +world+)))
             (when (typep selected 'movable)
               (v:info :kandria.editor "Selected ~a" selected)
               (setf (selected tool) selected)
               (setf (path (visualizer tool)) (path selected))))))))
