? a
  b

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;; 'name 'corresponding-sym list-of-extensions dirs-in-which-to-look
(defvar dp-src-info 
  '('c 'h ("cc" "c" "cxx" "c++" "C") ("../src" "../source" "."))
  "Info about finding a source file.")

(defvar dp-h-info
'('h 'c ("hh" "h" "hxx" "h++" "H") ("../include" "../inc" "../h" ".")))

(defvar dp-file-infos (list dp-src-info dp-h-info))

(defun dp-classify-file (&optional file-name file-infos)
  "Figure out what kind of file this is."
  (interactive)
  (unless file-name
    (setq file-name (buffer-file-name)))
  (unless file-infos
    (setq file-infos dp-file-infos))
  (catch 'match
    ;; for-each info in file-infos
    (mapc (lambda (file-info)
	    ;; for-each suffix in info.suffixes
	    (mapc (lambda (suffix)
		    (let ((suffix-re 
			   (concat "\\." (regexp-quote suffix) "$")))
		      ;;(dmessage "suf>%s<, s-re>%s<" suffix suffix-re)
		      (if (string-match suffix-re file-name)
			  (throw 'match file-info))))
		  (nth 2 file-info)))
	  file-infos)
    nil))

(defun dp-find-corresponding-file (&optional file-info file-name)
  "Find the corresponding file, e.g. c --> h, h --> c"
  (interactive)
  (unless file-name
    (setq file-name (buffer-file-name)))
  (unless file-info
    (setq file-info (dp-classify-file file-name)))
  (let ((co-info (assoc (nth 1 file-info) dp-file-infos))
	(base-dir (file-name-directory file-name))
	(file (file-name-sans-extension (file-name-nondirectory file-name)))
	(file-fmt "%s%s/%s.%s")
	candidate)
    ;; find new name in list of dirs.  try all exts and all dirs
    (catch 'found-it
      (mapc (lambda (dir)
	      (mapc (lambda (ext)
		      (setq candidate (format file-fmt base-dir dir file ext))
		      ;;(dmessage "cand>%s<" candidate)
		      (if (file-exists-p candidate)
			  (throw 'found-it candidate)))
		    (nth 2 co-info)))
	    (nth 3 co-info))
      nil)))

(defun ecf (&optional file-name)
  "Edit the corresponding file."
  (interactive)
  (unless file-name
    (setq file-name (buffer-file-name)))
  (let ((co-file (dp-find-corresponding-file nil file-name)))
    (if co-file
	(find-file co-file)
      (error "Cannot find corresponding file of >%s<" file-name))))


(defun dp-c++-find-matching-paren ()
  (interactive)
  (if (looking-at "[<>]")
      (with-syntax-table c++-template-syntax-table
	(call-interactively 'dp-copied-from-vi-find-matching-paren))
    (call-interactively 'dp-copied-from-vi-find-matching-paren)))

(defun dp-copied-from-vi-find-matching-paren ()
  "\"Locate the matching paren.  It's a hack right now.\"
Also, if on a CPP conditional directive, find complementary part:
{if[xx]|else|elif} -> endif, endif -> if[xx]."
  (interactive)
  (dp-set-zmacs-region-stays t)
  (let (ifdef-item)
    (cond 
     ((looking-at "[[({<]") (forward-sexp 1) (backward-char 1))
     ((looking-at "[])}>]") (forward-char 1) (backward-sexp 1))
     ((setq ifdef-item (dp-get-ifdef-item))
      (cond
       ((or (eq ifdef-item 'dp-if)
	    (eq ifdef-item 'dp-else)
	    (eq ifdef-item 'dp-elif)) (hif-ifdef-to-endif))
       ((eq ifdef-item 'dp-endif) (hif-endif-to-ifdef))
       (t (ding))))
      (t (ding)))))

(defun tramp-open-connection-setup-interactive-shell
  (p multi-method method user host)
  (let ((coding-system-for-read 'binary))
    (tramp-open-connection-setup-interactive-shell-XXXX
       p multi-method method user host)))

(defun tramp-open-connection-setup-interactive-shell-XXXX
  (p multi-method method user host)
  "Set up an interactive shell.
Mainly sets the prompt and the echo correctly.  P is the shell process
to set up.  METHOD, USER and HOST specify the connection."
  ;; Wait a bit in case the remote end feels like sending a little
  ;; junk first.  It seems that fencepost.gnu.org does this when doing
  ;; a Kerberos login.
  (sit-for 1)
  (tramp-discard-garbage-erase-buffer p multi-method method user host)
  (insert "bob>\n")
  (message "buffer>%s<" (buffer-substring))
  (process-send-string nil (format "exec %s%s"
                                   (tramp-get-remote-sh multi-method method)
                                   tramp-rsh-end-of-line))
  (when tramp-debug-buffer
    (save-excursion
      (set-buffer (tramp-get-debug-buffer multi-method method user host))
      (goto-char (point-max))
      (tramp-insert-with-face
       'bold (format "$ exec %s\n" (tramp-get-remote-sh multi-method method)))))
  (tramp-message 9 "Waiting 30s for remote `%s' to come up..."
               (tramp-get-remote-sh multi-method method))
  (unless (tramp-wait-for-regexp p 30
                               (format "\\(\\$\\|%s\\)" shell-prompt-pattern))
    (pop-to-buffer (buffer-name))
    (error "Remote `%s' didn't come up.  See buffer `%s' for details"
           (tramp-get-remote-sh multi-method method) (buffer-name)))
  (tramp-message 9 "Setting up remote shell environment")
  (tramp-discard-garbage-erase-buffer p multi-method method user host)
  (process-send-string
   nil (format "stty -inlcr -echo kill '^U'%s" tramp-rsh-end-of-line))
  (unless (tramp-wait-for-regexp p 30
                               (format "\\(\\$\\|%s\\)" shell-prompt-pattern))
    (pop-to-buffer (buffer-name))
    (error "Couldn't `stty -echo', see buffer `%s'" (buffer-name)))
  (erase-buffer)
  (process-send-string nil (format "TERM=dumb; export TERM%s"
                                   tramp-rsh-end-of-line))
  (unless (tramp-wait-for-regexp p 30
                                 (format "\\(\\$\\|%s\\)" shell-prompt-pattern))
    (pop-to-buffer (buffer-name))
    (error "Couldn't `TERM=dumb; export TERM', see buffer `%s'" (buffer-name)))
  ;; Try to set up the coding system correctly.
  ;; CCC this can't be the right way to do it.  Hm.
  (save-excursion
    (erase-buffer)
    (tramp-message 9 "Determining coding system")
    (process-send-string nil (format "echo foo ; echo bar %s"
                                     tramp-rsh-end-of-line))
    (unless (tramp-wait-for-regexp
             p 30 (format "\\(\\$\\|%s\\)" shell-prompt-pattern))
      (pop-to-buffer (buffer-name))
      (error "Couldn't `echo foo; echo bar' to determine line endings'"))
    (goto-char (point-min))
    (if (featurep 'mule)
        ;; Use MULE to select the right EOL convention for communicating
        ;; with the process.
        (let* ((cs (or (process-coding-system p) (cons 'undecided 'undecided)))
               cs-decode cs-encode)
          (when (symbolp cs) (setq cs (cons cs cs)))
          (setq cs-decode (car cs))
          (setq cs-encode (cdr cs))
          (unless cs-decode (setq cs-decode 'undecided))
          (unless cs-encode (setq cs-encode 'undecided))
          (setq cs-encode (tramp-coding-system-change-eol-conversion
                           cs-encode 'unix))
          (when (search-forward "\r" nil t)
            (setq cs-decode (tramp-coding-system-change-eol-conversion
                             cs-decode 'dos)))
          (set-buffer-process-coding-system cs-decode cs-encode))
      ;; Look for ^M and do something useful if found.
      (when (search-forward "\r" nil t)
        ;; We have found a ^M but cannot frob the process coding system
        ;; because we're running on a non-MULE Emacs.  Let's try
        ;; stty, instead.
        (tramp-message 9 "Trying `stty -onlcr'")
        (process-send-string nil (format "stty -onlcr%s" tramp-rsh-end-of-line))
        (unless (tramp-wait-for-regexp
                 p 30
                 (format "\\(\\$\\|%s\\)" shell-prompt-pattern))
          (pop-to-buffer (buffer-name))
          (error "Couldn't `stty -onlcr', see buffer `%s'" (buffer-name))))))
  (erase-buffer)
  (tramp-message
   9 "Waiting 30s for `HISTFILE=$HOME/.tramp_history; HISTSIZE=1'")
  (process-send-string
   nil (format "HISTFILE=$HOME/.tramp_history; HISTSIZE=1%s"
               tramp-rsh-end-of-line))
  (unless (tramp-wait-for-regexp
           p 30
           (format "\\(\\$\\|%s\\)" shell-prompt-pattern))
    (pop-to-buffer (buffer-name))
    (error (concat "Couldn't `HISTFILE=$HOME/.tramp_history; "
                   "HISTSIZE=1', see buffer `%s'")
           (buffer-name)))
  (erase-buffer)
  (tramp-message 9 "Waiting 30s for `set +o vi +o emacs'")
  (process-send-string
   nil (format "set +o vi +o emacs%s"      ;mustn't `>/dev/null' with AIX?
               tramp-rsh-end-of-line))
  (unless (tramp-wait-for-regexp
           p 30
           (format "\\(\\$\\|%s\\)" shell-prompt-pattern))
    (pop-to-buffer (buffer-name))
    (error "Couldn't `set +o vi +o emacs', see buffer `%s'"
           (buffer-name)))
  (erase-buffer)
  (tramp-message 9 "Waiting 30s for `unset MAIL MAILCHECK MAILPATH'")
  (process-send-string
   nil (format "unset MAIL MAILCHECK MAILPATH 1>/dev/null 2>/dev/null%s"
               tramp-rsh-end-of-line))
  (unless (tramp-wait-for-regexp
           p 30
           (format "\\(\\$\\|%s\\)" shell-prompt-pattern))
    (pop-to-buffer (buffer-name))
    (error "Couldn't `unset MAIL MAILCHECK MAILPATH', see buffer `%s'"
           (buffer-name)))
  (erase-buffer)
  (tramp-message 9 "Waiting 30s for `unset CDPATH'")
  (process-send-string
   nil (format "unset CDPATH%s" tramp-rsh-end-of-line))
  (unless (tramp-wait-for-regexp
           p 30
           (format "\\(\\$\\|%s\\)" shell-prompt-pattern))
    (pop-to-buffer (buffer-name))
    (error "Couldn't `unset CDPATH', see buffer `%s'"
           (buffer-name)))
  (erase-buffer)
  (insert "bob>\n")
  (message "buffer[%s]>%s<" (buffer-name) (buffer-substring))
  (tramp-message 9 "Setting shell prompt")
  (tramp-send-command
   multi-method method user host
   (format "PS1='1%s2%s3%s6'; PS2=''; PS3=''"
           tramp-rsh-end-of-line
           tramp-end-of-output
           tramp-rsh-end-of-line))
  (message "2,buffer[%s]>%s<" (buffer-name) (buffer-substring))
  (tramp-wait-for-output)
  (error "prompt done")
  (tramp-send-command multi-method method user host "echo hello")
  (tramp-message 9 "Waiting for remote `%s' to come up..."
               (tramp-get-remote-sh multi-method method))
  (unless (tramp-wait-for-output 5)
    (unless (tramp-wait-for-output 5)
      (pop-to-buffer (buffer-name))
      (error "Couldn't set remote shell prompt.  See buffer `%s' for details"
             (buffer-name))))
  (tramp-message 7 "Waiting for remote `%s' to come up...done"
               (tramp-get-remote-sh multi-method method)))

(defun tramp-wait-for-output (&optional timeout)
  "Wait for output from remote rsh command.XXXXXXXXXXXXXXXXXXXx"
  (message "tramp-wait-for-output, bn>%s< buf>%s<" (buffer-name)
	   (buffer-substring))
  (let ((proc (get-buffer-process (current-buffer)))
        (found nil)
        (start-time (current-time))
        (end-of-output (concat "^"
                               (regexp-quote tramp-end-of-output)
                               "$")))
    ;; Algorithm: get waiting output.  See if last line contains
    ;; end-of-output sentinel.  If not, wait a bit and again get
    ;; waiting output.  Repeat until timeout expires or end-of-output
    ;; sentinel is seen.  Will hang if timeout is nil and
    ;; end-of-output sentinel never appears.
    (save-match-data
      (cond (timeout
             ;; Work around an XEmacs bug, where the timeout expires
             ;; faster than it should.  This degenerates into polling
             ;; for buggy XEmacsen, but oh, well.
             (while (and (not found)
                         (< (tramp-time-diff (current-time) start-time)
                            timeout))
               (with-timeout (timeout)
                 (while (not found)
                   (accept-process-output proc 1)
                   (goto-char (point-max))
                   (forward-line -1)
                   (setq found (looking-at end-of-output))))))
            (t
             (while (not found)
               (accept-process-output proc 1)
               (goto-char (point-max))
               (forward-line -1)
               (setq found (looking-at end-of-output))))))
    ;; At this point, either the timeout has expired or we have found
    ;; the end-of-output sentinel.
    (when found
      (goto-char (point-max))
      (forward-line -2)
      (delete-region (point) (point-max)))
    ;; Add output to debug buffer if appropriate.
    (when tramp-debug-buffer
      (append-to-buffer
       (tramp-get-debug-buffer tramp-current-multi-method tramp-current-method
                             tramp-current-user tramp-current-host)
       (point-min) (point-max))
      (when (not found)
        (save-excursion
          (set-buffer
           (tramp-get-debug-buffer tramp-current-multi-method tramp-current-method
                                 tramp-current-user tramp-current-host))
          (goto-char (point-max))
          (insert "[[Remote prompt `" end-of-output "' not found"
                  (if timeout (concat " in " timeout " secs") "")
                  "]]"))))
    (goto-char (point-min))
    ;; Return value is whether end-of-output sentinel was found.
    found))

(defun tramp-get-buffer (multi-method method user host)
  "Get the connection buffer to be used for USER at HOST using METHOD."
  (let ((coding-system-for-read 'binary))
    (get-buffer-create (tramp-buffer-name multi-method method user host))))

(defun tramp-maybe-open-connection (multi-method method user host)
  "Maybe open a connection to HOST, logging in as USER, using METHOD.
Does not do anything if a connection is already open, but re-opens the
connection if a previous connection has died for some reason."
  (message "YOPP99!")
  (let ((coding-system-for-read 'binary))
    (let ((p (get-buffer-process 
	      (tramp-get-buffer multi-method method user host))))
      (unless (and p
		   (processp p)
		   (memq (process-status p) '(run open)))
	(when (and p (processp p))
	  (delete-process p))
	(funcall (tramp-get-connection-function multi-method method)
		 multi-method method user host)))))


(defun tramp-get-buffer (multi-method method user host)
  "Get the connection buffer to be used for USER at HOST using METHOD."
  (let ((coding-system-for-read 'binary)
	(coding-system-for-write 'binary)
	(bname (tramp-buffer-name multi-method method user host)))
    (message "tg>%s<" bname)
    (message "buf>%s<" (get-buffer bname))
    (get-buffer-create (tramp-buffer-name multi-method method user host))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
////////////////////////////////////////////////////////
(setq re1 "=========================[
][0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}T[0-9]\\{2\\}:[0-9]\\{2\\}:[0-9]\\{2\\}[
]\\(.*sp.*\\)[
]--[
]")

(setq re2 ".*sp.*")

(defun dp-find-topic4 (topic-re &optional count)
  (re-search-forward topic-re nil t count)
  (message "match-data>%s<" (match-data))
  (message "bms0>%s<" 
	   (buffer-substring (match-beginning 0) (+ (match-beginning 0) 1)))
  (message "cms0>%s<" 
	   (buffer-substring (match-beginning 0) (+ (match-beginning 0) 1)))
  (message "match-data>%s<" (match-data))
  (message "dms0>%s<" 
	   (buffer-substring (match-beginning 0) (+ (match-beginning 0) 1)))
  (message "ems0>%s<" 
	   (buffer-substring (match-beginning 0) (+ (match-beginning 0) 1))))

(progn 
  (dp-find-topic4 re1)
  (message "Fms0>%s<, mb0>%s<" (match-string 0) (match-beginning 0))
  (message "Gms0>%s<, mb0>%s<" (match-string 0) (match-beginning 0))
  (message "Hms0>%s<, mb0>%s<" (match-string 0) (match-beginning 0))
  (message "Ims0>%s<, mb0>%s<" (match-string 0) (match-beginning 0))
  (message "Jms0>%s<, mb0>%s<" (match-string 0) (match-beginning 0)))


=========================
2002-01-20T12:30:19
journal elisp devel
--
things are moving along.

=========================
2002-01-20T12:34:50
a topic with spaces
--
this requires C-q<space> for spaces.

(if (featurep 'xpm)
    (let ((file (expand-file-name "recycle.xpm" data-directory)))
      (if (condition-case nil
	      ;; check to make sure we can use the pointer.
	      (make-image-instance file nil
				   '(pointer))
	    (error nil))		; returns nil if an error occurred.
	  (set-glyph-image gc-pointer-glyph file))))

(defun term-send-raw ()
  "Send the last character typed through the terminal-emulator
without any interpretation." 
  (interactive)

  (message "boo!")
  (term-if-xemacs
   (if (key-press-event-p last-input-event)
       (let ((mods (event-modifiers last-input-event))
 	     (key (event-key last-input-event))
 	     meta)
	 (message "1mods>%s<, key>%s<" mods key)
 	 (if (memq 'meta mods)
	     (progn
	       (message "2")
	       (setq meta t)
	       (setq mods (delq 'meta mods))))
	 (message "1a")
	 (let ((ascii (event-to-character (character-to-event
					   (append mods (list key)))
					  t ;; lenient
					  nil ;; no meta mucking
					  t ;; allow non-ASCII
					  )))
	   (message "ascii>%s<" ascii)
	   (cond (ascii
		  (if meta
		      (progn
			(term-send-raw-string (format "\e%c" ascii))
			(message "3>%s<" (format "\e%c" ascii)))
		    (message "4>%s<" ascii)
		    (term-send-raw-string (make-string 1 ascii))))
		 (t 
		  ;; executed when C-backspace pressed
		  (message "kb>%s<" (key-binding last-input-event))
		  (command-execute (key-binding last-input-event))))))
     (message "5")
     (let ((cmd (lookup-key (current-global-map) (this-command-keys))))
       (and cmd (call-interactively cmd)))))

  (term-ifnot-xemacs
   ;; Convert `return' to C-m, etc.
   (if (and (symbolp last-input-char)
	    (get last-input-char 'ascii-character))
       (setq last-input-char (get last-input-char 'ascii-character)))
   (term-send-raw-string (make-string 1 last-input-char))))

(defmacro dp-i-test ()
  (interactive)
  (dmessage "i , i-p>%s< prefix>%s<" (interactive-p)
	    current-prefix-arg))

(defun dp-i-test2 ()
  (interactive)
  (dp-i-test)
  (dmessage "i2, i-p>%s< prefix>%s<" (interactive-p)
	    current-prefix-arg))

(defun dp-re-concat (old new)
  "Concatenate old and new into an re that matches either."
  (if (and old new)
      (format "\\(%s\\)\\|%s" old new)
    (or old new)))

(dp-re-concat "\\(aa\\)\\|bb" "cc")
"\\(\\(aa\\)\\|bb\\)\\|cc"


(defun dp-buffer-bracketed-substring (open close 
					   &optional left-limit right-limit)
  "Return substring bracketed by open and close."
  (interactive "sopen: \nsclose: ")
  (let (start end)
    (unless left-limit (setq left-limit (line-beginning-position)))
    (unless right-limit (setq right-limit (line-end-position)))
    (unless (looking-at open)
      (re-search-backward open left-limit))
    (setq start (1+ (match-end 0)))
    (re-search-forward close right-limit)
    (setq end (1- (match-beginning 0)))
    (buffer-substring start end)))
  
    <<aaaaabbbbbbbbcccccccc>>x
;; booger

;; is this useful? Well?
(defun dp-last-edit-position ()
  "Determine position of last edit."
  (interactive)
  (if (eq buffer-undo-list t)
      (error "No undo information in this buffer"))
  (let ((ul buffer-undo-list)
	undo-item undo-car
	pos stat)
    (setq stat
	  (catch 'done
	    (while ul
	      (setq undo-item (car ul)
		    undo-car  (car-safe undo-item)
		    ul (cdr ul))
	      (cond
	       ((integerp undo-item) (setq pos undo-item))
	       ((integerp undo-car)  (setq pos undo-car))
	       ((stringp undo-car)   (setq pos (cdr undo-item)))
	       ((eq undo-car t)      (setq pos (car (car undo-item)))))
	      (when pos
		;;(goto-char pos)
		(message "ui: %s, uc: %s, pos: %d" undo-item undo-car pos)
		(throw 'done pos)))
	    nil))
    (unless stat
      (message "No location found in undo info."))
    stat))

;; NO GO... isn't called unless new frame differs from old frame
(defun dpj-select-frame-hook ()
  "Run when a frame, and windows within frame, are selected."
  (dmessage "dpj-select-frame-hook"))

(add-hook 'select-frame-hook 'dpj-select-frame-hook)
(remove-hook 'select-frame-hook 'dpj-select-frame-hook)
(default-select-frame-hook)


(ldeb "dpj")
(setq dpj-debug-control t)
(dpj-debug "%s" "blah")

(defun dp-consecutive-key-command (cmd-cursor cmd-list consecutive-command)
  (interactive)
    (if (eq last-command consecutive-command)
	(set cmd-cursor (cdr-safe (symbol-value cmd-cursor)))
      (set cmd-cursor cmd-list))
    (let ((cmd (car-safe (symbol-value cmd-cursor))))
      (when cmd
	(if (eq cmd (car cmd-list))
	    (dp-push-go-back))
	(funcall cmd))))

(defvar dp-brief-home-command-list `(beginning-of-line
				     ,(lambda () (move-to-window-line 0))
				     ,(lambda () 
					(dp-beginning-of-buffer 'no-save-pos)))
  "Commands to run based on number of consecutive keys pressed.")

(defvar dp-brief-home-command-ptr dp-brief-home-command-list
  "Command to run.")

(defun dp-brief-home ()
  "Go bol, bow, bof."
  (interactive)
  (dp-consecutive-key-command 'dp-brief-home-command-ptr
			      dp-brief-home-command-list
			      'dp-brief-home))

(defvar dp-brief-end-command-list `(end-of-line
				    ,(lambda () (move-to-window-line -1))
				    ,(lambda () 
				       (dp-end-of-buffer 'no-save-pos)))
  "Commands to run based on number of consecutive keys pressed.")

(defvar dp-brief-end-command-ptr dp-brief-end-command-list
  "Command to run.")

(defun dp-brief-end ()
  "Go eol, eow, eof."
  (interactive)
  (dp-consecutive-key-command 'dp-brief-end-command-ptr
			      dp-brief-end-command-list
			      'dp-brief-end))

(defadvice set-buffer (after maybe-re-process-topics activate)
  "Re-process topics when switching to a journal mode buffer."
    (dpj-maybe-re-process-topics dpj-last-process-topics-args))


(defmacro def-bounded-stack (stack &optional max)
  "Define a bounded stack.
MAX gives max size.  nil --> no limit."
  (list 'defvar stack `(cons ,max nil)))

(defun dp-push-onto-new-bounded-stack (bstack item)
  "Push ITEM onto the size bounded stack BSTACK.  
BSTACK is a bounded stack object, a cons (max . stack)."
  (let ((stack (cons item (cdr bstack)))
	(bound (car bstack)))
    (when (and bound 
	       (> (length stack) bound))
      (setcdr (nthcdr (1- bound) stack) nil))
    (setcdr bstack stack)))

(defun dp-pop-from-bounded-stack (bstack)
  (let* ((stack (cdr bstack))
	 (el (car-safe stack))
	 (nstack (cdr-safe stack)))
    (setcdr bstack nstack)
    el))
	     
(macroexpand '(def-bounded-stack bubba 4))
(defvar bubba (cons 4 nil))
(def-bounded-stack ts 3)

(dp-push-onto-new-bounded-stack ts 5)
(5 3 2)

(4 3 2)
ts
(3 5 3 2)

(dp-pop-from-bounded-stack ts)
4
ts
(3 3 2)

      ("File"
       :filter file-menu-filter      ; file-menu-filter is a function that takes
                                     ; one argument (a list of menu items) and
                                     ; returns a list of menu items
       [ "Save As..."    write-file]
       [ "Revert Buffer" revert-buffer :active (buffer-modified-p) ]
       [ "Read Only"     toggle-read-only :style toggle :selected buffer-read-only ]
       )

(defvar dpj-menu       
  '("Jrnl")
  "Menu for Journal mode.")

(defun dpj-define-key-and-add-to-menu (keys def menu-text 
					  &optional keymap menu-def)
  "Bind command to key and add to menu."
  (dpj-define-key keys def keymap)
  (when menu-text
    (let* ((menu-item (vector menu-text (or menu-def def)))
	   (prev-item (member menu-item dpj-menu)))
      (if prev-item
	  (setcar prev-item menu-item)
	(setq dpj-menu (nconc dpj-menu (list menu-item)))))))

(dpj-define-key-and-add-to-menu "\C-cd" 'dpj-todo-done "Complete todo")

("Jrnl" ["Complete todo" dpj-todo-done])

(dpj-define-key-and-add-to-menu "\C-ct" 'dpj-todo "Complete todo")
("Jrnl" ["Complete todo" dpj-todo-done] ["Complete todo" dpj-todo])

dpj-menu
("Jrnl" ["Complete todo" dpj-todo-done] ["Complete todo" dpj-todo])

    ["Prev in topic" dpj-prev-in-topic]
    ["Prev in topic..." dpj-prev-in-topic-menu-command]
    ["Next in topic" dpj-next-in-topic]
    ["Next in topic..." dpj-next-in-topic-menu-command]
    ["Prev topic" dpj-goto-topic-backward-with-file-wrap]
    ["Next topic" dpj-goto-topic-forward-with-file-wrap]
    ["Insert new topic..." dpj-new-topic]
    ["Clone current" dpj-clone-topic]
    ["Highlight current" dpj-highlight-current]
    ["Show current" dpj-show-current]
    ["Show topic..." dpj-show-topic-command]
    ["Show all" dpj-show-all]
    ["Insert todo..." dpj-todo]
    ["Complete todo" dpj-todo-done]
    ["Prev todo" dpj-prev-todo]
    ["Cancel todo" dpj-todo-cancelled]
    ["Show topic time" dpj-pretty-timestamp]
    ["Goto link" dpj-goto-link]
    ["Insert link" dpj-insert-link]

(defun dp-gen-cpp-cond-regexp (keyword-list)
  (concat "^#\\s-*\\("
	  (regexp-opt keyword-list)
	  "\\)"))
  
(defvar dp-cpp-cond-regexp 
  (dp-gen-cpp-cond-regexp '("if" "ifdef" "else" "elif" "endif"))
  "Regexp to recognize cpp conditionals.")

(defvar dp-cpp-endif "^#\\s-*endif"
  "Regexp to recognize endif.")

(defvar dp-cpp-if 
  (dp-gen-cpp-cond-regexp '("if" "ifdef"))
  "Regexp to recognize ifxxx conditionals.")
	  
(defface dp-cifdef-face0
  '((((class color) (background light)) 
     (:background "paleturquoise3"))) 
  "Colorized ifdef face"
  :group 'faces
  :group 'dp-vars)

(defface dp-cifdef-face1
  '((((class color) (background light)) 
     (:background "plum"))) 
  "Colorized ifdef face"
  :group 'faces
  :group 'dp-vars)

(defvar dp-colorize-ifdefs-colors
  '(dp-cifdef-face0 dp-cifdef-face1)
  "List of faces to cycle thru when colorizing cpp conditionals.")

(defun dp-get-next-cpp-cond ()
  "Find and return the next cpp conditional statement"
  (re-search-forward dp-cpp-cond-regexp)
  (match-string 0))

(defun dp-clear-all-extents ()
  "Clear all 'dp-extent type extents."
  (dp-delete-extents (point-min) (point-max) 'dp-extent))

(defun dp-colorize-ifdefs ()
  "Colorize parts of ifdef."
  (interactive)
  (let (regions 
	(colors dp-colorize-ifdefs-colors) 
	color start cpp-cond region)
    ;; remove any existing colorization
    (dp-delete-extents (point-min) (point-max) 'dp-cifdef)
    (beginning-of-line)
    (setq start (point))

    ;; get what should be an ifxxx ??? assert this ???
    (setq cpp-cond (dp-get-next-cpp-cond))
    (dmessage "cpp-cond>%s<" cpp-cond)
    (while (not (string-match dp-cpp-endif cpp-cond))
      (setq cpp-cond (dp-get-next-cpp-cond))
      (dmessage "cpp-cond>%s<" cpp-cond)
      (if (string-match dp-cpp-if cpp-cond)
	  (progn
	    ;; skip to end of ifxxx
	    (beginning-of-line)
	    (hif-ifdef-to-endif)
	    (end-of-line)
	    (forward-char))
	;; not an ifxxx, terminate current extent
	(beginning-of-line)
	(setq color (car colors)
	      colors (cdr colors))
	(unless colors
	  (setq colors dp-colorize-ifdefs-colors))
	(dp-make-extent start (point) 'dp-cifdef 'face color)

	;; start a new extent
	(setq start (point))
	(end-of-line)
	(forward-char)))))


(defun dp-list-minus-eq (list-in elt-in)
  (let ((ret (mapcar (lambda (elt)
		       (if (eq elt elt-in)
			   nil
			 elt))
		     list-in)))
    (delq nil ret)))

(dp-list-minus-eq '(a b c d) 'd)
(a b c)
(b c d)
(a b d)


l
v        l3
0->1->2->3->4->5
      ^
      l2
==>
3->4->5->0->1

(defun dp-delq-and-rotate (l-in m)
  "Delete M from a copy of l-in and return the list rotated s.t. cdr of m is the new head."
  (let* ((l (copy-list l-in))
	 (l2 (member m l))
	 l3 ret)
    (if l2
	(progn
	  (setq l3 (cdr l2))
	  (if l3
	      (progn
		(setcdr l2 nil)
		(setq ret (append l3 l)))
	    (setq ret l))
	  (delq m ret)
	  ret)
      (error "dp-delq-and-rotate: m not in l"))))


(dp-delq-and-rotate '(a b c d) 'z)

a->b->c->d->e
   ^  ^
  l3  l2

|>|>|>|>|>0
a b c d e
    ^
  l3l2

(defun dp-func-and-rotate2 (l-in m &optional func)
  "Delete M from a copy of L-IN and return the list rotated s.t. cdr of m is the new head."
  (let* ((l (copy-list l-in))
	 (l2 (member m l))
	 l3 ret)
    (if l2
	(progn
	  (if (not (eq l2 l))
	      (progn
		(setq l3 l)
		(while (not (eq (cdr l3) l2))
		  (setq l3 (cdr l3)))
		(setcdr l3 nil)
		(setq ret (append l2 l)))
	    (setq ret l))
	  (if func 
	      (setq ret (funcall func m ret)))
	  ret)
      (error "dp-func-and-rotate: m not in l"))))

(dp-func-and-rotate2 '(a b c d) 'd 'delq)
(a b c)

(d a b c)

(b c d)

(a b c d)


(b c d a)

      v
a->b->c->d->e
   l2

(defun dp-rotate-and-func (l-in m &optional func)
  "Rotate the list L-IN s.t. M is the new head, then apply FUNC."
  (let* ((l (copy-list l-in))
	 l2 l3 
	 (ret
	  (if (equal (car l) m)
	      l
	    (setq l2 l)
	    (while (and (setq l3 (cdr l2))
			(not (equal m (car l3))))
	      (setq l2 l3))
	    (if (not l3)
		(error "dp-func-and-rotate: %s not in %s" m l)  
	      (setcdr l2 nil)
	      (append l3 l)))))
    (if func
	(funcall func m ret)
      ret)))
dp-func-and-rotate

(dp-func-and-rotate '(a b c d) 'e 'delq)

(c d a)


(b c d a)


(macroexpand '(def-bounded-stack bubba 4))
(macroexpand '(def-gdb "step"   "\M-s" "Step one source line with display"
  (gdb-delete-arrow-extent)))
(progn (defun gdb-step (arg) "Step one source line with display" (interactive "p") (gdb-call (if (not (= 1 arg)) (format "%s %s" "step" arg) "step")) (gdb-delete-arrow-extent)) (define-key gdb-mode-map "ó" (quote gdb-step)))

(def-debug "prefix")
-->
(defvar prefix-debug-on-p nil)
(defun prefix-debug fmt &rest args
  "Debug func for prefix."
  (when prefix-debug-on-p
    (apply 'message (concat "prefix: " fmt) args)))

(defmacro def-debug (prefix)
  (let ((fun (intern (format "%s-dmessage" prefix)))
	(docstr (format "Debug func for %s." prefix))
	(prefix-str (format "%s: " prefix)))
    (list 'defun fun '(fmt &rest args)
	  docstr
	  (list 'apply (list 'quote 'message) (list 'concat prefix-str 'fmt) 'args))))
def-debug

(macroexpand '(def-debug "boo"))

(defun boo-dmessage (fmt &rest args) "Debug func for boo." (apply (quote message) (concat "boo: " fmt) args))
boo-dmessage
(boo-dmessage "hello %s" "world")
"boo: hello world"

(defmacro def-pkg-dmessage (&optional prefix-in)
  "Define a pkg/file specific dmessage func and control var."
  (let* ((prefix (or prefix-in
		     (file-name-sans-extension 
		      (file-relative-name (buffer-file-name)))))
	 (fun (intern (format "%s-dmessage" prefix)))
	 (var (intern (format "%s-dmessage-on-p" prefix)))
	 (func-docstr (format "dmessage func for %s." prefix))
	 (var-docstr (format "dmessage control var for %s." prefix))
	 (prefix-str (format "%s: " prefix)))
    `(progn
       (defvar ,var nil ,var-docstr)
       (defun ,fun (fmt &rest args)
	 ,func-docstr
	 (if ,var
	     (apply (quote message) (concat ,prefix-str fmt) args))))))

def-pkg-dmessage

    (list 'progn
	  (list 'defvar var nil var-docstr)
	  (list 'defun fun '(fmt &rest args)
		func-docstr
		(list 'if var
		      (list 'apply (list 'quote 'message) 
			    (list 'concat prefix-str 'fmt) 'args))))))
def-debug

(pprint (macroexpand '(def-pkg-dmessage "boo")))
(progn
  (defvar boo-dmessage-on-p nil "dmessage control var for boo.")
  (defun boo-dmessage (fmt &rest args)
    "dmessage func for boo."
    (if boo-dmessage-on-p
	(apply 'message (concat "boo: " fmt) args))))
boo-dmessage


(progn
  (defvar boo-dmessage-on-p nil "dmessage control var for boo.")
  (defun boo-dmessage (fmt &rest args)
    "dmessage func for boo."
    (if boo-dmessage-on-p
	(apply (quote message) (concat "boo: " fmt) args))))
boo-dmessage

(setq boo-dmessage-on-p t)
t

nil

t

(boo-dmessage "hello %s" 'boo)
"boo: hello boo"

nil

"boo: hello boo"

"boo: hello boo"

(intern (format "%s" (file-relative-name (buffer-file-name))))
elisp-devel\.el

"elisp-devel.el"


(macroexpand '(def-pkg-dmessage))
(progn 
  (defvar elisp-devel-dmessage-on-p nil "Debug control var for elisp-devel.") 
  (defun elisp-devel-dmessage (fmt &rest args) 
    "Debug func for elisp-devel." 
    (if elisp-devel-dmessage-on-p 
	(apply (quote message) (concat "elisp-devel: " fmt) args))))
elisp-devel-dmessage

(setq elisp-devel-dmessage-on-p t)
(elisp-devel-dmessage "hello" 'xxx)
"elisp-devel: hello"


      (let (comment-column)
	(set-comment-column 'align-with-previous)))

(defun dp-lineup-comments (begin end)
  "Line up all comments in region to current column."
  (interactive "*r")
  (let ((comment-column (current-column)))
    (goto-char begin)
    (while (<= (point) end)
      (beginning-of-line)
      (indent-for-comment)
      (next-line 1))))
  

(defmacro moo (a b)
  (list a b))
moo


(macroexpand '(moo boo buu))
(boo buu)

(defvar dp-ID-file nil
  "File that holds the ID database file name.")
(make-variable-buffer-local 'dp-ID-file)

(defvar dp-ID-file-alist nil)

(defun dp-assoc-regexp (key regexp-alist)
  "Find KEY in REGEXP-ALIST.
REGEXP-ALIST is (regexp . whatever).  When matched, whatever is returned."
  (catch 'result
    (mapc (lambda (el)
	    (if (string-match (car el) key)
		(throw 'result el)))
	  regexp-alist)
    nil))

(defun dp-search-up-dir-tree (start-dir file-name)
  "Search for FILE-NAME up dir tree beginning at START-DIR."
  (if (string-match "/$" start-dir)
      (setq start-dir (substring start-dir 0 -1)))
  (catch 'found
    (let ((dir-list (split-string start-dir "/"))
	  path-name)
      (while dir-list
	(setq path-name (format "%s/%s" 
				(dp-string-join dir-list "/")
				file-name))
	(dmessage "pn>%s<" path-name)
	(if (file-exists-p path-name)
	  (throw 'found path-name))
	(setq dir-list (butlast dir-list)))
      nil)))

(defun dp-find-util-data-file (result-sym file-name &optional 
					  location-alist 
					  start-dir
					  ignore-current)
  "Look for the ID file. 
RESULT-SYM is a place to store the result.  It will be used if non-nil.
FILE-NAME is the name of the data file for which to search.
LOCATION-ALIST is an alist of like `tag-table-alist'.
IGNORE-CURRENT says to ignore the value of RESULT-SYM."
  ;; if buffer-local dp-ID-file is found, return it
  ;; else try to match the cwd against the dp-ID-file-alist
  ;; else if that doesn't work, walk up the dir tree to /
  ;; set and return buffer-local dp-ID-file
  (let* ((start-dir (expand-file-name (or start-dir (default-directory))))
	 (id-file (cond 
		   ((and (not ignore-current) (symbol-value result-sym)))
		   ((and location-alist 
			 (setq id-file (cdr-safe (dp-assoc-regexp 
						  start-dir
						  location-alist))))
		    (concat id-file file-name))
		   ((dp-search-up-dir-tree start-dir file-name)))))
    (set result-sym id-file)))

(defun dp-find-id-utils-ID-file (&optional start-dir ignore-current)
  "Find the id-utils' ID file."
  (dp-find-util-data-file 'dp-ID-file "ID" dp-ID-file-alist start-dir t))

(dp-find-id-utils-ID-file)
"/home/davep/lisp/ID"



(dp-find-id-utils-ID-file)
"/home/davep/lisp/ID"

(dp-search-up-dir-tree (expand-file-name (default-directory)) "kernel")
"/kernel"

"/kernel"

(expand-file-name (default-directory))
"/home/davep/lisp/"

(dp-find-util-data-file 'dp-ID-file "kernel" nil t)
"/kernel"







nil

nil

"~/lisp/ID"

"~/lisp/ID"

"~/lisp/ID"




(expand-file-name (default-directory))

(expand-file-name "//home//davep/lisp/")
"//home//davep/lisp/"

(cond
 ("boo")
 ("zoo"))
"boo"




(substring "1234" 0 -1)
"123"


(setq rel '(("^a.*b$" . "one")
	    ("aa.*bb" . "two")))
(("^a.*b$" . "one") ("aa.*bb" . "two"))

(dp-assoc-regexp "ab" rel)
("^a.*b$" . "one")

"one"
nil
"one"

(dp-in-regexp-alist "aaabbc" rel)
"two"

nil

"one"

(split-string "/a/b/c" "/")

(dp-string-join '("" "a" "b" "c") "/")
"/a/b/c"

(defun dpj-resolve-action-item (&optional resolution-char)
  (interactive)
  (unless resolution-char
    (setq resolution-char (if prefix-arg "-" "=")))
  (save-excursion
    (let (prefix)
      (previous-line 1)
      (beginning-of-line)
      (if (not (looking-at "^[?!]+[ 	]+"))
	  (error "No preceding action item"))
      (setq prefix (regexp-quote (match-string 0)))
      (beginning-of-line)
      (while (looking-at prefix)
	(insert resolution-char)
	(previous-line 1)
	(beginning-of-line))))
  (insert resolution-char resolution-char "> "))
dpj-resolve-action-item

(defalias 'ri 'dpj-resolve-action-item)
dpj-resolve-action-item



(defvar dpj-any-AI-regexp "^[?!]+[ 	]+")

(defun dpj-span-action-item ()
  "Return boundaries of current or immediately preceding action item."
  (save-excursion
    (let (begin end prefix)
      (end-of-line)
      (re-search-backward dpj-any-AI-regexp)
      (setq prefix 
	    (concat "^" (filladapt-convert-to-spaces (match-string 0)) "[^ 	
]+?$"))
      (setq begin (point))
      ;; search fw for end
      (forward-line 1)
      (beginning-of-line)
      (setq end (point))
      (catch 'done
	(while t
	  (unless (re-search-forward prefix (line-end-position) t)
	    (throw 'done nil))
	  ;; end tracks last successful match
	  (setq end (line-end-position))
	  (if (= (forward-line 1) 1)
	      (throw 'done nil))
	  (beginning-of-line)))
      (cons begin end))))
dpj-span-action-item

(defun dpj-mark-action-item ()
  (interactive)
  (let* ((reg (dpj-span-action-item))
	 (begin (car reg))
	 (end (cdr reg)))
    (dp-set-mark begin)
    (goto-char end)
    (dp-activate-mark)))

? a
  b
  c
  d
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!



! hi there
  dd ss 
  ee
  ff

! PROBLEM: no highlighting on subsequent lines.
  here is an example of the new style.  this is unhighlighted
  this may actually be cleaner.  Title + body

! aa
! bb
! cc
  more cc stuff
    more deeply indented cc stuff


(defun dpj-span-action-item ()
  "Return boundaries of current or immediately preceding action item."
  (save-excursion
    (let (begin prefix
		(end (save-excursion
		       (beginning-of-line)
		       (if (looking-at "^\\s-*$")
			   (point)
			 nil))))
      (end-of-line)
      (re-search-backward adpj-any-AI-regexp)
      (setq begin (point))
      (if end
	  ;; end is already set
	  (goto-char end)		
	;; find first lesser-indented or empty line
	(setq prefix (filladapt-convert-to-spaces (match-string 0)))
	(forward-line 1)
	(beginning-of-line)
	(setq end (point))
	(catch 'done
	  (while t
	    (setq end (point))
	    (unless (re-search-forward prefix (line-end-position) t)
	      (throw 'done nil))
	    ;; so/e line???
	    (if (looking-at "^\\s-*$")
		(throw 'done-nil))
	    ;; try to move down a line
	    (if (= (forward-line 1) 1)
		(throw 'done nil))
	    (if (eobp)
		(throw 'done nil))
	    (beginning-of-line))))
      (beginning-of-line)
      (backward-char 1)
      
      (cons begin end))))
dpj-span-action-item


(defun dpj-electric-resolve-action-item (resolution-char)
  (interactive)
  (if (and (bolp) (looking-at dpj-any-AI-regexp))
      (dpj-resolve-action-item resolution-char)
    (insert resolution-char)))

dpj-electric--
    
	   
=!! boo
   a boo item. deal with it.
==> 

(defun dp-isearch-for (s &optional backwards)
  "Do an isearch primed with S.  BACKWARDS says to search backwards initially."
  (interactive "sPat: ")
  (isearch-mode (not backwards))
  (setq isearch-string s
	isearch-message (mapconcat 'isearch-text-char-description
				   isearch-string ""))
  (isearch-search)
  (isearch-update))

(defun pydoc-topics (argument)
  "Prompt with completion for a Python topic ARGUMENT and display its documentation."
  (interactive
   (list
    (let ((completion-ignore-case t))
      (completing-read "Python topic help (RET for all): "
		       (cdr (assoc "topics" pydoc-alist))
		       nil t))))
  (if (member argument '(nil ""))
      (setq argument "topics")
    (setq argument (upcase argument)))
  (pydoc-call "help" (format "'%s'" argument) argument))

(cdr (assoc "topics" pydoc-alist))
nil
pydoc-alist
nil

(defun dp-point-follows-regexp (regexp &optional same-line-only)
  (save-excursion
    (let ((p (point)))
      (if (re-search-backward regexp (if same-line-only
					 (line-beginning-position)
				       nil)
			      t)
	  (eq p (match-end 0))))))


	   <spaces and tabs>
,,,,,

(defun dp-start-term (prompt-for-shell-program-p)
  "Start up a terminal session, but first set the coding system so eols are 
handled right."
  (interactive "P")
  (let ((coding-system-for-read 'undecided-unix)
	(prog-name (or
		    explicit-shell-file-name
		    (getenv "ESHELL")
		    (getenv "SHELL"))))
    (if (or prompt-for-shell-program-p
	    (not prog-name))
	  (call-interactively 'term)
      (term prog-name))))

(defun dp-rsh ()
  "Start up a terminal session, but first set the coding system so eols are 
handled right."
  (interactive)
  (let ((coding-system-for-read 'undecided-unix))
    (call-interactively 'rsh)))
dp-rsh

(defun dpj-add-abbrev (name topic)
  (interactive (list (read-from-minibuffer "name: ")
		     (dpj-read-topic)))
  (define-abbrev dp-journal-mode-abbrev-table name topic)
  (setq dpj-abbrev-list-modified-p t))

blah2:

todo:

blah1:

skipping non-todos
(hack!)
"^[^t][^o][^d][^o][^:]"

(defsubst dpj-not-a-todo (unused-arg topic-str)
  (interactive)
  (not (string-match dpj-todo-re topic-str)))


(defun dp-mew-draft-cite (&optional arg force)
  (interactive)
  (turn-off-filladapt-mode)
  (call-interactively 'mew-draft-cite)
  (turn-on-filladapt-mode))

(defun dp-Info-mode-hook ()
  (local-set-key (kbd "C--") 'Info-last))
dp-Info-mode-hook

(add-hook 'Info-mode-hook 'dp-Info-mode-hook)
(dp-Info-mode-hook)

(defun display-time-convert-num (time-string &optional textual)
  (let ((list (display-time-string-to-char-list time-string))
	elem tmp balloon-help balloon-ext)
    (if (not (display-time-can-do-graphical-display textual)) time-string 
      (display-time-generate-time-glyphs)
      (setq balloon-help
	    (format "%s, %s %s %s %s" dayname day monthname year
		    (concat "   Average load:"
			    (if (not (equal load ""))
				load
			      " 0"))))
      (setq balloon-ext (make-extent 0 (length balloon-help) balloon-help))
      (set-extent-property balloon-ext 'face 'display-time-time-balloon-face)
      (set-extent-property balloon-ext 'duplicable 't)
      (while (setq elem (pop list))
	(setq elem
	      (eval (intern-soft (concat "display-time-"
					 (char-to-string elem)
					 "-glyph"))))
	(set-extent-property (car elem) 'balloon-help balloon-help)
	(set-extent-property (car elem) 'help-echo 
			     (format "%s %s %s, %s" 
				     dayname monthname day year))

;;;	(set-extent-keymap (car elem) display-time-keymap)
	(push elem tmp))
      (reverse tmp))))

(setq bufs (buffers-tab-items))
(["*scratch*" (buffers-tab-switch-to-buffer "*scratch*") :selected t] ["gutter-items.el" (buffers-tab-switch-to-buffer "gutter-items.el") :selected nil])

(aref (car bufs) 0)
"*scratch*"

;; @todo needs to go to next with wrap after selected
(defun dp-next-in-tab-list ()
  (interactive)
  (let* ((buf-list0 (buffers-tab-items))
	 (buf-list buf-list0)
	 buf
	 obuf)
    (setq obuf 
	  (car-safe 
	   (catch 'done
	     (while buf-list
	       (setq buf (car buf-list))
	       (if (aref buf 2)
		   (if (cdr buf-list)
		       (throw 'done (cdr buf-list))
		     (throw 'done (cdr buf-list0)))
		 (message "looping")
		 (setq buf-list (cdr buf-list)))))))))
dp-next-in-tab-list

(dp-next-in-tab-list)
["dpmisc.el" (buffers-tab-switch-to-buffer "dpmisc.el") :selected nil]


(buffers-tab-items)
(["elisp-devel.el" (buffers-tab-switch-to-buffer "elisp-devel.el") :selected t] ["dpmisc.el" (buffers-tab-switch-to-buffer "dpmisc.el") :selected nil] ["*scratch*" (buffers-tab-switch-to-buffer "*scratch*") :selected nil] ["gutter-items.el" (buffers-tab-switch-to-buffer "gutter-items.el") :selected nil])

"*scratch*"

	 



(defun fill-paragraph-or-region (arg)
  "Fill the current region, if it's active; otherwise, fill the paragraph.
See `fill-paragraph' and `fill-region' for more information."
  (interactive "*P")
  (message "z:%s" zmacs-region-active-p)
  (message "r:%s" (region-active-p))
  (if (or zmacs-region-active-p
	  (region-active-p))
      (progn
	(message "YOPP!")
	(message "p:%s, m:%s." (point) (mark))
	(if (> (point) (mark))
	    (exchange-point-and-mark))
	(fill-region (point) (mark) arg))
    (fill-paragraph arg)))

=================================================================
    (setq mew-refile-guess-alist
          '(("To:" 
              ("wide@wide" . "+wide/wide")
              ("adam"      . "+labo/adam"))
            ("Newsgroups:"
              ("^nifty\\.\\([^ ]+\\)" . "+Nifty/\\1"))
            ("From:" 
              ("uucp" . "+adm/uucp")
              (".*"   . "+misc"))
            ))

(setq mew-refile-guess-alist-COPY mew-refile-guess-alist)
(setq mew-refile-guess-alist nil)
nil

(setq mew-refile-guess-alist mew-refile-guess-alist-COPY)
(("To:\\|Cc:\\|From:" ("filko\\|mel@digital\\.net\\|thayer\\|be_unique@\\|gouge\\|buchner\\|woodruff\\|dake\\|page_lee\\|leep@\\|grotefend\\|borzner\\|gillono\\|jfg\\|mattison\\|lepper\\|ghofrani\\|auld\\|mattisjo@" . "+oldgang")) ("To:\\|Cc:\\|From:" ("lwesson@pce2000.com" . "+ipaq")) ("To:\\|Cc:\\|From:" ("@mew.org" . "+mew")) ("To:" ("@handhelds.org\\|@crl.dec.com\\|@compaq.com")) ("To:\\|From:\\|Cc:" ("amazon.com\\|@buy.com\\|mwave.com\\|googlegear.com" . "+etail")) ("Subject:" ("tcpd:\\|FreeBSD.*Security Advisory" . "+security")) ("Sender:" ("freebsd" . "+freebsd")) ("From:" ("sesamefamily" . "+robbie")) ("From:" ("vanguardmail@" . "+invest")) ("Subject:" ("test" . "+tests")))



(pprint mew-refile-guess-alist-COPY)
(("To:\\|Cc:\\|From:"
  ("filko\\|mel@digital\\.net\\|thayer\\|be_unique@\\|gouge\\|buchner\\|woodruff\\|dake\\|page_lee\\|leep@\\|grotefend\\|borzner\\|gillono\\|jfg\\|mattison\\|lepper\\|ghofrani\\|auld\\|mattisjo@" . "+oldgang"))
 ("To:\\|Cc:\\|From:"
  ("lwesson@pce2000.com" . "+ipaq"))
 ("To:\\|Cc:\\|From:"
  ("@mew.org" . "+mew"))
 ("To:"
  ("@handhelds.org\\|@crl.dec.com\\|@compaq.com"))
 ("To:\\|From:\\|Cc:"
  ("amazon.com\\|@buy.com\\|mwave.com\\|googlegear.com" . "+etail"))
 ("Subject:"
  ("tcpd:\\|FreeBSD.*Security Advisory" . "+security"))
 ("Sender:"
  ("freebsd" . "+freebsd"))
 ("From:"
  ("sesamefamily" . "+robbie"))
 ("From:"
  ("vanguardmail@" . "+invest"))
 ("Subject:"
  ("test" . "+tests")))

(pprint mew-refile-guess-alist)
(setq mew-refile-guess-alist
	'(("To:\\|Cc:\\|From:"
	 ("filko\\|mel@digital\\.net\\|thayer\\|be_unique@\\|gouge\\|buchner\\|woodruff\\|dake\\|page_lee\\|leep@\\|grotefend\\|borzner\\|gillono\\|jfg\\|mattison\\|lepper\\|ghofrani\\|auld\\|mattisjo@" . "+oldgang"))))
(("To:\\|Cc:\\|From:" ("filko\\|mel@digital\\.net\\|thayer\\|be_unique@\\|gouge\\|buchner\\|woodruff\\|dake\\|page_lee\\|leep@\\|grotefend\\|borzner\\|gillono\\|jfg\\|mattison\\|lepper\\|ghofrani\\|auld\\|mattisjo@" . "+oldgang")))




(setq mew-refile-guess-alist
      '(
	("To:\\|Cc:\\|From:"
	 ("filko\\|mel@digital\\.net\\|thayer\\|be_unique@\\|gouge\\|buchner\\|woodruff\\|dake\\|page_lee\\|leep@\\|grotefend\\|borzner\\|gillono\\|jfg\\|mattison\\|lepper\\|ghofrani\\|auld\\|mattisjo@" . "+oldgang2"))
	("To:\\|Cc:\\|From:"
	 ("lwesson@pce2000.com" . "+ipaq"))
	("To:\\|Cc:\\|From:"
	 ("@mew.org" . "+mew"))
	("To:"
	 ("@handhelds.org\\|@crl.dec.com\\|@compaq.com" . "+ipaq"))))
(("To:\\|Cc:\\|From:" ("filko\\|mel@digital\\.net\\|thayer\\|be_unique@\\|gouge\\|buchner\\|woodruff\\|dake\\|page_lee\\|leep@\\|grotefend\\|borzner\\|gillono\\|jfg\\|mattison\\|lepper\\|ghofrani\\|auld\\|mattisjo@" . "+oldgang2")) ("To:\\|Cc:\\|From:" ("lwesson@pce2000.com" . "+ipaq")) ("To:\\|Cc:\\|From:" ("@mew.org" . "+mew")) ("To:" ("@handhelds.org\\|@crl.dec.com\\|@compaq.com" . "+ipaq")))



	("To:\\|From:\\|Cc:"
	 ("amazon.com\\|@buy.com\\|mwave.com\\|googlegear.com" . "+etail"))
	("Subject:"
	 ("tcpd:\\|FreeBSD.*Security Advisory" . "+security"))
	("Sender:"
	 ("freebsd" . "+freebsd"))
	("From:"
	 ("sesamefamily" . "+robbie"))
	("From:"
	 ("vanguardmail@" . "+invest"))
	("Subject:"
	 ("test" . "+tests")))


mew-refile-guess-alist
(("To:\\|Cc:\\|From:" ("filko\\|mel@digital\\.net\\|thayer\\|be_unique@\\|gouge\\|buchner\\|woodruff\\|dake\\|page_lee\\|leep@\\|grotefend\\|borzner\\|gillono\\|jfg\\|mattison\\|lepper\\|ghofrani\\|auld\\|mattisjo@" . "+oldgang2")))


(let ((mew-refile-guess-alist dp-from-suffix-alist)
      (mew-refile-guess-by-alist)))
nil


;    (progn 
;      (require 'mailheader)
;      (let ((hdrs (save-excursion 
;		    (goto-char (point-min))
;		    (mail-header-extract))))
;	(let ((mew-refile-guess-alist 
;	       '(("To:\\|Cc:" ("xemacs.*" . "davep.NOSPAM")))))
;	  (message "from:>%s<" (mew-refile-guess-by-alist)))

;	(let ((mew-refile-guess-alist dp-from-suffix-alist))
;	      (message "from:>%s<" (mew-refile-guess-by-alist)))
;	(message "hdrs>%s<" hdrs)))

(if (and (boundp 'dp-backup-dir)
	 dp-backup-dir)
    (defun make-backup-file-name (file)
      "Override the standard `make-backup-file-name'.
It lives in /usr/local/lib/xemacs-<ver>/lisp/files.el
This version puts all backups in a single directory.
Is this a good idea?"
      ;; FSF has code here for MS-DOS short filenames, not supported in XEmacs.
      (concat dp-backup-dir (auto-save-escape-name file)))

========================================================================

(defun dp-next-in-tab-list ()
  (interactive)
  (let* ((buf-list0 (buffers-tab-items))
	 (buf-list buf-list0)
	 buf
	 obuf)
    (setq obuf 
	  (car-safe 
	   (catch 'done
	     (while buf-list
	       (setq buf (car buf-list))
	       (if (aref buf 2)
		   (if (cdr buf-list)
		       (throw 'done (cdr buf-list))
		     (throw 'done (cdr buf-list0)))
		 (message "looping")
		 (setq buf-list (cdr buf-list)))))))))
      
=================================================================
(defvar dp-buffers-tab-items nil
  "Private copy of buffers-tab-items.")

(defvar dp-buffers-tab-items-sorted nil
  "Private copy of buffers-tab-items.")

(defvar dp-buffers-tab-items-cursor nil
  "Next tab in dp-buffers-tab-items.")

(defun dp-tab-lessp (tab-item1 tab-item2)
  (string-lessp (aref tab-item1 0) (aref tab-item2 0)))

(defun dp-buffers-tab-sort-function (buf-list)
  (sort (copy-sequence buf-list) (lambda (buf1 buf2)
				   (string-lessp (buffer-name buf1)
						 (buffer-name buf2)))))

(defun dp-current-in-tab-list (list)
  (catch 'found
    (while list
      (if (aref (car list) 2)
	  (throw 'found list)
	(setq list (cdr list))))
    (error "cannot find current tab.")))

;; ["*scratch*" (buffers-tab-switch-to-buffer "*scratch*") :selected nil]

(defun dp-buffers-tab-lists-equal (l1 l2)
  (catch 'done
    (if (= (length l1) (length l2))
	(progn
	  (mapcar* (lambda (i1 i2)
		     (unless (string= (aref i1 0) (aref i2 0))
		       (throw 'done nil)))
		   l1
		   l2)
	  t)
      nil)))

(defun dp-get-next-tab-item ()
  (interactive)
  (let* ((list (buffers-tab-items))
	 (slist (copy-sequence list))	; already sorted.  if not this whole
					; scheme doesn't work.
	 ret)
    (unless (dp-buffers-tab-lists-equal slist dp-buffers-tab-items-sorted)
      (dmessage "new list, old:")
;      (pprint dp-buffers-tab-items)
;      (dmessage "new:")
;      (pprint nlist)
      ;; find current item and start there.
      (setq dp-buffers-tab-items-sorted slist
	    dp-buffers-tab-items list
	    ;; is the dp-current-in-tab-list needed any more?
	    dp-buffers-tab-items-cursor (dp-current-in-tab-list list)))
    (setq ret dp-buffers-tab-items-cursor)
    (setq dp-buffers-tab-items-cursor (cdr dp-buffers-tab-items-cursor))
    (unless dp-buffers-tab-items-cursor
      (setq dp-buffers-tab-items-cursor dp-buffers-tab-items))
    ret))
	
(defun dp-select-next-tab ()
  (interactive)
  (if (not buffers-tab-sort-function)
      (error "buffers tabs are not currently being sorted.")
    (let ((buf (dp-get-next-tab-item)))
      (when buf
	(switch-to-buffer (aref (car buf) 0))))))


(setq buffers-tab-sort-function 'dp-buffers-tab-sort-function)
dp-buffers-tab-sort-function

dp-buffers-tab-sort-function
(setq buffers-tab-sort-function nil)
nil

nil

====================================================
;; xemacs func... needs patching?
;; problems:
;; this function assumes that the current buffer, :selected t
;; is the first in the list.
;; my change checks for the buffer being current.
(defsubst build-buffers-tab-internal (buffers)
  ;;(dmessage "bbti")
  (mapcar
   #'(lambda (buffer)
       (vector 
	(funcall buffers-tab-format-buffer-line-function
		 buffer)
	(list buffers-tab-switch-to-buffer-function
	      (buffer-name buffer))
	:selected (equal buffer (current-buffer))))
   buffers)
  )

(defun dp-dump-bil (l)
  (dmessage "%s" (mapconcat (lambda (i)
			      (aref i 0))
			    l ", ")))

dp-buffer-list-copy
(#<buffer "*scratch*"> #<buffer "elisp-devel.el"> #<buffer "glyphs.el"> #<buffer "gutter-items.el"> #<buffer "widgets-gtk.el">)

(pprint (build-buffers-tab-internal dp-buffer-list-copy))
(["*scratch*"
  (buffers-tab-switch-to-buffer "*scratch*")
  :selected nil] ["elisp-devel.el"
  (buffers-tab-switch-to-buffer "elisp-devel.el")
  :selected t] ["glyphs.el"
  (buffers-tab-switch-to-buffer "glyphs.el")
  :selected nil] ["gutter-items.el"
  (buffers-tab-switch-to-buffer "gutter-items.el")
  :selected nil] ["widgets-gtk.el"
  (buffers-tab-switch-to-buffer "widgets-gtk.el")
  :selected nil])


(defun update-tab-in-gutter (frame &optional force-selection)
  "Update the tab control in the gutter area."
    ;; dedicated frames don't get tabs
  (unless (or (window-dedicated-p (frame-selected-window frame))
	      (frame-property frame 'popup))
    (when (specifier-instance default-gutter-visible-p frame)
      (unless (and gutter-buffers-tab
		   (eq (default-gutter-position)
		       gutter-buffers-tab-orientation))
	(add-tab-to-gutter))
      (when (valid-image-instantiator-format-p 'tab-control frame)
	(let ((items (buffers-tab-items nil frame force-selection)))
	  (when items
	    (set-glyph-image
	     gutter-buffers-tab
	     (vector 'tab-control :descriptor "Buffers" :face buffers-tab-face
		     :orientation gutter-buffers-tab-orientation
		     (if (or (eq gutter-buffers-tab-orientation 'top)
			     (eq gutter-buffers-tab-orientation 'bottom))
			 :pixel-width :pixel-height)
		     (if (or (eq gutter-buffers-tab-orientation 'top)
			     (eq gutter-buffers-tab-orientation 'bottom))
			 '(gutter-pixel-width) '(gutter-pixel-height)) 
		     :items items)
	     frame)
	    ;; set-glyph-image will not make the gutter dirty
	    (set-gutter-dirty-p gutter-buffers-tab-orientation)

	    ;; !!!!!!!!!!!!!
	    ;; use the current buffer's buffer switching function
;	    (let ((buf (current-buffer)))
;	      (switch-to-buffer dp-message-buffer-name)
;	      (buffers-tab-switch-to-buffer buf))
	    ))))))
========================================================================

(progn
  (setq x 1000)
  (while (> x 0)
    (find-file "/goliath:diary")
    (sit-for 2)
    (kill-buffer "diary@goliath")
    (kill-buffer "*ftp davep@goliath*")
    (sb) (insert (format "x %3d; " x))
    (list-buffers)
    (sit-for 2)
    (list-buffers)
    (setq x (1- x))))




========================================================================
(defun resize-minibuffer-window ()
  (let ((height (window-height))
	(lines (1+ (resize-minibuffer-count-window-lines))))
    (dp-message-buf-only "lines: %s" lines)
    (and (numberp resize-minibuffer-window-max-height)
	 (> resize-minibuffer-window-max-height 0)
	 (setq lines (min
		      lines
		      resize-minibuffer-window-max-height)))
    (dp-message-buf-only "lines: %s, height: %s, diff: %s"
			 lines height (- lines height))
    (or (if resize-minibuffer-window-exactly
	    (= lines height)
	  (<= lines height))
	(enlarge-window (- lines height)))))

========================================================================

(defun dp-current-month (&optional date)
  (let* ((dlist (decode-time (or date (current-time))))
	 (month (nth 4 dlist)))
    month))

(defun dp-current-year (&optional date)
  (let* ((dlist (decode-time (or date (current-time))))
	 (year  (nth 5 dlist)))
    year))

(defmacro dp-define-date-function (name empty-ags docstring &rest body)
  (unless (stringp docstring)
    (setq body docstring)
    (setq docstring "Lazy bastard provided no doc."))
  `(defun ,name (&optional start-month end-month start-year 
			   end-year)
     ,docstring
     (interactive)
     (unless start-month
       (setq start-month (dp-current-month)))
     (unless end-month
       (setq end-month (dp-current-month)))
     (unless start-year
       (setq start-year (dp-current-year)))
     (unless end-year
       (setq end-year start-year))
     ,@body
     ))

(dp-define-date-function dp-get-diary-entries ()
  "Based on code in cal-tex.el"
  (interactive)
  (cal-tex-list-diary-entries
   (calendar-absolute-from-gregorian (list start-month 1 start-year))
   (calendar-absolute-from-gregorian 
    (list end-month 
	  (calendar-last-day-of-month end-month end-year) end-year))))

(dp-get-diary-entries)
(((9 6 2002) "
 11:30am Dr Lin, Mt Auburn" "Sep 6, 2002") ((9 9 2002) "
 1:15pm \"Dr\" Marvasti" "Sep 9, 2002") ((9 12 2002) "
 11:30am Dr Wagner, Somerville Hosp." "Sep 12, 2002") ((9 23 2002) "
 11:30am Dr Wagner, Somerville Hosp." "Sep 23, 2002"))

(defun dp-get-diary-entries (&optional start-month end-month start-year 
				       end-year)
  "Based on code in cal-tex.el"
  (interactive)
  (unless start-month
    (setq start-month (dp-current-month)))
  (unless end-month
    (setq end-month (dp-current-month)))
  (unless start-year
    (setq start-year (dp-current-year)))
  (unless end-year
    (setq end-year start-year))
  (cal-tex-list-diary-entries
   (calendar-absolute-from-gregorian (list start-month 1 start-year))
   (calendar-absolute-from-gregorian 
    (list end-month 
	  (calendar-last-day-of-month end-month end-year) end-year))))

(defun dp-diary-entries-to-pcal (&optional start-month end-month start-year 
					   end-year)
  (interactive)
  (let ((appts (dp-get-diary-entries start-month end-month 
				     start-year end-year))
	(buf-name (generate-new-buffer-name "*pcal-output*")))
    (switch-to-buffer buf-name)
    (erase-buffer)
    (mapc (lambda (diary-entry)
	    (let ((date (third diary-entry))
		  (appt (second diary-entry)))
	      (insert (format "%s\t%s\n" date (substring appt 1)))))
	  appts)))
(dp-diary-entries-to-pcal)
(((10 1 2002) "
 11:00am Schwab consultant call." "Oct 1, 2002") ((10 1 2002) "
 2:00pm block entry+alarm test" "%%(diary-block 10 1 2002 10 2 2002)") ((10 2 2002) "
 2:00pm block entry+alarm test" "%%(diary-block 10 1 2002 10 2 2002)") ((10 4 2002) "




(((9 6 2002) "
 11:30am Dr Lin, Mt Auburn" "Sep 6, 2002") ((9 9 2002) "
 1:15pm \"Dr\" Marvasti" "Sep 9, 2002") ((9 12 2002) "
 11:30am Dr Wagner, Somerville Hosp." "Sep 12, 2002") ((9 23 2002) "
 11:30am Dr Wagner, Somerville Hosp." "Sep 23, 2002"))


(((9 6 2002) "
 11:30am Dr Lin, Mt Auburn" "Sep 6, 2002") ((9 9 2002) "
 1:15pm \"Dr\" Marvasti" "Sep 9, 2002") ((9 12 2002) "
 11:30am Dr Wagner, Somerville Hosp." "Sep 12, 2002") ((9 23 2002) "
 11:30am Dr Wagner, Somerville Hosp." "Sep 23, 2002"))


(dp-get-diary-entries)
(setq x '(((9 6 2002) "
 11:30am Dr Lin, Mt Auburn" "Sep 6, 2002") ((9 9 2002) "
 1:15pm \"Dr\" Marvasti" "Sep 9, 2002") ((9 12 2002) "
 11:30am Dr Wagner, Somerville Hosp." "Sep 12, 2002") ((9 23 2002) "
 11:30am Dr Wagner, Somerville Hosp." "Sep 23, 2002")))

(
 ((9 6 2002) 
  "11:30am Dr Lin, Mt Auburn" "Sep 6, 2002") 
 ((9 9 2002) "
 1:15pm \"Dr\" Marvasti" "Sep 9, 2002") ((9 12 2002) "
 11:30am Dr Wagner, Somerville Hosp." "Sep 12, 2002") ((9 23 2002) "
 11:30am Dr Wagner, Somerville Hosp." "Sep 23, 2002"))

(cdr (car x))
("
 11:30am Dr Lin, Mt Auburn" "Sep 6, 2002")

((9 6 2002) "
 11:30am Dr Lin, Mt Auburn" "Sep 6, 2002")


(dp-current-month)
9

(dp-current-year)
2002

regexp for extracting
file and line from a ccmalloc, et.al. 
/a/b/c/d:123
"\\(.*?\\)\\(:[0-9]+\\)?$"

(defcustom SYMBOL VALUE DOC &rest ARGS)
(defmacro defcustom-local (symbol value doc &rest args)
  (unless (stringp doc)
    (setq doc ""))
  `(progn 
      (defcustom ,symbol ,value ,doc ,@args)
      (make-variable-buffer-local ,symbol)))
defcustom-local
(pprint (macroexpand '(defcustom-local lvar "lvar-val" "lvar-doc" lvar-forms lv1 lv2)))
(progn
  (defcustom lvar "lvar-val" "lvar-doc" lvar-forms lv1 lv2)
  (make-variable-buffer-local symbol))
"

(defmacro dp-i-lambda (&rest body)
  `(lambda ()
     (interactive)
     ,@body))
dp-i-lambda

(macroexpand '(dp-i-lambda (kb-func 'a 'b 'c)))
(function (lambda nil (interactive) (kb-func (quote a) (quote b) (quote c))))


(defun dp-pop-go-back ()
  "Pop the top of `dp-go-back-stack' and go there."
  (interactive)
  (catch 'done
    (let ((do-it t)
	  (pop-it t)
	  marker buffer)
    (while dp-go-back-stack
      (setq marker (car dp-go-back-stack)
	    buffer (marker-buffer marker))
      ;; Does the dest buffer still exist?
      (when buffer
	(unless (equal buffer (current-buffer))
	  (setq do-it (y-or-n-p "Leave buffer?")))
	(if do-it
	    (progn
	      (switch-to-buffer buffer)
	      (goto-char marker)
	      (set-marker marker nil))
	  (setq pop-it (y-or-n-p "Discard marker?")))
	(if pop-it
	    (setq dp-go-back-stack (cdr dp-go-back-stack)))
	(throw 'done t))
      (setq dp-go-back-stack (cdr dp-go-back-stack)))
    (message "Go back stack empty."))))
    
     
========================================================================
(defun dpj-tidy-topic-ends (&optional query)
  (interactive "P")
  (let ((topic-re (concat "\\(\n\n*?\\)"
			  "\\("
			  "\n\n" 
			  (substring (dpj-mk-topic-re) 1)
			  "\\)"
			  ))
	m-end)
    (if query
	(query-replace-regexp topic-re "\\2")
      (while (re-search-forward topic-re nil t)
	;; use marker so we go to the right place after deletions
	;; change char positions.
	(setq m-end (point-marker))
	(delete-region (match-beginning 1) (match-end 1))
	(goto-char m-end)))
    (setq m-end nil)))
dpj-tidy-topic-ends

dpj-tidy-topic-ends






dpj-tidy-topic-ends

	(dp-set-mark
	 (save-excursion
	   (goto-char (match-beginning 1))
	   (point)))
	(goto-char (match-end 1))
	(dp-activate-mark))

==============================================================
(
(defun dpj-prev-todo (&optional arg)
  "Find the prev todo in the files.
If arg is unset, search backwards.
If arg is > 4 (2x \\[universal-argument]), prompt for topic regexp
which will then restrict the topics searched for todos.
If arg is 1-3 or < 0 (1 C-u) search backwards."
  (interactive "p")
  ;(dpj-goto-topic-forward dpj-todo-re)
  (let ((nextp (prefix-numeric-value current-prefix-arg)))
    (when (> nextp 4)
      ;; prompt for regexp
	
  (if nextp
      (dpj-move-with-file-wrap 'dpj-goto-todo-or-ai-forward 1 dpj-todo-re)
    (dpj-move-with-file-wrap 'dpj-goto-todo-or-ai-backward -1 dpj-todo-re)))


;; this matches ^P
key         -> bw search
Cu + key    -> prompt for topic, bw search
CuCu + key  -> clear topic, bw search

doing this


========================
Saturday October 05 2002
--
(defun dp-simple-viewer (buf-name &optional fill-func quit-keys q-key-command)
  "View something in a buffer."
  (switch-to-buffer buf-name)
  (setq buffer-read-only t)
  (let ((inhibit-read-only t)
	rc)
    (erase-buffer)
    (goto-char (point-min))
    (cond
     ((stringp fill-func) (insert fill-func))
     ((functionp fill-func) (funcall fill-func))
     (t nil))
    (let* ((orig-map (car (current-keymaps)))
	   (kmap (copy-keymap orig-map)))
      (mapc (lambda (key)
	      (define-key kmap key  (or q-key-command 'kill-this-buffer)))
	    (or quit-keys '(?q ?Q ?x ?X )))
      (use-local-map kmap))))
dp-simple-viewer



(dp-simple-viewer "zzbuf" (lambda () (insert (upcase "upper"))))
(dp-simple-viewer "zzbuf" "in zz")
nil
========================
2002-10-06T19:05:59
--
(setq dp-mouse-fn-list '(
mouse-avoidance-mode
mouse-begin-drag-n-drop
mouse-bury-buffer
mouse-choose-completion
mouse-consolidated-yank
mouse-del-char
mouse-delete-window
mouse-directory-display-completion-list
mouse-drag-modeline
mouse-eval-last-sexpr
mouse-eval-sexp
mouse-event-p
mouse-file-display-completion-list
mouse-function-menu
mouse-ignore
mouse-keep-one-window
mouse-kill-line
mouse-line-length
mouse-me
mouse-pixel-position
mouse-position
mouse-position-as-motion-event
mouse-read-file-name-1
mouse-read-file-name-activate-callback
mouse-rfn-setup-vars
mouse-scroll
mouse-select
mouse-select-and-split
mouse-set-mark
mouse-set-point
mouse-track
mouse-track-activate-rectangular-selection
mouse-track-adjust
mouse-track-adjust-default
mouse-track-and-copy-to-cutbuffer
mouse-track-default
mouse-track-delete-and-insert
mouse-track-do-activate
mouse-track-do-rectangle
mouse-track-insert
mouse-track-run-hook
mouse-track-scroll-undefined
mouse-track-set-timeout
mouse-unbury-buffer
mouse-window-to-region
mouse-yank
default-mouse-track-anchor
default-mouse-track-beginning-of-word
default-mouse-track-cleanup-extent
default-mouse-track-cleanup-extents-hook
default-mouse-track-cleanup-hook
default-mouse-track-click-hook
default-mouse-track-deal-with-down-event
default-mouse-track-down-hook
default-mouse-track-drag-hook
default-mouse-track-drag-up-hook
default-mouse-track-end-of-word
default-mouse-track-event-is-with-button
default-mouse-track-has-selection-p
default-mouse-track-maybe-own-selection
default-mouse-track-next-move
default-mouse-track-next-move-rect
default-mouse-track-normalize-point
default-mouse-track-point-at-opening-quote-p
default-mouse-track-return-dragged-selection
default-mouse-track-scroll-and-set-point
default-mouse-track-set-point
default-mouse-track-set-point-in-window
default-mouse-track-symbolp))

(mapc (lambda (f)
	(trace-function-background f))
      dp-mouse-fn-list)

(defun default-mouse-track-drag-up-hook (event click-count)
  (when (default-mouse-track-event-is-with-button event 1)
    (let ((result (default-mouse-track-return-dragged-selection event)))
      (if result
	  (default-mouse-track-maybe-own-selection result 'PRIMARY)))
    t))

(defun default-mouse-track-drag-hook (event click-count was-timeout)
  (cond ((default-mouse-track-event-is-with-button event 1)
	 (default-mouse-track-deal-with-down-event click-count)
	 (default-mouse-track-set-point event default-mouse-track-window)
	 (default-mouse-track-cleanup-extent)
	 (default-mouse-track-next-move default-mouse-track-min-anchor
	   default-mouse-track-max-anchor
	   default-mouse-track-extent)
	 t)
	((default-mouse-track-event-is-with-button event 2)
	 (mouse-begin-drag-n-drop event))))

(defun mouse-track (event &optional overriding-hooks)
  "Generalized mouse-button handler.  This should be bound to a mouse button.
The behavior of this function is customizable using various hooks and
variables: see `mouse-track-click-hook', `mouse-track-drag-hook',
`mouse-track-drag-up-hook', `mouse-track-down-hook', `mouse-track-up-hook',
`mouse-track-cleanup-hook', `mouse-track-multi-click-time',
`mouse-track-scroll-delay', `mouse-track-x-threshold', and
`mouse-track-y-threshold'.

Default handlers are provided to implement standard selecting/positioning
behavior.  You can explicitly request this default behavior, and override
any custom-supplied handlers, by using the function `mouse-track-default'
instead of `mouse-track'.

\(In general, you can override specific hooks by using the argument
OVERRIDING-HOOKS, which should be a plist of alternating hook names
and values.)

Default behavior is as follows:

If you click-and-drag, the selection will be set to the region between the
point of the initial click and the point at which you release the button.
These positions need not be ordered.

If you click-and-release without moving the mouse, then the point is moved
and the selection is disowned (there will be no selection owner).  The mark
will be set to the previous position of point.

If you double-click, the selection will extend by symbols instead of by
characters.  If you triple-click, the selection will extend by lines.

If you drag the mouse off the top or bottom of the window, you can select
pieces of text which are larger than the visible part of the buffer; the
buffer will scroll as necessary.

The selected text becomes the current X Selection.  The point will be left
at the position at which you released the button, and the mark will be left
at the initial click position."
  (interactive "e")
  ;;(y-or-n-p "Continue3?")
  ;;(error "boo")
  (let ((mouse-down t)
	(xthresh (eval mouse-track-x-threshold))
	(ythresh (eval mouse-track-y-threshold))
	(orig-x (event-x-pixel event))
	(orig-y (event-y-pixel event))
	(buffer (event-buffer event))
	(mouse-grabbed-buffer (event-buffer event))
	mouse-moved)
    (if (or (not mouse-track-up-x)
	    (not mouse-track-up-y)
	    (not mouse-track-up-time)
	    (> (- (event-timestamp event) mouse-track-up-time)
	       mouse-track-multi-click-time)
	    (> (abs (- mouse-track-up-x orig-x)) xthresh)
	    (> (abs (- mouse-track-up-y orig-y)) ythresh))
	(setq mouse-track-click-count 1)
      (setq mouse-track-click-count (1+ mouse-track-click-count)))
    (if (not (event-window event))
	(error "Not over a window."))
    (mouse-track-run-hook 'mouse-track-down-hook overriding-hooks
			  event mouse-track-click-count)
    (unwind-protect
	(while mouse-down
	  (setq event (next-event event))
	  (cond ((motion-event-p event)
		 (if (and (not mouse-moved)
			  (or (> (abs (- (event-x-pixel event) orig-x))
				 xthresh)
			      (> (abs (- (event-y-pixel event) orig-y))
				 ythresh)))
		     (setq mouse-moved t))
		 (if mouse-moved
		     (mouse-track-run-hook 'mouse-track-drag-hook
					   overriding-hooks
					   event mouse-track-click-count nil))
		 (mouse-track-set-timeout event))
		((and (timeout-event-p event)
		      (eq (event-function event)
			  'mouse-track-scroll-undefined))
		 (if mouse-moved
		     (mouse-track-run-hook 'mouse-track-drag-hook
					   overriding-hooks
					   (event-object event)
					   mouse-track-click-count t))
		 (mouse-track-set-timeout (event-object event)))
		((button-release-event-p event)
		 (setq mouse-track-up-time (event-timestamp event))
		 (setq mouse-track-up-x (event-x-pixel event))
		 (setq mouse-track-up-y (event-y-pixel event))
		 (setq mouse-down nil)
		 (mouse-track-run-hook 'mouse-track-up-hook
				       overriding-hooks
				       event mouse-track-click-count)
		 (if mouse-moved
		     (mouse-track-run-hook 'mouse-track-drag-up-hook
					   overriding-hooks
					   event mouse-track-click-count)
		   (mouse-track-run-hook 'mouse-track-click-hook
					 overriding-hooks
					 event mouse-track-click-count)))
		((or (key-press-event-p event)
		     (and (misc-user-event-p event)
			  (eq (event-function event) 'cancel-mode-internal)))
		 (error "Selection aborted"))
		(t
		 (dispatch-event event))))
      ;; protected
      (if mouse-track-timeout-id
	  (disable-timeout mouse-track-timeout-id))
      (setq mouse-track-timeout-id nil)
      (and (buffer-live-p buffer)
	   (save-excursion
	     (set-buffer buffer)
	     (let ((override (plist-get overriding-hooks
					'mouse-track-cleanup-hook
					Mouse-track-gensym)))
	       (if (not (eq override Mouse-track-gensym))
		   (if (and (listp override) (not (eq (car override) 'lambda)))
		       (mapc 'funcall override)
		     (funcall override))
		 (run-hooks 'mouse-track-cleanup-hook))))))))

(1(2(3()3)2)1)
(3()3)
(2(3()3)2)
()
on close, go fwd, do it.

(defun dp-mark-sexp (&optional arg)
  (interactive "p")
  (unless arg (setq arg 1))
  ;; need to look at char behind point?
  (save-match-data
    (when (looking-at "[])}]")
      ;; mark-sexp w/-arg marks sexp *before* point
      ;; so if we're looking at a closing "paren" go fwd once.
      (forward-char 1)
      (setq arg (- arg))))
  ;; otherwise, let mark-sexp handle things
  (mark-sexp arg))

(defun dp-copy-sexp (&optional arg)
  "Copy sexps marked with dp-mark-sexp."
  (interactive)
  (save-excursion
    (call-interactively 'dp-mark-sexp)
    (copy-region-as-kill (mark) (point))))  
dp-copy-sexp

(defun dp-bm-cycle ()
  "Cycle thru book marks."
  (interactive)
  ;; advance ring pointer w/wrap
  (if (or (not dp-bm-ring-ptr)		; never been used?
	  (not (setq dp-bm-ring-ptr (cdr dp-bm-ring-ptr)))) ; wrap?
      (setq dp-bm-ring-ptr dp-bm-list))
  (let ((pos (dp-bm-pos (car dp-bm-ring-ptr))))
    (message "went to %d" pos)
    (unless (eq last-command 'dp-bm-cycle)
      (dp-push-go-back))
    (goto-char pos)))
    

1



2



3

4


5	
      
