(in-package #:org.shirakumo.fraf.kandria)

(define-shader-entity node-graph-visualizer (marker)
  ((trial::line-width :initform 5.0)))

(defmethod apply-transforms progn ((visualizer node-graph-visualizer)))

(defmethod (setf node-graph) ((entity movable) (visualizer node-graph-visualizer))
  (replace-vertex-data visualizer (path-mesh (path entity))))

(defmethod (setf node-graph) ((chunk chunk) (visualizer node-graph-visualizer))
  (replace-vertex-data visualizer (chunk-graph-mesh chunk :mesh (node-graph-mesh (node-graph chunk) :offset (location chunk)))))

(defmethod (setf node-graph) ((graph node-graph) (visualizer node-graph-visualizer))
  (replace-vertex-data visualizer (node-graph-mesh graph)))

(defun node-type-color (node)
  (etypecase node
    (climb-node (vec 0.6 0.3 0 1))
    (rope-node (vec 0.3 0.6 0 1))
    (crawl-node (vec 0 0 0 1))
    (fall-node (vec 0 0 1 1))
    (jump-node (vec 1 0 0 1))
    (move-node (vec 0 1 0 1))
    (door-node (vec 1 1 0 1))
    (teleport-node (vec 0 1 1 1))))

(defun node-type-offset (node)
  (etypecase node
    (climb-node (vec 2 0 0))
    (rope-node (vec 0 0 0))
    (crawl-node (vec 0 0 0))
    (fall-node (vec 0 0 0))
    (jump-node (vec 0 2 0))
    (move-node (vec 0 0 0))
    (door-node (vec 0 0 0))
    (teleport-node (vec 0 0 0))))

(defun node-graph-mesh (graph &key (mesh ())
                                   (offset (vec 0 0)))
  (let ((w (node-graph-width graph))
        (h (node-graph-height graph)))
    (flet ((loc (x y)
             (vec (+ (vx offset) (* (- x (/ w 2) -0.5) +tile-size+))
                  (+ (vy offset) (* (- y (/ h 2) -0.5) +tile-size+)) 0)))
      (do-nodes (x y graph mesh)
        (dolist (node (%node graph x y))
          (let ((color (node-type-color node))
                (off (node-type-offset node)))
            (push (list (nv+ (loc x y) off) color) mesh)
            (push (list (nv+ (loc (mod (move-node-to node) w) (floor (move-node-to node) w)) off) (v* color 0.1)) mesh)))))))

(defun chunk-graph-mesh (chunk &key (mesh ()))
  (let ((graph (chunk-graph (region +world+))))
    (flet ((loc (chunk node)
             (vxy_ (chunk-node-vec chunk node))))
      (dolist (node (svref graph (chunk-graph-id chunk)) mesh)
        (push (list (loc (chunk-node-from node) (chunk-node-from-node node)) (vec 1 1 0 1)) mesh)
        (push (list (loc (chunk-node-to node) (chunk-node-to-node node)) (vec 1 1 0 1)) mesh)))))

(defun path-mesh (path &key (mesh ()))
  (loop for prev = (second (first path)) then next
        for node in path
        for next = (second node)
        for color = (node-type-color (first node))
        do (push (list (vxy_ prev) color) mesh)
           (push (list (vxy_ next) color) mesh))
  mesh)

(defmethod render :before ((viz node-graph-visualizer) (program shader-program))
  (apply-transforms viz))

(defclass move-to (tool)
  ((visualizer :initform (make-instance 'node-graph-visualizer) :accessor visualizer)
   (selected :initform NIL :accessor selected)))

(defmethod label ((tool move-to)) "")
(defmethod title ((tool move-to)) "Movement AI")

(defmethod (setf tool) :after ((tool move-to) (editor editor))
  (setf (node-graph (visualizer tool)) (entity tool))
  (unless (find (visualizer tool) (alloy:elements (alloy:popups (alloy:layout-tree (unit 'ui-pass T)))))
    (alloy:enter (visualizer tool) (alloy:popups (alloy:layout-tree (unit 'ui-pass T)))
                 :w (width *context*) :h (height *context*))))

(defmethod stage ((tool move-to) (area staging-area))
  (stage (visualizer tool) area))

(defmethod hide :after ((tool move-to))
  (when (slot-boundp (visualizer tool) 'alloy:layout-parent)
    (alloy:leave (visualizer tool) (alloy:popups (alloy:layout-tree (unit 'ui-pass T))))))

(defmethod handle ((ev mouse-press) (tool move-to))
  (let ((pos (mouse-world-pos (pos ev))))
    (cond ((eql :left (button ev))
           (when (typep (entity tool) 'movable)
             (move-to pos (entity tool))
             (setf (node-graph (visualizer tool)) (entity tool)))))))

(defmethod applicable-tools append ((movable movable))
  '(move-to))

(defclass movement-trace (tool)
  ((marker :initform (make-instance 'marker) :accessor marker)))

(defmethod label ((tool movement-trace)) "")
(defmethod title ((tool movement-trace)) "Movement Trace")

(defmethod (setf tool) :after ((tool movement-trace) (editor editor))
  (let ((trace (movement-trace (entity tool))))
    (replace-vertex-data (marker tool)
                         (loop for i from 3 below (length trace) by 2
                               for invalid = (or (float-features:float-nan-p (aref trace (- i 3)))
                                                 (float-features:float-nan-p (aref trace (- i 1))))
                               unless invalid collect (list (vec (aref trace (- i 3)) (aref trace (- i 2)) 0) (vec 1 0 0 0.1))
                               unless invalid collect (list (vec (aref trace (- i 1)) (aref trace (- i 0)) 0) (vec 1 0 0 0.1)))))
  (unless (find (marker tool) (alloy:elements (alloy:popups (alloy:layout-tree (unit 'ui-pass T)))))
    (alloy:enter (marker tool) (alloy:popups (alloy:layout-tree (unit 'ui-pass T)))
                 :w (width *context*) :h (height *context*))))

(defmethod stage ((tool movement-trace) (area staging-area))
  (stage (marker tool) area))

(defmethod hide :after ((tool movement-trace))
  (when (slot-boundp (marker tool) 'alloy:layout-parent)
    (alloy:leave (marker tool) (alloy:popups (alloy:layout-tree (unit 'ui-pass T))))))

(defmethod applicable-tools append ((player player))
  '(movement-trace))
