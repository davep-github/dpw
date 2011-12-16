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
	    (efs-process-log-string proc str)
	    ;;(dmessage "str>%s<" str)
	    (if (string-match efs-process-prompt-regexp str)
		(setq efs-process-prompt-seen t))
	    (while (and efs-process-busy
			(string-match "\n" efs-process-string))
	      ;; get chars up to newline
	      (let ((line (substring efs-process-string
				     0
				     (match-beginning 0))))
		(setq efs-process-string (substring
					  efs-process-string
					  (match-end 0)))
		;; If we are in synch with the client, we should never
		;; get prompts in the wrong place. Just to be safe,
		;; chew them off.  dp: this may be, but there are
		;; cases where we get out of sync. It has been seen
		;; that a command can be issued before the ftp client
		;; has printed its next prompt.  The prompt
		;; 
		(while (string-match efs-process-prompt-regexp line)
		  (setq efs-process-prompt-seen t)
		  (setq line (substring line (match-end 0))))
		(efs-process-handle-line line proc)
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
	      efs-process-prompt-seen nil
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
	(if (and efs-ftp-broken-quote
		 (string-match efs-quoted-cmds cmd))
	    (setq cmd (efs-quote-percents cmd)))
	;; don't insert the password into the buffer on the USER command.
	(efs-save-match-data
	  (if (string-match efs-passwd-cmds cmd)
	      (insert (setq efs-process-cmd
			    (substring cmd 0 (match-end 0)))
		      " Turtle Power!\n")
	    (setq efs-process-cmd cmd)
	    (insert cmd "\n")))
	(process-send-string proc (concat cmd "\n"))
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
		(while (and (or efs-process-busy
				(not efs-process-prompt-seen)
				)
			    ;; Need to recheck nowait, since it may get reset
			    ;; in a cont.
			    (null efs-process-nowait)
			    (memq (process-status proc) '(run open)))
		  (accept-process-output proc)))
	      
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
(defvar efs-process-prompt-seen nil)
(make-variable-buffer-local 'efs-process-prompt-seen)
