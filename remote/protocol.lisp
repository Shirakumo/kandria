(in-package #:org.shirakumo.fraf.kandria)

(defvar *remotes* ())

(defgeneric search-module (remote id))
(defgeneric search-modules (remote query &key page))
(defgeneric subscribe-module (remote module))
(defgeneric unsubscribe-module (remote module))
(defgeneric install-module (remote module))

(defmethod search-module (remote (module module))
  (search-module remote (id module)))

(defmethod subscribe-module (remote (module module))
  (subscribe-module module (search-module remote module)))

(defmethod unsubscribe-module (remote (module module))
  (unsubscribe-module module (search-module remote module)))

(defmethod install-module (remote (module module))
  (install-module module (search-module remote module)))
