(in-package #:org.shirakumo.fraf.kandria)

(defvar *per-language-cached-dialogue-assemblies* (make-hash-table :test 'equal))
(defvar *cached-dialogue-assemblies* (make-hash-table :test 'equal))

(defgeneric extract-language (thing))
(defgeneric refresh-language (thing))

(defun useful-language-string-p (thing)
  (and thing (string/= "" thing) (string/= "-" thing) (string/= "<unknown>" thing)))

(defun %langname (thing &rest subset)
  (intern (format NIL "~:@(~a~{/~a~}~)" (string thing) subset)
          (symbol-package thing)))

(defmethod extract-language ((storyline quest:storyline))
  (reduce #'append (sort (loop for quest being the hash-values of (quest:quests storyline)
                               when (visible-p quest)
                               append (extract-language quest))
                         #'string< :key #'car)))

(defmethod extract-language ((quest quest:quest))
  (list*
   (when (useful-language-string-p (quest:title quest))
     (list (%langname (quest:name quest) 'title) (quest:title quest)))
   (when (useful-language-string-p (quest:description quest))
     (list (%langname (quest:name quest) 'description) (quest:description quest)))
   (loop for task being the hash-values of (quest:tasks quest)
         append (extract-language task))))

(defmethod extract-language ((task quest:task))
  (list*
   (when (and (visible-p task) (useful-language-string-p (quest:title task)))
     (list (%langname (quest:name (quest:quest task)) (quest:name task) 'title) (quest:title task)))
   (when (and (visible-p task) (useful-language-string-p (quest:description task)))
     (list (%langname (quest:name (quest:quest task)) (quest:name task) 'description) (quest:description task)))
   (loop for task being the hash-values of (quest:triggers task)
         append (extract-language task))))

(defmethod extract-language ((trigger quest:trigger))
  (when (useful-language-string-p (quest:title trigger))
    (list (list (%langname (quest:name (quest:quest (quest:task trigger)))
                           (quest:name (quest:task trigger))
                           (quest:name trigger))
                (quest:title trigger)))))

(defmethod refresh-language ((storyline quest:storyline))
  (loop for quest being the hash-values of (quest:quests storyline)
        do (refresh-language quest)))

(defmethod refresh-language ((quest quest:quest))
  (let ((title (language-string* (quest:name quest) 'title)))
    (when title (setf (quest:title quest) title)))
  (let ((description (language-string* (quest:name quest) 'description)))
    (when description (setf (quest:description quest) description)))
  (loop for task being the hash-values of (quest:tasks quest)
        do (refresh-language task)))

(defmethod refresh-language ((task quest:task))
  (let ((title (language-string* (quest:name (quest:quest task)) (quest:name task) 'title)))
    (when title (setf (quest:title task) title)))
  (let ((description (language-string* (quest:name (quest:quest task)) (quest:name task) 'description)))
    (when description (setf (quest:description task) description)))
  (loop for trigger being the hash-values of (quest:triggers task)
        do (refresh-language trigger)))

(defmethod refresh-language ((trigger quest:trigger))
  (let ((title (language-string* (quest:name (quest:quest (quest:task trigger)))
                                 (quest:name (quest:task trigger))
                                 (quest:name trigger))))
    (when title (setf (quest:title trigger) title))))

(defmethod refresh-language :after ((interaction interaction))
  (reinitialize-instance interaction))

(defmethod reinitialize-instance :before ((task task) &key)
  ;; Hook for redef, clear out first to make sure we get a fresh assembly.
  ;; KLUDGE: will cause assemblies to get recached for each interaction within the redefined quest, even if shared.
  (loop for trigger being the hash-values of (quest:triggers task)
        do (when (and (typep trigger 'interaction) (source trigger))
             (remhash (string-downcase (first (source trigger))) *cached-dialogue-assemblies*))))

(defun find-mess (name &optional chapter)
  (let* ((name (string-downcase name))
         (assembly (gethash name *cached-dialogue-assemblies*)))
    (unless assembly
      (let ((file (merge-pathnames name (merge-pathnames "quests/a.spess" (language-dir)))))
        (v:debug :kandria.language "Compiling assembly for ~a" file)
        (setf assembly (dialogue:compile* file (make-instance 'assembly)))
        (setf (gethash name *cached-dialogue-assemblies*) assembly)))
    (let ((clone (clone assembly)))
      (when chapter
        (restart-case
            (setf (aref (dialogue:instructions clone) 0)
                  (make-instance 'dialogue:jump :target (or (position chapter (dialogue:instructions clone)
                                                                      :key #'dialogue:label :test #'string-equal)
                                                            (error "No chapter named ~s found in ~a.~%The following chapters are defined: ~{~%  ~a~}"
                                                                   chapter name (remove-if #'null (map 'list #'dialogue:label (dialogue:instructions clone)))))
                                                :index 0))
          (retry ()
            :report "Try reloading the spess file."
            (remhash name *cached-dialogue-assemblies*)
            (find-mess name chapter))))
      clone)))

(defmethod refresh-language ((all (eql T)))
  (setf *cached-dialogue-assemblies*
        (maybe-init-language-cache (language)))
  (setf (default-interactions (storyline +world+))
        (or (gethash 'default-interactions *cached-dialogue-assemblies*)
            (setf (gethash 'default-interactions *cached-dialogue-assemblies*)
                  (load-default-interactions :table (make-hash-table :test 'eql)))))
  (refresh-language (storyline +world+))
  (for:for ((entity over (region +world+)))
    (when (typep entity 'profile)
      (unless (equal (nametag entity) (@ unknown-nametag))
        (setf (nametag entity) (or (language-string (intern (format NIL "~a-~a" (string (type-of entity)) 'nametag) (symbol-package (type-of entity))) NIL)
                                   (nametag entity)))))))

(defmethod refresh-language ((force (eql :force)))
  (clrhash *cached-dialogue-assemblies*)
  (refresh-language T))

(defun maybe-init-language-cache (&optional (language (language)))
  (or (gethash language *per-language-cached-dialogue-assemblies*)
      (let* ((tab (make-hash-table :test 'equal))
             (defaults (make-hash-table :test 'eql))
             (*cached-dialogue-assemblies* tab))
        (v:info :kandria.language "Refreshing language cache for ~a" language)
        (setf (gethash 'default-interactions tab) defaults)
        (load-language :language language)
        (load-default-interactions :table defaults :language language)
        (refresh-language (quest:storyline T))
        (setf (gethash language *per-language-cached-dialogue-assemblies*) tab))))

(define-language-change-hook refresh-quests (language)
  (when (and +world+ (storyline +world+))
    (refresh-language T)))

(defun count-all-words (dir &optional (method :whitespace))
  (let ((count 0))
    (dolist (file (directory (merge-pathnames "**/*.spess" dir)))
      (incf count (cl-markless:count-words (dialogue:parse file) method)))
    (dolist (file (directory (merge-pathnames "**/*.sexp" dir)) count)
      (with-open-file (stream file)
        (loop for token = (read stream NIL NIL)
              while token
              do (when (typep token 'string)
                   (incf count (cl-markless:count-words-by method token))))))))
