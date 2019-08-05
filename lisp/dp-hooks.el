;;;
;;; $Id: dp-hooks.el,v 1.121 2005/07/03 08:20:10 davep Exp $
;;;
;;; mode hooks and supporting functions.
;;;

;; historical variety of styles: see svn, < rev 2013.

;;(add-hook 'find-file-hooks 'dp-add-default-buffer-endicator)

;;; @todo XXX !!! this needs to be fixed to work with both XEmacs and Emacs.
;;; A first fix to to handle places where we use server- and predicate based
;;; on the *macs variant.

(message "dp-hooks loading...")

;; We could just use a buffer local set in the mode-hook.
(defcustom dp-global-master-cleanup-whitespace-p
  '(c-mode
    c++-mode
    sh-mode
    emacs-lisp-mode)
  "control whitespace cleanup off everywhere.
If this is a non-nil list, don't disable if it contains the current major
mode."
  :group 'dp-whitespace-vars
  :type 'boolean)


(defun dp-cleanup-whitespace-mode-pred (&optional list-o-modes mode)
  (setq-ifnil list-o-modes dp-global-master-cleanup-whitespace-p)
  (when (and list-o-modes(listp list-o-modes))
    (memq (or mode major-mode) list-o-modes)))

(defcustom dp-global-master-cleanup-whitespace-pred-fun
  'dp-cleanup-whitespace-mode-pred
  "Call through this to determine if we want to clean up whitespace."
  :group 'dp-whitespace-vars
  :type 'function)

(dp-deflocal dp-cleanup-whitespace-p nil
  "Should trailing whitespace be cleaned up in this buffer?
In particular, should `dp-next-line' do it?
Values:
nil      - NO.
t        - Just do it(tm)
eol-only - Only clean lines when cursor it at the end of a line.
           This makes it easy to leave the whitespace alone.
@todo XXX better to default to t or eol-only?")

(dp-deflocal dp-cleanup-whitespace-on-next-line-p t
  "Should trailing whitespace be cleaned up in this buffer on `next-line?
Values:
nil      - NO.
t        - Just do it(tm)
eol-only - Only clean lines when cursor it at the end of a line.
           This makes it easy to leave the whitespace alone.
@todo XXX better to default to t or eol-only?")

(defun dp-cleanup-whitespace-p ()
  "Do we wish to be anal about whitespace?"
  (when dp-global-master-cleanup-whitespace-p
    (cond
     ((eq dp-global-master-cleanup-whitespace-p t))
     ((dp-funcall-if dp-global-master-cleanup-whitespace-pred-fun nil))
     (dp-cleanup-whitespace-p))))

(defun dp-cleanup-whitespace-on-next-line-p ()
  "Do we wish to be really anal about whitespace?"
  (when (and dp-global-master-cleanup-whitespace-p
             dp-cleanup-whitespace-on-next-line-p)
    (cond
     ((eq dp-global-master-cleanup-whitespace-p t))
     ((and (listp dp-global-master-cleanup-whitespace-p)
	   (memq major-mode dp-global-master-cleanup-whitespace-p)))
     (dp-cleanup-whitespace-p))))

(defvar dp-enable-minibuffer-marking nil
  "Prevents any minibuffer marking from happening.")

(defun dp-minibuffer-abbrevs-post-hook ()
  "Init/refresh minibuffer's local abbrev table."
  (setq local-abbrev-table
        (dp-find-abbrev-table '(dp-minibuffer-abbrev-table))))

(defun dp-region-not-in-minibuf ()
  (and (dp-mark-active-p)
       (not ((eq (window-buffer (active-minibuffer-window))
           (zmacs-region-buffer))))))

(dp-deflocal dp-pre-minibuffer-buffer nil
  "Buffer we were in before we invoked the minibuffer.
Make it buffer local since there can be >1 minibuffers.")

(defun dp-region-active-in-buffer-p (buffer)
  (dmessage "dp-region-active-in-buffer-p, check: %s" buffer)
  (and (dp-buffer-live-p buffer)
       (with-current-buffer buffer
         (and (dp-mark-active-p)
              (dmessage "dp-region-active-in-buffer-p, mark active.")
              (dp-get--as-string--region-or... :bounder 'line-p)))))

(defun dp-minibuffer-exit-hook ()
  ;;(dmessage "dp-minibuffer-exit-hook, buf: %s" (current-buffer))
  (setq dp-pre-minibuffer-buffer nil))

;; This isn't called if we bust out of the minibuffer, e.g., with C-g.
(add-hook 'minibuffer-exit-hook 'dp-minibuffer-exit-hook)

(defun dp-minibuffer-grab-region ()
  (interactive)
  (insert
   (loop for buf in (list dp-pre-minibuffer-buffer
                          (cadr (buffer-list))
                          (zmacs-region-buffer))
     with region
     when (setq region (dp-region-active-in-buffer-p buf))
     return region
     finally do
     (undo-boundary)
     return "1**** CANNOT FIND REGION ***")))

(defun dp-minibuffer-setup-hook ()
  "Sets up personal minibuffer options."
;;CO;   (dmessage "dp-minibuffer-setup-hook, buf: %s, pre: %s\n bl: %s"
;;CO;             (current-buffer)
;;CO;             dp-pre-minibuffer-buffer
;;CO;             (buffer-list)
;;CO;             )

  ;; Where were we when we caused the minibuffer to be used?
  (setq dp-pre-minibuffer-buffer (cadr (buffer-list)))  ; SWAG
  ;; Some minibuffer users, like isearch, provide their own key maps for the
  ;; minibuffer to use.  We don't want to nuke those maps (here), so let's do
  ;; all our manipulations with the actual minibuffer key map.
  (let ((map minibuffer-local-map))
    ;; this may be a problem by causing the zmacs region to deactivate
    ;; when chars are typed in the mini-buffer
    ;;(set-mark nil)
    ;; set up standard history keys: up and down arrows.
    (define-key map [up] 'previous-history-element)
    (define-key map [down] 'next-history-element)
    (define-key map [(control space)]  'dp-expand-abbrev)
    (define-key map [(meta ?-)] 'minibuffer-keyboard-quit)
    (define-key map [(meta ?`)] 'previous-complete-history-element)
    ;; This is `dp-tag-pop' but it can be a reflexive response to an
    ;; inadvertent `dp-tag-find'.
    (define-key map [(meta ?,)] 'minibuffer-keyboard-quit)
    (define-key map [(control ?p)] 'previous-complete-history-element)
    (define-key map [(meta ?p)] 'dp-parenthesize-region)
    (define-key map [(control ?n)] 'next-complete-history-element)
;;; fsf no like these bindings vvv
    ;; (define-key map [(control ?m)] 'dp-minibuffer-grab-region)  ; <mini>buffer
    ;; (define-key map [(meta ?g)] 'dp-minibuffer-grab-region) ; grab
    ;; (define-key map [(meta ?s)] 'dp-minibuffer-grab-region) ; snag
;;; fsf no like these bindings ^^^
    (define-key map [(meta ?')] 'dp-copy-char-to-minibuf)  ; quote
    ;;; FSF change
    (if (dp-xemacs-p)
	(define-key map [(control tab)] 'dp-minibuffer-complete)
      (dp-define-key-list map '([tab] minibuffer-complete
				[(meta up)] dp-other-window-up)))
    (define-key map [(meta ?=)] (kb-lambda
                                   (enqueue-eval-event
                                    'eval
                                    (nth (1- (prefix-numeric-value arg))
                                         command-history))
                                   (top-level)))
    ;; Grabbing the region "normally" doesn't work in minibuffer.
    ;;!<@todo See if I can mod one of my region grabbers (AND try to merge the
    ;;two) to handle things in minibuffer-mode.
    (define-key map [(meta ?9)] (kb-lambda
                                   (dp-insert-parentheses nil)))
    (when (memq this-command '(eval-expression edebug-eval-expression))
      (define-key map [tab] 'dp-completion-at-point))
    (define-key map [(meta ?o)] 'dp-kill-ring-save)
    ;;restore if needed.;     (dp-minibuffer-abbrevs-post-hook)

    ;; M-e `find-file' M-w `save-buffer' don't make sense in a minibuffer so we
    ;; use them to grab a path name from the current *sh* window.  We put the
    ;; function on both so that a simple repeat key press gives us a nice
    ;; remote file name.
    (define-key map [(meta ?e)] 'dp-rsh-cwd-to-minibuffer)
    (define-key map [(meta ?w)] 'dp-rsh-cwd-to-minibuffer)
    (dp-minibuffer-abbrevs-post-hook))

  ;;
  ;; !!!!!!!!!!!!!!!!!
  ;; NO BINDINGS DOWN HERE!! EXCEPT FOR EXCEPTIONS.
  ;; !!!!!!!!!!!!!!!!!

  ;; Optionally mark the default selection for easy deletion
  ;;  (as long as pending-delete-mode is on)
  (if (and dp-enable-minibuffer-marking
	   (boundp 'dp-minibuffer-mark-line-p)
	   dp-minibuffer-mark-line-p)
      (let ((pt (point)))
	(beginning-of-line)
	(dp-set-mark)
	(dmessage "point: %s, pt: %s" (point) pt)
	(goto-char pt)
	(zmacs-make-extent-for-region (cons (point-marker t)
					    (mark-marker t)))
	))
  ;;(dmessage "dp-minibuffer-setup-hook")
)

(require 'dp-buffer-menu)

(defun dp-kill-emacs-hook ()
  "Do my finalization procedures when xemacs exits."
  (let ((debug-on-error nil))
    ;; emacs'll kill the editing server itself, so we just need to clean up
    ;; the ipc file.
    (dmessage "dp-kill-emacs-hook")
    (dp-finalize-editing-server 'rm-ipc-if-ours))
    (when (featurep 'saveconf)
        (dp-save-context)))

(defun dp-match-buffer-name (regexp &optional not-a-regexp-p buffer)
  "RE match the current buffer or BUFFER's name against regexp.
QUOTE-IT-P says to quote the regexp so special chars aren't."
  (when regexp
    (let ((buf-name (dp-buffer-name buffer)))
;       (dp-message-no-echo "regexp>%s<, buf-name>%s<\n"
;                           (if not-a-regexp-p
;                               (regexp-quote regexp)
;                             regexp)
;                           buffer)
      (when (posix-string-match (if not-a-regexp-p
                                    (regexp-quote regexp)
                                  regexp)
                                buf-name)
        ;; return the matching buffer name.
        buf-name))))

(defun dp-match-window-buffer (regexp &optional not-a-regexp-p window)
  "RE match the current buffer or BUFFER's name against regexp.
QUOTE-IT-P says to quote the regexp so special chars aren't."
  (dp-match-buffer-name regexp not-a-regexp-p
                        (if window
                            (window-buffer window)
                          (current-buffer))))

(eval-after-load "text-mode"
  (progn (dp-setup-indentation-colorization 'text-mode)))

(defun dp-text-mode-hook ()
  "Sets up personal text mode options."
  (dp-turn-on-auto-fill)
  (setq indent-tabs-mode nil)
  ;; @todo... try it on since the global abbrev table only has typos in it.
  (abbrev-mode 0)		     ; We use mah MFing abbrevs, MFer.
  ;; ICK!
  (cond
   ;; NB: This only runs when the diary file is first loaded.
   ;; Not realizing this caused a debugging headache.
   ;; I'm sure there's a better way to ID diary files,
   ;; especially since they can be renamed.
   ;; If `diary-file' doesn't begin w/ '/' then prepend
   ((dp-match-buffer-name
     (format "^%s%s$"
             (file-name-nondirectory (regexp-quote diary-file))
             "\\(<[0-9]*>\\)?"))
    (dmessage "diary file>%s<" diary-file)
    (dp-define-diary-file-keys)))

;;  (message "dp-text-mode-hook")
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Some font mercifully short font lock alii
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defalias 'font-lock-buffer 'font-lock-fontify-buffer)
(dp-safe-alias 'flb 'font-lock-fontify-buffer)
(defalias 'font-lock-region 'font-lock-fontify-region)
(dp-safe-alias 'flr 'font-lock-fontify-region)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; C Syntax highlighting mods...
;;
(defvar dp-c*-type-suffixes '("a" "udt" "cls" "t")
  "A preceding \"_\" is added below.")

(defvar dp-c*-type-suffix-regexp (concat "(_("
                                         (regexp-opt dp-c*-type-suffixes)
                                         "))"))


(defvar dp-c*-type-prefixes '("t" "udt" "cls" "c" "s")
  "A following \"_\" will be added below")

(defvar dp-c*-type-prefix-regexp (concat "(("
                                         (regexp-opt dp-c*-type-prefixes)
                                         ")_)"))

(defvar dp-c-font-lock-extra-types (list "FILE" "fd_set"
                                         (format "%s\\(\\sw\\|\\s_\\)+%s"
                                                 dp-c*-type-prefix-regexp
                                                 dp-c*-type-suffix-regexp))
  "My version of the C regexp for determining types.
_t as a suffix is reserved for ``their'' types.  Fine.  I'll use:
_udt: ugly, but not as confuzing as _a.
_cls: common abbreviation for class.
_str: looks too much like string
??? t_XXX: prefix_a, works as aggregate, abstract and alias (typedef).")

(defun dp-mk-font-lock-type-re (list)
  "Convert a list of words/regexps into a keyword matching pattern."
  ;; cannot use regexp-opt since we can have regexps in the list.
  (concat "\\<\\("
	  (dp-regexp-concat list)
	  "\\)\\>"))

;;retire; (defvar dp-debug-like-patterns-orig
;;retire;   (concat (regexp-opt `("tmp_cout" "tmp_cerr" "tmp_v_stream" "tmp_d_stream"
;;retire;                         "debug_stream"
;;retire;                         "very_tmp_stream"
;;retire;                         "dev_stream"
;;retire;                         "tmp_stdout" "tmp_stderr" "tmp_log_stream"
;;retire;                         "@tmp@" "@dbg@" "@rmv@" "@mark@" "WTF"
;;retire;                         "@todo"
;;retire;                         ,dp-debugging-code-tag))
;;retire;           "\\|N[.]?B[.]?\\|<<<<<?\\|"
;;retire;           "XXXX*\\|!!!!*\\|\\?\\?\\?\\?*")
;;retire;   "A regexp that recognizes things that are temporary/debug-like in nature.
;;retire; These can then be font-locked to make them easier to find and remove.")

(defvar dp-debug-like-patterns
  (concat (regexp-opt `("@tmp@" "@dbg@" "@rmv@" "@mark@" "WTF"
			"XXX" "OMFG" "FIXME" "RESTORE" "UNDO"
                        "@todo"))
          "\\|"
          "N[.]?B[.]?!*\\([^a-zA-Z_0-9]\\|$\\)\\|<<<<<?\\|"
          "XXXX*!*\\|!!!!*\\|\\?\\?\\?\\?*!*")
  "A regexp that recognizes things that are temporary/debug-like in nature.
These can then be font-locked to make them easier to find and remove.
These are general in nature and can be found in any [programming language]
file. ")

(defvar dp-c*-debug-like-patterns
  (concat (regexp-opt `("tmp_cout" "tmp_cerr" "tmp_v_stream" "tmp_d_stream"
                        "debug_stream"
                        "very_tmp_stream" "dev_stream"
                        "tmp_stdout" "tmp_stderr" "tmp_log_stream"
                        ,dp-debugging-code-tag)))
  "A regexp that recognizes things that are temporary/debug-like in nature.
These can then be font-locked to make them easier to find and remove.
For C/C++ source code.")

(defun dp-mk-debug-like-patterns (&rest more-patterns)
  (concat "\\("
          (if more-patterns
              (concat (dp-string-join more-patterns "\\|") "\\|")
            "")
          (if dp-local-debug-like-patterns
              (concat (dp-string-join dp-local-debug-like-patterns) "\\|")
            "")
          dp-debug-like-patterns
          "\\)"))

(defun dp-mk-c*-debug-like-patterns ()
  (dp-mk-debug-like-patterns dp-c*-debug-like-patterns))

(dp-deflocal dp-line-too-long-warning-zone-width 6
  "How wide the warning zone is: where len is still OK, but line is
colorized as an indication that you're getting _Close_To_the_Edge_.
The characters get marked with the line-too-long-warning-face.")

(dp-deflocal dp-line-too-long-error-column 80
  "*Become enraged (new face) when going beyond this column.")

(dp-deflocal dp-line-too-long-warning-column
    (- dp-line-too-long-error-column
       (or dp-line-too-long-warning-zone-width 0))
  "*Become annoyed (new face) when going beyond this column.
This must be < the error col. ??? Why ???  Because... math?
XXX @todo derive this from the wrap column.  Will need to be per-mode.")

(defface dp-default-line-too-long-warning-face
  '(
  (((class color) (background light))
   (:background "blue" :foreground "white"))
  (t (:inherit warning :background)))
  "Face for buffer lines which are becoming too long."
  :group 'faces
  :group 'dp-faces)

(defface dp-default-line-too-long-error-face
  '(
    (t (:inherit dp-default-line-too-long-warning-face
		 :slant oblique :weight bold
		 :strike-through nil
		 :underline (:color "warning" :style wave))))
  "Face for buffer lines which are too long."
  :group 'faces
  :group 'dp-faces)

;; ;; !<@todo XXX make this handle warning-col >= error-col. (if < 0) 0
;; (defvar dp-font-lock-line-too-long-error-element
;;   ;; +1 'cause column number starts at zero.
;;   (let ((warning-zone-len (- dp-line-too-long-error-column
;;                              dp-line-too-long-warning-column
;;                              1)))
;;    ;;               +-- 1 -------+  +-- 2 ---------+  +- 3 +
(defvar dp-font-lock-line-too-long-error-element
  `(
    ,(format
      "^\\([^\t\n]\\{%s\\}\\|[^\t\n]\\{0,%s\\}\t\\)\\{%d\\}%s\\(.+\\)$"
      tab-width
      (1- tab-width)
      (/ dp-line-too-long-error-column tab-width)
      (let ((rem (% dp-line-too-long-error-column tab-width)))
	(if (zerop rem)
	    ""
	  (format ".\\{%d\\}" rem))))
    2					; line tail
    'dp-default-line-too-long-error-face
    prepend)
  "Font-lock component to highlight lines that are too long.
Regexp and font-lock-keywords element.
Works with tabs.")

;; @todo XXX Make len of warning area (- error-len warning-len)
(defvar dp-font-lock-line-too-long-warning-element
  `(
    ,(format
      "^\\([^\t\n]\\{%s\\}\\|[^\t\n]\\{0,%s\\}\t\\)\\{%d\\}%s\\(%s\\)$"
      tab-width
      (1- tab-width)
      (/ dp-line-too-long-warning-column tab-width)
      (let ((rem (% dp-line-too-long-warning-column tab-width)))
	(if (zerop rem)
	    ""
	  (format ".\\{%d\\}" rem)))
      (let ((warning-zone-len (- dp-line-too-long-error-column
				 dp-line-too-long-warning-column)))

	;; (format ".\\{1,%d\\}" warning-zone-len)
	".+"
	))

    2					; line tail
    'dp-default-line-too-long-warning-face
    prepend)
  "As above, but handles the warning zone.")

(defvar dp-font-lock-line-too-long-error-default-element
    dp-font-lock-line-too-long-error-element
    "Font lock element to fontify line which are too long.")

(defvar dp-font-lock-line-too-long-warning-default-element
  dp-font-lock-line-too-long-warning-element
  "Font lock element to fontify line which are becoming too long.")

(defface dp-trailing-whitespace-face
  '((((class color) (background light))
     ;;     (:background "aliceblue" :bold nil)))
;;     (:background "gainsboro" :bold nil)))
     (:background "lightgrey" :bold nil)))
  "Face for buffer lines which have trailing whitespace."
  :group 'faces
  :group 'dp-faces)

(defcustom dp-trailing-whitespace-regexp "\\s-+$"
  "Regular expression to detect that most egregious of all programming
  problems, that of trailing whitespace. Something so bad, so heinous, so
  unutterably eeveel that it's worth checking out and modifying every single
  hideous violator of that most sacred of all things, the trailing whitespace
  free line. We must spare no effort to return our files to the most holy of
  all states. And don't get me stahted on macros. MACROS BAAAAAD, grrrrr!"
  :group 'dp-whitespace-vars
  :type 'string)

(defcustom dp-space-before-tab-regexp " +[\t]"
  "Regular expression to detect that most egregious of all programming
  problems, that of trailing whitespace. Something so bad, so heinous, so
  unutterably eeveel that it's worth checking out and modifying every single
  hideous violator of that most sacred of all things, the trailing whitespace
  free line. We must spare no effort to return our files to the most holy of
  all states. And don't get me stahted on macros. MACROS BAAAAAD, grrrrr!"
  :group 'dp-whitespace-vars
  :type 'string)

(defcustom dp-too-many-spaces-in-a-row-regexp " \\{8,80\\}"
  "Sometimes (although it may be fixed) AMD/Kernel c*-mode starts up without
  forcing the use of tabs.  Hopefully this will slap me in the face about it
  so the spatse-Nazis don't get me. "
  :group 'dp-whitespace-vars :type
  'string)

(defcustom dp-trailing-whitespace-use-trailing-ws-font-p nil
  "Highlight trailing white space with its own font? Yay!
For FSF, I'm using the inbuilt system, controlled by
`show-trailing-whitespace'."
  :group 'dp-whitespace-vars
  :type 'boolean)

(defvar dp-trailing-whitespace-font-lock-element
  (list dp-trailing-whitespace-regexp 0 'dp-trailing-whitespace-face 'prepend)
  "A font-lock element to pick out trailing whitespace.")

(defcustom dp-use-space-before-tab-font-lock-p nil
  "Highlight space before tab sequence. Kernel coding standard no-no!"
  :group 'dp-whitespace-vars
  :type 'boolean)

(defvar dp-space-before-tab-font-lock-element
  (list dp-space-before-tab-regexp 0 'dp-trailing-whitespace-face 'prepend)
  "A font-lock element to pick out trailing whitespace.")

(defvar dp-too-many-spaces-in-a-row-font-lock-element
  (list dp-too-many-spaces-in-a-row-regexp
	0
	'dp-trailing-whitespace-face 'prepend)
  "A font-lock element to pick out too many spaces in a row.")

(defcustom dp-use-too-many-spaces-font-p nil
  "Highlight too many spaces in a row (missing tabs)?"
  :group 'dp-whitespace-vars
  :type 'boolean)


(defun dp-whitespace-violation-regexp (&optional tabs-mode-p)
  (dp-regexp-concat (delq nil
			  (list dp-trailing-whitespace-regexp
				(when tabs-mode-p
				  dp-space-before-tab-regexp)
				(when tabs-mode-p
				  dp-too-many-spaces-in-a-row-regexp)))))

(defun dp-blah-blah (save-sym)
  (append (symbol-value save-sym)
          list-o-keys))

(defun dp-add-font-patterns-old (list-o-modes &rest list-o-keys)
  "Add the keyword patterns in LIST-O-KEYS to each mode in LIST-O-MODES.
This function uses a mechanism which restores a variable to its original
state and then applies changes. This is good... sometimes."
  ;; Icky... the lambda uses variables from the current environment.
  (loop for mode in list-o-modes do
    (dp-save-orig-n-set-new mode
                            (function (lambda (save-sym)
					(append
                                         (symbol-value save-sym)
                                         list-o-keys
                                         ))))))

(defun dp-add-font-patterns (list-o-modes buffer-local-p list-o-keys)
  "Add the font-lock keywords in LIST-O-KEYS to each mode in LIST-O-MODES.
This function uses a mechanism which restores a variable to its original
state and then applies changes. This is good... sometimes."
  ;; Icky... the lambda uses variables from the current environment.
  (setq list-o-modes (dp-listify-thing list-o-modes)
	lost-o-keys (dp-listify-thing list-o-keys))
  (loop for mode in list-o-modes do
    (progn
      (when buffer-local-p
        (make-variable-buffer-local mode))
      (dp-save-orig-n-set-new mode
                              (function
                               (lambda (save-sym)
                                 (append
                                  (symbol-value save-sym)
                                  list-o-keys
                                  )))))))


(defun dp-add-to-font-patterns (list-o-modes &rest list-o-keys)
  "Add the keyword patterns in LIST-O-KEYS to each mode in LIST-O-MODES.
This function uses a mechanism which restores a variable to its original
state and then applies changes. This is good... sometimes."
  ;; Icky... the lambda uses variables from the current environment.
  (loop for mode in list-o-modes do
    (loop for key in list-o-keys do
      (add-to-list mode key t))))

(defun* dp-add-line-too-long-font-old (font-lock-var-syms
                                       &key (buffer-local-p t))
  "WARNING: This function uses `dp-add-font-patterns' which resets the fonts.
`dp-add-font-patterns' uses a mechanism which restores a variable to its
original state and then applies changes. This is good... sometimes."
  (interactive "Smode's font lock var? ")
  (unless (listp font-lock-var-syms)
    ;; Listify the input.
    (setq font-lock-var-syms (list font-lock-var-syms)))
  (when buffer-local-p
    (loop for v in font-lock-var-syms do
      (make-variable-buffer-local v)))
  (dp-add-font-patterns-old font-lock-var-syms
                            dp-font-lock-line-too-long-error-default-element))

(defun* dp-add-line-too-long-font (font-lock-var-syms
                                   &key (buffer-local-p t))
  "WARNING: This function uses `dp-add-font-patterns' which resets the fonts.
This makes adding the element idempotent.
`dp-add-font-patterns' uses a mechanism which restores a variable
to its original state (when it is called for the first time) and
then applies changes. This is good... sometimes."
  (interactive "Smode's font lock var? ")
  (dp-add-font-patterns font-lock-var-syms
			buffer-local-p
			(list dp-font-lock-line-too-long-error-default-element
			      dp-font-lock-line-too-long-warning-default-element)))

(defun dp-muck-with-fontification ()
  ;; Reset things to original state.
;   (dp-save-orig-n-set-new 'c-font-lock-keywords-3 c-font-lock-keywords-3)
;   (dp-save-orig-n-set-new 'c++-font-lock-keywords-3 c++-font-lock-keywords-3)
;   (setq c-font-lock-keywords-3 dp-orig-c-font-lock-keywords-3)
  ;; fix up the loudest setting.
  (dmessage "in dp-muck-with-fontification")
  (if (dp-xemacs-p)
      ;; All font junk is now done in the cc-mode's `eval-after-load'
      ()

    ;;;;;;;;;;;;;;;;; FSF emacs ;;;;;;;;;;;;;;;;;
    ;;;;;;;  VERY, VERY STALE ~~~~ ;;;;;;;;;;;;;;

    (setq c-font-lock-keywords-3
	  ;;
	  ;; FSFMacs case.  They still haven't fixed the regexps to match
	  ;; funtion/macro names that include underscores.
	  ;; modified from c-...-2 to add support for \\s_
	  ;; in identifier names.  I'd like to just modify \\sw to be
	  ;; \\(\\sw\\|\\s_\\), but a couple of re's are moved to different
	  ;; match indexes when an un-parenthesized \sw is parenthesized to add
	  ;; the \s_
	  ;; XXX -- can add shy grouping parens around \\sw
	  ;; NOPE. shy grouping is XEmacs only.
	  '(("^\\(\\(\\sw\\|\\s_\\)+\\)[ 	]*(" 1 font-lock-function-name-face)
	    ("^#[ 	]*error[ 	]+\\(.+\\)" 1 font-lock-warning-face prepend)
	    ("^#[ 	]*\\(import\\|include\\)[ 	]+\\(<[^>\"\n]*>?\\)"
	     2 font-lock-string-face)
	    ("^#[ 	]*define[ 	]+\\(\\(\\sw\\|\\s_\\)+\\)("
	     1 font-lock-function-name-face)
	    ("^#[ 	]*\\(elif\\|if\\)\\>"
	     ("\\<\\(defined\\)\\>[ 	]*(?\\(\\(\\sw\\|\\s_\\)+\\)?" nil nil
	      (1 font-lock-reference-face)
	      (2 font-lock-variable-name-face nil t)))
	    ("^#[ 	]*\\(\\(\\sw\\|\\s_\\)+\\)\\>[ 	]*\\(\\(\\sw\\|\\s_\\)+\\)?"
	     (1 font-lock-reference-face)
	     (3 font-lock-variable-name-face nil t))
	    (eval cons
		  (dp-mk-font-lock-type-re
		   (cons
                    (concat
                     "auto\\|c\\(har\\|onst\\)\\|double\\|e\\(num\\|xtern\\)"
                     "\\|float\\|int\\|long\\|register"
                     "\\|s\\(hort\\|igned\\|t\\(atic\\|ruct\\)\\)"
                     "\\|typedef\\|typename\\|un\\(ion\\|signed\\)"
                     "\\|vo\\(id\\|latile\\)")
                    dp-c-font-lock-extra-types))
		  'font-lock-type-face)
	    (concat "\\<\\(break\\|continue\\|do\\|else\\|for\\|if\\|return"
                    "\\|switch\\|while\\)\\>")
	    ("\\<\\(case\\|goto\\)\\>[ 	]*\\(-?\\(\\sw\\|\\s_\\)+\\)?"
	     (1 font-lock-keyword-face)
	     (2 font-lock-reference-face nil t))
	    (":"
	     ("^[ 	]*\\(\\(\\sw\\|\\s_\\)+\\)[ 	]*:"
	      (beginning-of-line)
	      (end-of-line)
	      (1 font-lock-reference-face)))))
))

(when dp-fontify-p
  (add-hook 'dp-post-dpmacs-hook 'dp-muck-with-fontification))

;; ;;(brace-list-close . after)
(defvar dp-hanging-brace-alist '((brace-list-close . ignore))
  "My hanging braces values.  We will edit or append to
c-hanging-braces-alist based upon these values.")

;; things like `dp-use-too-many-spaces-font-p' are disabled because the fontifier says:
;; (jit-lock-function 66587)
;;   signaled (void-function dp-too-many-spaces-in-a-row-regexp)
(defun* dp-c-like-add-extra-faces (list-o-modes
                                   &key
                                   (buffer-local-p nil)
				   (set-em-p t)
                                   (use-trailing-ws-font-p
                                    dp-trailing-whitespace-use-trailing-ws-font-p)
                                   (use-too-many-spaces-font-p
                                    dp-use-too-many-spaces-font-p)
                                   (use-space-before-tab-font-p
                                    dp-use-space-before-tab-font-lock-p)
                                   (use-too-long-face-p
                                    (dp-val-if-boundp
                                     dp-global-c*-use-too-long-face))
                                   (use-too-long-warning-face-p
                                    (dp-val-if-boundp
                                     dp-global-c*-use-too-long-warning-face)))
  (interactive)
  (dmessage "in dp-c-like-add-extra-faces")
  (dmessage "in dp-c-like-add-extra-faces: dp-twsp: %s, utlf: %s, utlwf: %s"
	    dp-trailing-whitespace-use-trailing-ws-font-p
	    use-too-long-face-p use-too-long-warning-face-p)
  (let ((extras
	 (delq nil
	       (list
		(when use-trailing-ws-font-p
		  dp-trailing-whitespace-font-lock-element)
		(when use-too-long-face-p
		  dp-font-lock-line-too-long-error-default-element)
		(when use-too-long-warning-face-p
		  dp-font-lock-line-too-long-warning-element)
		(when use-space-before-tab-font-p
		  dp-space-before-tab-font-lock-element)
		(when use-too-many-spaces-font-p
		  dp-too-many-spaces-in-a-row-font-lock-element)
		(cons
		 (dp-mk-font-lock-type-re dp-c-font-lock-extra-types)
		 font-lock-type-face)
		(cons (dp-mk-c*-debug-like-patterns)
		      ;; ??? Which is better; just the match or the whole
		      ;;     line?
		      '(1 'dp-debug-like-face t))))))
    ;;
    ;; Add some extra types to the xemacs gaudy setting.  Rebuild the
    ;; list each time rather than adding to the existing value.  This
    ;; makes reinitializing cleaner.
    (dp-add-font-patterns list-o-modes
			  buffer-local-p
			  extras)
    (when (and nil set-em-p)
      (dp-set-font-lock-defaults 'c-mode '(extra t)))))

;; @todo XXX Make this a defcustom.
(dp-deflocal dp-use-c++-add-extra-faces-p t)
(defun* dp-c++-add-extra-faces (&key
				(buffer-local-p nil)
				(set-em-p t)
				(use-trailing-ws-font-p
				 dp-trailing-whitespace-use-trailing-ws-font-p)
				(dp-use-too-long-face-p
				 (dp-val-if-boundp
				  dp-global-c*-use-too-long-face)))
  (dmessage "in dp-c++-add-extra-faces")
  (when (bound-and-true-p dp-use-c++-add-extra-faces-p)
    (dp-c-like-add-extra-faces
     '(c++-font-lock-keywords-3
       c++-font-lock-keywords-2
       c++-font-lock-keywords-1)
     :buffer-local-p buffer-local-p
     :set-em-p set-em-p
     :use-trailing-ws-font-p use-trailing-ws-font-p
     :use-too-long-face-p dp-use-too-long-face-p)))

;; @todo XXX Make this a defcustom.
(dp-deflocal dp-use-c-add-extra-faces-p t)
(defun* dp-c-add-extra-faces (&key
                              (buffer-local-p nil)
                              (use-trailing-ws-font-p
                               dp-trailing-whitespace-use-trailing-ws-font-p)
                              (use-too-long-face-p
                               (dp-val-if-boundp
                                dp-global-c*-use-too-long-face)))
  (dmessage "in dp-c-add-extra-faces")
  (when (bound-and-true-p dp-use-c-add-extra-faces-p)
    (dp-c-like-add-extra-faces
     '(c-font-lock-keywords-3
       c-font-lock-keywords-2
       c-font-lock-keywords-1)
     :buffer-local-p buffer-local-p
     :use-trailing-ws-font-p use-trailing-ws-font-p
     :use-too-long-face-p use-too-long-face-p)))

(defvar dp-c-like-modes '(c++-mode c-mode)
  "This list holds the modes that can benefit, att, from `dp-open-newline'.")

;; Set up our mode specific open-newline function.
(dp-set-mode-local-value 'dp-open-newline-func 'dp-c-open-newline
                         dp-c-like-modes)

(defun dp-c-beginning-of-defun-0-real-bof ()
  (interactive)
  (dp-c-beginning-of-defun 1 'real-bof))

(defun dp-c-end-of-defun-0-real-bof ()
  (interactive)
  (dp-c-end-of-defun 1 'real-bof))

(defun dp-after-load-cc-mode ()     ;<:cc-after-load|bind-c*-keys|setup c* :>
  (interactive)
  ;; NB! Don't put per buffer vars, etc, here.
  ;; allow us to override the default style with a "current project"
  ;; style. This is not suitable for specifying in file local
  ;; variables due to the order in which things are done.  To use file
  ;; local vars, add the c style to the c-style-alist via (c-add-style
  ;; name style) and then specify the string name in the file local
  ;; variable `c-file-style'
  (c-add-style (or (and (boundp 'current-project-c++-mode-style-name)
                        current-project-c++-mode-style-name)
                   "PERSONAL-default")
               (or (and (boundp 'current-project-c++-mode-style)
                        current-project-c++-mode-style)
                   dp-default-c-style)
               ;; FSF tries to set this style to the current buffer (*scratch*)
               ;; during init and fails "Buffer *scratch* is not CC-Mode buffer"
               ;; Till resolved, x --> t, f --> nil
               (dp-xemacs-p))
  ;;  (define-key map [(control c) d (meta /)] 'dp-c++-mk-protection-section)
  ;;  (define-key map [(control c) d / ] 'dp-c++-goto-protection-section)
  (define-key dp-Ccd-map [(meta /)]  'dp-c++-mk-protection-section)
  (define-key dp-Ccd-map "/" 'dp-c++-goto-protection-section)
  (define-key dp-Ccd-map  [:] (kb-lambda (dp-c-open-newline 'colon)))

  ;; We may just want to put all of this into the c-mode-base-map
  ;; if it doesn't harm any of the other C syntax like languages.
  (loop for map in (list c-mode-map c++-mode-map) do
    ;;(define-key map [(meta return)] 'dp-c-open-newline)
    (define-key map [(meta ?e)] 'find-file-at-point)
    (define-key map [(meta ?a)] 'dp-toggle-mark)
    (define-key map [(meta ?A)] 'dp-mark-to-end-of-line)
    (define-key map [tab] 'dp-c-indent-command)
    (define-key map [(meta left)] 'dp-c-beginning-of-defun-0-real-bof)
    (define-key map [(meta right)] 'dp-c-end-of-defun-0-real-bof)
    (define-key map [(control ?x) (control left)] 'dp-c-beginning-of-defun)
    (define-key map [(control ?x) left] 'dp-c-show-class-name)
    (define-key map [(control ?x) (control right)] 'dp-c-end-of-defun)
    (define-key map [(meta right)]
      (kb-lambda
          (dp-c-end-of-defun 1 'real-bof)))
    (define-key map [(control ?x) right]
      (kb-lambda
          (let ((p (point)))
            (c-beginning-of-defun 1)
            (if (search-forward "data:> ///" nil t)
                (dp-push-go-back "goto-data" p)
              (goto-char p)
              (ding)
              (message "Cannot find data section.")))))

    (define-key map [(control space)] 'dp-expand-abbrev)
    (define-key map [(control meta ?x)] 'dp-embedded-lisp-eval@point)
    (define-key map [(meta ?j)] 'join-line)
    (define-key map [(control ?y)] 'dp-c-yank-pop)
    (define-key map [(control meta ?a)] 'mark-defun)
    (define-key map [(meta ?Q)] 'align)


    ;;
    ;; cc-mode now does much of what I do in dp-c-newline-and-indent in
    ;; c-context-line-break.  For now we bind the cc-mode func to RET
    ;; and put put mine on C-j for fallback access.
    (define-key map "\C-j" 'dp-c-newline-and-indent)
    (define-key map "\C-m" 'c-context-line-break)
    (define-key map "/" 'dp-c-electric-slash)
    (define-key map "{" 'dp-c-electric-brace)
    (define-key map "}" 'dp-c-close-brace)
    (define-key map [(meta ?\;)] 'dp-c-indent-for-comment)
    (define-key map [delete] 'dp-delete)
    (define-key map "\C-d" 'dp-delete)
    (define-key map [(control \;)] (kb-lambda (dp-c-open-newline 'colon)))
    (define-key map [(control meta return)] (kb-lambda
                                                (dp-c-open-newline 'colon)))
    ;; Why just straight c-mode?
    ;; @todo XXX For some reason, things go blammo if these defines are moved
    ;; outside of the loop. dp-mk-extern-proto is claimed to be void.
    ;;??(define-key map "\C-cdfd" 'dp-c-format-func-decl)
    (define-key dp-c-mode-map "d" 'dp-c-format-func-decl)
    ;;??(define-key map "\C-cdfc" 'dp-c-format-func-call)
    (define-key dp-c-mode-map "c" 'dp-c-format-func-call)
    (define-key dp-c-mode-map "p" 'dp-mk-extern-proto)

    (define-key map [(meta ?q)] 'dp-c-fill-paragraph)
    (define-key map [return] 'dp-c-context-line-break)
    (define-key map [?l] 'dp-c-mode-l)
    (define-key map [(control /)] 'semantic-ia-show-summary)

    ;; 'C-;'
    (define-key map [(control 59)] (kb-lambda (insert ";" )))
    )
)

(eval-after-load "cc-mode"
  (dp-after-load-cc-mode))

(defcustom dp-default-c-like-mode-cleanup-whitespace-p t
  "Turn it all on or off for all C like modes here."
  :group 'dp-whitespace-vars
  :type 'boolean)

(defcustom dp-c-like-mode-default-indent-tabs-mode-p t
  "How should we treat indentation: with chars or tabs.
kernel coding style be damned, indentation and tabs are two different things.
Also, spaces will *always* result in the same indentation size, regardless of
tab setting, font or phase of the moon."
  :group 'dp-vars
  :type 'boolean)

(defun dp-c-like-mode-common-hook ()
  "Sets up personal C/C++ mode options."
  (interactive)
  (dmessage "in dp-c-like-mode-common-hook")
  ;;
  ;;(message "in dp-c-like-mode-common-hook")
  ;; c-mode turns this on to get some keyword expansion, but it
  ;; doesn't work well with my dir abbrevs: they get expanded
  ;; when I don't want them to.
  ;; maybe I should only use them when I'm in an appropriate mode.
  ;; @todo... try it on since the global abbrev table only has typos in it.
  (abbrev-mode 0)		     ; We use mah MFing abbrevs, MFer.
  (c-toggle-auto-state 1)	     ;set c-auto-newline
  (dp-turn-off-auto-fill)
  (setq show-trailing-whitespace t)
  (setq dp-cleanup-whitespace-p dp-default-c-like-mode-cleanup-whitespace-p)
  (setq indent-tabs-mode dp-c-like-mode-default-indent-tabs-mode-p
        c-tab-always-indent (not dp-use-stupid-kernel-struct-indentation-p)
        c-recognize-knr-p nil
        dp-insert-tempo-comment-func 'dp-c-insert-tempo-comment)

  (dp-update-alist 'c-hanging-braces-alist dp-hanging-brace-alist)
  ;; @todo -- see if I can do this programmatically.
  (if (eq major-mode 'pike-mode)
      ()                                ; no I-menu support
    (imenu-add-to-menubar "IM-cc"))
  (dmessage "Apply mode-transparent check to ALL buffers.")
  (when (and (buffer-name)
             (dp-file-name-implies-readonly-p
              (buffer-name)
              (concat "[.,-]\\("
                      (dp-mk-mode-transparent-r/o-regexp nil)
                      "\\)")))
    (ding)                              ; !<@todo XXX
    (toggle-read-only 1))
  ;; xor modes?
  (when (dp-gtags-p)
    (gtags-mode 1))
  (when (dp-xgtags-p)
    (xgtags-mode 1))
  (dp-auto-it?)
  (dp-global-set-tags-keys)

  (progn
    (c-setup-filladapt)
    (filladapt-mode 1)
    (dmessage "Trying c-setup-filladapt in hook. If things get fucked up (as-of 2010-05-23T17:37:13, then check this."))

  ;; Do the too long fontification so I can turn it on or off on a per file
  ;; basis. Too many dumb-asses use 100s (not 100+, but n * 100) chars/line
  ;; very, very often and the files become nigh unreadable.
  (let ((fontification-msg "."))
    (if dp-fontify-p
        ;; This line seems to wipe out the extra faces.
        ;; Because it modifies the original value, not the current.
        ;; `dp-save-orig-n-set-new' saves that variable the first time it is
        ;; called and applies all other changes to that copy.  Hence, this
        ;; returns us to the original value and adds the line-too-long stuff.
        (when (and
               (not buffer-read-only)
               (if-and-fboundp 'dp-use-line-too-long-font-p
                   (dp-use-line-too-long-font-p)
                 t))                    ; default to using it.
          (dp-c-add-extra-faces :buffer-local-p t)
          (dp-c++-add-extra-faces :buffer-local-p t))
      (setq fontification-msg "... NOT!"))
    (message "dp-c-like-mode-common-hook, fontifying%s" fontification-msg)))


; (defadvice c-end-of-defun (around dp-c-end-of-defun act)
;   "If preceeding command was `c-beginning-of-defun' do a go-back.
; Otherwise business as usual.
; Also leave the region active."
;   (dp-set-zmacs-region-stays t)
;   (if (eq last-command 'c-beginning-of-defun)
;       (progn
;         (dp-pop-go-back)
;         (setq this-command nil))
;     (dp-push-go-back "advised `c-end-of-defun'")
;     ad-do-it))

(defcustom dp-c++-std-elements
  '("cout" "cerr" "cin" "clog" "endl" "istream" "ostream"
    "stringstream" "istringstream" "ostringstream"
    "streambuf" "string" "streamsize"
    "vector" "ofstream" "ifstream" "map" "set" "multimap"
    "skipws" "noskipws" "auto_ptr" "queue" "ostream_iterator"
    "min" "max" "exception" "list" "for_each" "unary_function"
    "deque" "pair"
    "unitbuf"
    )
  "*List of things in the std:: namespace we want to be expanded to
std::<thing> by abbrev-mode in a C++ buffer.
As a special case, undo will, after an expansion, will exactly undo the
expansion.  This helps remove the onus of defining things to expand which
are too general, e.g. queue."
  :group 'dp-vars
  :type '(repeat (string :tag "std:: symbol")))

(dp-deflocal dp-c++-mode-add-namespace-disabled t
  "*Per-buffer override.")

(defun dp-maybe-add-c++-namespace (&optional namespace)
  "Possibly add a C++ namespace qualifier to an abbrev.
Don't add it if we're in a comment, the qual already exists or it is
part of a longer name."
  (interactive)
  ;;(dmessage "add:last-command-event>%s<" last-command-event)
  (unless (or dp-c++-mode-add-namespace-disabled
              (dp-in-a-string)
              (dp-in-a-c*-comment))
    (let ((namespace-qual (regexp-quote (concat (or namespace "std") "::")))
          (case-fold-search nil))
      ;; no changes to comments
      (save-excursion
	(backward-word)
	;; don't do it if the previous token is already qualified or
	;; if the character triggering expansion (usually punctuation
	;; or whitespace) implies the token is going to be part of a
	;; longer token (e.g. we expand vector but not vector_of_pointers)
	(unless (save-excursion
		  (or
		   (save-excursion
		     (beginning-of-line)
		     (looking-at "\\s-*\\#\\s-*"))
		   ;; if we move back at all, that means there are
		   ;; other identifier type chars and in this case
		   ;; we assume that the abbrev is part of an
		   ;; identifier (like name_string)
		   (< (skip-chars-backward "[a-zA-Z_:]") 0)
		   (looking-at namespace-qual)
                   (eq last-command 'dp-c++-mode-undo)
		   ;; memq so we can check for other chars easily.
		   (memq (dp-last-command-char) '(?_ ?.))))
          ;;Allows for easy undoing of name space insertion.
          (undo-boundary)
	  (insert namespace-qual)
          (setq dp-c++-mode-last-event (copy-event last-command-event))
          (setq this-command 'dp-maybe-add-c++-namespace_was_added))))))

(defvar dp-c++-mode-last-event nil)
(defun dp-c++-mode-undo (&optional arg)
  "If last-command caused a C++ name space to be added, undo that, else just undo."
  (interactive "P")
  ;;(dmessage "last-command>%s<" last-command)
  (if (and (eq last-command 'dp-maybe-add-c++-namespace_was_added)
           (progn (setq last-command 'dp-c++-mode-undo) t))
      (let ((pt (point-marker)))
        ;;(dmessage "ns was added")
        (call-interactively 'undo)
        (when dp-c++-mode-last-event
          ;;(dmessage "dp-c++-mode-last-event>%s<" dp-c++-mode-last-event)
          (goto-char pt)
          (setq pt nil)                 ;Hasten marker reclamation.
          (dispatch-event dp-c++-mode-last-event)
          (deallocate-event dp-c++-mode-last-event) ;Hasten event reclamation.
          (setq dp-c++-mode-last-event nil)
	  (dmessage "Can `unexpand-abbrev' help?  Need to set up some vars in my exapnsion routine.")))
    (call-interactively 'undo)))

(defun dp-c++-mode-define-abbrevs ()
  (interactive)
  (mapc (function
         (lambda (arg)
           (define-abbrev local-abbrev-table arg arg
             'dp-maybe-add-c++-namespace)))
	dp-c++-std-elements))

(defun dp-string-match-no-fold (regexp string &optional fold-p)
  (with-case-folded fold-p
    (string-match regexp string)))

(defun dp-c++-source-file-name-p (file-name)
  (dp-string-match-no-fold dp-c-source-file-extension-regexp file-name))

(defun dp-c++-include-file-name-p (file-name)
  (dp-string-match-no-fold dp-c-include-file-extension-regexp file-name))

(defun* dp-c++-source-buffer-p (&optional (buffer (current-buffer)))
  (dp-c++-source-file-name-p (buffer-file-name buffer)))

(defvar dp-c++-new-source-file-template
  "#include <cstdio>
#include <iostream>

int
main(
  int argc,
  const char* argv[])
{
"
  "Template code for new C++ files.")

(defvar dp-c++-new-include-file-template 'dp-dot-h-reinclusion-protection
  "String or function.  Insert or call as appropriate.")

;; When adding initializers to a constructor this takes the var name and
;; makes it into a standard initializer.
;; e.g. avar-!-   -->   m_avar(avar),-!-
(defalias 'dp-c*-member-init
  (read-kbd-macro "<C-left> M-SPC M-o m) <backspace> _ C-e M-9 M-y C-e ,"))


(defun* dp-c++-mode-hook (&optional (insert-template-p t))
  "My C++ mode hook"
  (interactive)
  ;; try this again, w/some expansions like: cout --> std::cout
  (abbrev-mode 0)			; We use mah MFing abbrevs, MFer.
  ;; add the std:: namespace qualifier to a bunch of things.
  ;; may want to tweak this list
  (dp-c++-mode-define-abbrevs)
  (local-set-key [(meta ?e)] 'dp-ffap)
  (local-set-key "\e[" 'dp-c++-find-matching-paren)
  (local-set-key [(meta ?u)] 'dp-c++-mode-undo)
  (local-set-key [(control ?c) (control meta ?s)] 'dp-c-get-syntactic-region)
  (local-set-key [(meta ?s)] 'dp-c++-member-init)
  (local-set-key [?:] 'dp-c-electric-colon)
  (global-set-key [(control ?\\)] 'dp-eval-naked-embedded-lisp)
  (when (fboundp 'eassist-list-methods)
    (local-set-key [(control c) ?, ?.] 'eassist-list-methods))
  ;; Trying to find out why point moves around when switching buffers
;;?point?;   (dmessage "B0: buf: %s, p: %s, pmin: %s, pmax: %s win point: %s"
;;?point?;             (current-buffer) (point) (point-min) (point-max)
;;?point?;             "no win yet.")
  ;; Is the file empty?
  (when (and insert-template-p
             (equal (point-min) (point-max))  ; Suspenders.
             (equal (point) (point-max)))  ; Belt.
    (if (dp-c++-source-buffer-p)
        (dp-apply-if dp-c++-new-source-file-template nil
          (insert dp-c++-new-source-file-template))
      (dp-apply-if dp-c++-new-include-file-template nil
        (insert dp-c++-new-include-file-template)))
;;     !<@todo XXX point moves around when visiting files, especially (only?)
;;     shell buffers.  WHY!?!?!?!?
;;?point?;     (dmessage "B: buf: %s, p: %s, pmin: %s, pmax: %s win point: %s"
;;?point?;               (current-buffer) (point) (point-min) (point-max)
;;?point?;               (window-point (get-buffer-window (current-buffer))))
    (set-buffer-modified-p nil)
    (dp-push-go-back "c++ boiler plate" (1- (point-max)))
    (set-window-point (dp-get-buffer-window (current-buffer))
                      (1- (point-max)))
;;?point?;     (dmessage "A: buf: %s, p: %s, pmin: %s, pmax: %s win point: %s"
;;?point?;               (current-buffer) (point) (point-min) (point-max)
;;?point?;               (window-point (get-buffer-window (current-buffer))))
    ;;(dp-auto-it?)
    ))

(defun dp-pike-mode-hook ()
  "Add font lock info."
  (require 'pike)
  (dp-auto-it?))

(defun dp-ruby-mode-hook ()
  "Set up ruby-mode *my* way."
  (interactive)
  (dp-add-line-too-long-font 'ruby-font-lock-keywords)
  (setq dp-cleanup-whitespace-p t)
  (local-set-key [(meta right)] 'ruby-end-of-block)
  (local-set-key [(meta left)] 'dp-beginning-of-def-or-class)
  (dp-auto-it?))

(defvar dp-orig-python-tab-binding nil
  "Original binding for the tab key in python mode")

(defun dp-py-prepend-self. (&optional make-initializer-p)
  (interactive "P")
  (let (p m)
    (save-excursion
      (backward-word 1)
      (insert "self.")
      (setq m (dp-mk-marker))
      ;; This makes sure we get the whole symbol since we may have issued the
      ;; command inside it somewhere.
    (forward-word)
    (setq p (dp-mk-marker)))
    (when make-initializer-p
      (goto-char p)
      (insert " = " (buffer-substring m p)))))

;;(make-string 3 ?\')
;;(make-string 3 ?\")
(defvar dp-python-mode-parenthesize-region-paren-list
  `(("(" . ")")
    ("\"" . "\"")
    ,(cons (make-string 3 ?\") (make-string 3 ?\"))
    ("'" . "'")
    ,(cons (make-string 3 ?') (make-string 3 ?'))
    ("`" . "`")
    ("{" . "}")
    ("[" . "]")
    ("<" . ">")
    ("<:" . ":>")
    ("*" . "*")
    ("`" . "'")
    ("" . ""))
  "Python mode's Parenthesizing pairs to try, in order.
See `dp-parenthesize-region-paren-list'")


(dp-add-mode-paren-list 'python-mode
                        dp-python-mode-parenthesize-region-paren-list)

(defun dp-python-mode-hook ()
  "Set up python *my* way."
  (interactive)
  ;; Python has a problem with my  `dp-fix-comments' function.
  (setq dp-il&md-dont-fix-comments-p t)
  (progn
    (filladapt-mode)
    (dmessage "Added filladapt-mode to python hook 2012-02-10T14:14:39"))
  (setq-ifnil dp-orig-python-tab-binding (key-binding (kbd "TAB")))
  (make-variable-buffer-local 'block-comment-start)
  (setq dp-insert-tempo-comment-func 'dp-py-insert-tempo-doxy-comment
        block-comment-start (concat py-block-comment-prefix " ")
        comment-start "# ")
  (define-key dp-Ccd-map [(control d)] 'dp-py-insert-tempo-doxy-comment)
  ;; They set this to "# " This makes doxygen comments ("##") not look like
  ;; Python comments.
  ;; ## forces comment to line up @ comment col.
  (setq comment-start "#")
  (local-set-key [tab] 'dp-python-indent-command)
  (local-set-key [(meta \;)] 'dp-py-indent-for-comment)
  (local-set-key [(meta ?`)] 'comint-previous-matching-input-from-input)
  (local-set-key "\C-p`" 'comint-previous-matching-input-from-input)
  (local-set-key [delete] 'dp-delete)
  (local-set-key "\C-z" 'dp-shell)
  (local-set-key [(control x) (control left)] 'py-beginning-of-def-or-class)
  (local-set-key [(meta left)] 'dp-beginning-of-def-or-class)
  (if (dp-xemacs-p)
      (local-set-key [(meta right)] 'py-end-of-def-or-class)
    (local-set-key [(meta right)] 'end-of-defun))
  (local-set-key [(meta return)] 'dp-py-open-newline)
  (local-set-key [(control meta ?p)] 'py-beginning-of-def-or-class)
  (local-set-key "\C-c!" 'dp-python-shell)
  (local-set-key [(meta s)] 'dp-py-insert-self?)
  (local-set-key [(meta q)] 'dp-fill-paragraph-or-region-with-no-prefix)
  (dp-add-line-too-long-font 'python-font-lock-keywords)
  (setq dp-cleanup-whitespace-p t)
  ;; @todo XXX conditionalize this properly
  ;; dp-trailing-whitespace-font-lock-element

  ;; !<@todo XXX Add this to a new file hook?
  (dp-auto-it?)

  ;;;;;;;;move to dp-flyspell (dp-flyspell-prog-mode)
  (message "python mode hook finished."))

;;CO; (defadvice py-end-of-def-or-class (before dp-py-eodoc activate)
;;CO;   "Make `py-end-of-def-or-class' leave the region active."
;;CO;   (dp-set-zmacs-region-stays t))

(defadvice py-end-of-def-or-class (around dp-py-end-of-def-or-class activate)
  "If preceeding command was `dp-beginning-of-def-or-class' do a go-back.
Otherwise business as usual.
Also leave the region active."
  (dp-set-zmacs-region-stays t)
  (if (eq last-command 'dp-beginning-of-def-or-class)
      (dp-pop-go-back)
    ad-do-it))

(defadvice ruby-end-of-block (around dp-ruby-end-block activate)
  "If preceeding command was `dp-beginning-of-def-or-class' do a go-back.
Otherwise business as usual.
Also leave the region active."
  (dp-set-zmacs-region-stays t)
  (if (eq last-command 'dp-beginning-of-def-or-class)
      (dp-pop-go-back)
    ad-do-it))
; the python indenter uses this on every indentation:
; TABS and <Enter>, etc?
; Way too many useless pushes.
; I use my version anyway
; (defadvice py-beginning-of-def-or-class (before dp-py-bodoc act)
;   (dmessage "ADVISED py-beginning-of-def-or-class")
;   (dp-push-go-back "advised py-beginning-of-def-or-class"))

(autoload 'eldoc-doc "eldoc" "Display function doc in echo area." t)

(defun dp-you-cant-save-you-silly (&optional force-inhibit-p quiet-p)
  "Too much SpongeBob! NIL --> can save; non-nil --> can't.
Arr... beware the hooks! "
  (interactive)
  (unless (and (buffer-file-name)
               (not (dp-save-inhibited-p))
               (not force-inhibit-p))
    (ding)
    (unless quiet-p
      (message
       "You can't save this buffer, you silly.  But you can write it with %s."
       (sorted-key-descriptions (where-is-internal 'write-file))))
    ;; You CAN'T save, silly.
    t))

(dp-set-mode-local-value 'dp-open-newline-func
                         'dp-lisp-interaction-mode-open-newline
                         'lisp-interaction-mode)

(defun dp-lisp-interaction-mode-open-newline (&optional arg)
  (interactive)
  (if (equal (or arg current-prefix-arg) 1)
      (progn
        (end-of-line)
        (eval-print-last-sexp)
        nil)
    t))

(defun dp-elisp-mode-common-hook (&optional lisp-mode-p)
  "Set up lisp interaction mode *MY* way."
  (interactive)
  ;; experiment to see if I like this.
  ;;(turn-on-eldoc-mode)  ; too intrusive
  (dp-local-set-keys
   '(
     [(control tab)] dp-lisp-completion-at-point
     [(meta backspace)] dp-delete-word-forward
     [(control ?/)] dp-elisp-eldoc-doc ;; eldoc on demand.
     [(control meta return)] (kb-lambda (end-of-line
					 (eval-print-last-sexp)))
     [(meta left)] dp-beginning-of-defun
     [(meta right)] dp-end-of-defun
     [(control meta x)] dp-eval-defun-or-region
     [(meta s)] dp-upcase-preceding-symbol
     [(control ?x) (meta space)] edebug-x-modify-breakpoint-wrapper
     [(control ?|)] edebug-x-modify-breakpoint-wrapper
     [(control ?x) space] rectangle-mark-mode
     ))
  ;; @todo XXX Change `:' syntax so that :keyword-prefix<M-/> will complete on prefix.
  ;; What the GDMFFF? Why the spaces?
  ;;   (setq comment-start "; "
  ;;         block-comment-start ";; ")
  )

(defun dp-lisp-interaction-mode-hook ()
  (dp-elisp-mode-common-hook)
  (unless (buffer-file-name)
    (dp-define-buffer-local-keys '([(control ?x) (control ?d) ?x] dp-eol-and-eval
                                   [(control meta ?j)] dp-eol-and-eval
                                   [(meta ?w)] dp-you-cant-save-you-silly)
                                 nil nil nil "dlimh"))
  (local-set-key [(meta space)] 'dp-id-select-thing)  ;fsf change.x was dp-select-thing.
  (local-set-key [(meta ?-)] 'dp-bury-or-kill-buffer))

(defvar dp-lisp-modes-parenthesize-region-paren-list
  '(("(" . ")")                         ; 0
    ("`" . "'")                         ; 1
    ("[" . "]")                         ; 2
    ("\"" . "\"")                       ; 3
    ("'" . "'")                         ; 4
    ("<:" . ":>")                       ; 5
    ("\\\\(" . "\\\\)")                 ; 6
    ("*" . "*")                         ; 7
    ;; Keep last
    ("" . "")                           ; ...last (Undoish)
    )
  "Lisp mode's Parenthesizing pairs to try, in order.
See `dp-parenthesize-region-paren-list'")

(dp-add-mode-paren-list 'emacs-lisp-mode
                        dp-lisp-modes-parenthesize-region-paren-list)
(dp-add-mode-paren-list 'lisp-interaction-mode
                        dp-lisp-modes-parenthesize-region-paren-list)

(defvar dp-perl-mode-parenthesize-region-paren-list
  '(("(" . ")")                         ; 0
    ("{" . "}")                         ; 1
    ("[" . "]")                         ; 3
    ("\"" . "\"")                       ; 4
    ("'" . "'")                         ; 5
    ("<:" . ":>")                       ; 6
    ("\\\\(" . "\\\\)")                 ; 7
    ("*" . "*")                         ; 8
    ("`" . "'")                         ; 9
    ("{\"" . "\"}")                     ; 2
    ;; Keep last
    ("" . "")                           ; ...last (Undoish)
    )
  "Perl mode's Parenthesizing pairs to try, in order.
See `dp-parenthesize-region-paren-list'")

(dp-add-mode-paren-list 'perl-mode
                        dp-perl-mode-parenthesize-region-paren-list)


(defun dp-emacs-lisp-mode-hook ()
  "Set up emacs lisp mode *MY* way."
  (dp-elisp-mode-common-hook)
  (dp-add-line-too-long-font 'lisp-font-lock-keywords-2 :buffer-local-p t))

(defvar dp-isearch-region-active-at-search-start-p nil
  "Remembers whether the region was active when isearch started.")
(defvar dp-isearch-region-beginning-at-search-start nil
  "Remembers mark in order to restore it if region was active when search started.")

(defun dp-copy-isearch-string-as-kill ()
  "Copy current value of `isearch-string' as kill."
  (interactive)
  (kill-new isearch-string))
(put 'dp-copy-isearch-string-as-kill isearch-continues t)

(defun dp-insert-isearch-string ()
  (interactive)
  (insert isearch-string))
(defalias 'diis 'dp-insert-isearch-string)

(defun dp-isearch-mode-hook ()
  "Save point on the go back stack and save the region activation status.
We use the region status in the mode-end hook so that we can use an
isearch while the region is active to locate the end of the region."
  (let ((is-mode-map isearch-mode-map))
    (dp-set-zmacs-region-stays t)
    (define-key is-mode-map [(meta ?')] 'dp-copy-isearch-string-as-kill)
    (define-key is-mode-map [(meta ?o)] (kb-lambda
                                            (kill-new isearch-string)))
    (define-key is-mode-map [(control \')] 'dp-isearch-yank-char)
    (define-key is-mode-map [(control ?.)] 'dp-isearch-yank-char)
    (define-key is-mode-map [(control ?p)] 'isearch-ring-retreat) ; Emacs
    (define-key is-mode-map [(meta ?p)] 'isearch-ring-retreat)	  ; XEmacs
    (define-key is-mode-map [(control ?n)] 'isearch-ring-advance)
    (define-key is-mode-map "\M-s\C-e" 'isearch-yank-kill)
    (define-key is-mode-map "\C-y" 'isearch-yank-line)
;;    (define-key is-mode-map [up] 'isearch-ring-retreat)

    (when (dp-mark-active-p)
      (setq dp-isearch-region-active-at-search-start-p t
	    dp-isearch-region-beginning-at-search-start (region-beginning)))
    ;; M-p is set to `dp-parenthesize-region' in `dp-minibuffer-setup-hook'.
    (define-key is-mode-map "\C-p" 'isearch-ring-retreat)
    (define-key is-mode-map "\C-n" 'isearch-ring-advance)
    (dp-push-go-back "dp-isearch-mode-hook"))
  (let ((map minibuffer-local-isearch-map))
    (define-key map [(meta ?')] 'dp-copy-char-to-minibuf)
    ;; Keep compatibility w/ other standard hist keys.
;;CO;     (define-key map [up] 'isearch-ring-retreat)
;;CO;     (define-key map [down] 'isearch-ring-advance)
    (if (dp-xemacs-p)
        (progn
          (define-key map [(control ?p)] 'isearch-ring-retreat)
          (define-key map [(control ?n)] 'isearch-ring-advance))
      (define-key map [(control ?p)] 'previous-history-element)
      (define-key map [(control ?n)] 'next-history-element)
      (define-key map "\M-s\C-e" 'isearch-yank-kill)
      (define-key map "\C-y" 'isearch-yank-line))))

;;
;; I went to a lot of trouble to do this, and the above talks about it a bit.
;; But it causes a problem when: begin marking; move around with mark active;
;; isearch; exit isearch mode This ends up with the region beginning at the
;; point where the isearch started. I can see that being useful in some
;; cases, but it is unexpected and surprising. The same effect can be gotten
;; by deactivating the mark, reactivating it and then doing the isearch.
(defun dp-isearch-mode-end-hook ()
  (when dp-isearch-region-active-at-search-start-p
    (setq dp-isearch-region-active-at-search-start-p nil)
    (dp-set-mark dp-isearch-region-beginning-at-search-start)
    (setq dp-isearch-region-beginning-at-search-start nil)))

(defun dp-help-mode-hook ()
  "Set up help-mode *my* way."
  (dp-local-set-keys
   '(
     [?f] describe-function-at-point
     [?F] find-function-at-point
     [(shift tab)] backward-button
     [kp-add] dp-kill-ring-save
     [(control ?/)] dp-elisp-eldoc-doc)))

(defun dp-hyper-apropos-mode-hook ()
  (interactive)
  (define-key hyper-apropos-help-map [tab] 'help-next-symbol)
  (local-set-key [tab] 'help-next-symbol)
  (local-set-key [?l] 'dp-grep-lisp-files) ; lgrep in x, but lgrep is used in fsf.
  (local-set-key [?p] 'hyper-apropos-last-help))

(defun dp-w3m-view-previous-page (&optional exit)
  (interactive "P")
  (dp-func-or-kill-buffer
   (function (lambda () (call-interactively 'w3m-view-previous-page)))
   'w3m-quit))

(defun dp-w3m-mode-hook ()
  "Set up w3m-mode my way."
  (interactive)
  ;; give us most of the normal movement keys.
  (local-set-key [(left)] 'backward-char-command)
  (local-set-key [(right)] 'forward-char-command)
  (local-set-key [(up)] 'previous-line)
  (local-set-key [(down)] 'next-line)
  (local-set-key [(meta ?-)] 'dp-w3m-view-previous-page)
  (local-set-key "l" 'w3m-view-previous-page)
  (local-set-key [(meta left)] 'w3m-view-previous-page)
  (local-set-key [(meta right)] 'w3m-view-next-page)
  (local-set-key [(meta ?.)] 'w3m-view-this-url)
  (local-set-key [(meta ?a)] 'dp-toggle-mark)
  (local-set-key [(meta ?A)] 'dp-mark-to-end-of-line)
  (local-set-key [(shift tab)] 'w3m-previous-anchor)
  (local-set-key [(iso-left-tab)] 'w3m-previous-anchor)

  (message "dp-w3m-mode-hook done.")
)

(defun dp-dired-setup-keys-hook ()
  "Setup dired's key binding *my* way."
  (local-set-key "r" 'dired-do-rename)
  (local-set-key "b" 'dp-dired-sudo-edit)
  (local-set-key [(control ?x) (control ?q)] 'wdired-change-to-wdired-mode)
  )

(defun dp-dired-mode-hook ()
  "Setup dired *my* way."
  (dp-toggle-truncate 1)
  (local-set-key [(meta ?e)] 'find-file-at-point)
  (local-set-key [(meta return)] 'dired-find-file-other-window)
  (local-set-key [down] 'dired-next-line)
  ;; This is a buffer local variable.
  ;; They don't seem to be regular expressions.
  (dp-add-list-to-list 'dired-omit-extensions
                     '(".pyc" ".pyo"))
  (setq case-fold-search t))

(defalias 'dir 'dired)

(defun dp-Info-last-key ()
  (interactive)
  (dp-func-or-kill-buffer 'Info-last))

(defun dp-Info-mode-hook ()
  (let ((info-top-func (if (dp-xemacs-p)
			   'Info-top
			 'Info-top-node)))
    (dp-define-local-keys `([(meta ?-)] dp-bury-or-kill-buffer
			    [(?/)] isearch-forward
			    [(shift tab)] Info-prev-reference
			    [(iso-left-tab)] Info-prev-reference
			    [?Q] Info-exit
			    [?D] Info-directory
			    [?d] ,info-top-func))))

(defvar dp-time-mail-has-dung nil
  "Flag saying bell has rung since new mail has arrived")

;;;(defcustom dp-mail-present-string "**[\\/]** "
(defcustom dp-mail-present-string "/\\/\\ "
  "Prepend this string to the window title when mail is present."
  :group 'dp-vars
  :type 'string)

(defun dp-display-time-hook ()
  (if (and mail
	   (not dp-time-mail-has-dung))
      ;; since this func is intended to beep, ensure the beeper is
      ;; on.
      ;; ??? Have var the visible-bell is set to here.
      ;; may want no beep
      ;; but since I did this so my laptop would beep
      ;; on new mail, set to nil it is.
      (let ((visible-bell nil))
	(ding)
	;;(dmessage "ding, t-ing dung")
	(setq dp-time-mail-has-dung t)
	(setq frame-title-format (concat dp-mail-present-string
					 dp-frame-title-format)))
    ;;(dmessage "%s-ing dung" mail)
    (setq dp-time-mail-has-dung mail)
    (setq frame-title-format
	  (if mail
	      (concat dp-mail-present-string dp-frame-title-format)
	    dp-frame-title-format))
    ))

(defadvice manual-entry (after dp-advised-manual-entry act)
  "Convert ANSI junk to faces.
Why is this necessary?  I've had grief with ANSI ever since I saw the ANSI
color stuff for comint buffers.  Which sucked because the different color
faces had different sizes."
  (let ((inhibit-read-only t))
    (ansi-color-apply-on-region (point-min) (point-max))))

(defun dp-Manual-follow-xref-at-point ()
  "Invoke `manual-entry' on the cross-reference at point."
  (interactive)
  (let* ((extent (car (extents-at (point) nil 'manual-entry)))
	 (expr (or (and extent
                        (or (get extent 'man) 'manual-entry))
                   'manual-entry)))
    (dp-push-go-back "dp-Manual-follow-xref-at-point")
    (if (symbolp expr)
        (call-interactively expr)
      (eval expr))))

(defvar dp-Manual-section-regexp "^[0-9_A-Z -]+\\(([0-9]+)\\s-+.*\\)?$"
  "Part of a cheesy to find a man page section.
@todo XXX do we want the (number), e.g. the title, to be included?
`\\[dp-beginning-of-buffer]' gets the job done with the possibility of a false
positive. ")


(defun dp-Manual-previous-section (num)
  "Go to the previous section (NAME, SYNOPSIS, etc)."
  (interactive "p")
  (let ((case-fold-search nil))
    (while (and (> num 0)
                (re-search-backward dp-Manual-section-regexp nil t))
      ;; prev puts us at the beginning of the section name which makes a next
      ;; go to the end of that section name. Equivalent for next/prev.
      ;; Moving one character in the "opposite" direction means that there
      ;; will be no match on the current line.
      (forward-char)
      (decf num))))

(defun dp-Manual-next-section (num)
  "Go to the next section (NAME, SYNOPSIS, etc)."
  (interactive "p")
  (let ((case-fold-search nil))
    (while (and (> num 0)
                (dp-re-search-forward dp-Manual-section-regexp nil t))
      (backward-char)
      (decf num))))

(defun dp-manual-mode-hook ()
  (define-key Manual-mode-map [(return)] 'dp-Manual-follow-xref-at-point)
  (define-key Manual-mode-map "\C-m" 'dp-Manual-follow-xref-at-point)
  (define-key Manual-mode-map [(meta left)] 'dp-Manual-previous-section)
  (define-key Manual-mode-map [(meta right)] 'dp-Manual-next-section)

  ;;(dp-define-buffer-local-keys '( [(return)] 'dp-Manual-follow-xref-at-point))
  (define-key Manual-mode-map "\M-." 'dp-Manual-follow-xref-at-point)
  (define-key Manual-mode-map "\M-," 'dp-pop-go-back))


;; dp-pch (command data) look for dp-pch on this-command.  This means we do
;; only one comparison so we don't bog down this hook.  Then we figure out
;; what to do based on the contents of the value of dp-pch's data.  This
;; then, will be about as expensive as the code would have been inside the
;; function we are pre-commanding.
;; use (put '<command-symbol> 'dp-{pre|post}-command-hook (list 'func
;; [func-args]))  (apply (car x) (cdr x))
(defsubst dp-pre/post-command-hook (hook-type)
  ;;(dmessage "%s:%s" hook-type this-command)
  ;;(if (eq 'find-function this-command) (dmessage("ff")))
;   (if (eq 'execute-extended-command this-command)
;       (dmessage "eec:%s:%s" this-command (get this-command hook-type)))
  (and this-command
       (symbolp this-command)
;        (dp-message-no-echo "*this-command: %s, get>%s<\n"
;                            this-command
;                            (get this-command hook-type))
       ;; Most commands won't have functions attached.
       (get this-command hook-type)
;       (dp-message-no-echo "YOPP!\n")
       ;; If there is a function attached, then the double `get's probably
       ;; won't have a significant impact timewise compared to the function
       ;; called. Probably.
       (let ((dp-data (get this-command hook-type)))
         ;;(dp-message-no-echo "*******dp-data>%s<\n" dp-data)
         (and (car dp-data)
              (apply (car dp-data) (cdr dp-data))))))

(defun dp-pre-command-hook ()
  ;;(dmessage "this-command>%s<" this-command)
  ;;(if (eq 'find-function this-command) (dmessage "find-function"))
  ;;(if (eq 'ff this-command) (dmessage "ff"))
  (dp-pre/post-command-hook 'dp-pre-command-hook))

(defun dp-post-command-hook ()
  (dp-pre/post-command-hook 'dp-post-command-hook))

;;;(add-hook 'pre-command-hook 'dp-pre-command-hook)
;;;(add-hook 'post-command-hook 'dp-post-command-hook)

(dp-deflocal dp-server-done-function (lambda (&rest ignored)
				       (bury-buffer nil))
  "What shall we do when we are done editing a gnuserv file?
Default is to switch to a buffer as chosen by `switch-to-buffer'.")

;;; This needs to be made FSF/XEmacs compatible.
(defun dp-server-edit (&optional count keep-buffer-p)
  "Like `gnuserv-edit''`server-edit' except leaves buffer alone rather than killing it.
\\[universal-argument] eq `-' or non-nil KEEP-BUFFER-P means to kill the
buffer.
WTF did I do this? I think it had to do with IPython edit buffers.
In a later version of IPython (1.1.0), the file name is formatted thus:
/tmp/ipython_edit_<rand-junk>"
  (interactive "P")
  (let ((server-done-function dp-server-done-function))
    (if (not (or keep-buffer-p (Cu--p)))
        ;; Kill
        (setq current-prefix-arg nil
              server-done-function 'dp-maybe-kill-buffer)
      (if (and (numberp count)
               (< 0 count))
          ;; Kill count
          (setq current-prefix-arg (abs count)
            server-done-function 'dp-maybe-kill-buffer)))
    (call-interactively
     (if (dp-xemacs-p)
	 'gnuserv-edit
       'server-edit))
    (message "Editing complete.")))

(defun dp-gnuserv-edit-kill-buffer (&optional count)
  (interactive)
  (dp-gnuserv-done-function count 'kill-buffer-p))

;;(defun dp-gnuserv-edit-and-kill (&optional count))

(defun dp-gnuserv-find-file-function (path)
  "Called when gnuserv edits a file.
This could be done with advice, but advice should be avoided if another
solution exists. In this case, the `gnuserv-find-file-function' variable."
  (interactive "fFile: ")
  ;; gnuserv unconditionally goes to the line in the message.
  ;; Makes sense, except when the file is already being edited.
  ;; So, if the file is already in a buffer, then we push a go-back
  (let ((visited-p (get-file-buffer path)))
    (dp-find-file path)
    (when visited-p
      (dp-push-go-back "gnuserv visiting an already visited file"))))

(setq gnuserv-find-file-function 'dp-gnuserv-find-file-function)

(if (dp-xemacs-p)
    (add-hook 'gnuserv-visit-hook 'dp-server-visit-hook)
  (add-hook 'server-visit-hook 'dp-server-visit-hook))

(defun dp-server-visit-hook ()
  (interactive)
  (let ((file-name (buffer-file-name)))
    ;; Warn if we're serving a temp file that is empty.  When working as a
    ;; server, the file needs to be in a common file system between the
    ;; client and server. Things which like to edit temp files in temp dirs
    ;; don't work.
    (when (and file-name
               (not (dp-match-a-regexp file-name dp-known-temp-file-re-list))
               (string-match "/te?mp/" file-name)
               (equal (point-min) (point-max)))
      (dp-ding-and-message "Empty file. Could be a remote temp file.")))
  (switch-to-buffer (current-buffer))
  ;; (dp-raise-and-focus-frame)
  (local-set-key "\C-c\C-c" 'dp-server-edit))

(defun dp-grep-setup-hook ()
  (dp-local-set-keys
   '([(control ?o)] dp-one-window++
     [?o] compilation-display-error
     )))

;;; Wishful thinking.
;;;(add-hook 'grep-setup-hook 'dp-grep-setup-hook)

(when (dp-optionally-require 'igrep)
  (defadvice igrep (after dp-igrep activate)
    "Do a `dp-push-go-back' before we visit the matches returned by `igrep'.
 Before visiting means after the command completes because the sequence is:
 1) igrep
 2) examine list
 3) M-n for next match or goto a match by hand.
 This means pushing a go back works after the command is just fine.
 If we did it before, then an error in igrep would leave a kind of useless
 place on the go back stack.
 Wow: That's over commenting."
    (dp-push-go-back "advised igrep"))

  (defvar dp-orig-igrep-regex-default igrep-regex-default
    "Original value of `igrep-regex-default'.")

  (defalias 'ig 'igrep)			; Just think of the savings!

  (igrep-define zgrep)			; M-x zgrep
  (igrep-find-define zgrep)		; M-x zgrep-find

  (setq igrep-regex-default
	(function
	 (lambda ()
	   (dp-get--as-string--region-or...
	    :gettor dp-orig-igrep-regex-default))))

  (put 'igrep-files-default 'c-mode
       (lambda () "*.[ch]"))
  )					; End of `dp-optionally-require'.

(defadvice grep (after dp-grep activate)
  "Do a dp-push-go-back before we go finding the matches returned by `grep'.
Before visiting means after this command completes."
  (dp-set-compile-like-mode-error-function)
  (dp-push-go-back "advised grep"))

(defvar dp-bind-xcscope-fkeys-p t
  "Pretty self-explanatory?")

(defvar dp-bind-xcscope-keys-p t
  "Pretty self-explanatory?")

(defun* dp-default-make-cscope-database-regexps-fun (&optional
                                                     ignore-env-p
                                                     db-locations
                                                     (hierarchical-search-p t))
  "Set a default value for `cscope-database-regexps'.
This sets the value that will cause cscope to (in the words of cscope):
  \"In the case of \"( t )\", this specifies that the search is to use the
  normal hierarchical database search.  This option is used to
  explicitly search using the hierarchical database search either before
  or after other cscope database directories.\""
  '(("^/" (t))))

(defvar dp-make-cscope-database-regexps-fun
  'dp-default-make-cscope-database-regexps-fun
  "Call this to generate an appropriate value for
  `cscope-database-regexps'(q.v.)")

(defvar dp-cscope-memoized-cscope-database-regexps 'unset
  "Memoized copy of our value for `cscope-database-regexps.
Use of 'unset allows the legitimate value of nil to be used.")

(defun* dp-cscope-set-cscope-database-regexps (&optional
                                               non-memoized-p
                                               ignore-env-p
                                               db-locations
                                               (hierarchical-search-p t))
  (interactive "P")
  (setq cscope-database-regexps
        (if (or (eq dp-cscope-memoized-cscope-database-regexps 'unset)
                non-memoized-p)
            (funcall dp-make-cscope-database-regexps-fun
                     ignore-env-p
                     db-locations
                     hierarchical-search-p)
          dp-cscope-memoized-cscope-database-regexps)
        dp-cscope-memoized-cscope-database-regexps cscope-database-regexps))

;; Set a default if needed.
;; @todo XXX Should this be unconditional?
;; We can use `dp-cscope-set-cscope-database-regexps' for that.
(setq-if-unbound cscope-database-regexps
                 (funcall dp-make-cscope-database-regexps-fun))

(defadvice recover-file (before dp-recover-file-with-default activate)
  "Use current buffer's file name as a default.
NB: FSF has a function named `recover-this-file' which does this,
but this works in both FSF and X, and I prefer the way I did it.
So there."
  (interactive (list (read-buffer "Recover file: " (buffer-file-name)))))

(dp-deflocal dp-query-kill-buffer-p nil
  "If non-nil ask before killing this buffer.")

(defun* dp-kill-buffer-query-function (&optional arg)
  "Return non-nil if it is OK to kill this buffer."
  ;; Allow param to override any global/buffer-local value.
  (setq-ifnil arg dp-query-kill-buffer-p)
  (interactive)
  (if (bound-and-true-p dp-query-kill-buffer-p)
      (let (prompt)
        (cond
         ((functionp dp-query-kill-buffer-p)
          (return-from dp-kill-buffer-query-function
            (funcall dp-query-kill-buffer-p)))
         ((stringp dp-query-kill-buffer-p)
          (setq prompt dp-query-kill-buffer-p))
         (t (setq prompt "Really kill this buffer?")))
        (when prompt
          (y-or-n-p prompt)))
    ;; Nothing special... killing is OK.
    t))

(defun dp-set-buffer-kill-query (&optional arg)
  "Flag current buffer so that attempts to kill it require confirmation."
  (interactive "P")
  (if arg
      (setq dp-query-kill-buffer-p arg)
    (dp-toggle-var arg 'dp-query-kill-buffer-p)))

;; @todo ecb debugging
;;;;(add-hook 'kill-buffer-query-functions 'dp-kill-buffer-query-function)

(defadvice compile-internal (around dp-advised-compile-internal activate)
;  (when (eq major-mode 'compilation-mode)
;     (set-window-dedicated-p (dp-get-buffer-window) nil))
;   (when (dp-buffer-live-p compilation-last-buffer)
;     (set-window-dedicated-p (dp-get-buffer-window compilation-last-buffer) nil))
  (dp-set-compile-like-mode-error-function)
  ad-do-it
;   (when (dp-buffer-live-p compilation-last-buffer)
;     (set-window-dedicated-p (dp-get-buffer-window compilation-last-buffer) t))
  )

;;
;; @todo @todo @todo @todo @todo @todo
;; make into a function of my own
;;


(defadvice undo (around dp-advised-undo (&optional count) activate)
  "Allow a single C-- to mean `undo-all-changes'."
  (interactive "*p")
  ;; Use \C-- as our flag since it isn't useful as a count for the real
  ;; `undo'."
  (if (Cu--p nil current-prefix-arg)
      (call-interactively 'undo-all-changes)
    ad-do-it))

;!needed for FSF (defun dp-prefer-horizontal-split ()
;!needed for FSF   "Determine if we want a horizontal split when just `split' is requested."
;!needed for FSF   t)

;!needed for FSF (defvar dp-called-by-split-vertically nil
;!needed for FSF   "Icky hack to allow `split-window-vertically' to work.")

;!needed for FSF (defvar dp-called-by-split-horizontally nil
;!needed for FSF   "Icky hack to allow `split-window-horizontally' to work.")

;!needed for FSF (defadvice split-window (before dp-advised-split-window
;!needed for FSF                          (&optional window size horflag) activate)
;!needed for FSF   (interactive)
;!needed for FSF   ;; Set `horflag' on a per-call basis so it can change dynamically.
;!needed for FSF   ;; Only calculate this if we're called as `split-window' itself.
;!needed for FSF   (if (not
;!needed for FSF        (or dp-called-by-split-horizontally dp-called-by-split-vertically))
;!needed for FSF       (setq horflag (and (dp-prefer-horizontal-split)
;!needed for FSF                          (not (active-minibuffer-window))
;!needed for FSF                          (not (dp-tall-enough-for-2-windows-p))
;!needed for FSF                          (dp-wide-enough-for-2-windows-p)
;!needed for FSF                          (= (length (dp-window-list)) 1)
;!needed for FSF                          (not size)     ; Skip action if a size is specified.
;!needed for FSF                          (not dp-called-by-split-vertically)))
;!needed for FSF     (setq dp-called-by-split-vertically nil
;!needed for FSF           dp-called-by-split-horizontally nil)))

;!needed for FSF (defadvice split-window-vertically (before
;!needed for FSF                                     dp-advised-split-window-vertically
;!needed for FSF                                     (&optional arg)
;!needed for FSF                                     activate)
;!needed for FSF   (interactive "P")
;!needed for FSF   (setq dp-called-by-split-vertically t))

;!needed for FSF (defadvice split-window-horizontally (before
;!needed for FSF                                     dp-advised-split-window-horizontally
;!needed for FSF                                     (&optional arg)
;!needed for FSF                                     activate)
;!needed for FSF   (interactive "P")
;!needed for FSF   (setq dp-called-by-split-horizontally t))

(make-variable-buffer-local 'dp-allow-owner-to-eval-p)
(setq-default dp-allow-owner-to-eval-p t)

(defadvice hack-one-local-variable (before dp-hack-one-local-variable activate)
  ;; Allow user to eval things from their own files w/o asking.
  (unless enable-local-eval
    (setq enable-local-eval (and dp-allow-owner-to-eval-p
				 (dp-user-owns-this-file-p (buffer-file-name))))
    (when enable-local-eval
      (message "Allowing file's owner to auto eval Local Variables."))))
; (defadvice eval-defun (around dp-eval-defun activate)
;   (dmessage "this-command>%s<" this-command)
;   (if (and (nCu-p)
;             (not (eq this-command 'eval-defun))
;       (eval-defun nil))
;     ad-do-it))


(dp-deflocal-permanent dp-advise-confirm-frame-deletion-p t
  "Should we advise delete frame to possibly ask for confirmation before
  deleting the frame?")

(dp-deflocal-permanent dp-confirm-frame-deletion-p t
  "Should our advised delete frame ask for confirmation before deleting the
  frame?")

;; (when-and-boundp 'dp-advise-confirm-frame-deletion-p
;;   (defadvice delete-frame (around dp-advised-delete-frame activate)
;;     "Ask the user if they really meant to delete the frame rather than change to another."
;;     ;; Twice in a row actually does it.
;;     (if (or (nCu-p) (eq last-command 'delete-frame))
;;         ad-do-it
;;       ;; Not second in a row, so ask the user really wanted to do an
;;       ;; `other-frame'.
;;       (if (and dp-confirm-frame-deletion-p
;;                (or (< (dp-primary-frame-width) dp-2w-frame-width)
;;                                         ;Try to catch special frames like ediff control frame and
;;                                         ;speedbar.  We may want to check a list of frame name
;;                                         ;regexps, too.
;;                    (< (frame-width) 80)
;;                    (dp-primary-frame-p))
;;                (y-or-n-p "Did you mean to do `other-frame'? "))
;;           (progn
;;             (setq this-command 'other-frame)
;;             (call-interactively 'other-frame))
;;         ad-do-it))))

;;; Used by way too many commands to be advised.
(defun dp-beginning-of-defun (&optional arg)
  "If preceeding command was `end-of-defun' do a go-back.
Otherwise push-go-back and then business as usual.
In all cases maintain region activation."
  (interactive "p")
  (dp-set-zmacs-region-stays t)
  (if (eq last-command 'dp-end-of-defun)
      (progn
        (dp-pop-go-back)
        (setq this-command nil))
    (dp-push-go-back "`dp-beginning-of-defun'")
    (call-interactively 'beginning-of-defun)))

(defun dp-end-of-defun (&optional arg)
  "If preceeding command was `end-of-defun' do a go-back.
Otherwise maintain region activation, push-go-back
and then business as usual."
  (interactive "p")
  (dp-set-zmacs-region-stays t)
  (if (eq last-command 'dp-beginning-of-defun)
      (progn
        (dp-pop-go-back)
        (setq this-command nil))
    (dp-push-go-back "`dp-end-of-defun'")
    (call-interactively 'end-of-defun)))

(defun dp-compilation-start-hook (&optional proc)
  "Setup error handling when compile start. PROC is always passed.
It was made optional so it can be M-x 'd if \(eq when) things get hosed."
  (interactive)
  (dp-set-compile-like-mode-error-function))

(defun dp-sh-mode-hook ()
  "Hook for shell script editing."
  (interactive)
  (local-set-key [(meta left)] 'beginning-of-defun)
  (setq dp-cleanup-whitespace-p t)
  (dp-add-line-too-long-font '(sh-font-lock-keywords
                               sh-font-lock-keywords-1
                               sh-font-lock-keywords-2))
  ;; Add trailing WS visibility only on highest font lock level?
  (dp-auto-it?))

(defadvice fill-paragraph-or-region (around dp-fill-paragraph-or-region
                                     activate)
  "Allow prefix args C-0 or C-- to limit filling to the current line and below."
  (let ((current-prefix-arg current-prefix-arg))
    (if (not (Cu-memq '(- 0)))
        ad-do-it
      (setq current-prefix-arg nil)
      (save-restriction
        (narrow-to-region (line-beginning-position) (point-max))
        ad-do-it))))

;(defadvice set-window-buffer (around dp-maybe-hightlight-point activate)
;    "Highlight point in the new buffer to make it easier to locate."
;    (when (and-boundp 'dp-highlight-in-set-buffer
;            dp-highlight-in-other-buffer)
;      (dp-unhighlight-point))
;
;    ad-do-it
;
;    (when (and-boundp 'dp-highlight-in-set-buffer
;            dp-highlight-in-set-buffer)
;      (dp-highlight-point-until-next-command)
;      (setq this-command 'dp-highlight-point-until-next-command)))



(defstruct dp-position-info
  window
  buffer
)

(defvar dp-pre-cmd-window nil
  "Active window when command starts.")
(defvar dp-pre-cmd-buffer nil
  "Active buffer when command starts.")
(defvar dp-post-cmd-window nil
  "Active window when command finishes.")
(defvar dp-post-cmd-buffer nil
  "Active buffer when command finishes.")

;;!<@todo Does this really make sense?
(defun dp-highlight-window-excluded-p (window)
  (and nil
       (dp-match-window-buffer (dp-regexp-concat dp-highlight-excluded-buffers))))

(defvar dp-highlight-buffer-excluded-enabled-p t
  "*Determines whether we want to use the buffer exclusion code.")

(defun dp-highlight-buffer-excluded-p (buffer)
  (when dp-highlight-buffer-excluded-enabled-p
    (dp-match-buffer-name (dp-regexp-concat dp-highlight-excluded-buffers)
                          nil buffer)))

(defconst dp-center-line-on-window-change-p 't-for-now-to-see-if-I-like-it)

(defsubst dp-pre/post-highlight-helper (this that &optional pre post)
  ;; Being in the same window, and hence doing nothing is orders of orders of
  ;; magnitude more common than other conditions.  So check it early and
  ;; quickly, even tho using repeated code.
  (if (and (eq (dp-get-buffer-window (current-buffer))
               (symbol-value that))
           ;; More function calls... but it is better because we don't muck
           ;; with storage and increase the need for gc because we keep
           ;; overwriting *this.  But we are dealing with the same object
           ;; (hence `eq') so gc may be irrelevant.
           (not (eq (dp-get-buffer-window (current-buffer))
                    (symbol-value this))))
      (set this (dp-get-buffer-window (current-buffer)))
    (let* ((this-buf (current-buffer))
           (this-win (dp-get-buffer-window this-buf))
           (excluded-p (and dp-highlight-buffer-excluded-enabled-p
                            (or (dp-highlight-window-excluded-p this-win)
                                (dp-highlight-buffer-excluded-p this-buf)))))

      ;;{{{ Dead but possibly useful debugging code
;       (when (and nil
;                  (not (memq this-command '(self-insert-command other-window
;                                            next-line previous-line
;                                            isearch-forward isearch-backward
;                                            scroll-up-command scroll-down-command
;                                            dp-end-of-buffer
;                                            dp-beginning-of-buffer
;                                            dp-open-newline newline
;                                            forward-word backward-word
;                                            dp-scroll-up dp-scroll-down
;                                            end-of-buffer-other-window
;                                            forward-char-command
;                                            backward-char-command
;                                            delete-backward-char
;                                            execute-extended-command))))
;         (if pre
;             (dp-message-no-echo "%s" pre))
;         (dp-message-no-echo "cmd: %s\nthis: %s, that: %s\n*this: %s\n*that: %s\n"
;                             this-command
;                             this that (symbol-value this) (symbol-value that))
;         (if post
;             (dp-message-no-echo "%s" post)))
      ;;}}}

      ;;  (dmessage "this: %s, that: %s" (symbol-value this) (symbol-value that))
      ;; If the current window has changed and it's not a "forbidden" window and
      ;; not a "forbidden" buffer, then highlight it.
      (unless excluded-p
        (set this this-win))
      (unless (or (eq this-win (symbol-value that))
                  excluded-p)
        ;; Do the new window actions:
        ;;(dmessage "HIGH: this-win: %s, that: %s" this-win (symbol-value that))
        (when dp-center-line-on-window-change-p

          )
        (dp-highlight-point-until-next-command
         :colors dp-highlight-point-other-window-faces)))))

(defun dp-pre-cmd-for-highlight-hook ()
  "Called to help out the highlighting the current line when changing windows."
  (dp-pre/post-highlight-helper 'dp-pre-cmd-window 'dp-post-cmd-window
                                "vvvvvvv pre-command-hook =======\n"))

(defun dp-post-cmd-for-highlight-hook ()
  "Called to help out the highlighting the current line when changing windows."
  (dp-pre/post-highlight-helper 'dp-post-cmd-window 'dp-pre-cmd-window nil
                                "^^^^^^^ post-command-hook =======\n"))

;; Old highlight code in vc.

;;;
;;; I've added a function and a key binding for it in minibuffer-mode that
;;; allows one to yank the region (if active) otherwise the
;;; `symbol-near-point'.  This shouldn't cause as many complications as the
;;; advice can.
; (defvar dp-use-region-as-INITIAL-CONTENTS t
;   "*If non-nil, then use region, if active, as `read-from-minibuffer's initia-contents, if not specified.")

; (defadvice read-from-minibuffer (before dp-advised-read-from-minibuffer
;                                  activate)
;     (when (and dp-use-region-as-INITIAL-CONTENTS
;                (not (and (symbolp this-command)
;                          (get this-command
;                               'dp-DONT-use-region-as-INITIAL-CONTENTS)))
;                ;;(not (eq this-command 'execute-extended-command))
;                (not (ad-get-arg 1))
;                (dp-mark-active-p))
;       (ad-set-arg 1 (cons (buffer-substring (mark) (point))
;                           (abs (- (mark) (point)))))))

; ;;!<@todo We may want to change the sense of this if there are more commands
; ;;that don't want this than do.
; (put 'execute-extended-command 'dp-DONT-use-region-as-INITIAL-CONTENTS t)
; (put 'sort-regexp-fields 'dp-DONT-use-region-as-INITIAL-CONTENTS t)

;;;
;;; Hacks to make calc work a little nicer under XEmacs.
;;; it uses some Emacs only functions.  I've faked them
;;; *very* crudely, but functionally.

;; Gotta pull this in so we're defined *after* they are.
(require 'calc)

(if (dp-xemacs-p)
    (defun window-edges (&rest who-cares?)
      ))

(defun calc-delete-windows-keep (&rest bufs)
  (dp-pop-window-configuration))

(defadvice calc (before dp-calc activate)
  (dp-push-window-configuration))

(defadvice describe-variable (around dp-desc-var activate)
  (if (Cu-memq '(0 -))
      (dp-show-variable-value (ad-get-arg 0))
    ad-do-it))

(when (dp-xemacs-p)
  (defadvice set-frame-width (before dp-advised-set-frame-width activate)
    ;; 4 from "M-x "
    (setq icomplete-prospects-length (-(frame-width) 4))))

(when (fboundp 'savehist-autosave)
  (defadvice savehist-autosave (around dp-savehist-autosave activate)
    ;; debug-on-error breaks things since it is called in spite of the
    ;; unwind-protect inside of the savehist worker function.  Strange since
    ;; simple test code shows unwind-protect prevents debug-on-error from
    ;; entering the debugger.  So lets just turn it off.
    ;; 'praps due to hook context?
    (condition-case appease-byte-compiler
        (let ((debug-on-error nil))
          ad-do-it)
      (dmessage "savehist-autosave barfed... imagine that.")
      nil)))

(defadvice hyper-apropos-find-function (before dp-hyper-apropos-find-function
                                        activate)
  (dp-push-go-back "hyper-apropos-find-function" nil 'allow-dammit-p))

(defadvice hyper-apropos-find-variable (before dp-hyper-apropos-find-function
                                        activate)
  (dp-push-go-back "hyper-apropos-find-variable" nil 'allow-dammit-p))

(defun dp-outline-open-newline (&rest not-used)
  (end-of-line)
  (newline)
  (beginning-of-line)
  (indent-relative)
  nil)
;;  (dp-dupe-chars-prev-line 1 'word))

(defun dp-outline-hook ()
  (dp-set-mode-local-value 'dp-open-newline-func 'dp-outline-open-newline
                           'outline-mode)
  (local-set-key [(meta left)] 'outline-previous-visible-heading)
  (local-set-key [(meta right)] 'outline-next-visible-heading)
  (local-set-key [(control meta left)] 'outline-up-heading)
  (local-set-key [(control meta right)] 'outline-forward-same-level)

  (filladapt-mode 1)
  (make-local-variable 'indent-line-function)
  (setq indent-line-function 'indent-relative))

;;(require 'dp-perforce)

(defadvice cperl-electric-delete (around perl-crap activate)
  (if (dp-region-active-p)
      (delete-region (mark) (point))
    ad-do-it))

(defun dp-diff-mode-hook ()
  (interactive)
  ;; Put 'diff-goto-source on C-xM-e
  ;; It's on M-o and that will NOT do.
  ;; set C-xM-e to what was on M-o
  ;; M-e is open file, so it's kind of mnemonic.
  (dp-bump-key-binding [(meta ?o)]
                       'dp-kill-ring-save [(control ?x) (meta e)])
  (dp-local-set-keys
   '([(meta -)] dp-maybe-kill-this-buffer
     [?v] dp-diff-mode-goto-vc-dir)))

(defun dp-revert-hook ()
  ;; Remove existing colorization. We may want to have a "permanent" flag
  ;; saying that these extents should survive a reversion.
  (dp-uncolorize-region (point-min) (point-max)))

(defun dp-after-revert-hook  ()
  "FUCK! This isn't called if the file hasn't changed.
I want to use it to, at least, change colorization if the file has become
writable. And if going from RO --> R/W, the file is unlikely to have
changed."
  (interactive)
  (dp-revert-hook)
  (dp-colorize-found-file-buffer))

(defun dp-before-revert-hook ()
  "This is called even if the file hasn't changed."
  (interactive)
  (dp-revert-hook)
  (dp-colorize-found-file-buffer))

(defun dp-revert-buffer (&rest revert-buffer-args)
  (interactive)
  (call-interactively 'revert-buffer)
  ;; XXX @todo some of this will be called twice. That's better than being
  ;; called 0 times, but it needs correcting.
  (dp-revert-hook)
  (dp-after-revert-hook)
  ;; May want to put this in a more common place like one of the dp-revert
  ;; hooks.
  (dp-set-auto-mode))

;; Dum, dee, dum, dum, dada, do, dum... PERL SUCKS! dee, dum, dum...
(defun dp-cperl-mode-hook ()
  (message "Sigh. :-( Boo fucking hoo,  In cp-perl-mode-hook.")
  (setq dp-il&md-dont-fix-comments-p t) ; cperl sucks at this.
  (substitute-key-definition 'cperl-indent-for-comment
                             'dp-cperl-indent-comments-fucking-correctly
                             cperl-mode-map)
  (dp-add-line-too-long-font '(perl-font-lock-keywords
                               perl-font-lock-keywords-1
                               perl-font-lock-keywords-2))
  (setq dp-cleanup-whitespace-p t))

(defun dp-first-change-hook ()
  (dmessage "in dp-first-change-hook"))

;; All kinds of things change, like minibuf, temp files, message buffer, etc.
;; Definitely make this a local hook.
(defun dp-before-change-function (beg end)
  (dmessage "in dp-before-change-function, buf: %s, beg: %s, end: %s"
            (buffer-name) beg end))

(defun dp-bookmark-bmenu-mode-hook ()
  (dp-define-local-keys
   '(
     [return] bookmark-bmenu-other-window
     [?.] bookmark-bmenu-this-window
     [?v] bookmark-bmenu-switch-other-window
     [?w] dp-bookmark-bmenu-locate
     [(control ?o)] (kb-lambda
			(dp-one-window++ -1)
			(bookmark-bmenu-select))))
  )

(defun dp-bookmark-load-hook ()
  (global-set-key [(control ?c) ?b] 'bookmark-map)
  ;; C-cbb is easy typin', right Sarah?
  (dp-define-local-keys
   '([?b] bookmark-set
     ;; This is more betterer.
     ;;    <big-gold-letters>"I have the best words.</big-gold-letters>"
     ;; -- DD (aka) DT
     [?f] dp-bookmark-insert-location)))

(defun dp-asm-mode-hook()
  (interactive)
  (setq comment-start "@"
        comment-end ""
        block-comment-start "/* "
        block-comment-end "*/"))

(defadvice jka-compr-insert-file-contents
  (after dp-advised-jka-compr-insert-file-contents act)
  (dp-set-unmodified))

(defun dp-ibuffer-bind-keys ()
  (interactive)
  (dp-local-set-keys
   '([(meta ?w)] dp-ibuffer-do-save
     [(up)] ibuffer-backward-line
     [(down)] ibuffer-forward-line)
   ))

(defun dp-ibuffer-hook ()
  (interactive)
  (dp-ibuffer-bind-keys))

(defun dp-ibuffer-mode-hook ()
  (interactive)
  (ibuffer-switch-to-saved-filter-groups "dp-ibuffer-saved-filter[0]"))

(defun dp-icomplete-minibuffer-setup-hook ()
  (dp-define-local-keys
   '(
     [(meta return)] icomplete-force-complete-and-exit
     [(meta ?m)] minibuffer-force-complete)))

;; FSF apropos, sucks massively compared to XEmacs' hyper-apropos.
(defun dp-apropos-mode-hook ()
  (dp-define-local-keys
   '(
     [?v] dp-find-variable-other-window
     [?f] dp-find-function-other-window
     [?V] dp-find-variable
     [?F] dp-find-function
     [?a] apropos-command
     [?l] dp-grep-lisp-files)))

(defun dp-vc-dir-mode-hook ()
  (dp-define-local-keys
   '(
     [(control down)] dp-scroll-up
     [(control up)] dp-scroll-down
     [(control ?o)] dp-one-window++
     [?/] dp-vc-dir-find-next-edited
     [?.] dp-vc-dir-find-next-edited)))

(defun dp-Custom-mode-hook ()
  (interactive)
  (dp-define-local-keys
   '(
     [?l] Custom-buffer-done
     )))

;; <:add hook functions here aka hooks:>
;; I'm trending away from advice, since I've seen code that really rapes it
;; (I'm looking at you, ECB)
;;CO; (defadvice find-function-on-key (before dp-find-function-on-key activate)
;;CO;   (dp-push-go-back "find-function-on-key"))

;; Moved from dpmacs.el. They were grouped like this right after dp-hooks was
;; required.  They belong here.
(add-hook 'bookmark-bmenu-mode-hook 'dp-bookmark-bmenu-mode-hook)
(add-hook 'comint-mode-hook 'dp-comint-mode-hook)
(add-hook 'shell-mode-hook 'dp-shell-mode-hook)
(add-hook 'telnet-mode-hook 'dp-telnet-mode-hook)
(add-hook 'pike-mode-hook 'dp-pike-mode-hook)
(add-hook 'python-mode-hook 'dp-python-mode-hook)
(add-hook 'gdb-mode-hook 'dp-gdb-mode-hook)
(add-hook 'ssh-mode-hook 'dp-ssh-mode-hook)
(add-hook 'ruby-mode-hook 'dp-ruby-mode-hook)
(add-hook 'cperl-mode-hook 'dp-cperl-mode-hook)
(add-hook 'find-function-after-hook 'dp-find-function-after-hook)
(add-hook 'outline-mode-hook 'dp-outline-hook)
(add-hook 'diff-mode-hook 'dp-diff-mode-hook)
(add-hook 'vc-checkout-hook 'dp-set-auto-mode)
(add-hook 'after-revert-hook 'dp-after-revert-hook)
(when (functionp 'vc-find-file-hook)
  (add-hook 'after-revert-hook 'vc-find-file-hook))
(add-hook 'before-revert-hook 'dp-before-revert-hook)
;;
;; run-lisp sets the keymap *after* entering comint-mode and before
;; inferior-lisp-mode-hook is run, so we run the hook again
;; to get our keys
(add-hook 'inferior-lisp-mode-hook 'dp-comint-mode-hook)
(add-hook 'lisp-interaction-mode-hook 'dp-lisp-interaction-mode-hook)
(add-hook 'emacs-lisp-mode-hook 'dp-emacs-lisp-mode-hook)
(add-hook 'minibuffer-setup-hook 'dp-minibuffer-setup-hook)
(add-hook 'c-mode-common-hook 'dp-c-like-mode-common-hook)
(add-hook 'c++-mode-hook 'dp-c++-mode-hook)
(add-hook 'buffer-menu-mode-hook 'dp-buffer-menu-mode-hook)
(add-hook 'text-mode-hook 'dp-text-mode-hook)
(add-hook 'help-mode-hook 'dp-help-mode-hook)
(add-hook 'hyper-apropos-mode-hook 'dp-hyper-apropos-mode-hook)
(add-hook 'dired-setup-keys-hook 'dp-dired-setup-keys-hook)
(add-hook 'dired-mode-hook 'dp-dired-mode-hook)
(add-hook 'Info-mode-hook 'dp-Info-mode-hook)
(add-hook 'Manual-mode-hook 'dp-manual-mode-hook)
(add-hook 'sh-mode-hook 'dp-sh-mode-hook)
(add-hook 'asm-mode-hook 'dp-asm-mode-hook)
(add-hook 'ibuffer-hook 'dp-ibuffer-hook)
(add-hook 'ibuffer-mode-hook 'dp-ibuffer-mode-hook)
(add-hook 'compilation-start-hook 'dp-compilation-start-hook)
(add-hook 'icomplete-minibuffer-setup-hook 'dp-icomplete-minibuffer-setup-hook)
(add-hook 'magit-mode-setup-hook 'dp-magit-mode-setup-hook)
(add-hook 'apropos-mode-hook 'dp-apropos-mode-hook)
(add-hook 'vc-dir-mode-hook 'dp-vc-dir-mode-hook)
(add-hook 'mu4e-view-mode-hook 'dp-mu4e-view-mode-hook)
(add-hook 'mu4e-headers-mode-hook 'dp-mu4e-headers-mode-hook)
(add-hook 'Custom-mode-hook 'dp-Custom-mode-hook)

;; <:add-new-`add-hooks'-up-there:>
;; put new hooks up there ^

(provide 'dp-hooks)
(message "dp-hooks loading...done")

;;
;; Local variables:
;; folded-file: t
;; folding-internal-margins: nil
;; end:

