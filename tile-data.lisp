(in-package #:org.shirakumo.fraf.kandria)

(defclass tile-data (multi-resource-asset file-input-asset)
  ((tile-types :initform () :accessor tile-types)))

(defmethod generate-resources ((data tile-data) (path pathname) &key)
  (with-kandria-io-syntax
      (with-open-file (stream path)
        (destructuring-bind (&key albedo absorption normal tile-types) (read stream)
          (setf (tile-types data) tile-types)
          (generate-resources 'image-loader (merge-pathnames albedo path)
                              :resource (resource data 'albedo))
          (generate-resources 'image-loader (merge-pathnames absorption path)
                              :resource (resource data 'absorption))
          (if normal
              (generate-resources 'image-loader (merge-pathnames normal path)
                                  :resource (resource data 'normal))
              (ensure-instance (resource data 'normal) 'texture
                               :width (width (resource data 'albedo))
                               :height (height (resource data 'albedo))
                               :internal-format :rg8
                               :pixel-format :rg
                               :pixel-data (make-array (* 2 (width (resource data 'albedo)) (height (resource data 'albedo)))
                                                       :element-type '(unsigned-byte 8) :initial-element 128)))
          (list (resource data 'albedo)
                (resource data 'absorption)
                (resource data 'normal))))))

(defmethod notify:files-to-watch append ((asset tile-data))
  (list (make-pathname :type "ase" :defaults (input* asset))))

(defmethod notify:notify ((asset tile-data) file)
  (when (string= "ase" (pathname-type file))
    (ql:quickload :kandria-data)))
