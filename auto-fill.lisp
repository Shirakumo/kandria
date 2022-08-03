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

(defparameter *background-filters*
  '((:bg-tl>
     o o _
     o s s
     _ s s)
    (:bg-tr>
     _ o o
     s s o
     s s _)
    (:bg-bl>
     _ s s
     o s s
     o o _)
    (:bg-br>
     s s _
     s s o
     _ o o)
    (:bg-tl<
     o s _
     s s _
     _ _ s)
    (:bg-tr<
     _ _ s
     s s _
     o s _)
    (:bg-bl<
     _ s o
     _ s s
     s _ _)
    (:bg-br<
     s _ _
     _ s s
     _ s o)
    (:bg-i
     _ x _
     x s x
     _ x _)
    (:bg-t
     _ o _
     _ s _
     _ s _)
    (:bg-b
     _ s _
     _ s _
     _ o _)
    (:bg-l
     _ _ _
     o s s
     _ _ _)
    (:bg-r
     _ _ _
     s s o
     _ _ _)))

(defparameter *spike-filters*
  '(
    (:spike-tr>
     _ _ _
     st  o _
     si sr _)
    (:spike-tl>
     _ _ _
     _  o st
     _ sl si)
    (:spike-bl>
     _ sl si
     _  o sb
     _ _ _)
    (:spike-br>
     si sr _
     sb  o _
     _ _ _)
    (:spike-bl<
     _ sr _
     _ sp st
     x _ _)
    (:spike-br<
     _  sl _
     st sp _
     _ _ x)
    (:spike-tr<
     _ _ x
     sb sp _
     _  sl _)
    (:spike-tl<
     x _ _
     _ sp sb
     _ sr _)
    (:spike-br<
     _ _  st
     _ st sp
     _ _ x)
    (:spike-bl<
     st _  _
     sp st _
     x _ _)
    (:spike-tr<
     _ _  x
     _ sb sp
     _ _  sb)
    (:spike-tl<
     x _  _
     sp sb _
     sb _ _)
    (:spike-br<
     _ _ _
     _ sl _
     sl sp x)
    (:spike-bl<
     _ _ _
     _ sr _
     x sp sr)
    (:spike-tr<
     sl sp x
     _ sl _
     _ _ _)
    (:spike-tl<
     x sp sr
     _ sr _
     _ _ _)
    (:spike-t
     _ _ _
     _ st _
     _ _ _)
    (:spike-b
     _ _ _
     _ sb _
     _ _ _)
    (:spike-l
     _ _ _
     _ sl _
     _ _ _)
    (:spike-r
     _ _ _
     _ sr _
     _ _ _)
    (:spike
     _ _ _
     _ si _
     _ _ _)))

(defparameter *tile-filters*
  '((:platform-l
     _ _ _
     s* p _
     _ _ _)
    (:platform-r
     _ _ _
     _ p s*
     _ _ _)
    (:platform
     _ _ _
     _ p _
     _ _ _)
    (:tr>
     _ o o
     s s o
     x s _)
    (:tl>
     o o _
     o s s
     _ s x)
    (:br>
     x s _
     s s o
     _ o o)
    (:bl>
     _ s x
     o s s
     o o _)
    (:t
     _ o _
     s s s
     _ x _)
    (:b
     x x _
     s s s
     _ o _)
    (:l
     _ s x
     o s x
     _ s x)
    (:r
     x s _
     x s o
     x s _)
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
     _ i _)
    (:cb
     _ i _
     s s s
     o s o)
    (:cl
     o s _
     s s i
     o s _)
    (:cr
     _ s o
     i s s
     _ s o)
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
     _ o _)
    (:c
     _ o _
     o s o
     _ o _)))

(declaim (inline tile-type-p))
(defun tile-type-p (tile type)
  (ecase type
    ;; Tiles that are "outside"
    (o (or (= 0 tile) (= 2 tile) (= 3 tile) (<= 16 tile 20)))
    ;; Tiles that are edges
    (s (or (= 1 tile) (= 2 tile) (<= 4 tile 15) (= 21 tile)))
    ;; Tiles that are edges or inside
    (x (or (<= 1 tile 15) (= 21 tile) (= 255 tile) (= 22 tile)))
    ;; Tiles that are empty but inside
    (i (or (= 255 tile) (= 22 tile)))
    ;; Tiles that are platforms
    (p (= 2 tile))
    ;; Tiles that are solid but not platforms
    (s* (or (= 1 tile) (<= 4 tile 15) (= 21 tile)))
    ;; Tiles that are only blocks
    (b (or (= 1 tile) (= 21 tile)))
    ;; Tiles that are slopes
    (/ (<= 4 tile 15))
    ;; Tiles that you can bonk on
    (k (or (= 1 tile) (<= 17 tile 20) (= 21 tile)))
    ;; Tiles that can be climbed on
    (c (= 1 tile))
    ;; Spikes
    (sp (or (= 3 tile) (<= 17 tile 20)))
    (si (= 3 tile))
    (st (= 17 tile))
    (sr (= 18 tile))
    (sb (= 19 tile))
    (sl (= 20 tile))
    (se (<= 17 tile 20))
    ;; Zero
    (z (= 0 tile))
    (nz (< 0 tile))
    ;; Any tile at all (don't care)
    (_ T)))

(defun filter-edge (solids width height x y &optional (filters *tile-filters*))
  (labels ((pos (x y)
             (* (+ x (* y width)) 2))
           (tile (ox oy)
             (let* ((x (+ ox x))
                    (y (+ oy y))
                    (pos (pos x y)))
               (cond ((or (= -1 x) (= -1 y) (= width x) (= height y)) 1)
                     ((or (< x -1) (< y -1) (< width x) (< height y)) 0)
                     (T (aref solids pos))))))
    (loop for (type . filter) in filters
          do (when (loop for i from 0 below 9
                         for v in filter
                         for x = (- (mod i 3) 1)
                         for y = (- 1 (floor i 3))
                         for tile = (tile x y)
                         always (tile-type-p tile v))
               (return type)))))

(defun %auto-tile (solids tiles width height map &optional (sx 0) (sy 0) (sw width) (sh height))
  (flet ((tile (x y)
           (if (and (< -1 x width) (< -1 y height))
               (aref solids (* (+ x (* y width)) 2))
               0))
         ((setf tile) (kind x y &optional fallback)
           (let ((tilelist (cdr (or (assoc kind map :test 'equal)
                                    (assoc fallback map :test 'equal)))))
             (when tilelist
               (set-tile tiles width height x y (alexandria:random-elt tilelist))))))
    (macrolet ((do-tiles (&body body)
                 `(loop for y from sy below (+ sy sh)
                        do (loop for x from sx below (+ sx sw)
                                 do ,@body))))
      (do-tiles
          (let ((edge (filter-edge solids width height x y)))
            (when edge
              (setf (tile x y) edge))))
      (do-tiles
          (let ((edge (filter-edge solids width height x y *spike-filters*)))
            (when edge
              (setf (tile x y) edge))))
      (do-tiles
          (case (tile x y)
            ( 4 (setf (tile x y) `(:slope 0)))
            ( 5 (setf (tile x y) `(:slope 1)))
            ( 6 (setf (tile x y) `(:slope 2)))
            ( 7 (setf (tile x y) `(:slope 3)))
            ( 8 (setf (tile x y) `(:slope 4)))
            ( 9 (setf (tile x y) `(:slope 5)))
            (10 (setf (tile x y) `(:slope 6)))
            (11 (setf (tile x y) `(:slope 7)))
            (12 (setf (tile x y) `(:slope 8)))
            (13 (setf (tile x y) `(:slope 9)))
            (14 (setf (tile x y) `(:slope 10)))
            (15 (setf (tile x y) `(:slope 11)))
            (22
             (let ((mindist 100))
               (loop for dy from -5 to +5
                     do (loop for dx from -5 to +5
                              do (when (< 0 (tile (+ x dx) (+ y dy)) 22)
                                   (setf mindist (min mindist (sqrt (+ (* dx dx) (* dy dy))))))))
               (setf (tile x y T) (round mindist)))))
        (when (<= 4 (tile x y) 15)
          (set-tile tiles width height x (1+ y) '(0 0 1 1)))))))

(defun %auto-tile-bg (tiles etiles width height map &optional (sx 0) (sy 0) (sw width) (sh height))
  (labels ((tile (x y)
             (when (and (< -1 x width)
                        (< -1 y height))
               (+ (aref tiles (+ 0 (* (+ x (* y width)) 2)))
                  (aref tiles (+ 1 (* (+ x (* y width)) 2))))))
           ((setf tile) (kind x y &optional fallback)
             (let ((tilelist (cdr (or (assoc kind map :test 'equal)
                                      (assoc fallback map :test 'equal)))))
               (when tilelist
                 (set-tile tiles width height x y (alexandria:random-elt tilelist)))))
           (filter-edge (x y)
             (loop for (type . filter) in *background-filters*
                   do (when (loop for i from 0 below 9
                                  for v in filter
                                  for dx = (- (mod i 3) 1)
                                  for dy = (- 1 (floor i 3))
                                  for tile = (tile (+ x dx) (+ y dy))
                                  always (ecase v
                                           (s (and tile (< 0 tile)))
                                           (x (or (null tile) (< 0 tile)))
                                           (o (or (null tile) (= 0 tile)))
                                           (_ T)))
                        (return type)))))
    (macrolet ((do-tiles (&body body)
                 `(loop for y from sy below (+ sy sh)
                        do (loop for x from sx below (+ sx sw)
                                 do ,@body))))
      (do-tiles
          (let ((edge (filter-edge x y)))
            (when edge
              (setf (tile x y) edge)))))
    #++
    (let ((sdf (compute-sdf (tilemap-bitmap tiles width height (second (assoc :bg-i map :test 'equal))) width height)))
      (fill etiles 0)
      (tagbody repeat
         (dolist (stamp (alexandria:shuffle (cdr (assoc :bg-stamps map))))
           (destructuring-bind (tx ty tw th) stamp
             (let ((max (max tw th)))
               (dotimes (y height)
                 (dotimes (x width)
                   (let ((dist (aref sdf (+ x (* y width)))))
                     (when (<= (1- max) dist)
                       (print (list :placing stamp x y))
                       (set-tile etiles width height (max 0 (- x (truncate tw 2))) (max 0 (- y (truncate th 2))) stamp)
                       (update-sdf sdf width height (max 0 (- x (truncate tw 2))) (max 0 (- y (truncate th 2))) (1+ tw) (1+ th))
                       (go repeat))))))))))))

(defun tilemap-bitmap (tiles width height interior)
  (let ((data (make-array (* width height) :element-type 'single-float)))
    (destructuring-bind (x y) interior
      (loop for i from 0 below (* width height 2) by 2
            do (setf (aref data (truncate i 2))
                     (if (and (= x (aref tiles (+ i 0)))
                              (= y (aref tiles (+ i 1))))
                         1.0 0.0)))
      data)))

(defun update-sdf (data width height tx ty tw th)
  (dotimes (y height data)
    (dotimes (x width)
      (setf (aref data (+ x (* y width)))
            (min (aref data (+ x (* y width)))
                 (let ((dx (max (- tx x) (- x (1- (+ tx tw)))))
                       (dy (max (- ty y) (- y (1- (+ ty th))))))
                   (+ (sqrt (+ (expt (max 0.0 dx) 2) (expt (max 0.0 dy) 2)))
                      (min 0.0 (max dx dy)))))))))

(defun compute-sdf (data width height)
  (let ((outer (make-array (length data) :element-type 'single-float))
        (inner (make-array (length data) :element-type 'single-float))
        (f (make-array (max width height) :element-type 'single-float))
        (d (make-array (max width height) :element-type 'single-float))
        (z (make-array (1+ (max width height)) :element-type 'single-float))
        (v (make-array (max width height) :element-type '(signed-byte 32))))
    (dotimes (i (length data))
      (let ((a (aref data i)))
        (setf (aref outer i) (cond ((= a 1) 0.0)
                                   ((= a 0) most-positive-single-float)
                                   (T (expt (max 0 (- 0.5 a)) 2))))
        (setf (aref inner i) (cond ((= a 1) most-positive-single-float)
                                   ((= a 0) 0.0)
                                   (T (expt (max 0 (- a 0.5)) 2))))))
    (labels ((edt1d (n)
               (setf (aref v 0) 0)
               (setf (aref z 0) most-negative-single-float)
               (setf (aref z 1) most-positive-single-float)
               (loop with k = 0
                     for q from 1 below n
                     for s = (/ (- (+ (aref f q) (* q q)) (+ (aref f (aref v k)) (* (aref v k) (aref v k))))
                                (- (* 2 q) (* 2 (aref v k))))
                     do (loop while (<= s (aref z k))
                              do (decf k)
                                 (setf s (/ (- (+ (aref f q) (* q q)) (+ (aref f (aref v k)) (* (aref v k) (aref v k))))
                                            (- (* 2 q) (* 2 (aref v k))))))
                        (incf k)
                        (setf (aref v k) q)
                        (setf (aref z k) s)
                        (setf (aref z (1+ k)) most-positive-single-float))
               (loop with k = 0
                     for q from 0 below n
                     do (loop while (< (aref z (1+ k)) q) do (incf k))
                        (setf (aref d q) (+ (* (- q (aref v k)) (- q (aref v k))) (aref f (aref v k))))))
             (edt (data)
               (dotimes (x width)
                 (dotimes (y height)
                   (setf (aref f y) (aref data (+ x (* y width)))))
                 (edt1d height)
                 (dotimes (y height)
                   (setf (aref data (+ x (* y width))) (aref d y))))
               (dotimes (y height)
                 (dotimes (x width)
                   (setf (aref f x) (aref data (+ x (* y width)))))
                 (edt1d width)
                 (dotimes (x width)
                   (setf (aref data (+ x (* y width))) (sqrt (aref d x)))))))
      (edt outer)
      (edt inner))
    (let ((dist (make-array (length data) :element-type 'single-float)))
      (dotimes (i (length data) dist)
        (setf (aref dist i) (- (aref inner i) (aref outer i)))))))
