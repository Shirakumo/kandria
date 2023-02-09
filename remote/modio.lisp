(in-package #:org.shirakumo.fraf.kandria)

(unless modio:*client*
  (setf modio:*client* (make-instance 'modio:client :default-game-id 4561 :api-key "33d270c5b4b2ca4de8c8520c9708f80c"))
  (pushnew modio:*client* *remotes*))

(defclass modio-module (modio:mod stub-module)
  ())

(defmethod search-module ((client modio:client) (module modio-module))
  module)

(defmethod search-module ((client modio:client) (id string))
  (let ((found (modio:games/mods client (modio:default-game-id client)
                                 :metadata (format NIL "id:~a" id))))
    (when found (ensure-modio-module (first found)))))

(defun ensure-modio-module (mod)
  (ensure-instance mod 'modio-module
                   :id (or (gethash "id" (modio:metadata mod))
                           (modio:name-id mod)
                           (princ-to-string (modio:id mod)))
                   :title (modio:name mod)
                   :author (modio:name (modio:submitted-by mod))
                   :version (modio:version (modio:modfile mod))
                   :description (modio:description mod)
                   :upstream (or (modio:homepage-url mod)
                                 (modio:profile-url mod))))

(defmethod search-modules ((client modio:client) query &key (page 0) (ignore-cache NIL))
  (let ((mods (modio:games/mods client (modio:default-game-id client)
                                :name (modio:f (search query))
                                :start (* (+ 0 page) 50)
                                :end (* (+ 1 page) 50)
                                :per-page 50
                                :sort :name
                                :ignore-cache ignore-cache)))
    (dolist (mod mods mods)
      (ensure-modio-module mod)
      (when (and (modio:logo mod)
                 (null (preview mod)))
        (let ((target (tempfile :id (id mod) :type "png"))
              (source (or (getf (modio:thumbnails (modio:logo mod)) 640)
                          (getf (modio:thumbnails (modio:logo mod)) 320)
                          (modio:original (modio:logo mod)))))
          (unless (probe-file target)
            (with-open-stream (input (drakma:http-request source :want-stream T))
              (with-open-file (output target :direction :output :element-type '(unsigned-byte 8))
                (uiop:copy-stream-to-stream input output :element-type '(unsigned-byte 8)))))
          (setf (preview mod) target))))))

(defmethod subscribe-module ((client modio:client) (module modio-module))
  (modio:games/mods/subscribe client (modio:default-game-id client) (modio:id module)))

(defmethod unsubscribe-module ((client modio:client) (module modio-module))
  (modio:games/mods/unsubscribe client (modio:default-game-id client) (modio:id module)))

(defmethod install-module ((client modio:client) (module modio-module))
  (modio:download-modfile (modio:modfile module) (make-pathname :name (id module) :type "zip" :defaults (module-directory))
                          :if-exists :supersede))

(defmethod upload-module ((client modio:client) (module module))
  (let ((remote (search-module client module)))
    (cond (remote
           (setf (file remote) (file module))
           (upload-module client remote))
          (T ;; Upload a new module
           (let ((mod (ensure-modio-module
                       (modio:games/mods/add
                        client (modio:default-game-id client) (title module) (description module)
                        (or (preview module))
                        :homepage-url (upstream module)))))
             (modio:games/mods/metadata/add client (modio:default-game-id client) (modio:id mod)
                                            :metadata (mktab "id" (id module)))
             (modio:games/mods/files/add client (modio:default-game-id client) (modio:id mod)
                                         (file module) :version (version module)))))))

(defmethod upload-module ((client modio:client) (module modio-module))
  (modio:games/mods/edit client (modio:default-game-id client) (modio:id module)
                         :name (title module) :description (description module)
                         :homepage-url (upstream module) :logo (preview module))
  (modio:games/mods/files/add client (modio:default-game-id client) (modio:id module)
                              (file module) :version (version module)))
