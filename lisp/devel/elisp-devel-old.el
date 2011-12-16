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
2003-03-04T02:39:08
--
(defun mew-set-environment (&optional no-dir)
  (let (error-message)
    (condition-case nil
	(progn
	  ;; sanity check
	  (cond
	   ((string-match "^\\(18\\|19\\)" emacs-version)
	    (setq error-message "Not support Emacs 18/19 nor Mule 1\n")
	    (error "")))
	  ;; initializing
	  (dmessage "a1")
	  (or no-dir (mew-buffers-init))
	  (dmessage "a2")
	  (or no-dir (mew-temp-dir-init))
	  (dmessage "a3")
	  (mew-mark-init)
	  (dmessage "a4")
	  (mew-config-init)
	  (dmessage "a5")
	  (mew-rotate-log-files mew-smtp-log-file)
	  (dmessage "a6")
	  (mew-rotate-log-files mew-nntp-log-file))
	  (dmessage "a7")
      (error
       (set-buffer (generate-new-buffer mew-buffer-debug))
       (goto-char (point-max))
       (insert "\n\nMew errors:\n\n")
       (and error-message (insert error-message))
       (set-buffer-modified-p nil)
       (setq buffer-read-only t)
       ;; cause an error again
       (error "Mew found some errors above.")))))    


(defun mew-temp-dir-init ()
  "Setting temporary directory for Mew.
mew-temp-file must be local and readable for the user only
for privacy/speed reasons. "
  (setq mew-temp-dir (make-temp-name mew-temp-file-initial))
  (mew-make-directory mew-temp-dir)
  (set-file-modes mew-temp-dir mew-folder-mode)
  (setq mew-temp-file (expand-file-name "mew" mew-temp-dir))
  (add-hook 'kill-emacs-hook 'mew-temp-dir-clean-up))
========================
2003-03-05T14:02:30
--

(defface dp-remote-buffer-face
  '((((class color) (background light)) 
     (:background "thistle3"))) 
  "Face for file being edited via EFS on another host."
  :group 'faces
  :group 'dp-vars)

(setq list-buffers-header-line
      (concat " MR Buffer                     Size  Mode         File\n"
	      " -- ------                     ----  ----         ----\n"))

(defun default-list-buffers-identification (output)
  (save-excursion
    (let ((cur-buf (current-buffer))
	  (file (or (buffer-file-name (current-buffer))
		    (and (boundp 'list-buffers-directory)
			 list-buffers-directory)))
	  (size (buffer-size))
	  (mode mode-name)
	  eob p s col p1 p2)
      (set-buffer output)
      (indent-to 29 1)
      (beginning-of-line)
      (setq p1 (+ 4 (point)))
      (end-of-line)
      (setq eob (point)
	    p2 (point))
      (prin1 size output)
      (if (string-match "[@]" (buffer-name cur-buf))
	  (dp-set-text-color 'buff-menu-mode-remote-file 
			     'dp-remote-buffer-face p1 p2 'detachable))
      (setq p (point))
      ;; right-justify the size
      (move-to-column 29 t)
      (setq col (point))
      (if (> eob col)
	  (goto-char eob))
      (setq s (- 6 (- p col)))
      (dmessage "eob: %s, col: %s, s: %s" eob col s)
      (while (> s 0) ; speed/consing tradeoff...
	(insert ?. )
	(setq s (1- s)))
      (end-of-line)
      (indent-to 27 1)
      (setq p1 (point))
      (insert mode)
      (if (not file)
	  nil
	;; if the mode-name is really long, clip it for the filename
	(if (> 0 (setq s (- 49 (current-column))))
	    (delete-char (max s (- eob (point)))))
	(setq p2 (point))
	(indent-to 50 1)
	(insert file)
	(dp-set-text-color 'buff-menu-mode 'blue p1 p2 'detachable))

      (dp-make-extent (line-beginning-position)
		      (line-end-position)
		      'dp-buff-menu-buffer-name
		      'help-echo 
		      (or file
			  "No file"))

      )))
