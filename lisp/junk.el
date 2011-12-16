;; 'name 'corresponding-sym list-of-extensions dirs-in-which-to-look
;; if 'corresponding-sym is callable, 
;; then it will return the 'corresponding-sym
(defstruct dp-file-correspondence-info
  ;;
  ;; Should make this many -> many
  ;;
  (s->i-list-description "")
  ;; lists are ordered. fcfs.
  (src-extensions nil)
  (src->include-list nil)
  (src->include-func nil)               ; plist by src extension.
  
  (i->s-list-description "")
  (include-extensions nil)
  (include-extensions->d-list nil)      ; plist by include extension.
  (include-extensions->d-func nil)
  
)

(defun dp-set-cross-to-plist (l1 l2)
  (let (olist)
    (mapcar (lambda (l1e)
              (mapcar (lambda (l2e)
                        (setq olist (append olist (list l1e l2e)))
                        (cons l1e l2e))
                      l2))
            l1)
    olist))

(defvar dp-c++-extensions '("cxx" "c++" "cc" "tcc" "cpp")
  "All known -- to me -- c++ file extensions.")

(defvar dp-c++-include-extensions '("h" "hh" "h++" "hpp" "hpp")
  "All known -- to me -- c++ include file extensions.")

(defvar dp-file-correspondence-info-list
  (list
   (make-dp-file-correspondence-info
    :s->i-list-description "c to h"
    :src-extensions '("c")
    :include-extensions '("h")
    :src->include-list '("c" "h")
    :include->src-list '("h" "c"))

   (make-dp-file-correspondence-info
    :s->i-list-description "c++ to h"
    :src-extensions dp-c++-extensions
    :include-extensions dp-c++-include-extensions
    :src->include-list (dp-set-cross-to-alist dp-c++-extensions 
                                              dp-c++-include-extensions)

    :include->src-list (dp-set-cross-to-alist dp-c++-include-extensions
                                              dp-c++-extensions)
   
    )
  ))
