(in-package #:org.shirakumo.fraf.leaf)

(defstruct (block (:constructor make-block (l r)))
  (l 0 :type (unsigned-byte 16))
  (r 0 :type (unsigned-byte 16)))

(defun make-surface-blocks (t-s steps)
  (let ((blocks (make-array (+ 2 (* 2 (reduce #'+ steps)))))
        (i -1))
    (flet ((make (l r)
             (setf (aref blocks (incf i)) (make-block l r))))
      (make t-s t-s)
      (make 0 0)
      (loop for steps in '(1 2 3)
            do (loop for i from 0 below steps
                     for l = (* (/ i steps) *default-tile-size*)
                     for r = (* (/ (1+ i) steps) *default-tile-size*)
                     do (make (floor l) (floor r)))
            do (loop for i downfrom steps above 0
                     for l = (* (/ i steps) *default-tile-size*)
                     for r = (* (/ (1- i) steps) *default-tile-size*)
                     do (make (floor l) (floor r))))
      blocks)))

(defvar *default-surface-blocks* (make-surface-blocks *default-tile-size* '(1 2 3)))

(define-shader-entity surface (layer)
  ((blocks :initarg :blocks :accessor blocks))
  (:default-initargs
   :texture (asset 'leaf 'surface)
   :name :surface
   :blocks *default-surface-blocks*))

(defmethod scan ((surface surface) start dir)
  (let* ((t-s (tile-size surface))
         (steps (ceiling (vlength dir) t-s)))
    (dotimes (i steps)
      (let* ((loc (nv+ (v* dir (/ i steps)) start))
             (tile (tile loc surface)))
        (when (and tile (/= tile 0))
          (return (cons (vsetf loc (floor (vx loc) t-s) (floor (vy loc) t-s))
                        (aref (blocks surface) tile))))))))
