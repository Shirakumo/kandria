(in-package #:org.shirakumo.fraf.kandria)

(define-shader-entity paletted-entity ()
  ((palette :initarg :palette :initform (// 'kandria 'placeholder) :accessor palette
            :type resource :documentation "The texture to use for palette lookups")
   (palette-index :initarg :palette-index :initform 0 :accessor palette-index
                  :type integer :documentation "Which palette to use")))

;; FIXME: auto-fill palette...
#++
(defmethod observe-generation :after ((sprite paletted-entity) (data sprite-data) result)
  (when (palette sprite)
    ()))

(defmethod stage :after ((entity paletted-entity) (area staging-area))
  (stage (palette entity) area))

(defmethod render :before ((entity paletted-entity) (program shader-program))
  (gl:active-texture :texture4)
  (gl:bind-texture :texture-2D (gl-name (palette entity)))
  (setf (uniform program "palette") 4)
  (setf (uniform program "palette_index") (palette-index entity)))

(define-class-shader (paletted-entity :fragment-shader -1)
  "uniform sampler2D palette;
uniform int palette_index = 0;

void main(){
  maybe_call_next_method();
  if(color.r*color.b == 1 && color.g < 0.1){
    color = texelFetch(palette, ivec2(color.g*255, palette_index), 0);
  }
}")

(defun convert-palette (file palette)
  (let* ((palette (pngload:data (pngload:load-file palette)))
         (input (pngload:load-file file :flatten T))
         (data (pngload:data input))
         (y (1- (array-dimension palette 0))))
    (flet ((find-color (r g b)
             (loop for x from 0 below (array-dimension palette 1)
                   do (when (and (= r (aref palette y x 0))
                                 (= g (aref palette y x 1))
                                 (= b (aref palette y x 2)))
                        (return x)))))
      (loop for i from 0 below (length data) by 4
            for index = (when (< 0 (aref data (+ i 3)))
                          (find-color (aref data (+ i 0))
                                      (aref data (+ i 1))
                                      (aref data (+ i 2))))
            do (when index
                 (setf (aref data (+ i 0)) 255)
                 (setf (aref data (+ i 1)) index)
                 (setf (aref data (+ i 2)) 255))))
    (zpng:write-png (make-instance 'zpng:png :color-type :truecolor-alpha
                                             :width (pngload:width input)
                                             :height (pngload:height input)
                                             :image-data data)
                    file :if-exists :supersede)))
