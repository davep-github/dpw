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

(defconst dp-info-path-var 'Info-default-directory-list
  "Info dir list var we want to add our info dirs to.")

(defun dp-set-font-lock-defaults (mode-symbol defaults)
  (setq font-lock-defaults defaults))

(defun dp-colorize-buffer-if-readonly (&optional color uncolorize-if-rw-p)
  "XXX!!! Need to recast my colorization in Emacs' overlays, etc."
  (interactive "P")
  (message "dp-colorize-buffer-if-readonly: no colorization yet."))

(defun dp-colorize-buffer-if-remote (&optional color buf)
  "XXX!!! Need to recast my colorization in Emacs' overlays, etc."
  (interactive "P")
  (message "dp-colorize-buffer-if-remote: no colorization yet."))

;;;
;;;
;;;
(provide 'dp-fsf-early)
(message "dp-fsf-early loading...done")

