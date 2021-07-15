;;
;; This file does, unfortunately, kind of double duty being the overall
;; Python config space as well as the python-mode stuff.  Since the Python
;; mode stuff is now in a file called python.el, naming becomes inconsistent.
;;

(dp-loading-require 'dp-python t
"Load & support my Python needs."
;; Fancy vars...
(defcustom dp-python-new-file-template-file
  (expand-file-name "~/bin/templates/python-template.py")
  "A file to stuff into each new Python file created with `pyit'
or a list: \(function args).
An `undo-boundary' is done before the template is used.
We just barf if the template file is missing."
  :group 'dp-vars
  :type 'string)

;; Vars
(defvar dp-orig-python-tab-binding nil
  "Original binding for the tab key in python mode")
(defvar dp-latest-py-shell-buffer nil
  "Newest buffer created by `dp-python-shell'.")
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

;;;###autoload
(defalias 'dpy 'dp-python-shell)

;;;###autoload
(defun dp-python-shell-this-window (&optional args)
  "Try to put the shell in the current window."
  (interactive "P")
  (dp-python-shell)
  ;; This may or may not work, depending on the original window config.
  (dp-slide-window-right 1))


;;;###autoload
(defalias 'dpyd 'dp-python-shell-this-window)
;;;###autoload
(defalias 'dpy. 'dp-python-shell-this-window)
;;;###autoload
(defalias 'dpy0 'dp-python-shell-this-window)

(defun dp-py-prepend-self. (&optional make-initializer-p)
  (interactive "P")
  (let (p m)
    (save-excursion
      (backward-word 1)
      (insert "self.")
      (setq m (dp-mk-marker))
      ;; This makes sure we get the whole symbol since we may have issued
      ;; the command inside it somewhere.
      (forward-word)
      (setq p (dp-mk-marker)))
    (when make-initializer-p
      (goto-char p)
      (insert " = " (buffer-substring m p)))))

(dp-add-mode-paren-list 'python-mode
			dp-python-mode-parenthesize-region-paren-list)

(defvar dp-py-cleanup-class-re
  (concat "^\\s-*\\(class\\)\\s-+\\(\\(\\w\\|\\s_\\)+\\)\\s-*"
	  ;; 4  5
	  "\\(\\((?\\)"
	  "\\s-*"
	  ;; 6  7
	  "\\(\\(\\w\\|\\s_\\)*\\)"
	  "\\s-*"
	  ;; 8
	  "\\()?\\)\\)\\(.*\\)$"))

(defun dp-py-fix-comment ()
  ;; `save-excursion' doesn't work here.
  ;; ??? marker vs number?
  (let ((pt (point)))
    (end-of-line)
    (when (and (eq (buffer-syntactic-context) 'comment)
	       ;; Don't hose comment only lines.
	       (not (dp-comment-only-line nil nil
					  'except-block-comments-p)))
      (dp-python-indent-command))
    (goto-char pt)))

(defun pyit ()
  "Set up a buffer as a Python language buffer.
Inserts `dp-python-new-file-template-file' by default."
  (interactive)
  (when (and buffer-file-name
             (not (string-match dp-ipython-temp-file-re buffer-file-name))
	     (let ((comment-start "###"))
	       (dp-script-it "python" t
                    :comment-start comment-start
                    :template 'dp-insert-new-file-template
                    :template-args (list dp-python-new-file-template-file))))))

(defun dp-py-cleanup-class ()
  (interactive)
  ;; For some reason, I see `buffer-syntactic-context' getting hosed
  ;; such that it thinks it's in a string, when it's not.  It seems
  ;; like some kind of latch-up, since it will do that for a while
  ;; and then stop.  Going to `point-min' and calling
  ;; `buffer-syntactic-context' and returning seems to fix it, but...
  ;;  For now, I'll just make sure there's no colon where I want to
  ;;  put one.
  ;;  [ at this time: 2020-07-21T20:32:23 ] I'm using FSF Emacs so we'll see
  ;;  if it still happens.
  (save-excursion
    (beginning-of-line)
    (when (dp-re-search-forward dp-py-cleanup-class-re (line-end-position) t)
      (replace-match (format "\\1 \\2(%s)\\9"
			     (or (dp-non-empty-string (match-string 6))
				 "object"))))))

(defun dp-python-indent-command (&optional indent-offset)
  "Indent region if mark is active, the current line otherwise."
  (interactive "*P")
  (if (dp-mark-active-p)
      (progn
	(py-indent-region (region-beginning) (region-end) indent-offset)
	;;(message "indent region")
	)
    ;;(message "indent line")
    (when dp-orig-python-tab-binding
      (setq this-command dp-orig-python-tab-binding)
      (call-interactively dp-orig-python-tab-binding))))

;; ^^^^^^^^^^^^^^^^^^^^^^^^^^ Common ^^^^^^^^^^^^^^^^^^^^^^^^^^
;; vvvvvvvvvvvvvvvvvvvvvvvvvv Emacs  vvvvvvvvvvvvvvvvvvvvvvvvvv
(if (bound-and-true-p dp-use-standard-emacs-python-mode-p)
    (progn
      (dp-defaliases 'dpy 'dp-python 'python-shell-switch-to-shell)

      )
  ;; else my olde/XEmacs hacked together Python/IPython dev environment.
  (require 'dp-xemacs-python)
)

;; @todo XXX common or olde?
(defun dpy-reload ()
  (interactive)
  ;; Kill current buffer if it's a dpy buffer, else the latest one created.
  (let* ((doomed-buf (if dp-ima-dpy-buffer-p
			 (current-buffer)
		       dp-latest-py-shell-buffer))
	 (cwd (buffer-local-value 'default-directory doomed-buf)))
    (kill-buffer doomed-buf)
    ;; Start new shell in same directory
    (cd cwd))
  (dp-python-shell))

;; @todo XXX Extract common.
(defun dp-python-mode-hook ()
  "Set up python *my* way."
  (interactive)
  ;; Python has a problem with my  `dp-fix-comments' function.
  (dmessage "Entering `dp-python-mode-hook'.")
  (setq dp-il&md-dont-fix-comments-p t)
  (filladapt-mode)
  (setq-ifnil dp-orig-python-tab-binding (key-binding (kbd "TAB")))
  (make-variable-buffer-local 'block-comment-start)
  (setq dp-insert-tempo-comment-func 'dp-py-insert-tempo-doxy-comment
	block-comment-start (concat py-block-comment-prefix " ")
	comment-start "# ")
  (define-key dp-Ccd-map [(control ?d)] 'dp-py-insert-tempo-doxy-comment)
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
  (local-set-key [(control ?x) (control left)] 'py-beginning-of-def-or-class)
  (local-set-key [(meta left)] 'beginning-of-defun)
  (if (dp-xemacs-p)
      (local-set-key [(meta right)] 'py-end-of-def-or-class)
    (local-set-key [(meta right)] 'end-of-defun))
  (local-set-key [(meta return)] 'dp-py-open-newline)
  (local-set-key [(control meta ?p)] 'py-beginning-of-def-or-class)
  (local-set-key "\C-c!" 'dp-python-shell)
  (local-set-key [(meta ?s)] 'dp-py-insert-self?)
  (local-set-key [(shift meta ?s)] 'dp-py-insert-self?-and-init)
  (local-set-key [(meta ?q)] 'dp-fill-paragraph-or-region-with-no-prefix)
  (local-set-key [(meta up)] 'dp-other-window-up)
  (local-set-key [(meta down)] 'other-window)
  ;; company steals this for completion.
  (when (featurep 'company)
    ;; Steal it the fuck back
    ;; was: (global-set-key [(meta ?9)] 'dp-insert-parentheses)
    ;; should set locally to override the new local binding.
    ;; Doesn't work.
    ;; (local-set-key [(meta ?9)] 'dp-insert-parentheses))
    (define-key company-active-map [(meta ?9)] 'dp-insert-parentheses))

  ;; @todo XXX
  ;; See also <:elpy-python-bindings:> in `dp-elpy-mode-hook'.  This mode and
  ;; that mode interact by stacking in some way, some keys on one map, some
  ;; keys on another, as normal minor modes do, but I don't know how to
  ;; handle them in the best way.  So sometimes I'm stuck using mode specific
  ;; keymap (names).  That now seems to be a quite common practice. It
  ;; requires a convention, or source, to know the name, source quite often.
  ;; I hope it solves a worthy problem.

  (dp-add-line-too-long-font 'python-font-lock-keywords)
  (setq dp-cleanup-whitespace-p t)
  ;; @todo XXX conditionalize this properly
  ;; dp-trailing-whitespace-font-lock-element

  ;; !<@todo XXX Add this to a new file hook?
  (dp-auto-it?)

;;;;;;;;move to dp-flyspell >>>>> (dp-flyspell-prog-mode)

  (message "`dp-python-mode-hook' finished."))

(defvar dp-py-class-or-def-regexp-format-str
  (concat
   "\\(^"                               ; <ms1
   "\\(\\s-*\\)"                        ;   <ms2>
   "%s\\s-+"                            ; Keywords we're interested in.
   "[a-zA-Z_][a-zA-Z_0-9]*\\)"          ; ms1> def or class name
   ;; look for what's after the def/class name.
   ;; We're interested in:
   ;; "(", "(text", "(text)", "()"
   "\\("                                ; <ms3
   "\\(?:\\s-*\\)"
   "\\(?:"                              ; | <shy
   "(\\(.*?\\))"                        ; | xxx()
   "\\)"                                ; | shy>
   "\\|"                                ; |
   "\\(?:"                              ; | <shy
;;   "(\\(\\S-*\\)"                       ; | xxx(
   "(\\(.*?\\)\\s-*\\($\\|\\(#.*$\\)?\\)"
   "\\)"                                ; | shy>
   "\\|"                                ; |
   "\\(?:"                              ; | <shy
   ")"                                  ; | xxx)  <== ignore
   "\\)"                                ; | shy>
   "\\|"                                ; |
   "\\(?:"                              ; | <shy
   "[^()].*?"                             ; | ;; Added .* Tuesday June 24 2008
   "\\)"                                ; | shy>
   "\\)?"                               ; ms3>
   "\\(\\s-*\\(#.*\\|$\\)\\)"           ; <ms4 <ms5>>

   )
  "Get to the parts of a Python def or class:
ms2: indentation (if in class, and block keyword is def --> method)
ms3: block keyword
ms4: existing parens
ms5 or ms6: params with parens (depends on current state of kw)
ms9: rest of line after program text -- includes ws and comment
ms10: comment char to end of line
")

(defvar dp-py-special-char-fmt-str
  "[][,~`!@#$%%^&*(%s+={}\:;<>.?|/-/-]")

(defvar dp-py-special-chars
  (format dp-py-special-char-fmt-str ")")
  "dp-py-special-chars
s/-/ /g")

(defvar dp-py-special-chars-sans-close-paren
  (format dp-py-special-char-fmt-str ""))

(defvar dp-py-class-or-def-kw-regexp "def\\|class")

(defvar dp-py-class-or-def-regexp
  (format dp-py-class-or-def-regexp-format-str
          (concat "\\(" dp-py-class-or-def-kw-regexp "\\)")))

(defvar dp-py-block-stmt-split-regexp
  (format dp-py-class-or-def-regexp-format-str
          (concat "\\(" dp-py-block-keywords "\\)")))

(defun* dp-py-code-text-ends-with-special-char-p (&key except special-chars
                                                  new-pos)
  "Are we on a special character? E.g. one which cannot precede [,:], etc.
The characters are classified as good or bad by `looking-at' and so EXCEPT
must be compatible with that function.
Chars in EXCEPT are *always* OK.
There is a standard `looking-at' type string which is filled with all kinds
of naughty characters `dp-py-special-chars'.  This can be overridden by
passing SPECIAL-CHARS."
  (save-match-data
    (dp-with-saved-point nil
      (when new-pos (goto-char new-pos))
      ;; Goto the end of the code text on this line, if any.
      (dp-py-goto-end-of-code)
      ;; Will we even be here if we're on a comment line?
      (if (bolp)
          t
          ;;(error "In a comment; is this OK???")
        ;; We're just after the last char, so...
        (forward-char -1)
        ;; If I skipped forward, then the character was in the except list
        ;; and therefor should be considered as non special (I need a better
        ;; term than special.)
        (if (and except
                 (/= 0 (skip-chars-forward except)))
            nil                         ; Not special.
          ;; If we skip forward then we were on a spay-shul character.
          ;; and so should return true
          (/= 0 (skip-chars-forward
                 (or special-chars dp-py-special-chars))))))))

(defun* dp-py-open-newline ()
  (interactive)
  (let ((case-fold-search nil)
        (trailing-chars "")
        (block-kw-p t)
        replacement
        (add-here (dp-py-end-of-code-pos))
        something-special-p
        kword colon-pos in-class-p class-def-p open-paren-only-p
        no-colon-etc-p keyword parens parameters indent
        method-p class-or-def-p no-newline-&-indent-p)
    ;; parameters is one of ms{6, 5}
    (beginning-of-line)
    (cond
     ;; Punt if we're not in code... we could try moving forward some bounded
     ;; distance until we enter code space.
     ((not (dp-in-code-space-p))
      'pttthhhhhrrrrrrppppttthhhhh!)
     ((let ((stat (dp-add-comma-or-close-sexp
		   :beg (python-nav-beginning-of-statement)
		   :end (python-nav-end-of-statement)
		   :caller-cmd this-command
		   :add-here add-here)))
        (if (not (eq stat 'force-colon))
            stat
          (beginning-of-line)
          (setq something-special-p t
                colon-pos (dp-mk-marker (dp-py-end-of-code-pos) nil t))
          nil))
      ;; In a `cond' , nothing here causes the last return value (ie of
      ;; predicate) to be propagated.
      )
     (t (when (and (setq something-special-p
                         (dp-re-search-forward
                          (concat "^\\s-*"
                                  "\\(\\<\\("
                                  dp-py-block-keywords
                                  "\\)\\>"        ; keyword
                                  "\\(.*?\\)\\)"
                                  "\\(\\s-*\\($\\|#.*$\\)\\)")
                          (line-end-position) t))
                         (not (dp-py-got-colon?
                               :start (line-beginning-position))))
          ;; This colon-pos value is used for simple line opening.
          (setq something-special-p t
                colon-pos (dp-mk-marker (match-end 1) nil t)
                kword (match-string 2))
          ;; We know we're a block type statement.  We can split all of them
          ;; here and then handle the def and class as needed.
          (when (dp-looking-back-at dp-py-block-stmt-split-regexp)
            ;; Pick apart the bits of a class or def line
            (setq indent (match-string 2)
                  keyword (match-string 3)
                  class-or-def-p (save-match-data
                                   (string-match dp-py-class-or-def-kw-regexp
                                                 keyword))
                  block-kw-p (not class-or-def-p)
                  parens (match-string 4)
                  parameters (or (dp-non-empty-string (match-string 5))
                                 (dp-non-empty-string (match-string 6))
                                 "")
                  class-def-p (string= "class" keyword)
                  def-p (string= "def" keyword)
                  ;; Classes can be inside other classes and so have leading
                  ;; WS.
                  method-p (and (string= "def" keyword)
                                (dp-non-empty-string indent))
                  open-paren-only-p (string= "(" parens)
                  rest-of-line (match-string 9)
                  comment-string (match-string 10))
            ;; @todo Can this be merged w/the original check for adding a
            ;; colon? ;; We assume defs are indented in classes.  And I'm
            ;; sure Python must require it.
            (unless (dp-non-empty-string parameters)
              (setq parameters
                    (cond
                     (class-def-p "object")
                     (method-p "self")
                     (t "")))))             ; Hopefully a def
          ;; We just want an eol, newline, indent.
          (when (and class-or-def-p
                     (not (dp-py-code-text-ends-with-special-char-p
                           :new-pos colon-pos
                           :except ")")))
	    ;; We're interested in the character after the closing ')'
	    (setq colon-pos (dp-mk-marker (match-end 4) nil t)
		  )

            ;; replace match mangles strings from files like:
            ;;      def tail(self, join_with="\n", ofile=sys.stdout)
            ;; Even with literal set, the "\n" becomes "n"
            (setq replacement (format "%s(%s)%s%s"
                                      (or (match-string 1)
                                          "")
                                      parameters
                                      (or (match-string 9)
                                          "")
                                      rest-of-line))
            (delete-region (match-beginning 0) (match-end 0))
            (insert replacement)

            ;;(replace-match (format "\\1(%s)\\9%s" parameters rest-of-line))
            ;; set to end of class/def(...)
            ;; +2 for 2 new parens
            (goto-char colon-pos))
          (unless (dp-looking-back-at ":")
            (when class-def-p
              (dp-py-cleanup-class))))
        ;; There are too many legit cases where lines don't end with )
        ;;!<@todo only do this on def lines?
        ;;(when (or t (dp-looking-back-at ")"))
        (if (and something-special-p
                 (not (dp-py-code-text-ends-with-special-char-p
                       :new-pos colon-pos
                       :except "[])]"))
;;                  (or (not parameters)
;;                      block-kw-p)
                 )
            (progn
              (undo-boundary)
              (goto-char colon-pos)
	      (insert ":"))
          (dmessage "figure out when to insert a ,"))))
    ;; Fix regardless since it won't do anything if it's not needed.
    (dp-py-fix-comment)
    (unless no-newline-&-indent-p
      (end-of-line)
      (if (dp-xemacs-p)
	  (py-newline-and-indent)
	(newline-and-indent))
      ;; Fix any hosed comment spacing.
      (dp-py-fix-comment))))

;;CO; (defadvice py-end-of-def-or-class (before dp-py-eodoc activate)
;;CO;   "Make `py-end-of-def-or-class' leave the region active."
;;CO;   (dp-set-zmacs-region-stays t))

;;
(global-set-key [(control ?c) (control ?z)]
		(kb-lambda
		  (dp-kb-binding-moved arg 'dp-python-shell)))

;;;
;;; Make an? I?Python shell setup file or function?
;;; Not until I have only Python mode or Python type shell package.
;;; For now, assume we have both and leave them both here.
;;;
;;needed w/Elpy? (defun dp-python-get-process ()
;;needed w/Elpy?   (or (get-buffer-process (current-buffer))
;;needed w/Elpy?                                       ;XXX hack for .py buffers
;;needed w/Elpy? 	(get-process py-which-bufname)))

;; Make this a "style" thing (canna think ova better word)?  Putting the
;; hook in the setup file if there is a setup type file.  Otherwise near
;; the setup code or function definition.
(add-hook 'python-mode-hook 'dp-python-mode-hook)

;;needed w/Elpy? (defun dp-py-completion-setup-stolen ()
;;needed w/Elpy?   (let ((python-process (dp-python-get-process)))
;;needed w/Elpy?     (process-send-string
;;needed w/Elpy?      python-process
;;needed w/Elpy?      "from IPython.core.completerlib import module_completion\n")))

;; End of 'dp-use-standard-emacs-python-mode
)
