(in-package #:org.shirakumo.fraf.kandria)

(defun %flood-fill (layer width height x y fill)
  (let* ((tmp (vec2 0 0)))
    (labels ((pos (x y)
               (* (+ x (* y width)) 2))
             (tile (x y)
               (vsetf tmp
                      (aref layer (+ 0 (pos x y)))
                      (aref layer (+ 1 (pos x y)))))
             ((setf tile) (f x y)
               (setf (aref layer (+ 0 (pos x y))) (first f)
                     (aref layer (+ 1 (pos x y))) (second f))))
      (let ((q ()) (find (vec2 (aref layer (+ 0 (pos x y)))
                               (aref layer (+ 1 (pos x y))))))
        (unless (v= (vec (first fill) (second fill)) find)
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
                              (pushnew (cons i (1+ y)) q))
                            (when (and (< 0 y) (v= (tile i (1- y)) find))
                              (pushnew (cons i (1- y)) q)))))))))

(defun find-edge (solids width height x y)
  (labels ((pos (x y)
             (* (+ x (* y width)) 2)))
    (loop with state = :up
          while (= 255 (aref solids (+ 0 (pos x y))))
          do (ecase state
               (:up
                (incf y)
                (when (<= height y)
                  (decf y)
                  (setf state :right)))
               (:right
                (incf x)
                (when (<= width x)
                  (decf x)
                  (setf state :down)))
               (:down
                (decf y)
                (when (< y 0)
                  (incf y)
                  (setf state :left)))
               (:left
                (decf x)
                (when (< x 0)
                  (incf x)
                  (error "There is no edge.")))))
    (values x y)))

(defparameter *tile-filters*
  '((:t
     _ o _
     s s s
     x x x)
    (:b
     x x _
     s s s
     _ o _)
    (:l
     _ s x
     o s i
     _ s x)
    (:r
     x s _
     i s o
     x s _)
    (:tr>
     _ _ o
     s s _
     x s _)
    (:tl>
     o _ _
     _ s s
     _ s x)
    (:br>
     x s _
     s s _
     _ _ o)
    (:bl>
     _ s x
     _ s s
     o _ _)
    (:tr<
     x x x
     s s x
     o s x)
    (:tl<
     x x x
     x s s
     x s o)
    (:br<
     o s x
     s s x
     x x x)
    (:bl<
     x s o
     x s s
     x x x)
    (:ct
     o s o
     s s s
     x i x)
    (:ct
     o s o
     s s s
     _ i _)
    (:cb
     _ i _
     s s s
     o s o)
    (:h
     _ o _
     s s s
     _ o _)
    (:v
     _ s _
     o s o
     _ s _)
    (:hl
     _ o _
     o s s
     _ o _)
    (:hr
     _ o _
     s s o
     _ o _)
    (:vt
     _ o _
     o s o
     _ s _)
    (:vb
     _ s _
     o s o
     _ o _)))

(declaim (inline tile-type-p))
(defun tile-type-p (tile type)
  (ecase type
    ;; Tiles that are "outside"
    (o (or (= 0 tile) (= 3 tile)))
    ;; Tiles that are edges
    (s (or (= 1 tile) (= 2 tile) (<= 4 tile 254)))
    ;; Tiles that are edges or inside
    (x (< 0 tile))
    ;; Tiles that are empty but inside
    (i (= 255 tile))
    ;; Tiles that are platforms
    (p (= 2 tile))
    ;; Tiles that are only blocks
    (b (= 1 tile))
    ;; Tiles that are slopes
    (/ (<= 4 tile 16))
    ;; Any tile at all (don't care)
    (_ T)))

(defun filter-edge (solids width height x y)
  (labels ((pos (x y)
             (* (+ x (* y width)) 2))
           (tile (ox oy)
             (let* ((x (+ ox x))
                    (y (+ oy y))
                    (pos (pos x y)))
               (cond ((or (= -1 x) (= -1 y) (= width x) (= height y)) 1)
                     ((or (< x -1) (< y -1) (< width x) (< height y)) 0)
                     (T (aref solids pos))))))
    (loop for (type . filter) in *tile-filters*
          do (when (loop for i from 0 below 9
                         for v in filter
                         for x = (- (mod i 3) 1)
                         for y = (- 1 (floor i 3))
                         for tile = (tile x y)
                         always (tile-type-p tile v) )
               #+(OR)
               (warn "~a at ~3d,~3d:~%~3d ~3d ~3d~%~3d ~3d ~3d~%~3d ~3d ~3d" type x y
                     (tile -1 +1) (tile 0 +1) (tile +1 +1)
                     (tile -1 0) (tile 0 0) (tile +1 0)
                     (tile -1 -1) (tile 0 -1) (tile +1 -1))
               (return type))
          finally (error "Unknown tile configuration at ~3d,~3d:~%~3d ~3d ~3d~%~3d ~3d ~3d~%~3d ~3d ~3d" x y
                         (tile -1 +1) (tile 0 +1) (tile +1 +1)
                         (tile -1 0) (tile 0 0) (tile +1 0)
                         (tile -1 -1) (tile 0 -1) (tile +1 -1)))))

(defun fill-edge (solids tiles width height ox oy map)
  (labels ((pos (x y)
             (* (+ x (* y width)) 2))
           (solid (x y)
             (when (and (<= 0 x (1- width))
                        (<= 0 y (1- height)))
               (aref solids (pos x y))))
           ((setf tile) (f x y)
             (set-tile tiles width height x y (alexandria:random-elt f))))
    (loop with x = ox with y = oy with px = x with py = y
          for i from 0 below 1000
          for edge = (filter-edge solids width height x y)
          for solid = (solid x y)
          for tile = (case solid
                       (2 :platform)
                       (3 :spike)
                       (T (if (and (numberp solid) (<= 4 solid 15))
                              `(:slope ,(- solid 4))
                              edge)))
          do (unless (<= 4 (or (solid x (1+ y)) 0) 15)
               (setf (tile x y) (cdr (assoc tile map :test 'equal))))
             (when (listp tile)
               (setf (tile x (1- y))
                     (loop for (x y) in (cdr (assoc tile map :test 'equal))
                           collect (list x (1- y)))))
             (let ((ox x) (oy y))
               (ecase edge
                 (:l (incf y))
                 (:r (decf y))
                 (:t (incf x))
                 (:b (decf x))
                 (:tl> (incf x))
                 (:tr> (decf y))
                 (:br> (decf x))
                 (:bl> (incf y))
                 (:tl< (decf y))
                 (:tr< (decf x))
                 (:br< (incf y))
                 (:bl< (incf x))
                 (:ct (if (= px x)
                          (incf x)
                          (incf y)))
                 (:cb (if (= px x)
                          (decf x)
                          (decf y)))
                 (:cl (if (= py y)
                          (incf y)
                          (decf x)))
                 (:cr (if (= py y)
                          (decf y)
                          (incf x)))
                 (:h (if (< px x)
                         (incf x)
                         (decf x)))
                 (:v (if (< py y)
                         (incf y)
                         (decf y)))
                 (:hl (incf x))
                 (:hr (decf x))
                 (:vt (decf y))
                 (:vb (incf y)))
               (setf px ox py oy))
             (when (and (= x ox) (= y oy))
               (loop-finish))
          collect (vec x y))))

(defun fill-innards (solids tiles edge width height x- x+ y- y+ map)
  (labels ((pos (x y)
             (* (+ x (* y width)) 2))
           (tile (x y)
             (aref solids (+ 0 (pos x y))))
           ((setf tile) (f x y)
             (set-tile tiles width height x y (alexandria:random-elt f))))
    (loop with edge = (loop for pos in edge
                            when (and (< -1 (vx pos) width)
                                      (< -1 (vy pos) height))
                            collect pos)
          for y from (max 0 y-) to (min y+ (1- height))
          do (loop for x from (max 0 x-) to (min x+ (1- width))
                   do (when (and (= 255 (tile x y))
                                 (or (<= (1- height) y)
                                     (not (<= 4 (tile x (1+ y)) 15))))
                        (setf (tile x y)
                              (cdr (or (assoc (round (mindist (vec x y) edge)) map)
                                       (assoc T map)))))))))

(defun %auto-tile (solids tiles width height x y map)
  (let ((solids (copy-seq solids)))
    (%flood-fill solids width height x y (list 255 0))
    (multiple-value-bind (x y) (find-edge solids width height x y)
      (let* ((edge (fill-edge solids tiles width height x y map))
             (x- (truncate (loop for pos in edge minimize (vx pos))))
             (x+ (truncate (loop for pos in edge maximize (vx pos))))
             (y- (truncate (loop for pos in edge minimize (vy pos))))
             (y+ (truncate (loop for pos in edge maximize (vy pos)))))
        (fill-innards solids tiles edge width height x- x+ y- y+ map)))))
