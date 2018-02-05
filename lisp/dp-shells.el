;;;
;;; $Id: dp-shells.el,v 1.85 2005/07/03 08:20:10 davep Exp $
;;;
;;; Set up and support for shell mode stuff.
;;;
;;(require 'shell)

;;
;; add some stuff to the shell fontifications

(dp-optionally-require 'ssh)

(defvar dp-default-variant 'comint
  "Variant is comint vs term modes.
Term has more potential, but comint is easier and was around, for me, first
and so is the most developed.")


;;;###autoload
(defcustom shell-uninteresting-face 'shell-uninteresting-face
  "Face for shell output which is uninteresting.
Should be a color which nearly blends into background."
  :type 'face
  :group 'shell-faces)
(make-face shell-uninteresting-face)

(defface dp-shell-root-prompt-face
  '((((class color) (background light)) 
     (:foreground "red"))) 
  "Face for root prompt."
  :group 'faces
  :group 'dp-vars)

(copy-face 'dp-journal-high-example-face 'dp-shells-prompt-id-face)
(copy-face 'dp-journal-extra-emphasis-face 'dp-shells-prompt-path-face)

(defcustom dp-shell-bogus-echoers '("sybil")
  "*Nodes with fucked up stty echo behavior wrt emacs terminal type."
  :group 'dp-vars
  :type '(repeat string))

(defcustom dp-ls-front-end-command "run-with-cols-and-lines"
  "Use this to run an ls type command. This takes care of differences between 
*csh and *sh environment syntax."
  :type 'string
  :group 'dp-vars)

;;
;; currently: [ the 5056/0002> line is what we match. ]
;; dpanariti@sc-xterm-19:/home/scratch.dpanariti_t124_1/sb3/sb3hw/hw/ap_t132
;; 5056/0002>
;; After an error:
;; dpanariti@sc-xterm-19:/home/scratch.dpanariti_t124_1/sb3/sb3hw/hw/ap_t132
;; 5057/0002<1>
;; For shell 0 buffer:
;; 5002/spayshul> 
;;(defconst dp-sh-prompt-regexp "^[0-9]+\\([/<][0-9]+\\)?\\([#>]\\|<[0-9]*>\\)"
(defconst dp-sh-prompt-regexp 
  (concat "^[0-9]+"                     ; History number
          "\\("
          "[/<]"                        ; hist num separator.
          "\\(?:[0-9]+\\|spayshul\\)"   ; shell "name"
          "\\)"
          "?\\([#>]\\|<[0-9]*>\\)")
  "For bash/sh/etc.")

(defconst dp-gdb-prompt-regexp "^(gdb) "
  "For gdb.")

(defvar dp-shells-prompt-font-lock-regexp-list 
  (list dp-sh-prompt-regexp dp-gdb-prompt-regexp)
  "`comint'-y \"clients\" can have font locking regexp for its prompt here.")

;;;###autoload
(defun dp-shells-mk-prompt-font-lock-regexp (&optional regexp-list)
  (dp-concat-regexps-grouped (or regexp-list 
                                 dp-shells-prompt-font-lock-regexp-list)))

;;; Why does autoloading C-z (dp-shell) make this autoload necessary?
;;;###autoload
(defvar dp-shells-prompt-font-lock-regexp 
  "^\\([0-9]+\\)\\(/\\(?:[0-9]+\\|spayshul\\)\\)\\([#>]\\|\\(<[0-9]*>\\)?\\)"
  "*Regular expression to match my shell prompt.  Used for font locking.
For my multi-line prompt, this is second line.  For most prompts, this will
be the only line.  Some shells, like IPython's, already colorize their
prompt.  We don't want to stomp on them.")

(defvar dp-shell-root-prompt-regexp 
  "^[0-9]+## "
  "*Regular expression to match my shell prompt.")

(defun* dp-X-or-Y-at-pmark/eobp (arg &optional 
                                 (if-func 'process-send-eof)
                                 (else-func 'delete-char arg))
  (interactive "p")
  (call-interactively (if (and (dp-eobp) (dp-comint-at-pmark-p))
                          if-func
                        else-func)))

(defun dp-shells-prompt-font-locker (limit)
  (dp-re-search-forward dp-shells-prompt-font-lock-regexp limit t))

(defvar dp-shell-mode-font-lock-keywords
  ;; this font-lock def is basically the shell stuff + the
  ;; compile mode stuff.
  ;; Fix this for multiple users and hosts.
  ;;!<@todo no time now, but some kind of eval is needed to get current
  ;;values.
  (let* ((prompt-line-0 (format "^\\(%s\\)\\(.*$\\)$"
                                (concat "^"
                                        (getenv "USER")
                                        "@"
                                        (getenv "HOST")
                                        ":"))))
    (list 
     ;; Prompts:
     ;; user 
     ;;;;;???(cons 'dp-shells-prompt-font-locker 'shell-prompt-face)
     (cons dp-shells-prompt-font-lock-regexp
           (list (list 1 'shell-prompt-face)
                 (list 2 'dp-journal-medium-attention-face)
                 (list 3 'dp-journal-medium-attention-face)
                 (list 4 'dp-journal-high-problem-face t t)))
     ;; root prompt
     (cons dp-shell-root-prompt-regexp 'dp-shell-root-prompt-face)
     ;; The CWD part of my prompt  dp-journal-high-example-face
     ;; This ended up marking tons of stuff wrongly: "^[^@]+?@.*$"
     ;; Certainly the "@"s from ls -F are part of the problem.
     (cons prompt-line-0 
           (list (list 1 'dp-shells-prompt-id-face)
                 (list 2 'dp-shells-prompt-path-face)))
     
     ;; grep hits on emacs backup files *~
     '("^[^\n]*~:[0-9]+:.*$" . shell-uninteresting-face)
     ;; compiler warnings
     '("^[-_.\"A-Za-z0-9/+]+\\(:\\|, line \\)[0-9]+: \\([wW]arning:\\).*$" 
       . font-lock-keyword-face)
     ;; greppish -n  hits: a name a colon and a number.
     '("^[-_.\"A-Za-z0-9/+]+\\(: *\\|, line \\)[0-9]+:.*$" 
       . font-lock-function-name-face)
     ;; name part of a greppish -n hit.
     '("\\(^[-_.\"A-Za-z0-9/+]+\\)\\(: *\\|, line \\)[0-9]+" 1 
       shell-output-2-face t)
     ;; line number of grep hit
     '("^[-_.\"A-Za-z0-9/+]+\\(: *[0-9]+\\|, line [0-9]+\\)" 1 bold t)
     ;; everything else
     '("^[^\n]+.*$" . shell-output-face)))
  "My preferred shell-mode font-lock config")


;;;###autoload
(eval-after-load "shell" 
  '(progn
    ;; more specific pattern for my prompt so other output is
    ;; less likely to match
    (setq shell-prompt-pattern-for-font-lock 
          dp-shells-prompt-font-lock-regexp)))

(defun dp-comint-pmark ()
  (when (get-buffer-process (current-buffer))
    (process-mark (get-buffer-process (current-buffer)))))

(defun dp-comint-at-pmark-p ()
  "Return t if point is after the process output marker."
  (when (dp-comint-pmark)
    (= (marker-position (dp-comint-pmark)) (point))))

;; Current prompt style: NO / @ end
;; dpanariti@o-xterm-34:/home/scratch.dpanariti_t124/sb2/hw/hw
(defun dp-shell-lookfor-dir-change (str)
  ;;(dmessage "dir-change, str>%s<" str)
  (let ((regexp (format "^%s@%s:\\([~/].*[^/]$\\)"
                        (user-login-name) (dp-short-hostname))))
    ;;(message "regexp>%s<" regexp)
    (when (string-match regexp str)
      (let ((s (match-string 1 str)))
        (when (string-match "^\\([^ 	
]+\\)" s)
          ;; Just set it, no sense in comparing to see if it changed.
          (setq default-directory 
                (expand-file-name
                 (concat (match-string 1 s) "/"))))))))

;; XXX @todo fix this, make it work.
;; Debugger entered--Lisp error: (invalid-argument "Marker does not point anywhere")
;;   ansi-color-filter-region(#<marker in no buffer 0x6e80> #<marker at 594 in *gdb-nemo-2* 0x6d35>)
;;   ansi-color-process-output("(gdb) ")
;;   run-hook-with-args(ansi-color-process-output "(gdb) ")
;;   comint-output-filter(#<process "bash" pid 17415 state:run> "(gdb) ")

(dp-deflocal dp-dont-ask-to-tack-on-gdb-mode-p nil
  "Do not ask if the user want to ser gdb mode when we see a gdb-mode prompt.
Can be set after the first prompting.")

(defvar dp-shell-auto-tack-on-gdb-mode-p t
  "Should we automatically tack on gdb mode when we encounter the gdb prompt
  `dp-gdb-prompt-regexp'?")

(defun dp-shell-lookfor-gdb (str)
  (when (and (not (eq major-mode 'gdb-mode))
             (not dp-dont-ask-to-tack-on-gdb-mode-p)
             (string-match (concat dp-gdb-prompt-regexp "$") str))
    (setq dp-dont-ask-to-tack-on-gdb-mode-p t)
    (when (or dp-shell-auto-tack-on-gdb-mode-p
              (y-or-n-p "Tack on gdb mode? "))
      (dp-tack-on-gdb-mode+))))

(defun dp-shell-lookfor-shell-max-lines (str)
  (when (string-match "DP_SML=\\(-?[0-9]*\\)" str)
    (let ((num-lines (match-string 1 str)))
      (dp-set-shell-max-lines (if (string= num-lines "-")
                                  -1
                                (string-to-int num-lines))))))

(defun dp-shell-lookfor-cls (str)
  (when (string-match "^[ \t]*cls[ \t]*$" str)
    (dp-clr-shell nil nil)))

(defun dp-shell-lookfor-clsx (str)
  (when (string-match "^[ \t]*clsx[ \t]*$" str)
    (clsx)))

;;  "?this needs to be deleted when the ls and dimensions crap is resolved?"
(defcustom dp-shell-magic-ls-pattern
  "^[ 	]*\\<\\(ls1?\\|ltl\\|lsl\\|lth\\)\\>\\(?:\\s-*\\)\\($\\|.*\\)$"
;;"^[ \t]*\\<\\(ls1?\\|ltl\\|lsl\\|lth\\)\\>\\($\\|\\(?:[ \t]+\\)\\)\\(.*\\)$"
  "*Match this pattern for magic ls functionality!"
  :group 'dp-vars
  :type 'string)

(defvar dp-comint-discard-regexp "^[ \t]*\\(cls\\|ls\\|ltl\\|lsl\\|lth\\)\\>"
  "Don't send anything that matches to the comint process.")

(defun dp-shell-lookfor-ls (str)
  (when (string-match dp-shell-magic-ls-pattern str)
    (dp-magic-columns-ls
     (match-string 1 str)
     (match-string 2 str)
     nil)))                             ;Do I like this? 'no-echo

(defun* dp-bash-like-p (&optional (shell-name (getenv "SHELL")))
  "Are we using a bash-like shell?"
  (string-match "/\\(ba\\)?sh" (getenv "SHELL")))

(defvar dp-editing-server-cmd-regexp
  (concat "^\\s-*\\(.?/?\\)?"
          (dp-concat-regexps-grouped
           (append (list (regexp-opt '(
                                       "ec"
                                       "ef"
                                       "ec-diff"
                                       "git-diff-ec"
                                       "git-ec-diff"
                                       "ec-merge"
                                       "ef-diff"
                                       "gitcia"
                                       "hgcia"
                                       )))
                   ;; diff needs to be here because I use ec-diff which uses
                   ;; emacs.
                   '("sp\\s-+.*-e\\|dp4-review")
                   '("\\(hg\\|git\\)\\s-+\\(commit\\|.+\\s-+commit\\)")
                   ;; Resolve doesn't always result in an edit, but when it
                   ;; does, it sucks to poke around for the right instance.
                   '("p4\\s-+\\(resolve\\|diff\\|change\\|client\\|submit\\)\\|\\(as2\\s-+submit\\)"))
           nil 'one-around-all-p)
          "\\(\\s-+\\|$\\)")
  "Commands that end up invoking an editor. We may want to ensure that
  instance with the current shell gets to do the editing.")

(defvar dp-editing-server-cmd-regexp-exceptions
  (concat "^\\s-*\\(.?/?\\)?"
          (dp-concat-regexps-grouped
           (append 
            '("\\(hg\\|gitcia\\)\\s-+.*-m")
            '("\\(hg\\|git\\)\\s-+\\(commit\\|.+\\s-+commit\\s-+\\).*-m")
            ;; diff needs to be here because I use ec-diff which uses emacs.
            ;; This re needs to be modified to handle args to p4 itself, like
            ;; the git commit re above.
            '("p4\\s-+\\(client\\s-+.*-[odis]\\|change\\s-+.*-[odist]\\|submit\\s-+.*-[di]\\)"))
           nil 'one-around-all-p)
          "\\(\\s-+\\|$\\)")
  "Commands that don't end up invoking an editor even though other commands
  that look like them (and are matched by `dp-editing-server-cmd-regexp')
  do.")
 
(defun dp-shell-lookfor-editing-server-command (str)
  (interactive)
  (when (and (string-match dp-editing-server-cmd-regexp str)
             (not (dp-server-running-p))
             (not (string-match 
                   dp-editing-server-cmd-regexp-exceptions
                   str))
             (y-or-n-p "Start gnuserv in this XEmacs instance? "))
    (dp-start-editing-server nil 'force-serving)))

(defvar dp-shell-vc-cmds '("cvs" "svn" "git" "hg")
  "Version control commands that can cause problems if they are used and
  there are dirty buffers.")

(defvar dp-shell-vc-commit-cmds
  '("gitci" "gitcia")
  "Some aliases or extended functionality versions of checkin commands.
No regexps allowed. This will be processed by `regexp-opt'")

(defvar dp-shell-vc-commit-cmd-regexps
  (append
   (loop for vc-cmd in dp-shell-vc-cmds
     collect (format "\\s-*\\(%s\\|\\S-*/%s\\).* \\<\\(commit\\|ci\\)\\>"
                     vc-cmd vc-cmd))
   (list (regexp-opt dp-shell-vc-commit-cmds))))
   
(defvar dp-shell-vc-commit-cmd-regexp
  (dp-concat-regexps-grouped dp-shell-vc-commit-cmd-regexps)
  "All regexes in one \\|'d string.")

(defun dp-shell-vc-commit-p (str)
    (or (posix-string-match dp-shell-vc-commit-cmd-regexp str)
        ))

(defvar dp-shell-dirty-buffer-cmds
  (concat "^\\s-*\\(\\.?/?\\)?"
          (dp-concat-regexps-grouped
           (append (list (regexp-opt '("make"
                                       "nvmk"
                                       "t_make"
                                       "apmake"
                                       "kmk"  ; Make .o, .ko, etc in kernel tree.
                                       "cc"
                                       "gcc"
                                       "g++"
                                       "cpp"
                                       "diff"
                                       "sdiff"
                                       "diff3"
                                       "meld"
                                       "diffuse"
                                       "grep"
                                       "egrep"
                                       "fgrep"
                                       "dotfgrep"
                                       "dotegrep"
                                       "dotjgrep"
                                       "dotgrep"
                                       "sed"
                                       "gawk"
                                       "nawk"
                                       "awk"
                                       "ci"
                                       "xem"
                                       "lem"
                                       "gits"
                                       "gitstat"
				       "gitsno"
                                       "autoreconf"
                                       "aclocal"
                                       "autoconf"
                                       "libtoolize"
                                       "automake"
                                       "bgme"
                                       "tgbme"  ; Build multiengine test util.
                                       "build_gpu_multiengine.pl"
                                       "index-me-code"
                                       "index-code"
                                       "nvrun ness"
                                       "xemacs")))
;;                   '("\\(dp-\\)?git\\(\\s-*\\|-\\)\\(cia\\|st\\|diff\\)")
                   ;; Any git looking command.  Better a false + than false -
                   '("\\(dp-\\)?git\\(-\\S-+\\)")
                   '("p4\\s-+\\(diff\\)")
                   '("index-code.*")
                   '("\\(.*/\\)\\(t_make\\|build_gpu_multiengine.*\\.pl\\)")
                   dp-shell-vc-commit-cmd-regexps)
           nil 'one-around-all-p)
          "\\(\\s-+\\|$\\)")
  "Commands that may want to have modified buffers saved before running.
Commands that might want to use files in buffers. Shit that would piss us off
when we realized that we didn't use the latest modifications.
svn: Oh, shit. I did a commit w/older file!
g++: Why does it act exactly the same in spite of my changes?

;; !<@todo XXX Add ^ and $ to avoid over generalization.")

(defun dp-shell-lookfor-vc-cmd (str)
  (interactive)
  (when (dp-shell-vc-commit-p str)
    (save-some-buffers)))

(defun dp-shell-dirty-buffer-cmd-p (str)
  "Is STR a command which could have a problem with modified buffers?
Examples are things like make, cc, etc. We would like these commands to
operate on the most current file contents."
  (string-match dp-shell-dirty-buffer-cmds str))

(dp-deflocal dp-shells-save-buffer-flag-p t
  "Should this buffer be saved when a `dirty buffer' action in a shell window
is executed? E.g. *grep, make, etc.  Annoyingly, buffers visiting compressed,
tar, etc., type buffers are marked as modified when, overwhelmingly, they are
not destined to be saved.  ")

(defun dp-shells-skip-save-buffer (&optional buf)
  (interactive)
  (set-symbol-value-in-buffer 'dp-shells-save-buffer-flag-p 
                              nil
                              (dp-get-buffer buf)))
  
(defvar dp-shells-files-to-not-save 
  '("\\.gz$"
    "\\.bz2$"
    "\\.zip$"
    "\\.xz$"
    "\\.tar")
"Don't save these. XEmacs stupidly considers expanded files as dirty.")

(defun dp-shells-save-buffer-p ()
  (and dp-shells-save-buffer-flag-p
       (buffer-file-name)
       (not (dp-match-a-regexp (buffer-file-name)
                               dp-shells-files-to-not-save))))

(defun dp-shell-lookfor-dirty-buffer-cmds (str)
  (when (dp-shell-dirty-buffer-cmd-p str)
    (save-some-buffers nil 'dp-shells-save-buffer-p)))

(defvar dp-shell-*TAGS-changers
  (concat "^\\s-*"
          (dp-concat-regexps-grouped
           (cons (regexp-opt '("code-indexer"
                               "udstags"
                               "cscope"
                               "gtags"
                               "index-code"
                               "index-me-code"
                               "index-all-me-trees"
                               "extagtree"))
                 '(".*tags.*"))
           nil 'one-around-all-p))
  "Commands which cause *TAGS files (TAGS/CTAGS/ETAGS/etc) to be modified.
Changing these files causes an annoying problem in that the TAGS buffers are
updated with the new contents and marked dirty even though the buffer
contents matches the file contents.  This is some new bullshit... it affects
reverting buffers for changed files.  They end up modified.  This didn't use
to happen.  IIR, it was related to stuff like buffer coding systems or some
such. Getting a \"xxx is modified, do something anyway? (yes or no)\" is
fucking annoying and I shouldn't have to deal with it. But I do, so I let
elisp handle it. ")

(defun dp-shell-lookfor-*TAGS-changer (str)
  (when (string-match dp-shell-*TAGS-changers str)
    (dp-refresh-tags)))

(defvar dp-cd-type-command-regexp 
  "^[ \t]*\\(g\\s-+\\(\\|gb\\|pd\\)[ \t]*$\\)"
  "My dir changing commands.")

(defun dp-shells-comint-previous-or-matching-input ()
  (interactive)
  (if (Cu--p)
      (previous-line 1)
    (when (eq last-command 'dp-shells-comint-previous-or-matching-input)
      (setq last-command 'comint-previous-matching-input-from-input))
    (call-interactively 'comint-previous-matching-input-from-input)))

(defun dp-shells-term-previous-or-matching-input ()
  (interactive)
  (if (Cu--p)
      (previous-line 1)
    (when (eq last-command 'dp-shells-term-previous-or-matching-input)
      (setq last-command 'term-previous-matching-input-from-input))
    (call-interactively 'term-previous-matching-input-from-input)))

;; dp-shell-like-symbol
(defsubst dp-sls (variant &rest rest)
  "Return a symbol constructed by the concatenation of VARIANT and REST."
  (intern 
   (mapconcat (lambda (s)
                (format "%s" s))
              (cons variant rest)
              "")))
;;  (intern (format "%s%s" variant sym)))

;;;(eval (car (read-from-string (format "'%s%s" variant sym)))))

(defun* dp-shell-xxx-input (&key
                            at-pmark-fun ; :at-pmark-fun
                            after-pmark-fun ; :after-pmark-fun
                            before-pmark-fun ; :before-pmark-fun
                            mark-active-fun ; :mark-active-fun
                            empty-line-fun ; :empty-line-fun
                            end-of-line-fun ; :end-of-line-fun
                            (get-pmark-fun 'dp-comint-pmark)) ; :get-pmark-fun
  "Retrieve from history or move cursor, depending on location of point.
Uses AFTER-PMARK-P-FUN to determine if point is on command line or in
old output area.  If on command line, and the mark is not active, use
XXX-INPUT-FUN to access history, otherwise use MOVE-FUN to move
cursor.
We assume that if the mark is active that we should use MOVE-FUN instead
of a XXX-INPUT-FUN.
Passing a list as a function causes the list to be evaluated and the car of
the list is then used to set `this-command' variable.  Passing a lambda won't
result in `this-command' being set properly. "
  (interactive)
  (let ((fun 
         (if (dp-mark-active-p)
             mark-active-fun
           ;;else
           (let ((pmark (funcall get-pmark-fun))
                 (pt (point)))
             (cond
              ;; Check for an empty line first since the we're also `eobp' on
              ;; an empty line.
              ((and empty-line-fun
                    (= pmark pt (point-max)))
               empty-line-fun)
              ((and end-of-line-fun
                    (dp-eobp))
               end-of-line-fun)
              ((not pmark) before-pmark-fun)
              ((= pmark pt) at-pmark-fun)
              ((< pmark pt) after-pmark-fun)
              ((> pmark pt) before-pmark-fun))))))
    (dp-set-zmacs-region-stays t)
    (setq this-command fun)  ; We need this so consecutive key commands work.
    (if (listp fun)
        (progn
          (eval fun)
          (setq fun (car fun)))
      (call-interactively fun))
    (setq this-command fun)
    (dp-term-set-mode-from-pos)))

(defun dp-shell-magic-kill-ring-save ()
  (interactive)
  (dp-shell-xxx-input
   ;; at: kill-ring-save from process mark
   ;; rather than bol
   :at-pmark-fun '(dp-copy-to-end-of-line (dp-comint-pmark))
   ;; after: next input
   :after-pmark-fun '(dp-copy-to-end-of-line (dp-comint-pmark))
   ;; before: normal M-o
   :before-pmark-fun 'dp-kill-ring-save
   ;; mark active: M-o uses region if active.
   :mark-active-fun 'dp-kill-ring-save))

(defun dp-shell-dirs-or-delete-line ()
  "If at EOCL (== EOB) and last char was a TAB, do a dirs command.
It is usually after a failed TAB expansion that it becomes apparent that the
dir-tracker has become lost.  
@todo ??? Just do a `dirs' after every change?"
  (interactive)
  (if (and (dp-eobp)
           (eq last-command 'dp-comint-dynamic-complete))
      (dp-shell-resync-dirs)
    (dp-shell-delete-line)))

;;; (defun dp-shell-parens-or-dirs ()
;;;   (interactive)
;;;   (dp-consecutive-key-command 
;;;    (list
;;;     (lambda () (dp-shell-resync-dirs))   ; Just `dirs' may be better.
;;;     (lambda () (dp-parenthesize-region))
;;;    'dp-brief-end-command-ptr
;;; 			      dp-brief-end-command-list
;;; 			      'dp-brief-end))

;;;   )

(defun* dp-shell-line-mode-bindings (&optional (variant dp-default-variant)
                                    (bind-position-aware-keys-p t))
  "Bind some shell-mode keys."
  (when bind-position-aware-keys-p
    (dp-define-buffer-local-keys
     `([(meta ?p)] (lambda ()
                     (interactive)
                     (dp-shell-xxx-input
                      ;; at:
                      :at-pmark-fun 'dp-parenthesize-region
                      ;; after:
                      :after-pmark-fun 'dp-parenthesize-region
                      ;; before:
                      :before-pmark-fun 'compilation-previous-error
                      ;; mark active, where ever:
                      :mark-active-fun 'dp-parenthesize-region))
       [(control ?r)] (lambda ()
                        (interactive)
                        (dp-shell-xxx-input
                         ;; at: Regexp match in previous input.
                         :at-pmark-fun(dp-sls (quote ,variant) 
                                              '-previous-matching-input)
                         ;; after: Regexp match in previous input.
                         :after-pmark-fun (dp-sls (quote ,variant) 
                                                  '-previous-matching-input)
                         ;; before: up
                         :before-pmark-fun 'isearch-backward
                         ;; mark active: up
                         :mark-active-fun 'previous-line))
       [(control ?p)] (lambda ()
                        (interactive)
                        (dp-shell-xxx-input
                         ;; at: up
                         :at-pmark-fun 'previous-line
                         ;; after: match previous
                         :after-pmark-fun (dp-sls 'dp-shells-
                                 (quote ,variant)
                                 '-previous-or-matching-input)
                         ;; before: up
                         :before-pmark-fun 'previous-line
                         ;; mark active: up
                         :mark-active-fun 'previous-line))
       [(control ?n)] (lambda ()
                        (interactive)
                        (dp-shell-xxx-input
                         ;; at: next
                         :at-pmark-fun 'next-line
                         ;; after: match next
                         :after-pmark-fun (dp-sls (quote ,variant) 
                                                  '-next-matching-input-from-input)
                         ;; before: down
                         :before-pmark-fun 'next-line
                         ;; mark active: down
                         :mark-active-fun 'next-line))
       [up] (lambda ()
              (interactive)
              (dp-shell-xxx-input
               ;; at: prev input
               :at-pmark-fun (dp-sls (quote ,variant) '-previous-input)
               ;; after: prev input
               :after-pmark-fun (dp-sls (quote ,variant) '-previous-input)
               ;; before: up
               :before-pmark-fun 'previous-line
               ;; mark active: up
               :mark-active-fun 'previous-line))
       [kp-up] (lambda ()
                 (interactive)
                 (dp-shell-xxx-input
                  ;; at: prev input
                  :at-pmark-fun (dp-sls (quote ,variant) '-previous-input)
                  ;; after: prev input
                  :after-pmark-fun (dp-sls (quote ,variant) '-previous-input)
                  ;; before: up
                  :before-pmark-fun 'previous-line
                  ;; mark active: up
                  :mark-active-fun 'previous-line))
       [down] (lambda ()
                (interactive)
                (dp-shell-xxx-input
                 ;; at: next input
                 :at-pmark-fun (dp-sls (quote ,variant) '-next-input)
                 ;; after: next input
                 :after-pmark-fun (dp-sls (quote ,variant) '-next-input)
                 ;; before: down
                 :before-pmark-fun 'next-line
                 ;; mark active: down
                 :mark-active-fun 'next-line))
       [kp-down] (lambda ()
                   (interactive)
                   (dp-shell-xxx-input
                    ;; at: next input
                    :at-pmark-fun (dp-sls (quote ,variant) '-next-input)
                    ;; after: next input
                    :after-pmark-fun (dp-sls (quote ,variant) '-next-input)
                    ;; before: down
                    :before-pmark-fun 'next-line
                    ;; mark active: down
                    :mark-active-fun 'next-line))
       [(meta return)] (lambda ()
                         (interactive)
                         (dp-shell-xxx-input
                          ;; at: next input
                          :at-pmark-fun 'dp-open-newline
                          ;; after: next input
                          :after-pmark-fun 'dp-open-newline
                          ;; before: down
                          :before-pmark-fun 
                          'dp-error-force-reparse-point-to-end 
                          ;; mark active: down
                          :mark-active-fun 
                          'dp-error-force-reparse-point-to-end))
       [(meta ?d)] (lambda ()
                     (interactive)
                     (dp-shell-xxx-input
                      ;; at:
                      :at-pmark-fun 'dp-shell-delete-line
                      ;; after:
                      :after-pmark-fun 'dp-shell-delete-line
                      ;; before:
                      :before-pmark-fun 'dp-shell-delete-line
                      ;; mark active, where ever:
                      :mark-active-fun 'dp-shell-delete-line
                      ;; XXX @todo make M-d a simple dp-shell-delete-line binding
;;                      :empty-line-fun 'dirs
                      :empty-line-fun 'dp-shell-delete-line
;;                      :end-of-line-fun 'dp-shell-dirs-or-delete-line
                      :end-of-line-fun 'dp-shell-delete-line)))
     nil nil nil "dp-shell-line-mode-bindings"))
  
  ;; ??? Why did I do the C-c thing? Testing?
  (local-set-key [(control ?c) (meta ?o)] 'dp-shell-magic-kill-ring-save)
  (local-set-key [(meta ?o)] 'dp-shell-magic-kill-ring-save)
  
  ;; meta ` is already used by OS X
  ;; replace it by something common to both.
  ;;(local-set-key "\e`" (dp-sls variant '-previous-matching-input-from-input))
  (local-set-key [(control ?')] (dp-sls variant '-previous-matching-input-from-input))
  (local-set-key [home] (dp-sls variant '-bol))
  (local-set-key [(control ?a)] (dp-sls variant '-bol))
  ;;(local-set-key [(control ?z)] 'dp-shell-init-last-cmds)
  (local-set-key [(control space)] 'dp-expand-abbrev)
  ;; take us back from whence we came.
  ;;   (local-set-key [(control ?z)] (kb-lambda 
  ;;                           (and (dp-maybe-select-other-frame)
  ;;                                (bury-buffer))))
  ;;(local-set-key [(control ?z)] 'dp-shell-visit-whence)
  )

(defun dp-shell-bind-common-keys ()
  "Bind common shell keys."
  (interactive)
  ;; moved to dp-shell-mode-hook;(local-set-key "\t" 'dp-comint-dynamic-complete)
  (local-set-key "\en" 'bury-buffer)
  (local-set-key [(control up)] 'dp-scroll-down)
  (local-set-key [(control down)] 'dp-scroll-up)
  (local-set-key [(meta left)] 'dp-shell-goto-prev-cmd-pos)
  (local-set-key [(meta right)] 'dp-shell-goto-next-cmd-pos)
  ;; Usurped by \C-l other window.
  ;;(local-set-key [(control meta ?l)] 'dp-clr-shell)
  (local-set-key [(control ?l)] 'dp-center-to-top)
  (local-set-key [(meta ?-)] 'dp-bury-or-kill-this-process-buffer)
  (local-set-key [(control ?z)] 'dp-shell-visit-whence)
  (local-set-key [(control meta ?m)] 'emms-player-mpd-pause)

  (unless (buffer-file-name)
    ;;(local-set-key [(meta w)] 'dp-you-cant-save-you-silly)
    (local-set-key [(meta w)] 'dp-shell-save-buffer-command)
    ;;(local-set-key [(control ?x) (control ?s)] 'dp-you-cant-save-silly)
    )
  (local-set-key [(control ?g)] 'keyboard-quit))

(defun* dp-add-lookfor-hooks(&optional (variant dp-default-variant))
  (loop for hook in '(dp-shell-lookfor-cls
                      dp-shell-lookfor-clsx
                      dp-shell-lookfor-ls
                      dp-shell-lookfor-shell-max-lines
                      dp-shell-lookfor-vc-cmd
                      dp-shell-lookfor-editing-server-command
                      dp-shell-lookfor-dirty-buffer-cmds
                      dp-shell-lookfor-*TAGS-changer) 
    do (add-hook (dp-sls variant '-input-filter-functions)
                 hook nil t)))

(defun* dp-shell-common-hook (&optional (variant dp-default-variant))
  "Sets up personal shell-like mode bindings.
Called when shell, inferior-lisp-process, etc. are entered."
  (dp-shell-bind-common-keys)
  (when-and-boundp 'dp-use-pcomplete-p
    ;; Add programmable completion to the command line completion process.
    ;; I get bizarre behavior.  Is it my odd setup?  Bad config?  Sunspots?
    ;; I see 'pcomplete duplicated in `shell-dynamic-complete-functions' and in
    ;; `dp-comint-dynamic-complete-functions', which may be the problem...
    (when (dp-optionally-require 'pcomplete)
      (pcomplete-shell-setup))
    ;; So I remove any dupes after the first occurrence.
    (dp-nuniqify-lists '(shell-dynamic-complete-functions 
                         dp-comint-dynamic-complete-functions)))
  (dp-add-lookfor-hooks variant)
  ;;;@todo NEEDED??? (setq local-abbrev-table dp-shell-mode-abbrev-table)
  ;;(make-local-variable 'font-lock-defaults)
  ;;(setq font-lock-defaults '(dp-shell-mode-font-lock-keywords t))
  ;;(font-lock-set-defaults)
  (dp-set-font-lock-defaults 'shell-mode '(dp-shell-mode-font-lock-keywords t))
  (local-set-key [(control ?x)(control ?c)] 'dp-shell-create-next-shell-buffer)
  (local-set-key [(control ?x)(control ?n)] 'dp-shell-switch-to-next-buffer)
  (local-set-key [(control ?x)(control ?p)] 'dp-shell-switch-to-prev-buffer)
  (local-set-key [(control ?x) ?4 ?n]
                 (kb-lambda
                     (dp-shell-switch-to-next-buffer t)))
  (local-set-key [(control ?x) ?4 ?p]
                 (kb-lambda
                     (dp-shell-switch-to-prev-buffer t)))

  (message "dp-shell-common-hook, (major-mode-str)>%s<, bn>%s< done." 
	   (major-mode-str) (buffer-name)))

(defun dp-shell-ignored-buffer-p (&optional name)
  (posix-string-match 
   "^\\*\\ftp .*\\*$"
   (or name (buffer-name))))

(defun dp-shell-on-cl (&optional pos)
  "Are we on the command input part of the shell?"
  (interactive)
  (>= (or pos (point)) (dp-current-pmark-pos)))

(defun dp-delimit-command-line ()
  (interactive)
  (dp-order-cons (cons (save-excursion (comint-bol nil) (point)) 
                       (line-end-position))))

(defun* dp-shell-cl-op (&key on-cl-func off-cl-func on-args off-args)
  "Apply a shell location aware command.  The names are pretty clear given CL means command line.
ON-CL-FUNC is applied to the position just after the prompt, the
process-mark and the list ON-ARGS.
OFF-CL-FUNC is applied to off-args."
  (interactive)
  (if (or (not (dp-shell-on-cl))
          (dp-mark-active-p))
      (apply off-cl-func off-args)
    (let ((beg-end (dp-delimit-command-line)))
      (apply on-cl-func (car beg-end) (cdr beg-end) on-args))))

(defun dp-shell-delete-line ()
  (interactive)
  (dp-shell-cl-op :on-cl-func 'delete-region 
                  :off-cl-func 'dp-delete-entire-line))

(defun dp-shell-kill-line (&optional append-p)
  (interactive)
  (dp-shell-cl-op :on-cl-func 'kill-region 
                  :off-cl-func 'dp-kill-region :off-args (list append-p)))

(defun dp-shell-kill-ring-save (&optional append-p)
  (interactive)
  (dp-shell-cl-op :on-cl-func 'kill-ring-save ;;better? 'copy-region-as-kill 
                  :off-cl-func 'dp-kill-ring-save :off-args (list append-p)))

; (defun dp-shell-delete-line-old ()
;   (interactive)
;   (if (not (dp-shell-on-cl))
;       (dp-delete-entire-line)
;     (comint-bol nil)			;@todo make work for other term mode
;     (dp-delete-to-end-of-line)))


; (defun dp-shell-kill-line-old (&optional append-p)
;   (interactive)
;   (if (or (not (dp-shell-on-cl))
;           (dp-mark-active-p))
;       (dp-kill-region append-p)
;     (let ((beg-end (dp-delimit-command-line)))
;       (kill-region (car beg-end) (cdr beg-end)))))
  
(defun dp-remote-buffer-name-to-host (buffer-name)
  "E.g. *rsh-sybil*"
  (string-match "[^-]-\\(.*\\)\\*" buffer-name)
  (match-string 1 buffer-name))

(defun dp-maybe-set-telnet-remote-echoes (&optional buffer-name)
  ;;@todo try doing unconditionally
  ;;hopefully this will fix the ugly ^H^H^Hs that show up for long commands.
  (setq telnet-remote-echoes nil))
;  (if (member (dp-remote-buffer-name-to-host (or buffer-name (buffer-name)))
;	      dp-shell-bogus-echoers)
;      (setq telnet-remote-echoes nil)))
  

(dp-deflocal dp-shells-favored-shell-other-window-p t
  "Should going to a preferred buffer do so in another window.  
My current feeling is that if you've chosen a favored buffer, you may want to
see it and the favoring buffer.")

(dp-deflocal dp-shells-favored-shell-buffer nil
  "This tells, if non-nil, which shell buffer to select when using dp-shell.
Values:
nil --> No preference.  Traditional behavior.
buffer --> Switch to this buffer as controlled by
string --> Get the buffer and do buffer action.
           `dp-shells-favored-shell-other-window-p'
cons --> car is buffer, cdr is overriding other-window-p.")

(dp-deflocal dp-shell-mode-abbrev-table nil
  "Our shell-mode abbrev table.")

(defun dp-shell-refresh-abbrevs (&optional newest-abbrevs reset-p)
  "Set `dp-shell-mode-abbrev-table' to current table.
This is called from `dp-abbrevs'.  We save this here so we can set
`local-abbrev-table' in our mode-hook.  This is called with the shell buffer
being refreshed as the current-buffer."
  (interactive)
  (when reset-p
    (setq dp-shell-mode-abbrev-table nil))
  (setq dp-shell-mode-abbrev-table 
        (dp-find-abbrev-table '(newest-abbrevs dp-shell-mode-abbrev-table))
        local-abbrev-table dp-shell-mode-abbrev-table))

;; For easy human access.
(defun* dp-bind-comint-line-mode-bindings (&optional
                                           (variant 'comint)
                                           (bind-position-aware-keys-p t))
  (interactive)
  (dp-shell-line-mode-bindings variant bind-position-aware-keys-p))

;;;###autoload
(defun* dp-comint-mode-hook (&optional (variant dp-default-variant))
  "Sets up personal comint mode options.
Called when shell, inferior-lisp-process, etc. are entered."
  ;; @todo XXX ??? do we need this here and in the comint-hook?
  (interactive)
  (dp-make-local-hooks '(comint-output-filter-functions
                         comint-input-filter-functions))
  (dp-shell-refresh-abbrevs nil 'reset)
  (setq dp-refresh-my-abbrevs-p 'dp-shell-refresh-abbrevs)
  (unless (dp-shell-ignored-buffer-p (buffer-name))
    (message "dp-comint-mode-hook, (not ignored) (major-mode-str)>%s<, bn>%s<" 
             (major-mode-str) (buffer-name))
    (dp-shell-common-hook variant)
    (dp-bind-comint-line-mode-bindings variant)

    ;; @todo make this work for other term mode
    (local-set-key [(control ?a)] 'dp-shell-home)
    (local-set-key "\ed" 'dp-shell-delete-line)
    (local-set-key "\eo" 'dp-shell-kill-ring-save)
    (local-set-key [(control ?w)] 'dp-shell-kill-line)
    )
  ;; NB: This may run too early to catch the actual function bound to the
  ;; [return] key.
  (setq-ifnil dp-orig-comint-input-sender comint-input-sender)
  (setq comint-input-sender 'dp-comint-input-sender)
  (dmessage "dp-comint-mode-hook done."))


(dp-deflocal dp-shell-ask-to-limit-comint-output-p nil
  "Doesn't work yet!")

(dp-deflocal dp-shell-killing-limited-output-proc nil
  "Killing results in output and hence recursive calls.")

(dmessage "Add functionality to allow for output to just be suppressed.
And maybe having a line count print out periodically?
Or write to a spill file.
Or both.")

;; Using comint version.
;; (defun dp-shell-filter-proc (proc string)
;;     (dp-file-size-limiting-process-filter proc string dp-original-shell-filter-function
;;                                 ;; Some average ? line length to convert to
;;                                 ;; characters.
;;                                 (and dp-shell-output-max-lines
;;                                      (* 2 dp-shell-output-max-lines))))
  
(defun dp-set-shell-max-lines (max-lines)
  "Set max lines per shell command output and return it."
  (interactive 
   "sMaximum number of output lines per shell (nil or < 0 --> unlimited; 0 --> default; 'fh --> current frame height)? ")
  (when (stringp max-lines)
    (setq max-lines (eval (read max-lines))))
  (setq dp-shell-output-max-lines
        (cond
         ((eq max-lines 'fh) (frame-height))
         ((eq max-lines nil) nil)
         ((numberp max-lines) max-lines)
         (t dp-shell-output-max-lines-default)))
  (message "dp-shell-output-max-lines set to %s%s" 
           dp-shell-output-max-lines
           (if (or (not dp-shell-output-max-lines)
                   (< dp-shell-output-max-lines 0))
               " (unlimited)"
             ""))
  (setq comint-buffer-maximum-size
        dp-shell-output-max-lines))

(dp-defaliases 'sml 'ssml 'dp-shell-set-max-lines 'dp-shells-set-max-lines 
               'dp-set-shell-max-lines)

(defun* dp-maybe-add-ansi-color (&optional force-it-p (filter-it-p t))
  (interactive)
)
;;fix for fsf   (let ((want-it-p (or force-it-p
;;fix for fsf                        (bound-and-true-p dp-wants-ansi-color-p))))
;;fix for fsf     (if (and want-it-p (dp-optionally-require 'ansi-color))
;;fix for fsf         (progn
;;fix for fsf           (setq dp-wants-ansi-color-p t)
;;fix for fsf           (ansi-color-for-comint-mode-on)
;;fix for fsf           ;; Cheesy hack to replace the nigh invisible green face used for
;;fix for fsf           ;; executables.
;;fix for fsf           (aset ansi-color-map 32 font-lock-string-face)
;;fix for fsf           ;; The cyan face for symbolic links sucks, too.
;;fix for fsf           (aset ansi-color-map 36 'dp-journal-extra-emphasis-face))
;;fix for fsf       (if filter-it-p
;;fix for fsf           ;; Filters any ANSI color escape sequences from output.  Can be
;;fix for fsf           ;; useful if some program insists on emitting ANSI color codes.
;;fix for fsf           (ansi-color-for-comint-mode-filter)
;;fix for fsf         ;; Turns the mode off.  Do nothing with anything.
;;fix for fsf         (ansi-color-for-comint-mode-off))))))

;;;###autoload
(defun* dp-shell-mode-hook (&optional (variant dp-default-variant))
  "Sets up shell mode specific options."
  (interactive)
  (if-boundp 'semantic-mrub-push-disable-p
      (setq semantic-mrub-push-disable-p t))
  (local-set-key "\t" 'dp-comint-dynamic-complete)
  (setq font-lock-defaults nil
        font-lock-keywords nil)
  ;;(dmessage "enter dp-shell-mode-hook, current-buffer: %s" (current-buffer))
  (setq comint-prompt-regexp "^[^#$%>\n]*[#$%>]+ *"
        comint-use-prompt-regexp t)
  (unless (dp-shell-ignored-buffer-p (buffer-name))
    (dp-maybe-add-compilation-minor-mode)
    ;;(font-lock-set-defaults)
    (dp-maybe-add-ansi-color)
    (loop for hook in '(comint-strip-ctrl-m 
                        dp-shell-lookfor-dir-change
                        dp-shell-lookfor-gdb
                        comint-truncate-buffer)
    do (add-hook (dp-sls variant '-output-filter-functions)
                 hook nil t))

    (dp-set-shell-max-lines t))
  
  ;; something wipes this out after the call to comint-mode-hook and here,
  ;; so we do it again.
  (dp-shell-refresh-abbrevs nil 'reset)
  (font-lock-set-defaults)
  (message "dp-shell-mode-hook, (major-mode-str)>%s<, bn>%s<, done." 
           (major-mode-str) (buffer-name)))

;;;###autoload
(defun dp-telnet-mode-hook ()
  "Sets up telnet mode specific options."
  (dp-maybe-add-compilation-minor-mode)
  (dp-maybe-set-telnet-remote-echoes)
  (message "dp-telnet-mode-hook, (major-mode-str)>%s<, bn>%s<" 
	   (major-mode-str) (buffer-name)))

(dp-deflocal dp-shell-last-parse-start 0
  "Position in shell buf where last error parse was done.")
;(make-variable-buffer-local 'dp-shell-last-parse-start)
;(setq-default dp-shell-last-parse-start 0)

(dp-deflocal dp-shell-last-parse-end 0
  "position in shell buf where last error parse ended.")
;(make-variable-buffer-local 'dp-shell-last-parse-end)
;(setq-default dp-shell-last-parse-end 0)

(defun dp-shell-set-enter-alist (enter-alist)
  (setq dp-shell-enter-alist enter-alist))

(defvar dp-shell-buffer-modes '(shell-mode ssh-mode gdb-mode comint-mode 
                                telnet-mode)
  "Modes that act like shells.")

(defvar dp-shell-default-enter-alist '( ;really compilation mode
                                       ("ssh-mode" . comint-send-input)
                                       ("gdb-mode" . comint-send-input)
                                       ("grep" . compile-goto-error)  
                                       ("compilation" . compile-goto-error)
                                       ("comint-mode" . comint-send-input))
  "Default action for the enter key in these modes.
New modes should add their defaults as they are created.")

(defun dp-shell-add-to-default-enter-alist (item)
  (add-to-list 'dp-shell-default-enter-alist item))

(defun dp-shell-reset-enter-alist ()
  (interactive)
  (dp-shell-set-enter-alist dp-shell-default-enter-alist))

;;
;; ??? Make old enter binding buffer local ???
;; Let's try it.
;;
(dp-deflocal dp-shell-enter-alist (dp-shell-reset-enter-alist)
  "ALIST of original bindings of shell-type mode enter-keys. 
Keyed by (major-mode-str)")

(dp-deflocal dp-shell-type-enter-func 'dp-shell-send-input
  "What we bind the enter key to in shell-type buffers.")

(defun dp-shell-type-enter-func-p (func)
  (get func 'dp-isa-shell-enter-func))

(defun dp-isa-shell-enter-func-lambda-p (func)
  (get func 'dp-isa-shell-enter-func-lambda))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; command position stuff
;;

(defvar dp-shell-last-cmds nil
  "Positions in shell buf where previous commands were issued.")
(make-variable-buffer-local 'dp-shell-last-cmds)

(defun dp-shell-init-last-cmds ()
  "Create an empty list for holding the positions of previous commands."
  (interactive)
  ;;(dmessage "dp-shell-init-last-cmds called.")
  ;;(ding)(ding)(ding)
  (setq dp-shell-last-cmds '()))

(defun dp-shell-last-cmd-pos ()
  "Return position in buffer where last command was issued, nil if none."
  (interactive)
  (if (not dp-shell-last-cmds)
      nil
    (nth (1- (length dp-shell-last-cmds)) dp-shell-last-cmds)))
 
(defvar dp-command-pos-list-max nil
  "If non-nil, then this is the maximum number of positions to save in
  the command position list.")

(defun dp-save-last-command-pos (&optional pos)
  "Add the position of the latest command to the command position list.  
This is where we will begin to scan for new errors.  We save multiple
addresses on a list so we can easily visit earlier commands.  Set to
POS if specified else to somewhere near point."
  ;;
  ;; current vintages of compile skip forward 2 line to bypass
  ;; the cd and grep/compile command, so we compensate by
  ;; backing up here.
  ;; we just use a buffer offset, not a marker... not worth
  ;; the extra resources.  We don't expect to edit the buffer.
  (let (num-to-trim)
    (setq dp-shell-last-cmds 
	  (append dp-shell-last-cmds 
		  (list (dp-mk-marker (or pos
                                          (save-excursion
                                            (forward-line -1)
                                            (line-beginning-position)))))))
    (if (and dp-command-pos-list-max
	     (> (setq num-to-trim 
		      (- (length dp-shell-last-cmds) dp-command-pos-list-max))
		0))
	(setq dp-shell-last-cmds (nthcdr num-to-trim dp-shell-last-cmds)))))

(defun dp-shell-find-cmd-pos0 (dir pos &optional wrap-skips-current)
  "Move to previous or next command position.
DIR is either 'forwards, '+ or 'backwards '- or nil. 
WRAP-SKIPS-CURRENT says to skip the current (and as yet unentered)
command position."
  (catch 'up
    (let* ((pos-list dp-shell-last-cmds)
	   (index (dp-find-element-containing-pos pos pos-list))
	   (llen (length pos-list)))
      
      ;;(message "1i: %d pt: %d" index pos)
      
      ;;(message "2i: %d pt: %d, pl: %d" index pos (nth index pos-list))
      
      (cond
       ((memq dir '(backwards -))
	;; before first position, wrap to end.  end is (point-max) or
	;; list-len -1, depending on wrap-skips-current
        (if (= index -1)
            (if wrap-skips-current
                (setq index (1- llen))
              (throw 'up (point-max))))

        ;; When moving backwards, being at the start of a command means
        ;; we want to move to the preceding command.  This makes multiple
        ;; backward commands work most naturally.

	(when (= pos (nth index pos-list))
	  (setq index (- index 1))
	  (if (< index 0)
	      (if wrap-skips-current
		  (setq index (1- llen))
		(throw 'up (point-max))))))
       ((memq dir '(forwards + nil))
	;;(message "i: %d pt: %d, pl: %d" index pos (nth index pos-list))
	(setq index (1+ index))
	(if (>= index llen)
	    (if (or
		 wrap-skips-current
		 (= pos (point-max))) 
		(setq index 0)
	      (throw 'up (point-max))))))
      (nth index pos-list))))

(defun* dp-shell-find-cmd-pos (dir pos &optional (num 1) wrap-skips-current)
  (if (memq num '(- 0))
      (if (eq num 0)
          (dp-beginning-of-buffer)
        (dp-end-of-buffer))
    (setq-ifnil num (prefix-numeric-value num))
    (when (< num 0)
      (setq num (abs num)
            dir 'forwards))
    (loop for i from 1 to num do
      (setq pos (dp-shell-find-cmd-pos0 dir pos wrap-skips-current))
      finally return pos)))

(defun dp-shell-goto-cmd-pos (arg direction)
  (when dp-shell-last-cmds
    (goto-char 
     (dp-shell-find-cmd-pos direction (point) arg))
    (dp-highlight-point-until-next-command
     :colors dp-highlight-point-other-window-faces)))

(defun dp-shell-goto-prev-cmd-pos (&optional arg)
  (interactive "P")                     ;"_" - fsf
  (dp-shell-goto-cmd-pos arg 'backwards))

(defun dp-shell-goto-next-cmd-pos (&optional arg)
  (interactive "")                     ;"_" fsf
  (dp-shell-goto-cmd-pos arg 'forwards))

(defun dp-shell-adjust-command-positions (delta)
  ;;(dmessage "delta: %s" delta)
  (setq dp-shell-last-cmds
	(dp-left-shift-position-list dp-shell-last-cmds delta)))

(defun dp-shell-trimmed-command-positions (before-this)
  ;; BEFORE-THIS is a command position in the command positions ordered list,
  ;; so all we need to do is find it and return the tail of the list
  ;; beginning at said position. Which is what member does.
  (member (dp-mk-marker before-this) dp-shell-last-cmds))

(defun dp-shell-trim-command-positions (before-this)
  ;; Trim the list and set it.
  (setq dp-shell-last-cmds (dp-shell-trimmed-command-positions before-this)))

(defvar dp-grep-like-buffer-regexp 
  (regexp-opt '("[efi]?grep" "compilation"))
  "Regexp to recognize grep-like buffers.")

(defun dp-grep-like-buffer-p (&optional mode-str)
  (setq mode (or mode-str (major-mode-str)))
  "Determine if this (major-mode-str) represents a grep-like buffer."
  (posix-string-match dp-grep-like-buffer-regexp (major-mode-str)))

(dp-deflocal dp-shell-output-line-count 0
  "Number of lines ouput by the current command.")

;;; (dp-deflocal dp-shell-output-max-lines-default (* 3 163830)
(dp-deflocal dp-shell-output-max-lines-default 8192
  "Maximum number of lines which is kept in each shell buffer.
XXX @todo Limiter should be modified to handle lines.")

(dp-deflocal dp-shell-output-max-lines dp-shell-output-max-lines-default
  "*Number of lines which is kept in each shell buffer.
XXX @todo Limiter should be modified to handle lines.
NIL --> no limit.")

(dp-deflocal dp-shell-send-input-sender 'dp-shell-send-input
  "*What, ultimately, do we send our input with?
This allows us to do our fancy stuff and still call the correct sender.")

(defun dp-send-export-command (var val proc)
  (comint-simple-send proc
                      (format "export %s='%s'" var val)))

(defun dp-shells-export-terminal-dimensions (&optional cols lines)
  (if t
      nil
    ;; Need a way to send these commands without mucking up the history and
    ;; input line.
    (let* ((shell-buf (if (posix-string-match "\\*.*sh\\(ell\\)?.*\\*"
                                              (buffer-name))
                          (current-buffer)
                        (get-buffer "*shell*")))
           (shell-proc (get-buffer-process shell-buf))
           (shell-win (dp-get-buffer-window shell-buf)))
      (dp-send-export-command "COLUMNS"
                              (format "%s"
                                      (or cols
                                          (- (window-width shell-win) 5)))
                              shell-proc)
      (dp-send-export-command "LINES"
                              (format "%s"
                                      (or lines
                                          (/ (* 4 (window-displayed-height)) 5)))
                              shell-proc))))

(dp-deflocal dp-shell-first-command-p t
  "For some reason, in FSF Emacs, there is a problem adding compilation mode.
If it runs \"too soon\", then the keymap is hosed.  This is a major hack.")

(defun* dp-shell-send-input (variant
                             &key 
                             (dp-ef-before-pmark-func 
                              'dp-shell-set-error-func&goto-this-error)
                             &allow-other-keys)
  "MY send input function. Save buffer position of last command sent.
Then invoke original key binding if there was one, else try to call
xxx-send-input as a last resort."
  (interactive)

  (when dp-shell-first-command-p
    (dp-maybe-add-compilation-minor-mode)
    (setq dp-shell-first-command-p nil))

  ;; if we are above the prompt, or in a grep or compilation
  ;; buffer, then act like this is a goto-error request
  ;;; trying shell-mode w/o setting RET as a magic key
  ;; seems like some kind of magic is needed, since I want 
  ;; send-input after prompt and something like C-m before.
  ;;!<@todo can this be done more cleanly?
  (if (and dp-ef-before-pmark-func ; Set to nil to bypass this functionality.
           (or (dp-grep-like-buffer-p (major-mode-str))
               (not (fboundp (dp-sls variant '-after-pmark-p)))
               (not (funcall (dp-sls variant '-after-pmark-p)))))
      (funcall dp-ef-before-pmark-func current-prefix-arg)
    ;; save the position in the buffer where the latest command was issued.
    (dp-save-last-command-pos)
    ;; Set the environment variables telling the terminal dimensions before
    ;; every command.  It would be best to set it only when the window config
    ;; changes, but I don't know if there's a single place, a hook, or
    ;; whatever to do it. Setting environment variable for every command
    ;; isn't too onerous.
    (dp-shells-export-terminal-dimensions)
    (setq dp-shell-output-line-count 0)
    ;; try to call the original binding, trying the more specific buffer local
    ;; function variable before the default mode -> func mapping.
    (call-interactively (or 
                         (interactive-functionp 
                          dp-shell-original-enter-binding)
                         ;; This will always fail with v2 code.
                         (interactive-functionp 
                          (cdr (assoc (major-mode-str) 
                                      dp-shell-enter-alist)))
                         (and (message 
                               "No func assoc w/mode %s, trying defaults." 
                               (major-mode-str))
                              nil)
                         (interactive-functionp dp-shell-send-input-sender)
                         (interactive-functionp 
                          (dp-sls variant '-send-input))
                         (interactive-functionp (default-value 
                                                  'comint-input-sender))
                         'comint-simple-send))
    ;; You can't say I didn't try.
    ))

;; Older & way different version of `dp-shell-send-input' in vc.


(defun dp-compilation-mode-reset (&optional arg)
  (interactive "P")
  (dp-set-compile-like-mode-error-function)
  (dp-shell-goto-this-error (not arg)))

(defun* dp-define-compilation-mode-like-keys (&optional 
                                              (map compilation-minor-mode-map))
  (define-key dp-s-mode-map [?r] 'dp-error-parse-point-to-end)
  (dp-define-keys map `([(meta ?n)] dp-next-error
                        [(meta ?o)] dp-shell-magic-kill-ring-save
                        [(control meta return)] 
                        (kb-lambda 
                            (dp-error-parse-point-to-end 'force-reparse))
                        [(control meta ?j)] dp-shell-resync-dirs
                        [(control ?c) (control ?c)]
                        dp-maybe-kill-process-buffer-and-window)))

;;;###autoload
(defun dp-compilation-mode-hook ()
  (dmessage "enter dp-compilation-mode-hook")
  ;; nil makes 'em buffer local.
  (dp-define-compilation-mode-like-keys)
  (dp-define-keys compilation-mode-map 
                  '([return] dp-shell-set-error-func&goto-this-error
                    )))

(add-hook 'compilation-mode-hook 'dp-compilation-mode-hook)


(defun dp-add-compilation-minor-mode (buf)
  "Add in compilation minor mode to current or specified buffer."
  (save-excursion
    (when buf
      (set-buffer buf))
    (compilation-shell-minor-mode 1)
    (dp-define-compilation-mode-like-keys)))

(defun dp-shells-parse-error-region (beg end &optional reuse-last-parse)
  "Parse the specified region of a file.
if REUSE-LAST-PARSE is non-nil and the beg and end are contained within
the last parsed region, then don't perform a parse."
  ;;(message "reuse %s, beg: %s, end: %s, dpp: %s, dppe: %s" 
  ;;	   reuse-last-parse 
  ;;	   beg end 
  ;;	   dp-shell-last-parse-start dp-shell-last-parse-end)
  (unless (and reuse-last-parse
	       (>= beg dp-shell-last-parse-start)
	       (<=  beg dp-shell-last-parse-end)
	       (>= end dp-shell-last-parse-start)
	       (<=  end dp-shell-last-parse-end))
    (save-restriction
      (message "dp-shells-parse-error-region: reparsing...")
      (narrow-to-region beg end)
      (goto-char beg)
      (setq dp-shell-last-parse-start beg
	    dp-shell-last-parse-end end)
      (if (dp-xemacs-p)
	  (compile-reinitialize-errors t)
	(compilation-parse-errors beg end)))))

(dp-deflocal dp-shell-original-enter-binding nil
  "The original binding on the enter like key.")

(defun dp-mk-enter-kb-lambda (variant &optional func 
                              &rest enter-func-key-args
                              &allow-other-keys)
  "Make a shell enter key function, curried with FUNC and VARIANT."
  (unless variant
    ;;(ding)(ding)
    (dmessage "dp-mk-enter-kb-lambda: variant is nil, setting to 'comint")
    (setq variant 'comint))
  (let ((newf (gentemp "dp-sh-enter-")))
    (fset newf `(lambda ()
                  (interactive)
                  (apply (or (quote ,func) dp-shell-type-enter-func) 
                         (quote ,variant) (quote ,enter-func-key-args))))
    (map-plist (lambda (var val)
                 (put newf var val))
               '(dp-isa-shell-enter-func-lambda t
                 dp-isa-shell-enter-func t))
    newf))

(defun* dp-shell-bind-enter-key (keymap
                                 &rest enter-function-key-args
                                 &key
                                 (variant dp-default-variant)
                                 (current-binding (key-binding "\C-m" t))
                                 (new-binding dp-shell-type-enter-func)
                                 &allow-other-keys)
  "Bind the enter key to NEW-BINDING and save CURRENT-BINDING.
CURRENT-BINDING is saved in the buffer local variable
`dp-shell-original-enter-binding'."
  (interactive)
  (message "setting C-m to dp-mk-enter-kb-lambda: for mode>%s<" major-mode-str)
  (message "  the binding was: %s" current-binding)
  (setq-ifnil dp-shell-original-enter-binding current-binding)
  ;;!<@todo Use a buffer local key binding?
  ;;(define-key keymap
  ;;!<@todo This can be a call to `dp-define-keys' since keymap is provided.
  (dp-define-keys
   ;; nil says to define keys as buffer local.
   (if (dp-buffer-local-keymaps-p)
       nil
     keymap)
   (list "\C-m" (if (dp-isa-shell-enter-func-lambda-p new-binding)
                    new-binding
                  (apply 'dp-mk-enter-kb-lambda variant new-binding 
                         enter-function-key-args))))
  (message "  the binding is: %s" (key-binding "\C-m" t)))

(defun* dp-bind-shell-type-enter-key (&rest enter-function-key-args
                                      &key
                                      (current-binding (key-binding "\C-m" t)) 
                                      (variant dp-default-variant) 
                                      keymap
                                      major-mode 
                                      new-binding
                                      &allow-other-keys)
  "Bind our shell mode enter key and save off the original binding
so that we can call it after we do our other stuff."
  (dmessage "current-buffer: %s" (current-buffer))

  (when (eq variant 'term)
    (let ((message "working on term mode, fancy enter key junk disabled."))
      (warn message)
      (dmessage message)
      (ding))
    (return-from dp-bind-shell-type-enter-key))
  
  ;;
  ;; is key already bound ???
  (if (dp-shell-type-enter-func-p current-binding)
      (progn
        (message "\C-m already bound >%s<." (key-binding "\C-m" t))
        ;;!<@todo there's a problem if this key is bound in a non-local map.
        ;;If so, then `dp-shell-type-enter-func-p' is true, but this buffer
        ;;will not have the original key binding saved.
        ;;HACK! set the key map's name here, most likely again, since later
        ;;invocations of this function will have more specific mode names.
        (dp-blm-set-map-name keymap)
        nil)
    ;;
    ;; the enter key is not yet bound by us.
    ;; we need to bind the enter key to our function which
    ;; resets the last-cmd pointer
    ;; and then calls the original function
    ;; store orig binding in an assoc indexed by the mode name
    ;; The assoc holds some specific defaults.
    (let ((major-mode-str (major-mode-str major-mode))
          el)
      (when (not new-binding)
        (unless major-mode
          ;;(ding) (ding)
          (dmessage "dp-bind-shell-type-enter-key: major-mode is nil"))
        (if (setq el (assoc major-mode-str dp-shell-enter-alist))
            (progn
              (setcdr el current-binding)) ; change this mode's association
          ;; make a new association for this mode.
          (setq dp-shell-enter-alist (cons (cons major-mode-str
                                                 current-binding) 
                                           dp-shell-enter-alist))))
      (apply 'dp-shell-bind-enter-key keymap 
             :variant variant 
             :current-binding current-binding 
             :new-binding new-binding
             enter-function-key-args)
      t                                 ; Yes, it's true; we bound the key.
      )))

(defun dp-comint-type-buffer-p (&optional name)
  "Determine if this is a shell type buffer."
  ;; (string-equal name "*shell*"))
  (posix-string-match 
   "^\\*\\([0-9]+\\)?\\([sr]sh-.*\\|telnet-.*\\|Python\\|shell\\|[efi]?grep\\|compilation\\|hugsxxx\\)\\*\\(<[0-9]+>\\)?$" 
   (or name (buffer-name))))

(defun dp-term-type-buffer-p (name)
  "Determine if this is a term type buffer."
  (posix-string-match 
   "^\\*\\(terminal\\)\\*$" (or name (buffer-name))))

(defun dp-shell-buffer-type (name)
  "Determine the kind of shell buffer we are."
  (cond
   ((dp-comint-type-buffer-p name) 'comint)
   ((dp-term-type-buffer-p name) 'term)
   (t nil)))

(defun dp-maybe-add-compilation-minor-mode () ;<:macmm|maybe-add:>
  "Add and init compilation minor mode if not already in that mode.
return t if we are in a shell type buffer, false otherwise."
  (interactive)
  (message "in dp-maybe-add-compilation-minor-mode %s" (buffer-name))
  (let ((is-shell-type (dp-shell-buffer-type (buffer-name))))
    (if is-shell-type
	(progn
	  (message "is shell type buf")

	  (save-excursion
	    (set-buffer (current-buffer))
	    (message "**%s, %s, %s, >%s<, %s**" 
                     compilation-shell-minor-mode 
		     compilation-minor-mode
		     (major-mode-str) 'compilation-mode
		     (compilation-buffer-p (current-buffer))))

	  (if (not (compilation-buffer-p (current-buffer)))
	      ;; we're not in compilation mode yet
	      (let ((current-binding (key-binding "\C-m" t)))
		(message "non compilation-buffer-p")
		(message "bind and add mode, orig>%s<, mn>%s<" 
			 current-binding (major-mode-str))
		(dp-add-compilation-minor-mode (current-buffer))
		;; M-. is becoming a habit... so the added complexity of
		;; giving C-m a dual personality is becoming less and 
		;; less worthwhile.  Make it go away.
		;; For all cases, to make the mental assoc C-m -> goto-error
		;; fade.
		(dp-bind-shell-type-enter-key :current-binding current-binding 
                                              :variant is-shell-type
                                              :keymap compilation-minor-mode-map)
		;; this is only needed and correct on the first entry.
                (goto-char (point-min))
		(dp-save-last-command-pos) ; (point-min))
		;;(dp-shell-init-last-cmds)
		(setq dp-shell-last-parse-start (point-min))))
	  t)
      (message "not shell type buf")
      nil)))

(defvar dp-current-error-function 'dp-do-next-compile-like-error
  "Most recently called function for which we'd like to use \\[dp-next-error] to go to the next result.
E.g. a compile, igrep or cscope results buffer.")

(defvar dp-current-error-function-args nil
  "List of args to go with `dp-current-error-function'
In order to allow nil to mean and arg of nil rather than NO args, the args
are kept in the cdr of a cons, e.g. (cons 'args-are-my-cdr real-args).  If
`real-args' is a symbol, then there are no args... e.g. we just (funcall
'fun), else we (apply fun (cdr args-cons)).")

(defun dp-shell-set-error-func&goto-this-error (&optional force-reparse-p)
  (interactive "P")
  (dp-set-compile-like-mode-error-function)
  (dp-shell-goto-this-error force-reparse-p))

(defun dp-shell-set-error-func&goto-this-error-other-window (&rest rest)
  (interactive)
  (call-interactively 'dp-shell-set-error-func&goto-this-error)
  (dp-slide-window-next 1))

;; !<@todo XXX Need to define a local `one-window-p' function and have it
;; return 1
;;finish later; (defun dp-shell-set-error-func&goto-this-error-this-window ()
;;finish later;   (interactive)
;;finish later;   (dp-set-compile-like-mode-error-function)
;;finish later;   (dp-shell-goto-this-error t))
  
;;;###autoload      
(defun dp-set-current-error-function (func use-no-args-p &rest args)
  (interactive)
  (unless dp-dont-set-latest-function
    (setq dp-current-error-function func
          dp-current-error-function-args 
          (cons 'args-are-my-cdr (or use-no-args-p args)))))

;;;###autoload
(defun dp-reset-current-error-function ()
  (interactive)
  (dp-set-current-error-function nil nil))

;;;###autoload
(defun dp-set-compile-like-mode-error-function ()
  (interactive)
  (dp-set-current-error-function 'dp-do-next-compile-like-error nil))

;;;###autoload      
(defun dp-next-error (&optional kill-buffer-first-p)
  "Find next error in shell buffer.
This key is globally bound.  It does special things only if it is
invoked inside a shell type buffer.  In this case, it ensures the
buffer is in compilation minor-mode and reparses errors if it detects
that a new command has been sent since the last parse.
KILL-BUFFER-FIRST-P says to kill the current buffer first. Useful when
examining a bunch of hits in a bunch of files to prevent ending up with tons
of open files.
NB! KILL-BUFFER-FIRST-P does not work. Don't use it. Seriously."
  (interactive "P")
  (if (let ((bss (buffer-substring (line-beginning-position) 
                                   (line-end-position))))
                                        ;(dmessage "1: bss>%s<" bss)
        (string-match "grep\\s-+finish"
                      (buffer-substring (line-beginning-position)
                                        (line-end-position))))
      (dmessage "1: dp-next-error DONE")
    (unless (eq last-command 'dp-next-error)
      (dp-push-go-back "Going to next error"))
    (let ((starting-point (point-marker))
          (starting-buffer (current-buffer))
          (args (cdr dp-current-error-function-args)))
      (if (symbolp args)
          (funcall dp-current-error-function)
        (apply dp-current-error-function args))
      (when (and kill-buffer-first-p
                 (not (equal (current-buffer) starting-buffer)))
        (with-current-buffer starting-buffer
          (dp-meta-minus)))
      (when (not (equal starting-point (point-marker)))
        (dp-highlight-point-until-next-command
         :colors dp-next-error-other-buffer-faces)))))
  
(defvar dp-dont-set-latest-function nil)

;;;###autoload
(defun dp-cscope-next-thing (func)
  (interactive)
  ;;(dp-cscope-buffer 'no-select)
  ;; Don't set the next error function here.
  ;; Only let it be set when the functions are called directly.
  (let ((dp-dont-set-latest-function t))
    (cscope-display-buffer)
    (call-interactively func)
    (cscope-select-entry-other-window)))

(defun dp-do-next-compile-like-error ()
  "Actually find next error in shell buffer.
This key is globally bound.  It does special things only if it is
invoked inside a shell type buffer.  In this case, it ensures the
buffer is in compilation minor-mode and reparses errors if it detects
that a new command has been sent since the last parse."
  (interactive)
  (when (dp-maybe-add-compilation-minor-mode)
    (setq compilation-last-buffer (current-buffer))
    (when (or (null (dp-shell-last-cmd-pos)) 
              (/= (dp-shell-last-cmd-pos) dp-shell-last-parse-start))
      ;; reparse the errors since it looks like we've issued
      ;; a new command since the last parse.
      ;; this keeps us from seeing old error messages.
      ;; if desired, we can revisit old errors
      ;; with dp-shell-goto-this-error
      ;; we use /= above so that if we clear the buffer
      ;; and -cmd becomes < -parse we still parse.
      (when (not (dp-shell-last-cmd-pos))
        (goto-char (point-min))
        (dp-save-last-command-pos))
      (dp-shells-parse-error-region (dp-shell-last-cmd-pos) (point-max))))
  
  ;; set things up so that we end up with the source file and
  ;; error listing (*shell*) in separate windows
  ;; q.v. all vars set.
  ;; !<@todo XXX this don't work. why?
  (if (string-match "grep\\s-+finish"
                    (with-current-buffer compilation-last-buffer
                      (buffer-substring (line-beginning-position) 
                                        (line-end-position))
;;                       (dmessage "2: bss>%s<" (buffer-substring 
;;                                               (line-beginning-position)
;;                                               (line-end-position)))
                      ))
      (and (dmessage "2: dp-next-error DONE")
           nil)
    (let ((pop-up-windows t)
          special-display-buffer-names
          special-display-regexps
          same-window-buffer-names
          same-window-regexps)
      (next-error 1)))
  ;; Needed??  We do it in dp-next-error.
  ;;   (dp-highlight-point-until-next-command)
  )

(defadvice compile-goto-error (after dp-advised-compile-goto-error activate)
  (dp-set-compile-like-mode-error-function)
  (dp-highlight-point-until-next-command))
                              
(defun dp-error-parse-point-to-end (&optional force-reparse-p)
  "Parse errors from point to end of buffer.  We narrow the buf to be
point to EOB to reduce the amount of parsing that is needed."
  (interactive "P")
  (dp-shells-parse-error-region (save-excursion
                                  (forward-line -2)
                                  (line-beginning-position))
                                (point-max)
                                (or (not (interactive-p))
                                    (not force-reparse-p))))

(defun dp-error-force-reparse-point-to-end ()
  (interactive)
  (dp-error-parse-point-to-end 'force-reparse))

;;;###autoload
(defun dp-shell-goto-this-error (&optional force-reparse-p)
  "Goto the error at point in the shell buffer.  
This has the fortunate side effect of setting 
things up so that dp-next-error (\\[dp-next-error]) 
picks up right after the error we just visited.
We use this instead of just `compile-goto-error' so that
we can goto errors anywhere in the buffer, especially 
earlier in the buffer. `compile-goto-error' has a 
very (too) forward looking view of parsing error buffers."
  (interactive "P")
  (setq compilation-last-buffer (current-buffer))
  (when (dp-maybe-add-compilation-minor-mode)
    (dp-error-parse-point-to-end force-reparse-p))
  (compile-goto-error))

(dp-deflocal dp-shell-ignoreeof 1
  "Just like bash's ignoreeof variable.")

(dp-deflocal dp-shell-num-eofs-seen 0
  "Counter for ignoreeof variable.")

(defun dp-shell-quit-p ()
  (interactive)
  (incf dp-shell-num-eofs-seen)
  (not
   (if (< dp-shell-num-eofs-seen dp-shell-ignoreeof)
       (message "Only seen %d of %d EOFs" 
                dp-shell-num-eofs-seen
                dp-shell-ignoreeof)
     nil)))
  
(defun dp-shell-quit-or-eof (prompt-regexp quit-string)
  (when (dp-shell-quit-p)
    (if (and (dp-on-last-line-p)
             (dp-looking-back-at prompt-regexp))
        (progn
          (insert quit-string)
          (comint-send-input))
      (comint-send-eof))))
  

(defun dp-shell-delchar-or-quit (arg)
  (interactive "p")
  (if (not (eq last-command 'dp-shell-delchar-or-quit))
      (setq dp-shell-num-eofs-seen 0))
  (dp-X-or-Y-at-pmark/eobp arg (kb-lambda
                                   (dp-shell-quit-or-eof "^((*pdb).*" "q"))
                           'dp-delete))

(dp-deflocal-permanent dp-input-ring-has-been-read-p nil
  "Have we already read the input ring file into this buffer?
This is needed so we can call the particular shell's main function more than
once.  For things like `dpy', it's easier to switch to the shell buffer by
reissuing the command.")

(defun dp-maybe-read-input-ring (&optional history-file)
  "Read HISTORY-FILE into this buffer's input ring if not already read.
HISTORY-FILE can be a single string or a list of strings of file names.  The
first file that is `dp-file-readable-p' is used.  Also sets
`comint-input-ring-file-name'."
  (setq-ifnil history-file (and comint-input-ring-file-name
                                (list comint-input-ring-file-name)))
  (dmessage "dp-maybe-read-input-ring, history-file>%s<" history-file)
  (unless dp-input-ring-has-been-read-p
    (dmessage "input ring>%s< unread as of yet." history-file)
    (if (not history-file)
        (progn
;;py-shell always sends nil           (ding)
;;py-shell always sends nil           (message "No history file to read.")
          )
      (when (setq comint-input-ring-file-name
                  (when history-file
                    (loop for h-file in (if (listp history-file) 
                                            history-file 
                                          (list history-file)) do
                                          (when (dp-file-readable-p h-file)
                                            (return h-file)))))
        (dmessage "readin... buf: %s, file: %s" (current-buffer)
                  comint-input-ring-file-name)
        (if-and-boundp 'dp-real-comint-read-input-ring
            (funcall dp-real-comint-read-input-ring)
          (comint-read-input-ring))
        ;; Extra info for debugging... it's non-nil which is all it needs to
        ;; be.
        (setq dp-input-ring-has-been-read-p (list (current-buffer) 
                                                  history-file))))))
  
(defun dp-specialized-shell-setup (&optional history-file hook-type 
                                   &rest bind-args)
  (interactive)
  (dp-maybe-read-input-ring history-file)
  (dmessage "dp-specialized-shell-setup calling dp-comint-mode-hook")
  (dp-comint-mode-hook)
  (dp-shell-bind-common-keys)
  (cond
   ((eq hook-type 'bind-enter)
    (apply 'dp-bind-shell-type-enter-key bind-args))))


(defun dp-python-get-process ()
  (or (get-buffer-process (current-buffer))
                                        ;XXX hack for .py buffers
      (get-process py-which-bufname)))

(defun dp-py-completion-setup-stolen ()
  (let ((python-process (dp-python-get-process)))
    (process-send-string 
     python-process
     "from IPython.core.completerlib import module_completion\n")))


;;;###autoload
(defun dp-py-shell-hook ()              ;<:psh|pysh:>
  "Set up my python shell mode fiddle-faddle."
  (interactive) 
  (dmessage "in dp-py-shell-hook")
  (make-variable-buffer-local 'dp-wants-ansi-color-p)
  (dp-maybe-add-ansi-color nil)
  (dp-specialized-shell-setup "~/.ipython/history" 
                              'bind-enter
                              ;; these are args to
                              ;; `dp-bind-shell-type-enter-key'
                              :keymap py-shell-map
                              :dp-ef-before-pmark-func nil
                              ;; ?????? 'dp-ignore-this-mode
                              )
  (when (fboundp 'ipython-complete)
    (local-set-key [tab] 'ipython-complete))

  (dp-py-completion-setup-stolen)

  (dp-define-buffer-local-keys 
   '([(meta return)] dp-end-of-line-and-enter
     "\C-d" dp-shell-delchar-or-quit
     [(control backspace)] dp-ipython-backward-delete-word) 
   nil nil nil "dpsh"))

(dp-optionally-require 'gdb)

(defvar dp-gdb-buffer-name nil
  "Latest gdb shell we've started.")

(defvar dp-gdb-default-func nil
  "Function to call when `dp-gdb-buffer-name' is nil or dead.")

(defun dp-gdb-run-to-here ()
  "Create a temporary gdb break point and then issue a `c' command."
  (interactive)
  (dp-gdb-issue-command-list (list (dp-mk-breakpoint-command 'temporary) "c")))
;;   (dp-gdb-issue-command (dp-mk-breakpoint-command 'temporary))
;;   ;;(gdb-refresh)
;;   (dp-gdb-issue-command "c")
;;   (setq current-gdb-buffer (current-buffer))
;; ;;   (gdb-refresh)
;;  )

(defun dp-gdb-issue-command (cmd &optional do-not-send-p gdb-buffer)
  (interactive "scmd name: \nSdo not send: ")
  (setq-ifnil gdb-buffer current-gdb-buffer)
  (set-buffer gdb-buffer)
  (goto-char (process-mark (get-buffer-process gdb-buffer)))
  (delete-region (point) (point-max))
  (insert cmd)
  (unless do-not-send-p
    (comint-send-input)))

(defun dp-gdb-issue-command-list (cmds &rest rest)
  (loop for cmd in cmds do
    (apply 'dp-gdb-issue-command rest)))

;;;###autoload
(defun dp-gdb-mode-hook ()              ;<:gdb:>
  "Set up my gdb shell mode fiddle-faddle."
  (interactive)
  (dmessage "in dp-gdb-mode-hook")
  (dp-specialized-shell-setup (list
                               (format 
                                "/home/davep/droppings/persist/gdb_history/%s"
                                (dp-short-hostname)))
                              'bind-enter
                              :keymap (current-local-map)
                              :dp-ef-before-pmark-func nil)
  (define-key c++-mode-map [(control ?x)(control space)] 'dp-gdb-run-to-here)
  (define-key c-mode-map [(control ?x)(control space)] 'dp-gdb-run-to-here)
  (local-set-key [(control meta down)] 'dp-gdb-scroll-up-source-buffer)
  (local-set-key [(control meta up)] 'dp-gdb-scroll-down-source-buffer)
;   (setq dp-wants-ansi-color-p nil)
  )


(defsubst dp-shell-reset-parse-info ()
  (setq dp-shell-last-parse-start 0
	dp-shell-last-parse-end 0))

;;;###autoload
(defun dp-ssh-mode-hook ()              ;<:ssh:>
  "Set up my ssh shell mode fiddle-faddle."
  (interactive)
  (dmessage "in dp-ssh-mode-hook")
  ;; The shell mode underlying the ssh mode handle the history reading.
  (dp-specialized-shell-setup nil 'bind-enter))

(defun* dp-clr-shell0 (&key (fake-cmd-p t)
                       (preserve-input-p t)
                       (save-contents-p 'ask))
  "Clear shell window and remembered command positions."
  (interactive)
  (dp-shell-reset-parse-info)
  (let* ((cur-input (buffer-substring (dp-current-pmark-pos) (point-max))))
    (when (or (and (eq save-contents-p 'ask)
                   (y-or-n-p "Save contents first? "))
              save-contents-p)
      (dp-save-shell-buffer))
    (dp-erase-buffer)
    (when fake-cmd-p
      (funcall dp-shell-type-enter-func
	       (dp-shell-buffer-type (buffer-name)))) ;; get us a prompt
    (dp-shell-init-last-cmds)
    (when preserve-input-p
      (dp-end-of-buffer)
      (insert cur-input))
    ))

(defcustom dp-shell-buffer-max-lines 1701
  "*Max lines to preserve in shell buf when using `dp-clr-shell' w/o a prefix arg."
  :group 'dp-vars
  :type 'integer)

(defun* dp-clr-shell (erase-buffer-p 
                      &optional dont-fake-cmd dont-preserve-input
                      (save-contents-p 'ask))
  (interactive "P")
  (if (or (and erase-buffer-p
               (not (Cu0p erase-buffer-p)))
          (eq last-command 'dp-clr-shell)
          ;; too many accidental real clears, when triggering a real clear by
          ;; 2 clear commands in a row.  so use only prefix arg to wipe
          ;; history
          nil)                          ;see if I like it.
      (dp-clr-shell0 :fake-cmd-p (not dont-fake-cmd) 
                     :preserve-input-p (not dont-preserve-input)
                     :save-contents-p save-contents-p)
    (let (point
          (old-point-max (point-max)))
      ;; See if we're over the max.
      (if (<= (line-number (point-max)) dp-shell-buffer-max-lines)
          (message "Not enough lines to bother clearing.")
        (dp-shell-reset-parse-info)
        (when (and (not (Cu0p erase-buffer-p))
                   (if (eq save-contents-p 'ask)
                       (y-or-n-p "Save shell buffer contents? ")
                     save-contents-p))
          (dp-save-shell-buffer))
        (dp-end-of-buffer)
        (forward-line (- dp-shell-buffer-max-lines))
        ;; move back to previous command so that we have the entire command
        ;; still in the history
        (setq point (point))
        (dp-shell-goto-prev-cmd-pos)
        (if (> (point) point)           ;did we wrap?
            (goto-char point))
        ;; Remove all of the command positions before the truncation point.
        ;; They're all markers so the remaining ones should adjust
        ;; themselves.
        (dp-shell-trim-command-positions (point))
	(delete-region (point-min) (point)))
      (dp-end-of-buffer)
      (dp-point-to-top 1))))


(dp-safe-alias 'cls 'dp-clr-shell)

(defun dp-clr-shell-dont-save ()
  "Clear shell buffer w/o asking to save contents."
  (interactive)
  (if (dp-shell-buffer-p)
      (dp-clr-shell0 :save-contents-p nil)
    (message "Must be in a shell buffer to use clsn.")))

(dp-defaliases 'clsx 'clx 'clsn 'dp-clr-shell-dont-save)

(defun dp-clr-shell-after-save ()
  "Clear shell buffer after saving contents."
  (interactive)
  (if (dp-shell-buffer-p)
      (dp-clr-shell0 :save-contents-p t)
    (message "Must be in a shell buffer to use clsy.")))

(dp-defaliases 'clss 'clsy 'dp-clr-shell-after-save)

(defun dp-shell-beginning-of-line ()
  ;;beginning of command line (after prompt)
  ;; If we're already @ comint-bol, then skip to the next command.
  ;; The context sensitive stuff makes automatic typing DTWT too often.  If I
  ;; don't notice I'm at comint-bol I'll automatically do 2 C-a and get to
  ;; then wrong place.
  (comint-bol nil))
;;   (let ((point (point)))
;;     (comint-bol nil)
;;     (when (= point (point))
;;       (beginning-of-line)
;;       (setq dp-shell-home-command-ptr (cdr-safe dp-shell-home-command-ptr)))))

(defvar dp-shell-home-command-list
  '(
    dp-shell-beginning-of-line
    ;;True beginning of line (C-p is previous-line here) unless we're already
    ;;there.
    dp-beginning-of-line-if-not-bolp 
    (lambda () (move-to-window-line 0))
    (lambda () 
      (dp-push-go-back "dp-shell-home^4" 
                       dp-consecutive-key-command-initial-point )
      (dp-beginning-of-buffer 'no-save-pos)))
  "Commands to run based on number of consecutive keys pressed.")

(defvar dp-shell-home-command-ptr dp-shell-home-command-list
  "Points to next command to run during a `dp-shell-home' consecutive
  key-sequence command.")

(defun dp-shell-home ()
  "Go bocl, bol, bow, bof."
  (interactive)
  (dp-consecutive-key-command 'dp-shell-home-command-ptr
			      dp-shell-home-command-list
			      'dp-shell-home))

(defvar dp-latest-py-shell-buffer nil
  "Newest buffer created by `dp-python-shell'.")

(dp-deflocal-permanent dp-ima-dpy-buffer-p nil)

(defun dp-ipython-buffer-killed ()
  (dmessage "dp-ipython-buffer-killed")
  (comint-write-input-ring)
  (and (eq (current-buffer) dp-latest-py-shell-buffer)
       (setq dp-latest-py-shell-buffer nil)))

;;;###autoload
(defun* dp-python-shell (&optional args)
  "Start up python shell and then run my shell-mode-hook since they
set the key-map after the hook has run."
  (interactive "P")
  ;; Hide history file... we'll manage it oursefs.
  ;; Hack around for python-mode bug:
  ;; It, `py-shell', sets mode name before switching to the Python buffer.
  (let ((py-buf (get-buffer "*Python*")))
    (when py-buf
      (dp-visit-or-switch-to-buffer py-buf)
      (return-from dp-python-shell)))
    
  (let ((dp-real-comint-read-input-ring (symbol-function 
                                         'comint-read-input-ring))
        mode-name input-ring-name)
    ;; Fucking ipython's advice for py-shell reads in the history before
    ;; switching to the Python shell buffer.  So if, e.g., we're in a regular
    ;; shell buffer, its history is hosed.  So we'll spoof the read and
    ;; capture the file name they want to read and use that as our history
    ;; file and read that AT ZE *RIGHT* TIME!
    (flet ((comint-read-input-ring (&rest r)
             (dmessage "in dummy comint-read-input-ring")
             (setq input-ring-name comint-input-ring-file-name)))
      (py-shell args))
    (setq comint-input-ring-file-name input-ring-name))
  ;; This should be done in the Python buffer by `py-shell', but isn't.
  (setq mode-name "Python")
  (setq dp-ima-dpy-buffer-p t)
  (dp-maybe-read-input-ring)
  (unless (eq dp-latest-py-shell-buffer (current-buffer))
    (setq dp-latest-py-shell-buffer (current-buffer))
    (local-set-key "\C-c\C-b" 'dpy-reload)
    (dp-py-shell-hook))
  (add-local-hook 'kill-buffer-hook 'dp-ipython-buffer-killed))

;;;###autoload
(defalias 'dpy 'dp-python-shell)

;;;###autoload
(defsubst dp-python-shell-this-window (&optional args)
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

;;;;;;;;;;;;;;;;;
;; term stuff
(defun dp-term-set-mode-from-pos (&optional pos buf-name)
  "Set the correct term mode based on cursor location:
  before pmark point: line mode
  at or after pmpoint: char mode"
  (when (dp-term-type-buffer-p buf-name)
    (if (>= (or pos (point)) (dp-current-pmark-pos))
	(term-char-mode)
      (term-line-mode))))
  
(defun dp-term-mode-common-keys ()
  "Set up term mode *my* way"

  (dp-shell-common-hook 'term)
  (setq term-prompt-regexp "^[0-9]+> ")
  (local-set-key "\en" 'bury-buffer)
  (local-set-key "\C-xb" 'switch-to-buffer)
  (local-set-key "\C-x\C-b" 'list-buffers)
  (local-set-key "\C-p" 'previous-line)
  (local-set-key "\M-x" 'execute-extended-command)

  (message "dp-term-mode-common-keys, (major-mode-str)>%s<, bn>%s<, map>%s<" 
	   (major-mode-str) (buffer-name) (current-local-map)))

;;;###autoload
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

(defun dp-shell-process-xdir (arg)
  "Let the dir tracking stuff track my xdir command.
It's getting to the point, though, that I should just do a `dirs' after 
every dir changing command.
Especially since this won't work as I don't have the other arg.
The code which calls the dirtrack other function isn't passing all of the
args so this can't work."
  (shell-process-pushd (substring (shell-command-to-string 
                                   (format "sed_path %s" arg)) 0 -1)))

(defun dp-shell-process-go (arg)
  "Use my `go' command to change directories.
Xemacs's view of the pwd often gets confuzed."
  (interactive "sdir: ")
  (shell-process-pushd (dp-expand-dir-abbrev arg)))

(defun dp-shell-dirtrack-other (cmd arg)
  ;; Let's take the easy way out and just do a dirs after every dir changing
  ;; command.
  ;; !<@todo XXX Is there a pre or post shell command hook?
  ;; Doesn't work... and it prints the dirs all over the screen and leaves the
  ;; original command on the next prompt line.
  ;; (shell-resync-dirs))
  ;; Since my commands print a compatible dirs output, let's use our command
  ;; as shell-dirstack-query. But the fact that we don't get all of the args
  ;; keeps xdir broken.
  ;; Also we'd need to prevent the shell from getting the original command in
  ;; order to prevent the command being issued twice.  Most of the commands
  ;; are not idempotent the way they are used.
  (cond 
   ((string-match cmd "\\`gr?\\'") (dp-shell-process-go arg))
   ((string-match cmd "\\`xdir\\'") (dp-shell-process-xdir arg))
   ((string-match cmd "\\`gb\\'")	;swap top two dirstack items
    (let ((dir (car shell-dirstack)))
      (when dir
	(setq shell-dirstack (cdr shell-dirstack))
	(shell-directory-tracker (format "pushd %s\n" dir)))))
   (t (error (format "Unknown cmd(%s) in dp-shell-dirtrack-other" cmd)))))

;; tell the dirtracker about my functions.
(setq shell-dirtrack-process-other-func 'dp-shell-dirtrack-other
      shell-dirtrack-other-regexp "g\\|gb\\|gr\\|kd\\|xdir")

(setq shell-popd-regexp (regexp-opt '("popd" "pd")))

(dp-deflocal-permanent dp-shell-last-abbrev-iter -1)

(defvar dp-shells-shell-in-other-frame-p nil
  "*Do what the name says.")

(dp-deflocal dp-shell-whence-buf nil
  "Buffer we were in when we ran `dp-shell'.")

(defun dp-shell-visit-whence (&optional arg)
  (interactive "P")
  (if arg
      (dp-shell arg)
    (if (and dp-use-whence-buffers-p
             dp-shell-whence-buf
             ;;(bufferp dp-shell-whence-buf)
             (buffer-live-p dp-shell-whence-buf))
        (dp-visit-whence dp-shell-whence-buf)
      (dmessage "Not whence'ing")
      (switch-to-other-buffer 1))))
;       (if (> (count-windows nil) 1)
;           (other-window 1)
;         (switch-to-other-buffer 1)))))

(dp-deflocal dp-shell-isa-shell-buf-p nil
  "Is this a shell buffer?  This is a list of symbols which ID the buffer.")

(defun dp-shell-buffer-p (&optional buffer 
				    pred
				    pred-args)
  (with-current-buffer (or buffer (current-buffer))
    (setq-ifnil pred dp-shell-isa-shell-buf-p)
    (dp-apply-or-value pred pred-args)))

(defsubst dp-shell-xxx-buffer-p (&optional buffer buffer-id-list)
  (let ((isa-shell-buf-p (dp-shell-buffer-p buffer)))
    (and isa-shell-buf-p
         (some (function
                (lambda (val)
                  ;; Problem if val is nil... it won't look like a match.
                  ;; We should never encounter this case.
                  (if (memq val (or buffer-id-list
                                    '(dp-shell shell)))
                      val)))
               isa-shell-buf-p))))

(defsubst dp-shell-ssh-buffer-p(&optional buffer)
  (dp-shell-xxx-buffer-p buffer '(ssh dp-ssh)))

(defsubst dp-shell-shell-buffer-p(&optional buffer buffer-id-list)
  (dp-shell-xxx-buffer-p buffer '(shell dp-shell)))

(defvar dp-shells-shell-buffer-list '()
  "All known buffers containing some kind of shell.
This is synchronously updated, so none of the icky scanning for buffers stuff
is needed.
That junk should be put to rest with extreme prejudice.")

(defvar dp-shells-ssh-host-name-fmt nil)
(defvar dp-shells-ssh-buf-name-fmt nil)
(defvar dp-shells-ssh-buf-name-regexp-fmt nil)

;; def: "*ssh-%s*", ie just prefix with *ssh- and suffix w/*
(defun dp-shells-make-ssh-buf-name (host-name shell-id)
  (and-boundp 'dp-shells-ssh-buf-name-fmt
    dp-shells-ssh-buf-name-fmt
    (format dp-shells-ssh-buf-name-fmt host-name)))

(defvar dp-shells-make-ssh-buf-name-fp 'dp-shells-make-ssh-buf-name
  "*Function to convert a ssh host-name an ssh buf-name")

(defun dp-shells-make-ssh-host-name (id)
  (if (and-boundp 'dp-shells-ssh-host-name-fmt
        dp-shells-ssh-host-name-fmt
        (format dp-shells-ssh-host-name-fmt id))
      id))

(defvar dp-shells-make-ssh-host-name-fp 'dp-shells-make-ssh-host-name
  "*Function to convert a numeric prefix arg to an ssh host-name")

(defun dp-shells-find-matching-shell-buffers (suffix &optional regexp buf-list)
  "Find all known shell buffers that either end with SUFFIX or match REGEXP.
REGEXP overrides suffix.  SUFFIX becomes \".*<suffix>$\".  It's just for
convenience."
  (let ((regexp (or regexp (format ".*%s$" (regexp-quote suffix)))))
    (loop for shell-buf in (or buf-list (buffer-list))
      when (and (dp-shell-buffer-p shell-buf)
                (buffer-live-p shell-buf)
                (posix-string-match regexp (buffer-name shell-buf)))
      collect shell-buf)))

(defsubst dp-shells-find-all-buffers (pred)
  (delq nil
        (mapcar (lambda (buffer)
                  (when (funcall pred buffer)
                    buffer))
                (dp-shells-find-matching-shell-buffers nil ".*"))))

(defsubst dp-shells-find-all-shell-buffers ()
  "Find all of my shell buffers."
  (dp-shells-find-all-buffers 'dp-shell-shell-buffer-p))

(defsubst dp-shells-find-all-ssh-buffers ()
  (dp-shells-find-all-buffers 'dp-shell-ssh-buffer-p))

;; Can't do it like this.  Use the "static" list.
;; because the ordering isn't guaranteed.
;; (defun dp-shells-next-shell-buffer ()
;;   (interactive)
;;   (let* ((asb (dp-shells-find-all-shell-buffers))
;;          (lp (memq (current-buffer) asb)))
;;     (or (cadr lp) (car asb))))

(defun dp-shells-get-shell-buffer-name-old (id &optional must-exist-p regexp)
  "Guess for existing or ask for new."
  (if (and (not id) (not regexp))
      "*shell*"
    (let* ((id (if (stringp id) (regexp-quote id) id))
           (regexp (if (eq id 'all)
                       ".*"             ;get 'em all
                     (format (or regexp
                                 "^\\*\\(shell\\*<%s>\\|ssh-.*%s\\*\\)$") 
                             id id)))
           (buffers (mapcar (function 
                             (lambda (buf-name)
                               (cons (buffer-name buf-name) nil)))
                            (dp-shells-find-matching-shell-buffers nil 
                                                                   regexp))))
      
      (cond
       ((eq 1 (length buffers)) (caar buffers))
       (buffers (completing-read "choose from shell-buffers? " 
                                 buffers nil must-exist-p))
       (t nil)))))

(defun dp-shells-get-shell-buffer-name (id &optional must-exist-p regexp)
  "Guess for existing or ask for new."
  (if (and (not id) (not regexp))
      "*shell*"
    (let* ((id (if (stringp id) (regexp-quote id) id))
           (regexp (or regexp "^\\*\\(shell\\*<%s>\\|ssh-.*%s\\*\\)$"))
           (regexp (if id
                       (if (eq id 'all)
                           ".*"         ;get 'em all
                         (format regexp id id))
                     regexp))
           (buffers (mapcar (function 
                             (lambda (buf-name)
                               (cons (buffer-name buf-name) nil)))
                            (dp-shells-find-matching-shell-buffers nil 
                                                                   regexp))))
      
      (cond
       ((eq 1 (length buffers)) (caar buffers))
       (buffers (completing-read "choose from shell-buffers? " 
                                 buffers nil must-exist-p))
       (t nil)))))

(defvar dp-shells-most-recent-shell nil
  "Most recent shell visited by one of my shell functions. (buf[name]. 'type)
E.g. a `switch-to-buffer' to a shell buffer isn't recorded here.
Maybe later.
NAME is a buffer or buf-name.  Type is (currently) one of: '(shell ssh)")

(defvar dp-shells-most-recently-created-shell nil
  "Most recent shell created by one of my shell functions. (buf[name]. 'type)
NAME is a buffer or buf-name.  Type is (currently) one of: '(shell ssh)")

(defun dp-shells-mk-recent-shell (&optional buffer type)
  (cons (or buffer (current-buffer))
        (or type 'shell)))

(defun dp-shells-set-most-recent-shell (&rest rest)
  (setq dp-shells-most-recent-shell (apply 'dp-shells-mk-recent-shell rest)))

(defun dp-shells-recent-shell-buffer (recent-one)
  (car-safe recent-one))

(defun dp-shells-recent-shell-type (recent-one)
  (cdr-safe recent-one))

(defun dp-shells-most-recent-shell-buffer ()
  (dp-shells-recent-shell-buffer dp-shells-most-recent-shell))

(defun dp-shells-most-recent-shell-type ()
  (dp-shells-recent-shell-type dp-shells-most-recent-shell))

(defun dp-shells-set-most-recently-created-shell (&rest rest)
  (setq dp-shells-most-recently-created-shell 
        (apply 'dp-shells-mk-recent-shell rest)))

(defvar dp-shells-most-recent-ssh-shell nil
  "Specifically the most recent ssh buffer.")

(defun dp-shells-guess-suffix (sh-name &optional default)
  "Guess a shell's suffix.  I use <nnn>.  This is very brittle."
  (if (and sh-name (posix-string-match "\\(<[^>\n]*>\\)$" sh-name))
      (match-string 1 sh-name)
    default))

;; This was mostly copied from shell-snarf-envar
;; Which says:
;; This was mostly copied from shell-resync-dirs.
;;
(defun dp-shells-setenv (var val)
  "Set a shell's environment VAR to VAL.
It isn't pretty."
  (interactive "svar? \nsval? ")
  (let* ((cmd (format "%s=%s; export %s\n" var val var))
	 (proc (get-buffer-process (current-buffer)))
	 (pmark (process-mark proc)))
    (goto-char pmark)
    (insert cmd)
    (sit-for 0)				; force redisplay
    (comint-send-string proc cmd)
    (sit-for 0)
    (comint-send-string proc "##\n")
    (goto-char (point-max))
    (set-marker pmark (point))))

(defvar dp-shells-shell-num-fmt "/%04d" ; <:shell prompt numeric id part:>
  "Note, many characters ef-up comint stuff, most seem to have to do with
  it's finding the end of the prompt.  Two in particular: > and #")

(defun* dp-shells-display-name (display-id-num &optional format)
  (setq-ifnil format "%s")
  (format format (if (equal display-id-num 0)
                     "spayshul"
                   display-id-num)))

(defun dp-shells-remove-buffer ()
  (setq dp-shells-shell-buffer-list
        (delq (current-buffer) dp-shells-shell-buffer-list)))

             
;;CO;(or (and dp-shells-favored-shell-buffer
;;CO;         (or (dp-visit-or-switch-to-buffer 
;;CO;              dp-shells-favored-shell-buffer) t))
;;CO;    (and (dp-buffer-live-p (car-safe dp-shells-most-recent-shell))
;;CO;         (or (dp-visit-or-switch-to-buffer 
;;CO;              (car-safe dp-shells-most-recent-shell)) t))))

(defun dp-shells-set-favored-buffer (name &optional other-window-p buffer)
  "Set the shell buffer we think the current buffer most wants to visit."
  (interactive "bBuffer: \nP")
  (setq dp-shells-favored-shell-buffer
        (cons name other-window-p)))

(defun dp-shells-get-favored-buffer (&optional buffer)
  (with-current-buffer (or buffer (current-buffer))
    (let ((fav (cond
                (dp-shells-favored-shell-buffer ; Something set in this buffer?
                 (if (consp dp-shells-favored-shell-buffer)
                     dp-shells-favored-shell-buffer
                   (cons dp-shells-favored-shell-buffer nil)))
                ((dp-shells-most-recent-shell-buffer))
                (t nil))))
      (setq fav (dp-shells-favored-shell-buffer-buffer fav))
      (and (dp-buffer-live-p fav)
           fav))))

(defun dp-fav-buf-p (buf)
  (dp-and-consp buf))
  
(defun dp-shells-favored-shell-buffer-buffer (fav-buf)
  (let ((buf (if (dp-fav-buf-p fav-buf)
                 (car fav-buf)
               fav-buf)))
    (when buf
      (get-buffer buf))))

(defun dp-shells-favored-shell-buffer-name (fav-buf)
  (when (dp-and-consp fav-buf)
    (setq fav-buf (car fav-buf)))
  (dp-buffer-name (dp-shells-favored-shell-buffer-buffer fav-buf)))

(defun dp-shells-favored-shell-buffer-flags (buf)
  (if (dp-fav-buf-p buf)
      (cdr buf)
    nil))

(defvar dp-shells-primary-shell-names '(- 1 nil ; (Cup) (not arg) (Cu0p))
                                        primary 0th zeroth main first 1st)
  "Other names by which shell<0> can be selected.")

(dp-deflocal dp-original-shell-filter-function nil
  "So we can use it later.")

(dp-deflocal dp-shell-num nil
  "Shell number, the number in the <>s")   

;;;###autoload
(defun* dp-shell0 (&optional arg &key other-window-p name other-frame-p)
  "Open/visit a shell buffer.
First shell is numbered 1 by default. 0 is too far away from the others. Save
it for something \"speshul\".
 ARG is numberp:
 ARG is >= 0: switch to that numbered shell.
 ARG is < 0: switch to shell buffer<\(abs ARG)>
 ARG memq `dp-shells-primary-shell-names' shell<0> in other window."
  (interactive "P")
  (let* ((specific-buf-requested-p current-prefix-arg)
         (pnv (cond
               ((member arg dp-shells-primary-shell-names)
                1)
               (t (prefix-numeric-value arg))))
         (fav-buf0 (dp-shells-get-favored-buffer (current-buffer)))
         (fav-buf (dp-shells-favored-shell-buffer-buffer fav-buf0))
         (fav-buf-name (dp-shells-favored-shell-buffer-name fav-buf))
         ;; The fan is the buffer who favors this shell.
         (fan-buf-name (format "<%s>" (buffer-name)))
         (fav-flags (dp-shells-favored-shell-buffer-flags fav-buf0))
         (other-window-p (or (eq arg '-) 
                             (and pnv (< pnv 0) (setq pnv (abs pnv)))
                             other-window-p
                             fav-flags
                             (nCu-p)))
         (switch-window-func (cond
                              ((functionp other-window-p) other-window-p)
                              (other-window-p 'switch-to-buffer-other-window)
                              (t nil)))
         ;; Ordered by priority.
         (sh-name (or name
                      (and
                       (stringp arg)
                       arg)
                      (and (equal arg '(4))
                           (read-from-minibuffer "Shell buffer name: "))
                      (and arg
                           (or (dp-shells-get-shell-buffer-name pnv)
                               (format "*shell*<%s>" 
                                       (dp-shells-display-name pnv "%s"))))
                      (and fav-buf0 fav-buf-name)
                      (and pnv
                           (or (dp-shells-get-shell-buffer-name pnv)
                               (format "*shell*<%s>" 
                                       (dp-shells-display-name pnv "%s"))))
                      (and (dp-buffer-live-p 
                            (dp-shells-most-recent-shell-buffer)))))
         ;; Is the shell already in existence?
         (existing-shell-p (dp-buffer-live-p sh-name))
         (sh-buffer (and sh-name
                         (get-buffer-create sh-name)))
         win fav-buf0 new-shell-buf)
    ;;(dmessage "arg>%s<, sh-name>%s<" arg sh-name)
    (if existing-shell-p
        (progn
          ;; I need to figure out how to force a [shell] buffer to display
          ;; itself in the CURRENT FRAME.
          (dp-visit-or-switch-to-buffer sh-buffer switch-window-func)
          ;;(switch-to-buffer sh-buffer)
          ;; We're in the requested buffer now.
          ;; If we came from a file with a live favored shell buffer, set up
          ;; the fiddly-bits(tm).
          ;;!<@todo This should be moved to any we visit this buffer, but
          ;;the hook doesn't exist yet.  I can still do it in all of my
          ;;visit  points.
          (when specific-buf-requested-p
            (dp-shells-set-most-recent-shell (current-buffer) 'shell))
          (when (dp-fav-buf-p fav-buf0)
            (setq dp-shell-whence-buf fav-buf
                  dp-use-whence-buffers-p t)
            (unless (string-match (regexp-quote fan-buf-name) fav-buf-name)
              (rename-buffer (format "%s%s" fav-buf-name fan-buf-name)))
            (message "Using fav buf: %s" fav-buf0))
          (dmessage "point: %s, window-point: %s" (point) (window-point)))
      ;; "else"
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; EA! ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;; Handle new shell case. We may have a name already.
      ;; These go into the editor's environment which will then be inherited
      ;; by the new shell.
      (setenv "PS1_prefix" nil 'UNSET)
      (setenv "PS1_host_suffix"
              (format "%s" (dp-shells-guess-suffix sh-name "")))
      (setenv "PS1_bang_suff" 
              (dp-shells-display-name pnv dp-shells-shell-num-fmt))
      (setenv "dp_emacs_shell_num" (format "%s" pnv))
      (save-window-excursion/mapping 
       (shell sh-buffer))
      (dp-visit-or-switch-to-buffer sh-buffer switch-window-func)
      ;;
      ;; We're in the new shell buffer now.
      ;;
      (setq dp-shell-num pnv)
      (setq dp-shell-isa-shell-buf-p '(dp-shell shell)
            dp-prefer-independent-frames-p t
            other-window-p nil
            dp-shell-buffer-save-file-name (dp-transformed-save-buffer-file-name
                                            dp-default-save-shell-buffer-contents-dir
                                            'dp-shellify-shell-name))

      (dp-shells-set-most-recently-created-shell sh-buffer 'shell)
      (dp-shells-set-most-recent-shell sh-buffer 'shell)
      ;; new shell (I hope!)
      (add-to-list 'dp-shells-shell-buffer-list sh-buffer)
      (add-local-hook 'kill-buffer-hook 'dp-shells-remove-buffer)
      (add-local-hook 'kill-buffer-hook 
                      (lambda ()
                        (dp-save-shell-buffer-contents-hook nil t)))
      ;; Set up a filter to prevent a flood of output from hanging us up.
      (setq dp-original-shell-filter-function 
            (process-filter (dp-get-buffer-process-safe)))
      ;;(set-process-filter (dp-get-buffer-process-safe) 'dp-shell-filter-proc)

      ;; Set the name once. All saves will pile up in the same file.  I've
      ;; added a manual save command and that will go there, too.  If shell
      ;; buffers get too big, then the performance begins to suck.  Many
      ;; things can be shell wide.
      ;; !<@todo XXX Make sure that as few things as possible (0!) look at
      ;; the entire buffer. Also, check into the fontifier. It may do evil
      ;; things.
      ;; Saves are currently done with sticky names so this isn't needed.
      ;;(setq-ifnil dp-save-buffer-contents-file-name 
      ;;            (dp-shellify-shell-name (buffer-name)))
      (dmessage "Loading shell input ring")
      (dp-maybe-read-input-ring))))

;;;###autoload
(defun* dp-shell (&optional arg &key other-window-p name other-frame-p)
  (interactive "P")
  ;; Don't set the whence buffer when leaving a shell buffer.
  (let ((whence-buf (unless (dp-shell-buffer-p) 
                      (current-buffer)))
        shell-buf)
    (if nil ; (equal current-prefix-arg '(4)) ; One plain C-u
        (dp-shell-cycle-buffers -1)
      (dp-shell0 arg :other-window-p other-window-p :name name
                 :other-frame-p other-frame-p)
      ;; WTF??;;(setq shell-buf (current-buffer))
      ;; we're now in the new shell buffer
      ;; Set the previous buffer
      (when whence-buf
        ;; Don't save a shell buffer as a whence.
        (setq dp-shell-whence-buf whence-buf)))))

;;;###autoload
(defun dp-shell-other-window (&optional arg)
  (interactive "P")
  (dp-shell arg :other-window-p t))

(defadvice comint-delchar-or-maybe-eof (around dp-comint-delchar-or-maybe-eof
                                        (arg)
                                        activate)
  "Delete the region if it is active, otherwise do the standard actions."
  (interactive "p")
  (if (not (dp-buffer-process-live-p))
      (dp-maybe-kill-this-buffer)
    (if (dp-mark-active-p)
        (delete-region (mark) (point))
      ad-do-it)))

(dp-deflocal dp-orig-comint-input-sender nil
  "RTFN.")

(defun dp-comint-input-sender (proc input)
  (interactive)                         ;for testing.
  (unless (posix-string-match dp-comint-discard-regexp input)
    (funcall dp-orig-comint-input-sender proc input)))
    
(defun dp-magic-columns-ls (ls-cmd &optional args cols echo-p lines)
  "Do an ls-like command in the *shell* buffer with COL columns.
COL defaults the the width of the window in which the first *shell* buffer is
displayed."
  (interactive "P")
  (when args
    (if (nCu-p)
        (setq args (concat (read-string "Args? " "" nil "") " ")
              cols (dp-read-number "Cols? " t 78))))
  (save-excursion
    (let* ((shell-buf (if (posix-string-match "\\*.*sh\\(ell\\)?.*\\*"
                                              (buffer-name))
                          (current-buffer)
                        (get-buffer "*shell*")))
           (shell-proc (get-buffer-process shell-buf))
           (shell-win (dp-get-buffer-window shell-buf))
           (echo "")
           (args (if (not (string= args ""))
                     (concat " " args)
                   args))
           ;; Space --> Don't put command in the history.  Well, we do want
           ;; the rest of the line and I don't want to lose that.
           ;; 
           (cmd (format "export COLUMNS=%s LINES=%s ; %s%s"
                        (or cols
                            (- (window-width shell-win) 5))
                        (or lines
                            (/ (* 4 (window-displayed-height)) 5))
                        ls-cmd
                        args)))
      (when (and shell-buf shell-win shell-proc)
        (dp-save-last-command-pos)
        (when echo-p
          (setq echo (format "echo '%s'; " cmd)))
        (setq cmd (format "%s%s" echo cmd))
        (dmessage "dp-magic-columns-ls, cmd>%s<" cmd)
        (comint-simple-send shell-proc cmd)))))

;; dp-ssh (id), host-name = f(id): f is currently a format-string. NEEDS to
;; change to a function(id)
;; ssh-buf-name = f(fmt-str, id, id): NEEDS to change to be f(host-name, ...)
;; try: 
;; 1) get-buffer(ssh-buf-name)
;; 2) find a buffer by regexp, regexp is f(dp-shells-ssh-buf-name-fmt)

(defvar dp-shells-ssh-host-name-fmt nil
  "How to turn a prefix-arg into a hostname.
Can be a regexp or a function")
(defvar dp-ssh-buf-name-fmt nil
  "How to turn a prefix-arg into a regexp to find an ssh buffer-name.
Format can have up to two %s codes in it.  Each is fed the current shell-id.
RSN: Or it may be `functionp'")
(defvar dp-ssh-shell-buf-name-fmt "\\*shell\\*\\(<%s>\\)?"
  "How to turn a prefix-arg into a regexp to find a shell buffer-name.
Format can have up to two %s codes in it.  This is used when an ssh buf
cannot be found using `dp-shells-ssh-buf-name-fmt'.")

(defun dp-collect-all-ssh-buffers ()
  "Find ALL existing ssh buffers."
  (dp-choose-buffers (function
                      (lambda (buf)
                        (and buf
                             (buffer-live-p buf)
                             (with-current-buffer buf
                               (and-boundp 'ssh-host ssh-host))
                             buf)))))
              
(defvar dp-gdb-buffer-history '()
  "Gdb buffer name history.")

(defvar dp-gdb-buffers '()
  "Gdb buffers we have active.  In completion list format (q.v.)")

(defun* dp-gdb-get-buffers (&key dead-or-alive-p)
  "Get the current list of gdb buffers, predicating on DEAD-OR-ALIVE-P."
  ;; `dp-choose-buffers' uses `buffer-list<f>' if the incoming buffer-list is
  ;; nil."
  (when dp-gdb-buffers
    (dp-choose-buffers (function
                        (lambda (buf-cons)
                          (when (or dead-or-alive-p
                                    (dp-buffer-process-live-p
                                     (car buf-cons)))
                            buf-cons)))
                       dp-gdb-buffers)))

;; Aliased because, currently, they do the same thing.
(defalias 'dp-gdb-buffer-completion-list 'dp-gdb-get-buffers)

(defun dp-gdb-clear-killed-buffer ()
  (interactive)
  ;; Get all living gdb buffers and make that the current list of gdb buffers.
  (setq dp-gdb-buffers 
        (delete (cons (buffer-name) 'dp-gdb)
                (dp-gdb-get-buffers :dead-or-alive-p nil))))

(defun* dp-gdb-most-recent-buffer (&rest dead-or-alive-p)
  (caar (apply 'dp-gdb-buffer-completion-list dead-or-alive-p)))

(defun dp-num-gdb-buffers ()
  (length (dp-gdb-buffer-completion-list)))

(defun dp-gdb-get-buffer-interactively (&optional use-most-recent-p)
  (list 
   (let ((prompt (if (dp-gdb-most-recent-buffer)
                     (format "gdb buffer name (default %s): " 
                             (dp-gdb-most-recent-buffer))
                   "gdb buffer name: "))
         (completion-list (dp-gdb-buffer-completion-list))
         (most-recent-buffer (dp-gdb-most-recent-buffer
                              :dead-or-alive-p t)))
     ;; WTF was this for?  It just ends up removing the current gdb buffer if
     ;; you're in it when you type C-g.
     ;;     (dp-gdb-clear-killed-buffer)
     (if (and use-most-recent-p
              (dp-buffer-process-live-p most-recent-buffer
                                        :default-p nil))
         most-recent-buffer
       (completing-read  prompt (dp-gdb-buffer-completion-list)
                         nil nil nil 
                         'dp-gdb-buffer-history 
                         (dp-gdb-most-recent-buffer))))))

(defun* dp-get-locale-rcs (&optional (env-var-name "locale_rcs"))
  (let ((rcs (getenv env-var-name)))
    (when rcs
      (mapcar (function
               (lambda (v)
                 (substring v 1)))
              (split-string rcs)))))

;;!<@todo finish this 
;;(defvar dp-locale-rcs-regexp (dp-))

(defun dp-gdb-scroll-down-source-buffer (num)
  (interactive "p")                    ; fsf - fix "_"
  (let ((buffer (and gdb-arrow-extent
                     (extent-object gdb-arrow-extent)))
        window)
    (if (not buffer)
        (call-interactively 'dp-scroll-down-other-window)
      (setq window (display-buffer buffer))
      (with-selected-window window
        (dp-scroll-down num)))))

(defun dp-gdb-scroll-up-source-buffer (num)
  (interactive "_p")
  (let ((buffer (and gdb-arrow-extent
                     (extent-object gdb-arrow-extent)))
        window)
    (if (not buffer)
        (call-interactively 'dp-scroll-up-other-window)
      (setq window (display-buffer buffer))
      (with-selected-window window
        (dp-scroll-up num)))))

(defvar dp-gdb-recursing nil)

;;;###autoload
;;needed? (defun dp-gdb-old (&optional new-p path corefile)
;;needed?   (interactive "P")
;;needed?   (unless new-p
;;needed?     (if (dp-buffer-process-live-p (dp-gdb-most-recent-buffer))
;;needed?         (dp-visit-or-switch-to-buffer (car (dp-gdb-get-buffer-interactively)))
;;needed?       (setq new-p t)
;;needed?       (if (dp-buffer-live-p (dp-gdb-most-recent-buffer))
;;needed?           (dp-maybe-kill-buffer (dp-gdb-most-recent-buffer)))))
;;needed?   (when new-p
;;needed?     ;; Want to get here if new-p or no live proc buffers.
;;needed?     (let ((dp-gdb-recursing t))
;;needed?       (call-interactively 'gdb))
;;needed?     (dp-add-or-update-alist 'dp-gdb-buffers (buffer-name) (or corefile 'dp-gdb))
;;needed?     (dp-add-to-history 'dp-gdb-buffer-history (buffer-name))
;;needed?     (when (boundp 'dp-gdb-commands)
;;needed?       (loop for key in (cons "." (dp-get-locale-rcs)) do
;;needed?         (loop for cmd in (cdr (assoc key dp-gdb-commands)) do
;;needed?           (insert cmd)
;;needed?           (comint-send-input))))))

(defvar dp-gdb-file-history '()
  "Files on which we've run `dp-gdb'.")

(dp-deflocal dp-gdb-buffer-max-size (* 45 3000)
  "How big can the gdb buffer get?")

;; (defun dp-file-size-limiting-process-filter (proc string original-filter
;;                                    max-size &optional max-percentage)
;;   "A process filter which limits the size of the process output buffer.
;; PROC is the process, STRING is the string to filter, ORIGINAL-FILTER is the
;; filter that would normally be called, MAX-SIZE is the maximum size in chars
;; and MAX-PERCENTAGE is the percentage of MAX-SIZE is the desired number of
;; chars that that will remain after the oldest output has been deleted.
;; If MAX-SIZE is nil, do not limit the size.
;; MAX-PERCENTAGE's default is determined in `dp-restrict-buffer-growth'."
;;   (prog1
;;       (when original-filter
;;         (funcall original-filter proc string))
;;     (save-excursion
;;       (when max-size
;;         (with-current-buffer (process-buffer proc)
;;           (dp-restrict-buffer-growth max-size max-percentage))))))

;; (defun dp-file-size-limiting-process-filter (proc string original-filter
;;                                              max-size &optional max-percentage)
;;   "A process filter which limits the size of the process output buffer.
;; PROC is the process, STRING is the string to filter, ORIGINAL-FILTER is the
;; filter that would normally be called, MAX-SIZE is the maximum size in chars
;; and MAX-PERCENTAGE is the percentage of MAX-SIZE is the desired number of
;; chars that that will remain after the oldest output has been deleted.
;; If MAX-SIZE is nil, do not limit the size.
;; MAX-PERCENTAGE's default is determined in `dp-restrict-buffer-growth'."
;;   (save-excursion
;;       (when max-size
;;         (with-current-buffer (process-buffer proc)
;;           (dp-restrict-buffer-growth max-size max-percentage))))
;;   (when original-filter
;;     (funcall original-filter proc string)))

(defun dp-gdb-filter (proc string)
  (gdb-filter proc string))
;;  (dp-file-size-limiting-process-filter proc string 'gdb-filter
;;                              dp-gdb-buffer-max-size))

(defvar dp-tacked-gdb-uniquifier 0
  "Gives each tacked on gdb buffer a unique name.
The gdb naming is embedded inside the function, so I need to uniqify it this
way.")

(defun* dp-mk-gdb-name (&optional name (uniquify-p t))
  (let (buffer-name)
    (setq name
          (if name
              (concat "gdb-" name)
            ;; Always uniquify when no name is specified.
            (setq uniquify-p t)
            "gdb-nemo"))
    (when uniquify-p
      (setq name (format "%s-%s" name dp-tacked-gdb-uniquifier))
      (incf dp-tacked-gdb-uniquifier))
    (setq buffer-name (generate-new-buffer-name name))
    (cons buffer-name (concat "*" buffer-name "*"))))

;;;###autoload
(defun dp-tack-on-gdb-mode (&optional buffer-or-name new-buffer-name)
  "Major hack to change a shell buffer which is running gdb into a gdb-mode buffer."
  (interactive)
  (let ((buffer (dp-get-buffer buffer-or-name))
        ;; This gets set to nil somewhere within this function (?why?) and
        ;; nil causes a problem when we first change windows. So we just
        ;; propagate the existing value. Seems to work.
        (tmp-font-lock-cache-position font-lock-cache-position))
    (switch-to-buffer buffer)
    (unless (eq new-buffer-name t)
      (dp-gdb-issue-command "set annotate 1" nil (current-buffer))
      (rename-buffer (cdr (dp-mk-gdb-name (or new-buffer-name
                                              "tacky")))))
    (dp-add-or-update-alist 'dp-gdb-buffers (buffer-name) 'dp-gdb)
    (dp-add-to-history 'dp-gdb-buffer-history (buffer-name))
    ;; If we exit gdb directly, we'll be back in the shell we started and the
    ;; gdb-mode hooks will be gone.
    (add-local-hook 'kill-buffer-hook 'dp-gdb-clear-killed-buffer)
    ;; XEmacs change: turn on gdb mode after setting up the proc filters
    ;; for the benefit of shell-font.el
    (gdb-mode)
    ;; gdb-mode, incredibly rudely, replaces this hook entirely.
    (add-local-hook 'kill-buffer-hook 'dp-gdb-clear-killed-buffer)
    (set-process-filter (get-buffer-process buffer) 'dp-gdb-filter)
    (set-process-sentinel (get-buffer-process buffer) 'gdb-sentinel)
    (gdb-set-buffer)
    (setq font-lock-cache-position tmp-font-lock-cache-position)
    (goto-char (point-max))
    ;; Some markers were made before the buffer was renamed which makes them
    ;; invalid.
    (set-marker comint-last-output-start (point))))


(defun dp-tack-on-gdb-mode+ ()
  ;; The ansi-color filter get hosed so we turn it off here.
  ;; I think this is fixed in dp-tack-on-gdb-mode. 
  ;; (ansi-color-for-comint-mode-off)
  (interactive)
  (dp-tack-on-gdb-mode)
  (ansi-color-for-comint-mode-filter))
  
;;;###autoload
(defun dp-gdb-naught (&optional name)
  "Run gdb on nothing. 
Useful for creating a gdb session from which you can attach to another
running process."
  (interactive)
  (let* ((names (dp-mk-gdb-name (or name "naught")))
         (buffer-name (car names))
         (gdb-buffer-name (cdr names)))
    ;; This is really stupid. We have to mimic the name make-comint will
    ;; use, Make it, switch to it, do junk, make the comint which will
    ;; make the same buffer name and switch to it.  This is NOT mine. It
    ;; is copped from `gdb'. LISP is, IIR, a *functional* language.
    (switch-to-buffer (get-buffer-create gdb-buffer-name))
    (or (bolp) (newline))
    (insert "Current directory is " default-directory "\n")
    (apply 'make-comint
           buffer-name
           (substitute-in-file-name gdb-command-name)
           nil
           "-fullname"
           nil)
    (set-process-filter (get-buffer-process (current-buffer)) 'dp-gdb-filter)
    (set-process-sentinel (get-buffer-process (current-buffer)) 'gdb-sentinel)
    ;; XEmacs change: turn on gdb mode after setting up the proc filters
    ;; for the benefit of shell-font.el
    (gdb-mode)
    (gdb-set-buffer)))

;;;###autoload
(defun dp-gdb (&optional interactive-only-arg path 
               corefile use-most-recent-p new-p prompt-p
               other-window-p force-interactive-p)
  "Extension to gdb that:
. Prefers the most recently used buffer if its process is still live,
. Else it asks for a buffer using a completion list of other gdb buffers,
. Else (or if nothing selected above) it starts a new gdb session.
ARG == nil  --> Use most recent session
ARG == '(4) --> Prompt for buffer
ARG == '-   --> Create new session
ARG == 0    --> New `dp-gdb-naught' session."
  (interactive "P")
  (when (or (interactive-p)
            force-interactive-p)
    (cond
     ((eq interactive-only-arg nil) (setq use-most-recent-p t))
     ((Cu-p) (setq other-window-p 'switch-to-buffer-other-window
                   use-most-recent-p t))
     ((nCu-p nil interactive-only-arg) (setq prompt-p t))
     ((equal interactive-only-arg 0) (setq new-p 0))
     ((Cu--p nil interactive-only-arg) (setq new-p t))))

  (unless new-p
    (if (and (dp-buffer-process-live-p (dp-gdb-most-recent-buffer
                                        :dead-or-alive-p t)
                                       :default-p nil)
             (let ((buf (car (dp-gdb-get-buffer-interactively
                              (and (not prompt-p)
                                   use-most-recent-p)))))
               (if (not (string= buf "-" ))
                   ;; Make sure we're true.
                   (or (dp-visit-or-switch-to-buffer 
                        buf
                        (and other-window-p
                             'switch-to-buffer-other-window)
                        ) t)
                 nil)))
        ()
      (setq new-p t)
      ;; Toss a buffer with a dead gdb proc.
      (dp-bury-or-kill-process-buffer (dp-gdb-most-recent-buffer
                                       :dead-or-alive-p t))))
  (when new-p                           ; New could have been changed above.
    (if (equal new-p 0)
        (dp-gdb-naught)
      ;; Want to get here if arg or no live proc buffers.
      (let ((dp-gdb-recursing t))
        ;; Let's grab the file name our-self, regardless of interactivity, so
        ;; we can put it into our own history.
        (setq-ifnil path (read-file-name "Run dp-gdb on file: " nil nil nil nil
                                         'dp-gdb-file-history))
        (gdb path corefile)
        (set-process-filter (get-buffer-process (current-buffer))
                            'dp-gdb-filter)))
    (add-local-hook 'kill-buffer-hook 'dp-gdb-clear-killed-buffer)
    (dp-add-or-update-alist 'dp-gdb-buffers (buffer-name)
                            (or corefile 'dp-gdb))
    (dp-add-to-history 'dp-gdb-buffer-history (buffer-name))
    (when (boundp 'dp-gdb-commands)
      ;; The node-name from locale-rcs will probably be used most.  But since
      ;; I have the whole list easily available, I may as well allow gdb
      ;; commands to be keyed to any of the locales.
      (loop for key in (cons "." (dp-get-locale-rcs)) do
        (loop for cmd in (cdr (assoc key dp-gdb-commands)) do
          (insert cmd)
          (comint-send-input))))))

;;;###autoload
(defun dp-gdb-other-window (&rest r)
  (interactive)
  (let ((current-prefix-arg '(4)))
    (call-interactively 'dp-gdb)))

(defun dp-gdb-most-recent-session ()
  (interactive)
  (dp-gdb nil nil nil t))

(defadvice gdb (around dp-advised-gdb activate)
  (dmessage "YOPP!")
  (if (and (not dp-gdb-recursing)
           (y-or-n-p "Wouldn't prefer dp-gdb? "))
      (call-interactively 'dp-gdb)
    ad-do-it))

(defun gdb-with-pid (file pid)
  "Same as `gdb-with-core' but say pid for less confusion."
  (interactive "fProgram to debug: \nsPID for attach: ")
  (gdb file pid))

;;   (if (y-or-n-p "Use dp-gdb? ")
;;       (dp-gdb current-prefix-arg file pid)
;;     (gdb file pid)))

(defun dp-shells-clear-n-setenv (var val)
  "Clear, then set if VAL is non-nil."
  (when val
    (dp-shells-setenv var val))
  ;; This environment isn't passed to ssh shell clients.
  (setenv var nil 'UNSET)
  (when val
    (setenv var val)))

;;; if no id, simple ssh
;;; since this is ssh, ssh buffers have precedence.
;;; create a host name from id, e.g.
;;; (for spiral)
;;; if id < 10 host-name = tc-le${id}
;;; if id < 20 host-name = z${id}
;;; else nil
;;; if host-name possible-buf-name = *ssh-${host-name}*
;;; if possible-buf-name exists go there; done;
;;; if one or more buffers matching  regexp
;;;   // *ssh-host1* or *ssh-host1*<n>
;;;   (format "\\*ssh-.*%s\\*\\([0-9]+\\)?$" id) exist
;;;    if 1 go there; done
;;;    completing read on rest
;;; if one or more buffers matching  regexp (format "\\*shell<%s>\\*$" id) exist
;;;    if 1 go there; done
;;;    completing read on rest
;;; if host-name create ssh buffer with that host-name ??? do I need to add <xx> if > 1?
;;; make shell buf *shell*<id>

(defvar dp-ssh-PS1_prefix "-SSH-"
  "Prefix added to PS1 to make the fact that we're in an ssh bufer more noticable.")

(defun dp-ssh-already-running-p (stat)
  "Very hackish way of determining if ssh found an existing session with the host."
  (and (listp stat)
       (memq 'run stat)))

(defun dp-bash-history-file-name (&optional host-name extry)
  (setq-ifnil extry "")
  (let ((name (or (getenv "HISTORY")
                  (dp-nuke-newline (shell-command-to-string 
                                    "mk-persistent-dropping-name.sh"))
                  (concat (or (getenv "HOME") "~")
                          "/.bash_history." (or host-name
                                                (dp-short-hostname))))))
    (concat name extry)))

;;;###autoload
(defun dp-ssh (&optional shell-id)
  "Find/create a shell buf, an existing ssh buf or create a ssh buf."
  (interactive "P")
  
  (warn "@todo Use last host as default. Last bunch of hosts in the completion
  list.  Will probably need to join and uniqueify the last hosts and the
  short list of hosts.")
  
  (if (and nil (not shell-id))
      (call-interactively 'ssh)
    (let* ((do-ssh-p (and shell-id (stringp shell-id)))
           (host-name (or do-ssh-p
                          (funcall dp-shells-make-ssh-host-name-fp shell-id)))
           (shell-id (or shell-id ""))  ; ?? needed any more?
           (do-shell (and host-name (string= host-name (dp-short-hostname))))
           ssh-buf-name
           ssh-buf-regexp
           isa-shell-buf-p
           host-info
           buf)
      (if do-shell
          (dp-shell)
        ;; look for a buffer corresponding to the host-name.
        ;; 1st, exact match
        (setq ssh-buf-name (dp-shells-make-ssh-buf-name host-name shell-id)
              ;; possible matches
              ssh-buf-regexp (format "%s\\(<[0-9]+\\)?$" ssh-buf-name))
        ;;!<@todo try without <> first?
        ;; See if a specific ssh buffer exists.
        (setq buf (or (and ssh-buf-name (get-buffer ssh-buf-name))
                      (dp-regexp-find-buffer 
                       (if (functionp 'dp-shells-ssh-buf-name-fmt)
                           (apply dp-shells-ssh-buf-name-fmt shell-id)
                         ssh-buf-regexp))
                      ;; the see if there's a shell buf with the same id.
                      (dp-regexp-find-buffer
                       (dp-funcall-if 'dp-ssh-shell-buf-name-fmt
                           shell-id
                         (format "\\*shell\\*<%s>" shell-id)))))
        (setq isa-shell-buf-p (and buf (dp-shell-buffer-p buf)))
        (when (and isa-shell-buf-p 
                   (not (memq isa-shell-buf-p '(ssh dp-ssh))))
          (ding)
          (unless (y-or-n-p (format "Non-ssh buffer [%s], go there? " 
                                    (buffer-name buf)))
            (setq shell-id nil   ; This will make `ssh' prompt for host name.
                  buf nil
                  do-ssh-p nil)))
        (if buf
            (dp-switch-to-buffer buf)
          (unless do-ssh-p
            (setq shell-id 
                  (dp-completing-read "dp-ssh arguments (host-name first): "
                                      dp-ssh-host-name-completion-list
                                      :initial-contents host-name
                                      :history 'ssh-history
                                      :dp-match-ret-fun 'cdar
                                      :dp-no-match-ret-fun 'car)))
          (if (setq host-info 
                    (cdr-safe (assoc shell-id 
                                     dp-ssh-host-name-completion-list)))
              (if (and (valid-plist-p host-info)
                       (plist-get host-info 'ip-addr))
                  (setq host-name shell-id
                        shell-id (plist-get host-info 'ip-addr))))
          ;; We can come through here multiple times (legitimately) but we
          ;; need to handle subsequent passes through the routine.
          ;; `ssh' returns nil when new or the status of the shell process.
          (unless (dp-ssh-already-running-p (ssh shell-id))
            ;; New ssh buffer.
            (unless (dp-in-completion-list-p 
                     dp-ssh-host-name-completion-list shell-id)
              (add-to-list 'dp-ssh-host-name-completion-list
                           (cons shell-id t)))
            ;;
            ;; We're in a newly created ssh shell
            ;;
            ;; !<@todo We should get this color via host-info.py...
            (add-to-list 'dp-shells-shell-buffer-list (current-buffer))
            (add-local-hook 'kill-buffer-hook 
                            'dp-save-shell-buffer-contents-hook)
            (add-local-hook 'kill-buffer-hook 'dp-shells-remove-buffer)
            (dp-set-text-color 'dp-ssh-bg-extent 'dp-remote-buffer-face)
            (dp-shells-clear-n-setenv "PS1_prefix" dp-ssh-PS1_prefix)
            (dp-shells-clear-n-setenv 
             "PS1_host_suffix"
             (format "'%s'" (dp-shells-guess-suffix (buffer-name) "")))
            (setq dp-shell-isa-shell-buf-p '(dp-ssh ssh))
            (setq comint-input-ring-file-name 
                  (dp-bash-history-file-name host-name))
            (dp-define-buffer-local-keys  
             (list [tab] (lambda () 
                           (interactive)
                           (ding)
                           (message "No TAB expansion in ssh buffer."))) 
             nil nil nil "dp-ssh")
            (dp-maybe-read-input-ring)))
        (setq dp-shells-most-recent-ssh-shell
              (setq dp-shells-most-recent-shell 
                    (cons (current-buffer) 'dp-ssh)))))))

(defun dp-comint-command (proc &rest args)
  (goto-char (point-max))               ; (process-mark proc))
  (apply 'insert args)
  (sit-for 0)             ; force redisplay (from shell.c::shell-resync-dirs)
  (funcall 'comint-send-string proc (dp-string-join args "")))

(defun dp-comint-command-2 (proc &rest args)
;;  (goto-char (point-max))               ; (process-mark proc))
;;  (apply 'insert args)
;;  (sit-for 0)             ; force redisplay (from shell.c::shell-resync-dirs)
  (funcall 'comint-send-string proc (dp-string-join args "")))

(defvar dp-ssh-gdb-history '()
  "Hostnames use so far by `dp-ssh-gdb'.")

;;;###autoload
(defun dp-ssh-gdb (ssh-args path &optional corefile)
  (interactive (list
                (completing-read "ssh arguments (host-name first): "
                                 dp-ssh-host-name-completion-list
                                 nil nil nil 'dp-ssh-gdb-history)
                (read-file-name "Run gdb on file: ")
                (when current-prefix-arg
                  (read-file-name "Name of corefile: "))))
  (dp-optionally-require 'ssh)
  (dp-optionally-require 'gdb)
  (let* ((buffer nil)
         (args (ssh-parse-words ssh-args))
         ;;(process-connection-type ssh-process-connection-type)
	 (host (car args))
	 (user (or (car (cdr (member "-l" args)))
                   (user-login-name)))
         (buffer-name (if (string= user (user-login-name))
                          (format "*ssh+gdb-%s*" host)
                        (format "*ssh+gdb-%s@%s*" user host)))
	 proc)
    
    (and ssh-explicit-args
         (setq args (append ssh-explicit-args args)))
    
    (cond ((null buffer))
	  ((stringp buffer)
	   (setq buffer-name buffer))
          ((bufferp buffer)
           (setq buffer-name (buffer-name buffer)))
          ((numberp buffer)
           (setq buffer-name (format "%s<%d>" buffer-name buffer)))
          (t
           (setq buffer-name (generate-new-buffer-name buffer-name))))
    
    (setq buffer (get-buffer-create buffer-name))
    (set-buffer buffer)
    (pop-to-buffer buffer-name)
    
    (cond
     ((comint-check-proc buffer-name))
     (t
      (comint-exec buffer buffer-name ssh-program nil args)
      (setq proc (get-buffer-process buffer))
      ;; Set process-mark to point-max in case there is text in the
      ;; buffer from a previous exited process.
      (set-marker (process-mark proc) (point-max))))
    
    (setq path (file-truename (expand-file-name path)))
    (let ((file (file-name-nondirectory path)))
    ;;; already done above (switch-to-buffer (concat "*gdb-" file "*"))
      (setq default-directory (file-name-directory path))
      (or (bolp) (newline))
      (dp-comint-command-2 proc "cd " default-directory "\n")
      (dp-comint-command-2 proc "echo Current directory is $PWD"  "\n")
      ;; gdb file-name -fullname -cd dir
      (dp-comint-command-2 proc (format "exec %s %s -fullname -cd %s\n"
                                        gdb-command-name
                                        (substitute-in-file-name path)
                                        default-directory))
      (set-process-filter proc 'dp-gdb-filter)
      (set-process-sentinel proc 'gdb-sentinel)
      ;; XEmacs change: turn on gdb mode after setting up the proc filters
      ;; for the benefit of shell-font.el
      (gdb-mode)
      (gdb-set-buffer))))

(defun dp-shell-resync-dirs ()
  (interactive)
  (let ((pm (if (dp-comint-at-pmark-p) ;(point-marker) acts oddly @ the pmark.
                (dp-comint-pmark)
              (point-marker))))         ;If we were @ pmark, follow it.
    (shell-resync-dirs)
    (goto-char (or pm (point-max)))))

;; Group these so any changes are propagated.
(progn
  (defvar dp-shell-hostile-chars
    (concat dp-ws+newline "{}()\\/!@#$^&*;'\"<>?|")
    "Characters that require escaping or other annoyances in the shell.")
  
  (defvar dp-shell-hostile-chars-regexp
    (concat "\\([" dp-shell-hostile-chars "]\\)" "\\|"  "\\(\\|\\[\\|\\]" "]\\)")
    "Detect those bothersome characters."))

(defvar dp-default-shellify-replacement-str ""
  "Use this string by default when cleaning up a string to be used as a file name.")

(defvar dp-default-save-shell-buffer-contents-dir "$HOME/log/shell-sessions/"
  "Where do the files go by default.  Will be created including any missing parents.")

(dp-deflocal dp-shell-buffer-save-file-name nil
  "This is set when each shell starts up. This allows all saves from of the
  shell to go into a single file. Using a timestamp from the time of the save
  gives each buffer a unique save file (mod resolution of the timestamp and
  save frequency).")

(defun dp-shellify-shell-name (name &optional args suffixer)
  (or dp-shell-buffer-save-file-name
      (let* ((replacement-str (or (car args) 
                                  dp-default-shellify-replacement-str))
             (new-name (replace-regexp-in-string dp-shell-hostile-chars-regexp
                                                 replacement-str
                                                 name)))
        ;; Surround the name with a less common file name character to make it
        ;; more visible.
        (concat "dp-shell-session%" new-name "%"
                (cond
                 ((not suffixer)
                  (dp-timestamp-string))
                 ((stringp suffixer)
                  suffixer)
                 (t (funcall-suffixer)))))))

(dp-deflocal dp-save-buffer-contents-file-name nil
  "As it looks.  Can also be used to set a name without using a name transformer.  Say at buffer creation time \(e.g. dp-shell)")


(defun* dp-save-shell-buffer-contents (&rest kw-args
                                       &key (buffer (current-buffer))
                                       (confirm-save-p 'ask)
                                       &allow-other-keys)
  (interactive)
  ;; Annotate the buffer.
  (if (or (not confirm-save-p)
          (y-or-n-p "Save shell buffer contents? "))
      (with-current-buffer (get-buffer buffer)
        (save-restriction
          (widen)
          (save-excursion
            ;; We can get multiple stanzas if we save >1 time.
            (goto-char (point-min))
            (insert "\n# Buffer saved on " (current-time-string) "\n")
            (insert "# In working dir " default-directory "\n")
            (insert "# Logged in as " (user-login-name) "@" (system-name) "\n")
            (insert "# Name: " (user-full-name) "\n")
            (insert "#\n"))
          (apply 'dp-save-buffer-contents
                 :file-name dp-save-buffer-contents-file-name
                 kw-args)))
    (message "Not saving shell buffer contents.")))

(defun dp-shell-visit-buffer-log ()
  (interactive)
  (if dp-save-buffer-contents-file-name
      (find-file dp-save-buffer-contents-file-name)
    (message "No save file for this buffer.")))

(defvar dp-save-shell-buffer-contents-exclusion-regexp
  "vilya"
  "Regexp to determine which shell buffers should not be saved.")

(defun dp-save-shell-buffer-contents-pred (buffer &optional regexp)
  (not (string-match (or regexp
                         dp-save-shell-buffer-contents-exclusion-regexp)
                     (buffer-name buffer))))

(defun dp-save-shell-buffer-contents-hook (&optional filter-pred
                                           confirm-save-p)
  (when (funcall (or filter-pred 'dp-save-shell-buffer-contents-pred)
                 (current-buffer))
    (dp-save-shell-buffer-contents :confirm-save-p confirm-save-p)))

(defun dp-save-shell-buffer (&optional ask-p buf)
  "Save the shell buffer BUF. 
The buffer could have useful information from past sessions or record
procedures that have been partly (0%) remembered."
  (setq-ifnil buf (current-buffer))
  (when (buffer-live-p buf)
    (with-current-buffer buf
      (dp-save-shell-buffer-contents-hook))))

(defun dp-shell-save-buffer-command (&optional confirm-p)
  (interactive "P")
  (if (or (not confirm-p)
          (y-or-n-p "Really save the shell buffer? "))
      (dp-save-shell-buffer)
    (message "Not saving shell buffer.")))

(defun dp-save-shell-buffers (&optional ask-not-p)
  (loop for buf in dp-shells-shell-buffer-list do
    (dp-save-shell-buffer buf ask-not-p)))
  
(defun dp-save-shell-buffers-hook ()
  "Leaves evidence that we're running in `kill-emacs-hook'.
It would be nice if there was a global `current-hook' or some such."
  (setq dp-in-kill-emacs-hook-p t
        dp-in-save-shell-buffers-hook-p t)
  (dp-save-shell-buffers t))

(add-hook 'kill-emacs-hook 'dp-save-shell-buffers-hook)

(defun dp-shell-next-buffer-in-cycle (&optional buffer)
  (let ((this-buf (memq (or buffer (current-buffer))
                        dp-shells-shell-buffer-list)))
    (car (or (and this-buf (cdr this-buf))
             dp-shells-shell-buffer-list))))
  
(defun dp-shell-cycle-buffers (&optional other-place-p buffer)
  (interactive "P")
  (let ((prefix-arg-val (prefix-numeric-value other-place-p)))
    (funcall
     (cond 
      ((not other-place-p) 'switch-to-buffer)
      ((>= prefix-arg-val 0)
       'switch-to-buffer-other-window)
      ((< prefix-arg-val 0)
       (if (= (length (device-frame-list)) 1)
           'switch-to-buffer-other-frame
       (dp-other-frame '-)
       (when (= prefix-arg-val -1)
           (delete-other-windows))
       'switch-to-buffer))
      (t 'switch-to-buffer))
     (dp-shell-next-buffer-in-cycle buffer))))

(defun dp-shell-insert-command-output (command-string)
  "Run COMMAND-STRING in a shell and insert the output.
Can this really not exist elsewhere?"
  (interactive (list (read-shell-command "Shell command: ")))
  (insert (shell-command-to-string command-string)))

(defun dp-shell-dp-shell-num-less-p (buf1 buf2)
  "Sort the buffers by dp-shell-buf-num."
  (funcall '<
           (symbol-value-in-buffer 'dp-shell-num buf1)
           (symbol-value-in-buffer 'dp-shell-num buf2)))

(defun dp-shell-dp-shell-num-greater-or-equal-p (buf1 buf2)
  (not (dp-shell-dp-shell-num-less-p buf1 buf2)))

(defun dp-shell-buffer-name-less-p (buf1 buf2)
  "Sort the buffers by name in some useful/comsistent manner.
The auto-generated names are numeric, and I have plans to allow them to be 
named. formatting with %s will not cause an error for anything 
reasonable: numbers, strings, symbols.
@todo XXX There will be the classic number sorting issue where 2 is > 100."
  (funcall 'string<
           (format "%s" 
                   (symbol-value-in-buffer 'dp-shell-num buf1))
           (format "%s" 
                   (symbol-value-in-buffer 'dp-shell-num buf2))))

(defun dp-shell-buffer-name-greater-or-equal-p (buf1 buf2)
  (not (dp-shell-buffer-name-less-p buf1 buf2)))

(defun dp-shells-next-shell-buf-num ()
  (interactive)
  (let* ((shell-buffers (sort (dp-shells-find-matching-shell-buffers 
                                nil ".*")
                              'dp-shell-dp-shell-num-greater-or-equal-p))
         (shell-num (symbol-value-in-buffer 
                     'dp-shell-num 
                     (car shell-buffers))))
    (1+ shell-num)))

(defun dp-next/prev-shell-buffer (next/prev &optional buffer)
  (interactive)
  (let* ((shell-buffers (sort (dp-shells-find-matching-shell-buffers 
                               nil ".*")
                              (if (eq next/prev 'prev)
                                  'dp-shell-dp-shell-num-greater-or-equal-p
                                'dp-shell-dp-shell-num-less-p)))
         (this-buf (memq (or buffer (current-buffer)) shell-buffers)))
    ;; Handle wrapping.
    (or (nth 1 this-buf)
        (car shell-buffers))))

(defun dp-next-shell-buffer (&optional buffer)
  (interactive)
  (dp-next/prev-shell-buffer 'next buffer))

(defun dp-prev-shell-buffer (&optional buffer)
  (interactive)
  (dp-next/prev-shell-buffer 'prev buffer))

(defun dp-shell-switch-to-next-buffer (&optional other-window-p buffer)
  (interactive "P")
  ;; It would be nice if there was someplace higher up that we could put the
  ;; no more buffers check but there's no clean way to do it since those
  ;; functions shouldn't consider no more buffers as an error.
  ;; Pass a no error flag?
  (let ((next-buffer (dp-next-shell-buffer)))
    (if (eq next-buffer (current-buffer))
        (dp-ding-and-message "No more shell buffers.")
      (funcall (if other-window-p
                   'switch-to-buffer-other-window
                 'switch-to-buffer)
               next-buffer)
      (dp-shells-set-most-recent-shell (current-buffer) 'shell))))

(defun dp-shell-switch-to-prev-buffer (&optional other-window-p buffer)
  (interactive "P")
  (let ((next-buffer (dp-next-shell-buffer)))
    (if (eq next-buffer (current-buffer))
        (dp-ding-and-message "No more shell buffers.")
      (funcall (if other-window-p
                   'switch-to-buffer-other-window
                 'switch-to-buffer)
               (dp-prev-shell-buffer))
      (dp-shells-set-most-recent-shell (current-buffer) 'shell))))


;;WTF?! (defun dp-shell-switch-to-prev-buffer (&optional buffer)
;;WTF?!   (interactive)
;;WTF?!   (switch-to-buffer (dp-prev-shell-buffer)))

(defun dp-shell-create-next-shell-buffer (&optional other-window-p)
  (interactive "P")
  (dp-shell (dp-shells-next-shell-buf-num)
            ;; the `when' converts non-nil to t
            :other-window-p (when other-window-p t)))

;;;
;;;
;;;
(setq dp-shells-dp-shells t)
(provide 'dp-shells)
