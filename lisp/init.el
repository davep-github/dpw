;; -*-emacs-lisp-*-
;; $Id: init.el,v 1.3 2002/07/28 04:45:06 davep Exp $


;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(defvar dp-lisp-dir
  (if (featurep 'xemacs)
      (expand-file-name "~/xlisp")
    (expand-file-name "~/flisp")))

(add-to-list 'load-path dp-lisp-dir)

(defun dp-lisp-subdir (sub &rest args)
  (expand-file-name (apply 'format sub args) dp-lisp-dir))

(unless (featurep 'emacs)
  (require 'fsf-init))

(message "in init.el")
;; no blah, blah, blah.
(setq inhibit-startup-message t)

;; for debuggin'...
(setq dp-orig-load-path load-path)

; (add-to-list 'dp-auto-mode-alist-additions '("\\.wy$" . wisent-grammar-mode))
; (add-to-list 'dp-auto-mode-alist-additions '("\\.by$" . bovine-grammar-mode))

;; so we can get to my lisp files
;; we're consing, so last will be first.
(defvar dp-init.el-load-path-dirs
  (list (dp-lisp-subdir "contrib")
        (dp-lisp-subdir "contrib/emacs-jabber")
        dp-lisp-dir)
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
    (message "l>%s<" l)
    (add-to-list 'load-path (car l))
    (message "load-path>%s<" load-path)
    (setq l (cdr l))))

;; load the bulk of the init file...
(load "dpmacs")
(put 'narrow-to-region 'disabled nil)
