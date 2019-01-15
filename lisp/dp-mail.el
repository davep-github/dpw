;;;
;;; $Id: dp-mail.el,v 1.79 2005/02/19 09:20:06 davep Exp $
;;;
;;; Set up mail subsystem.
;;; First we try for mew, then fall back to mh-e.
;;;

(dp-deflocal dp-sig-sep-start-marker nil 
  "Position of the beginning of an email signature's separator \(e.g. \n--\n).")
(dp-deflocal dp-sig-sep-end-marker nil 
  "Position of the end of an email signature's separator \(e.g. \n--\n).")
(dp-deflocal dp-sig-start-marker nil 
  "Position of the beginning of an email's signature.")
(dp-deflocal dp-sig-orig-point-max-marker nil 
  "point-max before we added a sig")
(dp-deflocal dp-mail-header-end-marker nil 
 "Marker of the end of an email's headers.")
(dp-deflocal dp-mail-body-end-marker  nil
  "Position of end of mail body.  E.g. in a mew message with attachements,
this position is the position of the attachment header.")

(defconst dp-sig-source dp-default-sig-source)

;;@todo find a better way to determine this.
;; this way requires us to set/clear this in a number of places.
(dp-deflocal dp-mail-is-a-reply-p nil
  "Lets us know if a reply operation is in progress.")

(defvar dp-mail-confirm-when-no-SPAM-in-subject t
  "See variable name.")

(defvar dp-mail-file-vs-forward-p nil
  "Refile spam in a holding folder to be processed later rather than
forwarding now.  This is an override.  Normally, `dp-mail-upchuck-spam'
refiles if in `+inbox' and forwards if in `+spamcan'.")

(defvar dp-mail-extract-addr-regexp "<\\(.*\\)>" 
  "Regexp to get basic reply-to addr out of a more elaborate email addr.")
;;
(autoload 'sc-cite-region "supercite" "supercite region citer" t)
(require 'dp-supercite)

(defcustom dp-mail-auto-accept-was-to-regexp
  ".*@meduseld.net\\|david.panariti@hp.com\\|.*@crickhollow.org\\|.*@withywindle.org\\|dpanariti@speakeasy.net\\|chicxulub@speakeasy.net"
  "Use to: addresses matching this as return addresses without asking."
  :group 'dp-vars
  :type 'string)

;; actually, all that makes sense for now is the auto accept list.
(defcustom dp-mail-auto-reject-was-to-regexp
  ;; she bcc's everyone, so stuff from: her is addressed to: her
  ;; never use my attbi.com, since ISP may change
  ;;"mattisjo\\|panariti@attbi.com"
  ".*"
  "Never use to: addresses matching this as return addresses."
  :group 'dp-vars
  :type 'string)

(defcustom dp-mail-per-recipient-hook-alist
  ;; cdr of each element must be a list
  '( ("uce@ftc\\.gov\\|419\\.fcd@usss\\.treas\\.gov\\|spoof@paypal\\.com" . 
      dp-mail-delete-body))
  "List recipients in need of special processing."
  :group 'dp-vars
  :type '(repeat (cons (string :tag "Recipient regexp")
		       (function :tag "Hook func"))))

(defcustom dp-mail-use-auth-p t
  "*Use authorization, currently with `secrets'?"
  :group 'dp-vars
  :type 'boolean)

(defvar dp-sig-prefix '("       /"
			"davep (|)"
			"       /")
  "List of strings making up the baroque signature's prefix.")

(defconst dp-generic-mail-code (dp-lisp-subdir "dp-mail.el")
  "This file, basically.")

(defconst dp-current-mailer-config-file dp-generic-mail-code
  "The config file for the current default mailer I'm using.")

(when dp-mail-use-auth-p
  (require 'secrets)
  ;; `auth-sources' set via customize.
  ;; And I quote, "Eew, I'm not gonna use customize."
  ;; He a man!
  ;; Me a man, too. A lazy (efficient) one.
  ;; (setq message-send-mail-function 'smtpmail-send-it
  ;;     smtpmail-smtp-server "smtp.office365.com"
  ;;     smtpmail-smtp-service 587) <==-- 25 works as well.
  )
;;
;; load up the best mailer we can...
;; A good spec-macs variable.
;;(setq-ifnil-or-unbound dp-mailer 'gnus)
(defun dp-mail-setup-mailer (&optional mailer)
  (setq-ifnil mailer dp-mailer)
  (case dp-mailer
    ('mu4e
     (require 'dp-mu4e)
     (dp-setup-mu4e)
     )
    ('mew
     (let ((min-macs-ver "20.7.1"))
       (when (string< emacs-version min-macs-ver)
	 (error "mew is displeased. Emacs version %s needs must be >= %s"
		emacs-version
		min-macs-ver)))
     ;; try for mew mailer package.  An error will
     ;; cause condition-case to yield nil, causing a
     ;; load of mhe.
     (require 'dp-mew)
     )
    ;; for now, only other mailer is mhe and that is the
    ;; default, too, so return nil which causes the
    ;; default to be loaded.
    ('gnus
     ;; This is a pretty safe default... it's quite popular... despite great
     ;; suckage as a mailer.
     (global-set-key [(control ?c) ?r] 'gnus)
     (global-set-key [(control ?x) ?m] 'gnus-msg-mail)
     ;; This works better if called before gnus is started.  Need to fix that.
     ;;(require 'dp-dot-gnus)
     )
    ('vm
     (require 'vm)
     (setq dp-current-mailer-config-file (dp-lisp-subdir "dp-dot-vm.el"))
     (global-set-key [(control ?c) ?r] 'vm)
     (global-set-key [(control ?x) ?m] 'vm-mail))
    )
  )
(dp-mail-setup-mailer)

(if (and (boundp 'dp-mailer-setup)
	 dp-mailer-setup)
     (funcall dp-mailer-setup))

(setq mail-default-headers 
      (format "X-Attribution: davep\nX-Mailer: %sEmacs %s \n"
              (if (dp-xemacs-p)
                  "X"
                "")
              dp-mailer))

(defun dp-insert-shell-cmd-sig (cmd &rest args)
  "Insert the output of a command as a signature."
  (interactive)
  (insert (shell-command-to-string (format "%s %s"
					   cmd
					   (dp-string-join args " ")))))

(defun dp-insert-file-sig (fname)
  "Insert contents of FNAME as signature."
  (condition-case err
      (insert-file fname)
    (error (message "Error reading: %s: %s" fname err))))

(defun dp-insert-sig (&optional sig-source)
  "Insert sig according to dp-sig-source."
  (interactive)
  (let ((old-buffer-modified-state (buffer-modified-p))
        sig-type sig-val)
    (setq-ifnil sig-source dp-sig-source)
    (save-excursion
      ;; delete any existing sig
      (dp-mail-remove-sig 'keep-separator)
      (goto-char (marker-position dp-sig-start-marker))
      (cond
       ((consp sig-source)
        (setq sig-type (car sig-source)
              sig-val (cdr sig-source))
        (case sig-type
          ('file (insert-file sig-val))
          ('string (insert sig-val))
          ('function (funcall sig-val))
          ('expr (eval sig-val))))
       ((functionp sig-source) (funcall sig-source))
       ((stringp sig-source) (insert sig-source))
       (sig-source (eval sig-source))
       ((stringp mail-signature) (insert mail-signature)) ;historical
       (t (message "Unsupported type in sig-source>%<" sig-source)
          (ding))))
    ;; Preserve modification status.  I don't want adding a sig to make the
    ;; buffer appear modified but I also don't want to remove a previous
    ;; modified state.
    (set-buffer-modified-p old-buffer-modified-state)))

(defalias 'dis 'dp-insert-sig)

(defun disb ()
  (interactive)
  (let ((dp-sig-source dp-default-sig-source))
    (dp-insert-sig)))

(defconst dp-insert-tame-sig-p t
  "Are we being prim and proper?")

(defun* dp-maybe-insert-tame-sig (&optional (pred dp-insert-tame-sig-p) 
                                  &rest pred-args)
  (dp-maybe-insert-sig (if (apply 'dp-call-pred-or-pred pred pred-args)
                           'dp-insert-tame-sig
                         nil)))         ; nil --> default.
                         

(defun dp-maybe-insert-sig (&optional sig-source insert-not-p insert--not-p)
  "Insert a sig of the desired type."
  (interactive)
  (setq-ifnil sig-source dp-sig-source)
  (if (and dp-mail-include-sig-p dp-sig-source)
      (save-excursion
	(goto-char (point-max))
	(setq dp-sig-orig-point-max-marker (dp-mk-marker nil nil t))
	(setq dp-sig-sep-start-marker (dp-mk-marker))
	(unless (or insert-not-p insert--not-p)
          (insert "\n--\n"))
	(setq dp-sig-sep-end-marker (dp-mk-marker))
	(setq dp-sig-start-marker (dp-mk-marker))
	(unless insert-not-p 
          (dp-insert-sig sig-source)))
    (setq dp-sig-orig-point-max-marker nil)))

(defun dp-tame-sig-source-internal (sig-source)
  (let ((old-buffer-modified-state (buffer-modified-p)))
    (dp-maybe-insert-sig sig-source)
    (set-buffer-modified-p old-buffer-modified-state))
  nil)

(defun dp-mail-header-end ()
  "Return marker for end of headers.  If the current mail system doesn't
provide this, the value will be nil, which is OK-ish since we will then
search to the end of the email."
  dp-mail-header-end-marker)

(defun* dp-mail-in-headers-p (&optional (pos (point)) &rest args)
  
  (dp-with-saved-point nil
    (goto-char pos)
    (dp-apply-if 'dp-mail-spec-in-headers-p args
      (< pos dp-mail-header-end-marker))))
  
(defun dp-mail-get-header-value (hdr-regexp)
  "Get value of header HDR-REGEXP.
Returns everything after the header, the colon and any whitespace."
  (save-excursion
    (dp-beginning-of-buffer)
    (save-match-data
      (when (dp-re-search-forward hdr-regexp dp-mail-header-end-marker t)
	(beginning-of-line)
	(dp-re-search-forward ":\\s-*\\(.*\\)" dp-mail-header-end-marker)
	(match-string 1)))))

(defun dp-mail-get-@ddr (str)
  "Parse simple user@host.domain out of fancier adderss.
Returns list of all addrs."
  (when str
    (save-match-data
      (let ((addrs (rfc822-addresses str)))
        (if (stringp addrs)
            (list addrs)
          addrs)))))
; old extraction code	
;    (string-match "\\([^< ]+@[^>]+\\)" str)
;    (match-string 1 str)))

(defun dp-mail-get-recipients-string ()
  "Get values of To: and Cc: into a regexp matching either."
  (dp-string-join (delq nil (list
			     (dp-mail-get-header-value "^[Tt][Oo]:")
			     (dp-mail-get-header-value "^[Bb]?[Cc][Cc]:")))
		  "\\|"))

(defvar dp-mail-skip-per-recipient-hooks nil)

(defun dp-mail-skip-per-recipient-hooks (&optional arg)
  (interactive)
  (dp-toggle-var arg 'dp-mail-skip-per-recipient-hooks))

(defvar dp-mail-skip-rewrite-from nil)

(defun dp-mail-skip-rewrite-from (&optional arg)
  (interactive)
  (dp-toggle-var arg 'dp-mail-skip-rewrite-from))
    

(defun dp-mail-run-per-recipient-hooks (recip-string hook-alist)
  "@todo fix this:
Only the first match in hook-alist of recip-string is used.
`dp-assoc-regexp' should, perhaps, return a list of matches?"
  (unless dp-mail-skip-per-recipient-hooks
    (let* ((hook-rec (dp-assoc-regexp recip-string hook-alist))
	   (fun-list (cdr hook-rec)))
      ;; fun-list can be a list of funcps or a single funcp.
      (unless (listp fun-list)
	;; make it a list so the dolist works.
	(setq fun-list (list fun-list)))
      (dolist (el fun-list nil) 
	(funcall el)))))

(defun dp-replace-mail-header (hdr-regexp hdr-name hdr-val 
					  &optional hdr-terminator)
  "Replace or add a mail header."
  (save-excursion
    (goto-char (point-min))
    ;; try to replace it first.
    ;; @todo should I determine the header end first and use that to
    ;; bound the search.
    (save-match-data
      (if (dp-re-search-forward hdr-regexp dp-mail-header-end-marker t)
	  (replace-match (concat hdr-name ": " hdr-val))
	;; since we couldn't find it, add it at the end of the headers.
	(if (dp-re-search-forward 
	     (or hdr-terminator dp-mail-header-terminator)
	     dp-mail-header-end-marker t)
	    (progn
	      (beginning-of-line)
	      (insert (concat hdr-name ": " hdr-val "\n")))
	  (message "Cannot find %s: field or header delimitter." hdr-name))))))

(defun dp-delete-mail-header (hdr-regexp)
  (save-excursion
    (goto-char (point-min))
    (save-match-data
      (if (dp-re-search-forward hdr-regexp dp-mail-header-end-marker t)
	  (dp-delete-entire-line)))))

(defun dp-replace-fcc (val &optional hdr-terminator)
  "Replace or add an fcc header."
  (dp-replace-mail-header "^[fF]cc:.*$" "Fcc" val hdr-terminator))

(defun dp-delete-fcc ()
  "Delete the fcc header."
  (dp-delete-mail-header "^[fF]cc:.*$"))

(defun dp-replace-From: (val &optional hdr-terminator)
  "Replace or add an fcc header."
  (dp-replace-mail-header "^[fF]rom:.*$" "From" val hdr-terminator))

(defun dp-mail-handle-spam (&optional confirm-p)
  "Handles spam by selecting it and forwarding to uce@ftc.gov."
  (interactive)
  (let ((dp-mail-confirm-when-no-SPAM-in-subject confirm-p))
    (if (dp-mail-in-spamcan-p)
	(dp-mail-mark-all)
      (pick-spam))
    (dp-mail-fwd-marked-spam nil)
    (message "xspam done.")))

(defalias 'xspam 'dp-mail-handle-spam)

;; use lower case so re-search doesn't go into case sensitive mode
;; @todo ?? is this true for non-interactive usage, too?
;;       should use case-fold-search where necessary.
(defvar dp-mail-SPAM-indicator
  "\\*\\*\\*\\*\\*spam\\([^*]*\\)\\*\\*\\*\\*\\* "
  "E.g: *****SPAM(5.5)*****, *****SPAM:5.5*****")

(defun dp-mail-nuke-SPAM-indicator ()
  "Remove the Spamassassin spam indicator:
Subject: Re: *****SPAM***** blah blah blah"
  (save-excursion
    (dp-beginning-of-buffer)
    (save-match-data
      (let ((case-fold-search t))
	(when (dp-re-search-forward (concat 
				  "^sub\\S-*:.*\\(" 
				  dp-mail-SPAM-indicator
				  "\\)")
				 (dp-mail-header-end)
				 t)
	  (replace-match "" nil 'literal nil 1))))))

;; check for auto-reject: those which we know we don't want to
;; result in a rewrite
(defun dp-mail-auto-reject-was-to-p (was-to)
  (dp-find-regexp-in-list dp-mail-auto-reject-was-to-regexp was-to))

;; check for auto-accept: those which we know we want to
;; result in a rewrite
(defun dp-mail-auto-accept-was-to-p (was-to)
  (dp-find-regexp-in-list dp-mail-auto-accept-was-to-regexp was-to))

(defun dp-mail-old-from (reply-to)
  (save-match-data
    (if (string-match dp-mail-extract-addr-regexp reply-to)
	(match-string 1 reply-to)
      "?old-from?")))

(defun dp-mail-generate-from-element (val def-val
				       &optional format-string)
  "Generate a name string for a mail element.
If VAL is nil use DEF_VAL.
If format-string is nil, use \"%s\"."
  (format (or format-string "%s") (or val def-val)))

(defun dp-mail-generate-fullname (val &optional def-val)
  "Generate a proper fullname for an email address.
If fullname is \"\" or nil, the return an empty string.
Otherwise, quote the value and add a separating space."
  (let ((v (or val def-val)))
    (if (and v
	     (not (string= v "")))
	(format "\"%s\" " v)
      "")))

;;
;; implemented by the current mailer.
;;(defun dp-mail-generate-from (from-suffix)
;;

(defun dp-mail-generate-From:-given-plist (element-plist)
  "ELEMENT-PLIST a plist that contains From: address elements for rewrite.
Use defaults for unspecified elements.
\[\"fullname\" ]<user[.suffix]@domain>
The plist elements use the above names prefixed with a `:',
e.g. :suffix."
  (format "%s<%s%s@%s>" 
	  (dp-mail-generate-fullname (plist-get element-plist 
						':fullname)
				     dp-mail-fullname)
	  (dp-mail-generate-from-element (plist-get element-plist 
						    ':user)
					   dp-mail-user)
	  (dp-mail-generate-from-element (plist-get element-plist
						    ':suffix)
					 "")
	  (dp-mail-generate-from-element (plist-get element-plist
						    ':domain)
					 dp-mail-domain)))

(defun dp-mail-rewrite-From:-header (from-suffix)
  (if from-suffix
      (progn
	(dp-replace-From: (dp-mail-generate-From: from-suffix))
	(message "Replacing From: due to from-suffix >%s<" from-suffix))
    (when dp-mail-is-a-reply-p
      ;; no from-suffix, see to whom this message was addressed this is used
      ;; when replying to a message to ensure that the reply appears to come
      ;; from the same address to which the original was sent
      (let ((was-to (dp-mail-get-who-message-was-to))
	    accept-str)
	(if (and was-to
		 (or (setq accept-str (dp-mail-auto-accept-was-to-p was-to))
		     (and (not (dp-mail-auto-reject-was-to-p was-to))
			  (y-or-n-p (format 
				     "Replace %s with %s? "
				     (dp-mail-old-from 
				      mail-default-reply-to) 
				     accept-str)))))
	    (progn
	      (message "Replacing From: case #2")
	      (dp-replace-From: (replace-in-string mail-default-reply-to
						  dp-mail-extract-addr-regexp
						  (concat "<" accept-str ">")
						  'literal)))
	  (dmessage "was-to is nil."))))))

(defun dp-mail-remove-sig (&optional keep-separator)
  (delete-region (if keep-separator 
		     dp-sig-sep-end-marker
		   dp-sig-sep-start-marker)
		 (dp-mail-end-of-body)))

(defun dp-mail-beginning-of-body ()
  (save-excursion
    (goto-char dp-mail-header-end-marker)
    (forward-line 1)
    (point)))

(defun dp-mail-delete-body ()
  (delete-region (dp-mail-beginning-of-body)
		 (dp-mail-end-of-body)))

(defcustom dp-baroque-sig-max-lines 7
  "Max lines in a baroque sig."
  :group 'dp-vars
  :type 'integer)

(defun dp-exec-short-fortune ()
  (shell-command-to-string "fortune -s"))

;; move to dpmisc some day?  Remove sig refs since it is now
;; not entirely sig related.
;; useful, e.g., for producing this:
;       / | Every absurdity has a champion who will defend it.
;davep (|)| 
;       / | 
;where chars left of the |s are SIG-LEFT, and vice versa
;and the |s don't exist.
;
(defun dp-zip-lists-padded (sig-left sig-right right-refiller
				     &optional 
				     max-lines-right
				     extra-pad wrap-p)
  "Zip lists SIG-LEFT and SIG-RIGHT together.
Pad lines from SIG-LEFT to all be the same length, 
\(or EXTRA-PAD 8\) greater than the longest line in SIG-LEFT."
  ;; maintain max from sig-left
  (let* (r-line 
	 l-line 
	 o-list
	 l-pad
	 (too-long t)
	 (iters 0)
	 (left-max (length (dp-longest-line-in-list sig-left)))
         ;; @todo ??? change hard coded 80 to the current frame width?
	 (right-max (- 80 left-max (or extra-pad 8)))
	 (l-fill (make-string (1+ left-max) ? )))  ;spaces
    (if wrap-p
	(setq sig-right 
	      (split-string (dp-fill-string sig-right right-max) "[\n]"))
      (while too-long
        (dp-message-no-echo "sig-right>%s<" sig-right)
        (message "%s*" (make-string iters ?.))
	(setq sig-right (dp-untabify-string sig-right))
	(incf iters)
	(setq sig-right (split-string sig-right "\n")
              too-long (or (> (length sig-right) (or max-lines-right 7))
			   (> (length (dp-longest-line-in-list sig-right))
			      right-max)))
	(if too-long
	    (setq sig-right (funcall right-refiller)))))

    ;; gen string to show us the `cost' of our baroqueness.
    (setq sig-left (append sig-left (list (make-string (min iters left-max)
						       ?$))))
    (while (<= (length sig-right) (- (length sig-left) 2))
      (dp-message-no-echo "lsr>%s<, lsl>%s<" 
                          (length sig-right) (- (length sig-left) 2))
      (setq sig-right (cons "" sig-right)))
    (while (or sig-left sig-right)
      (setq l-line (car sig-left)
	    r-line (car sig-right)
	    sig-left (cdr sig-left)
	    sig-right (cdr sig-right))
      (if (not l-line)
	  (setq l-line l-fill
		l-pad "")
	(setq l-pad (make-string (- (1+ left-max) (length l-line)) ? ))
	)
      (if (not r-line)
	  (setq r-line ""))
      (setq o-list (cons (concat l-line l-pad r-line) o-list)))
    (nreverse o-list)))

(defun dp-mk-baroque-fortune-sig ()
  "Make a baroque fortune signature."
  (dp-string-join (dp-zip-lists-padded dp-sig-prefix 
				       (dp-exec-short-fortune)
				       'dp-exec-short-fortune
				       dp-baroque-sig-max-lines)
		  "\n"))

(defun dp-mail-fwd-spam (num-cans)
  "Forward the next NUM-CANS messages as spam."
  (interactive "p")
  (dotimes (i (or num-cans 1))
    (dp-mail-upchuck-spam)))

;;
;;
;; XXX: May want to change alist format to be compatible with mew
;;
;; search alist
;; wanna be able to say:
;; ipaq@handhelds as a to: or cc: --> x as fcc
;;
;; ((addr1 (mail-hdr-list) list-of-fccs-if-addr1-is-in-a-hdr-in-mail-hdr-list)
;;  (addr2 (f2a f2b) fcc2a fcc2b)))	
;; e.g.:
;; (setq fcc-alist '(("addr-to" ("to") "to-fcc1a" "to-fcc1b")
;;  ("addr-cc" ("f2a" "cc") "cc-fcc2a" "cc-fcc2b")))
;; addr1 can be a list. If it is, then each element is assumed
;;  to be a string and a regexp is constructed with each element
;;  as an alternation (e.g. ("a" "b" "c") --> "a\\|b\\|c"
;; If you want a default fcc folder, use nil as the addr.
;;  this will only be used if there is no other fcc folder already
;;  selected in the search process
;; If you want a folder that is always used, use ".*" as the addr
;; 
(defun dp-map-hdrs-to-fcclist (to subject cc fcc-alist)
  "We want to determine where to place our fcc(s) based on the 
TO, SUBJECT, CC and FCC-ALIST.
We will return a list of fcc folder names."
  (let (fcc-ret
	(fcc-tmp fcc-alist)
	;;
	;; stick the passed in hdrs into an alist for quick
	;; programmatic access
	;;
	(hdr-alist (list (cons "to" to) 
			 (cons "sub" subject) 
			 (cons "cc" cc))))
    ;; (message "hdr-alist>%s<" hdr-alist)
    ;; for all entries in fcc-alist
    (while fcc-tmp
      (let* ((fcc-el (car fcc-tmp))
	     (search-val (car fcc-el))	;value to search for
	     (search-hdrs (car (cdr fcc-el)))	;header fields to search
	     (fcc-folders (cdr (cdr fcc-el)))) ;fcc folders in case of match
	;;(message ">>>fcc-el>%s<" fcc-el)
	;;(message "search-hdrs>%s<" search-hdrs)
	;;
	;; loop thru all of the search headers
	(while search-hdrs
	  (let* ((hdr-name (car search-hdrs)) ; get hdr name
		 ;; and the value of that header
		 (hdr-val (cdr (assoc hdr-name hdr-alist)))) 
	    ;;(message "hdr-name>%s<" hdr-name)
	    ;;(message "search-val>%s<" search-val)
	    ;;(message "hdr-val>%s<" hdr-val)
	    ;; nil search val --> default entry.
	    ;; only use if current return list is empty.
	    (if search-val
		(progn
		  ;;
		  ;; if the search val is a list, assume it is list
		  ;; of strings and make a regex that has each string
		  ;; as an alternation
		  ;;
		  (if (listp search-val)
		      (setq search-val (dp-string-join search-val "\\|")))
		  ;;(message "search-val2>%s<" search-val)
		  (save-match-data
		    (when (and hdr-val (string-match search-val hdr-val))
		      ;;(message "match, fcc-folders>%s<" fcc-folders)
		      (setq search-hdrs nil)
		      (setq fcc-ret (append fcc-folders fcc-ret)))))
	      (if (not fcc-ret)
		  (setq fcc-ret fcc-folders)))
	    (setq search-hdrs (cdr search-hdrs)))))
      
      (setq fcc-tmp (cdr fcc-tmp)))
    fcc-ret))

;;;
;;;
;;;
(provide 'dp-mail)
