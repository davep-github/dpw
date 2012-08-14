;;;
;;; "Open Below"
;;; Magic M-return
;;;
;;; Originally began as an implementation of "o" command in Vi*.
;;;
;;; The baseline behavior is, loosely: got EOL, mode specific [return] and mode specific 
;;; I have been trying to add intelligence to it so it can do the most useful
;;; thing given that I want to create a new line (not a newline).
;;; Some examples:
;;; C-alikes:
;;; Add semi after a return (possibly a close paren?).
;;; Add an open { after the closing ) in a function definition.
;;; Python:
;;; Empty () after a non-class "def"
;;; self added after open on def ( if needed. (self) @ end of def-line w/no (
;;; And so on.
;;; 
;;; A mode specific function can be vectored to via a `dp-model-local'
;;; variable named 'dp-open-newline-func. Or a global vector of the same name
;;; can be used. They are checked in {mode-local, global} order.
;;;
;;;
;;; The C-mode one is hard as hell and is 99.9% kludge.
;;; I use c++ mode's indentation syntax functions.
;;; This is problematical since the indenter is solving a different problem.
;;; I also use the mode movement functions, eg beginning of statement, etc.
;;; !<@todo XXX Can semantic[-bovinator] help?
;;; !<@todo XXX language specific faces can be use to augment c++ mode
;;; syntax info.

;;; It will never be fully DWIM, so a "cycle through alternatives" mode is
;;; useful. Ie, a way (eg repeating the command) of having to command try one
;;; alternative after another. These alternatives can be narrowed to just
;;; those that make sense given the syntax guess, or all. Or, of course,
;;; both. Hacking in a cycle mode should be easy-ish. There is already some
;;; code to do it. It can also make a better improvement sooner.
;;; !<@todo XXX Make a meta-level cycler using mode specific data.
;;;
;;; Add a set of mode specific bindings to do specific cases.
;;; [C-d M-return +
;;; In C syntax alikes: !<@todo XXX Look at cc-mode's context new line mechanism.
;;; M-return] --> plain EOL, return, indent. ALL modes. Base behavior. This
;;; can help with many confuzing cases.
;;; ;]--> EOL, insert `;', return, indent. This case confuze current code.
;;; /] --> continue comment. Code exists.

;;; These generally work...
;;; { --> Close arg list w/ ), format function decl, add opening { on next
;;; line. This code exists.
;;; : --> C++ initializer list (this code exists)
;;; ... other things that can/do confuze the current code.


(defun dp-c-replace-statement-end (new-text)
  (dp-c-end-of-line)
  (if (looking-at ".")
      (replace-match (concat "\\1" new-text))
    (insert new-text)))

(defstruct dp-cob-state-t
  last-sub-command
  mod-begin-pos
  mod-end-pos
  next-suffix
  (under-score ""))

(dp-deflocal dp-cob-state (make-dp-cob-state-t)
  "State of last cob modification.")

(defun dp-c-open-newline (&optional mk-c++-init-list-p) ; <:cob:>
  (unless (eq last-command this-command)
    (setf (dp-cob-state-t-last-sub-command dp-cob-state) nil))
      
  (when mk-c++-init-list-p
    (end-of-line)
    (insert "\n:") (dp-c-indent-command))
  (let ((last-sub-cmd (dp-cob-state-t-last-sub-command dp-cob-state))
        (p (point))
        result my-sub-cmd
        suffix under-score
        std-suffix-present-p
        repeat-cmd
        t1 t2 t3)
    (end-of-line)
    (if (dp-looking-back-at dp-c*-junk-after-eos+)
        (goto-char (match-beginning 0))
      (goto-char p))
    (setq result
          (cond
           ;; What a bitch trying to get the order right.
   ;;;;;;;;;;;;;;;;;
           ;; Auto append `dp-c-typename-suffix' to typedefs, structs,
           ;; classes, and enums.
           ;;!<@todo Fix this to use the apropos suffix for the given
           ;;construct.  
           ;; !<@todo Allow consecutive `dp-open-newline' commands
           ;;to cycle through the various suffixes.
           ((progn
              (setq my-sub-cmd 'dp-cob-decorate-user-types
                    repeat-cmd (dp-cob-repeat-sub-command-p dp-cob-state
                                                             my-sub-cmd))
              (or repeat-cmd
                  (save-excursion
                    (beginning-of-line)
                    ;; Get some match data
                    (when (dp-c-looking-at-struct-decl-p
                           (line-end-position) t)
                      ;; match string 4 is non-nil when we are part of a
                      ;; subclassing statement.
                      (setq t1 (if (match-string 4)
                                   3
                                 0))
                      (setq under-score (if (string= "_" (match-string (+ t1
                                                                          3)))
                                            ""
                                          "_")
                            std-suffix-present-p (not
                                                  (string= (match-string 7) ""))
                            )
                      t))))
            (unless repeat-cmd
              (undo-boundary)
              (setq dp-cob-state
                    (make-dp-cob-state-t
                     :last-sub-command my-sub-cmd
                     :mod-begin-pos (match-end (+ t1 2))
                     :mod-end-pos (match-beginning 7)
                     :next-suffix dp-c-classname-suffix-list
                     :under-score under-score)))
            (when (or repeat-cmd
                      (not std-suffix-present-p))
              (setq suffix (dp-car&cycle-list 
                            (dp-cob-state-t-next-suffix dp-cob-state)
                            dp-c-classname-suffix-list))
              (delete-region (dp-cob-state-t-mod-begin-pos dp-cob-state)
                             (dp-cob-state-t-mod-end-pos dp-cob-state))
              (goto-char (dp-cob-state-t-mod-begin-pos dp-cob-state))
              (insert (dp-cob-state-t-under-score dp-cob-state) suffix)
              (setf (dp-cob-state-t-mod-end-pos dp-cob-state) (point)))
            (dp-c-ensure-opening-brace)
            (dmessage "cob: %s" my-sub-cmd)
            (message "Repeat command to cycle type decorators.")
            nil)


           ;; <:first:>
           ;; First case of syntactic interest.
   ;;;;;;;;;;;;;;;;;
           ((dp-in-a-c*-comment)
            (end-of-line)
            (c-context-line-break)
            nil)

   ;;;;;;;;;;;;;;;;;
           ;; Find some places where anything special is clearly not
           ;; desirable, such as after ;, }, etc. Just the basic eol, nl,
           ;; indent.
           ;; !<@todo XXX exp: adding goto-eol-p to handle
           ;;   if (aaa) {
           ;; if point is not @ eol then this breaks.
           ;; But what about other cases?
           ((dp-c-prev-eol-regexp "[;}{]" t)
            (dmessage "Looking back at special action killers.")
            t)

   ;;;;;;;;;;;;;;;;;
           ;; Add new line for current context {comment|backslashed}
           ((or ;; (dp-in-a-c*-comment)
                (dp-c*-pure-comment-line-p)
                (and (dp-in-cpp-construct-p)
                     (save-excursion
                       (beginning-of-line)
                       (re-search-forward "\\\\$" (line-end-position) t))))
            (dp-c-continue-comment-or-backslash)
            (dmessage "cob: dp-c-continue-comment-or-backslash")
            nil)

   ;;;;;;;;;;;;;;;;;
           ;; Case label... should be pretty unambiguous
           ((dp-c-in-syntactic-region '(case-label))
            (if (dp-c-looking-back-at-sans-eos-junk ":\\s-*" 'from-eol-p)
                ;; Already colon'd
                ()
              (dp-c-replace-statement-end ":"))
            (dmessage "cob: case label")
            t)
           
   ;;;;;;;;;;;;;;;;;
           ;; Clean up function or method:
           ;; add "(void)" if no args are present.  
           ;; replace () with void
           ;; formats decl if closing paren is in place.
           ((and (save-excursion
                   (dp-c-in-syntactic-region '(arglist-intro arglist-cont
                                               topmost-intro topmost-intro-cont
                                               func-decl-cont)))
                 ;; Don't do anything on pure "attribute" lines: virtual void
                 ;; int static etc.  !<@todo XXX ?Will a simple search for an
                 ;; open paren tell us we're on a decl line if there isn't
                 ;; one.  It seems that other types will confuse things now
                 ;; that I've learned that the whiny cry-babies of the ANSI
                 ;; C(++)? spec have reserved _t as a suffix.
                 (not (dp-looking-back-at (concat "\\(?:[^(]\\)"
                                                  dp-c-function-type-decl-re 
                                                  "\\s-*")))
                 (not (save-excursion
                        (end-of-line)
                        (dp-c-looking-back-at-sans-eos-junk ";\\s-*")))
                 (not (dp-c-looking-back-at-sans-eos-junk "};\\s-*" 
                                                          'from-eol-p))
                 ;; We *may not* end up wanting to format ourselves as a
                 ;; function decl. `dp-c-format-func-decl' tells us if it did
                 ;; so. If it did, we're done. Else we try something else.
                 (dp-c-format-func-decl))
            (dmessage "cob: voidify/format decl.")
            (setf (dp-cob-state-t-last-sub-command dp-cob-state) 'voidify)
            nil)

   ;;;;;;;;;;;;;;;;;
           ((and (setq my-sub-cmd 'add-newline-only)
                 (or (eq my-sub-cmd last-sub-cmd)
                     (dp-c-statement-terminated-p)))
            (setf (dp-cob-state-t-last-sub-command dp-cob-state) my-sub-cmd)
            (dmessage "cod: add a newline 0")
            t) ; Nothing to do but add a new line.

   ;;;;;;;;;;;;;;;;;
           ;; In a c++ class and after a protection label with or without a ":"
           ((dp-c-looking-back-at-sans-eos-junk "}\\|^\\s-*" t)
            (dmessage "cob: looking back at } or blankness")
            t)                          ; eol/newline/indent.
           
   ;;;;;;;;;;;;;;;;;
           ((let ((l (save-excursion
                       (end-of-line)
                       (dp-c++-class-protection-label))))
              (if l
                  (progn
                    (replace-match "")
                    (dp-c++-mk-data-section l)
                    t)
                nil))
            (setf (dp-cob-state-t-last-sub-command dp-cob-state) 
                  'mk-data-section)
            (dmessage "cob: make data section")
            nil)
           
   ;;;;;;;;;;;;;;;;;
           ;;
           ;; Add ; after return.
           ;; p is where we started.
           ((save-excursion 
              (c-beginning-of-statement)
              (dp-c-open-after-any-kw '("return" "break")))
            (dmessage "cob: add ;")
            (setf (dp-cob-state-t-last-sub-command dp-cob-state) 'add-semi-kw)
            t)
           
   ;;;;;;;;;;;;;;;;;
           ;; Add { after: if, else if, while, for
           ;; If following a fully parenthesized form.
           ;; Technically, if a FPF is on the line.
           ((save-excursion
              (let ((starting-point (point))
                    iswhile-p)
                (dp-c-beginning-of-statement)
                (and (or (looking-at (concat "\\s-*" 
                                             dp-c*-keywords-with-stmt-blocks))
                         ;; `[dp-]c-beginning-of-statement' works oddly with
                         ;; for(;;).  It takes you to the beginning of the
                         ;; internal sub-expressions:
                         ;; initializer/tester/reinit Hence the hideously
                         ;; ugly (and hopefully short-term) hack where we try
                         ;; to do things right, but then check in a more
                         ;; crude fashion with `beginning-of-line'.
                         (progn
                           (goto-char starting-point)
                           (beginning-of-line)
                           (looking-at 
                            (concat "\\s-*" 
                                    dp-c*-keywords-with-stmt-blocks)))
                         (setq iswhile-p (string= "while" (match-string 1))))
                     (search-forward "(" (line-end-position) t))))
            (goto-char (match-beginning 0))
            (dp-find-matching-paren)
            (if (dp-c-ensure-opening-brace :newline-before-brace nil
                                           :regexp-prefix ")")
                (progn
                  (dmessage "cob: add { to if and friends.")
                  (setf (dp-cob-state-t-last-sub-command dp-cob-state) 
                        'add-statement-block-{)
                  nil)
              t))          ; Didn't to anything special so just eol & indent.
           
   ;;;;;;;;;;;;;;;;;
           ;; pre-preprocessor constructs.
           ((dp-in-cpp-construct-p)
            (dp-c-indent-command)
            (dmessage "cob: cpp statement.")
            (setf (dp-cob-state-t-last-sub-command dp-cob-state) 'cpp-stmt)
            t)
           
   ;;;;;;;;;;;;;;;;;
           ;; Lone else?
           ((save-excursion
              (end-of-line)
              (dp-c-looking-back-at-sans-eos-junk 
               (concat "\\("
                       (dp-mk-c++-symbol-regexp "else")
                       "\\)"
                       "\\(\\s-*\\)")))
            (dmessage "matches: %s" (dp-string-join (dp-all-match-strings) "|"))
            (replace-match (format "\\2 {%s\\4"
                                   (if (> (length (match-string 3)) 2)
                                       (substring (match-string 3) 2)
                                     "\\3")))
;                              (dp-make-n-replacements 
;                               (- (/ (length (match-data)) 2) 3)  ; n
;                               3)))
            (setf (dp-cob-state-t-last-sub-command dp-cob-state) 'lone-else)
            (dmessage "cob: lone else?")
            t)

   ;;;;;;;;;;;;;;;;;
           ;; In a brace list? Add a comma if needed.
           ((and (dp-c-in-brace-list-p)
                 (save-excursion
                   (dp-c-end-of-line)
                   (not (dp-c-looking-back-at-comma-killers-p))))
            (dp-c-end-of-line)
            (dmessage "cob: auto brace-list comma")
            (insert ",")
            t)

   ;;;;;;;;;;;;;;;;;
           ((dp-c-in-syntactic-region
             '(member-init-intro member-init-cont func-decl-cont))
            (save-excursion
              (when (dp-c-prev-eol-regexp ")" 'goto-eol)
                (dmessage "cob: add comma in member-init")
                (dp-c-end-of-line)
                (insert ",")))
            t)
                         
   ;;;;;;;;;;;;;;;;;
           ;; Add comma to end of line?  <:cob-comma|cob:>
           ((and (not (dp-in-c-iostream-statement-p))
                 (not (save-excursion
                        (dp-c-end-of-line)
                        (dp-c-looking-back-at-comma-killers-p)))
                 (or (progn
                       (beginning-of-line)
                       (and (not (looking-at (concat "\\s-*"
                                                     (dp-mk-c++-symbol-regexp
                                                      "struct\\|class"))))
                            (not (re-search-forward
                                  "\\(^\\s-*#\\s-*[ie]\\)\\|\\([)\\\\:;,.}{*!@#$%^&:|]\\s-*$\\)\\|\\(^\\s-*$\\)"
                                  (line-end-position) t))))
                     (progn
                       (dp-c-end-of-line)
                       (or (and (dp-in-c-statement)
                                (not (dp-looking-back-at-close-paren-p 'final)))
                           (dp-c-in-syntactic-region
                            dp-c-add-comma-@-eol-of-regions))))
                 (progn
                   (beginning-of-line)
                   (when (and
                          (save-excursion
                            (not (re-search-forward
                                  dp-c-control-keywords
                                  (line-end-position) t)))
                          (save-excursion
                            (dp-c-end-of-line)
                            (let ((r (not (dp-looking-back-at 
                                           (concat dp-c-no-comma-after-these 
                                                   "\\(\\s-*$\\)")
                                           nil))))
                              r)))
                     (dp-c-replace-statement-end ",")
                     t)))
            (dmessage "cob: auto ,")
            (setf (dp-cob-state-t-last-sub-command dp-cob-state) 'add-comma)
            t)
           
   ;;;;;;;;;;;;;;;;;
           ;; Terminate function call with ; ? <:cob-semi|cob;:>
           ((dp-c-terminate-function-stmt)
            (dmessage "cob: auto ;")
            (setf (dp-cob-state-t-last-sub-command dp-cob-state) 
                  'add-semi-function)
            t)
           
   ;;;;;;;;;;;;;;;;;
           ;; Add stream operator?
           ((setq stream-op (dp-in-c-iostream-statement-p))
            (c-newline-and-indent)
            (insert stream-op " ")
            (c-indent-line)
            (dmessage "cob: auto <<|>>")
            (setf (dp-cob-state-t-last-sub-command dp-cob-state) 'stream-op)
            nil)
           
   ;;;;;;;;;;;;;;;;;
           (t
            (dmessage "cob: in default clause")
            ;;; XXX (barfolal)
            ;;; !<@todo XXX (end-of-line) 
            (dp-c-context-line-break)
            ;; !<@todo XXX "return" 'no-change-p
            nil)))
    (if (eq result 'no-change-p)
        nil
    (save-excursion
      (beginning-of-line)
      (dp-c-fix-comment)
      result))))


(defun* dp-cob-repeat-sub-command-p (cob-state sub-cmd &key l-last-command
                                     l-this-command)
  "Use state info to determine if we're repeating a sub-command.
Useful for cycling through alternatives."
  
  (and (eq (or l-this-command this-command)
           (or l-last-command last-command))
       (eq (dp-cob-state-t-last-sub-command cob-state) sub-cmd)
       sub-cmd))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun dp-c-continue-comment-or-backslash ()
  (interactive)
  (end-of-line)
  (c-context-line-break)
  (dmessage "cob: continue a comment or backslashed line.")
  (setf (dp-cob-state-t-last-sub-command dp-cob-state) 
        'continue-comment-or-backslashed-line)
  nil)

(provide 'dp-open-newline)
