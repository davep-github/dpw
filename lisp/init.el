;; -*-emacs-lisp-*-
;; $Id: init.el,v 1.3 2002/07/28 04:45:06 davep Exp $

(message "in init.el")
;; no blah, blah, blah.
(setq inhibit-startup-message t)

;; for debuggin'...
(setq dp-orig-load-path load-path)

; (add-to-list 'auto-mode-alist '("\\.wy$" . wisent-grammar-mode))
; (add-to-list 'auto-mode-alist '("\\.by$" . bovine-grammar-mode))

;; so we can get to my lisp files
;; we're consing, so last will be first.
(defvar dp-init.el-load-path-dirs
  (list (expand-file-name "~/lisp/contrib")
        (expand-file-name "~/lisp/contrib/emacs-jabber")
        (expand-file-name "~/lisp"))
  "Initial dirs to add to load path.")

;; We're getting dupes:
;; 1) from the ebuild stuff in /usr/lib/xemacs
;; 2) And from my ?COPY? in ~/.xemacs
;;    Why do I have copies of:
;;    mule-packages/
;;    xemacs-packages/
;;
; (setq load-path (delq nil (mapcar 
;                            (function 
;                             (lambda (dir)
;                               (if (posix-string-match "^/usr/lib/xemacs")
;                                   nil
;                                 dir))))))

;; Old-sk00l loop... don't count on cl being loaded yet.
(let ((l dp-init.el-load-path-dirs))
  (while l
    (add-to-list 'load-path (car l))
    (setq l (cdr l))))

;; load the bulk of the init file...
(load "dpmacs")
