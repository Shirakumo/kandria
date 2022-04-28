(in-package #:org.shirakumo.fraf.kandria)

(defclass paragraph (label)
  ())

(presentations:define-update (ui paragraph)
  (:label
   :size (alloy:un 15)
   :wrap T
   :valign :top
   :halign :middle))

(defclass header (label)
  ((level :initarg :level :initform 1 :accessor level)))

(presentations:define-update (ui header)
  (:label
   :size (case (level alloy:renderable)
           (0 (alloy:un 50))
           (1 (alloy:un 35))
           (2 (alloy:un 25))
           (T (alloy:un 20)))
   :valign :middle
   :halign :middle))

(defclass icon (alloy:direct-value-component alloy:icon)
  ())

(presentations:define-update (ui icon)
  (:icon
   :sizing :contain))

(defmethod alloy:suggest-bounds ((bounds alloy:extent) (icon icon))
  (alloy:extent (alloy:x bounds)
                (alloy:y bounds)
                (alloy:w bounds)
                (alloy:un 200)))

(defclass credits-layout (alloy:fullscreen-layout alloy:focus-element alloy:renderable)
  ())

(defmethod alloy:handle ((ev alloy:pointer-event) (layout credits-layout))
  T)

(defmethod alloy:handle ((ev alloy:exit) (layout credits-layout)))

(presentations:define-realization (ui credits-layout)
  ((:bg simple:rectangle)
   (alloy:margins)
   :pattern colors:black))

(defclass credits (menuing-panel)
  ((credits :accessor credits)
   (offset :initform 0 :accessor offset)
   (ideal :initform NIL :accessor ideal)))

(defmethod hide :after ((credits credits))
  (setf (game-speed +main+) 1.0)
  (labels ((traverse (node)
             (typecase node
               (alloy:layout
                (alloy:call-with-elements #'traverse node))
               (presentations::renderable
                (map NIL #'traverse (presentations:shapes node)))
               (simple:icon
                (deallocate (simple:image node))))))
    (traverse (credits credits))))

(defmethod handle ((ev tick) (panel credits))
  (let* ((extent (alloy:bounds (credits panel)))
         (ideal (or (ideal panel) (setf (ideal panel) (alloy:pxh (alloy:suggest-bounds extent (credits panel)))))))
    (setf (game-speed +main+) (if (retained 'skip) 10.0 1.0))
    (alloy:with-unit-parent (alloy:layout-element panel)
      (setf (alloy:bounds (credits panel)) 
            (alloy:px-extent (alloy:pxx extent)
                             (- (offset panel) ideal)
                             (alloy:vw 1)
                             ideal))
      (incf (offset panel) (* (alloy:to-px (alloy:un 100)) (dt ev)))
      (when (< (+ ideal (height *context*)) (offset panel))
        (hide panel)))))

(defmethod handle :after (ev (panel credits))
  (when (typep ev '(or back toggle-menu))
    (hide panel)))

(defmethod from-markless (path layout)
  (from-markless (cl-markless:parse path T) layout))

(defmethod from-markless ((markless cl-markless-components:root-component) layout)
  (let ((renderer (unit 'ui-pass T)))
    (labels ((traverse (element)
               (typecase element
                 (cl-markless-components:header
                  (alloy:enter (make-instance 'header :value (cl-markless-components:text element)
                                                      :level (cl-markless-components:depth element))
                               layout))
                 (cl-markless-components:image
                  (let ((image (simple:request-image renderer (pool-path 'kandria (cl-markless-components:target element)))))
                    (allocate image)
                    (alloy:enter (make-instance 'icon :value image) layout)))
                 (cl-markless-components:paragraph
                  (alloy:enter (make-instance 'paragraph :value (cl-markless-components:text element)) layout))
                 (cl-markless-components:parent-component
                  (loop for child across (cl-markless-components:children element)
                        do (traverse child)))
                 (string
                  (alloy:enter (make-instance 'paragraph :value element) layout)))))
      (traverse markless))))

(defmethod initialize-instance :after ((panel credits) &key (file "CREDITS.mess"))
  (let* ((layout (make-instance 'credits-layout))
         (credits (make-instance 'alloy:vertical-linear-layout
                                 :layout-parent layout
                                 :min-size (alloy:size (alloy:vw 1) 100)
                                 :cell-margins (alloy:margins 10))))
    (setf (credits panel) credits)
    (from-markless (merge-pathnames file (root)) credits)
    (alloy:finish-structure panel layout layout)))
