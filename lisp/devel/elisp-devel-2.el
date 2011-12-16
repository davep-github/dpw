;;
;; Time-stamp: <10/05/09 00:10:41 davep>
@ sudo editing
  sudo cat file into buffer.
  sudo write it back -or- write to tmp, sudo cp to orig.
  detect owned by root, read only. prompt to do this.
  ! need to hook save-buffer, or just rebind M-w in this mode and that
    becomes the only way to save this kind of file.
    !! set background of all faces as in example init.el
  ?? use efs/tramp to get to root@localhost?


(defvar dp-sudo-edit-temp-dir (expand-file-name "~/.emacs.sudo-edit/"))
(deflocal dp-sudo-edit-temp-file-name nil)
(deflocal dp-sudo-edit-orig-file-name nil)

;; can unquote w/auto-save-unescape-name

(defun dp-sudo-edit-make-temp-name (file-name)
  (expand-file-name (concat dp-sudo-edit-temp-dir 
			    (auto-save-escape-name file-name))))

(defun dp-sudo-edit-save-buffer ()
  (interactive)
  (save-buffer)
  ;; hideous hack!
  (if (string= (file-name-directory (buffer-file-name)) dp-sudo-edit-temp-dir)
      (let* ((orig-name (auto-save-unescape-name
			 (file-name-nondirectory (buffer-file-name))))
	     (cp-rc
	      (call-process "sudo" nil nil nil 
			    "cp" 
			    (buffer-file-name)
			    orig-name)))
	(if (/= cp-rc 0)
	    (error (formar "cp failed: %d" cp-rc))))
    (dmessage "copy skipped, not sudo-edit dir.")))

;; ?? can I sudo cat the file and then set the name to be the original
;;    file without it being saved?  See how save buffer sets the
;;    visited file name.
;; ?? Can it use read/save hooks to do this?
;; find-file-name-handler
;; and file-name-handler-alist
;; ?? Bind locally when doing initial read (w/let) then set handler
;;    alist to old the exact expanded name of this file.  ??? How to
;;    remove from list?
;; ?? Use special syntax for sudo-editing?
(defun dp-sudo-edit (orig-file-name)
  (interactive "Ffile to edit> ")
  (let* ((buf-name (format "sudo edit: %s" orig-file-name))
	;; make temp file like autosave does, in a ?dedicated?  temp
	;; dir. fixed temp name prevents us from ending up with
	;; multiple copies of the file in different buffers
	 (file-name (expand-file-name orig-file-name))
	 (temp-file-name (dp-sudo-edit-make-temp-name file-name)))
    (switch-to-buffer buf-name)
    (erase-buffer)
    (goto-char (point-min))
    (call-process "sudo" nil t nil "cat" orig-file-name)
    ;; @todo determine mode based on orig-file-name
    (sam)
    (write-file temp-file-name)
    (goto-char (point-min))
;    (setq dp-sudo-edit-temp-file-name temp-file-name
;	  dp-sudo-edit-orig-file-name file-name)
    ;; @todo !!!
    ;; this is broken.  I need a buffer-local key binding.
    (local-set-key "\ew" 'dp-sudo-edit-save-buffer)))

========================
2002-10-14T17:50:53
--
(defun dp-mmm-univ-back (stop)
  (let* ((back "{%/~1%}")
	 (pos (regexp-quote (mmm-format-matches back))))
    (mmm-match-and-verify pos nil stop nil)))
  

(defun dp-mmm-univ-get-mode (string)
  (string-match "{%\\(.*?\\)%}" string)
  (setq string (match-string 1 string))
  (let ((modestr (intern (if (string-match "mode\\'" string)
                             string
                           (concat string "-mode")))))
    (or (mmm-ensure-modename modestr)
        (signal 'mmm-no-matching-submode nil))))

(defun dp-mmm-no-regexp-quote-form ()
  (match-string 0))

(mmm-add-classes
 `((dp-universal
    :front "{%\\(.*?\\)%}"
    :front-form dp-mmm-no-regexp-quote-form
    :back dp-mmm-univ-back
;    :back "{%/~1%}"
    :insert ((?/ dp-universal "Submode: " @ "{%" str "%}" @ "\n" _ "\n"
                 @ "{%/" str "%}" @))
    :match-submode dp-mmm-univ-get-mode
    :save-matches 1
    )))


=============
(setq mmm-classes-alist 
'((universal :front "{%\\([a-zA-Z-]+\\)%}" :back "{%/~1%}" :insert ((?/ universal "Submode: " @ "{%" str "%}" @ "
" _ "
" @ "{%/" str "%}" @)) :match-submode mmm-univ-get-mode :save-matches 1)))
((universal :front "{%\\([a-zA-Z-]+\\)%}" :back "{%/~1%}" :insert ((?/ universal "Submode: " @ "{%" str "%}" @ "
" _ "
" @ "{%/" str "%}" @)) :match-submode mmm-univ-get-mode :save-matches 1))


mmm-classes-alist

========================
2002-10-20T11:11:48
--

>>>>>>>>>>>>!<<<<<<<<<<<

(defun dp-regexp-dequote (str)
  (replace-in-string str "\\\\" ""))
dp-regexp-dequote

(dp-regexp-dequote "c\\+\\+")
"c++"

========================
2002-10-23T11:56:10
--
(defun dp-sudo-edit (orig-file-name)
  "Edit a file by using sudo to cat the file into a buffer and sudo do cp the edited file over the original."
  (interactive "FSudo edit: ")
  (let* ((inhibit-read-only t)
	 (change-major-mode-with-file-name nil)
	 (buf-name (format "sudo edit: %s" orig-file-name))
	 ;; make temp file like autosave does, in a ?dedicated?  temp
	 ;; dir. fixed temp name prevents us from ending up with
	 ;; multiple copies of the file in different buffers
	 (file-name (expand-file-name orig-file-name))
	 (temp-file-name (dp-sudo-edit-make-temp-name file-name)))
    (if (find-buffer-visiting orig-file-name)
	(error "Another buffer is visiting %s" orig-file-name))
    (if (find-buffer-visiting temp-file-name)
	(error "Another buffer is visiting %s" temp-file-name))
    (find-file orig-file-name)
    (erase-buffer)
    (goto-char (point-min))
    (call-process "sudo" nil t nil "cat" orig-file-name)
    ;; @todo determine mode based on orig-file-name
    ;;(sam)
    ;; the following sets the mode based on the new name
    ;; the mode changes when write-file calls (set-visited-file-name filename)
    ;; ! if I do a write-file by hand, the mode doesn't change
    ;;   ??? WHY!?
    ;; ! look at change-major-mode-with-file-name

    (write-file temp-file-name)
    (goto-char (point-min))
    (setq dp-sudo-edit-p t)
    (rename-buffer buf-name t)
    (add-local-hook 'kill-buffer-hook 'dp-sudo-edit-temp-buffer-killed)
    (let ((map (make-keymap "dp-sudo-edit keymap")))
      (set-keymap-parents map (list (current-local-map)))
      (define-key map "\ew" 'dp-sudo-edit-save-buffer)
      (use-local-map map))))
========================
2002-10-23T18:51:38
--
(defun dp-comment-endif ()
  "Grab conditional off current line, jump fwd to #endif and insert as comment"
  (interactive)
  (let (line 
	(cpp-item (dp-get-ifdef-item)))
    (save-excursion
      ;; find out where we are, and go to the
      ;; initial ifdef if possible.
      (cond
       ((eq cpp-item 'dp-endif) (hif-endif-to-ifdef))
       ((or (eq cpp-item 'dp-else) 
	    (eq cpp-item 'dp-elif))
	(hif-ifdef-to-endif)
	(hif-endif-to-ifdef))
       ((eq cpp-item 'dp-if) ())
       (t (error "Dunno where I am.  Put cursor on a CPP conditional.")))
       
      (setq line (buffer-substring (line-beginning-position)
				   (line-end-position)))
      (beginning-of-line)
      (hif-ifdef-to-endif)
      (beginning-of-line)
      (re-search-forward "#\\s-*endif\\(.*\\)$" nil t)
      (delete-region (match-beginning 1) (match-end 1))
      (end-of-line)
      (insert " /* " line " */"))))
========================
2002-10-26T21:37:22
--

dp-tabdent

(dp-tabdent 4)
    4

	8

	8

(dp-phys-tab 3)
			nil

	nil

========================
2002-10-28T11:07:03
--

(defun* f1 (&optional (a1 "boo"))
  (interactive)
  (message "a1>%s<" a1))
f1

(f1)
"a1>boo<"
(f1 nil)
"a1>nil<"

(macroexpand '(defun* f1 (&optional (a1 "boo"))
  (interactive)
  (message "a1>%s<" a1)))

(defun f1 (&rest --rest--70121) 
"Common Lisp lambda list:
  (f1 &optional (A1 nil))" 
  (interactive) 
  (let* ((a1 (if --rest--70121 
		 (pop --rest--70121) 
	       "boo"))) 
    (if --rest--70121 
	(signal (quote wrong-number-of-arguments) 
		(list (quote f1) 
		      (+ 1 (length --rest--70121))))) 
    (block f1 (message "a1>%s<" a1))))


(defmacro arg-defaults (&rest arglist)
  "Setup default values for args which are nil."
  (let (arg init-val result)
    (while arglist
      (setq arg (car arglist)
	    arglist (cdr arglist)
	    init-val (car arglist)
	    arglist (cdr arglist))
      (setq new-elem `(unless ,arg (setq ,arg ,init-val)))
      (setq result (cons new-elem result)))
    (cons 'progn (reverse result))))
arg-defaults
(macroexpand '(arg-defaults a1 "a1-def" a2))
(progn (unless a1 (setq a1 "a1-def")) (unless a2 (setq a2 nil)))

(progn (unless a1 (setq a1 "a1-def")) (unless a2 (setq a2 "a2def")))

(macroexpand '(arg-defaults
		indent-width (if (dp-in-c)
				   c-basic-offset
				 tab-width)))
(progn 
  (unless indent-width 
    (setq indent-width 
	  (if (dp-in-c) 
	      c-basic-offset 
	    tab-width))))

========================
2002-10-28T13:39:24
--

(defvar dp-debug-ignored-errors
   '(beginning-of-line
     beginning-of-buffer
     end-of-line
     end-of-buffer
     end-of-file
     buffer-read-only
     undefined-keystroke-sequence
     "^Previous command was not a yank$"
     "^Command attempted to use minibuffer while in minibuffer$"
     "^Minibuffer window is not active$"
     "^End of history; no next item$"
     "^Beginning of history; no preceding item$"
     "^No recursive edit is in progress$"
     "^Changes to be undone are outside visible portion of buffer$"
     "^No undo information in this buffer$"
     "^No further undo information$"
     "^Save not confirmed$"
     "^Recover-file cancelled\\.$"
     "^Attempt to save to a file which you aren't allowed to write$"
     "^"File reverted"$"
     "^The mode `.*' does not support Imenu$"
     "^This buffer cannot use `imenu-default-create-index-function'$"

     ;;XEmacs
     "^No preceding item in "
     "^No following item in "
     "^Unbalanced parentheses$"
     "^no selection$"
     "^No selection or cut buffer available$"
   
     ;; comint
     "^Not at command line$"
     "^Empty input ring$"
     "^No history$"
     "^Not found$";; Too common?
     "^Current buffer has no process$"
   
     ;; dabbrev
     "^No dynamic expansion for \".*\" found\\.$"
     "^No further dynamic expansions? for .* found\\.?$"
   
     ;; Completion
     (concat "^To complete, the point must be after a symbol at "
	     "least [0-9]* character long\\.$")
     "^The string \".*\" is too short to be saved as a completion\\.$"
   
     ;; Compile
     "^No more errors\\( yet\\|\\)$"
   
     ;; Gnus
     "^NNTP: Connection closed\\.$"
   
     ;; info
     "^Node has no Previous$"
     "^No \".*\" in index$"
   
     ;; imenu
     "^No items suitable for an index found in this buffer\\.$"
     "^The mode \".*\" does not take full advantage of imenu\\.el yet\\.$"
   
     ;; ispell
     "^No word found to check!$"
   
     ;; mh-e
     "^Cursor not pointing to message$"
     "^There is no other window$"
   
     ;; man
     "^No manpage [0-9]* found$"
   
     ;; etags
     "^No tags table in use!  Use .* to select one\\.$"
     "^There is no default tag$"
     "^No previous tag locations$"
     "^File .* is not a valid tags table$"
     "^No \\(more \\|\\)tags \\(matching\\|containing\\) "
     "^Rerun etags: `.*' not found in "
     "^All files processed\\.$"
	
     ;; BBDB
     "^no previous record$"
     "^no next record$"

     ;; copied from emacs
     "^No possible abbreviation preceding point$"
     "^Current buffer has no process$"
     file-supersession
     "^Cannot switch buffers in a dedicated window$"
     ;; ediff errors
     "^Errors in diff output. Diff output is in "
     "^Hmm... I don't see an Ediff command around here...$"
     "^Undocumented command! Type `G' in Ediff Control Panel to drop a note to the Ediff maintainer$"
     ": This command runs in Ediff Control Buffer only!$"
     ": Invalid op in ediff-check-version$"
     "^ediff-shrink-window-C can be used only for merging jobs$"
     "^Lost difference info on these directories$"
     "^This command is inapplicable in the present context$"
     "^This session group has no parent$"
     "^Can't hide active session, $"
     "^Ediff: something wrong--no multiple diffs buffer$"
     "^Can't make context diff for Session $"
     "^The patch buffer wasn't found$"
     "^Aborted$"
     "^This Ediff session is not part of a session group$"
     "^No active Ediff sessions or corrupted session registry$"
     "^No session info in this line$"
     "^`.*' is not an ordinary file$"
     "^Patch appears to have failed$"
     "^Recomputation of differences cancelled$"
     "^No fine differences in this mode$"
     "^Lost connection to ancestor buffer...sorry$"
     "^Not merging with ancestor$"
     "^Don't know how to toggle read-only in buffer "
     "Emacs is not running as a window application$"
     "^This command makes sense only when merging with an ancestor$"
     "^At end of the difference list$"
     "^At beginning of the difference list$"
     "^Nothing saved for diff .* in buffer "
     "^Buffer is out of sync for file "
     "^Buffer out of sync for file "
     "^Output from `diff' not found$"
     "^You forgot to specify a region in buffer "
     "^All right. Make up your mind and come back...$"
     "^Current buffer is not visiting any file$"
     "^Failed to retrieve revision: $"
     "^Can't determine display width.$"
     "^File `.*' does not exist or is not readable$"
     "^File `.*' is a directory$"
     "^Buffer .* doesn't exist$"
     "^Directories . and . are the same: "
     "^Directory merge aborted$"
     "^Merge of directory revisions aborted$"
     "^Buffer .* doesn't exist$"
     "^There is no file to merge$"
     "^Version control package .*.el not found. Use vc.el instead$"
     )
  "*My list of ignored signals.  These will not cause an entry into the
debugger if encountered when `debug-on-error' is non-nil.
This list was copped from fdb.el by Anders Lindgren <andersl@csd.uu.se>
See also `debug-ignored-errors'.")


(error 'end-of-buffer "booya")




(error "msg")







(setq debug-ignored-errors nil)
nil

nil

(setq debug-ignored-errors dp-debug-ignored-errors)





(end-of-buffer "msg")

debug-ignored-errors


Signaling: (file-supersession "File reverted" "/home/davep/lisp/devel/elisp-devel.el")
  signal(file-supersession ("File reverted" "/home/davep/lisp/devel/elisp-devel.el"))
  byte-code("..." [buffer-backed-up help-char cursor-in-echo-area tem filename answer nil message "%s changed on disk; really edit the buffer? (y, n, r or C-h) " file-name-nondirectory t read-char help assoc ((?n . yield) (?\^G . yield) (?y . proceed) (?r . revert) (?\? . help)) beep "Please type y, n or r; or ? for help" sit-for 3 ask-user-about-supersession-help revert revert-buffer buffer-modified-p signal file-supersession "File reverted" yield "File changed on disk" "File on disk now will become a backup file if you save these changes."] 5)
  ask-user-about-supersession-threat-minibuf("/home/davep/lisp/devel/elisp-devel.el")
  ask-user-about-supersession-threat("/home/davep/lisp/devel/elisp-devel.el")
  self-insert-command(1)
  call-interactively(self-insert-command)

From emacs:
debug-ignored-errors:
"^No possible abbreviation preceding point$"
"^Current buffer has no process$"
file-supersession
"^Cannot switch buffers in a dedicated window$"
"^Errors in diff output. Diff output is in "
"^Hmm... I don't see an Ediff command around here...$"
"^Undocumented command! Type `G' in Ediff Control Panel to drop a note to the Ediff maintainer$"
": This command runs in Ediff Control Buffer only!$"
": Invalid op in ediff-check-version$"
"^ediff-shrink-window-C can be used only for merging jobs$"
"^Lost difference info on these directories$"
"^This command is inapplicable in the present context$"
"^This session group has no parent$"
"^Can't hide active session, $"
"^Ediff: something wrong--no multiple diffs buffer$"
"^Can't make context diff for Session $"
"^The patch buffer wasn't found$"
"^Aborted$"
"^This Ediff session is not part of a session group$"
"^No active Ediff sessions or corrupted session registry$"
"^No session info in this line$"
"^`.*' is not an ordinary file$"
"^Patch appears to have failed$"
"^Recomputation of differences cancelled$"
"^No fine differences in this mode$"
"^Lost connection to ancestor buffer...sorry$"
"^Not merging with ancestor$"
"^Don't know how to toggle read-only in buffer "
"Emacs is not running as a window application$"
"^This command makes sense only when merging with an ancestor$"
"^At end of the difference list$"
"^At beginning of the difference list$"
"^Nothing saved for diff .* in buffer "
"^Buffer is out of sync for file "
"^Buffer out of sync for file "
"^Output from `diff' not found$"
"^You forgot to specify a region in buffer "
"^All right. Make up your mind and come back...$"
"^Current buffer is not visiting any file$"
"^Failed to retrieve revision: $"
"^Can't determine display width.$"
"^File `.*' does not exist or is not readable$"
"^File `.*' is a directory$"
"^Buffer .* doesn't exist$"
"^Directories . and . are the same: "
"^Directory merge aborted$"
"^Merge of directory revisions aborted$"
"^Buffer .* doesn't exist$"
"^There is no file to merge$"
"^Version control package .*.el not found. Use vc.el instead$"


(setq debug-ignored-errors
   '(beginning-of-line
     beginning-of-buffer
     end-of-line
     end-of-buffer
     end-of-file
     buffer-read-only
     undefined-keystroke-sequence
     "^Previous command was not a yank$"
     "^Command attempted to use minibuffer while in minibuffer$"
     "^Minibuffer window is not active$"
     "^End of history; no next item$"
     "^Beginning of history; no preceding item$"
     "^No recursive edit is in progress$"


;     "^Changes to be undone are outside visible portion of buffer$"
;     "^No undo information in this buffer$"
;     "^No further undo information$"
;     "^Save not confirmed$"
;     "^Recover-file cancelled\\.$"
;     "^Attempt to save to a file which you aren't allowed to write$"
;     "^"File reverted$"



;     "^The mode `.*' does not support Imenu$"
;     "^This buffer cannot use `imenu-default-create-index-function'$"

;     ;;XEmacs
;     "^No preceding item in "
;     "^No following item in "
;     "^Unbalanced parentheses$"
;     "^no selection$"
;     "^No selection or cut buffer available$"



   
;     ;; comint
;     "^Not at command line$"
;     "^Empty input ring$"
;     "^No history$"
;     "^Not found$";; Too common?
;     "^Current buffer has no process$"
   
;     ;; dabbrev
;     "^No dynamic expansion for \".*\" found\\.$"
;     "^No further dynamic expansions? for .* found\\.?$"
   
;     ;; Completion
;     (concat "^To complete, the point must be after a symbol at "
;	     "least [0-9]* character long\\.$")
;     "^The string \".*\" is too short to be saved as a completion\\.$"
   
;     ;; Compile
;     "^No more errors\\( yet\\|\\)$"
   
;     ;; Gnus
;     "^NNTP: Connection closed\\.$"
   
;     ;; info
;     "^Node has no Previous$"
;     "^No \".*\" in index$"
   
;     ;; imenu
;     "^No items suitable for an index found in this buffer\\.$"
;     "^The mode \".*\" does not take full advantage of imenu\\.el yet\\.$"
   
;     ;; ispell
;     "^No word found to check!$"
   
;     ;; mh-e
;     "^Cursor not pointing to message$"
;     "^There is no other window$"
   
;     ;; man
;     "^No manpage [0-9]* found$"
   
;     ;; etags
;     "^No tags table in use!  Use .* to select one\\.$"
;     "^There is no default tag$"
;     "^No previous tag locations$"
;     "^File .* is not a valid tags table$"
;     "^No \\(more \\|\\)tags \\(matching\\|containing\\) "
;     "^Rerun etags: `.*' not found in "
;     "^All files processed\\.$"
	
;     ;; BBDB
;     "^no previous record$"
;     "^no next record$"

     ;; copied from emacs
;     "^No possible abbreviation preceding point$"
;     "^Current buffer has no process$"
;     file-supersession
;     "^Cannot switch buffers in a dedicated window$"
     ;; ediff errors
;     "^Errors in diff output. Diff output is in "
;     "^Hmm... I don't see an Ediff command around here...$"
;     "^Undocumented command! Type `G' in Ediff Control Panel to drop a note to the Ediff maintainer$"
;     ": This command runs in Ediff Control Buffer only!$"
;     ": Invalid op in ediff-check-version$"
;     "^ediff-shrink-window-C can be used only for merging jobs$"
;     "^Lost difference info on these directories$"
;     "^This command is inapplicable in the present context$"
;     "^This session group has no parent$"
;     "^Can't hide active session, $"
;     "^Ediff: something wrong--no multiple diffs buffer$"
;     "^Can't make context diff for Session $"
;     "^The patch buffer wasn't found$"
;     "^Aborted$"
;     "^This Ediff session is not part of a session group$"
;     "^No active Ediff sessions or corrupted session registry$"
;     "^No session info in this line$"
;     "^`.*' is not an ordinary file$"
;     "^Patch appears to have failed$"
;     "^Recomputation of differences cancelled$"
;     "^No fine differences in this mode$"
;     "^Lost connection to ancestor buffer...sorry$"
;     "^Not merging with ancestor$"
;     "^Don't know how to toggle read-only in buffer "
;     "Emacs is not running as a window application$"
;     "^This command makes sense only when merging with an ancestor$"
;     "^At end of the difference list$"
;     "^At beginning of the difference list$"
;     "^Nothing saved for diff .* in buffer "
;     "^Buffer is out of sync for file "
;     "^Buffer out of sync for file "
;     "^Output from `diff' not found$"
;     "^You forgot to specify a region in buffer "
;     "^All right. Make up your mind and come back...$"
;     "^Current buffer is not visiting any file$"
;     "^Failed to retrieve revision: $"
;     "^Can't determine display width.$"
;     "^File `.*' does not exist or is not readable$"
;     "^File `.*' is a directory$"
;     "^Buffer .* doesn't exist$"
;     "^Directories . and . are the same: "
;     "^Directory merge aborted$"
;     "^Merge of directory revisions aborted$"
;     "^Buffer .* doesn't exist$"
;     "^There is no file to merge$"
;     "^Version control package .*.el not found. Use vc.el instead$"
     ))



debug-ignored-errors

(error "YA!")

========================================================================
========================
2002-10-28T15:45:03
--

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
	       ((integerp undo-item) nil) ; movement
	       ((integerp undo-car) (setq pos undo-car)) ; insertion
	       ; deletion
	       ((stringp undo-car) 
		(setq pos (abs (cdr undo-item))))
	       ((eq undo-car t)  nil))	; mod time change?
	      (when pos
		;;(goto-char pos)
		(message "ui: %s, uc: %s, pos: %d" undo-item undo-car pos)
		(throw 'done pos)))
	    nil))
    stat))

========================
2002-10-29T20:32:44
--
(defun mmm-check-changed-buffers ()
  "Run major mode hook for the buffers in `mmm-changed-buffers-list'."
  (remove-hook 'post-command-hook 'mmm-check-changed-buffers)
  (dolist (buffer mmm-changed-buffers-list)
    (dmessage "mmm-ccb>%s<" buffer)
    (when (buffer-live-p buffer)
      (save-excursion
        (set-buffer buffer)
        (mmm-run-major-mode-hook))))
  (setq mmm-changed-buffers-list '()))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;========================
;2002-11-01T22:37:10
;--
(defun dp-next-line+wrap ()
  (interactive)
  (condition-case nil
      (next-line 1)			; !! doesn't preserve column
    (error
     (set-goal-column (current-column))
     (goto-line 1))))


(nth 2 '(a b c d))
c

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;========================
;2002-11-05T12:25:49
;--
(defun dp-fmp ()
  (interactive)
  ;; info: pre count post
  (let ((info (cond
		((looking-at "[[({]") '(0 1 -1))
		((looking-at "[])}]") '(1 -1 0))
		(t nil)))
	ppos)
    (if info
	(progn
	  (forward-char (nth 0 info))
	  (setq ppos (scan-sexps (point) (nth 1 info)))
	  (goto-char ppos)
	  (forward-char (nth 2 info)))
      (message "Not on paren."))))
dp-fmp

(defun dp-copied-from-vi-find-matching-paren ()
  "\"Locate the matching paren.  It's a hack right now.\"
Also, if on a CPP conditional directive, find complementary part:
{if[xx]|else|elif} -> endif, endif -> if[xx]."
  (interactive)
  (dp-set-zmacs-region-stays t)
  (let (ifdef-item)
    (cond 
     ((looking-at "[[({<]") (goto-char (1- (scan-sexps (point) 1))))
     ((looking-at "[])}>]") (goto-char (scan-sexps (1+ (point)) -1)))
     ((setq ifdef-item (dp-get-ifdef-item))
      (cond
       ((or (eq ifdef-item 'dp-if)
	    (eq ifdef-item 'dp-else)
	    (eq ifdef-item 'dp-elif)) (hif-ifdef-to-endif))
       ((eq ifdef-item 'dp-endif) (hif-endif-to-ifdef))
       (t (ding))))
      (t (ding)))))

'(a b c)
    
========================
2002-11-06T21:38:24
--
(put 'mail-mode 'flyspell-mode-predicate 'mail-mode-flyspell-verify)

;; fix up flyspell mode in mew buffers
;; like in the flyspell example

headers...
Subject:
headers...
----

msg

--
sig

already have: dp-sig-start-marker
now	have: dp-mail-header-end-marker *** Need to make 0th line marker.

need predicate that is true if:

((point) < header-end)
   (line == ^Subject:

;; handle cited lines?
(defun dp-flyspell-mew-draft-mode-p ()
  (cond
   ((< (point) dp-mail-header-end-marker)
    (save-excursion (beginning-of-line) (looking-at "^Subject:")))
   ((>= (point) dp-sig-start-marker) nil)
   (t t)))



(put 'mew-draft-mode 'flyspell-mode-predicate 'dp-flyspell-mew-draft-mode-p)
dp-flyspell-mew-draft-mode-p
========================
2002-11-07T17:00:26
--
(insert (shell-command-to-string "cat ~/bin/dogo"))
#!/bin/sh
#set -x
eval y=\$$1	# see if dest is set as an environment variable
argWas=$1
case $y in
	""|\$*)	# dest is not an envvar: look it up in the go database
		case $1 in
			back|b) echo ${GoBack-$HOME} ;;
			"") echo . ; exit ;;
			*) gPath=${GOPATH-$HOME/.go}
				oldIFS=$IFS
				IFS=":"
				for pathEl in $gPath
				do
					[ -f "$pathEl" ] && {
						IFS=$oldIFS
						tmp=`fgrep "|$1|" $pathEl` && {
							set -- $tmp
							eval echo $2
							exit
						}
					}
				done
				IFS=$oldIFS
			   echo $argWas
			   ;;
		esac ;;

	*) eval echo $y ; exit ;;
esac

nil

========================
2002-11-07T17:43:09
--
(insert (shell-command-to-string "cat ~/bin/dogo"))

(setq dp-copy-of-file-name-handler-alist file-name-handler-alist)
(("." . dired-handler-fn) ("^/[^/:]+:" . efs-file-handler-function) ("^/$" . efs-root-handler-function) ("^/\\([[][^]]*\\)?$" . tramp-completion-file-name-handler) ("\\`/\\[.*\\]" . tramp-file-name-handler) ("\\(^\\|[^$]\\)\\(\\$\\$\\)*\\$[{a-zA-Z0-9]" . efs-sifn-handler-function))

file-name-handler-alist
(("^/\\([[][^]]*\\)?$" . tramp-completion-file-name-handler) ("\\`/\\[.*\\]" . tramp-file-name-handler) ("^/[^/:]+:" . remote-path-file-handler-function))



(setq file-name-handler-alist 
'( ("^/sudo-edit:" . dp-sudo-edit-handler-fn)
("." . dired-handler-fn) ("^/[^/:]+:" . efs-file-handler-function) ("^/$" . efs-root-handler-function) ("^/\\([[][^]]*\\)?$" . tramp-completion-file-name-handler) ("\\`/\\[.*\\]" . tramp-file-name-handler) ("\\(^\\|[^$]\\)\\(\\$\\$\\)*\\$[{a-zA-Z0-9]" . efs-sifn-handler-function)))
(("^/sudo-edit:" . dp-sudo-edit-handler-fn) ("." . dired-handler-fn) ("^/[^/:]+:" . efs-file-handler-function) ("^/$" . efs-root-handler-function) ("^/\\([[][^]]*\\)?$" . tramp-completion-file-name-handler) ("\\`/\\[.*\\]" . tramp-file-name-handler) ("\\(^\\|[^$]\\)\\(\\$\\$\\)*\\$[{a-zA-Z0-9]" . efs-sifn-handler-function))

(defvar dp-sudo-edit-prefix "/sudo-edit#")

(defvar dp-sudo-edit-prefix-regexp (concat "^" dp-sudo-edit-prefix))

(add-to-list 'file-name-handler-alist 
	     (cons dp-sudo-edit-prefix-regexp 'dp-sudo-edit-handler-fn))

(defvar dp-sudo-edit-handler-alist
  '((substitute-in-file-name . dp-sudo-edit-file-name-fn)
    (expand-file-name        . dp-sudo-edit-file-name-fn)
    (abbreviate-file-name    . dp-sudo-edit-file-name-fn)
    (file-name-directory     . dp-sudo-edit-file-name-fn)
    (file-name-nondirectory  . dp-sudo-edit-file-name-fn)
    (file-name-sans-versions . dp-sudo-edit-file-name-fn)
;    (get-file-buffer         . dp-sudo-edit-file-name-fn)
    (file-directory-p        . dp-sudo-edit-file-op-fn)
    (file-attributes         . dp-sudo-edit-file-op-fn)
    ))
dp-sudo-edit-handler-alist

(defun dp-sudo-edit-file-op-fn (func fname &rest rest)
  (setq fname (replace-in-string fname dp-sudo-edit-prefix-regexp ""))
  (if rest
      (apply func fname rest)
    (apply func (list fname))))

(defun dp-sudo-edit-file-op-no-subst-fn (func fname &rest rest)
  (if rest
      (apply func fname rest)
    (apply func (list fname))))

(defun dp-sudo-edit-file-name-fn (op fname &rest rest)
  (let (ret)
    ;; remove prefix
    (dmessage "fname1>%s<" fname)
    (setq fname (replace-in-string fname dp-sudo-edit-prefix-regexp ""))
    (dmessage "fname2>%s<" fname)
    ;; apply function to prefix-less fname
    (setq ret (funcall op fname))
    (dmessage "ret1>%s<" ret)
    (setq ret (concat dp-sudo-edit-prefix ret))
    (dmessage "ret2>%s<" ret)
    ret))

(defun dp-sudo-edit-handler-fn (op &rest rest)
  (dmessage "handler: op>%s<, rest>%s<" op rest)
  (let ((handler (assoc op dp-sudo-edit-handler-alist))
	(inhibit-file-name-handlers (list 'dp-sudo-edit-handler-fn))
	(inhibit-file-name-operation op))
    (if handler
	(apply (cdr handler) op rest)
      (dmessage "handler: using default handler.")
      (apply op rest))))


========================
2002-11-12T12:45:01
--
(defconst hif-cpp-prefix "\\(^\\|\r\\)[ \t]*#[ \t]*")
(defconst hif-ifndef-regexp (concat hif-cpp-prefix "ifndef"))
(defconst hif-ifx-regexp (concat hif-cpp-prefix "if\\(n?def\\)?[ \t]+"))
(defconst hif-else-regexp (concat hif-cpp-prefix "else"))
(defconst hif-endif-regexp (concat hif-cpp-prefix "endif"))
(defconst hif-ifx-else-endif-regexp
  (concat hif-ifx-regexp "\\|" hif-else-regexp "\\|" hif-endif-regexp))

(defvar dp-makefile-mode-ifx-re-alist 
  '((dp-if . "[ 	]*if")		; gets #if, #ifdef and #endif.
    (dp-else . "[ 	]*else")
    (dp-elif . "[ 	]*elif")	; ignored by the hideif stuff.
    (dp-endif . "[ 	]*endif"))
  "alist of regexps to find and identify CPP conditional directives")

(defun dp-makefile-mode-find-matching-paren ()
  (interactive)
  (let* (
	 (hif-ifndef-regexp "^ifndef")
	 (hif-ifx-regexp "^if\\(n?\\(def\\|eq\\)\\)?[ \t]*")
	 (hif-else-regexp "^else")
	 (hif-endif-regexp "^endif")
	 (hif-ifx-else-endif-regexp
	  (concat hif-ifx-regexp "\\|" hif-else-regexp "\\|" hif-endif-regexp)))
    (dp-find-matching-paren dp-makefile-mode-ifx-re-alist)))

(defun tss ()
  (interactive)
  (insert (dp-timestamp-string)))

2002-11-12T16:06:29

========================
2002-11-22T23:21:11
--

(defun shell-process-cd (arg)
  (let ((new-dir (cond ((zerop (length arg)) (concat comint-file-name-prefix
						     "~"))
		       ((string-equal "-" arg) shell-last-dir)
		       (t (shell-prefixed-directory-name arg)))))
    (setq shell-last-dir default-directory)
    (shell-cd-1 new-dir shell-dirstack)))


(defun shell-cd-1 (dir dirstack)
  (if shell-dirtrackp
      (setq list-buffers-directory (file-name-as-directory
				    (expand-file-name dir))))
  (condition-case nil
      (progn (if (file-name-absolute-p dir)
                 ;;(cd-absolute (concat comint-file-name-prefix dir))
		 (cd-absolute dir)
	       (cd dir))
             (setq shell-dirstack dirstack)
             (shell-dirstack-message))
    (file-error (message "Couldn't cd."))))

(defun dp-shell-process-go (arg)
  (interactive "sdir: ")
  (let ((new-dir (and dp-go-abbrev-table
		      (abbrev-expansion arg dp-go-abbrev-table))))
    (shell-process-pushd (or new-dir arg))))

(defvar shell-dirtrack-other-regexp "g\\|gb"
  "*Regexp to match commands fow which we call `shell-dirtrack-process-other-func'")

;; @todo make this a full blown hook?  ?A hook which stops when a func
;; returns t? Or nil?
(defvar shell-dirtrack-process-other-func 'dp-shell-dirtrack-other
  "*Command to allow user to hook into and handle any other kind of
directory changing command.")

(defun dp-shell-dirtrack-other (cmd arg)
  (cond 
   ((string-match cmd "\\`g\\'") (dp-shell-process-go arg))
   ((string-match cmd "\\`gb\\'") 
    (let ((dir (car shell-dirstack)))
      (when dir
	(setq shell-dirstack (cdr shell-dirstack))
	(shell-directory-tracker (format "pushd %s\n" dir)))))
   (t (error "Unknown cmd in dp-shell-dirtrack-other"))))

;; we need to pull in shell-directory-tracker so we can override it
;; below
(require 'shell)

(defun shell-directory-tracker (str)
  "Tracks cd, pushd and popd commands issued to the shell.
This function is called on each input passed to the shell.
It watches for cd, pushd and popd commands and sets the buffer's
default directory to track these commands.

You may toggle this tracking on and off with \\[dirtrack-toggle].
If emacs gets confused, you can resync with the shell with \\[dirs].

See variables `shell-cd-regexp', `shell-chdrive-regexp', `shell-pushd-regexp',
and  `shell-popd-regexp', while `shell-pushd-tohome', `shell-pushd-dextract', 
and `shell-pushd-dunique' control the behavior of the relevant command.

Environment variables are expanded, see function `substitute-in-file-name'."
  (if shell-dirtrackp
      ;; We fail gracefully if we think the command will fail in the shell.
      (condition-case chdir-failure
	  (let ((start (progn (string-match "^[; \t]*" str) ; skip whitespace
			      (match-end 0)))
		end cmd arg1)
	    (while (string-match shell-command-regexp str start)
	      (setq end (match-end 0)
		    cmd (comint-arguments (substring str start end) 0 0)
		    arg1 (comint-arguments (substring str start end) 1 1))
	      (cond ((string-match (concat "\\`\\(" shell-popd-regexp
					   "\\)\\($\\|[ \t]\\)")
				   cmd)
		     (shell-process-popd (comint-substitute-in-file-name arg1)))
		    ((string-match (concat "\\`\\(" shell-pushd-regexp
					   "\\)\\($\\|[ \t]\\)")
				   cmd)
		     (shell-process-pushd (comint-substitute-in-file-name arg1)))
		    ((string-match (concat "\\`\\(" shell-cd-regexp
					   "\\)\\($\\|[ \t]\\)")
				   cmd)
		     (shell-process-cd (comint-substitute-in-file-name arg1)))
		    ;;; ++dp
		    ((and shell-dirtrack-other-regexp
			  (string-match (concat "\\`\\(" 
						shell-dirtrack-other-regexp
						"\\)\\($\\|[ \t]\\)")
				   cmd))
		     (funcall shell-dirtrack-process-other-func
			      cmd
			      (comint-substitute-in-file-name arg1)))
		    ;;; --dp
		    ((and shell-chdrive-regexp
			  (string-match (concat "\\`\\(" shell-chdrive-regexp
						"\\)\\($\\|[ \t]\\)")
					cmd))
		     (shell-process-cd (comint-substitute-in-file-name cmd))))
	      (setq start (progn (string-match "[; \t]*" str end) ; skip again
				 (match-end 0)))))
    (error "Couldn't cd"))))
 ========================
2002-11-30T01:21:10
--
(defdialect scm "Scm Scheme"
  scheme
  (setq ilisp-program "scm -i")		; assume scm is in path.
  (setq comint-prompt-regexp "^> ")
  ;;inspired by the qsci dialect
  (setq ilisp-eval-command
	"(begin (require 'string-port) ; slib specific
                (car (list (call-with-input-string \"%s\"
                              (lambda (input) (eval (read input))))
                            \"%s\" \"%s\")))"
	ilisp-package-command "%s"
	ilisp-set-directory-command "(chdir \"%s\")"
	)
  ;; (setq comint-fix-error "(ret 0)")
  ;; (setq ilisp-last-command "*")
  ;; (setq ilisp-describe-command "(describe %s)")
  )
========================
2002-12-01T15:43:33
--
(defun dpj-extract-a-record (record-info buffer)
  (buffer-substring 
   (dpj-topic-info-record-start record-info)
   (dpj-topic-info-end record-info)
   buffer))

(defun dpj-view-topic-visit-real-topic ()
  (interactive)
  (let* ((extent (car (extents-at (point) nil 'dpj-view-topic)))
	 (boo (dmessage "props>%s<" (extent-properties extent)))
	 (file (get extent 'dpj-source-file))
	 (pos (get extent 'dpj-source-start)))
    (dpj-edit-journal-file file 'must-exist)
    (goto-char pos)))

(defvar dpj-view-topic-keymap nil)
(setq dpj-view-topic-keymap (make-keymap))
(define-key dpj-view-topic-keymap "\C-m" 'dpj-view-topic-visit-real-topic)
(define-key dpj-view-topic-keymap "v" 'dpj-view-topic-visit-real-topic)
(define-key dpj-view-topic-keymap [(meta ?.)] 'dpj-view-topic-visit-real-topic)


(defun dpj-view-topic (topic-re &optional src-buffer)
  "Extract topics from current-buffer and insert into view-buffer."
  (interactive (dpj-get-topic-interactive))
  (let* ((buf-name "*dpj-view-topic*")
	 (buffer (get-buffer-create buf-name))
	 (jfile-name (buffer-file-name))
	 topic-list
	 new-start
	 new-end
	 new-extent
	 (source-file (buffer-file-name))
	 (source-buffer (or src-buffer (current-buffer))))
    (setq topics (car (dpj-find-topics topic-re)))
    (with-current-buffer buffer
      (dpj-new-topic0 (format "Journal File: %s" jfile-name))
      (insert "\n")
      (dolist (topic-info topics)
	(setq new-start (point))
	(insert (dpj-extract-a-record topic-info source-buffer))
	(setq new-end (point))
	(dp-make-extent new-start new-end
			'dpj-view-topic
			'dpj-source-file source-file
			'dpj-source-start (dpj-topic-info-topic-start 
					   topic-info)
			'keymap dpj-view-topic-keymap)
	(insert "\n")
	))))
========================
2002-12-02T23:11:26
--
(defun dpj-view-topic-history (number-of-months topic-re)
  (interactive "nNumber of months: \nstopic-re: ")
  (if (= number-of-months 0)
      (setq number-of-months 1))
  (let* ((latest-file (dpj-latest-note-file-name))
	 (latest-month-num (dpj-journal-name-to-month-num latest-file))
	 (oldest-month-name (- latest-month-num (1- number-of-months)))
	 (jmon oldest-month-name)
	 (view-buf-name "*dpj-view-topic*")
	 (view-buffer (get-buffer-create view-buf-name))
	 already-loaded
	 jfile)
  
    (with-current-buffer view-buffer
      (toggle-read-only 0)
      (erase-buffer)
      (dpj-new-topic0 (format "Visiting topic %s, from the last %d months" 
			      topic-re number-of-months)))

    (dotimes (n number-of-months)
      (setq jfile (dpj-month-num-to-journal-name jmon))
      (setq jmon (1+ jmon))
      (setq already-loaded (get-file-buffer jfile))
      (dpj-edit-journal-file jfile 'must-exist)
      (dpj-view-topic topic-re)
      (unless already-loaded
	(kill-this-buffer))
      )

    (switch-to-buffer view-buffer)
    (set-buffer-modified-p nil)
    (toggle-read-only 1)
    (dp-journal-mode)))
      
      
    
  
========================
2002-12-14T22:08:49
--
make view-grep func

========================
2002-12-17T01:05:16
--
(defun dpj-grep-topic (grep-re &optional topic-re skip-re 
			       just-remember-records)
  "Grep the bodies of the selected topic records."
  (interactive "sgrep-re: ")
  (when current-prefix-arg
    (setq topic-re (dpj-read-topic))
    (if (> (prefix-numeric-value current-prefix-arg) 4)
	(setq just-remember-records t)))
  (setq topic-re (or topic-re
		     (or dpj-next-in-topic-topic 
			 (concat "^" (car (dpj-current-topic-or-todo)) "$"))))
  (save-excursion
    (let ((matching-topics (car (dpj-find-topics topic-re nil skip-re)))
	  matching-records
	  done)
      (unless just-remember-records
	(setq dpj-grep-addrs nil))
      (dolist (topic-info matching-topics)
	(setq done nil)
	(goto-char (dpj-topic-info-record-start topic-info))
	(while (and (not done)
		    (re-search-forward grep-re 
				       (dpj-topic-info-end topic-info) t))
	  (if just-remember-records 
	      (setq matching-records (cons topic-info matching-records)
		    done t)
	    (setq dpj-grep-addrs 
		  (cons (match-beginning 0) dpj-grep-addrs)))))
      
      (if just-remember-records
	  (nreverse matching-records)
	(setq dpj-grep-addrs (nreverse dpj-grep-addrs)
	      dpj-grep-cursor dpj-grep-addrs)
	(message "grep topic: %s for %s" topic-re grep-re))
      )))
========================
2002-12-20T10:05:43
--
;;@todo !!! make this work with other shell emulator like up-n-down
(defun dp-comint-bol ()
  (interactive)
  (if (and (comint-after-pmark-p)
	   (not (eq last-command 'dp-comint-bol)))
      (call-interactively 'comint-bol)
    (setq this-command 'dp-brief-home)
    (call-interactively 'dp-brief-home)))

========================
2003-02-16T17:30:36
--

(defun dpj-find-todos-for-view-topic ()
  "Find todos in the current file and return a list of topic-info records."
  (let (rec-list
	opos
	rec-bounds)
    (goto-char (point-min))
    (catch 'done
      (while t
	(setq opos (point))
	(dpj-next-todo-this-file nil)
	(if (= opos (point))
	    (throw 'done nil))
	(setq rec-bounds (dpj-current-record-boundaries))
	;;topic-info:: (topic-string record-start topic-start record-end)
	(setq rec-list (cons (list (dpj-topic-match-string)
				   (car rec-bounds)
				   (dpj-topic-match-beginning)
				   (cdr rec-bounds))
			     rec-list))
	(goto-char (cdr rec-bounds))))
    (nreverse rec-list)))

(defun dpj-view-todos (number-of-months)
  "View all todos in preceding NUMBER-OF-MONTHS files in a view-buf."
  (interactive (list (read-number "Number of months(1): " 'integers-only "1")))
  (let ((topic-re "n/a"))		;remove use of topic-re in view code
    (dpj-view-topics number-of-months 
		     'dpj-find-todos-for-view-topic
		     nil)))
========================
2003-02-17T12:05:42
--
(defun dp-list-buffers-predicate (b &rest rest)
  (if (and b
	   (eq
	    (save-excursion
	      (set-buffer b)
	      major-mode)
	    'dired-mode))
      t
    (apply 'buffers-menu-files-only-predicate (cons b rest))))
dp-list-buffers-predicate



(setq buffers-menu-files-only-predicate 'dp-list-buffers-predicate)
dp-list-buffers-predicate

my-buffers-predicate

(setq buffers-menu-files-only-predicate 'buffers-menu-files-only-predicate)
buffers-menu-files-only-predicate

buffers-menu-predicate

buffers-menu-predicate


========================
2003-02-21T17:13:59
--
(defun dp-up-with-wrap (arg)
  (interactive "p")
  (dmessage "arg>%s<" arg)
  (let ((col (current-column))
	(resid (forward-line (- arg))))
    (dmessage "resid>%s<, gt:%s" resid (> resid 0))
    (unless (= resid 0)
	(goto-line (+ (line-number (point-max)) resid)))))

(defun dp-up-with-wrap (arg)
  (interactive "p")
  (dmessage "arg>%s<" arg)
  (let ((col (current-column)))
    (setq this-command 'previous-line)
    (condition-case nil
	(previous-line arg)
      (error 
       (let ((wrap-lines (- (line-number) arg))
	     (max-lines (line-number (point-max))))
	 (goto-line (- max-lines wrap-lines))
	 (move-to-column col))))))

(defun dp-down-with-wrap (arg)
  (interactive "p")
  (dmessage "arg>%s<" arg)
  (let ((col (current-column)))
    (setq this-command 'next-line)
    (condition-case nil
	(next-line arg)
      (error 
       (let* ((max-lines (line-number (point-max)))
	      (wrap-lines (- max-lines (line-number) arg))
	      )
	 (goto-line wrap-lines)
	 (move-to-column col))))))
dp-down-with-wrap

========================
2003-03-03T14:42:52
--
(defun dp-region-boundaries-ordered ()
  "Return the boundaries of the region ordered in a cons: \(low . hi\)"
  (let ((s (mark))
	(e (point)))
    (if (> e s)
	(cons s e)
      (cons e s))))

(defun dp-bq ()
  "Replace region w/command output using region as command."
  (interactive)
  (let* ((region (dp-region-boundaries-ordered))
	 (beg (car region))
	 (end (cdr region))
	 (command (buffer-substring beg end))
	 (output (shell-command-to-string command)))
    (when output
      (kill-region beg end)
      (goto-char beg)
      (insert output)
      (dp-set-mark beg))))


-rw-r--r--  1 davep  wheel  43344 Mar  3 14:54 elisp-devel.el
-rw-r--r--  1 davep  wheel  43394 Mar  3 14:56 elisp-devel.el

    


========================
2003-03-21T12:37:56
--
(defvar dp-ffap-file-finder-line-num nil
  "Line number parsed from filename.
If non-nil, dp-ffap-file-finder will `goto-line' with this number")

(defvar dp-ffap-ffap-file-finder ffap-file-finder)

(setq ffap-file-finder 'dp-ffap-file-finder)
;;(setq ffap-file-finder dp-ffap-ffap-file-finder)

(defun dp-ffap-file-finder ()
  "Recognize /file/name:<linenum>.
Visit /file/name and then goto <linenum>."
  (interactive)
  (let ((name (ffap-string-at-point 'file))
	line-num
	filename)
    (string-match "\\(.*\\)[@:]\\([0-9][0-9]*\\)$" name)
    (setq line-num (match-string 2 name))
    (setq filename (match-string 1 name))
    (if (and line-num
	     (file-exists-p filename)
	     (y-or-n-p (format "visit %s and goto %s? " filename line-num))
	     (find-file filename))
	(goto-line (string-to-int line-num))
      (call-interactively 'find-file-at-point))))
    


(defvar dp-ffap-ffap-file-finder ffap-file-finder
  "Copy of `ffap-file-finder', since we point it our function.")

(setq ffap-file-finder 'dp-ffap-file-finder2)

(defun dp-ffap-file-finder2 (name-in)
  "Recognize /file/name:<linenum>.
Visit /file/name and then goto <linenum>."
  (interactive)
  (let ((name (ffap-string-at-point 'file))
	(file-name-in (file-name-nondirectory name-in))
	line-num
	filename)
    (when (string-match "\\(.*\\)[@:]\\([0-9][0-9]*\\)$" name)
      (setq line-num (match-string 2 name))
      (setq filename (file-name-nondirectory (match-string 1 name))))
    (if (and line-num
	     (string= filename file-name-in)
	     (file-exists-p filename)
	     (y-or-n-p (format "visit %s and goto %s? " filename line-num))
	     (funcall dp-ffap-ffap-file-finder filename))
	(progn
	  (if (find-buffer-visiting name-in)
	      (dp-push-go-back))
	  (goto-line (string-to-int line-num)))
      (funcall dp-ffap-ffap-file-finder name-in))))
========================
2003-03-25T19:14:53
--
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
	 (if (string-match efs-cmd-ok-cmds efs-process-cmd)
	     (setq efs-process-busy nil
		   efs-process-result nil
		   efs-process-result-line line)))

	((string-match efs-pending-msgs line)
	 (if (string-match "^quote rnfr " efs-process-cmd)
	     (setq efs-process-busy nil
		   efs-process-result nil
		   efs-process-result-line line)))
	
	((string-match efs-bytes-received-msgs line)
	 (if efs-process-server-confused
	     (setq efs-process-busy nil
		   efs-process-result nil
		   efs-process-result-line line)))
	
	((string-match efs-server-confused-msgs line)
	 (setq efs-process-server-confused t))

	((string-match efs-good-msgs line)
	 (setq efs-process-busy nil
	       efs-process-result nil
	       efs-process-result-line line))

	((string-match efs-fatal-msgs line)
	 (edebug)
	 (dmessage "++delete-proc0, proc>%s<, line>%s<" proc line)
	 (set-process-sentinel proc nil)
	 (delete-process proc)
	 (dmessage "--delete-proc0")
	 (setq efs-process-busy nil
	       efs-process-result 'fatal
	       efs-process-result-line line))
	
	((string-match efs-failed-msgs line)
	 (setq efs-process-busy nil
	       efs-process-result 'failed
	       efs-process-result-line line))
	
	((string-match efs-unknown-response-msgs line)
	 (setq efs-process-busy nil
	       efs-process-result 'weird
	       efs-process-result-line line)
	 (efs-process-scream-and-yell line))))

========================
2003-03-27T17:33:50
--
(defun dired-handler-fn (op &rest args)
  ;; Function to update dired buffers after I/O.
  (prog1
      (let ((inhibit-file-name-handlers
	     (cons 'dired-handler-fn
		   (and (eq inhibit-file-name-operation op)
			inhibit-file-name-handlers)))
	    (inhibit-file-name-operation op)
	    rc)
	(dmessage "1op:%s, args>%s<, kill-buffer-hooks>%s<"
		  op args kill-buffer-hook)
	(setq rc (apply op args))
	(dmessage "2op:%s, args>%s<, kill-buffer-hooks>%s<"
		  op args kill-buffer-hook)
	rc
	)

    (let ((dired-omit-silent t)
	  (hf (get op 'dired))
	  rc)
      (when hf 
	(dmessage "3op:%s, args>%s<, kill-buffer-hooks>%s<"
		  op args kill-buffer-hook)
	(setq rc (funcall hf args))
	(dmessage "4op:%s, args>%s<, kill-buffer-hooks>%s<"
		  op args kill-buffer-hook)
	rc
	))))

========================
2003-03-28T16:46:38
--
(setq lines 
      '("421 No Transfer Timeout (300 seconds): closing control connection."
	"421 Service not available, remote server has closed connection."))
("421 No Transfer Timeout (300 seconds): closing control connection." "421 Service not available, remote server has closed connection.")

(dolist (line lines)
  (loop for line in lines
    collect (cons (string-match efs-fatal-msgs line) line))
((0 . "421 No Transfer Timeout (300 seconds): closing control connection.") (0 . "421 Service not available, remote server has closed connection."))

========================
2003-03-30T02:25:01
--

(defvar debug-setq-syms nil
  "List of symbols upon whose setting we wish to break.")

;; has to be a macro since sym is unevalled.
;; if macro, we won't work w/previously compiled code.
;; but most of interest can be reevalled.
;; but if we have no idea where something is being set, we're hosed.
(defmacro debug-setq (&rest args)
  (assert (= (% (length args) 2) 0))
  (let (sym val result)
    (while args
      (
    

(defmacro boo ()
  "macboo")
boo

(boo)
"macboo"

"macboo"

"boo"

"boo"

"boo"



(symbol-function 'boo)
(macro lambda nil "macboo")
(symbol-function 'blah)
(lambda nil (concat (boo) "--" "blah"))

nil



(defun boo ()
  "boo")


(defun blah ()
  (concat (boo) "--" "blah"))
blah



(blah)
"macboo--blah"

"boo--blah"

========================
2003-04-03T12:37:08
--
(defun dired-find-file ()
  "In dired, visit the file or directory named on this line."
  (interactive)
  (let ((find-file-run-dired t))
    (find-file (dired-get-filename))
    (dmessage "bn>%s<, kill-buffer-hook>%s<" 
	      (buffer-name)
	      kill-buffer-hook)
    ))


(defun dpj-tidy-journals ()
  "Kill all but the most recent journal buffers."
  (interactive)
  (let ((latest-journal (dpj-latest-note-file-name)))
    (dolist (buf (buffer-list))
      (set-buffer buf)
      (when (and (eq major-mode 'dp-journal-mode)
		 (not (string= (buffer-file-name) latest-journal)))
	(if (buffer-modified-p)
	    (if (y-or-n-p (format "Save %s? " (buffer-file-name)))
		(save-buffer)))
	(kill-buffer buf)))
	
    (switch-to-buffer (find-buffer-visiting latest-journal))
    (setq dpj-current-journal-file latest-journal)))
  
(buffer-list)
(#<buffer "elisp-devel.el"> #<buffer " *Minibuf-0*"> #<buffer "*Buffer List*"> #<buffer "daily-2003-02.jxt"> #<buffer "daily-2003-03.jxt"> #<buffer "daily-2003-04.jxt"> #<buffer "dp-journal.el"> #<buffer "*Dictionary buffer*<3>"> #<buffer "*Dictionary buffer*<2>"> #<buffer "mew-vars.el"> #<buffer "*shell*"> #<buffer "index-ports"> #<buffer "*Dictionary buffer*"> #<buffer "*scratch*"> #<buffer " *Echo Area*"> #<buffer " *pixmap conversion*"> #<buffer " *load*"> #<buffer " *Message-Log*"> #<buffer " *substitute*"> #<buffer "diary"> #<buffer " *Mew* +inbox"> #<buffer " *string-output*"> #<buffer "*journal-topics*"> #<buffer " *string-output*<2>"> #<buffer " *string-output*<3>"> #<buffer " *string-output*<4>"> #<buffer " *string-output*<5>"> #<buffer " *string-output*<6>"> #<buffer " *mew cache*0"> #<buffer " *mew cache*1"> #<buffer " *mew cache*2"> #<buffer " *mew cache*3"> #<buffer " *mew cache*4"> #<buffer "*Completions*"> #<buffer " *string-output*<7>"> #<buffer " *string-output*<8>"> #<buffer "*Warnings*"> #<buffer " connection to dict.org:2628"> #<buffer "*Hyper Help*"> #<buffer "*Help: function `set-buffer'*"> #<buffer "*Hyper Apropos*"> #<buffer " *mew cache*5"> #<buffer "*Mew message*0"> #<buffer "+etail"> #<buffer "+inbox">)

#<window on "*Buffer List*" 0x1694b>

========================
2003-04-29T16:59:39
--


(defface dp-highlight-point-before-face
  '((((class color) (background light)) 
     (:background "plum"))) 
  "Face before point."
  :group 'faces
  :group 'dp-vars)

(defface dp-highlight-point-after-face
  '((((class color) (background light)) 
     (:background "plum"))) 
  "Face after point."
  :group 'faces
  :group 'dp-vars)

(defface dp-highlight-point-face
  '((((class color) (background light)) 
     (:background "yellow"))) 
  "Face for point."
  :group 'faces
  :group 'dp-vars)


(defun dp-highlight-point (&optional point)
  "lskdjslk kljdskjd lskdjslkdj lskdjslkdjslj klsdjlkdj slkdjskdjlkj
  skdjskdjlkdjslkjd"

  (interactive)
  (unless point
    (setq point (point)))
  (let ((bol (line-beginning-position))
	(eol (line-end-position))
	(pp (1+ point)))
    (if (< bol point)
	(dp-make-extent bol point
			'dp-highlight-point
			'face 'dp-highlight-point-before-face))
    (if (<= pp eol)
	(dp-make-extent point pp
			'dp-highlight-point
			'face 'dp-highlight-point-face))
    (if (> eol pp)
	(dp-make-extent pp eol
			'dp-highlight-point
			'face 'dp-highlight-point-after-face))))

(defun dp-unhighlight-point (&optional point)
  (interactive)
  (unless point
    (setq point (point)))
  (dp-delete-extents (line-beginning-position) (line-end-position) 
		     'dp-highlight-point))

  

	  

========================
Friday May 23 2003
--
(setq text-mode-hook '(dp-text-mode-hook text-mode-hook-identify))



  


========================
Saturday May 24 2003
--
(defun dp-sudo-edit-do-cmd (start end passwd readp &rest args)
  ;; clear pw cache
  (call-process "sudo" nil nil nil "-k")
  (let ((proc (apply 'start-process 
		     " *sudo-edit-sudoer*" 
		     (current-buffer)
		     ;;"cmd-logger.sh" 
		     dp-sudo-edit-sudoer
		     (append (list "-S")
		     args)))
	(proc-stat -1)
	(opoint (point)))
    (unwind-protect
	(progn
	  (if passwd
	      (process-send-string proc (concat passwd "\n")))
	  (if start
	      (process-send-region proc start end))
;	  (if (or passwd start)
;	      (process-send-eof proc))
	  (when readp
	    (setq proc-stat
		  (catch 'proc-stat
		    (set-process-sentinel
		     proc
		     #'(lambda (proc status)
			 (dmessage "proc>%s<, \nstatus>%s<"
				   proc status)
			 (cond ((eq 'exit (process-status proc))
				(set-process-sentinel proc nil)
				(throw 'proc-stat
				       (process-exit-status proc)))
			       ((eq 'signal (process-status proc))
				(set-process-sentinel proc nil)
				(throw 'proc-stat status)))))
		    
		    (while t
		      (dmessage "+ya")
		      (accept-process-output proc)
		      (dmessage "-ya")))
		  ;; delete pw string from buffer if at opoint
		  )))
      (if proc (set-process-sentinel proc nil)))
    (condition-case nil
	(if (and proc (process-live-p proc)) (kill-process proc))
      (error nil))
    (dmessage "YOPP1")
    proc-stat))


(defun dp-sudo-edit-insert-file-contents (op file-name &rest rest)
  "Provide the `insert-file-contents' functionality.
Not all options are supported."
  (let ((opoint (point))
	handler-entry)
    (if (file-exists-p file-name)
	;;(call-process dp-sudo-edit-sudoer nil t nil "cat" file-name)
	(dp-sudo-edit-do-cmd nil nil
			     "gore-tex"
			     'read
			     (format "cat %s" file-name)))

    ;; @todo fix use of visit, take from rest, (nth 0 rest)
    (when visit
      (setq buffer-file-name file-name)
      (set-visited-file-modtime))

    (unless dp-sudo-edit-handler-entry
      (setq handler-entry (dp-sudo-edit-mk-handler-alist-entry file-name))
      (add-to-list 'file-name-handler-alist handler-entry)
      (dp-sudo-edit-common-setup handler-entry))

    (goto-char (point-min))
    (list file-name (- (point) opoint))
    ))



========================
Sunday May 25 2003
--
(defun mc-process-region (beg end passwd program args parser &optional buffer)
  (let ((obuf (current-buffer))
	(process-connection-type nil)
	mybuf result rgn proc)
    (unwind-protect
	(progn
	  (setq mybuf (or buffer (generate-new-buffer " *mailcrypt temp")))
	  (set-buffer mybuf)
	  (erase-buffer)
	  (set-buffer obuf)
	  (buffer-disable-undo mybuf)
	  (setq proc
		(apply 'start-process "*PGP*" mybuf program args))
	  (if passwd
	      (progn
		(process-send-string proc (concat passwd "\n"))
		(or mc-passwd-timeout (mc-deactivate-passwd t))))
	  (process-send-region proc beg end)
	  (process-send-eof proc)
	  (while (eq 'run (process-status proc))
	    (accept-process-output proc 5))
	  (setq result (process-exit-status proc))
	  ;; Hack to force a status_notify() in Emacs 19.29
	  (delete-process proc)
	  (set-buffer mybuf)
	  (goto-char (point-min))
	  (let ((case-fold-search nil))
	    (if (re-search-forward "xx" nil t)
		(debug)))
	  (goto-char (point-max))
	  (if (re-search-backward "\nProcess \\*PGP.*\n\\'" nil t)
	      (delete-region (match-beginning 0) (match-end 0)))
	  (goto-char (point-min))
	  ;; CRNL -> NL
	  (while (search-forward "\r\n" nil t)
	    (replace-match "\n"))
	  ;; Hurm.  FIXME; must get better result codes.
	  (if (stringp result)
	      (error "%s exited abnormally: '%s'" program result)
	    (setq rgn (funcall parser result))
	    ;; If the parser found something, migrate it
	    (if (consp rgn)
		(progn
		  (set-buffer obuf)
		  (delete-region beg end)
		  (goto-char beg)
		  (insert-buffer-substring mybuf (car rgn) (cdr rgn))
		  (set-buffer mybuf)
		  (delete-region (car rgn) (cdr rgn)))))
	  ;; Return nil on failure and exit code on success
	  (if rgn result))
      ;; Cleanup even on nonlocal exit
      (if (and proc (eq 'run (process-status proc)))
	  (interrupt-process proc))
      (set-buffer obuf)
      (or buffer (null mybuf) (kill-buffer mybuf)))))


(setq dp-sudo-edit-sudoer "/usr/ports/security/sudo/work/sudo-1.6.7p4/sudo")
(setq dp-sudo-edit-sudo-template 
      (concat dp-sudo-edit-sudoer " -k && " 
	      dp-sudo-edit-sudoer " -S %s"))

(defun dp-sudo-edit-do-cmd (start end passwd readp cmd)
  ;; clear pw cache
  (let (proc 
	(proc-stat -1)
	(opoint (point)))
      (unwind-protect
	  (progn
	    (setq proc (start-process-shell-command
			"*sudo-edit-sudoer*" 
			(current-buffer)
			;;"cmd-logger.sh" 
			(format dp-sudo-edit-sudo-template cmd)))
	    (when passwd
	      (accept-process-output proc 1)
	      (process-send-string proc (concat passwd "\n"))
	      )
	    (if start
		(process-send-region proc start end))
;	  (if (or passwd start)
;	      (process-send-eof proc))
	    (when readp
	      (while (eq 'run (process-status proc))
		(accept-process-output proc 5))))
	(setq proc-stat (process-exit-status proc))
	(condition-case nil
	    (if proc (delete-process proc))
	  (error nil)))
    proc-stat
    ))


(defun dp-sudo-edit-do-cmd (start end passwd readp &rest args)
  ;; clear pw cache
  (call-process "sudo" nil nil nil "-k")
  (let (proc 
	(proc-stat -1)
	(opoint (point)))
      (unwind-protect
	  (progn
	    (setq proc (apply 'start-process 
			      "*sudo-edit-sudoer*" 
			      (current-buffer)
			      "cmd-logger.sh" 
			      ;;dp-sudo-edit-sudoer
			      (append (list "-S")
				      args)))
	    (insert "+++\n")
	    (sit-for 0.5))
	  (delete-process proc))
      (dmessage "boo!")
      0))

========================
Sunday June 01 2003
--
(defvar dp-message-grep-regexps '("eh-oh" "blah[0-9]*")
  "Regexps to grep for in calls to `message'.")

(defvar dp-insert-grep-regexps '("zzz*" "blah[A-F]*")
  "Regexps to grep for in calls to `insert'.")

(defvar dp-original-message 'message
  "Original value of `message' function.")

(defvar dp-original-insert  'insert
  "Original value of `insert' function.")

(defun dp-grep-listzzzzzzzzzzzz (regexps &rest args)
  (message "res>%s<, args>%s<" regexps args)
  (dolist (arg args)
    (when (stringp arg)
      (dolist (regexp regexps)
	(if (string-match regexp arg)
	    ;;(debug)
	    (message "woulda debugged")
	  )))))

(defun dp-message-grep (fmt &rest args)
  (let ((s (apply 'format fmt args)))
    (dp-grep-list dp-message-grep-regexps s)
    (funcall dp-original-message "%s" s)))

(defun dp-insert-grep (&rest args)
  (apply 'dp-grep-list dp-insert-grep-regexps args)
  (apply dp-original-insert args))

(dp-message-grep "blehoh%s" "0100")
"blehoh0100"

"blehoh0100"

(dp-insert-grep "a" ?b ?1  "zzzzzzzz")
ab1zzzzzzzznil


ab1zzzzzzzznil

ab1zzzzzzzznil

"bleh-oh0100"

"blah0100"

(apply 'format "%d %s" '(9 aaaa))
"9 aaaa"

(funcall dp-original-message "%s" "boo!")
"boo!"

"boo!"
(dp-message-grep "blehoh%s" "0100")
nil

"blehoh0100"

(message "wah!")



========================
Tuesday June 03 2003
--

(setq pita dp-From:-suffix-alist)
(("To:\\|Cc:" ("xemacs.*" . ".xemacs")) ("To:\\|Cc:" ("freebsd.*" . ".freebsd")) ("To:\\|Cc:" ("mew.*" . ".mew")) ("To:\\|Cc:" ("sawfish.*" . ".sawfish")) ("To:\\|Cc:" ("amazon.com" . ".amazon")) ("To:\\|Cc:" ("buy.com" . ".buy.com")) ("To:\\|Cc:" ("chelmervalve" . ".cvc")) ("To:\\|Cc:" ("uce@ftc.gov" . ".uce")) ("To:\\|Cc:" ("2k3\\|2003" . "chicxulub")))

(defun dp-mew-guess-From-suffix (&optional def-suf)
  (or (car-safe (let ((mew-refile-guess-alist pita))
		  (mew-refile-guess-by-alist)))
      def-suf))

(defun dp-mew-guess-From:-suffix (&optional def-suf)
  (dp-mew-guess-From-suffix def-suf))
dp-mew-guess-From:-suffix

(defun dp-mew-guess-From:-suffix (&optional def-suf)
  (or (car-safe (let* ((mew-refile-guess-alist dp-From:-suffix-alist)
		       (ret (mew-refile-guess-by-alist)))
		  (message "guess from ret>%s<" ret)
		  ret))
      def-suf))


(defcustom dp-From:-suffix-alist
  nil
  "Alist of suffixes to add to the From: address based on other mail headers.
Format is a list of these: 
   '(header-selection-regexp (header-value-regexp . suffix-string)"
  :group 'dp-vars
  :type mew-custom-type-of-guess-alist)

(setq dp-From:-suffix-alist '(("To:\\|Cc:" ("xemacs.*" . ".xemacs")) ("To:\\|Cc:" ("freebsd.*" . ".freebsd")) ("To:\\|Cc:" ("mew.*" . ".mew")) ("To:\\|Cc:" ("sawfish.*" . ".sawfish")) ("To:\\|Cc:" ("amazon.com" . ".amazon")) ("To:\\|Cc:" ("buy.com" . ".buy.com")) ("To:\\|Cc:" ("chelmervalve" . ".cvc")) ("To:\\|Cc:" ("uce@ftc.gov" . ".uce")) ("To:\\|Cc:" ("2k3\\|2003" . "chicxulub"))
("To:\\|Cc:" ("jobs" . ".jobs@crickhollow.org"))
))
(("To:\\|Cc:" ("xemacs.*" . ".xemacs")) ("To:\\|Cc:" ("freebsd.*" . ".freebsd")) ("To:\\|Cc:" ("mew.*" . ".mew")) ("To:\\|Cc:" ("sawfish.*" . ".sawfish")) ("To:\\|Cc:" ("amazon.com" . ".amazon")) ("To:\\|Cc:" ("buy.com" . ".buy.com")) ("To:\\|Cc:" ("chelmervalve" . ".cvc")) ("To:\\|Cc:" ("uce@ftc.gov" . ".uce")) ("To:\\|Cc:" ("2k3\\|2003" . "chicxulub")) ("To:\\|Cc:" ("jobs" . ".jobs@crickhollow.org")))









dp-From:-suffix-alist
(("To:\\|Cc:" ("xemacs.*" . ".xemacs")) ("To:\\|Cc:" ("freebsd.*" . ".freebsd")) ("To:\\|Cc:" ("mew.*" . ".mew")) ("To:\\|Cc:" ("sawfish.*" . ".sawfish")) ("To:\\|Cc:" ("amazon.com" . ".amazon")) ("To:\\|Cc:" ("buy.com" . ".buy.com")) ("To:\\|Cc:" ("chelmervalve" . ".cvc")) ("To:\\|Cc:" ("uce@ftc.gov" . ".uce")) ("To:\\|Cc:" ("2k3\\|2003" . "chicxulub")))




========================
Monday June 30 2003
--
(re-search-forward (concat 
		    "^sub\\S-*:.*\\(" 
		    dp-mail-SPAM-indicator
		    "\\)")
		   (point-max)
		   'no-error)
X-Spam-Flag: YES
X-Spam-Status: Yes, hits=8.0 required=5.0	tests=CLICK_BELOW,HTML_70_80,HTML_MESSAGE,MIME_HTML_ONLY,	      OBFUSCATING_COMMENT,OFFERS_ETC,VIAGRA_ONLINE	version=2.55
X-Spam-Level: ssssssss
X-Spam-Checker-Version: SpamAssassin 2.55 (1.174.2.19-2003-05-19-exp)
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="----------=_3EFFC40C.E30374F6"
Subject: *****SPAM:08.00***** All you can handle!
From: "Cherye Reid" <reidba@lvcm.com>
To: davep.nospam@meduseld.net
Date: Mon, 30 Jun 2003 04:58:13 +0000


========================
Friday July 04 2003
--

(1- 5)
4

(setq a 1 b 2)
2

 slkjd lskjdl :(message " %s" (concat "yo" "pp")):

63694 63710

(defun dp-extract-embedded-lisp (&optional prefix)
  (interactive)
  (unless prefix (setq prefix ":"))
  (let ((go t)
	ch
	ret)
    (while go
      (call-interactively 'id-select-thing)
      ;;(message "r>%s<" (buffer-substring (mark) (point)))
      (if (not (bolp))
	  (progn
	    (setq ch (buffer-substring (1- (point)) (point)))
	    ;;(message "pt: %s, ch>%s<" (point) ch)
	    (when (string= prefix ch)
		(setq go nil)
		(setq ret (dp-region-boundaries-ordered))))
	(setq go nil)))
    ret))
	      
(defun dp-ist ()
  (interactive)
  (call-interactively 'id-select-thing))
	

(progn
  (save-excursion
    (goto-char 63707)
    (setq vvv (dp-extract-embedded-lisp))))
(63694 . 63728)

(63694 . 63728)

(63694 . 63728)

vvv
nil

nil

(defun dp-delimit-embedded-lisp (&optional prefix)
  "Find the limits of the embedded sexp surrounding point."
  (interactive)
  (unless prefix (setq prefix ":"))
  (let* ((go t)
	 (prefix-len (length prefix))
	 (left-limit (- (line-beginning-position) prefix-len))
	ch
	ret)
    (while go
      (call-interactively 'id-select-thing)
      ;;(message "r>%s<" (buffer-substring (mark) (point)))
      (if (> (point) left-limit)
	  (progn
	    (setq ch (buffer-substring (- (point) prefix-len) (point)))
	    ;;(message "pt: %s, ch>%s<" (point) ch)
	    (when (string= prefix ch)
		(setq go nil)
		(setq ret (dp-region-boundaries-ordered))))
	(setq go nil)))
    ret))

(defun dp-find-embedded-lisp (&optional prefix)
  "Search forward for an embedded lisp sexp."
  (interactive)
  (unless prefix (setq prefix ":"))
  (let ((pat (concat prefix "(.*)" prefix)))
    (dmessage "pat>%s<" pat)
    (save-excursion
      (if (re-search-forward pat nil t)
	  (match-beginning 0)
	nil))))

(defun dp-eval-lisp@point (&optional prefix)
  "Eval the embedded lisp sexp surrounding point."
  (interactive)
  (let ((region (dp-delimit-embedded-lisp prefix))
	s)
    (dp-deactivate-mark)
    (if region
	(progn
	  (setq s (buffer-substring (car region) (cdr region)))
	  ;;(message "sv>%s<" (read-from-string s))
	  (eval (car (read-from-string s))))
      (message "Can't find sexp @ point."))))

(defun dpj-chase-link (file-name offset date-string)
  "Follow a link to another record."
  ;;@todo add notes dir to file-name
  (when (dpj-edit-journal-file file-name 'must-exist)
    (goto-char offset)
    (unless (search-forward date-string nil t)
      (goto-char (point-min))
      (unless (search-forward date-string nil t)
	(error "Cannot find ds>%s<" date-string)))
    (beginning-of-line)
    (dpj-move-with-file-wrap 'dpj-goto-topic-forward 0)
    nil))
====================================================================
(defun append-expand-filename (file-string string)
  "Append STRING to FILE-STRING differently depending on whether STRING
is a username (~string), an environment variable ($string),
or a filename (/string).  The resultant string is returned with the
environment variable or username expanded and resolved to indicate
whether it is a file(/result) or a directory (/result/)."
  (let ((file
	 (cond ((string-match "\\([~$]\\)\\([^~$/]*\\)$" file-string)
		(cond ((string= (substring file-string
					   (match-beginning 1)
					   (match-end 1)) "~")
		       (concat (substring file-string 0 (match-end 1))
			       string))
		      (t (substitute-in-file-name
			  (concat (substring file-string 0 (match-end 1))
				  string)))))
	       (t (concat (file-name-directory
			   (substitute-in-file-name file-string)) string))))
	result)

    (cond ((stringp (setq result (and (file-exists-p (expand-file-name file))
				      (read-file-name-internal
				       (condition-case nil
					   (expand-file-name file)
					 (error file))
				       "" nil))))
	   result)
	  (t file))))



(append-expand-filename "~/notes/" "journal-topics")
"/home/davep/notes/journal-topics"

"/home/davep/notes/journal-topics"

"~/journal-topics"



========================================
(defun dpj-chase-link (file-name offset date-string)
  "Follow a link to another note."
  ;;@todo add notes dir to file-name
  (if (not (string= "/" (substring file-name 0 1)))
      (setq file-name
	    (append-expand-filename (concat dp-note-base-dir "/") file-name)))
  (dp-push-go-back)
  (when (dpj-edit-journal-file file-name 'must-exist)
    (goto-char offset)
    (goto-char (dpj-current-timestamp-pos))
    (unless (search-forward date-string nil t)
      (goto-char (point-min))
      (unless (search-forward date-string nil t)
	(error "Cannot find ds>%s<" date-string)))
    (beginning-of-line)
    (dpj-move-with-file-wrap 'dpj-goto-topic-forward 0)))


========================
Sunday July 06 2003
--
(set-face-foreground 'isearch-secondary
		     '(((x default color) . "red3")
		       ((mswindows default color) . "red3"))
		     'global)


========================
Tuesday July 08 2003
--

a0a1a2a3a4a5a6a7a8a9
b0b1b2b3b4b5b6b7b8b9
c0c1c2c3c4c5c6c7c8c9
d0d1d2d3d4d5d6d7d8d9
e0e1e2e3e4e5e6e7e8e9
f0f1f2f3f4f5f6f7f8f9


(apply-on-rectangle 'dp-op-on-rect-line 68584 68637 'dp-rfun)
nil




nil

(defun dp-op-on-rect-line (start end funcp)
  (let* ((pt (point)))
    (funcall funcp (+ pt start) (+ pt end))))
dp-op-on-rect-line



(defun dp-rfun (s e)
  (message "s: %d, e: %d, bss>%s<" s e (buffer-substring s e)))
dp-rfun

dp-rfun


========================
Thursday July 10 2003
--

(defun dp-get-buffer-var (buffer var-sym)
  (save-excursion


(defun efst1 ()
  (interactive)
  (message "a")
  (call-process "rsh" nil nil nil "sybil" "killprog" "proftpd:")
  (insert "x")
  (message "b")
  (call-process "rsh" nil nil nil "sybil" "killprog" "proftpd:")
  (message "c")
  (save-buffer)
  (message "efst1 done"))

(defun efst2 ()
  (interactive)
  (let ((flag t))
    (while flag
      (efst1)
      (setq flag (y-or-n-p "Again")))))

(defun efst3 ()
  (interactive)
  (let ((flag t))
    (while flag
      (efst1)
      (sit-for 5))))

efst2

efst1

efst1

efst1

(efst1)
xnil



========================
Monday July 21 2003
--
(defun telnet-send-input ()
  (interactive)
  (let ((proc (get-buffer-process (current-buffer)))
	p1 p2)
    (if (and telnet-remote-echoes
	     (>= (point) (process-mark proc)))
	(save-excursion
	  (if comint-eol-on-send (end-of-line))
	  (setq p1 (marker-position (process-mark proc))
		p2 (point))))
    (prog1
	(comint-send-input)
      ;; at this point, comint-send-input has moved the process mark, inserted
      ;; a newline, and possibly inserted the (echoed) output.  If the host is
      ;; in remote-echo mode, then delete our local copy of the command, and
      ;; the newline that comint-send-input sent.
      (if (and telnet-remote-echoes p1)
	  (delete-region p1 (1+ p2))))))

========================
Monday July 28 2003
--
grab output from fortune.
split on newlines
indent = ''
while too long
 snip max piece
 add concat indent max piece to fortune-list
 indent = 'some indentation'
if line not ""
 add concat indent line to f-list

loop over prefix and f-list
 if prefix nil
   prefix = "margindentation"
 insert margindentation f-line
 (setq f-list (cdr f-list)
       p-list (cdr p-list))

(defun dp-wrap-line-list (list &optional max indent-in)
  "Wrap a list of lines into a list where each line is < MAX."
  (if (not max)
      (setq max 79))
  (if (not indent-in)
      (setq indent-in "  "))
  (let (olist subs (indent ""))
    (dolist (line list)
      (while (> (length line) max)
	(setq subs (substring line 0 (1- max))
	      line (substring line max))
	(setq olist (cons (concat indent subs) olist)
	      indent indent-in))
      (if (> (length line) 0)
	(setq olist (cons (concat indent line) olist)))
      (setq indent ""))
    (nreverse olist)))


(dp-wrap-line-list '("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
		     "bbbbbbbbbbbbbbb ccccccccccc ddddddddddd"
		     "eeeeeeee fffffffff gg hhhh iiiii jjjj kkkkkkkkkkk")
		   40
		   "...")
(
"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" 
"...aa" 
"bbbbbbbbbbbbbbb ccccccccccc ddddddddddd" 
"eeeeeeee fffffffff gg hhhh iiiii jjjj k" 
"...kkkkkkkkk")


DDDDOOOOOOOOOOOOOOOOOHHHHHHHHHHHHHH!!!!!!!!!!!!!!!!
use filladapt to fill fortune.

(dp-fill-shell-command "fortune -s" 40)

(dp-fill-string fort 90)
"Paradise is exactly like where you are right now ... only much, much better.
                -- Laurie Anderson
"

"Paradise is exactly like where you are right now ... only much, much better.
                -- Laurie Anderson
"

"Paradise is exactly like where
you are right now ... only
much, much better.
                -- Laurie
                   Anderson
"

"Paradise is exactly like where you are right now ... only much,
much better.
                -- Laurie Anderson
"

       / "Paradise is exactly like where you are right now ... only much,
davep (/) much better.
       / 		-- Laurie Anderson
"

"

"\"All my life I wanted to be
someone; I guess I should have
been more specific.\"
		-- Jane Wagner
"


(setq fort (shell-command-to-string "fortune -s"))
"Paradise is exactly like where you are right now ... only much, much
better.
		-- Laurie Anderson
"

"


"You have an unusual magnetic personality.  Don't walk too close to
metal objects which are not fastened down.
"

"\"All my life I wanted to be someone; I guess I should have been more
specific.\"
		-- Jane Wagner
"

"My opinions may have changed, but not the fact that I am right.
"

"What garlic is to salad, insanity is to art.
"

(defvar dp-sig-prefix '("       /"
			"davep (|)"
			"       /")
  "Baroque signature's prefix.")

(defun dp-fill-string (string max)
  "Fill STRING to MAX, splitting at words as needed."
  (let ((default-fill-column max))
    (with-string-as-buffer-contents string
       (fill-region (point-min) (point-max))
       (untabify (point-min) (point-max)))))

(defun dp-fill-lines (lines max)
  "Fill list of lines into list of lines."
  (split-string (dp-fill-string (dp-string-join lines) max) "[\n]"))

(defun dp-fill-shell-command (command max)
  (dp-fill-string (shell-command-to-string command) max))

(defun dp-zip-lists-padded (sig-left sig-right &optional extra-pad wrap-p)
  "Zip left and right sigs together.
Pad lines from SIG-LEFT to all be the same length, 
\(or EXTRA-PAD 8\) greater than the longest line in SIG-LEFT."
  ;; maintain max from sig-left
  (let* (r-line 
	 l-line 
	 o-list
	 l-pad
	 (too-long t)
	 (iters 0)
	 (max-len (length (dp-longest-line-in-list sig-left)))
	 (right-max (- 80 max-len (or extra-pad 8)))
	 (l-fill (make-string (1+ max-len) ? )))
    (if wrap-p
	(setq sig-right 
	      (split-string (dp-fill-string sig-right right-max) "[\n]"))
      (while too-long
	(setq iters (1+ iters))
	(setq sig-right (split-string sig-right "\n"))
	(setq too-long (or (> (length sig-right) 7)
			   (> (length (dp-longest-line-in-list sig-right))
			      right-max)))
	(if too-long
	    (setq sig-right (shell-command-to-string "fortune -s")))))

    (setq sig-left (append sig-left (list (make-string iters ?$))))
    (while (or sig-left sig-right)
      (setq l-line (car sig-left)
	    r-line (car sig-right)
	    sig-left (cdr sig-left)
	    sig-right (cdr sig-right))
      (if (not l-line)
	  (setq l-line l-fill
		l-pad "")
	(setq l-pad (make-string (- (1+ max-len) (length l-line)) ? ))
	)
      (if (not r-line)
	  (setq r-line ""))
      (setq o-list (cons (concat l-line l-pad r-line) o-list)))
    (nreverse o-list)))

???? fill one line at a time
???? don't fill at all if no line is too long.

(defun dp-mk-baroque-fortune-sig ()
  "Make a baroque fortune signature."
  (dp-string-join 
   (dp-zip-lists-padded
    dp-sig-prefix
    (shell-command-to-string "fortune -s"))
   "\n"))


(dp-mk-baroque-fortune-sig)


dp-sig-source
(dp-insert-shell-cmd-sig "fortune" "-s")

(setq dp-sig-source '(insert (dp-mk-baroque-fortune-sig)))
(insert (dp-mk-baroque-fortune-sig))
       /  Every absurdity has a champion who will defend it.
davep (|) 
       /  
$         nil














(dp-fill-lines '("aaa" "bbb") (- 10 (or nil 8)))
("aaa" "bbb" "")









(dp-string-join dp-sig-prefix "\n")



(- 80 12 (or nil 8))
60

========================
Wednesday August 06 2003
--


(defun hif-ifdef-to-endif ()
  "If positioned at #ifX or #else form, skip to corresponding #endif."
;  (message "hif-ifdef-to-endif at %d" (point)) (sit-for 1)
  (hif-find-next-relevant)
  (cond ((hif-looking-at-ifX)
	 (hif-ifdef-to-endif) ; find endif of nested if
	 (hif-ifdef-to-endif)) ; find outer endif or else
	((hif-looking-at-else)
	 (hif-ifdef-to-endif)) ; find endif following else
	((hif-looking-at-endif)
	 'done)
	(t
	 (error "Mismatched #ifdef #endif pair"))))
hif-ifdef-to-endif


(defcustom dp-uline-region-char "_"
  "Character that replaces spaces in dp-uline-region."
  :group 'dp-vars
  :type 'string)

(defun dp-uline-region ()
  (interactive)
  (dp-mark-line-if-no-mark)
  (let* ((reg (dp-region-boundaries-ordered))
	 (start (car reg))
	 (end (cdr reg)))
    (untabify start end)
    (goto-char start)
    (while (< (point) end)
      (when (looking-at " ")
	(delete-char 1)
	(insert dp-uline-region-char))
      (forward-char 1))))

(defun dp-uline-region ()
  "Convert all ws to spaces and replace spaces with `dp-uline-region-char'."
  (interactive)
  (dp-mark-line-if-no-mark)
  (let* ((reg (dp-region-boundaries-ordered))
	 (start (car reg))
	 (end (cdr reg)))
    (untabify start end)
    (goto-char start)
    (while (search-forward " " end t)
      (replace-match dp-uline-region-char nil t))))

		 
_The_Lord_______of______the_Rings 


_The_Lord_of_the_Rings_

_The_Lord_of_the_Rings_

========================
2003-08-11T01:55:50
--
for each element
  if el < delta skip
  collect (el - delta)

(defun dp-shell-adjust-command-positions (delta &optional pos-list)
  (interactive)
  (unless pos-list
    (setq pos-list dp-shell-last-cmds))
  (loop for pos in pos-list
    when (>= pos delta) collect (- pos delta)))
dp-shell-adjust-command-positions

(dp-shell-adjust-command-positions 14 '(1 3 13 14 15 28 114 1014))
(0 1 14 100 1000)

(1 14 100 1000)


(let ((l list)
      (list-off)
      (ret -1))
  (while l
    (setq list-off (car l))		; grab next offset from list
    (if (> list-off target-pos)	; is this item past our cursor?
	(setq l nil)			; yes, end the loop, we fell within
					; the previous item
      (setq l (cdr l)			; nope, trim the list
	    ret (+ 1 ret)))		; bump the index
    ret))


(let ((pos-list '(2 22 222 2222))
      (target-pos 2)
      (ret -1))
  (loop for pos in pos-list
    until (> pos target-pos)
    do (setq ret (1+ ret)))
  ret)
0

-1

4

3

1

2

2

nil

========================
2003-08-12T15:52:14
--
(defun dp-keep-lines-in-region-by-regexp (start end regexp)
  (interactive "r\nsregexp: ")
  (save-match-data
    (goto-char end)
    (setq end (line-end-position))
    (goto-char start)
    (beginning-of-line)
    (while (< (point) end)
      (beginning-of-line)
      (if (re-search-forward regexp (line-end-position) t)
	  (forward-line)
	(dp-kill-entire-line)))))

========================
2003-08-21T01:52:49
--
(insert (dp-mk-baroque-fortune-sig))

(dp-mk-baroque-fortune-sig)
"
       /  WHERE CAN THE MATTER BE
davep (|) 
       /          Oh, dear, where can the matter be
$                 When it's converted to energy?
                  There is a slight loss of parity.
                  Johnny's so long at the fair.
          "

          WHERE CAN THE MATTER BE

	          Oh, dear, where can the matter be
	When it's converted to energy?
	There is a slight loss of parity.
	Johnny's so long at the fair.
davep@baloo:~/work-xfer/exp09

========================
2003-08-23T01:28:01
--

(defun dp-delta-t0 (timestamp &optional now)
  (unless now
    (setq now (current-time)))
  (let* ((then (dp-encode-timestamp timestamp))
	 (diff (time-subtract now then)))
    (message "diff>%s<" (decode-time (time-add '(0 18000) diff)))))

(defun dp-delta-t (timestamp &optional now)
  "Compute and format a delta t from a dp standard timestamp to NOW.
If NOW is nil, then use current-time.
NOW is expected to be in the format returned by `current-time' (q.v.)"
  (interactive "sstart: ")
  (unless now
    (setq now (current-time)))
  (let* ((then (dp-encode-timestamp timestamp))
	 (diff (time-subtract now then))
	 (fdiff (+ (* (car diff) 65536)
		   (nth 1 diff)))
	 (time-str (cond 
		    ((< fdiff 60.0) (format "%1.0f seconds" fdiff))
		    ((< fdiff 3600.0) (format "%3.1f minutes" (/ fdiff 60.0)))
		    ((< fdiff 86400) (format "%3.1f hours" (/ fdiff 3600.0)))
		    (t (format "%7.2f days" (/ fdiff 86400)))))
	 )
    ;;(dmessage "now>%s<, then>%s<, fdiff>%s<" now then fdiff)
    (format "age: %s" time-str)))

(defun dp-encode-timestamp (timestamp)
  "Encode a dp standard timestamp into system format."
  (let* ((ptime (dp-parse-timestamp timestamp)) ;(dow mon day yr time)
	 (time-list (split-string (nth 4 ptime ) ":")) ;(hr min sec)
	 (now (current-time)))
    (encode-time (string-to-int (nth 2 time-list)) ; sec
		 (string-to-int (nth 1 time-list)) ; min
		 (string-to-int (nth 0 time-list)) ; hour
		 (nth 2 ptime)		; day
		 (nth 1 ptime)		; mon
		 (nth 3 ptime)		; year
		 nil)))			; Zone


(float 1)
1.0

(nth 1 '(1 . 4))

1
========================
2003-08-23T21:28:50
--


(dp-delta-t "2003-08-23T21:28:50")
"age: 2.97 hours"

"age:    2.96 hours"

"age: 3 hours"

"age: 3 hours"

"age: 2.6 hours"

"age: 2.5 hours"

"age: 41.7 minutes"

"age: 6.7 hours"

"age: 4.0 minutes"

"age: 4.0 minutes"


"diff>(13 0 0 1 1 1970 4 nil -18000)<"

"diff>(23 1 0 1 1 1970 4 nil -18000)<"

"diff>(18 1 0 1 1 1970 4 nil -18000)<"

"diff>(8 18000 19)<"

"diff>(12 18013 19)<"

========================
2003-08-23T02:04:39
--

========================
2003-08-23T01:59:06
--



(decode-time (time-add '(0 18000) '(0 0)))
(0 0 0 1 1 1970 4 nil -18000)

(0 0 0 1 1 1970 4 nil -18000)

(0 0 19 31 12 1969 3 nil -18000)

"diff>(41 6 19 31 12 1969 3 nil -18000)<"

"diff>(0 165)<"

"diff>(0 18)<"

"diff>(0 15)<"

"diff>(0 9)<"

"diff>(0 1049)<"

========================
2003-08-23T01:45:40
--

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

(def-pkg-dmessage "ld:")
ld:-dmessage

(symbol-function 'ld:-dmessage)
(lambda (fmt &rest args) "dmessage func for ld:." (if ld:-dmessage-on-p (apply (quote message) (concat "ld:: " fmt) args)))

(setq ld:-dmessage-on-p t)

(defmacro ld:-dmessage (m))
ld:-dmessage

ld:-dmessage


(ld:-dmessage "YOPP!")
nil


"ld:: YOPP!"

nil

ld:\ -dmessage


========================
Friday September 05 2003
--
(define-specifier-tag tag &optional predicate)


(specifier-tag-list)
(x tty stream color grayscale mono dp-modeline-spec-tag-remote dp-modeline-spec-tag-local mule-fonts custom default gtk mswindows win display printer)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar dp-modeline-remote-id-extent
        (copy-extent modeline-buffer-id-right-extent)
  "Extent to highlight remote files")

(set-extent-face dp-modeline-remote-id-extent 'dp-remote-buffer-face)

(define-specifier-tag 'dp-modeline-spec-tag-local (lambda (device)
						    (not (dp-remote-file-p))))

(define-specifier-tag 'dp-modeline-spec-tag-remote (lambda (device)
						     (dp-remote-file-p)))

;; ((LOCALE (TAG-SET . INSTANTIATOR) ...) ...)
(setq dp-modeline-id-spec 
      (make-specifier-and-init 
       'generic
       (list
	(list 
	 'global
	 (cons '(dp-modeline-spec-tag-remote) dp-modeline-remote-id-extent)
	 (cons '(dp-modeline-spec-tag-local) modeline-buffer-id-right-extent)
	 ))
       t)
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dp-modeline-remote-id-extent
#<extent [detached) help-echo keymap 0x8d0a9c4 from no buffer>


make-specifier-and-init type spec-list

(specifier-instance dp-modeline-id-spec)
(global (dp-modeline-spec-tag-remote . #<extent [detached) help-echo keymap 0x8f9cac0 from no buffer>) (dp-modeline-spec-tag-local . #<extent [detached) help-echo keymap 0x83ea8e4 from no buffer>))

modeline-buffer-id-right-extent
#<extent [detached) help-echo keymap 0x84538e4 from no buffer>
dp-modeline-remote-id-extent
#<extent [detached) help-echo keymap 0x8d0a9c4 from no buffer>

(valid-specifier-tag-p 'dp-modeline-spec-tag-local)
t
(valid-specifier-tag-p 'x)
t


#<extent [detached) help-echo keymap 0x8d0a9c4 from no buffer>
dp-modeline-spec-tag-remote





(specifier-specs dp-modeline-id-spec 'global)


(specifier-spec-list dp-modeline-id-spec 'global)
((global (nil global (dp-modeline-spec-tag-remote . #<extent [detached) help-echo keymap 0x8f9cac0 from no buffer>) (dp-modeline-spec-tag-local . #<extent [detached) help-echo keymap 0x83ea8e4 from no buffer>))))

(specifier-spec-list sp 'global)
((global ((default x) . "gray80")))

(pprint (setq sp (face-property 'default 'background)))
#<color-specifier global=
((default x)
. "gray80")
fallback=
(((tty)
.
[])
((x)

(specifier-instance dp-modeline-id-spec)
#<extent [detached) help-echo keymap 0x84538e4 from no buffer>

#<extent [detached) help-echo keymap 0x84538e4 from no buffer>



(pprint (specifier-specs sp))
((global
  ((default x)
   . "gray80")))
"((global
  ((default x)
   . \"gray80\")))
"
;; ((LOCALE (TAG-SET . INSTANTIATOR) ...) ...)
;;  '((global ((default x) . "gray80")))

(make-specifier-and-init 
 'generic
 (list
  (list 
   'global
   (cons '(dp-modeline-spec-tag-remote) dp-modeline-remote-id-extent)
   (cons '(dp-modeline-spec-tag-local) modeline-buffer-id-right-extent)))
 t)


(make-specifier-and-init 
 'generic
 (list 
  (list 'global 
	(cons (list 'default 'x)  "gray80")
	(cons (list 'default 'x)  "gray81")))
 t)
#<generic-specifier global=(((default x) . "gray80") ((default x) . "gray81")) 0xafa7>


(device-matches-specifier-tag-set-p 'x '(dp-modeline-spec-tag-local))
(specifier-tag-predicate 'dp-modeline-spec-tag-local)
(lambda (device) (not (dp-remote-file-p)))

(specifier-tag-list)
(x tty stream color grayscale mono dp-modeline-spec-tag-remote dp-modeline-spec-tag-local mule-fonts custom default gtk mswindows win display printer)

(specifier-tag-predicate 'x)
(lambda (device) (eq (quote x) (console-type device)))



========================
Saturday September 13 2003
--
marked --> marked with `*'

if marked or (goto-next-mark succeeds)
while marked
  process
  goto next mark

if marked 
  process
while goto-next-mark
  process


;; we need to look at the current message since the spam 
;; forwarder ends with an `o' command, which moves to the
;; next line


while t
  while marked
    process
  goto next mark
  if no next
    throw

(defun dp-mew-process-marks-fwd (func &rest func-args)
  "Send all marked messages to the authorities."
  (let ((keep-looping t))
    (while keep-looping
      (while (eq (mew-summary-get-mark) ?*)
	(mew-summary-undo-one)
	;;(dmessage "spam @ %s" (point))
	(apply func func-args)

	;; delete when using upchuck.  this is just for testing
	;;(mew-summary-display-review-down)
	)
      (setq keep-looping (mew-summary-display-review-down)))))

(defun dp-mew-fwd-marked-spam (&optional entire-buf-p)
  (interactive "P")
  (if entire-buf-p
      (dp-beginning-of-buffer))
  (dp-mew-process-marks-fwd 'dp-mail-upchuck-spam))
  (dp-mew-process-marks-fwd (lambda ()
			      (dmessage "%s" 
					(buffer-substring (point)
							  (+ 40 (point)))))))


  
	
(line-beginning-position)

 M09/14 westerly@earth|*****SPAM:14.30***** davep.new|* 1.1 -- From: does not +inbox 14211 <20030914052924.956E215EED5@conn.mc.mpls.visi.com> <nil>  

(concat "|" dp-mail-SPAM-indicator)
"|\\*\\*\\*\\*\\*spam\\(:[0-9][0-9]*\\.[0-9][0-9]*\\)?\\*\\*\\*\\*\\* "


========================
Tuesday September 16 2003
--

(define-abbrev local-abbrev-table arg arg 
	    'dp-maybe-add-c++-namespace)

(define-abbrev dp-minibuffer-abbrev-table "cwd" "cwd"
  'dp-rsh-cwd)

(defun dp-rsh-cwd ()
  (interactive)
  ;; counting on buffer order is risky...
  (let ((prev-buf (cadr (buffer-list)))
	cwd)
    (dmessage "dp-rsh-cwd, buf>%s<" (buffer-name prev-buf))
    (save-excursion
      (set-buffer prev-buf)
      (goto-char (point-max))
      ;; davep@sybil:~/work/timings/timer-bug/tstreams
      (re-search-backward "^davep@.*:[~/].*$")
      (setq cwd (match-string 0))
      (dmessage "cwd>%s<" cwd))
    (backward-kill-word)
    (insert "/" cwd "/")
    ))
dp-rsh-cwd


when cwd is expanded in the minibuf, the minibuf is the current buffer.

(buffer-list)

((((((((((((((((((((((((((((3))))))))))))))))))))))))))))
========================
2003-09-16T13:49:58
--

(defmacro dp-if-rsh-cwd (&rest action)
  `(let ((cwd (dp-rsh-cwd)))
     (when cwd
       ,@action)))
dp-if-rsh-cwd

dp-if-rsh-cwd


(dp-if-rsh-cwd (dmessage "YOPP!"))
nil

(macroexpand '(dp-if-rsh-cwd (dmessage "YOPP!") (dmessage "again!")))
(let ((cwd (dp-rsh-cwd))) (when cwd (dmessage "YOPP!") (dmessage "again!")))

(let ((cwd (dp-rsh-cwd))) (when cwd ((dmessage "YOPP!") (dmessage "again!"))))

(let ((cwd (dp-rsh-cwd))) (when cwd (dmessage "YOPP!")))



(macroexpand '`(let ((cwd (dp-rsh-cwd)))
		 (when cwd
		   ,action)) '(dmessage "YOPP!"))
(list (quote let) (quote ((cwd (dp-rsh-cwd)))) (list (quote when) (quote cwd) action))




  

========================
Friday September 19 2003
--
To: <sreekanth@accoladetechnology.com>,
	"David A. Panariti" <davep.jobs@crickhollow.org>

To: <sreekanth@accoladetechnology.com>,
	"David A. Panariti" <davep2.jobs@crickhollow.org>

(rfc822-addresses "<sreekanth@accoladetechnology.com>,
	\"David A. Panariti\" <davep.jobs@crickhollow.org>")
("sreekanth@accoladetechnology.com" "davep.jobs@crickhollow.org")


(defun rfc822-addresses (header-text)
  (if (string-match "\\`[ \t]*\\([^][\000-\037 ()<>@,;:\\\".]+\\)[ \t]*\\'"
                    header-text)
      ;; Make very simple case moderately fast.
      (list (substring header-text (match-beginning 1) (match-end 1)))
    (let ((buf (generate-new-buffer " rfc822")))
      (unwind-protect
	(save-excursion
	  (set-buffer buf)
	  (make-local-variable 'case-fold-search)
	  (setq case-fold-search nil)	;For speed(?)
	  (insert header-text)
	  ;; unfold continuation lines
	  (goto-char (point-min))

	  (while (re-search-forward "\\([^\\]\\(\\\\\\\\\\)*\\)\n[ \t]" nil t)
	    (replace-match "\\1 " t))

	  (goto-char (point-min))
	  (rfc822-nuke-whitespace)
	  (let ((list ())
		tem
		address-start); this is for rfc822-bad-address
	    (while (not (eobp))
	      (setq address-start (point))
	      (setq tem
		    (catch 'address ; this is for rfc822-bad-address
		      (cond ((rfc822-looking-at ?\,)
			     nil)
			    ((looking-at "[][\000-\037@;:\\.>)]")
			     (forward-char)
			     (rfc822-bad-address
			       (format "Strange character \\%c found"
				       (preceding-char))))
			    (t
			     (rfc822-addresses-1 t)))))
	      (cond ((null tem))
		    ((stringp tem)
		     (setq list (cons tem list)))
		    (t
		     (setq list (nconc (nreverse tem) list)))))
	    (nreverse list)))
      (and buf (kill-buffer buf))))))

(rfc822-addresses(mew-header-get-value "To:"))
(rfc822-addresses(mew-header-get-value "[Tt][Oo]:"))


(((((((1)))))))

(((((((2)))))))

/////////////////////////////////////////////
