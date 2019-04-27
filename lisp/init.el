;; -*-emacs-lisp-*-
;; $Id: init.el,v 1.3 2002/07/28 04:45:06 davep Exp $


;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
;; This is done in fsf-init.el.  I *moved* it there, but it came back.
;;      |
;;     ---
;;      |
;;      |
;; No undead code!

(message "init.el...")

(defvar dp-lisp-dir
  (if (featurep 'xemacs)
      (expand-file-name "~/xlisp/")
    (expand-file-name "~/flisp/")))
(unless (featurep 'xemacs)
  (if (version< emacs-version "27.0.0")
      (package-initialize)))

(add-to-list 'load-path dp-lisp-dir)

(defun dp-lisp-subdir (sub &rest args)
  (expand-file-name (apply 'format sub args) dp-lisp-dir))

(defun dp-hostname (&optional default)
  "Get a hostname, whatever the system gives us."
  (or (getenv "HOSTNAME")
      (shell-command-to-string "hostname")
      (or default "***LOCALHOST***")))

(defun dp-short-hostname ()
  (or (getenv "HOST")
      (car (split-string-by-char
	    (dp-hostname)
	    ?.))))

(defun dp-hostify-name (format-str)
  "Add a host specific part to a name."
  (format format-str (dp-short-hostname)))

(defun dp-userfy-name (format-str)
  "Add a user specific part to a name."
  (format format-str (user-login-name)))

(when (featurep 'emacs)
  (load-library "fsf-early-init"))

;; no blah, blah, blah.
(setq inhibit-startup-message t)

;; for debuggin'...
(setq dp-orig-load-path load-path)

; (add-to-list 'dp-auto-mode-alist-additions '("\\.wy$" . wisent-grammar-mode))
; (add-to-list 'dp-auto-mode-alist-additions '("\\.by$" . bovine-grammar-mode))

;; so we can get to my lisp files
;; we're consing, so last will be first.
(defvar dp-init.el-load-path-dirs
  (list
   ;; Move amd location to home.
   ;; Just keep them both, but give preference to my home.
   ;; If there are problems, predicate them
   "/home/davep/local/share/emacs/site-lisp/mu4e" ; home
   "/usr/share/emacs/site-lisp/mu4e"	; amd
   (dp-lisp-subdir "contrib")
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
    ;; (message "l>%s<" l)
    (add-to-list 'load-path (car l))
    ;; (message "load-path>%s<" load-path)
    (setq l (cdr l))))

;; load the bulk of the init file...
(load "dpmacs")
(put 'narrow-to-region 'disabled nil)

(message "init.el...done")
