(in-package #:org.shirakumo.fraf.kandria.dialogue)

(defclass request () ())

(defclass input-request (request) ())

(defclass target-request (request)
  ((target :initarg :target :reader target)))

(defclass text-request ()
  ((text :initarg :text :reader text)
   (markup :initarg :markup :reader markup)))

(defmethod print-object ((request text-request) stream)
  (print-unreadable-object (request stream :type T :identity T)
    (format stream "~s" (text request))))

(defclass choice-request (input-request)
  ((choices :initarg :choices :reader choices)
   (targets :initarg :targets :reader targets)))

(defmethod print-object ((request choice-request) stream)
  (print-unreadable-object (request stream :type T :identity T)
    (format stream "~s" (choices request))))

(defclass confirm-request (input-request target-request text-request)
  ())

(defclass emote-request (text-request target-request)
  ((emote :initarg :emote :reader emote)))

(defmethod print-object ((request emote-request) stream)
  (print-unreadable-object (request stream :type T :identity T)
    (format stream "~s" (emote request))))

(defclass pause-request (text-request target-request)
  ((duration :initarg :duration :reader duration)))

(defmethod print-object ((request pause-request) stream)
  (print-unreadable-object (request stream :type T :identity T)
    (format stream "~fs" (duration request))))

(defclass source-request (target-request)
  ((name :initarg :name :reader name)))

(defclass end-request (request)
  ())

(defclass vm ()
  ((instructions :initform () :accessor instructions)
   (text-buffer :initform (make-string-output-stream) :reader text-buffer)
   (choices :initform () :accessor choices)
   (markup :initform () :accessor markup)))

(defgeneric execute (instruction vm ip))

(defmethod text ((vm vm))
  (let ((string (get-output-stream-string (text-buffer vm))))
    (write-string string (text-buffer vm))
    string))

(defmethod pop-text ((vm vm))
  (values (get-output-stream-string (text-buffer vm))
          (shiftf (markup vm) ())))

(defmethod run (assembly (vm (eql T)))
  (run assembly (make-instance 'vm)))

(defmethod run ((assembly assembly) (vm vm))
  (setf (instructions vm) (instructions assembly))
  (reset vm))

(defmethod run ((string string) (vm vm))
  (run (compile* string T) vm))

(defmethod reset ((vm vm))
  (get-output-stream-string (text-buffer vm))
  (setf (markup vm) ())
  (setf (choices vm) ())
  vm)

(defmethod resume ((vm vm) ip)
  (catch 'suspend
    (loop with instructions = (instructions vm)
          while (< ip (length instructions))
          do (setf ip (execute (aref instructions ip) vm ip)))
    (make-instance 'end-request)))

(defmethod suspend ((vm vm) return)
  (throw 'suspend return))

(defmethod execute ((instruction noop) (vm vm) ip)
  (1+ ip))

(defmethod execute ((instruction jump) (vm vm) ip)
  (target instruction))

(defmethod execute ((instruction text) (vm vm) ip)
  (write-string (text instruction) (text-buffer vm))
  (1+ ip))

(defmethod execute ((instruction confirm) (vm vm) ip)
  (multiple-value-bind (text markup) (pop-text vm)
    (suspend vm (make-instance 'confirm-request
                               :target (1+ ip)
                               :markup markup
                               :text text))))

(defmethod execute ((instruction dispatch) (vm vm) ip)
  (if (funcall (func instruction))
      (first (targets instruction))
      (second (targets instruction))))

(defmethod execute ((instruction conditional) (vm vm) ip)
  (loop for (func . target) in (clauses instruction)
        do (when (funcall func)
             (return target))))

(defmethod execute ((instruction choose) (vm vm) ip)
  (let ((choices (nreverse (shiftf (choices vm) ()))))
    (suspend vm (make-instance 'choice-request
                               :choices (mapcar #'car choices)
                               :targets (mapcar #'cdr choices)))))

(defmethod execute ((instruction commit-choice) (vm vm) ip)
  (let ((choice (get-output-stream-string (text-buffer vm))))
    (when (string/= "" choice)
      (push (cons choice (target instruction))
            (choices vm))))
  (1+ ip))

(defmethod execute ((instruction eval) (vm vm) ip)
  (funcall (func instruction))
  (1+ ip))

(defmethod execute ((instruction begin-mark) (vm vm) ip)
  (push (list (markup instruction) (file-position (text-buffer vm)) NIL)
        (markup vm))
  (1+ ip))

(defmethod execute ((instruction end-mark) (vm vm) ip)
  (setf (third (first (markup vm)))
        (file-position (text-buffer vm)))
  (1+ ip))

(defmethod execute ((instruction placeholder) (vm vm) ip)
  (princ (funcall (func instruction))
         (text-buffer vm))
  (1+ ip))

(defmethod execute ((instruction emote) (vm vm) ip)
  (multiple-value-bind (text markup) (pop-text vm)
    (suspend vm (make-instance 'emote-request
                               :emote (emote instruction)
                               :target (1+ ip)
                               :markup markup
                               :text text))))

(defmethod execute ((instruction pause) (vm vm) ip)
  (multiple-value-bind (text markup) (pop-text vm)
    (suspend vm (make-instance 'pause-request
                               :duration (duration instruction)
                               :target (1+ ip)
                               :markup markup
                               :text text))))

(defmethod execute ((instruction source) (vm vm) ip)
  (suspend vm (make-instance 'source-request
                             :target (1+ ip)
                             :name (name instruction))))
