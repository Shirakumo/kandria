(in-package #:org.shirakumo.fraf.kandria)

(defclass tile-data (multi-resource-asset file-input-asset)
  ((tile-types :initform () :accessor tile-types)))

(defun parse-tile-types (types)
  (labels ((parse-tile-spec (spec)
             (case (first spec)
               (repeat
                (destructuring-bind ((start end) tile) (rest spec)
                  (loop for x from start to end
                        collect (subst x 'x tile))))
               (T (list spec))))
           (parse-type-spec (spec)
             (destructuring-bind (type . parts) spec
               (list* type (reduce #'append parts :key #'parse-tile-spec)))))
    (loop for (name . tiles) in types
          collect (list* name (mapcar #'parse-type-spec tiles)))))

(defmethod generate-resources ((data tile-data) (path pathname) &key)
  (with-kandria-io-syntax
    (with-open-file (stream path)
      (destructuring-bind (&key albedo absorption normal tile-types) (read stream)
        (setf (tile-types data) (parse-tile-types tile-types))
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

(defmethod resource ((data tile-data) (name (eql T)))
  (resource data 'albedo))

(defmethod notify:files-to-watch append ((asset tile-data))
  (list (make-pathname :type "ase" :defaults (input* asset))))

(defmethod notify:notify :before ((asset tile-data) file)
  (when (string= "ase" (pathname-type file))
    (sleep 1)
    (ql:quickload :kandria-data)))
