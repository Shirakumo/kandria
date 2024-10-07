(in-package #:org.shirakumo.fraf.kandria)

(defun modio-remote ()
  (unless modio:*client*
    (setf modio:*client* (make-instance 'modio:client :default-game-id 4561 :api-key "33d270c5b4b2ca4de8c8520c9708f80c"
                                                      :language (language)))
    (modio:restore-user-properties modio:*client* (setting :modules :modio)))
  modio:*client*)

(defmethod modio::complete-authentication :after ((client modio:client) data)
  (setf (setting :modules :modio) (modio:extract-user-properties client)))

(pushnew 'modio-remote *remote-funcs*)

(defclass modio-module (modio:mod remote-module)
  ((title :initform NIL)
   (version :initform NIL)
   (author :initform NIL)))

(defmethod authenticated-p ((client modio:client))
  (modio:authenticated-p client))

(defmethod remote ((module modio-module))
  modio:*client*)

(defmethod rating ((module modio-module))
  (getf (modio:rating (modio:stats module)) :text))

(defmethod download-count ((module modio-module))
  (getf (modio:downloads (modio:stats module)) :total))

(defmethod authenticated-p ((module modio-module))
  (modio:authenticated-p modio:*client*))

(defmethod register-module ((client modio:client))
  (if (modio:authenticated-p client)
      (with-ignored-errors-on-release (:kandria.module.modio "Failed to register subscribed mods.")
        (dolist (mod (modio:me/subscribed client :game (modio:default-game-id client)))
          (install-module client (ensure-modio-module mod))))
      (v:info :kandria.module.modio "Skipping listing subscribed mods as the client is not authenticated")))

(defmethod search-module ((client modio:client) (module modio-module))
  module)

(defmethod search-module ((client modio:client) (id string))
  (let ((found (or (modio:games/mods client (modio:default-game-id client)
                                     :metadata-blob (prin1-to-string id))
                   (modio:games/mods client (modio:default-game-id client)
                                     :metadata (format NIL "id:~a" id)))))
    (when found (ensure-modio-module (first found)))))

(defmethod logout ((client modio:client))
  (when (modio:authenticated-p client)
    (modio:authenticate/logout client)
    (setf (setting :modules :modio) (modio:extract-user-properties client))))

(defun ensure-modio-module (mod)
  (let ((mod (ensure-instance mod 'modio-module)))
    (setf (slot-value mod 'id) (or (gethash "id" (modio:metadata mod))
                                   (when (and (modio:metadata-blob mod) (string/= "" (modio:metadata-blob mod)))
                                     (read-from-string (modio:metadata-blob mod)))
                                   (modio:name-id mod)
                                   (princ-to-string (modio:id mod))))
    (setf (slot-value mod 'title) (modio:name mod))
    (setf (slot-value mod 'author) (username (modio:submitted-by mod)))
    (setf (slot-value mod 'version) (or (modio:version (modio:modfile mod)) "0.0.0"))
    (setf (slot-value mod 'description) (or (or* (modio:description mod)
                                                 (modio:summary mod))
                                            ""))
    (setf (slot-value mod 'upstream) (or (modio:homepage-url mod)
                                         (modio:profile-url mod)))
    mod))

(defmethod search-modules ((client modio:client) &key query (sort :title) (page 0) (ignore-cache T))
  (let ((mods (modio:games/mods client (modio:default-game-id client)
                                :name (when (or* query) (modio:f (search query)))
                                :start (* (+ 0 page) 50)
                                :end (* (+ 1 page) 50)
                                :per-page 50
                                :sort (ecase sort
                                        (:latest '(:date-added :desc))
                                        (:updated '(:date-updated :desc))
                                        (:title '(:name :asc))
                                        (:rating '(:rating :desc))
                                        (:popular '(:popular :desc))
                                        (:subscribers '(:downloads :desc)))
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
              (with-open-file (output target :direction :output :element-type '(unsigned-byte 8)
                                             :if-exists :supersede)
                (uiop:copy-stream-to-stream input output :element-type '(unsigned-byte 8)))))
          (setf (slot-value mod 'preview) target))))))

(defmethod user-authored-p ((client modio:client) (module modio-module))
  (and (modio:authenticated-p client)
       (= (modio:id (modio:submitted-by module))
          (modio:id (modio:me client)))))

(defmethod username ((user modio:user))
  (let ((name (modio:display-name user)))
    (if (or (null name) (eql 'null name))
        (modio:name user)
        name)))

(defmethod username ((client modio:client))
  (username (modio:me client)))

(defmethod subscribed-p ((client modio:client) (module modio-module))
  (modio:me/subscribed client :mod (modio:id module)))

(defmethod subscribe-module ((client modio:client) (module modio-module))
  (unless (modio:authenticated-p client) (error 'not-authenticated :remote client))
  (modio:games/mods/subscribe client (modio:default-game-id client) (modio:id module)))

(defmethod unsubscribe-module ((client modio:client) (module modio-module))
  (unless (modio:authenticated-p client) (error 'not-authenticated :remote client))
  (modio:games/mods/unsubscribe client (modio:default-game-id client) (modio:id module)))

(defmethod install-module ((client modio:client) (module modio-module))
  (handler-bind (((and error (not unsupported-save-file) (not module-registration-failed))
                   (lambda (e)
                     (v:error :kandria.module.modio "Install failed: ~a" e)
                     (v:debug :kandria.module.modio e)
                     (error 'module-installation-failed :module module :error e))))
    ;; Install dependencies first.
    (dolist (dependency (modio:games/mods/dependencies client (modio:default-game-id client) (modio:id module)))
      (install-module client (ensure-modio-module (modio:mod dependency))))
    ;; Now actually download it.
    (let ((file (make-pathname :name (id module) :type "zip" :defaults (module-directory))))
      (when (or (null (probe-file file))
                (< (file-write-date file) (modio:date-added (modio:modfile module))))
        (v:info :kandria.module.modio "Downloading modfile for ~a..." module)
        (modio:download-modfile (modio:modfile module) file :if-exists :supersede))
      (register-module file))))

(defmethod upload-module ((client modio:client) (module module))
  (unless (modio:authenticated-p client) (error 'not-authenticated :remote client))
  (let ((remote (search-module client module)))
    (cond (remote
           (setf (file remote) (file module))
           (upload-module client remote))
          (T ;; Upload a new module
           (let ((mod (modio:games/mods/add
                       client (modio:default-game-id client) (title module) (shorten-text (or* (description module) "No description provided.") 250)
                       (or (preview module) (input* (asset 'kandria 'empty-save))) :homepage-url (upstream module) :description (or* (description module))
                       :metadata-blob (prin1-to-string (id module)))))
             (with-cleanup-on-failure (modio:games/mods/delete client (modio:default-game-id client) (modio:id mod))
               (ensure-modio-module mod)
               (modio:games/mods/files/add client (modio:default-game-id client) (modio:id mod)
                                           (file module) :version (version module))
               (ignore-errors
                (modio:games/mods/metadata/add client (modio:default-game-id client) (modio:id mod)
                                               (mktab "id" (id module))))
               ;; Search self to invalidate cache
               (modio:games/mods client (modio:default-game-id client)
                                 :metadata-blob (princ-to-string (id module)) :ignore-cache T)
               (modio:games/mods client (modio:default-game-id client)
                                 :metadata (format NIL "id:~a" (id module)) :ignore-cache T))
             mod)))))

(defmethod upload-module ((client modio:client) (module modio-module))
  (unless (modio:authenticated-p client) (error 'not-authenticated :remote client))
  (let ((local (or (find-module (id module)) module)))
    (modio:games/mods/edit client (modio:default-game-id client) (modio:id module)
                           :summary (when (description local) (shorten-text (description local) 250))
                           :name (title local) :description (description local)
                           :homepage-url (upstream local) :logo (or (preview local) (input* (asset 'kandria 'empty-save))))
    (modio:games/mods/files/add client (modio:default-game-id client) (modio:id module)
                                (file local) :version (version local)))
  module)

(defmethod remote-id ((module modio-module))
  (modio:name-id module))

(defmethod (setf rating) (rating (module modio-module))
  (handler-case
      (modio:games/mods/ratings/add modio:*client* (modio:default-game-id modio:*client*) (modio:id module)
                                    (ecase rating
                                      ((1 :up) +1)
                                      ((0 NIL) 0)
                                      ((-1 :down) -1)))
    (modio:bad-request (e)
      (case (modio:error-code e)
        ;; Already rated, ignore.
        (15028 rating)
        (T (error e)))))
  rating)

(define-language-change-hook modio (language)
  (when modio:*client*
    (setf (modio:language modio:*client*) language)))
