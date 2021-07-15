
;;@todo find a better way to determine this.
;; this way requires us to set/clear this in a number of places.
(defvar dp-mail-is-a-reply-p nil
  "Lets us know if a reply operation is in progress.")

(defun dp-mew-summary-reply (&optional not-onlytofrom-p)
  "Invert the meaning of \\[universal-argument]
since I prefer to *not* cc everyone on the
cc list."
  (interactive "P")
  (setq dp-mail-is-a-reply-p t)
  (mew-summary-reply (not not-onlytofrom-p)))

(defun dp-mew-summary-reply-with-citation (&optional onlytofrom)
  (interactive)
  (setq dp-mail-is-a-reply-p t)
  (call-interactively 'mew-summary-reply-with-citation))
  
(defun dp-mew-real-send-hook (&rest rest)
  (dmessage "rsh>%s<" rest)
  (setq dp-mail-is-a-reply-p nil))

(defun dp-mew-guess-From:-suffix (&optional def-suf)
  (or (car-safe (let ((mew-refile-guess-alist dp-From:-suffix-alist))
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
	       (dp-mail-get-@ddr (dp-mail-get-header-value "^[Tt][oO]:"))))
	  (dmessage "was-to>%s<" was-to)
	  was-to))))

(defun dp-mew-rewrite-from-header (dont-force-reply)
  (interactive "P")
  (let ((dp-mail-is-a-reply-p (or (not dont-force-reply) 
				  dp-mail-is-a-reply-p)))
    (dp-mail-rewrite-from-header (dp-mew-guess-From:-suffix))))

(defun dp-mew-send-hook ()
  "Send hook.  Compute destination fcc folder by guessing with
`mew-refile-guess-by-alist'.  Compute From: suffix.
Remove any SpamAssassin added *****SPAM***** from headers."
  (interactive)
  (let* ((fcc-list (dp-mew-guess-fcc))
	 (fcc-val (dp-string-join fcc-list ", ")))
    ;;(message "fcc-val>%s<" fcc-val)
    ;;(message "fcc-val2>%s<" (mew-refile-guess-by-alist))
    (dp-replace-fcc fcc-val dp-mail-header-terminator)
    (dp-mew-rewrite-from-header t)

    (dp-mail-run-per-recipient-hooks (dp-mail-get-recipients-string)
				     dp-mail-per-recipient-hook-alist)
    (dp-mail-nuke-SPAM-indicator)))

(defvar dp-mail-extract-addr-regexp "<\\(.*\\)>" 
  "Regexp to get basic reply-to addr out of a more elaborate email addr.")
;;

(defcustom dp-mail-auto-accept-was-to-regexp
  "davep.*@meduseld.net\\|some-other-name@some-other.domain"
  "Use to: addresses matching this as return addresses without asking."
  :group 'dp-vars
  :type 'string)

;; actually, all that makes sense for now is the auto accept list.
(defcustom dp-mail-auto-reject-was-to-regexp
  ".*"
  "Never use to: addresses matching this as return addresses."
  :group 'dp-vars
  :type 'string)

(defcustom dp-mail-per-recipient-hook-alist
  ;; cdr of each element must be a list
  '( ("uce@ftc\\.gov\\|419\\.fcd@usss\\.treas\\.gov" . dp-mail-delete-body))
  "List of recipients in need of special processing."
  :group 'dp-vars
  :type '(repeat (cons (string :tag "Recipient regexp")
		       (function :tag "Hook func"))))


(defun dp-mail-header-end ()
  "Return marker for end of headers.  If the current mail system doesn't
provide this, the value will be nil, which is OK-ish since we will then
search to the end of the email."
  dp-mail-header-end-marker)

(defun dp-mail-get-header-value (hdr-regexp)
  "Get value of header HDR-REGEXP.
Returns everything after the header, the colon and any whitespace."
  (save-excursion
    (dp-beginning-of-buffer)
    (when (re-search-forward hdr-regexp dp-mail-header-end-marker t)
      (beginning-of-line)
      (re-search-forward ":\\S-*\\(.*\\)" dp-mail-header-end-marker)
      (match-string 1))))

(defun dp-mail-get-@ddr (str)
  (string-match "\\([^< ]+@[^>]+\\)" str)
  (match-string 1 str))

(defun dp-mail-get-recipients-string ()
  "Get values of To: and Cc: into a list of strings."
  (concat (dp-mail-get-header-value "[Tt][Oo]:")
	  (dp-mail-get-header-value "[Cc][Cc]:")))

(defun dp-assoc-regexp (key regexp-alist)
  "Find KEY in REGEXP-ALIST.
REGEXP-ALIST is a list of (regexp . whatever).  When matched, WHATEVER is
returned."
  (dolist (el regexp-alist nil)
    (if (string-match (car el) key)
	(return  el))))

(defun dp-mail-run-per-recipient-hooks (recip-string hook-alist)
  (let* ((hook-rec (dp-assoc-regexp recip-string hook-alist))
	 (fun-list (cdr hook-rec)))
    (unless (listp fun-list)
      (setq fun-list (list fun-list)))
    (dolist (el fun-list nil) 
	(funcall el))))

(defun dp-replace-mail-header (hdr-regexp hdr-name hdr-val 
					  &optional hdr-terminator)
  "Replace or add a mail header."
  (save-excursion
    (goto-char (point-min))
    ;; try to replace it first.
    ;; @todo should I determine the header end first and use that to
    ;; bound the search.
    (if (re-search-forward hdr-regexp dp-mail-header-end-marker t)
	(replace-match (concat hdr-name ": " hdr-val))
      ;; since we couldn't find it, att it at the end of the headers.
      (if (re-search-forward 
	   (or hdr-terminator dp-mail-header-terminator)
	       dp-mail-header-end-marker t)
	  (progn
	    (beginning-of-line)
	    (insert (concat hdr-name ": " hdr-val "\n")))
	(message "Cannot find %s: field or header delimitter." hdr-name)))))

(defun dp-replace-fcc (val &optional hdr-terminator)
  "Replace or add an fcc header."
  (dp-replace-mail-header "^[fF]cc:.*$" "Fcc" val hdr-terminator))

(defun dp-replace-from (val &optional hdr-terminator)
  "Replace or add an fcc header."
  (dp-replace-mail-header "^[fF]rom:.*$" "From" val hdr-terminator))

;; use lower case so re-search doesn't go into case sensitive mode
;; @todo ?? is this true for non-interactive usage, too?
(defvar dp-mail-SPAM-indicator "\\*\\*\\*\\*\\*spam\\*\\*\\*\\*\\* ")

(defun dp-mail-nuke-SPAM-indicator ()
  "Remove the Spamassassin spam indicator:
Subject: Re: *****SPAM***** blah blah blah"
  (save-excursion
    (dp-beginning-of-buffer)
    (let ((case-fold-search t))
      (when (re-search-forward (concat 
				"^sub\\S-*:.*\\(" 
				dp-mail-SPAM-indicator
				"\\)")
			       (dp-mail-header-end)
			       'no-error)
	(replace-match "" nil 'literal nil 1)))))

;; check for auto-reject: those which we know we don't want to
;; result in a rewrite
(defun dp-mail-auto-reject-was-to-p (was-to)
  (string-match dp-mail-auto-reject-was-to-regexp
		was-to))

;; check for auto-accept: those which we know we want to
;; result in a rewrite
(defun dp-mail-auto-accept-was-to-p (was-to)
  (string-match dp-mail-auto-accept-was-to-regexp
		was-to))

(defun dp-mail-old-from (reply-to)
  (if (string-match dp-mail-extract-addr-regexp reply-to)
      (match-string 1 reply-to)
    "?old-from?"))

(defun dp-mail-generate-from (from-suffix)
  "Create a From: value given FROM-SUFFIX.  
If FROM-SUFFIX begins w/., the it is a suffix and is composited with
`dp-mail-fullname' and `dp-mail-user'."
  (if (string= (substring from-suffix 0 1) ".")
      (format "%s <%s%s@%s>" 
	      dp-mail-fullname dp-mail-user 
	      from-suffix dp-mail-domain)
    (format "<%s@%s>" from-suffix dp-mail-domain)))

(defun dp-mail-rewrite-from-header (from-suffix)
  (if from-suffix
      (dp-replace-from (dp-mail-generate-from from-suffix))
    (when dp-mail-is-a-reply-p
      ;; no from-suffix, see to whom this message was addressed
      (let ((was-to (dp-mail-get-who-message-was-to)))
	(if (or (dp-mail-auto-accept-was-to-p was-to)
		(and (not (dp-mail-auto-reject-was-to-p was-to))
		     (y-or-n-p (format 
				"Replace %s with %s? "
				(dp-mail-old-from mail-default-reply-to) 
				was-to))))
	    (dp-replace-from (replace-in-string mail-default-reply-to
						dp-mail-extract-addr-regexp
						(concat "<" was-to ">")
						'literal)))))))

(defun dp-mail-remove-sig (&optional keep-separator)
  (delete-region (if keep-separator 
		     dp-sig-start-marker 
		   dp-sig-orig-point-max)
		 (dp-mail-end-of-body)))

(defun dp-mail-beginning-of-body ()
  (save-excursion
    (goto-char dp-mail-header-end-marker)
    (forward-line 1)
    (point)))

(defun dp-mail-delete-body ()
  (delete-region (dp-mail-beginning-of-body)
		 (dp-mail-end-of-body)))

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

(defconst dp-mew-attachments-header 
  "------------------------------ attachments ------------------------------")

(defcustom dp-From:-suffix-alist
  nil
  "Alist of suffixes to add to the From: address based on other mail headers.
Format is a list of these: 
   '(header-selection-regexp (header-value-regexp . suffix-string)"
  :group 'dp-vars
  :type mew-custom-type-of-guess-alist)

;;
;; I set this in a per user piece of code since mew's `mew-config-alist'
;; doesn't know about this variable.
(setq dp-From:-suffix-alist
      '(("To:\\|Cc:" ("xemacs.*" . ".xemacs"))
	("To:\\|Cc:" ("freebsd.*" . ".freebsd"))
	("To:\\|Cc:" ("mew.*" . ".mew"))
	("To:\\|Cc:" ("sawfish.*" . ".sawfish"))
	("To:\\|Cc:" ("amazon.com" . ".amazon"))
	("To:\\|Cc:" ("buy.com" . ".buy.com"))
	("To:\\|Cc:" ("uce@ftc.gov" . ".uce"))
	))


