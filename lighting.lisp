(in-package #:org.shirakumo.fraf.leaf)

(define-shader-pass lighting-pass (per-object-pass hdr-output-pass)
  ())

(define-shader-entity light (vertex-entity located-entity)
  ())

(defmethod register-object-for-pass ((pass lighting-pass) (entity shader-entity))
  (when (typep entity 'light)
    (call-next-method)))

(defmethod paint-with ((pass lighting-pass) (entity shader-entity))
  (when (typep entity 'light)
    (call-next-method)))

(defmethod paint :around ((entity shader-entity) (pass lighting-pass))
  (when (typep entity 'light)
    (call-next-method)))

(define-shader-pass rendering-pass (render-pass)
  ((lighting :port-type input :texspec (:target :texture-2D :internal-format :rgba16f))))

(defmethod register-object-for-pass ((pass rendering-pass) (light light)))
(defmethod paint-with ((pass rendering-pass) (light light)))

(define-class-shader (rendering-pass :fragment-shader -100)
  "uniform sampler2D lighting;
out vec4 color;
uniform float gamma = 2.2;
uniform float exposure = 0.8;

void main(){
  ivec2 pos = ivec2(gl_FragCoord.xy-vec2(0.5));
  vec4 light = texelFetch(lighting, pos, 0);
  color.rgb += light.rgb*light.a;

  vec3 mapped = vec3(1.0) - exp((-color.rgb) * exposure);
  mapped = pow(mapped, vec3(1.0 / gamma));
  color = vec4(mapped, color.a);
}")

(define-asset (leaf sphere) mesh
    (make-disc 100))

(define-asset (leaf radial-gradient) mesh
    (let ((inner (vec4 1 1 1 1))
          (outer (vec4 0 0 0 1)))
      (with-vertex-filling ((make-instance 'vertex-mesh :vertex-type 'colored-vertex) :pack T)
        (loop with step = (/ (* 2 PI) 32)
              for i1 = (- step) then i2
              for i2 from 0 to (* 2 PI) by step
              do (vertex :position (vec 0 0 0) :color inner)
                 (vertex :position (vec (* 100 (cos i1)) (* 100 (sin i1)) 0) :color outer)
                 (vertex :position (vec (* 100 (cos i2)) (* 100 (sin i2)) 0) :color outer)))))

(define-shader-entity basic-light (light colored-entity)
  ((color :initform (vec4 1 1 1 1))))

(define-shader-entity per-vertex-light (light vertex-colored-entity)
  ())

(define-shader-entity textured-light (light textured-entity)
  ())
