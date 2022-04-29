(in-package #:org.shirakumo.fraf.kandria)

(defclass binary-v0 (version) ())

(define-encoder (string binary-v0) (stream depot)
  (let ((bin (babel:string-to-octets string :encoding :utf-8)))
    (when (< (ash 1 16) (length bin))
      (error "String way too long to dump!"))
    (nibbles:write-ub16/le (length bin) stream)
    (write-sequence bin stream)))

(define-decoder (string binary-v0) (stream depot)
  (let ((bin (make-array (nibbles:read-ub16/le stream) :element-type '(unsigned-byte 8))))
    (read-sequence bin stream)
    (babel:octets-to-string bin :encoding :utf-8)))

(define-encoder (symbol binary-v0) (stream depot)
  (encode (package-name (symbol-package symbol)))
  (encode (symbol-name symbol)))

(define-decoder (symbol binary-v0) (stream depot)
  (let ((package (decode ""))
        (name (decode "")))
    (intern name package)))

(define-decoder (vec2 binary-v0) (stream _p)
  (vec2 (nibbles:read-ieee-single/le stream)
        (nibbles:read-ieee-single/le stream)))

(define-encoder (vec2 binary-v0) (stream _p)
  (nibbles:write-ieee-single/le (vx2 vec2) stream)
  (nibbles:write-ieee-single/le (vy2 vec2) stream))

(define-decoder (vec3 binary-v0) (stream _p)
  (vec3 (nibbles:read-ieee-single/le stream)
        (nibbles:read-ieee-single/le stream)
        (nibbles:read-ieee-single/le stream)))

(define-encoder (vec3 binary-v0) (stream _p)
  (nibbles:write-ieee-single/le (vx3 vec3) stream)
  (nibbles:write-ieee-single/le (vy3 vec3) stream)
  (nibbles:write-ieee-single/le (vz3 vec3) stream))

(define-decoder (vec4 binary-v0) (stream _p)
  (vec4 (nibbles:read-ieee-single/le stream)
        (nibbles:read-ieee-single/le stream)
        (nibbles:read-ieee-single/le stream)
        (nibbles:read-ieee-single/le stream)))

(define-encoder (vec4 binary-v0) (stream _p)
  (nibbles:write-ieee-single/le (vx4 vec4) stream)
  (nibbles:write-ieee-single/le (vy4 vec4) stream)
  (nibbles:write-ieee-single/le (vz4 vec4) stream)
  (nibbles:write-ieee-single/le (vw4 vec4) stream))

(define-decoder (asset binary-v0) (data _p)
  (asset (decode 'symbol)
         (decode 'symbol)))

(define-encoder (asset binary-v0) (_b _p)
  (encode (name (pool asset)))
  (encode (name asset)))

(define-decoder (resource binary-v0) (data _p)
  (// (decode 'symbol)
      (decode 'symbol)
      (decode 'symbol)))

(define-encoder (resource binary-v0) (_b _p)
  (encode (name (pool (generator resource))))
  (encode (name (generator resource)))
  (encode (name resource)))
