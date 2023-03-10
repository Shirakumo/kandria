(in-package #:org.shirakumo.fraf.kandria)

(defun steam-remote ()
  (if (steam:steamworks-available-p)
      (steam:interface 'steam:steamworkshop T)
      (error 'not-authenticated :remote (type-prototype 'steam:steamworkshop))))

#++(pushnew 'steam-remote *remote-funcs*)

(defclass steam-module (steam:workshop-file remote-module)
  ())

(defun ensure-steam-module (mod)
  (ensure-instance mod 'steam-module
                   :id (steam:metadata mod)
                   :title (steam:display-name mod)
                   :description (steam:description mod)
                   :author (steam:display-name (steam:owner mod))
                   :preview (steam:preview mod)
                   :upstream (steam:url mod)))

(defmethod authenticated-p ((client steam:steamworkshop))
  (steam:steamworks-available-p))

(defmethod remote ((module steam-module))
  (steam:interface 'steam:steamworkshop T))

(defmethod rating ((module steam-module))
  (steam:score module))

(defmethod download-count ((module steam-module))
  (getf (steam:statistics module) :num-subscriptions))

(defmethod authenticated-p ((client steam-module)) T)

(defmethod user-authored-p ((client steam:steamworkshop) (module steam-module))
  (= (steam:steam-id T)
     (steam:steam-id (steam:owner module))))

(defmethod username ((client steam:steamworkshop))
  (steam:display-name T))

(defmethod logout ((client steam:steamworkshop)))

(defmethod register-module ((client steam:steamworkshop))
  (if (steam:steamworks-available-p)
      (dolist (mod (steam:list-subscribed-files client))
        (install-module client (ensure-steam-module mod)))
      (v:info :kandria.module.steam "Skipping listing subscribed mods as the client is not authenticated")))

(defmethod search-module ((client steam:steamworkshop) (id string))
  (let ((mods (steam:query client (steam:app (steam:interface 'steam:steamapps T))
                           :key-value-tags `(("id" . ,id)) :request '(:full-description :metadata))))
    (when mods (ensure-steam-module (first mods)))))

(defmethod search-modules ((client steam:steamworkshop) &key query (sort :title) (page 0))
  (let ((mods (steam:query client (steam:app (steam:interface 'steam:steamapps T))
                           :search (or* query)
                           :request '(:full-description :metadata)
                           :page (1+ page)
                           :sort (ecase sort
                                   (:latest :ranked-by-publication-date)
                                   (:updated :ranked-by-last-updated-date)
                                   (:title :ranked-by-text-search)
                                   (:rating :ranked-by-vote)
                                   (:popular :ranked-by-trend)
                                   (:subscribers :ranked-by-total-unique-subscriptions)))))
    (dolist (mod mods mods)
      (ensure-steam-module mod))))

(defmethod subscribed-p ((client steam:steamworkshop) (file steam:workshop-file))
  ;; FIXME: WHAT?
  )

(defmethod subscribe-module ((client steam:steamworkshop) (file steam:workshop-file))
  (steam:subscribe file))

(defmethod unsubscribe-module ((client steam:steamworkshop) (file steam:workshop-file))
  (steam:unsubscribe file))

(defmethod install-module ((client steam:steamworkshop) (file steam:workshop-file))
  (case (steam:state file)
    (:installed
     (destructuring-bind (&key directory &allow-other-keys) (steam:installation-info file)
       (if directory
           (register-module directory)
           (v:warn :kandria.module.steam "No directory for mod ~a" file))))
    ((:needs-update :downloading :download-pending :subscribed)
     (steam:download file))
    (:legacy-item
     (error "Can't deal with legacy item ~a" file))
    (:none
     (steam:subscribe file)
     (steam:download file))))

(defmethod upload-module ((client steam:steamworkshop) (file steam-module))
  (let ((update (make-instance 'steam:workshop-update :interface client :workshop-file file)))
    (setf (steam:metadata update) (id file))
    (setf (steam:key-value-tags update) `(("id" . ,(id file))))
    (setf (steam:content update) (file file))
    (setf (steam:display-name update) (title file))
    (setf (steam:description update) (description file))
    (when (preview file)
      (setf (steam:preview update) (preview file)))
    (steam:execute update)
    file))

(defmethod upload-module ((client steam:steamworkshop) (module module))
  (let ((remote (search-module client module)))
    (unless remote
      (setf remote (make-instance 'steam-module
                                  :interface client
                                  :id (id module)
                                  :title (title module)
                                  :author (author module)
                                  :description (description module)
                                  :version (version module)
                                  :preview (preview module))))
    (setf (file remote) (file module))
    (upload-module client remote)))

(defmethod remote-id ((file steam:workshop-file))
  (steam:handle file))

#++
(steam:define-callback steam*::download-item (result app-id published-file-id result)
  (when (eql app-id (steam:app-id (steam:interface 'steam:steamutils T)))
    (if (eql :ok result)
        (let ((iface (steam:interface 'steam:steamworkshop T)))
          (install-module iface (make-instance 'steam:workshop-file :interface iface :handle published-file-id)))
        (v:warn :kandria.module.steam "Item download for ~a failed: ~a" published-file-id result))))
