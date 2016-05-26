;;;
;;; $Id: dp-errors.el,v 1.13 2004/09/07 01:52:13 davep Exp $
;;;
;;; Error handling stuff
;;;

;; @todo make this `custom'izable
;; In the following, the symbol beginning-of-buffer can be ignored.
;; e.g.: Debugger entered--Lisp error: (beginning-of-buffer[ possible text])
;;
;; e.g.: Debugger entered--Lisp error: (error "Previous command was ...")
;;
;;       Debugger entered--Lisp error: (search-failed "sata")
;; Debugger entered--Lisp error: (error "You've already clocked in!")
;;
;; Debugger entered--Lisp error: (error "History is not being recorded in this context")
;; For:
;; Lisp error: (invalid-operation "Keyboard macro terminated by a command ringing the bell")
;; can use:
;; "^Invalid operation: Keyboard macro terminated by a command ringing the bell$"
;; Useful if you really want to use ^ & $
;; However, "Keyboard macro terminated...bell$" is just fine.
;;Debugger entered--Lisp error: (error "Quit")
;;  signal(error ("Quit"))
;;  cerror("Quit")
;;;;;;;;;;;;;;;;;
;; ??? How to specify the following???
;; Debugger entered--Lisp error: (wrong-type-argument window-live-p #<window 0xf5be74c>)
;;
;; Debugger entered--Lisp error: (error "Don't know where `:minibufferp' is defined")
;; Don't know how to ignore the error string after 'invalid-operation.
;; e.g.: Debugger entered--Lisp error: (invalid-operation "Keyboard ...")
;; ??? Try using 'invalid-operation?  But how to specify the exact error?
;;
;; In the following, the string can be used to ignore this error.

(defconst dp-debug-ignored-errors
  '(beginning-of-line
    beginning-of-buffer
    end-of-line
    end-of-buffer
    end-of-file
    buffer-read-only
    undefined-keystroke-sequence
    file-locked
    search-failed
    folder-empty
    end-of-folder                       ; vm-* error.
    dp-vm-IMAP-data-modification-disabled
    "Keyboard macro terminated by a command ringing the bell$"
    "No cross references in this node"
    "There is no next link"
    "wconfig-rotate-yank-pointer): Window configuration save ring is empty"
    "(wconfig-delete-pop): Window configuration save ring is empty"
    "^Previous command was not a yank$"
    "^Command attempted to use minibuffer while in minibuffer$"
    "^Minibuffer window is not active$"
    "^End of history; no next item$"
    "^Beginning of history; no preceding item$"
    "^History is not being recorded in this context$"
    "^No recursive edit is in progress$"
    "^Changes to be undone are outside visible portion of buffer$"
    "^No undo information in this buffer$"
    "^No further undo information$"
    "^Save not confirmed$"
    "^Recover-file cancelled\\.$"
    "^Attempt to save to a file which you aren't allowed to write$"
    "^File reverted$"
    "^Nothing to revert$"
    "^The mode `.*' does not support Imenu$"
    "^This buffer cannot use `imenu-default-create-index-function'$"
    "^No \\(earlier\\|later\\) matching history item$"
    "^No more grep hits"
    "man .* not found"
    "Listing directory failed"
    "\"No entries containing .*\""
    "No entries containing .*"
    "No such file or directory.*"
    "is a primitive \\(function\\|variable\\)$"
    "no matching lines for re:.*"
    "^kb-warning"
    "^You've already clocked in"
    "^Place cursor inside tag to be searched for"
    ".* does not belong to a gnuserv client$"
    "^set-fill-column requires an explicit argument$"
    "^Don't know where `.*' is defined"
    "Buffer not visiting a file or directory"
    "Mismatched #ifdef #endif pair"
    
    ;;XEmacs
    "^No preceding item in "
    "^No following item in "
    "Unbalanced parentheses"
    "^no selection$"
    "^No selection or cut buffer available$"
    "Selection aborted"
    "^Quit$"                            ; Tossed by Semantic/Senator.
    
    ;; comint
    "^Not at command line$"
    "^Empty input ring$"
    "^No history$"
    "^Not found$";; Too common?
;;    "^Current buffer has no process$"
    
    ;; dabbrev
    "^No dynamic expansion for \".*\" found\\.$"
    "^No further dynamic expansions? for .* found\\.?$"
    "^No dynamic expansion for"
    
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
    "^This is the first Info node you looked at$"    
    ;; imenu
    "^No items suitable for an index found in this buffer\\.$"
    "^The mode \".*\" does not take full advantage of imenu\\.el yet\\.$"
    
    ;; ispell
    "^No word found to check!$"
    
    ;; dictionary
    "^No match for .* with strategy"
    ;; mh-e
    "^Cursor not pointing to message$"
    "^There is no other window$"
    
    ;; man
    "^No manpage [0-9]* found$"

    ;; folding-mode
    "^Outside all folds$"
    
    ;; (X|SG)ML mode
    "No previous element in .* element$"

    ;; etags
    "^No tags table in use!  Use .* to select one\\.$"
    "^There is no default tag$"
    "^No previous tag locations$"
    "^File .* is not a valid tags table$"
    "^No \\(more \\|\\)tags \\(matching\\|containing\\) "
    "^Rerun etags: `.*' not found in "
    "^All files processed\\.$"
    "^No more entries containing "
    "No more tag marks on stack"
    "Buffer has no associated tag tables"
    "The beginning of the \\*xgtags\\* buffer has been reached"
    
    ;; BBDB
    "^no previous record$"
    "^no next record$"
    
    ;; copied from emacs
    "^No possible abbreviation preceding point$"
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
    "^The end of the .* buffer has been reached$"
    "^Marker has no buffer$"
    "^No mark set in this buffer$"
    
    ;; recover-file
    "^Auto-save file .* not current$"
    
    ;; edebug* errors:
    "[^ ]*edebug(error"
    
    ;; shell-resync-dirs will cause this if there are non-existent
    ;; directories on the dirstack.
    "^No such directory: "
    
    ;; cscope errors
    "^There is no unique cscope database directory!$"
    )
  "*My list of ignored signals.  These will not cause an entry into the
debugger if encountered when `debug-on-error' is non-nil.
This list was copped from fdb.el by Anders Lindgren <andersl@csd.uu.se>
And copiously extended by me.
See also `debug-ignored-errors'.")

(setq debug-ignored-errors dp-debug-ignored-errors)
(setq debug-on-error t)

(defun dp-ignore-errors ()
  (interactive)
  (load-file "dp-errors.el"))

;;  <:eval:>
;; :(dp-ignore-errors):   ;; <<< eval with C-a C-c d C-e

;;;
;;;
;;;
(provide 'dp-errors)
