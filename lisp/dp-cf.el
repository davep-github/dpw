(defconst dp-c-source-file-extensions '("cxx" "cc" "c" "c++" "C" "tcc" "cpp"
                                        "inl" "impl" "tcc")
  "Name says it all.")

(defconst dp-c-include-file-extensions '("h" "hh" "hxx" "h++" "H" "thh" "hpp")
  "Name says it all.")

(defconst dp-c-source-file-extension-regexp
  (concat "\\." 
          (dp-regexp-concat dp-c-source-file-extensions 'group-all-p 'quote-p)
          "$")
  "Regexp to recognize c source file names.")

(defconst dp-c-include-file-extension-regexp
  (concat "\\." 
          (dp-regexp-concat dp-c-include-file-extensions 'group-all-p 'quote-p)
          "$")
  "Regexp to recognize c include file names.")

(defun dp-c*-src-file-p (file-name)
  (interactive)
  (string-match dp-c-source-file-extension-regexp file-name))

(defun dp-c*-inc-file-p (file-name)
  (interactive)
  (string-match dp-c-include-file-extension-regexp file-name))

(defun dp-c*-code-file-p (file-name)
  (or (dp-c*-src-file-p file-name)
      (dp-c*-inc-file-p file-name)))
;; Easier to play with two negated test chunks that an (if)
(defun dp-distribute-lists (l1 l2)
  (let (olist)
    (mapcar (lambda (l1e) 
              (setq olist 
                    (cons (list l1e l2) olist)))
            l1)
    olist))

(defun dp-set-cross-to-plist (l1 l2)
  (let (olist)
    (mapcar (lambda (l1e)
              (mapcar (lambda (l2e)
                        (setq olist (append olist (list l1e l2e))))
                      l2))
            (if (listp l1) l1 (list l1)))
    olist))

(defun dp-set-cross-to-alist (l1 l2)
  (nreverse
   (let (olist)
     (mapcar (lambda (l1e)
               (mapcar (lambda (l2e)
                         (setq olist (cons (list l1e l2e) olist)))
                       l2))
             (if (listp l1) l1 (list l1)))
     olist)))

(defun dp-path-filter (path pred)
  (delq nil
        (mapcar (lambda (p)
                  (when (funcall pred p)
                    p))
                path)))


(defvar dp-c++-extensions '("cxx" "c++" "cc" "tcc" "cpp" "c")
  "All known -- to me -- c++ extensions.
And a plain old C extension.")

(defvar dp-c++-include-extensions '("h" "hh" "hxx" "h++" "hpp" "hpp") 
  "All known -- to me -- c++ include file extensions")

(defvar dp-cf-inc-search-path '("../include" "../h" "./inc" "./include" "./h"
                                "./inc" "../../include" "../../h"
                                "../../inc" "."))

(defvar dp-cf-src-search-path '("../src" "../source" "../code" "../../src"
                                "../../source" "../../code" "./src" "./source"
                                "./code" "."))

(defstruct dp-cf-file-info
  ;;
  ;; Should make this many -> many
  ;;
  (description "")
  (from-ext-list nil)
  (to-ext-list nil)
  (to-path nil)
  (map-to-list nil)
  (map-to-func nil))

;;(concat (cadr l) "/" file-name "." (car l)))
(defvar dp-cf-default-name-format "%s/%s.%s"
  "How to `format' file name parts into a file name.")

(defvar dp-cf-map-to-list
  (list 
   (make-dp-cf-file-info
    :description "c++ src to inc"
    ;; lists are ordered. fcfs.
    :from-ext-list dp-c++-extensions
    :to-ext-list dp-c++-include-extensions
    :to-path dp-cf-inc-search-path
    :map-to-list (dp-distribute-lists dp-c++-extensions 
                                      dp-c++-include-extensions)
    :map-to-func nil)
   
   (make-dp-cf-file-info
    :description "c++ inc to src"
    ;; lists are ordered. fcfs.
    :from-ext-list dp-c++-include-extensions
    :to-ext-list dp-c++-extensions
    :to-path dp-cf-src-search-path
    :map-to-list (dp-distribute-lists dp-c++-include-extensions 
                                      dp-c++-extensions)
    :map-to-func nil))
  "Corresponding file info list. Eg .c -> .h, .h -> .c")

(defun* dp-ext-to-cf-info (ext &optional (fci-list dp-cf-map-to-list))
  (loop for fci in fci-list do
    (let ((l (or (and (dp-cf-file-info-map-to-func fci)
                      (funcall dp-cf-map-to-func))
                 (dp-cf-file-info-map-to-list fci))))
      (when (assoc ext l)
        (return (list (cadr (assoc ext l)) ext fci l))))))

(defun* dp-cross-file-name-and-dirs (file-name ext 
                                     &optional
                                     cf-search-path
                                     (new-name-format dp-cf-default-name-format))
  "Create a list of all corresponding file names using FILE-NAME EXT and PATH.
Every possible extension in every possible dir in PATH."
  (let* ((cf-xi (dp-ext-to-cf-info ext))
         (cfi (nth 2 cf-xi))
         (path (or cf-search-path (funcall dp-cf-file-info-func cfi)))
         (cf-ext-list (dp-cf-file-info-to-ext-list cfi)))
    (when cf-ext-list
      (mapcar (lambda (l)
                (format new-name-format
                        (cadr l) file-name (car l)))
              (dp-set-cross-to-alist cf-ext-list path)))))

(defun dp-cf-edit-cf (file-name)
  "Find the file corresponding to the given file name."
  (let* ((path (file-name-directory (file-truename file-name)))
         (name (file-name-sans-extension (file-name-nondirectory file-name)))
         ;;(name "")
         (ext (file-name-extension file-name)))
    (list path name ext)
    ))


;; Get PATH based on EXT
;; (dp-cf-file-info-to-path (nth 2 (dp-ext-to-cf-info "c++")))
(defun* dp-corresponding-file-name (&optional file-name
                    search-path
                    (new-name-format dp-cf-default-name-format))
  "Find the FILE-NAME's corresponding file based on EXT. 
Primary motivation was: x.c <-->x.h
It will search \"standard\" places for a match to FILE-NAME's counterpart.

If no counterpart is found, return a completion list suitable and useful for
handing to a completing read."
  (setq file-name (file-relative-name (or file-name
                                          (buffer-file-name))))
  (or (dp-fixed-corresponding-file-name file-name) 
      (let* ((path (file-name-directory file-name))
             (just-name (file-name-sans-extension 
                         (file-name-nondirectory file-name)))
             (ext (file-name-extension file-name))
             (cf-xi (dp-ext-to-cf-info ext)))
        (if cf-xi
            (let* ((cfi (nth 2 cf-xi))
                   (existing-path (dp-path-filter:existing 
                                   (or search-path 
                                       (dp-cf-file-info-to-path cfi))))
                   (first-cf-ext (caar cf-xi))
                   (all-names (dp-cross-file-name-and-dirs
                               just-name ext existing-path new-name-format)))
              (loop for fname in all-names
                when (file-exists-p fname)
                return fname
                ;; We found nothing. Create the most desirable default.
                finally return (dp-mk-completion-list 
                                (cons (cons
                                       (format new-name-format
                                        ; First existing dir in path.
                                               (car existing-path) 
                                               just-name
                                               first-cf-ext)
                                       '<<not-found:try-this-first)
                                      all-names))))
          (ding)
          (message "No corresponding file info for \"%s\"" file-name)
          nil))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
;;;
;;; ECF code useful for either version.
;;;

(dp-deflocal dp-ecf-whence-marker nil
  "Marker in file from whence we came to edit this file using `ecf' et.al.")

(defun dp-ecf-return-whence (&optional prompt file)
  (interactive)
  (if dp-ecf-whence-marker
      (dp-goto-marker dp-ecf-whence-marker)
    (dp-find-similar-file (or prompt "Whence-less; file: ") file)))

(defvar dp-ecf-dummy-history-var nil
  "Needed for `completing-read' and friends.")

(dp-deflocal dp-fixed-corresponding-file-names nil
  "Set per file if there is no rhyme/reason for the corresponding file's name.
Eg, via `hack-local-variables', hook, magic.")

(defun dp-fixed-corresponding-file-name (&optional file-name)
  (or dp-fixed-corresponding-file-names
      (let* ((file-name (file-name-nondirectory (or file-name 
                                                    (buffer-file-name))))
             ;; Non algorithmic correspondence.
             (co-file-a (assoc file-name dp-fixed-corresponding-files))
             (co-file-r (unless co-file-a
                          (rassoc file-name dp-fixed-corresponding-files))))
        (or (and co-file-a (cdr co-file-a))
            (and co-file-r (car co-file-r))))))
  
;; refs 1 def, 2 calls
(defun dp-find-corresponding-file (&optional file-name find-file-func 
                                   search-re)
  "Edit the corresponding file: *.c-type <--> *.h-type"
  (interactive)
  (setq-ifnil file-name (buffer-file-name)
              find-file-func 'find-file)
  (let ((whence (point-marker))
        (co-file (dp-corresponding-file-name file-name))
        default)
    (when (and co-file (listp co-file))
      ;; No cf found... we got the list of candidates, tho.
      ;; !<@todo XXX Check in buffer list as well.
      ;; !<@todo XXX Put all variants in the history.
      (setq co-file (completing-read "No corresponding file found. File name: "
                                     (cdr co-file) ; completion table
                                     nil ; predicate
                                     nil ; require match
                                     (caar co-file)  ; Initial contents
                                     (progn  ; history
                                       (setq dp-ecf-dummy-history-var
                                             (cdr (append (mapcar 'car co-file)
                                                          file-name-history)))
                                       'dp-ecf-dummy-history-var))))
    (when co-file
      (unless (memq last-command '(ecf ecf2))
        (dp-push-go-back "ecf"))
      (funcall find-file-func co-file)
      (when search-re
        (dp-search-re-with-wrap search-re))
      (setq dp-ecf-whence-marker whence))))

;; 1 def, 2 refs
(defvar dp-fixed-corresponding-files nil
  "Alist of fixed corresponding files.  Bidirectional.  car-->cdr, cdr-->car")

(defun dp-add-corresponding-file-pair (file1 file2)
  (let ((new-pair (cons file1 file2)))
    (unless (member new-pair dp-fixed-corresponding-files)
      (setq dp-fixed-corresponding-files (cons new-pair
                                               dp-fixed-corresponding-files)))))

(dp-add-corresponding-file-pair "dpmisc.el" "dpmacs.el")

(defun dp-edit-corresponding-file (&optional find-symbol-p find-file-func)
  "Call `dp-find-corresponding-file' using `find-file' for FIND-FILE-FUNC.
1 C-u says look for symbol at point in the current file, in the new file.
2 C-u says set dp-ecf-whence-marker to nil."
  (interactive "P")
  (when (C-u-p 2 find-symbol-p)
    (setq dp-ecf-whence-marker nil
          find-symbol-p t))
  (dp-find-corresponding-file nil (or find-file-func 'dp-find-file-this-window)
                              (when find-symbol-p
                                (format "\\<\\(%s\\)\\>" 
                                        (symbol-near-point)))))
(defalias 'ecf 'dp-edit-corresponding-file)

(defun dp-edit-cf-other-window (&optional find-symbol-p)
  "Call `dp-edit-corresponding-file' using `find-file-other-window'."
  (interactive "P")
  (dp-edit-corresponding-file find-symbol-p 'dp-find-file-other-window))
;;  (dp-edit-corresponding-file file-name 'find-file-other-window))
(dp-defaliases 'ecf2 'ecw 'ecow 'dp-edit-cf-other-window)

(defun dp-edit-cf-other-frame (&optional file-name)
  "Call `dp-edit-corresponding-file' using `find-file-other-frame'."
  (interactive)
  (dp-edit-corresponding-file file-name 'find-file-other-frame))
(defalias 'ecof 'dp-edit-cf-other-frame)

(provide 'dp-cf)
