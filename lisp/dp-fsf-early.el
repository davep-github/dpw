;;;
;;; $Id: dp-fsf-early.el,v 1.5 2002/01/27 08:30:12 davep Exp $
;;;
;;; FSF emacs only stuff that can or must be loaded
;;; early in the startup sequence.
;;;

(message "dp-fsf-early loading...")

;;(defvar directory-sep-char ?/)
;;(require 'setup-paths))
;; need this to automagically use font-lock-mode everywhere.
(global-font-lock-mode t)

(defun remassoc (key alist)
  (delete* key alist :test #'equal
           :key (if key #'car-safe #'car-or-not-nil)))

(defconst dp-info-path-var 'Info-default-directory-list
  "Info dir list var we want to add our info dirs to.")

;;
;; FSF Emacs puts font lock info into buffer local var `font-lock-defaults'
;; Which is then, somehow, put into the various buffer local font lock
;; variables.
;; 
(defun dp-set-font-lock-defaults (mode-symbol defaults)
  (set (make-local-variable 'font-lock-defaults) defaults))

(defun dp-ssh-mode-hook () ;<:ssh:>
  (setq ssh-directory-tracking-mode t)
  (shell-dirtrack-mode t)
  (setq dirtrackp nil))

(defun dp-home-and-kill-line ()
  "Implemention of `dp-delete-entire-line' when in the minibuffer.
`dp-line-boundaries' ends up inside the prompt part of the
minibuffer which is read only and so generates an error."
  (interactive)
  (beginning-of-line)
  (dp-delete-to-end-of-line))

;;;
;;;
;;;
(provide 'dp-fsf-early)
(message "dp-fsf-early loading...done")
