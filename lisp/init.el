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

;;
;; Since I don't know how to bail from a file being `require'd or `load'd,
;; I'll make a very small if to get what I need.
;; sigh.
(if (getenv "DP_NO_DP_LISP_INIT")
    (message "init.el...env var DP_NO_DP_LISP_INIT exists, skipping.")
  (defvar dp-lisp-dir
    (if (featurep 'xemacs)
	(expand-file-name "~/xlisp/")
      (expand-file-name "~/flisp/")))
  (unless (featurep 'xemacs)
    (if (version< emacs-version "27.0.0")
	(package-initialize)))
  (add-to-list 'load-path dp-lisp-dir)
  (load "dp-init"))

(message "init.el...done")
