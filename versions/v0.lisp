(in-package #:org.shirakumo.fraf.kandria)

(defclass v0 (version) ())

(define-decoder (vec2 v0) (data _p)
  (destructuring-bind (x y) data
    (vec2 x y)))

(define-encoder (vec2 v0) (_b _p)
  (list (vx vec2)
        (vy vec2)))

(define-decoder (vec3 v0) (data _p)
  (destructuring-bind (x y z) data
    (vec3 x y z)))

(define-encoder (vec3 v0) (_b _p)
  (list (vx vec3)
        (vy vec3)
        (vz vec3)))

(define-decoder (vec4 v0) (data _p)
  (destructuring-bind (x y z w) data
    (vec4 x y z w)))

(define-encoder (vec4 v0) (_b _p)
  (list (vx vec4)
        (vy vec4)
        (vz vec4)
        (vw vec4)))

(define-decoder (colored:rgb v0) (data _p)
  (destructuring-bind (x y z &optional (a 1.0)) data
    (colored:color x y z a)))

(define-encoder (colored:rgb v0) (_b _p)
  (list (colored:r colored:rgb)
        (colored:g colored:rgb)
        (colored:b colored:rgb)))

(define-decoder (asset v0) (data _p)
  (destructuring-bind (pool name) data
    (asset pool name)))

(define-encoder (asset v0) (_b _p)
  (list (name (pool asset))
        (name asset)))

(define-decoder (resource v0) (data _p)
  (destructuring-bind (pool name &optional (id T)) data
    (// pool name id)))

(define-encoder (resource v0) (_b _p)
  (list (name (pool (generator resource)))
        (name (generator resource))
        (name resource)))

(defmethod decode-payload (_b (bindings (eql 'bindings)) _p (v0 v0))
  (loop for binding in _b
        for (var type val) = (enlist binding T)
        collect (cons var
                      (if (eql type T)
                          val
                          (decode-payload val (type-prototype type) _p v0)))))

(defmethod encode-payload ((bindings (eql 'bindings)) _b _p (v0 v0))
  (loop for (var . val) in _b
        collect (list* var
                       (etypecase val
                         ((or string symbol number) (list t val))
                         (standard-object
                          (list (type-of val) (encode-payload val _b _p v0)))))))
