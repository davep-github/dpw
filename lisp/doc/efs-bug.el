result>(mark . Hash mark printing on (1024 bytes/hash mark).)<
XXX put messages in each place that can clear -busy.
 why are we getting -busy cleared before response from hash command.
Put bp at -scream-and-yell and look back at state.

-----------------------------------------------------
open ftp.xemacs.org
open ftp.xemacs.org
Connected to xemacs.org.
220 ProFTPD 1.2.0pre10 Server (Xemacs FTP Archives) [207.96.122.9]
quote user "anonymous"
ftp> quote user "anonymous"
331 Anonymous login ok, send your complete e-mail address as password.
ftp> quote pass  Turtle Power!
quote pass davep@who.net
230 Anonymous access granted, restrictions apply.
hash
ftp> hash
quote pwd
Hash mark printing on (1024 bytes/hash mark).
ftp> quote pwd
257 "/" is current directory.
ftp>
-----------------------------------------------------

(setq efs-host-cache nil)
nil
(setq efs-host-hashtable (efs-make-hashtable))
[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]

(require 'efs)

(defvar chomped-line "")

(defun efs-guess-host-type (host user)
  "Guess the host type of HOST.
Does a PWD and examines the directory syntax. The PWD is then cached for use
in file name expansion."
  (let ((host-type (efs-host-type host))
	(key (concat host "/" user "/~"))
	syst)
    (efs-save-match-data
      (if (eq host-type 'unknown)
	  ;; Note that efs-host-type returns unknown as the default.
	  ;; Since we don't yet know the host-type, we use the default
	  ;; version of efs-send-pwd. We compensate if necessary
	  ;; by looking at the entire line of output.
	  (let* ((result (efs-send-pwd nil host user))
		 (dir (car result))
		 (line (cdr result)))
	    (message "result>%s<" result)
	    (cond
	     
	     ;; First sift through process lines to see if we recognize
	     ;; any pwd errors, or full line messages.
	     
	     ;; CMS
	     ((string-match efs-cms-pwd-line-template line)
	      (setq host-type (efs-add-host 'cms host)
		    dir (concat "/" (if (> (length user) 8)
					(substring user 0 8)
				      user)
				".191"))
	      (message
	       "Unable to determine a \"home\" CMS minidisk.  Assuming %s"
	       dir)
	      (sit-for 1))
	     
	     ;; TOPS-20
	     ((string-match efs-tops-20-pwd-line-template line)
	      (setq host-type (efs-add-host 'tops-20 host)
		    dir (car (efs-send-pwd 'tops-20 host user))))
	     
	     ;; TI-EXPLORER lisp machine. pwd works here, but the output
	     ;; needs to be specially parsed since spaces separate
	     ;; hostnames from dirs from filenames.
	     ((string-match efs-ti-explorer-pwd-line-template line)
	      (setq host-type (efs-add-host 'ti-explorer host)
		    dir (substring line 4)))

	     ;; FTP Software's DOS Server
	     ((string-match efs-dos:ftp-pwd-line-template line)
	      (setq host-type (efs-add-host 'dos host)
		    dir (substring line (match-end 0)))
	      (efs-add-listing-type 'dos:ftp host user))

	     ;; MVS
	     ((string-match efs-mvs-pwd-line-template line)
	      (setq host-type (efs-add-host 'mvs host)
		    dir "")) ; "" will convert to /, which is always
			     ; the mvs home dir.

	     ;; COKE
	     ((string-match efs-coke-pwd-line-template line)
	      (setq host-type (efs-add-host 'coke host)
		    dir "/"))
	     
	     ;; Try to get tilde.
	     ((null dir)
	      (let ((tilde (nth 1 (efs-send-cmd
				   host user (list 'get "~"
						   efs-null-device)))))
		(cond
		 ;; super dumb unix
		 ((string-match efs-super-dumb-unix-tilde-regexp tilde)
		  (setq dir (car (efs-send-pwd 'super-dumb-unix host user))
			host-type (efs-add-host 'super-dumb-unix host)))

		 ;; Try for cms-knet
		 ((string-match efs-cms-knet-tilde-regexp tilde)
		  (setq dir (car (efs-send-pwd 'cms-knet host user))
			host-type (efs-add-host 'cms-knet host)))
		 
		 ;; We don't know. Scream and yell.
		 (efs-scream-and-yell host user))))
	     
	     ;; Now look at dir to determine host type
	     
	     ;; try for UN*X-y type stuff
	     ((string-match efs-unix-path-template dir)
	      (if
		  ;; Check for apollo, so we know not to short-circuit //.
		  (string-match efs-apollo-unix-path-template dir)
		  (progn
		    (setq host-type (efs-add-host 'apollo-unix host))
		    (efs-add-listing-type 'unix:unknown host user))
		;; could be ka9q, dos-distinct, plus any of the unix breeds,
		;; except apollo.
		(if (setq syst (efs-get-syst host user))
		    (let ((case-fold-search t))
		      (cond
		       ((string-match "\\bNet[wW]are\\b" syst)
			(setq host-type (efs-add-host 'netware host)))
		       ((string-match "^Plan 9" syst)
			(setq host-type (efs-add-host 'plan9 host)))
		       ((string-match "^UNIX" syst)
			(setq host-type (efs-add-host 'unix host))
			(efs-add-listing-type 'unix:unknown host user)))))))
	     
	     ;; try for VMS
	     ((string-match efs-vms-path-template dir)
	      (setq host-type (efs-add-host 'vms host)))
	     
	     ;; try for MTS
	     ((string-match efs-mts-path-template dir)
	      (setq host-type (efs-add-host 'mts host)))
	     
	     ;; try for CMS
	     ((string-match efs-cms-path-template dir)
	      (setq host-type (efs-add-host 'cms host)))

	     ;; try for Tandem's guardian OS
	     ((string-match efs-guardian-path-template dir)
	      (setq host-type (efs-add-host 'guardian host)))
	     
	     ;; Try for TOPS-20. pwd doesn't usually work for tops-20
	     ;; But who knows???
	     ((string-match efs-tops-20-path-template dir)
	      (setq host-type (efs-add-host 'tops-20 host)))
	     
	     ;; Try for DOS or OS/2.
	     ((string-match efs-pc-path-template dir)
	      (let ((syst (efs-get-syst host user))
		    (case-fold-search t))
		(if (and syst (string-match "^OS/2 " syst))
		    (setq host-type (efs-add-host 'os2 host))
		  (setq host-type (efs-add-host 'dos host)))))
	     
	     ;; try for TI-TWENEX lisp machine
	     ((string-match efs-ti-twenex-path-template dir)
	      (setq host-type (efs-add-host 'ti-twenex host)))

	     ;; try for MPE
	     ((string-match efs-mpe-path-template dir)
	      (setq host-type (efs-add-host 'mpe host)))

	     ;; try for VOS
	     ((string-match efs-vos-path-template dir)
	      (setq host-type (efs-add-host 'vos host)))

	     ;; try for the microsoft server in unix mode
	     ((string-match efs-ms-unix-path-template dir)
	      (setq host-type (efs-add-host 'ms-unix host)))

	     ;; Netware?
	     ((string-match efs-netware-path-template dir)
	      (setq host-type (efs-add-host 'netware host)))

	     ;; Try for MVS
	     ((string-match efs-mvs-path-template dir)
	      (if (string-match "^'.+'$" dir)
		  ;; broken MVS PWD quoting
		  (setq dir (substring dir 1 -1)))
	      (setq host-type (efs-add-host 'mvs host)))

	     ;; Try for NOS/VE
	     ((string-match efs-nos-ve-path-template dir)
	      (setq host-type (efs-add-host 'nos-ve host)))
	     
	     ;; We don't know. Scream and yell.
	     (t
	      (efs-scream-and-yell host user)))
	    
	    ;; Now that we have done a pwd, might as well put it in
	    ;; the expand-dir hashtable.
	    (if dir
		(efs-put-hash-entry
		 key
		 (efs-internal-directory-file-name
		  (efs-fix-path host-type dir 'reverse))
		 efs-expand-dir-hashtable
		 (memq host-type efs-case-insensitive-host-types))))

	;; host-type has been identified by regexp, set the mode-line.
	(efs-set-process-host-type host user)
	
	;; Some special cases, where we need to store the cwd on login.
	(if (not (efs-hash-entry-exists-p
		  key efs-expand-dir-hashtable))
	    (cond
	     ;; CMS: We will be doing cd's, so we'd better make sure that
	     ;; we know where home is.
	     ((eq host-type 'cms)
	      (let* ((res (efs-send-pwd 'cms host user))
		     (dir (car res))
		     (line (cdr res)))
		(if (and dir (not (string-match
				   efs-cms-pwd-line-template line)))
		    (setq dir (concat "/" dir))
		  (setq dir (concat "/" (if (> (length user) 8)
					    (substring user 0 8)
					  user)
				    ".191"))
		  (message
		   "Unable to determine a \"home\" CMS minidisk. Assuming %s"
		   dir))
		(efs-put-hash-entry
		 key dir efs-expand-dir-hashtable
		 (memq 'cms efs-case-insensitive-host-types))))
	     ;; MVS: pwd doesn't work in the root directory, so we stuff this
	     ;; into the hashtable manually.
	     ((eq host-type 'mvs)
	      (efs-put-hash-entry key "/" efs-expand-dir-hashtable))
	     ))))))

(defun efs-process-filter (proc str)
  ;; Build up a complete line of output from the ftp PROCESS and pass it
  ;; on to efs-process-handle-line to deal with.
  (let ((inhibit-quit t)
	(buffer (get-buffer (process-buffer proc)))
	(efs-default-directory default-directory))

    ;; see if the buffer is still around... it could have been deleted.
    (if buffer
	(efs-save-buffer-excursion
	  (set-buffer (process-buffer proc))
	  (efs-save-match-data

	    ;; handle hash mark printing
	    (if efs-process-busy
		(setq str (efs-process-handle-hash str)
		      efs-process-string (concat efs-process-string str)))
	    ;;;;(message "str>%s<" str)
	    (efs-process-log-string proc str)
	    (while (and efs-process-busy
			(string-match "\n" efs-process-string))
	      (let ((line (substring efs-process-string
				     0
				     (match-beginning 0))))
		(setq efs-process-string (substring
					  efs-process-string
					  (match-end 0)))
		;; If we are in synch with the client, we should
		;; never get prompts in the wrong place. Just to be safe,
		;; chew them off.
		(while (string-match efs-process-prompt-regexp line)
		  (setq chomped-line (concat chomped-line ">" line "<"))
		  ;;;(setq chomped-line line)
		  (setq line (substring line (match-end 0))))
		(efs-process-handle-line line proc)
		;;;;(message "-busy>%s<" efs-process-busy)
		))
	    
	    ;; has the ftp client finished?  if so then do some clean-up
	    ;; actions.
	    (if (not efs-process-busy)
		(progn
		  (efs-correct-hash-mark-size)
		  ;; reset process-kill-without-query
		  (process-kill-without-query proc)
		  ;; issue the "done" message since we've finished.
		  (if (and efs-process-msg
			   (efs-message-p)
			   (null efs-process-result))
		      (progn

			(efs-message "%s...done" efs-process-msg)
			(setq efs-process-msg nil)))
		  
		  (if (and efs-process-nowait
			   (null efs-process-cmd-waiting))
		      
		      (progn
			;; Is there a continuation we should be calling?
			;; If so, we'd better call it, making sure we
			;; only call it once.
			(if efs-process-continue
			    (let ((cont efs-process-continue))
			      (setq efs-process-continue nil)
			      (efs-call-cont
			       cont
			       efs-process-result
			       efs-process-result-line
			       efs-process-result-cont-lines)))
			;; If the cmd was run asynch, run the next
			;; cmd from the queue. For synch cmds, this
			;; is done by efs-send-cmd. For asynch
			;; cmds we don't care about
			;; efs-nested-cmd, since nothing is
			;; waiting for the cmd to complete. If
			;; efs-process-cmd-waiting is t, exit
			;; to let this command run.
			(if (and efs-process-q
				 ;; Be careful to check efs-process-busy
				 ;; again, because the cont may have started
				 ;; some new ftp action.
				 ;; wheels within wheels...
				 (null efs-process-busy))
			    (let ((next (car efs-process-q)))
			      (setq efs-process-q
				      (cdr efs-process-q))
			      (apply 'efs-send-cmd
				     efs-process-host
				     efs-process-user
				     next))))
		    
		    (if efs-process-continue
			(let ((cont efs-process-continue))
			  (setq efs-process-continue nil)
			  (efs-call-cont
			   cont
			   efs-process-result
			   efs-process-result-line
			   efs-process-result-cont-lines))))
		  
		  ;; Update the mode line
		  ;; We can't test nowait to see if we changed the
		  ;; modeline in the first place, because conts
		  ;; may be running now, which will confuse the issue.
		  ;; The logic is simpler if we update the modeline
		  ;; before the cont, but then the user sees the
		  ;; modeline track the cont execution. It's dizzying.
		  (if (and (or efs-mode-line-format
			       efs-ftp-activity-function)
			   (null efs-process-busy))
		      (efs-update-mode-line)))))

	  ;; Trim buffer, if required.
	  (and efs-max-ftp-buffer-size
	       (zerop efs-process-cmd-counter)
	       (> (point-max) efs-max-ftp-buffer-size)
	       (= (point-min) 1) ; who knows, the user may have narrowed.
	       (null (get-buffer-window (current-buffer)))
	       (save-excursion
		 (goto-char (/ efs-max-ftp-buffer-size 2))
		 (forward-line 1)
		 (delete-region (point-min) (point))))))))



(defun efs-raw-send-cmd (proc cmd &optional msg pre-cont cont nowait)
;; Low-level routine to send the given ftp CMD to the ftp PROCESS.
;; MSG is an optional message to output before and after the command.
;; If PRE-CONT is non-nil, it is called immediately after execution
;; of the command starts, but without waiting for it to finish.
;; If CONT is non-NIL then it is either a function or a list of function and
;; some arguments.  The function will be called when the ftp command has 
;; completed.
;; If CONT is NIL then this routine will return \( RESULT . LINE \) where
;; RESULT is whether the command was successful, and LINE is the line from
;; the FTP process that caused the command to complete.
;; If NOWAIT is nil then we will wait for the command to complete before 
;; returning. If NOWAIT is 0, then we will wait until the command starts,
;; executing before returning. NOWAIT of 1 is like 0, except that the modeline
;; will indicate an asynch FTP command.
;; If NOWAIT has any other value, then we will simply queue the
;; command. In all cases, CONT will still be called

  (if (memq (process-status proc) '(run open))
      (efs-save-buffer-excursion
	(set-buffer (process-buffer proc))
	
	(if efs-process-busy
	    ;; This function will always wait on a busy process.
	    ;; Queueing is done by efs-send-cmd.
	    (let ((efs-process-cmd-waiting t))
	      (efs-kbd-quit-protect proc
		(while efs-process-busy
		  (accept-process-output)))))

	(setq efs-process-string ""
	      efs-process-result-line ""
	      efs-process-result-cont-lines ""
	      efs-process-busy t
	      efs-process-msg (and efs-verbose msg)
	      efs-process-continue cont
	      efs-process-server-confused nil
	      efs-process-nowait nowait
	      efs-process-hash-mark-count 0
	      efs-process-hash-mark-history (list (list 0 (current-time)))
	      efs-process-last-percent -1
	      efs-process-xfer-size 0
	      efs-process-cmd-counter (% (1+ efs-process-cmd-counter) 16))
	(process-kill-without-query proc t)
	(and efs-process-msg
	     (efs-message-p)
	     (efs-message "%s..." efs-process-msg))
	(goto-char (point-max))
	(move-marker comint-last-input-start (point))
	(move-marker comint-last-input-end (point))
	;; don't insert the password into the buffer on the USER command.
	(efs-save-match-data
	  (if (string-match efs-passwd-cmds cmd)
	      (insert (setq efs-process-cmd
			    (substring cmd 0 (match-end 0)))
		      " Turtle Power!\n")
	    (setq efs-process-cmd cmd)
	    (insert cmd "\n")))
	(process-send-string proc (concat cmd "\n"))
	(message "sending cmd>%s<" cmd)
	(set-marker (process-mark proc) (point))
	;; Update the mode-line
	(if (and (or efs-mode-line-format efs-ftp-activity-function)
		 (memq nowait '(t 1)))
	    (efs-update-mode-line))
	(if pre-cont
	    (let ((efs-nested-cmd t))
	      (save-excursion
		(apply (car pre-cont) (cdr pre-cont)))))
	(prog1
	    (if nowait 
		nil
	      ;; hang around for command to complete
	      ;; Some clients die after the command is sent, if the server
	      ;; times out. Don't wait on dead processes.
	      (efs-kbd-quit-protect proc
		(while (and efs-process-busy
			    ;; Need to recheck nowait, since it may get reset
			    ;; in a cont.
			    (null efs-process-nowait)
			    (memq (process-status proc) '(run open)))
		  (accept-process-output proc)
		  ;;; XXX davep ... play with delays here to let more
		  ;;; chars com thru.
		  ))
	      (message "got cmd>%s< output" cmd)
	      
	      ;; cont is called by the process filter
	      (if cont
		  ;; Return nil if a cont was called.
		  ;; Can't return process-result
		  ;; and process-line since executing
		  ;; the cont may have changed
		  ;; the state of the process buffer.
		  nil
		(list efs-process-result
		      efs-process-result-line
		      efs-process-result-cont-lines)))
	  
	  ;; If the process died, the filter would have never got the chance
	  ;; to call the cont. Try to jump start things.
	  
	  (if (and (not (memq (process-status proc) '(run open)))
		   (string-equal efs-process-result-line "")
		   cont
		   (equal cont efs-process-continue))
	      (progn
		(setq efs-process-continue nil
		      efs-process-busy nil)
		;; The process may be in some strange state. Get rid of it.
		(condition-case nil (delete-process proc) (error nil))
		(efs-call-cont cont 'fatal "" "")))))
    
    (error "FTP process %s has died." (process-name proc))))

(defun efs-process-handle-line (line proc)
  ;; Look at the given LINE from the ftp process PROC and try to catagorize it.
  (cond ((string-match efs-xfer-size-msgs line)
	 (let ((n 1))
	   ;; this loop will bomb with an args out of range error at 10
	   (while (not (match-beginning n))
	     (setq n (1+ n)))
	   (setq efs-process-xfer-size
		 (ash (string-to-int (substring line
						(match-beginning n)
						(match-end n)))
		    -10))))
	
	((string-match efs-multi-msgs line)
	 (setq efs-process-result-cont-lines
	       (concat efs-process-result-cont-lines line "\n")))
	
	((efs-skip-cmd-msg-p efs-process-cmd line))

	((string-match efs-cmd-ok-msgs line)
	 (message "ephl 1")
	 (if (string-match efs-cmd-ok-cmds efs-process-cmd)
	     (progn 
	       (message "ephl 1a")
	       (setq efs-process-busy nil
		     efs-process-result nil
		     efs-process-result-line line))))

	((string-match efs-pending-msgs line)
	 (message "ephl 2")
	 (if (string-match "^quote rnfr " efs-process-cmd)
	     (progn 
	       (message "ephl 2a")
	       (setq efs-process-busy nil
		     efs-process-result nil
		     efs-process-result-line line))))
	
	((string-match efs-bytes-received-msgs line)
	 (message "ephl 3")
	 (if efs-process-server-confused
	     (progn
	       (message "ephl 3a")
	       (setq efs-process-busy nil
		     efs-process-result nil
		     efs-process-result-line line))))
	
	((string-match efs-server-confused-msgs line)
	 (setq efs-process-server-confused t))

	((string-match efs-good-msgs line)
	 (message "ephl 4")
	 (message "chomped>%s<" chomped-line)
	 (setq chomped-line "")
	 (setq efs-process-busy nil
	       efs-process-result nil
	       efs-process-result-line line))

	((string-match efs-fatal-msgs line)
	 (message "ephl 5")
	 (set-process-sentinel proc nil)
	 (delete-process proc)
	 (setq efs-process-busy nil
	       efs-process-result 'fatal
	       efs-process-result-line line))
	
	((string-match efs-failed-msgs line)
	 (message "ephl 6")
	 (setq efs-process-busy nil
	       efs-process-result 'failed
	       efs-process-result-line line))
	
	((string-match efs-unknown-response-msgs line)
	 (message "ephl 7")
	 (setq efs-process-busy nil
	       efs-process-result 'weird
	       efs-process-result-line line)
	 (efs-process-scream-and-yell line))))
