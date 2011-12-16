;;;
;;; $Id: dp-mhe.el,v 1.5 2001/12/31 08:30:13 davep Exp $
;;;
;;; configure mhe mailer.
;;; this is only used if the primary mailer (mew) cannot
;;; be found... 'ware the bit-rot!
;;;

(require 'mh-comp)

(defconst dp-mail-header-terminator "^--------$"
  "RE to find end of mail headers.")

(global-set-key "\C-cr" 'mh-rmail)
(global-set-key "\C-xm" 'mh-smail)
(global-set-key "\C-x4m" 'mh-smail-other-window)

(setq mh-inc-folder-hook 'dp-rmail)
(add-hook 'mail-setup-hook 'dp-mail-mode-hook)
(add-hook 'mh-letter-mode-hook 'dp-mail-mode-hook)
(add-hook 'mh-letter-mode-hook 'dp-mh-letter-mode-hook)
(add-hook 'mh-show-mode-hook 'dp-mh-show-mode-hook)
(add-hook 'mh-folder-mode-hook 'dp-mh-folder-mode-hook)
(setq mh-compose-letter-function 'dp-mh-compose-letter-function)

(defun dp-mh-compose-letter-function (to subject cc)
  "Prepare to compose a letter.
We want to determine where to place our fcc based on the 
TO, SUBJECT and CC.
Map to and/or cc fields to a list of fcc folders.
Find and modify or insert an fcc header into the current buffer."
  (interactive)
  (let ((fcc-list (dp-map-hdrs-to-fcclist to subject cc dp-fcc-alist)))
    (if fcc-list
	(let ((fcc-val (dp-string-join fcc-list ", ")))
	  (dp-replace-fcc fcc-val dp-mail-header-terminator)))))
	  
;;
;; mail mode hook functions
;;
(defun dp-mail-mode-hook ()
  "Set up mail mode *my* way :-)"
  (mail-abbrevs-setup)
  ;; @todo... try it on since the global abbrev table only has typos in it.
  (abbrev-mode 1))

(defun dp-mh-letter-mode-hook ()
  "Append separator and signature file (mh-signature-file-name)
to mail message."
  (interactive)
  (dp-maybe-insert-sig))

(defun dp-mh-show-mode-hook ()
  "Set up some useful key bindings."
  (interactive)
  (local-set-key "\e." 'find-file-at-point)
  (local-set-key "\em" 'dp-metamail))

(defun dp-mh-folder-mode-hook ()
  "Perpetuate my non-standard bindings..."
  (interactive)
  (local-set-key "\ee" 'find-file)
  (local-set-key "\ea" 'dp-toggle-mark)
  (local-set-key "\eb" 'dp-buffer-menu))

(defun dp-rmail ()
  "Read the last few mail messages.  Since at CRL,  linux is 
not allowed to mount the mail spool, I need to rsh an inc command 
on another machine.
That means mh-rmail doesn't know about the new mail, so I need to do
an mh-visit-folder into the inbox for the last few messages."
  (interactive)
  (mh-visit-folder "+inbox" "last:50"))

(provide 'dp-mhe.el)
