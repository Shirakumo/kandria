(in-package #:org.shirakumo.fraf.kandria)

(define-shader-entity node-graph-visualizer (located-entity vertex-colored-entity vertex-entity standalone-shader-entity deferrer)
  ())

(defmethod initialize-instance :after ((visualizer node-graph-visualizer) &key graph)
  (setf (vertex-array visualizer) (generate-resources 'mesh-loader (node-graph-mesh (or graph (make-node-graph #() 0 0))))))

(defmethod (setf node-graph) ((graph node-graph) (visualizer node-graph-visualizer))
  (let* ((vao (vertex-array visualizer))
         (vbo (car (second (bindings vao))))
         (ebo (first (bindings vao)))
         (mesh (node-graph-mesh graph)))
    (trial:replace-vertex-data vao mesh :update T)))

(defmethod (setf path) (path (visualizer node-graph-visualizer))
  (when path
    (setf (location visualizer) (vec 0 0))
    (let* ((vao (vertex-array visualizer))
           (vbo (car (second (bindings vao))))
           (ebo (first (bindings vao)))
           (mesh (path-mesh path)))
      (trial:replace-vertex-data vao mesh :update T))))

(defun path-mesh (path)
  (with-vertex-filling ((make-instance 'vertex-mesh :vertex-type 'colored-vertex :face-length 2))
    (loop for prev = (second (first path)) then next
          for node in path
          for next = (second node)
          do (vertex :position (vxy_ prev) :color (vec 1 0 0 1))
             (vertex :position (vxy_ next) :color (vec 1 0 0 1)))))

(defun node-graph-mesh (graph)
  (let ((w (node-graph-width graph))
        (h (node-graph-height graph)))
    (flet ((loc (x y)
             (vec (* (- x (/ w 2) -0.5) +tile-size+) (* (- y (/ h 2) -0.5) +tile-size+) 0)))
      (with-vertex-filling ((make-instance 'vertex-mesh :vertex-type 'colored-vertex :face-length 2))
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

(defmethod render :before ((viz node-graph-visualizer) (program shader-program))
  (apply-transforms viz))

(defclass move-to (tool)
  ((visualizer :initform (make-instance 'node-graph-visualizer) :accessor visualizer)
   (selected :initform NIL :accessor selected)))

(defmethod label ((tool move-to)) "Movement")

(defmethod (setf tool) :after ((tool move-to) (editor editor))
  (setf (node-graph (visualizer tool)) (node-graph (entity tool)))
  (setf (location (visualizer tool)) (location (entity tool)))
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
