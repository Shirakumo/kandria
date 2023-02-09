(in-package #:org.shirakumo.fraf.kandria)

(defclass steam-module (steam:workshop-file stub-module)
  ())

(defun ensure-steam-module (mod)
  (ensure-instance mod 'steam-module
                   :id (steam:metadata mod)
                   :title (steam:display-name mod)
                   :description (steam:description mod)
                   :author (steam:display-name (steam:owner mod))
                   :preview (steam:preview mod)
                   :upstream (steam:url mod)))

(defmethod search-module ((client steam:steamworkshop) (id string))
  (let ((mods (steam:query client (steam:app (steam:interface 'steam:steamapps T))
                           :key-value-tags `(("id" . ,id)) :request '(:full-description :metadata))))
    (when mods (ensure-steam-module (first mods)))))

(defmethod search-modules ((client steam:steamworkshop) query &key (page 0))
  (let ((mods (steam:query client (steam:app (steam:interface 'steam:steamapps T))
                           :search query :request '(:full-description :metadata) :page (1+ page))))
    (dolist (mod mods mods)
      (ensure-steam-module mod))))

(defmethod subscribe-module ((client steam:steamworkshop) (file steam:workshop-file))
  (steam:subscribe file))

(defmethod unsubscribe-module ((client steam:steamworkshop) (file steam:workshop-file))
  (steam:unsubscribe file))

(defmethod install-module ((client steam:steamworkshop) (file steam-module))
  (steam:download file))

(defmethod upload-module ((client steam:steamworkshop) (file steam-module))
  (let ((update (make-instance 'steam:workshop-update :interface client :workshop-file file)))
    (setf (steam:metadata update) (id file))
    (setf (steam:key-value-tags update) `(("id" . ,(id file))))
    (setf (steam:content update) (file file))
    (setf (steam:display-name update) (title file))
    (setf (steam:description update) (description file))
    (when (preview file)
      (setf (steam:preview update) (preview file)))
    (steam:execute update)))

(defmethod upload-module ((client steam:steamworkshop) (module module))
  (let ((remote (search-module client module)))
    (unless remote
      (setf remote (make-instance 'steam-module
                                  :app (steam:app (steam:interface 'steam:steamapps T))
                                  :kind :community
                                  :id (id module)
                                  :title (title module)
                                  :author (author module)
                                  :description (description module)
                                  :version (version module)
                                  :preview (preview module))))
    (setf (file remote) (file module))
    (upload-module client remote)))

(steam:define-callback steam*::download-item (result app-id published-file-id result)
  (when (eql app-id (steam:app-id (steam:interface 'steam:steamutils T)))
    (destructuring-bind (&key directory &allow-other-keys) (steam:installation-info (make-intsance 'steam:workshop-file :iface (steam:interface 'steam:steamworkshop T)
                                                                                                                        :handle published-file-id))
      (when directory
        (register-module directory)))))
