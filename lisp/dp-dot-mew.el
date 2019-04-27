;;;
;;; $Id: dp-dot-mew.el,v 1.112 2004/04/14 08:20:05 davep Exp $
;;;
;;; ~/.mew.el --> ~/lisp/dp-dot-mew.el (this file)
;;; mew will load this (~/.mew.el) when it
;;; starts up.
;;;

;; try to load w3m for inline viewing of html
;; this is also used for browsing in emacs, so it is autoloaded elsewhere.
(dp-optionally-require 'mew-w3m nil 'verbose)

;; view images with xli
(setq mew-prog-image/*-ext "xli")

(defconst dp-mail-header-terminator "^--------$"
  "Regular expression used to find end of mail headers.")

(defconst dp-mew-attachments-header
  "------------------------------ attachments ------------------------------")

(defvar dp-mew-prog-agrep-opts '("-l" "-e")
  "*Options to agrep, an approximate grepper.")

(defvar dp-mew-no-fcc "+no fcc")

;; each mailer should provide this variable in some way.
(defvar dp-mail-spamcan "+spamcan"
  "Holding pen for spam.  Will be forwarded later.")

(defvar dp-mail-fwd-spam-idle t
  "*Non-nil if `dp-mail-fwd-spam' is running.
Shouldn't really set this unless something breaks.")

(defun dp-mew-smtp-sentinel-hook ()
  "Called after mail sent to smtp MTA."
  (setq dp-mail-fwd-spam-idle t))

;; each mailer can define this
(defun dp-mail-upchuck-spam (&optional force-p)
  (while (not dp-mail-fwd-spam-idle)
    (message "Can't talk... eating SPAM.  UUuurggllll")
    (ding)
    (sit-for 1))
  (let ((case-fold-search t)
	(dp-mail-file-vs-forward-p (or dp-mail-file-vs-forward-p
				       (not (dp-mail-in-spamcan-p)))))
    (if (or force-p
	    (string-match (concat "|" dp-mail-SPAM-indicator)
			  (let ((p (line-beginning-position)))
			    ;; this is an ugly hack and may only work with
			    ;; mew, although it is likely that other mailers
			    ;; will display the subject in the first 50 chars.
			    (buffer-substring p (min (+ 50 p)
						     (line-end-position)))))
	    (or (not dp-mail-confirm-when-no-SPAM-in-subject)
		(y-or-n-p "No SPAM in subject... process anyway? ")))
	(if dp-mail-file-vs-forward-p
	    (progn
	      (dmessage "refiling message...")
	      (execute-kbd-macro
	       (read-kbd-macro (format "o M-d %s RET" dp-mail-spamcan))))
	  (dmessage "forwarding message...")
	  (setq dp-mail-fwd-spam-idle nil)
	  (execute-kbd-macro
	   (read-kbd-macro "fuce@ftc.gov C-c C-c y <down>"))))))

(defun dp-mew-process-marks-fwd (func &rest func-args)
  "Send all marked messages to the authorities."
  (let ((keep-looping t)
	pt)
    (while keep-looping
      (while (eq (mew-summary-get-mark) ?*)
	(mew-summary-undo-one)
	;;(dmessage "spam @ %s" (point))
	(apply func func-args)

	;; delete when using upchuck.  this is just for testing
	;;(mew-summary-display-review-down)
	)
      (setq pt (point))
      (mew-summary-display-review-down)
      (setq keep-looping (/= pt (point))))))

;;
;; each mailer should provide this functionality in some way.
(defun dp-mail-fwd-marked-spam (&optional from-here-p)
  (interactive "P")
  (unless from-here-p
      (dp-beginning-of-buffer))
  (dp-mew-process-marks-fwd 'dp-mail-upchuck-spam))

;;
;; each mailer should provide this functionality in some way.
(defun dp-mail-mark-spam (&optional entire-buf-p)
  (interactive "P")
  (if entire-buf-p
      (dp-beginning-of-buffer))
  (save-excursion
    (execute-kbd-macro (read-kbd-macro "?sub=*****spam C-m"))))
(defalias 'pick-spam 'dp-mail-mark-spam)

;;
;; each mailer should provide this functionality in some way.
(defun dp-mail-mark-all ()
  (interactive)
  (mew-summary-mark-all))

;;
;; each mailer should provide this functionality in some way.
(defun dp-mail-in-spamcan-p ()
  (interactive)
  (string= (buffer-name) dp-mail-spamcan))

;;
;; HOOKS
(add-hook 'mew-draft-mode-hook  'dp-mew-draft-mode-hook)
(add-hook 'mew-send-hook 'dp-mew-send-hook)
(add-hook 'mew-before-cite-hook 'dp-mew-before-cite-hook)
(add-hook 'mew-summary-mode-hook 'dp-mew-summary-mode-hook)
(add-hook 'mew-message-hook 'dp-mew-message-hook)
(add-hook 'mew-cite-hook 'dp-mew-cite-hook)
(add-hook 'mew-real-send-hook 'dp-mew-real-send-hook)
(add-hook 'mew-smtp-sentinel-hook 'dp-mew-smtp-sentinel-hook)

;;
;; Use this??? Perhaps once I'm used to it.
;; It is kind of nice since I can see the changes send hooks make before
;; sending (which is likely why it exists).
;;(setq mew-ask-send nil)

;;
;; mhe summary format:
;; 9619  02/08 lwesson@pce2000.c  Memory test<<Hi David, This is from the new
;; good enough to copy?  mew has problems displaying body lines in summary.
;;(setq mew-scan-form-list
;;      '((t (type (5 date) "!!! " (14 from) " |" (0 subj)) 28)))
(setq mew-summary-form
      '(type (5 date) " " (14 from) "|" t (30 subj) "|" (0 body)))

(setq mew-use-cursor-mark t)
(setq mew-highlight-cursor-line-face 'bold)

;;
;; -l will help us to be a tad faster and to lower the mem requirements.
(setq mew-prog-grep-opts '("-l" "-e"))

;; they set reply to for a reason...
(setq mew-replyto-to-list '("Reply-To:"))

;;
;; in dp-mew.el now. see comments there.
;;(setq mew-draft-folder "+mew-drafts")

(load "dp-mew-config.el")
(dp-mew-config-set-config)

(setq mew-name (format "\"%s\"" dp-mail-fullname))

(if (boundp 'mail-user-agent)
    (setq mail-user-agent 'mew-user-agent))
(or (boundp 'mew-refile-guess-alist)
    (setq  mew-refile-guess-alist
	   '((nil ("+sent_mail")))))
(if (fboundp 'define-mail-user-agent)
    (define-mail-user-agent
      'mew-user-agent
      'mew-user-agent-compose
      'mew-draft-send-letter
      'mew-draft-kill
      'mew-send-hook))
(setq mail-user-agent 'mew-user-agent)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Code: hooks, support, etc.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun dp-flyspell-mew-draft-mode-p ()
  "Return non-nil if we want to use flyspell at \\(point)."
  (cond
   ((< (point) dp-mail-header-end-marker)
    (save-excursion (beginning-of-line) (looking-at "^Subject:")))
   ((>= (point) dp-sig-start-marker) nil)
   (t t)))

(defun dp-mew-draft-mode-hook  ()
  "Bind keys, append separator and add signature to mail message."
  (interactive)
  (local-set-key [?\C-\ ] 'mew-draft-expand)
  (local-set-key "\e." 'find-file-at-point)
  ;;(dmessage "this-command>%s<" this-command)
  ;;(mail-abbrevs-setup)
  ;; turn off auto abbrev expansion, which the above turns on.
  ;; @todo... try it on since the global abbrev table only has typos in it.
  (abbrev-mode 0)		  ; We use mah MFing abbrevs, MFer.
  ;;(dmessage "buf>%s<" (buffer-name))
  (setq dp-mail-is-a-reply-p (memq this-command
				   '(dp-mew-summary-reply
				     dp-mew-summary-reply-with-citation)))
  (if (and (boundp 'dp-email-composition-abbrevs)
	   dp-email-composition-abbrevs)
      (setq local-abbrev-table dp-email-composition-abbrevs))

  (local-set-key [(control space)]  (kb-lambda
				      (dp-expand-apprev 'mail-aliases)))
  (local-set-key "\C-c\C-f\C-f" 'dp-mew-rewrite-From:-header)
  (local-set-key "\eq" 'dp-fill-paragraph-or-region-preserving-fill-prefix)

  (local-set-key "\C-c\C-c" 'dp-mew-draft-send-message)
  (define-key mew-draft-header-map "\C-c\C-c" 'dp-mew-draft-send-message)

  (set-marker (setq dp-mail-header-end-marker (make-marker)) (mew-header-end))
  (if (dp-using-flyspell-p)
      ;; 'mail-mode-flyspell-verify
      (setq flyspell-generic-check-word-p 'dp-flyspell-mew-draft-mode-p))
  (dp-maybe-insert-sig))

(defun dp-mew-guess-fcc (&optional def-fcc)
  (or (mew-refile-guess-by-alist) (or def-fcc '("+sent_mail"))))

(defun dp-mew-guess-From:-suffix (&optional def-suf)
  (or (car-safe (let ((mew-refile-guess-alist
		       dp-mew-config-From:-rewrite-alist))
		  (mew-refile-guess-by-alist)))
      def-suf))

;;
;; this must be implemented for each mailer in order to support using
;;  replied-to messages' to: addr as a return addr basis.
(defun dp-mail-get-who-message-was-to ()
    (save-excursion
      (set-buffer (mew-buffer-message))
      (save-restriction
	(widen)
	(goto-char (point-min))
	(let ((was-to
	       ;; special case... change dp-mail-get-header-value to
	       ;; use mew's if available, else my simpler one.
	       (dp-mail-get-@ddr (mew-header-get-value "[Tt][oO]:"))))
	  (dmessage "was-to>%s<" was-to)
	  was-to))))

;;
;; this must be implemented for each mailer in order to support using
;;  replied-to messages' to: addr as a return addr basis.
(defun dp-mail-generate-From: (from-suffix)
  "Create a From: value given FROM-SUFFIX.

The value of the from suffix is a dreadful hack.  In order to use mew's
header to folder mapping function (which is *very* useful), we have to return
a string as the result of the mapping.  Mew checks and barfs if it isn't.  So
I create a temp unique var interned into a mail specific obarray and return
its name as a string.  This is then used as the input to this function.  Once
here, the var is `dereferenced' from its name.  BLECCH!
The deref'd value is passed to `dp-mail-generate-From:-given-plist'."
    (dp-mail-generate-From:-given-plist
     (dp-mew-config-get-From:-rewrite-info from-suffix)))

(defun dp-mew-rewrite-From:-header (dont-force-reply)
  (interactive "P")
  ;;(dmessage "dp-mew-rewrite-From:-header, disap>%s<" dp-mail-is-a-reply-p)
  (let ((dp-mail-is-a-reply-p (or (not dont-force-reply)
				  dp-mail-is-a-reply-p)))
    (dp-mail-rewrite-From:-header (dp-mew-guess-From:-suffix))))

(defalias 'rfh 'dp-mew-rewrite-From:-header)

(defun dp-mew-From:-has-changed ()
  (not (string=
	(dp-mail-get-header-value "^[Ff][Rr][Oo][Mm]:")
	(car mew-from-list))))

(defun dp-mew-send-hook ()
  "Send hook.  Compute destination fcc folder by guessing with
`mew-refile-guess-by-alist'.  Compute From: suffix.
Remove any added *****SPAM***** from headers."
  (interactive)
  (let* ((fcc-list (dp-mew-guess-fcc))
	 (fcc-val (dp-string-join fcc-list ", ")))
    ;;(message "fcc-val>%s<" fcc-val)
    ;;(message "fcc-val2>%s<" (mew-refile-guess-by-alist))
    (if (equal fcc-list (list dp-mew-no-fcc))
	(dp-delete-fcc)
      (dp-replace-fcc fcc-val dp-mail-header-terminator))

    (when (and (not dp-mail-skip-rewrite-from)
	       (not (dp-mew-From:-has-changed)))
      (dp-mew-rewrite-From:-header 'dont-force-reply))

    (dp-mail-run-per-recipient-hooks (dp-mail-get-recipients-string)
				     dp-mail-per-recipient-hook-alist)
    (dp-mail-nuke-SPAM-indicator)))

(defun dp-mew-before-cite-hook ()
  "Before cite hook.  Since mew calls draft mode hook before
inserting cited text when using '\\[mew-summary-reply-with-citation]'
\(mew-summary-reply-with-citation), the cited text is placed after the
signature.  This hook positions us to the place that was point-max
before the sig was inserted so the citation goes where it belongs."
  (interactive)
  (if dp-sig-orig-point-max-marker
      (goto-char (marker-position dp-sig-orig-point-max-marker))))

(defun dp-agrep-mew-messages(&optional num-mismatches)
  "Try to use agrep for searching message bodies.
Only does special things if (equal mew-prog-grep \"agrep\").
NUM-MISMATCHES is used to tell us how many mismatches to allow in the
agrep search.  If called with just '\\[universal-argument]',
we set the number of mismatches to 1.  Otherwise uses the value of
'\\[universal-argument]' as a number.
Calls (mew-summary-search-mark 1) after possibly tweaking
mew-prog-grep-opts."
  (interactive "P")
  (when (equal mew-prog-grep "/usr/bin/agrep")
    ;;(message "num-mismatches>%s<" num-mismatches)
    (setq num-mismatches
	  (if num-mismatches
	      (if (listp num-mismatches)
		  ;; \c-u by itself returns '(4)
		  ;; for us, 1 is more convenient
		  1
		num-mismatches)
	    0))				; 0 --> exact match
    ;;(message "num-mismatches>%s<" num-mismatches)
    (setq mew-prog-grep-opts
	  (cons (format "-%d" num-mismatches) dp-mew-prog-agrep-opts))
    (message "agrep-args>%s<" mew-prog-grep-opts))
  ;; do the grep search on message bodies.
  (mew-summary-search-mark 1))

;; @todo move key-bindings into a one-shot hook, or a load hook.
(defun dp-mew-summary-mode-hook ()
  "Bind keys my way.  These are more compatible with other mailers."
  (interactive)
  ;;(message "mew-summary-mode-hook")
  ;; non-standard bindings aweigh!!!!!!!!!!!!
  (local-set-key "\eg" 'dp-agrep-mew-messages)
  (local-set-key "a" 'dp-mew-summary-reply)
  (local-set-key "A" 'dp-mew-summary-reply-with-citation)
  (local-set-key "r" 'dp-mew-summary-reply) ; was 'a' for answer :-(
  (local-set-key "\em" (kb-lambda	; M-m for mark w/*
			 (mew-summary-review)
			 (mew-summary-next-line)))
  (local-set-key "k" 'dp-mew-summary-delete) ; del with no visit of next msg
  (local-set-key "\C-k" 'dp-mew-summary-delete) ; del with no visit of next msg
  (local-set-key "\ek" 'dp-mew-summary-delete) ; del with no visit of next msg

  ; Reply to all...
  (local-set-key "R" (kb-lambda
		       (setq this-command 'dp-mew-summary-reply)
		       (dp-mew-summary-reply t)))

  ;; 'b' for bounce.
  (local-set-key "b" 'mew-summary-resend) ; was 'r' for resend :-(

  ;; give me back the use of M-b --> buffer-menu
  (local-set-key [(control meta b)] 'mew-summary-burst-multi) ;move mew's cmd
  (local-set-key "\eb" 'dp-buffer-menu)

  ;; give me back M-e --> edit file (find-file)
  (local-set-key [(control meta e)] 'mew-summary-edit-again)
  (local-set-key "\ee" 'find-file)
  (local-set-key [(control meta q)] 'dp-mail-fwd-spam)
  (local-set-key [(control meta d)] 'dp-mail-fwd-spam)
  (local-set-key [(meta ?-)] 'dp-bury-or-kill-buffer)

  ;; @todo XXX See if there's a way to do something like this with FSF.
  (when (dp-xemacs-p)
    (make-local-variable 'current-menubar)
    (setq current-menubar (copy-tree current-menubar))
    (add-menu-button nil
		     ["SPAM" dp-mail-fwd-spam
		      :active (and
			       (fboundp (quote dp-mail-fwd-spam))
			       dp-mail-fwd-spam-idle)]
		     nil current-menubar)

    (add-menu-button nil
		     ["Inc" mew-summary-retrieve
		      :active (fboundp (quote mew-summary-retrieve))]
		     nil current-menubar)
    (add-menu-button nil
		     ["X-Spam" dp-mail-handle-spam
		      :active (and
			       (fboundp (quote dp-mail-handle-spam))
			       dp-mail-fwd-spam-idle)]
		     nil current-menubar))
  ;;(message "YOPP!")
  (message "mew-summary-mode-hook done"))

(defun dp-mew-message-hook ()
  "Set up mew message mode my way."
  (interactive)
  ;; Bad keyboard keys.
  (define-key dp-Ccd-map "a" 'mew-draft-prepare-attachments)
  (define-key dp-Ccd-map "2" 'mew-attach-copy)
  (local-set-key "\e." 'find-file-at-point))

(defun dp-mew-summary-reply (&optional not-onlytofrom-p)
  "Invert the meaning of \\[universal-argument]
since I prefer to *not* cc everyone on the
cc list."
  (interactive "P")
  (mew-summary-reply (not not-onlytofrom-p)))

(defun dp-mew-summary-reply-with-citation (&optional onlytofrom)
  (interactive)
  (call-interactively 'mew-summary-reply-with-citation))

;; a *much* nicer splash
;; doesn't work well, I think it is too large.
;;(setq mew-icon-mew "rpasta.png")

(defun dp-mew-real-send-hook (&rest rest)
  ;;(dmessage "rsh>%s<" rest)
  )

(defun dp-mew-cite-hook ()
  (dp-push-filladapt-state (not 'on))
  (sc-cite-original)
  ;;(dmessage "dp-mew-cite-hook, buf>%s<" (buffer-name))
  (dp-pop-filladapt-state)

  ;; sc leaves it set to the citation header.  This means my replies are
  ;; prefixed with, say, "kath> ", when they're filled.
  ;; Since filladapt can guess the citation's prefix, I set fill-prefix to
  ;; be empty here.
  (setq fill-prefix nil))

;; must be implemented for each mailer.
(defun dp-mail-end-of-body ()
  "Return position of end of body.
For mew, this may be the beginning of attachements or the end of file."
  (save-excursion
    (goto-char (point-min))
    (if (search-forward
	 dp-mew-attachments-header nil t)
	(progn
	  (beginning-of-line)
	  (backward-char 1)
	  (point))
      (point-max))))

(defun dp-mew-draft-send-message (skip-rewrites)
  (interactive "P")
  (let ((dp-mail-skip-per-recipient-hooks skip-rewrites)
	(dp-mail-skip-rewrite-from skip-rewrites))
    (mew-draft-send-message)))

(defun dp-mew-summary-delete (count)
  (interactive "p")
  (dotimes (n count)
    (mew-summary-delete-one t)
    (mew-summary-next-line)))
