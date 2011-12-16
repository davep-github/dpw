
(defvar dp-c++-extensions '("cxx" "c++" "cc" "tcc" "cpp")
  "All known -- to me -- c++ extensions")

(defvar dp-c++-include-extensions '("h" "hh" "h++" "hpp" "hpp") 
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
  (from-list nil)
  (to-path nil)
  (map-to-list nil)
  (map-to-func nil))
  
;;exp;   (i->s-list-description "")
;;exp;   (include-extensions nil)
;;exp;   (include-extensions->src-extensions-path nil)
;;exp;   (include-extensions->src-extensions-list nil)
;;exp;   (include-extensions->src-extensions-func nil)
;;exp; )

;;(concat (cadr l) "/" file-name "." (car l)))
(defvar dp-cf-default-name-format "%s/%s.%s"
  "How to `format' file name parts into a file name.")

(defvar dp-cf-map-to-list
  (list 
   (make-dp-cf-file-info
    :description "c++ src to inc"
    ;; lists are ordered. fcfs.
    :from-list dp-c++-extensions
    :to-path dp-cf-inc-search-path
    :map-to-list (dp-distribute-lists dp-c++-extensions 
                                      dp-c++-include-extensions)
    :map-to-func nil)
   
   (make-dp-cf-file-info
    :description "c++ src to inc"
    ;; lists are ordered. fcfs.
    :from-list dp-c++-include-extensions
    :to-path dp-cf-src-search-path
    :map-to-list (dp-distribute-lists dp-c++-include-extensions 
                                       dp-c++-extensions)
    :map-to-func nil))
  "Corresponding file info list. Eg .c -> .h, .h -> .c")

(defun* dp-ext-to-cf-info (ext &optional (fci-list dp-cf-map-to-list))
  (loop for fci in fci-list do
    (let ((l (or (and (dp-cf-info-map-to-func fci)
                   (funcall dp-cf-map-to-func))
                (dp-cf-map-to-list fci))))
      (when (assoc ext l)
        (return (list (cadr (assoc ext l)) ext fci l))))))

(defun* dp-cross-file-name-and-dirs (file-name ext 
                                     &optional
                                     path
                                     (new-name-format dp-cf-default-name-format))
  (let* ((cf-xi (dp-ext-to-cf-info ext))
         (cfi (nth 2 cf-xi))
         (path (or path (funcall dp-cf-file-info-func cfi)))
         (cf-ext-list (car cf-xi)))
         (when cf-ext-list
           (mapcar (lambda (l)
                     (format new-name-format
                             (cadr l) file-name (car l)))
                   (dp-set-cross-to-alist cf-ext-list path)))))
  
(defun* dp-find-cf (file-name ext 
                   &optional 
                   (path dp-cf-search-path)
                   (new-name-format dp-cf-default-name-format))
  "Find the FILE-NAME's corresponding file based on EXT. 
Primary motivation was: x.c <-->x.h
It will search \"standard\" places for a match to FILE-NAME's counterpart.

If no counterpart is found, return a completion list suitable and useful for
handing to a completing read."
  (let* ((existing-path (dp-path-filter-existing path))
         (first-cf-ext (caar (dp-ext-to-cf-info ext)))
         (all-names (dp-cross-file-name-and-dirs
                     file-name ext existing-path new-name-format)))
    (loop for fname in all-names
      when (file-exists-p fname)
      return fname
      ;; We found nothing. Create the most desirable default.
      finally return (cons (format new-name-format
                                   (car existing-path) ; first existing dir
                                   file-name
                                   first-cf-ext) ; first extension
                           '<<not-found:try-this))))

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
