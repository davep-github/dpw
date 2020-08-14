;;; dp-sel2.el -- select an item from a list -- abstracted from
;;; sel-paste.el which was:
;;; Whacked from:
;;; ebuff-menu.el --- electric-buffer-list mode
;;; $Header: /usr/yokel/archive-cvsroot/davep/lisp/dp-sel2.el,v 1.44 2005/06/22 08:20:08 davep Exp $

;; Which was:
;; Copyright (C) 1985, 1986, 1994 Free Software Foundation, Inc.

;; Author: Richard Mlynarik <mly@ai.mit.edu>

;; This file is (not) part of GNU Emacs.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

;; *** Almost everything from that original whacking is gone.

;;; Commentary:


;;; Code:

;;; ??? allow one per buffer, named after buffer.
;;; keep alist mapping sel buffer to target buffer.
;;;   " ///////////////// <:%sdata:> /////////////////"
;;;
;;; begin vars
;;;
(defvar dp-sel2:mode-map nil)

(defconst dp-sel2-arrow-id 'dp-sel2-arrow-id)

;;;
;;; global vals... individual callers (like dp-sel-2paste) can have
;;; their own custom vars or use this.
;;;


(dp-defcustom-local dp-sel2:squish-whitespace-p t
  "*Controls squishing of white space into `dp-sel2:squish-whitespace-string'"
  :group 'dp-vars
  :type 'boolean)

(dp-defcustom-local dp-sel2:use-unicode-p
    (not (not (bound-and-true-p
	       unicode-category-table)))
  "*Hard to believe, but this tells us to use, I believe, Unicode."
  :group 'dp-vars
  :type 'boolean)

;; Using `dp-delete*ALL*extents' hasn't been ported to FSF Emacs yet.
(dp-defcustom-local dp-sel2:delete*ALL*extents-p (dp-xemacs-p)
  "*Can we use `dp-sel2:delete*ALL*extents' yet?"
  :group 'dp-vars
  :type 'boolean)

(dp-defcustom-local dp-sel2:use-squish-whitespace-face-p
    dp-sel2:delete*ALL*extents-p
  "*Controls whether or not we apply the `dp-sel2:squish-whitespace-face' to squished runs of white space."
  :group 'dp-vars
  :type 'boolean)

(dp-defcustom-local dp-sel2:squish-whitespace-string
    (if dp-sel2:use-unicode-p
	(concat
	 (make-string 1 dp-unicode-open-box)
	 (make-string 1 dp-unicode-ellipsis))
      " ")
  "*String into which we squish runs of (WS sans newlines)."
  :group 'dp-vars
  :type 'string)

(dp-defcustom-local dp-sel2:squish-newline-string
    (if dp-sel2:use-unicode-p
	(make-string 1 dp-unicode-newline-glyph)
      " ")
  "*String into which we squish runs of newlines."
  :group 'dp-vars
  :type 'string)

(dp-defcustom-local dp-sel2:item-trunc-len 512
  "*Controls whether and to what len we truncate items in the ssel buffer."
  :group 'dp-vars
  :type 'integer)

;; @todo XXX if we can't make this work, remove `t'
(dp-defcustom-local dp-sel2:use-truncation-face-p (or t (dp-xemacs-p))
  "*Controls whether or not we apply `dp-sel2:truncation-face'."
  :group 'dp-vars
  :type 'boolean)

(dp-defcustom-local dp-sel2:truncation-string
    (if dp-sel2:use-unicode-p
	(make-string 1 dp-unicode-ellipsis)
      "<<truncated>>")		 ; @todo XXX fix if XEmacs has Unicode
  "*String which indicates a line has been truncated."
  :group 'dp-vars
  :type 'string)

;;;

(defface dp-sel2:squish-whitespace-face
  '((((class color) (background light))
     (:background "paleturquoise")))
  "Face (background) for squished runs of tabs and spaces."
  :group 'faces
  :group 'dp-faces)

(defface dp-sel2:squish-newline-face
  '((((class color) (background light))
     (:background "lightblue3")))
  "Face (background) for squished runs of newlines."
  :group 'faces
  :group 'dp-faces)

(defface dp-sel2:truncation-face
  '((((class color) (background light))
     (:background "lightblue3")))
  "Face (background) for truncation indicator face."
  :group 'faces
  :group 'dp-faces)

(defface dp-sel2:viewer-bg-face
  '((((class color) (background light))
     (:background "aliceblue")))
  "Face (background) for item being viewed."
  :group 'faces
  :group 'dp-faces)

(defvar dp-sel2:mode-hook nil
  "Hooks to call just before dp-sel2:mode finishes.")

(dp-deflocal-permanent dp-sel2:post-mode-hook nil
  "Hook to call after sel-mode is set up.
This is unique per caller so different users can have different
functions called, e.g. to set up usage-specific key bindings.")

(dp-deflocal-permanent dp-sel2:buffer nil
  "Buffer in which selection is taking place.")

(dp-deflocal-permanent dp-sel2:window-height 10
  "Max created height of selection window.")

;;
;; turn off by default, since with it off we can insert at point
;; simply by not moving point.  But if it is on, then it is impossible
;; to insert elsewhere if the user changes their mind.
;; A slight problem is that the highlighting of point in the dest buffer
;;  is not updated when point moves.
;; Could check on every keystroke or in post-command-hook for moved point,
;; but only if this mode is active? Hook in at start of mode, remove @ end?
;; The hooking mentioned above will need to wrap that in the safest
;; `condition-case' like thing.  unwind-protect?
;;
(dp-defcustom-local dp-sel2:goto-target-original-point nil
  "*Controls whether or not we go to where ever point was in the
original buffer when exiting dp-sel2:mode."
  :group 'dp-vars
  :type 'boolean)

;;;
;;; line number input variables
;;;
(dp-deflocal-permanent dp-sel2:buf-prefix ""
  "Prefix used to generate selection buffer name.
This is provided by the caller.  We retain a copy in order to be able
to regenerate the buffer name, e.g. for refreshing the buffer.")

(dp-deflocal-permanent dp-sel2:index nil
  "A list containing numeric digits that specify the desired
item index.  The list is reversed so that chars can be removed
easily when \\[dp-sel2:backspace] is pressed.")

(dp-deflocal-permanent dp-sel2:preserve-index nil
  "When t, tells us that dp-sel2:index is being used, i.e. that
numeric input is under weigh.")

(dp-deflocal-permanent dp-sel2:items-offset-list nil
  "Offsets into the buffer corresponding to the start of each item.")

(dp-deflocal-permanent dp-sel2:items-num-offsets 0
  "The number of offsets (and items) in the selection list.")

;;;
;;; callbacks
;;; each one gets the current item: a cons (index . item)
;;;
(dp-deflocal-permanent dp-sel2:sel-func nil
  "Function to call when an item is selected.")

(dp-deflocal-permanent dp-sel2:cancel-func nil
  "Function to call when selection is cancelled.")

(dp-deflocal-permanent dp-sel2:insertor nil
  "Function used to insert and format items in selection buffer.")
(dp-deflocal-permanent dp-sel2:insertor-args nil
  "Args passed to `dp-sel2:insertor'.")

;;;
;;; Target buffer information.
;;; The target buffer is the buffer that was current when the
;;; selection process began.
;;;
(dp-deflocal-permanent dp-sel2:target-marker 'no-marker
  "Marker holding location in what was the current buffer when the selection
process began.")

(dp-deflocal-permanent dp-sel2:target-buffer-name 'no-name
  "The name of the target buffer.")

(dp-deflocal-permanent dp-sel2:item-list-generator nil
  "Function to generate the list of items from which the selection will be made.")
(dp-deflocal-permanent dp-sel2:item-list '()
  "Current list of items from which the selection will be made.")

;; only compress >1 space, >0 other white chars
(defvar dp-sel2:squish-whitespace-regexp "[ \t]\\{2,\\}"
  "Regexp to identify squishable runs of whitespace.")
(defvar dp-sel2:squish-newline-regexp "[\n]+"
  "Regexp to identify squishable runs of whitespace.")

(dp-deflocal-permanent dp-sel2:window-config nil
  "Window config when mode entered.")

(dp-deflocal-permanent dp-sel2:initial-sel2-window-config nil
  "Window config after sel2 mode initialization is completed.")

(dp-deflocal-permanent dp-sel2:sel-buf-name nil
  "Selection buffer name.")

(dp-deflocal dp-sel2:rotate-only-p nil
  "If t, only rotate the kill ring so the current item will be pasted next.
If 'no-exit-p, then rotate the ring and refresh the buffer and don't exit.")

;;;
;;; end vars
;;;

;;;
;;; begin code
;;;

(defun dp-sel2:mk-buf-name (prefix &optional buf-name)
  (format "%s for: %s" prefix (or buf-name (buffer-name))))

(defun dp-sel2:window (&optional buffer)
  (dp-get-buffer-window dp-sel2:buffer))

(defun dp-sel2:target-buffer ()
  (if (and dp-sel2:target-marker
	   (not (eq dp-sel2:target-marker 'no-marker)))
      (marker-buffer dp-sel2:target-marker)))

(defun dp-sel2:target-position ()
  (if (and dp-sel2:target-marker
	   (not (eq dp-sel2:target-marker 'no-marker)))
      (marker-position dp-sel2:target-marker)))

(defun dp-sel2:adjust-window-size (num-items)
  ;; set window's initial size
  (let ((desired-height (min dp-sel2:window-height
					;(/ (window-displayed-height) 2)
			     (+ num-items 2)))
	;; ?? window-height seems incorrect at this point if there
	;;    already was a second window.
	;; ? or is it that window-displayed-height isn't updated yet.
	(lines-used-by-decorations (- (window-height)
				      (window-displayed-height))))
    ;;    (dmessage "wdh: %d, wh: %d, dh: %d, lbd: %d"
    ;;	      (window-displayed-height)
    ;;	      (window-height) desired-height lines-used-by-decorations)
    (enlarge-window (+ (- desired-height
			  (window-height)
			  )
		       ;;lines-used-by-decorations
		       1)) ;; compensate for bad height estimates
    ;; "it needs this to make it go"
    )
  )

(defun dp-sel2:refresh ()
  (interactive)
  (setq dp-sel2:item-list (funcall dp-sel2:item-list-generator))
  (let ((buf (dp-sel2:items dp-sel2:sel-buf-name dp-sel2:insertor
			    dp-sel2:insertor-args
			    dp-sel2:item-list)))
    (dp-sel2:adjust-window-size (length dp-sel2:item-list))
    buf))

;;
;; DP-SEL2
;;
(defun dp-sel2 (buf-prefix item-list-generator
			   &optional sel-func cancel-func post-mode-hook
			   insertor insertor-args)
  "Pops up a buffer containing a list of items from which the user may choose.
This allows a visual selection of the item of interest.
BUF-PREFIX is concatenated with the name of the original buffer (the
target buffer) to yield the name of the temporary selection buffer.
ITEM-LIST-GENERATOR is a function that is called to generate the list
of items to be selected from.  If an item is itself a list, then the
car of the item is displayed in the selection buffer; otherwise the
item is displayed.
SEL-FUNC, if non-nil, is called when an item is selected.
CANCEL-FUNC, if non-nil, is called when the mode is cancelled.
POST-MODE-HOOK, if non-nil, is called after dp-sel2 has made the selection
buffer the current buffer and put it into dp-sel2:mode.  This can be used to
allow calling functions to set up extra key-bindings.
INSERTOR is called to insert and format each item.  It is passed the
item to insert (at point) and INSERTOR-ARGS.
INSERTOR-ARGS is a list of args to pass to INSERTOR.
If INSERTOR is nil, then it defaults to: `dp-sel2:insert-line' with
args dp-sel2:squish-whitespace-p, dp-sel2:use-squish-whitespace-face-p and
dp-sel2:item-trunc-len.

RETURNS a cons cell (0_based_index . item) corresponding to the
selected item or nil if no selection was made.  It may be useful to
have each item be a list, with extra information contained in the cdr.
This information may then be used when the callback routine handles an item.

One may move around in the list to examine and select an item.  The
keymap of the target buffer is used as the basis for the keymap in the
selection buffer, with the exception of number keys, motion keys, and
selection and cancellation keys.

Calls value of `dp-sel2:mode-hook' on entry if non-nil.

dp-sel2 uses these bindings:
\\{dp-sel2:mode-map}"
  (interactive)

  (if (eq major-mode 'dp-sel2:mode)
      (error "Cannot use dp-sel2 in a dp-sel2:mode buffer"))
  (let ((pop-up-windows t)
	special-display-buffer-names
	special-display-regexps
	same-window-buffer-names
	same-window-regexps
	(t-name (buffer-name))
	(marker (point-marker))
	(t-buf (current-buffer))
	(window-config (current-window-configuration))
	(item-list (funcall item-list-generator))
	(buf-name (dp-sel2:mk-buf-name buf-prefix)))
    ;;    (push-window-configuration)

    (unless insertor
      (setq insertor 'dp-sel2:insert-line
	    insertor-args (list dp-sel2:squish-whitespace-p
				dp-sel2:use-squish-whitespace-face-p
				dp-sel2:item-trunc-len)))
    (when (> (window-height) (* 2 dp-sel2:window-height))
      (split-window-vertically))

    (switch-to-buffer-other-window
     (dp-sel2:items buf-name insertor insertor-args item-list))
;;;    (dp-toggle-read-only 0 nil)		; in case this is a re-entry

;;;    (goto-char (point-min))
;;;    (dp-erase-buffer)

    (dp-sel2:adjust-window-size (length item-list))

    ;;
    ;; Save parameters in buffer local variables.
    ;; some are saved for when we'll add the ability to refresh
    ;;  the selection buffer.
    ;;
    ;;!<@todo MAKE THIS AN EFFIN' struct!!!!!!
    (setq dp-sel2:sel-func sel-func
	  dp-sel2:cancel-func cancel-func
	  dp-sel2:item-list-generator item-list-generator
	  dp-sel2:target-marker marker
	  dp-sel2:post-mode-hook post-mode-hook
	  dp-sel2:buffer (current-buffer)
	  dp-sel2:window-config window-config
	  dp-sel2:insertor insertor
	  dp-sel2:insertor-args insertor-args
	  dp-sel2:sel-buf-name buf-name
	  dp-sel2:item-list item-list
	  dp-sel2:target-buffer-name t-name)
    (dp-sel2:mode)
    (message "%d items. Press 'h' for help." (length item-list))
    (when post-mode-hook
      (funcall post-mode-hook))
    (setq dp-sel2:initial-sel2-window-config (current-window-configuration)))
  (setq this-command 'yank))

;; ??? consider recursive edit for this ???
;; have to be good reasons.

(put 'dp-sel2:mode 'mode-class 'special)

(defun* dp-sel2:reset-to-orig-buffer (sel-func item
					  &key no-exit-p kill-current-buffer-p)
  "Propogate variables from listing buffer to current invokation buffer."
  (interactive)
  (let ((doomed (current-buffer))
	(t-rotate-only-p dp-sel2:rotate-only-p)
	(t-name dp-sel2:target-buffer-name)
	(t-buf (marker-buffer dp-sel2:target-marker))
	(t-pos (marker-position dp-sel2:target-marker))
	(t-go dp-sel2:goto-target-original-point)
	(t-mode-name mode-name)
	(window-config dp-sel2:window-config)
	(region (dp-maybe-get-region))
	t-new-pos
	(t-item (or item (dp-sel2:current-item))))
    (setq dp-sel2:target-marker nil)

    (when kill-current-buffer-p
      (kill-buffer doomed))

    ;;
    ;; switch-to-buffer sometimes hoses point.  It can be recreated by
    ;; splitting the window, and using dp-sel2.  Once dp-sel2 is used in a
    ;; non-split situation it gets better.  This should help in any case.
    (with-current-buffer t-buf
      (setq t-new-pos (point)))

    (if (buffer-live-p t-buf)
	(progn
	  (switch-to-buffer t-buf)

	  ;; try to restore everything as it was.

	  ;; save the current cursor position in the target buffer.
	  ;; it may have moved since target-marker was set.
	  ;;(setq t-new-pos (point))

	  (unless no-exit-p
	    (set-window-configuration window-config))

	  ;;
	  ;; `current-window-configuration' does NOT save point in the
	  ;; current buffer, so we need to explicitly go back to where we
	  ;; started.
	  (when t-go
	    (goto-char t-pos))
	  ;; This used to be, and needs to be again, in the command loop.
	  ;; To make this more correcter -- if we don't add it back into
	  ;; the command loop, we needs must handle errors.
	  ;; Hack around this for now.
	  ;; (dp-unhighlight-point :pos this-is-where :id-prop dp-sel2-arrow-id)
	  (dp-unextent-region dp-sel2-arrow-id
			      (line-beginning-position)
			      (line-end-position))
	  (if sel-func
	      (funcall sel-func region t-item t-rotate-only-p)))

      (message (format "%s: target buffer `%s' is gone." t-mode-name t-name))
      (ding))))

(defun dp-sel2:one-line-of-help ()
  (interactive)
  (message "Digit keys: Move to item. i,^M,spc: insert and exit; c: copy; g: refresh, q: quit; v: view item; r: rotate current to top."))

(defun dp-sel2:mode ()
  "Major mode for selecting which item to select.
Each possible item is listed.
Letters do not insert themselves; instead, they are commands.
\\<dp-sel2:mode-map>
\\[keyboard-quit] or \\[dp-sel2:quit] -- exit buffer menu, returning to previous window and buffer configuration.
If the very first character typed is a space, it also has this effect.
\\[dp-sel2:select] -- select item of line point is on.

\\{dp-sel2:mode-map}

Entry to this mode via command dp-sel2:list calls the value of
`dp-sel2:mode-hook' if it is non-nil."
  (kill-all-local-variables)
  (use-local-map dp-sel2:mode-map)
  (setq mode-name "dp-sel2")
  (setq mode-line-buffer-identification mode-name)
  (setq truncate-lines t)
  (dp-toggle-read-only 1 nil)
  (setq major-mode 'dp-sel2:mode)
  (goto-char (point-min))
  (if (search-forward "\n." nil t) (forward-char -1))
  (run-hooks 'dp-sel2:mode-hook))

(setq dp-sel2:mode-map nil)
(if nil					;dp-sel2:mode-map
    nil
  (let ((map (make-keymap)))
    (define-key map [(control ?c) (control ?c)] 'dp-sel2:quit)
    (define-key map [(control ?g)] 'dp-sel2:quit)
    (define-key map [(control ?\])] 'dp-sel2:quit)
    (define-key map [?q] 'dp-sel2:quit)
    ;; ??? C-- is a prefix key(define-key map  [?\C--] 'dp-sel2:quit)
    (define-key map [(meta ?-)] 'dp-sel2:quit)

    (define-key map [?\ ] 'dp-sel2:select)
    (define-key map [?i] 'dp-sel2:select)
    (define-key map [insert] 'dp-sel2:select)
    (define-key map [(control ?m)] 'dp-sel2:select)
    (define-key map [return] 'dp-sel2:select)
    (define-key map [kp-add] 'dp-sel2:select)
    (define-key map [?Y] 'dp-sel2:select)
    (define-key map [?y] 'dp-sel2:select)
    (define-key map [?g] 'dp-sel2:refresh)
    (define-key map [?f] (kb-lambda (set-window-configuration
				     dp-sel2:initial-sel2-window-config)))
    (if (dp-xemacs-p)
	(define-key map [button2] 'dp-sel2:mouse-select)
      (define-key map [mouse-2] 'dp-sel2:mouse-select))
    (define-key map [(meta insert)] 'dp-sel2:select)

    (let ((i ?0))
      (while (<= i ?9)
	(define-key map (char-to-string i) 'dp-sel2:digit-argument)
	(setq i (1+ i))))
    (define-key map [(control ?p)] 'dp-up-with-wrap)
    (define-key map [(control ?n)] 'dp-down-with-wrap)
    (define-key map [?p] 'dp-up-with-wrap)
    (define-key map [?n] 'dp-down-with-wrap)
    (define-key map [up] 'dp-up-with-wrap)
    (define-key map [down] 'dp-down-with-wrap)
    (define-key map [(control ?v)] 'scroll-up)
    (define-key map [(meta ?v)] 'scroll-down)
    (define-key map [?>] 'scroll-right)
    (define-key map [?.] 'scroll-right)
    (define-key map [?<] 'scroll-left)
    (define-key map [?,] 'scroll-left)
    (define-key map [(control ??)] 'dp-sel2:backspace)
    (define-key map [(backspace)] 'dp-sel2:backspace)
    (define-key map [?h] 'dp-sel2:one-line-of-help)
    (define-key map [?H] 'describe-mode)
    (setq dp-sel2:mode-map map)))

(defun dp-sel2:current-item ()
  "Return cons of current item's index and value."
  (let* ((ret-index (dp-sel2:off-to-index))
	 (ret-val (nth ret-index dp-sel2:item-list)))
    ;;(dmessage "ret-index: %d" ret-index)
    (cons ret-index ret-val)))

(defun dp-sel2:done (sel-func item &optional no-exit-p)
  "Leave select item mode after calling SEL-FUNC."
  (interactive)
  ;; save the values we need since they will vanish with the buffer
  (dp-sel2:reset-to-orig-buffer sel-func item
				:no-exit-p no-exit-p
				:kill-current-buffer-p t))

(defun dp-sel2:select (&optional current-item)
  "Select the current item.
Calls selection callback, if non-nil, then exits mode."
  (interactive)
  (dp-sel2:done dp-sel2:sel-func (or current-item
				     (dp-sel2:current-item)))
  (setq this-command 'yank))

(defun dp-sel2:cancel ()
  "Cancel the current item.
Calls cancel callback, if non-nil, then exits mode."
  (interactive)
  (dp-sel2:done dp-sel2:cancel-func nil))

(defun dp-sel2:exit-mode ()
  (interactive)
  (dp-sel2:done nil nil))

(defun dp-sel2:mouse-select (event)
  (interactive "e")
  (mouse-set-point event)
;;;  (select-window (posn-window (event-end event)))
;;;  (set-buffer (window-buffer (selected-window)))
;;;  (goto-char (posn-point (event-end event)))
  (dp-sel2:done dp-sel2:sel-func 'AM-I-OK?))

(defun dp-sel2:quit ()
  "Leave select item mode, restoring previous window configuration.
Does not insert any text."
  (interactive)
  (dp-sel2:cancel))

;;
;; @todo make squish faces args
(defun dp-sel2:insert-line (item &optional squish-p use-squish-face-p
				 trunc-len)
  "Insert and format the ITEM into the listing buffer."
  ;; remove all extents from the items for display since things like a
  ;; read-only extent can hose things.  NB: this means that regions
  ;; selected and inserted from the sel-buf will not have the original
  ;; text's properties.  Using view-item will allow text props to be
  ;; retained.  Also, squished runs will not have the original text
  ;; saved so that qill require getting the text from the view item.
  (when (bound-and-true-p dp-sel2:delete*ALL*extents-p)
    (dp-delete*ALL*extents nil nil item))
  (let ((start (point))
	(truncate-p (and trunc-len
			 (> (length item) trunc-len)))
	(use-squish-face-p (cond
			    ((not use-squish-face-p))
			    ((eq use-squish-face-p t)
			     dp-sel2:use-squish-whitespace-face-p)
			    (t use-squish-face-p))))
    (when truncate-p
      (setq item (truncate-string-to-width
		  item trunc-len nil nil
		  dp-sel2:truncation-string)))
    (insert item)
    (when (and truncate-p
	       use-squish-face-p
	       dp-sel2:use-truncation-face-p)
      (dp-make-extent start trunc-len
		      'dp-sel2
		      'face 'dp-sel2:truncation-face))
    (goto-char start)
    ;; squish the item for display by squeezing all runs of WS to a
    ;; single space (if requested)
    (when squish-p
      (while (dp-re-search-forward dp-sel2:squish-whitespace-regexp nil t)
	(if use-squish-face-p
	    (dp-make-extent (match-beginning 0) (match-end 0)
			    'dp-sel2
			    'face 'dp-sel2:squish-whitespace-face))
	(replace-match dp-sel2:squish-whitespace-string nil nil))
      (goto-char start)
      (while (dp-re-search-forward dp-sel2:squish-newline-regexp nil t)
	(if use-squish-face-p
	    (dp-make-extent (match-beginning 0) (match-end 0)
			    'dp-sel2
			    'face 'dp-sel2:squish-newline-face))
	(replace-match dp-sel2:squish-newline-string nil nil))
      ))
  (goto-char (point-max)))

(defun dp-sel2:items (buf-name insertor insertor-args item-list)
  "List all of the items in the item-list in buffer named buf-name.
BUF-NAME is the name of the temporary buffer.
SQUISH is a flag telling the system to compress runs of whitespace into
a single copy of dp-sel2:squish-whitespace-string.
ITEM-LIST is the list of items to be selected from.  If the item is a list,
then the car of the list is displayed in the selection buffer, otherwise
the item is displayed."

  ;; (message (format "buf-name>%s<, items>%s<" buf-name item-list))
  (save-excursion
    (let (el l
	     (sel-buf (get-buffer-create buf-name)))
      (set-buffer sel-buf)

      (setq dp-sel2:items-offset-list nil
	    dp-sel2:items-num-offsets 0)

      ;; I just spent hours chasing down a read-only character in a pastie buffer.  The dumbass (from what I can see) read-only changes didn't help.
      ;; The inhibit-read-only allows us to delete chars/overlays/etc/ that
      ;; have a read-only type property.
      (let ((inhibit-read-only t))
	(dp-erase-buffer))

      ;; Make us read/write.  We may be reusing a pastie buffer that is read
      ;; only or has something in it with a read only property.  We could
      ;; live in the (let ((inhibit-read-only t))...) but individual RO... RW
      ;; calls seem more obvious.
      (dp-toggle-read-only -1 nil)

      (goto-char (point-min))
      ;;
      ;; Stuff all list items into the list buffer.
      ;; prepend each item with an item index number.
      ;; make a list of corresponding buffer positions at which the
      ;; items were inserted into the buffer so we can map a buffer
      ;; position to an item.
      ;;
      (setq l item-list)
      (while l
	(setq el (car l)
	      l  (cdr l))
	(if (listp el)
	    (setq el (car el)))
	(setq dp-sel2:items-offset-list
	      (cons (point) dp-sel2:items-offset-list))
	(insert (format "%3d%s" dp-sel2:items-num-offsets "|"))
	(apply insertor el insertor-args)
	(insert "\n")
	(setq dp-sel2:items-num-offsets
	      (+ 1 dp-sel2:items-num-offsets))
	)
      ;; nuke trailing '\n' added in dp-sel2:insert-line
      (setq dp-sel2:items-offset-list
	    (nreverse dp-sel2:items-offset-list))
      (when (> (1- (point-max )) 0)
	(delete-region (- (point-max) 1) (point-max)))
      (dp-toggle-read-only t nil)
      sel-buf)))

(defun dp-sel2:off-to-index (&optional off)
  "Convert offset in buffer to index used to select
the desired item."
  (unless off
    (setq off (point)))
  (let ((l dp-sel2:items-offset-list)
	(cur-off)
	(ret -1))
    (while l
      (setq cur-off (car l))	   ; grab next offset from list
      (if (> cur-off off)	   ; is this item past our cursor?
	  (setq l nil)		   ; yes, end the loop, we fell within
					; the previous item
	(setq l (cdr l))		; nope, trim the list
	(setq ret (+ 1 ret))))		; bump the index
    ret))

(defun dp-sel2:move-line (by)
  "Go to another item in buffer.  Wrap @ either end.
BY gives number of items to move."
  (interactive)
  (let ((col (current-column))
	(i (dp-sel2:off-to-index (point))))
    (setq i (+ by i))
    (if (>= i dp-sel2:items-num-offsets)
	(setq i (mod i dp-sel2:items-num-offsets)))
    (if (< i 0)
	(setq i (- dp-sel2:items-num-offsets 1))) ; fix for wraps > 1
    (goto-char (nth i dp-sel2:items-offset-list))
    (move-to-column col)))

(defun dp-sel2:index-as-int ()
  "Convert a list of reversed digits into an integer.
There's got to be a better way. I wrote this when I was a 1st^H^H^H 0th level
Elispomancer.
@todo XXX Use concat to add chars to the index, and substring to remove them."
  ;; There is.
  (1+ (string-to-int (apply 'string (reverse dp-sel2:index)))))
;;leveled up!;   (let ((i 0)
;;leveled up!;(l (reverse dp-sel2:index)))
;;leveled up!;     (while l
;;leveled up!;       (setq i (+
;;leveled up!;       (* i 10)
;;leveled up!;       (- (car l) ?0)))
;;leveled up!;       (setq l (cdr l)))
;;leveled up!;     i))

(defun dp-sel2:goto-index ()
  "Goto the index gathered in dp-sel2:index.
Return t if index was out of range, else nil."
  (let ((i (dp-sel2:index-as-int)))
    (if (< i dp-sel2:items-num-offsets)
	(progn
	  (goto-char (point-min))
;;;	  (message "goto %d" i)
	  (dp-sel2:move-line (1- i))
	  nil)
      t)))

(defun dp-sel2:digit-argument ()
  "Accumulate an index in dp-sel2:index and move to
item currently selected.
E.g. typing `1' `2' will send us to item 1 and then to
item 12."
  (interactive)
  (setq dp-sel2:preserve-index t)
  ;; (message "dp-sel2:index: %S" dp-sel2:index)
  ;; (message "(dp-last-command-char): %S" (dp-last-command-char))
;;;  (message "0c2:%S" last-input-char) <<<< XEmacs only.
  ;; (message "(this-command-keys): %s" (this-command-keys))
  (setq dp-sel2:index (cons (dp-last-command-char) dp-sel2:index))

  ;;  (message "1i: %S" dp-sel2:index)
  ;; the call will fail if the new index is too big.  If so, we remove the
  ;; offending digit from the list.
  (if (dp-sel2:goto-index)
      (setq dp-sel2:index (cdr dp-sel2:index))))

(defun dp-sel2:backspace ()
  "Remove the most recently entered digit from dp-sel2:index,
and move to the resulting item.  An empty list gets us to
item 0."
  (interactive)
;;;  (message "in bs, i: %S, pi: %S" dp-sel2:index
;;;	   dp-sel2:preserve-index)
  (if dp-sel2:index
      (progn
;;;	(message "t, i: %S" dp-sel2:index)
	(setq dp-sel2:index (cdr dp-sel2:index))
	(dp-sel2:goto-index)
	(if dp-sel2:index
	    (progn
;;;	      (message "t2, i: %S" dp-sel2:index)
	      (setq dp-sel2:preserve-index t))))
    (backward-char)))

;;;
;;; Some things that use dp-sel2
;;;

(defcustom dp-sel2-paste:window-height 17
  "Make the section window no taller than this.
We try to shrink-wrap the window, but if it is too big then we use
this as an upper size limit.
However, if the main window is very short (i.e. less than 2x this value,
then make the height 1/2 of the current frame height."
  :group 'dp-vars
  :type 'integer)


(defun dp-sel2:list-pastes ()
  "Create a list of all the paste buffers in the kill-ring.
Start at the current yank position and go until we get back to where
we started.  The strings are in the same order that a series of
`yank-pop's would produce."
  ;; start with kill-ring-yank-pointer and wrap at end of list to
  ;; kill-ring and stop when we get back to kill-ring-yank-pointer
  (let (ret-list
	(el (car kill-ring-yank-pointer))
	(l (cdr kill-ring-yank-pointer)))
    (while el
      ;; build the list reversed
      (setq ret-list (cons el ret-list))
      (if (not l)			;wrap at end to beginning
	  (setq l kill-ring))
      (if (eq l kill-ring-yank-pointer)
	  (setq el nil)
	(setq el (substring-no-properties (car l)))
	(setq l (cdr l))))
    ;; reverse list for return
    (nreverse ret-list)))

(defun dp-sel2-paste:get-item-text (&optional item)
  (dp-get--as-string--region-or...
   :bounder nil
   :default (cdr (or item (dp-sel2:current-item)))))

;; called w/sel-buf active
(defun dp-sel2-paste:copy-no-exit (&optional add-to-kill-ring item)
  "Insert current item but do not exit sel-mode."
  (interactive)
  (let ((text (dp-sel2-paste:get-item-text item)))
    (setq dp-sel2:target-marker
	  (dp-sel2:with-target-buffer
	      (insert text)
	      (dp-rehighlight-point :id-prop dp-sel2-arrow-id)
	    (point-marker)))
    (if add-to-kill-ring
	(kill-new text))))

(defun dp-sel2-paste:undo-target-buffer ()
  (interactive)
  (dp-sel2:with-target-buffer
      (undo)))

(defun dp-sel2-paste:view-item ()
  "View the entire current item in a buffer of its own."
  (interactive)
  (let* ((t-item (dp-sel2:current-item))
	 (t-item-val (cdr t-item))
	 (text (if (atom t-item-val) t-item-val (car t-item-val)))
	 (view-buf (get-buffer-create
		    (generate-new-buffer-name "*sel-item-view*")))
	 (key-map (make-keymap))
	 (target-marker dp-sel2:target-marker)
	 (item-list dp-sel2:item-list)
	 (items-offset-list dp-sel2:items-offset-list)
	 (copyor `(lambda ()
		    (interactive)
		    (dp-sel2-paste:copy-no-exit nil
						(quote ,t-item))))
	 (selector `(lambda ()
		      (interactive)
		      (kill-this-buffer)
		      (dp-sel2:select (quote ,t-item)))))
    (define-key key-map [?c] copyor)
    (define-key key-map [?C] copyor)
    (define-key key-map [?k] copyor)
    (define-key key-map [?K] copyor)
    (define-key key-map [?\ ] selector)
    (define-key key-map [?i] selector)
    (define-key key-map [insert] selector)
    (define-key key-map [(control ?m)] selector)
    (define-key key-map [return] selector)
    (define-key key-map [kp-add] selector)
    (define-key key-map [?Y] selector)
    (define-key key-map [?y] selector)
    (define-key key-map [?g] 'dp-sel2:refresh)
    ;; put buffer local in scope for called functions
    (with-current-buffer view-buf
      (setq dp-sel2:target-marker target-marker))
    (let ((window-config (current-window-configuration)))
      (dp-simple-viewer view-buf
			;; fill func
			(function
			 (lambda ()
			   (insert text)))
			;; additional ('add) quit-keys
			'(add [?v] [?V])
			;; q-key-command
			(kb-lambda ()
			    ;; Preserve config from view buffer local var.
			    (let ((window-config
				   dp-simple-viewer-exit-func-args))
			      (kill-this-buffer)
			      (apply 'set-window-configuration
				     window-config)))
			key-map
			'dp-sel2:viewer-bg-face
			window-config))))

;; selected callback
(defun dp-sel2:select-callback (region sel-item &optional rotate-only-p)
  ;; ignore the interprogram-paste-function since
  ;; 1) we know we want stuff from the kill-list
  ;; 2) it seems to be buggy and causes much
  ;;    duplication of kill items.
  (dp-unhighlight-point :id-prop dp-sel2-arrow-id)
  (let (interprogram-paste-function
	(do-not-rotate
	 (and (not rotate-only-p)
	      (or (and (key-press-event-p last-input-event)
		       (eq (event-key last-input-event)
			   'insert)
		       (equal (event-modifiers
			       last-input-event)
			      (list 'meta)))
		  (and (dp-last-command-char)
		       (characterp (dp-last-command-char))
		       (= (dp-last-command-char) ?Y))))))
    (if region
	(insert region)
      ;; not enough... ring will not be rotated correctly
      ;; if another sel buf has inserted and rotated
      ;; kill-ring
      (if (not rotate-only-p)
	  (insert (cdr sel-item)))
      (current-kill (car sel-item) do-not-rotate)))
  (setq this-command 'yank))

;; User has chosen to cancel.  Please don't be sad.
(defun dp-sel2:cancel-callback (&rest unused)
  (dp-unhighlight-point :id-prop dp-sel2-arrow-id))

(defun dp-sel2:post-mode-callback ()
  (dp-define-local-keys
   `(
     [?r] ,(kb-lambda
	      (let ((dp-sel2:rotate-only-p 'no-exit-p))
		(dp-sel2:select)))
     [?R] ,(kb-lambda
	      (let ((dp-sel2:rotate-only-p t))
		(dp-sel2:select)))
     [?c] ,(kb-lambda
	      (dp-sel2-paste:copy-no-exit 'copy))
     [?k] ,(kb-lambda
	      (dp-sel2-paste:copy-no-exit 'copy))
     [?C] ,(kb-lambda
	      (dp-sel2-paste:copy-no-exit 'copy))
     [?K] ,(kb-lambda
	      (dp-sel2-paste:copy-no-exit 'copy))
     [(meta ?o)] ,(kb-lambda
		      (kill-new (dp-sel2-paste:get-item-text)
				(dp-deactivate-mark)))
     [?o] dp-sel2-paste:view-item
     [?v] dp-sel2-paste:view-item
     [?u] dp-sel2-paste:undo-target-buffer
     [(meta ?u)] dp-sel2-paste:undo-target-buffer
     )
   )
)

;;;###autoload
(defun dp-sel2:paste (&optional goto-embedded-p)
  "Select the item to paste from a list.
Rotate kill list so that the selected kill-text is at the head of the
yank ring."
  (interactive "P")
  (if goto-embedded-p
      (dp-sel3:bm)
    (let ()				;(sel-item)
      (if (not kill-ring)
	  (message "Nothing in kill-ring.")
	(save-excursion
	  (dp-rehighlight-point :id-prop dp-sel2-arrow-id))
	(dp-sel2 "*pasties*"		;Buffer name prefix.
		 ;; Item generator function
		 'dp-sel2:list-pastes
		 ;; Function to apply when an item has been selected.
		 'dp-sel2:select-callback
		 ;; Function to apply when the operation has been cancelled.
		 'dp-sel2:cancel-callback
		 ;; post-mode-hook
		 'dp-sel2:post-mode-callback
		 )))
    (setq this-command 'yank)))

(defun dp-sel2:list-bookmarks ()
  (save-excursion
    (mapcar
     (function
      (lambda (name)
	(setq bm (dp-bm-find name))
	;;format: (bookmark-name . marker)
	(dp-goto-bm bm)
	;; grab line from bm location
	(setq line (buffer-substring
		    (progn (beginning-of-line) (point))
		    (progn (end-of-line) (point))))
	(cons (format "`%s'%s" name  line) name)))
     (dp-bm-names 'sortem))))

;;;###autoload
(defun dp-sel2:bm (&optional ignore-embedded-bookmarks-p)
  "Select a bookmark to which to jump."
  (interactive "P")
  (unless ignore-embedded-bookmarks-p
    (dp-scan-for-embedded-bookmarks))
  (if dp-bm-list
      (dp-sel2 "*bookies*"
	       ;; item list generator
	       'dp-sel2:list-bookmarks
	       ;; selected callback
	       (function
		(lambda (region sel-item &optional rotate-only-p)
		  (if sel-item
		      (dp-set-or-goto-bm (cdr (cdr sel-item))))))
	       ;; cancel/quit callback
	       nil)
    (message "No bookmarks.")))

;;; dp-sel2.el ends here
(provide 'dp-sel2)

"
===========================================
*scratch*



"
