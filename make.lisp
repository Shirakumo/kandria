(asdf:load-system :clip)
(asdf:load-system :drakma)

(defvar *here* #.(or *load-pathname*
                     (error "LOAD this file.")))

(defun file (name type)
  (make-pathname :name name :type type :defaults *here*))

(defun process (in out &rest args)
  (with-open-file (stream out :direction :output
                              :if-exists :supersede)
    (let ((*package* #.*package*))
      (plump:serialize (apply #'clip:process in args) stream))))

(defun process-content (content)
  (let ((plump:*tag-dispatchers* plump:*html-tags*))
    (lquery:$1 (inline (plump:parse content))
      "p" (html))))

(defun max-array (array n)
  (if (<= (length array) n)
      array
      (subseq array 0 n)))

(defun fetch-updates (&optional (url "https://tymoon.eu/api/reader/atom?tag=leaf"))
  (let ((plump:*tag-dispatchers* plump:*xml-tags*)
        (drakma:*text-content-types* '(("application" . "atom+xml"))))
    (lquery:$ (initialize (drakma:http-request url))
      "entry" (map (lambda (entry)
                     (list :title (lquery:$1 entry "title" (text))
                           :url (lquery:$1 entry "link" (attr :href))
                           :time (subseq (lquery:$1 entry "published" (text)) 0 (length "2020-02-04"))
                           :excerpt (process-content (lquery:$1 entry "content" (text)))))))))

(defun make ()
  (process (file "index" "ctml") (file "index" "html")
           :updates (handler-case (max-array (fetch-updates) 3)
                      (usocket:ns-try-again-condition ()))))

(make)
