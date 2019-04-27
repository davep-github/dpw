;;;
;;; $Id: dp-mew.el,v 1.30 2004/02/08 09:20:13 davep Exp $
;;;
;;; Set us up so that mew is our mailer.
;;; When we use the first mew command, mew will
;;; eval ~/.mew.el --> ~/lisp/dp-dot-mew.el (q.v.)
;;;

(autoload 'mew "mew" "read mail with mew" t)
(autoload 'mew-send "mew" "send mail with mew" nil t)
(autoload 'mew-user-agent-compose "mew" nil t)

(setq mew-rc-file "dp-dot-mew")

;;
;; some mh mailers like to use the name "draft" for drafts and barf
;; if draft is not a plain file.
;; do this before mew loads since it seems to create the dir early in
;; the init sequence
;; it looks like mew is ensuring only the user can the draft dir or file.
;; if a file (or fifo) by the name of draft exists, the mode is set to
;; rwx------
;;
(setq mew-draft-folder "+mew-drafts")

(global-set-key "\C-cr" 'dp-mew)
(global-set-key "\C-xm" 'mew-send)

(when (dp-xemacs-p)
  ;; add us to the internet menu and default menubar
  (defvar dp-mew-menubutton-guts
    [ mew :active (fboundp 'mew)]
    "Menu button to activate mew.")
  ;;
  ;; the button name of `Mew' works out well since it is also the
  ;; name of the menu in the summary buffer, so our button is replaced
  ;; with mew's own submenu.  This is the one place where we don't
  ;; want or need a Mew button.
  (defvar dp-mew-menubar-button (vconcat ["Mew"] dp-mew-menubutton-guts)
    "Mew menubar button.")
  (defvar dp-mew-menu-button
    (vconcat ["%_Read Mail (Mew)"] dp-mew-menubutton-guts)
    "Mew internet menu button.")

  ;; add to Tools->Internet menu
  (add-menu-button '("Tools" "Internet") dp-mew-menu-button
		   "Read Mail 1 (VM)...")

  ;; add to menu-bar
  (add-menu-button nil dp-mew-menubar-button nil default-menubar)
  )

(setq mew-conf-path "~/MH")
(setq mew-mail-path "~/MH")
(setq mew-mailbox-type 'mbox)
(setq mew-mbox-command "true")
(setq mew-mbox-command-arg nil)

(defun dp-mew (&optional arg)
  (interactive "P")
  (if arg
      (delete-other-windows))
  (mew))

(message "dp-mew: mew loaded.")


(provide 'dp-mew)
