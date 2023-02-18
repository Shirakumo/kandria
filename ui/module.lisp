(in-package #:org.shirakumo.fraf.kandria)

(defun load-into-world (world &key edit)
  (when edit (! (issue +world+ 'toggle-editor)))
  (show-panel 'load-panel :loader (loader +main+))
  (render +main+ +main+)
  (let ((scene (scene +main+)))
    (setf (action-lists scene) ())
    (tagbody retry
       (loop for panel in (panels (unit 'ui-pass scene))
             do (unless (typep panel '(or prerelease-notice load-panel hud))
                  (hide panel)
                  (go retry))))
    (load-world (depot:to-pathname (depot world)) scene))
  (load-state NIL +main+))

(defun create-module (&key title author type)
  (let* ((module (make-instance 'stub-module :title title :version "0.0.0" :author author))
         (file (pathname-utils:subdirectory (module-directory) (id module))))
    (ensure-directories-exist file)
    (setf (file module) file)
    (uiop:copy-file (input* (asset 'kandria 'empty-save))
                    (merge-pathnames "preview.png" file))
    (depot:with-depot (depot file :commit T)
      (encode-payload module NIL depot 'module-v0)
      (case type
        (:world
         (let ((depot (depot:ensure-entry "world" depot :type :directory))
               (region (make-instance 'region))
               (world (make-instance 'world :title title :author author)))
           (enter (make-instance 'chunk) region)
           (enter (make-instance 'background) region)
           (enter (make-instance 'player) region)
           (enter region world)
           (save-world world depot)))
        (:other
         (depot:with-open (tx (depot:ensure-entry "setup.lisp" depot) :output 'character)
           (let ((stream (depot:to-stream tx)))
             (princ* `(define-module ,(id module)) stream)
             (princ* `(in-package ,(format NIL "~a.~a" '#:org.shirakumo.fraf.kandria.mod (id module))) stream)
             (terpri stream))))))
    (setf (find-module T) module)
    (case type
      (:world
       (load-module module)
       (load-into-world (first (worlds module)) :edit T))
      (T
       (open-in-file-manager file)
       (show (make-instance 'info-panel :text (@ module-create-new-info))
             :width (alloy:un 500) :height (alloy:un 300))))))

(defclass module-button (alloy:button)
  ())

(presentations:define-realization (ui module-button)
  ((:background simple:rectangle)
   (alloy:margins)
   :pattern (colored:color 0.1 0.1 0.1))
  ;; FIXME: The preview allocation leaks textures *bad*
  ((icon simple:icon)
   (alloy:extent 0 0 (alloy:ph 16/9) (alloy:ph 1))
   (or (preview alloy:value) (// 'kandria 'empty-save))
   :sizing :contain)
  ((title simple:text)
   (alloy:margins (alloy:ph 17/9) 10 10 10)
   (title alloy:value)
   :pattern colors:white
   :font (setting :display :font)
   :size (alloy:un 20)
   :halign :start
   :valign :top)
  ((author simple:text)
   (alloy:margins (alloy:ph 17/9) 40 10 0)
   (or (author alloy:value) "Anonymous")
   :pattern colors:white
   :font (setting :display :font)
   :size (alloy:un 14)
   :halign :start
   :valign :top)
  ((description simple:text)
   (alloy:margins (alloy:ph 17/9) 70 10 10)
   (shorten-text (description alloy:value) 64)
   :pattern colors:white
   :font (setting :display :font)
   :size (alloy:un 14)
   :halign :start
   :valign :top)
  ((version simple:text)
   (alloy:margins 10)
   (or (version alloy:value) "0.0.0")
   :pattern colors:white
   :font (setting :display :font)
   :size (alloy:un 20)
   :halign :end
   :valign :top)
  ((rating simple:text)
   (alloy:margins (alloy:ph 17/9) 40 10 0)
   (rating alloy:value)
   :pattern colors:white
   :font (setting :display :font)
   :size (alloy:un 14)
   :halign :end
   :valign :top)
  ((download-count simple:text)
   (alloy:margins (alloy:ph 17/9) 60 10 10)
   (@formats 'module-download-counter (download-count alloy:value))
   :pattern colors:white
   :font (setting :display :font)
   :size (alloy:un 14)
   :halign :end
   :valign :top))

(presentations:define-update (ui module-button)
  (:background
   :pattern (if alloy:focus
                (colored:color 0.3 0.3 0.3)
                (colored:color 0.1 0.1 0.1))))

(presentations:define-animated-shapes module-button
  (:background (simple:pattern :duration 0.2)))

(defmethod alloy:activate ((button module-button))
  (show (make-instance 'module-popup :module (alloy:value button))
        :width (alloy:vw 0.9)
        :height (alloy:vh 0.9)))

(defclass module-popup (popup-panel)
  ())

(defmethod initialize-instance :after ((panel module-popup) &key module)
  (let* ((layout (make-instance 'alloy:grid-layout :col-sizes '(T) :row-sizes '(T 40)
                                                   :shapes (list (simple:rectangle (unit 'ui-pass T) (alloy:margins) :pattern colors:white))))
         (preview (make-instance 'module-preview :object module))
         (button (alloy:represent (@ go-backwards-in-ui) 'popup-button)))
    (alloy:on alloy:activate (button)
      (hide panel))
    (alloy:enter preview layout)
    (alloy:enter button layout)
    (alloy:enter button (alloy:focus-element preview))
    (alloy:finish-structure panel layout (alloy:focus-element preview))))

(defclass module-list (alloy:vertical-linear-layout alloy:vertical-focus-list alloy:observable alloy:renderable)
  ((alloy:min-size :initform (alloy:size 150 50))
   (alloy:cell-margins :initform (alloy:margins))))

(presentations:define-realization (ui module-list)
  ((:bg simple:rectangle)
   (alloy:margins)
   :pattern colors:black))

(defmethod alloy:enter ((module module) (list module-list) &key)
  (let ((button (make-instance 'module-button :data (make-instance 'alloy:value-data :value module))))
    (alloy:enter button list)))

(defclass filter-input (alloy:input-line)
  ((alloy:placeholder :initform (@ module-filter-placeholder))))

(presentations:define-realization (ui filter-input)
  ((background simple:rectangle)
   (alloy:margins)
   :pattern colors:black)
  ((:border simple:rectangle)
   (alloy:margins)
   :pattern colors:white
   :line-width (alloy:un 1))
  ((:placeholder simple:text)
   (alloy:margins 10 2)
   (alloy:placeholder alloy:renderable)
   :font (setting :display :font)
   :size (alloy:un 14)
   :halign :start
   :valign :middle)
  ((:label simple:text)
   (alloy:margins 10 2)
   alloy:text
   :font (setting :display :font)
   :wrap T
   :size (alloy:un 14)
   :halign :start
   :valign :middle)
  ((:cursor simple:cursor)
   (presentations:find-shape :label alloy:renderable)
   0
   :pattern colors:white))

(presentations:define-update (ui filter-input)
  (:label :pattern colors:white))

(defclass module-create-panel (popup-panel)
  ())

(defmethod initialize-instance :after ((panel module-create-panel) &key on-accept)
  (let* ((focus (make-instance 'alloy:focus-list))
         (buttons (make-instance 'alloy:grid-layout :col-sizes '(T T) :row-sizes '(30)
                                                    :shapes (list (simple:rectangle (unit 'ui-pass T) (alloy:margins) :pattern colors:white))))
         (type :world)
         (title "Untitled")
         (author (username +main+)))
    (make-instance 'popup-label :value (@ module-title) :layout-parent buttons)
    (alloy:represent title 'popup-line :layout-parent buttons :focus-parent focus)
    (make-instance 'popup-label :value (@ module-author) :layout-parent buttons)
    (alloy:represent author 'popup-line :layout-parent buttons :focus-parent focus)
    (make-instance 'popup-label :value (@ module-type) :layout-parent buttons)
    (alloy:represent type 'alloy:combo-set :value-set '(:world :other) :layout-parent buttons :focus-parent focus)
    (let ((cancel (alloy:represent (@ dismiss-prompt-panel) 'popup-button :layout-parent buttons :focus-parent focus))
          (accept (alloy:represent (@ accept-prompt-panel) 'popup-button :layout-parent buttons :focus-parent focus)))
      (alloy:on alloy:activate (cancel)
        (hide panel))
      (alloy:on alloy:activate (accept)
        (hide panel)
        (funcall on-accept :title title :author author :type type))
      (alloy:on alloy:exit (focus)
        (setf (alloy:focus focus) :strong)
        (setf (alloy:focus cancel) :weak)))
    (alloy:finish-structure panel buttons focus)))

(defmethod show :after ((panel prompt-panel) &key)
  (harmony:play (// 'sound 'ui-warning)))

(defclass module-icon (alloy:icon alloy:value-component)
  ())

;; KLUDGE: since the icon is not part of any focus list, we handle the drop in an :around.
(defmethod alloy:handle :around ((event alloy:drop-event) (icon module-icon))
  (let ((path (first (alloy:paths event))))
    (when (or (not (string-equal "png" (pathname-type path)))
              (null (ignore-errors (pngload:load-file path :decode NIL))))
      (message (@formats 'error-bad-file-format "PNG")))
    (let ((module (alloy:object (alloy:data icon))))
      (unless (typep module 'remote-module)
        (v:info :kandria.module "Updating preview of ~a to ~a" module path)
        (depot:with-depot (depot (file module) :commit T)
          (depot:write-to (depot:ensure-entry "preview.png" depot) path))
        (setf (alloy:value icon) path)))))

(presentations:define-update (ui module-icon)
  (:icon
   :image alloy:value
   :sizing :contain))

(defclass module-title (alloy:label) ())

(presentations:define-realization (ui module-title)
  ((:label simple:text)
   (alloy:margins)
   alloy:text
   :font (setting :display :font)
   :wrap T
   :size (alloy:un 30)
   :halign :start
   :valign :middle))

(defclass module-label (alloy:label) ())

(presentations:define-realization (ui module-label)
  ((:label simple:text)
   (alloy:margins)
   alloy:text
   :font (setting :display :font)
   :wrap T
   :size (alloy:un 12)
   :halign :start
   :valign :middle))

(defclass module-description (alloy:label) ())

(presentations:define-realization (ui module-description)
  ((background simple:rectangle)
   (alloy:margins)
   :pattern colors:black)
  ((:label simple:text)
   (alloy:margins 15)
   alloy:text
   :font (setting :display :font)
   :wrap T
   :size (alloy:un 14)
   :halign :start
   :valign :top))

(presentations:define-update (ui module-description)
  (:label
   :pattern colors:white))

(defclass module-preview (alloy:structure alloy:delegate-data)
  ((actions :initform NIl :accessor actions)))

(defmethod initialize-instance :after ((preview module-preview) &key)
  (let* ((layout (make-instance 'alloy:border-layout :padding (alloy:margins 5)))
         (focus (make-instance 'alloy:focus-list))
         (info (make-instance 'alloy:vertical-linear-layout :cell-margins (alloy:margins 5)
                              :shapes (list (simple:rectangle (unit 'ui-pass T) (alloy:margins) :pattern colors:black))))
         (icon (alloy:represent-with 'module-icon preview :value-function 'preview :layout-parent info :ideal-size (alloy:size 400 (/ 400 16/9))))
         (title (alloy:represent-with 'module-title preview :value-function 'title :layout-parent info))
         (actions (make-instance 'alloy:vertical-linear-layout :cell-margins (alloy:margins 0 5) :layout-parent info))
         (data (make-instance 'alloy:grid-layout :col-sizes '(100 T) :row-sizes '(40) :layout-parent info))
         (description (alloy:represent-with 'module-description preview :value-function 'description)))
    (setf (actions preview) actions)
    (macrolet ((label (lang function)
                 `(progn
                    (alloy:represent (@ ,lang) 'module-label :layout-parent data)
                    (alloy:represent-with 'module-label preview :value-function ',function :layout-parent data))))
      (label module-id id)
      (label module-author author)
      (label module-version version)
      (label module-upstream-url upstream))
    (alloy:enter info layout :place :west :size (alloy:un 400))
    (alloy:enter description layout)
    (alloy:finish-structure preview layout focus)
    (alloy:refresh preview)))

(defmethod alloy:observe ((none (eql NIL)) object (data module-preview) &optional (name data))
  (declare (ignore name))
  (when object (call-next-method)))

(defmethod alloy:observe ((none (eql T)) object (data module-preview) &optional (name data))
  (declare (ignore name))
  (when object (call-next-method)))

(defmethod alloy:access ((preview module-preview) (field (eql 'preview)))
  (if (alloy:object preview)
      (or (preview (alloy:object preview)) (// 'kandria 'empty-save))
      (// 'kandria 'empty-save)))

(defmethod alloy:access ((preview module-preview) field)
  (when (alloy:object preview)
    (call-next-method)))

(defmethod alloy:refresh ((preview module-preview))
  (when (and (slot-boundp preview 'alloy:layout-element)
             (actions preview))
    (let* ((object (alloy:object preview))
           (focus (alloy:focus-element preview))
           (actions (actions preview)))
      (when object
        (dolist (function (alloy:observed preview))
          (alloy:notify-observers function preview (slot-value object function) object)))
      (alloy:clear focus)
      (alloy:clear actions)
      (etypecase object
        (null)
        (remote-module
         (when (authenticated-p object)
           (let ((subscribe (alloy:represent-with 'alloy:labelled-switch preview
                                                  :value-function 'active-p :text (@ module-subscribe-switch)
                                                  :focus-parent focus :layout-parent actions)))
             (alloy:on alloy:activate (subscribe)
               (setf (subscribed-p (remote object) object) (alloy:value subscribe)))))
         (cond ((null (find-module (id object)))
                (let ((install (alloy:represent (@ module-install) 'button
                                                :focus-parent focus :layout-parent actions)))
                  (alloy:on alloy:activate (install)
                    (with-ui-task (install-module (remote object) object)))))
               (T
                (alloy:represent (@ module-already-installed) 'button
                                 :focus-parent focus :layout-parent actions)))
         (when (upstream object)
           (let ((visit (alloy:represent (@ module-visit-official-page) 'button
                                         :focus-parent focus :layout-parent actions)))
             (alloy:on alloy:activate (visit)
               (open-in-browser (upstream object))))))
        (module
         (let ((active-p (alloy:represent-with 'alloy:labelled-switch preview
                                               :value-function 'active-p :text (@ module-active-switch)
                                               :focus-parent focus :layout-parent actions)))
           (alloy:on alloy:activate (active-p)
             (setf (active-p object) (alloy:value active-p))))
         (flet ((b (remote button)
                  (alloy:enter button focus)
                  (alloy:enter button actions)
                  (alloy:on alloy:activate (button)
                    (if (authenticated-p remote)
                        (begin-upload-flow remote object)
                        (promise:-> (begin-authentication-flow remote)
                          (:then () (begin-upload-flow remote object)))))))
           (dolist (remote (list-remotes))
             (if (search-module remote object)
                 (etypecase remote
                   (modio:client (b remote (alloy:represent (@ module-update-on-modio) 'button)))
                   (steam:steamworkshop (b remote (alloy:represent (@ module-update-on-steam) 'button))))
                 (etypecase remote
                   (modio:client (b remote (alloy:represent (@ module-publish-to-modio) 'button)))
                   (steam:steamworkshop (b remote (alloy:represent (@ module-publish-to-steam) 'button))))))))))))

(defclass world-preview (alloy:structure alloy:delegate-data)
  ())

(defmethod initialize-instance :after ((preview world-preview) &key)
  (let* ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout))
         (focus (make-instance 'alloy:focus-list))
         (title (alloy:represent-with 'module-title preview :value-function 'title))
         (description (alloy:represent-with 'module-description preview :value-function 'description))
         (data (make-instance 'alloy:grid-layout :col-sizes '(100 T 100 T) :row-sizes '(40)))
         (start (alloy:represent (@ module-load-world) 'button :focus-parent focus))
         (edit (alloy:represent (@ module-edit-world) 'button :focus-parent focus)))
    (alloy:on alloy:activate (start)
      (load-into-world (alloy:object preview)))
    (alloy:on alloy:activate (edit)
      (load-into-world (alloy:object preview) :edit T))
    (macrolet ((label (lang function)
                 `(progn
                    (alloy:represent (@ ,lang) 'module-label :layout-parent data)
                    (alloy:represent-with 'module-label preview :value-function ',function :layout-parent data))))
      (label module-author author)
      (label module-version version)
      (label module-id id))
    (alloy:enter title layout :constraints `((:top 0) (:left 0) (:right 0) (:height 50)))
    (alloy:enter data layout :constraints `((:chain :below ,title 5) (:height 80)))
    (alloy:enter edit layout :constraints `((:bottom 0) (:right 0) (:width 200) (:height 50)))
    (alloy:enter start layout :constraints `((:bottom 0) (:left 0) (:height 50) (:left-of ,edit 5)))
    (alloy:enter description layout :constraints `((:chain :below ,data 10) (:above ,start 10)))
    (alloy:finish-structure preview layout focus)))

(defmethod alloy:observe ((none (eql NIL)) object (data world-preview) &optional (name data))
  )

(defmethod alloy:observe ((all (eql T)) object (data world-preview) &optional (name data))
  (when (alloy:object data)
    (alloy:refresh data)))

(defmethod alloy:access ((preview world-preview) field)
  (when (alloy:object preview)
    (call-next-method)))

(defmethod alloy:refresh ((preview world-preview))
  (let ((object (alloy:object preview)))
    (dolist (function (alloy:observed preview))
      (alloy:notify-observers function preview (slot-value object function) object))))

(defclass module-menu (tab-view menuing-panel)
  ((module-list :accessor module-list)
   (module-preview :accessor module-preview)
   (world-list :accessor world-list)
   (world-preview :accessor world-preview)))

(defun make-searchable-list (main)
  (let* ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout))
         (focus (make-instance 'alloy:focus-stack :orientation :horizontal))
         (clipper (make-instance 'alloy:clip-view :limit :x))
         (list (make-instance 'vertical-tab-bar :min-size (alloy:size 100 0)))
         (filter "")
         (input (alloy:represent filter 'filter-input)))
    (alloy:on alloy:value (value input)
      (print value)
      (alloy:do-elements (element list)
        (if (search value (alloy:text element) :test #'char-equal)
            (setf (alloy:ideal-size element) NIL)
            (setf (alloy:ideal-size element) (alloy:size 0 0))))
      (alloy:refit list))
    (alloy:enter list focus :layer 0)
    (alloy:enter input focus :layer 1)
    (alloy:enter main focus :layer 1)
    (alloy:enter list clipper)
    (alloy:enter input layout :constraints `((:size 250 30) (:left 0) (:top 0)))
    (alloy:enter clipper layout :constraints `((:width 250) (:left 0) (:bottom 0) (:top 30)))
    (alloy:enter main layout :constraints `((:right-of ,clipper 10) (:top 10) (:bottom 10) (:right 10)))
    (values layout focus list)))

(defmethod initialize-instance :after ((panel module-menu) &key)
  ;; Mods Browser
  (multiple-value-bind (layout focus list) (make-searchable-list (setf (module-preview panel) (make-instance 'module-preview :object NIL)))
    (setf (module-list panel) list)
    (add-tab panel (make-instance 'trial-alloy::language-data :name 'module-manage-tab) layout focus :icon ""))
  ;; Worlds Browser
  (multiple-value-bind (layout focus list) (make-searchable-list (setf (world-preview panel) (make-instance 'world-preview :object NIL)))
    (setf (world-list panel) list)
    (add-tab panel (make-instance 'trial-alloy::language-data :name 'module-worlds-tab) layout focus :icon ""))
  ;; Discovery Tab
  (let* ((tab (make-instance 'module-discovery-panel))
         (button (add-tab panel (make-instance 'trial-alloy::language-data :name 'module-discover-tab)
                          (alloy:layout-element tab)
                          (alloy:focus-element tab) :icon "")))
    (alloy:on alloy:activate (button)
      (reset tab)))
  ;; Extra buttons
  (let ((button (alloy:represent (@ module-import-new) 'tab-button :layout-parent panel :icon "")))
    (alloy:on alloy:activate (button)
      (dolist (path (file-select:existing :title "Select Mod Files" :multiple T))
        (v:info :kandria.module "Copying module from ~a" path)
        (filesystem-utils:copy-file path (module-directory) :replace T))
      (register-module T)))
  (let ((button (alloy:represent (@ module-create-new) 'tab-button :layout-parent panel :icon "")))
    (alloy:on alloy:activate (button)
      (show (make-instance 'module-create-panel :on-accept #'create-module)
            :width (alloy:un 500) :height (alloy:un 200))))
  (alloy:on alloy:exit ((alloy:focus-element panel))
    (when (active-p panel)
      (hide panel)))
  (reset panel))

(defmethod stage :after ((menu module-menu) (area staging-area))
  (stage (// 'kandria 'empty-save) area))

(defmethod show :before ((panel module-menu) &key)
  (alloy:enter (alloy:represent (@ go-backwards-in-ui) 'back-button :icon "") panel)
  (let ((layout (make-instance 'menu-layout)))
    (alloy:enter (alloy:layout-element panel) layout :place :center)
    (setf (slot-value panel 'alloy:layout-element) layout)))

(defmethod handle ((event module-event) (panel module-menu))
  (reset panel))

(defmethod reset ((panel module-menu))
  (alloy:clear (module-list panel))
  (dolist (module (list-modules :available))
    (let ((button (make-instance 'tab-button :data (make-instance 'alloy:value-data :value (title module)) :layout-parent (module-list panel))))
      (alloy:on alloy:focus (value button)
        (when value
          (setf (alloy:object (module-preview panel)) module)))))
  (alloy:clear (world-list panel))
  (dolist (world (list-worlds))
    (let ((button (make-instance 'tab-button :data (make-instance 'alloy:value-data :value (title world)) :layout-parent (world-list panel))))
      (alloy:on alloy:focus (value button)
        (when value
          (setf (alloy:object (world-preview panel)) world))))))

(defclass module-sort-combo-item (alloy:combo-item)
  ())

(defmethod alloy:text ((item module-sort-combo-item))
  (ecase (alloy:value item)
    (:latest (@ module-sort-latest-uploads-first))
    (:updated (@ module-sort-most-recently-updated-first))
    (:title (@ module-sort-title-alphabetically))
    (:rating (@ module-sort-best-rated-first))
    (:popular (@ module-sort-most-popular-first))
    (:subscribers (@ module-sort-most-subscribers-first))))

(presentations:define-realization (ui module-sort-combo-item)
  ((background simple:rectangle)
   (alloy:margins)
   :pattern colors:black
   :z-index 100)
  ((:label simple:text)
   (alloy:margins 2)
   alloy:text
   :font (setting :display :font)
   :wrap NIL
   :size (alloy:un 14)
   :z-index 100
   :halign :start
   :valign :middle))

(presentations:define-update (ui module-sort-combo-item)
  (:background
   :pattern (if (alloy:focus alloy:renderable)
              (colored:color 0.2 0.2 0.2)
              colors:black)))

(defclass module-sort (alloy:combo)
  ())

(defmethod alloy:value-set ((combo module-sort))
  '(:latest :updated :title :rating :popular :subscribers))

(defmethod alloy:combo-item (item (combo module-sort))
  (make-instance 'module-sort-combo-item :value item))

(presentations:define-realization (ui module-sort)
  ((background simple:rectangle)
   (alloy:margins)
   :pattern colors:black)
  ((:border simple:rectangle)
   (alloy:margins)
   :pattern colors:white
   :line-width (alloy:un 1))
  ((:label simple:text)
   (alloy:margins 10 2)
   alloy:text
   :font (setting :display :font)
   :size (alloy:un 14)
   :valign :middle))

(defclass module-discovery-panel (alloy:structure alloy:observable-object)
  ((query :initform "" :accessor query)
   (page :initform 0 :accessor page)
   (sort-by :initform :latest :accessor sort-by)
   (module-list :accessor module-list)))

(defmethod initialize-instance :after ((panel module-discovery-panel) &key)
  (let* ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout))
         (focus (make-instance 'alloy:focus-stack :orientation :vertical))
         (clipper (make-instance 'alloy:clip-view :limit :x))
         (list (setf (module-list panel) (make-instance 'module-list :min-size (alloy:size 150 100))))
         (scroll (alloy:represent-with 'alloy:y-scrollbar clipper :focus-parent focus))
         (query (alloy:represent (slot-value panel 'query) 'filter-input :placeholder (@ module-search-placeholder) :focus-parent focus))
         (sort (alloy:represent (slot-value panel 'sort-by) 'module-sort :focus-parent focus))
         (search (alloy:represent (@ module-search-confirm) 'button :focus-parent focus)))
    (alloy:enter list clipper)
    (alloy:enter list focus :layer 1)
    (alloy:enter search layout :constraints `((:top 10) (:right 10) (:size 100 50)))
    (alloy:enter sort layout :constraints `((:width 150) (:chain :left ,search 5)))
    (alloy:enter query layout :constraints `((:left 10) (:chain :left ,sort 5)))
    (alloy:enter scroll layout :constraints `((:width 20) (:right 10) (:bottom 10) (:below ,query 5)))
    (alloy:enter clipper layout :constraints `((:left 10) (:chain :left ,scroll 0)))
    (alloy:on alloy:activate (search) (reset panel))
    (alloy:finish-structure panel layout focus)))

(defmethod reset ((panel module-discovery-panel))
  (v:info :kandria.module "Refreshing discovery panel...")
  (alloy:clear (module-list panel))
  (with-ui-task
    (let ((modules (search-modules T :query (query panel) :sort (sort-by panel) :page (page panel))))
      (v:info :kandria.module "Got ~d mod~:p matching query" (length modules))
      (dolist (module modules)
        (alloy:enter module (module-list panel))))))

(defun begin-upload-flow (remote module)
  (promise:-> (with-ui-task (upload-module remote module))
    (:then (remote-module) (message (@formats 'module-upload-successful (remote-id remote-module))))))

(defmethod begin-authentication-flow ((client modio:client))
  (promise:with-promise (ok)
    (if (steam:steamworks-available-p)
        (let ((terms (modio:authenticate/terms client)))
          (promise:-> (prompt terms)
            (:then (email)
                   (let ((data (steam:make-encrypted-app-ticket (steam:interface 'steam:steamuser T) :data email)))
                     (modio:authenticate/steam client (base64:usb8-array-to-base64-string data)
                                               :email email :terms-agreed T)))
            (:then () (funcall ok))))
        (promise:-> (query* (@ module-modio-login-query-email)
                            :placeholder "someone@example.com")
          (:then (email)
                 (query* (or (modio:authenticate/email-request client email)
                             (@ module-modio-login-query-email-code))
                         :placeholder "----"))
          (:then (code)
                 (modio:authenticate/email-exchange client code)
                 (message (@ module-login-completed-successfully)))
          (:then () (funcall ok))))))
