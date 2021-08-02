(in-package #:org.shirakumo.fraf.kandria)

(defclass news-display (label)
  ((alloy:value :initform "")
   (markup :initform () :accessor markup)))

(defmethod initialize-instance :after ((display news-display) &key)
  (fetch-news display))

(presentations:define-update (ui news-display)
  (:label
   :size (alloy:un 15)
   :pattern colors:gray
   :valign :bottom :halign :left
   :markup (markup alloy:renderable)))

(defun parse-news (source)
  (let ((req (dialogue:resume (dialogue:run (dialogue:compile source T) (make-instance 'dialogue:vm)) 1)))
    (values (dialogue:text req)
            (normalize-markup (dialogue:markup req)))))

(defun fetch-news (target &optional (url "https://kandria.com/news.mess"))
  (with-thread ("news-fetcher")
    (v:info :kandria.news "Fetching news...")
    (handler-case
        (multiple-value-bind (text markup) (parse-news (drakma:http-request url :want-stream T))
          (setf (alloy:value target) text)
          (setf (markup target) markup))
      (error (e)
        (v:severe :kandria.news "Failed to fetch news: ~a" e)))))

(defclass main-menu-button (button)
  ())

(presentations:define-realization (ui main-menu-button)
  ((:label simple:text)
   (alloy:margins) alloy:text
   :font (setting :display :font)
   :halign :middle :valign :middle)
  ((:border simple:rectangle)
   (alloy:extent 0 0 (alloy:pw 1) 1)))

(presentations:define-update (ui main-menu-button)
  (:label
   :size (alloy:un 16)
   :pattern colors:white)
  (:border
   :pattern (if alloy:focus colors:white colors:transparent)))

(presentations:define-animated-shapes main-menu-button
  (:border (simple:pattern :duration 0.2)))

(defclass main-menu (menuing-panel)
  ())

(defmethod initialize-instance :after ((panel main-menu) &key)
  (let ((layout (make-instance 'org.shirakumo.alloy.layouts.constraint:layout))
        (menu (make-instance 'alloy:vertical-linear-layout :cell-margins (alloy:margins 5) :min-size (alloy:size 100 30)))
        (focus (make-instance 'alloy:focus-list)))
    (alloy:enter menu layout :constraints `((:center :w) (:bottom 20) (:top 400) (:width 200)))
    (macrolet ((with-button ((name &rest initargs) &body body)
                 `(make-instance 'main-menu-button :value (@ ,name) :on-activate (lambda ()
                                                                                   (discard-events +world+)
                                                                                   ,@body)
                                                   :focus-parent focus :layout-parent menu ,@initargs)))
      (when (list-saves)
        (with-button (load-game-menu)
          (show-panel 'save-menu :intent :load)))
      (with-button (new-game)
        (if (list-saves)
            (show-panel 'save-menu :intent :new)
            (load-game NIL +main+)))
      (with-button (options-menu)
        (show-panel 'options-menu))
      (with-button (credits-menu)
        (show-panel 'credits))
      #++
      (with-button (changelog-menu)
        )
      (let ((subbutton
              (if (steam:steamworks-available-p)
                  (with-button (subscribe-cta)
                    (open-in-browser "https://courier.tymoon.eu/subscription/1"))
                  (with-button (wishlist-cta)
                    (open-in-browser "https://store.steampowered.com/app/1261430/Kandria/?utm_source=in-game")))))
        (alloy:on alloy:focus (value subbutton)
          (setf (presentations:update-overrides subbutton)
                (if value
                    `((:label :markup ((0 1000 (:rainbow T)))))
                    `((:label :markup ()))))))
      (let ((exit (with-button (exit-game)
                    (quit *context*))))
        (alloy:on alloy:exit (focus)
          (setf (alloy:focus exit) :weak)
          (setf (alloy:focus focus) :strong)))
      (let ((news (make-instance 'news-display)))
        (alloy:enter news layout :constraints `((:left 5) (:bottom 5) (:height 50) (:width 500)))))
    (alloy:finish-structure panel layout focus)))
