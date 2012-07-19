;;;
;;; $Id: dpmisc.el,v 1.379 2005/07/03 08:20:10 davep Exp $
;;;
;;; Misc elisp code.
;;;
(message "dpmisc.el...")
(require 'advice)
(require 'ispell)
(require 'comint)
(require 'cl)
(require 'tempo)
(require 'compile)
(require 'appt)
(require 'time-date)

(require 'dp-vars)

;;;;;;;;;;;;;;;;;
;; 
;; Stuff I'm too lazy to code up...
;;
;; Simple way to make these:
;; 1) Record kbd macro
;; 2) M-x name-last-kbd-macro
;; 3) (format-kbd-macro 'name) on name from step 2.
;; 4) Add a `defalias' like below using the string from step 3.
(defalias 'dp-var-to-initializer    
  (read-kbd-macro
   (concat "C-a C-s ; RET <backspace> , <left> M-a C-r SPC <right>"
           " M-o M-a C-a C-d TAB C-s , RET <left> M-9 M-y <down>")))

(defalias 'insert-hrs-form 
  (read-kbd-macro
   "RET M: SPC RET T: RET W: RET T: RET F: RET S: RET S: RET 7*<up> 3*<right>"))

;;
;;
;; Simply run on (a copy of) the assignment and whalah[sic]
;; e.g.
;; before EXTRA_LIBS += -L $(ADDITIONAL_PACKAGE_DIR)/lib
;; after @echo "EXTRA_LIBS>$(EXTRA_LIBS)<"
(defalias 'mak-=-to-echo
  (read-kbd-macro
   (concat "C-a SPC C-a <M-backspace> TAB @echo SPC \" M-a ESC C-s "
           "\\s- RET <left> M-o > $ M-9 M-y M-0 <\" M-k <down> C-a")))

(defalias 'mak-=-to-echo0
  (read-kbd-macro 
   (concat "C-a TAB @echo SPC \" M-a C-s SPC RET <left> M-o M-k > $ M-9 M-y"
           " C-e <\" <down> C-a")))

;; Convert a Makefile variable into a line that displays it.
;; ^MISC_PROG_NAMES$
;; [ tab ]@echo "MISC_PROGS>$(MISC_PROGS)<"
(defalias 'mak-=-to-echo1
  (read-kbd-macro 
   (concat "C-a TAB C-a <M-backspace> TAB @echo SPC \" M-a C-e M-o > $ M-9 M-y"
           " C-e <\" <right>")))


(defalias 'dp-to-knr-open-brace
  (read-kbd-macro "ESC C-s ^ \\s- +{ RET <up> M-j"))

(defalias 'dp-prepare-to-move-c++-method
  (read-kbd-macro 
   (concat "C-a M-a C-s ( <left> M-[ <right> M-C-1 <right> M-o"
           " C-s { <left> M-[ <down> <up> C-a C-s } <left> M-[ M-a"
           " M-[ 2*<right> M-C-o C-x C-x DEL <up> C-e ; ")))

(defalias 'dp-move-c++-method
  (read-kbd-macro 
   (concat "C-a M-a C-s ( <left> M-[ <right> M-C-1 <right> M-o"
           " C-s { <left> M-[ <down> <up> C-a C-s } <left> M-[ M-a"
           " M-[ 2*<right> M-C-o C-x C-x DEL <up> C-e ; C-x 4 M-b <C-next>"
           " <up> C-e RET RET M-y")))

(defalias 'dp-fix-class-dox
  (read-kbd-macro 
   (concat "C-a C-s @class RET C-T <up> <C-right> <C-backspace> "
           "class 2*<C-s> RET <C-backspace> brief SPC")))

;;;;;;; end of kbd macros ;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defsubst dp-sticky-goto-char (offset &optional buffer)
  ;; !<@todo XXX The goto-char alone does not keep point when the buffer is
  ;; activated. re-search-forward has the ability to make it stick. How?
  ;; The C code looks close enough that I can't see where the difference is

  ;;   BUF_SET_PT (b, n);
  ;;   atomic_extent_goto_char_p = 1; [but it's supposed to be going away]
  (goto-char offset)
  
  ;;   BUF_SET_PT (buf, np);
  (re-search-forward ".*" nil t))
  

(defsubst and-listp (list?)
  (and (listp list?)
       ;; put the list last so it will be returned if non-nil and listp
       list?))

(defsubst nilp (any)
  (null any))

(defun dp-cons-to-list (cons)
  "Make a list from a cons: \(list (car CONS) (cdr CONS)). nil begets nil.
I return many things as conses, especially match and regions 
beginnings and ends."
  (when cons
    (list (car cons) (cdr cons))))

(defsubst dp-consecutive-command-p ()
  (eq this-command last-command))

(defsubst non-nil-symbolp (s)
  "NIL is an effin' symbol, but I usually don't want NIL to be considered a
  symbol."
  (and s (symbolp s)))

(defun dp-insert-isearch-string ()
  (interactive)
  (insert isearch-string))

(defsubst dp-buffer-syntactic-context (&rest rest)
  (save-match-data (apply 'buffer-syntactic-context rest)))

(defsubst dp-and-consp (x)
  (and x (consp x)))

(defun dp-write-this (this &rest args)
  "Add an admonishment to write THIS function.  Used as an unforgettable placeholder."
  ;; @note: concept: active development comment: things which don't let you
  ;; forget to handle them.  A more noticeable thing than the old XXX.
  (interactive)
  (dmessage "Write this: %s" (apply 'format this args))
  (ding)
  nil)

(defun* dp-pluralize-num (num &optional if-one not-one stem)
  "Picky ass way to pluralize a number of things correctly.
If you hate things like '1 things fucked up' vs '1 thing...', use this."
  (setq-ifnil if-one ""
              not-one "s"
              stem "")
  (concat stem (if (= num 1)
                   if-one
                 not-one)))

(defun dp-at-work-p ()
  (equal dp-mail-domain dp-mail-domain-work))

(defun dp-make-post-command-function (on-whom func &rest argses)
  (put on-whom 'dp-post-command-hook
       (cons func argses)))

(defun dp-make-highlight-point-function (on-whom &rest argses)
  (apply 'dp-make-post-command-function on-whom
         'dp-highlight-point-until-next-command
         argses))

(defun dp-mk-save-orig-symbol-name (sym-name)
  (dp-ify-symbol sym-name "save-orig-n-set-new>"))

(defun* dp-save-orig-n-set-new (var-sym new-var-value &optional docstring
                                &rest new-var-value-args)
  "Save a copy of VAR-SYM's value iff it hasn't already been backed up.
Set VAR-SYM's value according to NEW-VAR-VALUE.
NEW-VAR-VALUE can be a variable or \(functionp).  If \(functionp), then it is 
applied to NEW-VAR-VALUE-ARGS.
If NEW-VAR-VALUE is a cons, then the cdr tells us what it is.  
Currently only 'literal is defined.  This allows a way to quote a
NEW-VAR-VALUE that is functionp but that we don't want to be applied.
Always return the value from NEW-VAR-VALUE."
  ;; Simple dp-orig- prefix is too likely to have been done somewhere by hand.
  ;; !<@todo XXX put in own namespace
  (let ((save-sym (dp-mk-save-orig-symbol-name var-sym)))
    ;; iff
    (unless (boundp save-sym)
      (set save-sym (if (boundp var-sym) 
                        (symbol-value var-sym)
                      (format "%s was unbound." var-sym)))
      (put save-sym 'variable-documentation 
           (or docstring
               (format "Original value of `%s'%s." 
                       var-sym
                       (if (setq docstring (get var-sym 
                                                'variable-documentation))
			   ;; `format's %s handles all objects.
                           (format "%s%s" "\n--\n Original documentation:\n" 
                                   docstring)
                         "")))))
    (set var-sym (cond 
                  ((functionp new-var-value)
                   (apply new-var-value save-sym new-var-value-args))
                  ((consp new-var-value)
                   (case (cdr new-var-value) 
                     ('literal (car new-var-value))
                     ('self (symbol-value var-sym))
                     (t (error 'invalid-argument 
                               (format "new-var-value tag: %s" 
                                       (cdr new-var-value))))))
                  (t new-var-value)))))

(dp-defaliases 'dp-fset-preserve 'dp-save-orig-n-set-new)

;;!<@todo need to restore original doc string, too. 
(defun dp-get-orig-value (var-sym)
  (symbol-value (dp-mk-save-orig-symbol-name var-sym)))

(defun dp-restore-orig-value (var-sym)
  (set var-sym (dp-get-orig-value var-sym)))

(defun format? (fmt &optional args)
  (if args
      (apply 'format fmt args)
    fmt))

(defun format?-rest (fmt &rest rest)
  (format? fmt rest))
  
(defun princf (newline-flag &optional fmt &rest args)
  ;;(princ (format? fmt args))
  ;; (princf "0: newline-flag: %s, fmt: %s, args: %s\n" newline-flag fmt args)
  (let ((new-line (cond 
                   ((nilp newline-flag) "")
                   (t (setq args (cons fmt args)
                            fmt newline-flag)
                      "\n"))))
    (princ (format "%s%s" (apply 'format fmt args) new-line))
    ;; "<for debugging. REMOVE ME!"        ; for debugging
    )
  nil)

(defun* dp-member*-index (target list &optional (pred 'equal))
  (let* ((m (member* target list :test pred)))
    (when m
      (- (length list) (length m)))))

(defun dp-insert-most-recent-history-item (hist-var)
  (insert (car hist-var)))

(defun* dp-insert-cwd (&optional (expand-p t) (relative-to "~"))
  (interactive "P")
  (insert (if (and (not current-prefix-arg) expand-p)
	      default-directory
	    (concat (or relative-to "")
		    (expand-file-name (substitute-in-file-name "/var/") "~")))))

(defun dp-regexp-quote-and-make-word-regexp (string)
  (concat "\\<" (regexp-quote string) "\\>"))

(defun dp-string-join (list-o-strings &optional sep append-one-p prefix-one-p 
                       number-strings-p
                       string-pre-proc)
  "Join LIST-O-STRINGS separated with SEP.  SEP defaults to a space.
APPEND-ONE-P, if non-nil, says to append one SEP to the result.
PREFIX-ONE-P same kind of thing with a prefix.
append and pre are reversed for historical reasons.
NUMBER-STRINGS-P, if non-nil, says to prefix each string with an ordinal number.
If \(numberp NUMBER-STRINGS-P\), then NUMBER-STRINGS-P is the first ordinal.
If NUMBER-STRINGS-P is a string then convert to an int first.
STRING-PRE-PROC if non-nil is a function that is applied to each string
before it is joined. A useful example is `regexp-quote' when making a
compound regexp to match a list of specific strings."
  (let ((i (1- (cond 
            ((numberp number-strings-p) number-strings-p)
            ((stringp number-strings-p) (string-to-int number-strings-p))
            (t 0))))
        ;; Save an in-loop function call.  Would an optimizer find it?
        (dont-number-p (not number-strings-p)))
    (setq-ifnil string-pre-proc 'identity)
    (concat (if (stringp prefix-one-p) 
                prefix-one-p
              (if prefix-one-p sep ""))
            (mapconcat 
             (lambda (s)
               (setq s (funcall string-pre-proc s))
               (format "%s" (if dont-number-p
                                s
                              (incf i)
                              ;; Must be last as it is our return value.
                              (format "[%s]%s<" i s))))
             list-o-strings (or sep " "))
            (if (stringp append-one-p) 
                append-one-p
              (if append-one-p sep "")))))

(defun dp-regexp-concat (re-list &optional group-all-p quote-p)
  "Concatenate all of the regexps in RE-LIST separated by \\\\|.
@todo Should each list element be wrapped in shy grouping operators?
`\(?: ... \)'
This can now be done by calling `dp-concat-regexps-grouped' with non-nil shy-p.
QUOTE-P controls regexp quoting. t -> use `regexp-quote'. Anything else 
non-nil is assumed to be a quoting function.
"
  (concat (if group-all-p "\\(" "")
          (dp-string-join re-list "\\|" nil nil nil (if (memq quote-p '(t quote-p))
                                                        'regexp-quote
                                                      quote-p))
          (if group-all-p "\\)" "")))

(defun dp-re-concat (first last &optional shy-p quote-p)
  "Concatenate FIRST and LAST into an re that matches either.
WILL change number of groups unless shy-p is non-nil"
  (when quote-p
    (setq first (and first (regexp-quote first))
          last (and last (regexp-quote) last)))
  (if (and first last)
      (format "\\(%s%s\\)\\|%s" (if shy-p "?:" "") first last)
    (or first last)))

(defun dp-re-concat2 (first last &optional shy-p quote-p)
  "Concatenate FIRST and LAST into an re that matches either.
WILL change number of groups unless shy-p is non-nil"
  (when quote-p
    (setq first (and first (regexp-quote first))
          last (and last (regexp-quote) last)))
  (if (and first last)
      (format "%s\\|\\(%s%s\\)" first (if shy-p "?:" "") last)
    (or first last)))

(defun dp-concat-regexps-grouped (regexps &optional shy-p one-around-all-p)
  "Return regex matching ANY of the regexes in REGEXPS (a list of regex strings).
SHY-P says to wrap the individual regexes in shy regexps that won't muck with
the match groups.  
ONE-AROUND-ALL-P wraps the result in [shy] parens."
  ;; Do first here so a length 1 list has no "\\|" element.
  (let ((result (format "\\(%s%s\\)" (if shy-p "?:" "") (car regexps)))
        (rest (cdr regexps)))
    (loop for re in rest
      do (setq result (dp-re-concat2 result re shy-p)))
    (if one-around-all-p
        (format "\\(%s%s\\)" (if shy-p "?:" "") result)
      result)))

(defun dp-use-v2-appt-stuff-p ()
  (or (bound-and-true-p dp-use-new-appt-code-p)
      (not (fboundp 'appt-frame-announce))))

(defun* dp-symvals (vsym &key (format "%s: %s") (val-fmt "val: %S")
                    (func-fmt "func: %S")
                    (vals-fmt "%s%s%s")
                    (sep-str ", "))
  "Return string with value(s) of VSYM, a symbol.
Show symbol's value and/or symbol's funtion.  FORMAT is used to format the
results.  The first %s is for the vsym's name, and the second is for the
string containing their values."
  (let* ((sep "")
         (vstr (if (boundp vsym)
                   (progn
                     (setq sep sep-str)
                     (format val-fmt (symbol-value vsym)))
                 ""))
        (fstr (if (fboundp vsym)
                  (format func-fmt (symbol-function vsym))
                "")))
    (format format vsym (format vals-fmt vstr sep-str fstr))))

(defun dp-identity-rest (&rest rest)
  (interactive)
  "Return REST.  This is essentially a NOP, if `apply'-ed."
  rest)
(dp-defaliases 'dp-nop-rest 'dp-interactive-identity-rest 'dp-identity-rest)

(defun dp-identity (&rest rest)
  ;; Remove effects of &rest
  (car rest))
(defalias 'dp-nop 'dp-identity)

;; Fails with simple M-x invocation.
(defun dp-interactive-default-arg (arg)
  (interactive "p")
  arg)

(defun dp-interactive-default-optional-arg (&optional arg)
  (interactive "p")
  (dmessage "arg>%s<" arg)
  arg)

(defun dp-nop-nil (&rest rest)
  (interactive)
  "Return nil.  Ignore REST. This is essentially a NOP."
  nil)
(defalias 'dp-nilop 'dp-nop-nil)

(defun dp-nop-t (&rest rest)
  (interactive)
  "Return t.  Ignore REST. This is essentially a NOP."
  t)

;;;
;;; <: White space recognitions regexp :>

(defvar dp-ws " 	"
  "White space chars sans newline.")

(defvar dp-ws+newline (format "%s
" dp-ws)
  "White space chars including newline.")

(defvar dp-ws-regexp (format "[%s]" dp-ws)
  "White space chars regexp.")

(defvar dp-ws-regexp+ (format "%s+" dp-ws-regexp)
  "White space chars regexp, one or more.")

(defvar dp-ws-regexp* (format "%s*" dp-ws-regexp)
  "White space chars regexp, 0 or more.")

(defvar dp-ws+newline-regexp (format "[%s]" dp-ws+newline)
  "White space chars including newline regexp.")

(defvar dp-ws+newline-regexp* (format "%s*" dp-ws+newline-regexp)
  "White space chars including newline regexp, zero or more.")

(defvar dp-ws+newline-regexp+ (format "%s+" dp-ws+newline-regexp)
  "White space chars including newline regexp, one or more.")

(defvar dp-ws-regexp-not (format "[^%s]" dp-ws)
  "Non white space chars regexp.")

(defvar dp-ws-regexp+-not (format "%s+" dp-ws-regexp-not)
  "Non white space chars regexp, one or more.")

(defvar dp-ws-regexp*-not (format "%s*" dp-ws-regexp-not)
  "White space chars regexp, 0 or more.")

(defvar dp-ws+newline-regexp-not (format "[^%s]"
                                         dp-ws+newline)
  "White space chars including newline regexp, one or more.")

(defvar dp-ws+newline-regexp+-not (format "[^%s]+"
                                          dp-ws+newline)
  "White space chars including newline regexp, one or more.")


(defsubst dp-order-cons (cons &optional lessp)
  "Return CONS' elements ordered in some way as determined by LESSP.
LESSP defaults to less-than ('<)."
  (if (funcall (or lessp '<)
	       (cdr cons)
	       (car cons))
      (cons (cdr cons) (car cons))
    cons))

(defsubst dp-order-cons-list (cons &optional lessp)
  "Order elements of CONS as per `dp-order-cons' but return results as a list."
  (if (funcall (or lessp '<)
	       (cdr cons)
	       (car cons))
      (list (cdr cons) (car cons))
    (list (car cons) (cdr cons))))

(defun dp-ding-and-message (flag-or-format &optional format-string &rest args)
  "Display message and `ding'."
  (interactive)
  (let* ((ding-first-p (not (stringp flag-or-format)))
         (args (cons format-string args))
         (format-args (if ding-first-p
                          args
                        (cons flag-or-format args))))
    (when ding-first-p
      (ding))
    (apply 'message format-args)
    (unless ding-first-p
      (ding))))

(defalias 'dingm 'dp-ding-and-message)

(defun dp-safe-char-to-string (char)
  "Convert CHAR to string.  Just returns CHAR if it already a string."
  (if (characterp char)
      (char-to-string char)
    char))

(defun dp-ify-symbol (symbol &optional post-dp-prefix complete-prefix)
  "Convert the given symbol to one in my dp- namespace."
  (intern (format "%s%s" 
                  (or complete-prefix
                      (concat "dp-" (or post-dp-prefix "orig-")))
                  symbol)))

(defun dp-flanked-string (start end middle front back 
                          &optional sep prefix)
  (setq-ifnil sep " "
              prefix "")
  (let* ((sep-len (length sep))
         (middle (concat sep middle sep))
         (mid-len (length middle))
         (width (- end start))
         (flank-space (/ (- width mid-len) 2))
         (front (concat prefix (make-string flank-space front)))
         (num-back (- width mid-len (length front)))
         )
    (concat front
            middle
            (make-string num-back back))))

(defun dp-c-beginning-of-current-token (&rest rrr)
  "Just insulation from `c-beginning-of-current-token'.
In short, if point is in a token then back up to beginning.
Otherwise, nothing."
  (apply 'c-beginning-of-current-token rrr)
  (dp-set-zmacs-region-stays t))

;;(defvar dp-data-section-id-format 
;;  " ///////////////// <:%s%sdata:> /////////////////"
;;  "String to indicate the location of a class's data.")

(defun dp-format-data-section-id (name prot-level &optional
                                  start-col end-col)
  
  (setq-ifnil start-col (current-column)
              end-col fill-column)
  (let* ((name (format "<:%s%sdata:>" name prot-level)))
    (dp-flanked-string start-col end-col name ?/ ?/)))

(defvar dp-data-section-id-format 'dp-format-data-section-id)

(defun dp-c++-make-data-section-id (&optional prot-level)
  "Make a data section identifier for the current class."
  (interactive "p")
  (let ((name (if (dp-c++-get-class-name)
                  (format "%s: " (cdr (dp-c++-get-class-name)))
                "")))
    (if (functionp dp-data-section-id-format)
        (funcall dp-data-section-id-format name
                 (concat (dp-prot-level-name prot-level) " "))
      (format dp-data-section-id-format name 
              (concat (dp-prot-level-name prot-level) " ")))))

(defvar dp-c++-default-data-protection "protected")

(defvar dp-c++-class-protection-names '("private" "protected" "public")
  "In order of access.  Order must be maintained.")

(defun dp-prot-level-name (prot-level)
  (if (integerp prot-level)
      (nth (mod prot-level 
                (length dp-c++-class-protection-names))
           dp-c++-class-protection-names)
    prot-level))

(defvar dp-c++-class-protection-level-regexp
  ;;         1  |<---------------------[2]--------------------->|    3
  (concat "\\(" 
          (dp-regexp-concat dp-c++-class-protection-names t) 
          "\\(\\s-*:\\)?\\)"))

(defvar dp-c++-class-protection-label-match-string-index 2
  "Index for \(match-string\) et al.")

(defvar dp-c++-class-protection-colon-index 3
  "Index for \(match-string\) et al.")

(defun dp-class-protection-name-colon-p (name)
  "Return colon match value if it exists."
  (and name
       (save-match-data
         (string-match dp-c++-class-protection-level-regexp name)
         (match-string dp-c++-class-protection-colon-index name))))
  
(defun dp-c++-class-protection-map-name-to-level (name)
  (and name
       (dp-member*-index name dp-c++-class-protection-names)))

(defun dp-c++-class-protection-level (&optional name)
  (setq-ifnil name (dp-c++-class-protection-label))
  (if name
      (dp-c++-class-protection-map-name-to-level name)))

(defun dp-c++-class-protection-label-p ()
  "Return `:' if label is in place but needs a `:' terminator,
\"\" if <label>: exists (convenient for concatenation to complete label)
nil otherwise."
  (interactive)
  (when (and (dp-in-c++-class)
             (dp-c-looking-back-at-sans-eos-junk
              (concat "^\\s-*"
                      dp-c++-class-protection-level-regexp
                      "\\s-*")))
    (if (dp-class-protection-name-colon-p (match-string 0))
        ""
      ":")))

(defun dp-c++-class-protection-label ()
  (when (dp-c++-class-protection-label-p)
   (match-string dp-c++-class-protection-label-match-string-index)))

(defun* dp-c++-mk-data-section (&optional 
                                (prot-level dp-c++-default-data-protection)
                                (indent-p t)
                                (add-protection-label-p t)
                                (show-help-p t))
  "Make a C++ class's data area.  The ultimate in laziness.
C-u --> ask.
Default is protected.
prefix arg:  0|- --> private, 1 --> protected, 2 --> public (or none)."
  (interactive)
  (when (or current-prefix-arg (null prot-level))
    ;; Don't muck with current-prefix-arg's value
    (setq prot-level current-prefix-arg 
          prot-level (cond
                      ((numberp prot-level) (dp-prot-level-name prot-level))
                      ((eq '- prot-level) (dp-prot-level-name 0))
                      (t (completing-read
                          ;; prompt
                          (format "prot-level (default: %s): " 
                                  dp-c++-default-data-protection)
                          ;; table
                          (dp-mk-completion-list dp-c++-class-protection-names)
                          nil           ; predicate
                          t             ; require match
                          nil           ; initial contents
                          nil           ; history
                          dp-c++-default-data-protection)))))
  (if (not (dp-c++-goto-data-section prot-level 'missing-ok))
      (progn
        (dp-c-indent-command)
        (insert (dp-c++-make-data-section-id prot-level))
        (when indent-p
          (beginning-of-line)
          (insert " ") ; No indentation is done if comment is in the 1st col.
          (dp-c-indent-command)
          (end-of-line)
          (dp-c-newline-and-indent))
        (when add-protection-label-p
          (let* ((limit (dp-mk-marker (save-excursion
                                        ;; So we don't do a go-back.
                                        (setq last-command nil)
                                        (dp-c-end-of-defun 1 (quote real-bof))
                                        (line-beginning-position))))
                 (anything-pos (save-excursion
                                 (when (re-search-forward "[^ 	\n\r]" limit 
                                                          t)
                                   (line-beginning-position))))
                 (prot-level-pos (and anything-pos
                                      (save-excursion 
                                        (when (re-search-forward 
                                               (concat 
                                                "\\([ \t\n\r]*\\("
                                                (dp-regexp-concat 
                                                 dp-c++-class-protection-names) 
                                                "\\)\\s-*:[ \t\n\r]*\\)")
                                               limit t)
                                          (goto-char (match-beginning 2))
                                          (line-beginning-position))))))
            (if (or (and prot-level-pos
                         (< anything-pos prot-level-pos))
                    (not prot-level-pos))
                (let ((current-prefix-arg nil))
                  (insert prot-level ":"))
              (replace-match (concat prot-level ":\n"))
              (dp-c-indent-command)
              (previous-line 1))
            (when indent-p
              (dp-c-indent-command))
            (dp-open-newline t)
            (dp-c-indent-command)
            (delete-matching-lines "^\\s-*$")))
        (when show-help-p
          (message
           ;; default goes with [1] because that is the default argument.
           "prefix arg:  0|- --> private, 1 --> protected, 2 --> public (or none)")))
    ;; else
    ;; We're at end of comment line.
    (unless (looking-at (concat "\\s-*\n\\(^\\s-*\n\\)*\\s-*"
                                dp-c++-class-protection-level-regexp))
      (insert "\n")
      (insert prot-level ":")
      (dp-c-indent-command)
      (dp-c-newline-and-indent)
      )))


(defun dp-c++-find-data-section-id (prot-level)
  (save-excursion
    ;; We need to get the sec-id before we goto the beginning of the function.
    (let ((sec-id (dp-c++-make-data-section-id prot-level)))
      (dp-c-beginning-of-defun 1 'real-bof)
      (search-forward sec-id nil t))))

(defun* dp-c++-goto-data-section (&optional (prot-level 1) missing-ok-p)
  "Goto the current class's data section."
  (interactive "p")
  (let ((p (dp-c++-find-data-section-id prot-level)))
    (if p
        (progn
          (dp-push-go-back "dp-c++-goto-data-section")
          (goto-char p))
      (unless missing-ok-p
        (message "cannot find: %s" (dp-c++-make-data-section-id prot-level))
        (ding)))))

(defun dp-buffer-empty-p()
  (= 1 (point) (point-min) (point-max)))

(defun dp-find-last-char-before-pos (&optional line-offset char)
  "Find the last CHAR before some position LINE-OFFSET.
CHAR defaults to \",\".
LINE-OFFSET defaults to `dp-c-fill-column'."
  (interactive "p")
  (let ((p (point)))
    (goto-char (+ (or line-offset (dp-c-fill-column) line-beginning-position)))
    (unless (search-backward char (line-beginning-position) t)
      (goto-char p)
      (ding)
      (message "Cannot find %s before %s" char line-beginning-position))))

(defun dp-break-line-at-str (count &optional str)
  "Go forward COUNT STRs and `newline-and-indent.'"
  (interactive (list (prefix-numeric-value current-prefix-arg)
                     (read-string (format "String(def: \"%s\")? " ",")
                                  "" nil ",")))
  (let ((p (point)))
    (if (search-forward (dp-safe-char-to-string str) (line-end-position) 
                        t count)
        (newline-and-indent))
    (dp-ding-and-message "Could not find \"%s\"" str)
    (goto-char p)))

(defun dp-c-mode-l (&optional arg)
  "Change )<ws*>l to )<same-ws>; since it is so likely to be a mistake.
ARG, if non-nil \(interactively the prefix-arg\) says to act normally.  NB:
ARG will be used by the original `self-insert-command' and so will act as a
repeat count.  Use prefix arg with value 1 to override AI and get a single ?l."
  (interactive "P")
  (if (or arg
          (dp-in-a-c*-comment)
          (not (dp-looking-back-at ")\\s-*")))
      (call-interactively 'self-insert-command)
    (insert ";")
    (message "// Oracle thinks you wanted a ;")))

(defun dp-c-fill-column (&optional fill-val)
  "Determine current fill column for (at least) c mode."
  (or fill-val 78))

(defun* dp-add-or-update-alist (alist-var key val &key 
                                (update-p 'remove-all-then-add)
                                keep-old-if-nil-p)
  "Add \(cons KEY VAL) to ALIST-VAR iff KEY isn't in ALIST-VAR.
If KEY exists, VAL will replace the existing val associated with KEY.
UPDATE-P tells us how to update VAL: 
nil or not specified: just add or replace.
'rem-add: Nuke all with matching keys w/ `remassoc'.  This puts the list into
          the expected format: 0 or 1 instance of KEY.
We don't use `add-to-list' because we only want to key on KEY."
  (let ((update-p-legit-vals '(nil t rem-add remove-all-then-add)))
    (unless (memq update-p update-p-legit-vals)
      (error 'invalid-constant update-p update-p-legit-vals)))
  (when (and (null val)
             keep-old-if-nil-p)
    ;; Preserve the original value if new one is nil.
    (setq val (cdr-safe (assoc key (symbol-value alist-var)))))
  (when (eq update-p 'rem-add)
    ;; Nuke 'em all. Canonicalize to 1 or zero keys in list.
    (set alist-var (remassoc key (symbol-value alist-var))))
  (if (assoc key (symbol-value alist-var))
      ;; Update in place.
      (setcdr (assoc key (symbol-value alist-var)) val)
    ;; Not in the alist, add it.
    (set alist-var (acons key val (symbol-value alist-var))))
  ;; Return current value.
  (symbol-value alist-var))

(defun* dp-add-item-or-update-alist (alist-var item &rest args 
                                     &key &allow-other-keys)
  (apply 'dp-add-or-update-alist alist-var (car item) (cdr item) args))

(defun dp-kb-binding-moved (arg new-keys)
  "Show a message telling to where the old binding has moved."
  (interactive)
  (let* ((these-keys (this-command-keys))
         (this-desc (key-description these-keys))
         (new-desc (if (functionp new-keys)
                       (let ((desc (with-temp-buffer
                                     (if (keymapp arg)
                                         (use-local-map arg))
                                     (where-is new-keys 'INSERT)
                                     (buffer-substring))))
                         (posix-string-match "\\(^.*\\)\\s-*(" desc)
                         (match-string 1 desc))
                     (key-description new-keys)))
         (new-binding (if (functionp new-keys)
                          new-keys
                        (key-binding new-keys))))
    (ding)
    (message "The binding for `%s' has moved from \"%s\" to \"%s\""
             new-binding this-desc new-desc)))

(defun interactive-functionp (sym)
  "Return SYM if it refers to an interactive function."
  (and (functionp sym)
       (interactive-form sym)
       sym))

(defun major-mode-str (&optional mode)
  (format "%s" (or mode major-mode)))

(defun xmessage (&rest rest)
  "A quick, easy, visible and expensive way to turn off messages."
)

(defun dp-dmessage (format &rest rest)
  "A more easily identifiable debugging message name.  
Use this for debug messages you'll want to remove.  Easier than
examining all of the message calls."
  (apply 'message format rest))
(defalias 'dmessage 'dp-dmessage)

(defun dmessage-ding (format &rest rest)
  (apply 'dp-dmessage format rest)
  (ding))

;;(defun dmessage-todo (format &rest rest)
(defun dmessage-todo (optional-flag &optional fmt &rest args)
  "A TODO reminder.  This makes it easier to search for.
Also kindly inserts the `@todo' prefix for you.
Also does an obnoxious `ding' by default."
  (let* ((optional-flag2 (cond 
                         ((eq optional-flag nil)
                          nil)
                         ((memq optional-flag '(ding t))
                          t)
                         (t 'no-flag-p)))
         (fmt (if (eq optional-flag2 'no-flag-p)
                  optional-flag
                fmt))
         (args (if (eq optional-flag2 'no-flag-p)
                  args
                (cons fmt args))))
    (and (eq optional-flag2 t)
         (ding))
    (apply 'dmessage (format "@todo! %s" fmt) args)))
                          
(defun dmessageX (format &rest rest)
  "A more easily identifiable debugging message name.  
Use this for debug messages you'll want to remove.  Easier than
examining all of the message calls."
  (with-current-buffer dp-message-buffer-name
    (goto-char (point-max))
    (apply 'message format rest)
    (goto-char (point-max))))

(defun message-nl (fmt &rest args)
  (apply 'lmessage 'no-log fmt args))

(defvar dp-message-no-echo-num 0
  "*Number of times `dp-message-no-echo' has been called.")

(defvar dp-message-no-echo-sync-p nil
  "*Should dp-message-no-echo try to force the message buffer's window to be updated.")

(defun dp-message-no-echo (fmt &rest rest-of-args)
  "Insert a message directly into the message buf w/no copy in echo area. No newline is appended."
  (with-current-buffer dp-message-buffer-name
    (goto-char (point-max))
    (insert ;;(format "%d>" dp-message-no-echo-num)
            (apply 'format fmt rest-of-args)
            ;;(format "<%d" dp-message-no-echo-num)
            )
    (goto-char (point-max))
    (incf dp-message-no-echo-num)
    (when (if (numberp dp-message-no-echo-sync-p)
              (= (mod dp-message-no-echo-num dp-message-no-echo-sync-p) 0)
            dp-message-no-echo-sync-p)
      (let ((buf-win (get-buffer-window dp-message-buffer-name t)))
        (when buf-win
          (recenter nil buf-win)
          ;;(redisplay-frame)
          )))))

(defun in-windwoes ()
  "Determine if we are ``running'' under NT."
  (string-equal (getenv "TERM") "cmd"))

;;exp; (defun dp-line-boundaries (&optional text-only-p no-newline-p from-pos)
;;exp;   "Return cons of beginning-of-line and end-of-line.
;;exp; The *ENTIRE* line is marked.  This includes the following newline, if
;;exp; one exists, otherwise the preceding newline.  The purpose of this was
;;exp; to emulate the behavior of the slick editor (itself a derivative of
;;exp; emacs).  The reason we mark the preceding newline is so that deleting
;;exp; the last line \"deletes upwards\", leaving the cursor on the new last
;;exp; line.
;;exp; If TEXT-ONLY-P is non-nil, then shrink-wrap the mark around just the
;;exp; non-white space on the line."
;;exp;   (interactive "P")
;;exp;   (save-excursion
;;exp;     (let (bol)
;;exp;       (beginning-of-line)
;;exp;       (if text-only-p
;;exp; 	  (skip-chars-forward dp-ws (line-end-position)))
;;exp;       (setq bol (or from-pos (point)))
;;exp;       (end-of-line)
;;exp;       (if text-only-p
;;exp; 	  (skip-chars-backward dp-ws bol)
;;exp; 	;; if we're not at EOF, include this line's newline
;;exp; 	(if (not (or no-newline-p
;;exp;                      (eobp)))
;;exp; 	    (forward-char 1)
;;exp; 	  ;; we're deleting the last line in the file, so we want to
;;exp; 	  ;; delete the newline from the preceeding line, otherwise we
;;exp; 	  ;; leave an empty line at the end of the file.
;;exp; 	  (if (and (not no-newline-p) (> bol (point-min)))
;;exp; 	      ;; if we can backup, do so.
;;exp; 	      (setq bol (1- bol)))))
;;exp;       (cons bol (point)))))

(defun dp-line-boundaries (&optional text-only-p no-newline-p from-pos
                               no-eol-punctuation-p)
  "Return cons of beginning-of-line and end-of-line.
The *ENTIRE* line is marked.  This includes the following newline, if
one exists, otherwise the preceding newline.  The purpose of this was
to emulate the behavior of the slick editor (itself a derivative of
emacs).  The reason we mark the preceding newline is so that deleting
the last line \"deletes upwards\", leaving the cursor on the new last
line.
If TEXT-ONLY-P is non-nil, then shrink-wrap the mark around just the
non-white space on the line."
  (interactive "P")
  (save-excursion
    (let (bol skip-backward-chars)
      (when text-only-p
        (setq skip-backward-chars (concat skip-backward-chars dp-ws)))
      (when no-eol-punctuation-p
        (setq skip-backward-chars (concat skip-backward-chars ";,:")))
      (beginning-of-line)
      (if text-only-p
          (skip-chars-forward dp-ws (line-end-position)))
      (setq bol (or from-pos (point)))
      (end-of-line)
      (when skip-backward-chars
        (skip-chars-backward skip-backward-chars bol))
      (cond
       ;; if we're not at EOF, include this line's newline
       ((not (or no-newline-p
                 (eobp)))
        (forward-char 1))
       ((and (not no-newline-p) (> bol (point-min)))
        ;; if we can backup, do so.
        (setq bol (1- bol))))
      (cons bol (point)))))

(defun dp-line-boundaries-as-list (&rest r)
  (interactive)
  (dp-cons-to-list (apply 'dp-line-boundaries r)))

(defun dp-region-or-line-boundaries(&optional m p text-only-p
                                    no-newline-p from-pos)
  (interactive)
  (dp-region-or... :beg m :end p
                   :bounder 'dp-line-boundaries
                   :bounder-args (list text-only-p no-newline-p from-pos)))

(defun dp-region-or-line-boundaries-as-list(&rest r)
  "Front end to `dp-region-or-line-boundaries' returning a list vs cons."
  (interactive)
  (dp-cons-to-list (apply dp-region-or-line-boundaries r)))

(defun dp-func-on-region-or-line (func &optional text-only-p
                                  no-newline-p from-pos
                                  m p)
  "Apply FUNC to region if defined else the entire line."
  (let ((region (dp-region-or-line-boundaries m p text-only-p no-newline-p
                                              from-pos)))
    (funcall func (car region) (cdr region))))

;(defun dp-pwn-sel (&optional p1 p2 type how-to-add data-type)
;  (interactive "r")
;  (setq-ifnil p1 (mark)
;	      p2 (point))
;  (let ((bss (buffer-substring p1 p2)))
;    (dp-deactivate-mark)		; TEMP????
;    (own-selection bss type how-to-add data-type)))

(defun dp-pwn-sel()
  )
(defun dp-mark-line (&optional text-only-p no-newline-p from-pos)
  "Mark the line point is on, leaving mark at bol and point at eol, as
determined by dp-line-boundaries."
  (interactive "_P")
  (let ((region (dp-line-boundaries text-only-p no-newline-p from-pos)))
    (dp-set-mark (car region))
    (goto-char (cdr region))))

(defun dp-copy-primary-selection (&optional arg)
  "Copy selection if it exists, else the current line."
  (interactive "p")
  (let ((opoint (point)))
    (dp-mark-line-if-no-mark)
    (own-selection (buffer-substring (mark) (point)))
    (copy-primary-selection)
    (goto-char opoint)
    (dp-deactivate-mark)))

(defsubst dp-operate-on-entire-line (func &optional text-only-p)
  "Mark the entire line and then call FUNC with mark and point.
Preserves the current column and attempts to move there after calling
FUNC.  This was created for deleting and killing entire lines.
FUNC must take two args, beginning and end buffer positions."
  (let ((col (current-column)))
    (dp-func-on-region-or-line func text-only-p)
    (move-to-column col)))

(defun dp-kill-entire-line ()
  "Kill the entire line."
  (interactive "*")
  (dp-operate-on-entire-line 'kill-region))

(defun dp-delete-entire-line ()
  "Delete the entire line, ala A-D in Slick."
  (interactive "*")
  (dp-operate-on-entire-line 'delete-region))

(defun dp-mark-line-if-no-mark (&optional text-only-p no-newline-p)
  "Mark the entire line if no mark is currently set.
If TEXT-ONLY-P is non-nil, then shrink-wrap the mark aound just the
first and last non-white space on the line."
  (interactive "P")
  (unless (dp-mark-active-p)
    (dp-mark-line text-only-p no-newline-p)
    (dp-set-zmacs-region-stays t)))

;; (defun* dp-rest-or-all-of-line (&optional (text-only-p t) (no-newline-p t) 
;;                                 from-pos shrink-wrap-p
;;                                 ignore-eol-punctuation-p)
(defun* dp-rest-or-all-of-line (&key (text-only-p t) (no-newline-p t) 
                                from-pos shrink-wrap-p
                                ignore-eol-punctuation-p)
  "If at eol, return boundaries of whole line, else the rest of line."
  (if (looking-at "\\s-*$")
      (dp-line-boundaries text-only-p no-newline-p from-pos)
    (dp-bound-rest-of-line :text-only-p text-only-p
                           :no-newline-p no-newline-p
                           :ignore-eol-punctuation-p ignore-eol-punctuation-p
                           :from-beginning-p (eq from-pos 
                                                 (line-beginning-position)))))

(defun dp-indentation-boundaries ()
  (cons (line-beginning-position)
        (+ (line-beginning-position) (current-indentation))))

(defvar dp-region-function-map 
  '((line-p               . (dp-line-boundaries))
    (indentation-p        . (dp-indentation-boundaries))
    (buffer-p             . ((lambda ()
                               (cons (point-min) (point-max)))))
    (rest-of-line-p       . (dp-bound-rest-of-line))
    (rest-or-all-of-line-p . (dp-rest-or-all-of-line))
    (text-of-line-p       . (dp-mark-line-if-no-mark t t))
    (first-extent         . (dp-first-extent-boundaries))
    (zero-len-p          . ((lambda (&rest unused)
                              (cons (point) (point)))))
    (rest-of-buffer-p     . (dp-rest-of-buffer-cons)))
  "Map of convenience symbolic args to `dp-region-or...' to functions.
Format is an alist of: \(symbol . \(function [args...]))  I know, it's the
same as \(symbol function [args...]), but the . emphasizes the key
element. ")

(defun* dp-region-or... (&key beg end 
                         (bounder 'line-p) bounder-args 
                         &allow-other-keys)
  "Return an ordered (cons first last) from one of many bounding conditions:
1. (cons BEG END) if they are non-nil,
2. the region if active,
3. when BOUNDER is callable, the results of `BOUNDER' applied to BOUNDER-ARGS.
4. when BOUNDER is a symbol in `dp-region-function-map' the results of the
   associated function the map applied to BOUNDER-ARGS.
Return nil when BOUNDER eq 'nada and when BOUNDER matches nothing else.
See `dp-region-function-map' for other bounders."
  (let (bounder-info)
    (cond
     ((or (and beg end)
          (dp-mark-active-p))
      ;; `dp-region-boundaries-ordered' figures out which is which.
      (dp-region-boundaries-ordered beg end))
     ((and-fboundp bounder)
      (apply bounder bounder-args))
     ((setq bounder-info (assoc bounder dp-region-function-map))
      ;; We got: (symbol function [args...])
      (apply (cadr bounder-info) (or bounder-args
                                     (cddr bounder-info))))
     ((eq bounder 'nada) nil))))

(defun dp-region-or...as-list (&rest r)
  (dp-cons-to-list (apply dp-region-or... r)))

(defun dp-mark-region-or... (&rest args-for-dp-region-or...)
  "Mark region as determined by `dp-region-or...'.
All args are simply passed thru to `dp-mark-region-or...'"
  (interactive)
  (dp-mark-region (apply 'dp-region-or... args-for-dp-region-or...)))

(defun* dp-get--as-string--region-or... (&rest args-for-dp-region-or...
                             &key (gettor 'symbol-near-point) gettor-args
                             (default "")
                             &allow-other-keys)
  "Get region or... (see `dp-region-or...') and return it as a string.
If region is not active, default gettor is `symbol-near-point'."
  (interactive)
  (let* ((beg-end (apply 'dp-region-or... :bounder 'nada 
                         args-for-dp-region-or...))
         ;;(dumby (dmessage "YOPP!, be: %s" beg-end))
         (str (if (consp beg-end)
                  (buffer-substring (car beg-end) (cdr beg-end))
                (apply gettor gettor-args))))
    (or str default)))


; (defun dp-get-region-or-apply (&optional or-func &rest rest)
;     "Get the currently marked region or return the result of OR-FUNC.
; If not specified, OR-FUNC defaults to the original value of
; If neither is non-nil, then use `current-word'."
;     (interactive)
;     (if (dp-mark-active-p)
;         (buffer-substring (mark) (point))
;       (apply (or or-func 'current-word) rest)))

(defun dp-delete ()
  "Delete the current region if mark is active, else the current character."
  (interactive "*")
  (if (dp-mark-active-p)
      (delete-region (mark) (point))
    ;; @todo univ-arg set --> delete-char does kill. ? Do I like this?
    (call-interactively 'delete-char)))

(defun* dp-kill-or-copy (func append-p &optional pre-op post-op 
                         (deactivate-mark-p t)
                         text-props)
  "Call FUNC on the region if active, the current line otherwise.
If APPEND-P is non-nil, append the affected text.
Perform PRE-OP immediately before and POST-OP immediately after calling func."
  (progn
    (save-excursion
      (dp-mark-line-if-no-mark)
      (dp-activate-mark)
      (if append-p
	  (append-next-kill))
      (if pre-op
	  (funcall pre-op))

      ;;(dmessage "f>%s<, m>%s<, p>%s<" func (mark) (point))
      (funcall func (region-beginning) (region-end))
      
      (if post-op
	  (funcall post-op)))
    (when deactivate-mark-p
      (dp-deactivate-mark))))

(defun dp-kill-ring-save (&optional append-p)
  "Copy the current region to the kill ring if mark is set,
the current line otherwise.
If APPEND-P if set (with prefix arg interactively) append the newly
copied text."
  (interactive "P")
  (dp-kill-or-copy 'copy-region-as-kill append-p 'dp-pwn-sel))

(defun dp-kill-ring-save-append ()
  "Append the current region to the kill ring if mark is set,
the current line otherwise."
  (interactive)
  (dp-kill-or-copy 'kill-ring-save      ;;; 'copy-region-as-kill 
                   'append 'dp-pwn-sel))

(defun dp-kill-region (&optional append-p)
  "Kill the current region to the kill ring if mark is set,
the current line otherwise.
If APPEND if set (with prefix arg interactively) append
the newly copied text."
  (interactive "*P")
  (dp-kill-or-copy 'kill-region append-p 'dp-pwn-sel))

(defun dp-kill-region-append ()
  "Kill and append current region if defined, else the current line."
  (interactive "*")
  (dp-kill-or-copy 'kill-region 'append))

(defun dp-op-other-window (num op &rest args)
  "Perform OP on ARGS NUM `other-window's away."
  (interactive)
  (let ((num (or num 1)))
    (other-window num)
    (apply op args)
    (other-window (- num))))

(defun dp-scroll-up-down (&optional nlines half-page-p up-down)
  "Scroll screen down 1 line or 1/2 page."
  (interactive "_P")

  (let* ((lines (if (or (eq current-prefix-arg '-)
                        half-page-p)
                    (/ (window-displayed-height) 2)
                  (or nlines 1)))
         (lines (if (eq up-down 'up) (- lines) lines))
         (scrolled-pos-visible  
          (pos-visible-in-window-p (save-excursion
                                     (forward-line lines)
                                     (point)))))
    (if (or (not half-page-p)
            scrolled-pos-visible)
        (scroll-down lines)
      (move-to-window-line (if (< lines 0) -1 0))
      ;;if arg is consp (e.g. ^U) then there's no erase/redraw
      (recenter '(4)))))

(defun dp-scroll-up (&optional num half-page-p)
  (interactive "_p")
  (dp-scroll-up-down num half-page-p 'up))
(put 'dp-scroll-up 'isearch-command t)

(defun dp-scroll-down (&optional num half-page-p)
  (interactive "_p")
  (dp-scroll-up-down num half-page-p 'down))
(put 'dp-scroll-down 'isearch-command t)

(defun dp-scroll-up-other-window (&optional num)
  (interactive "_p")
  (dp-op-other-window nil 'dp-scroll-up))
;;  (dp-scroll-up-down num nil 'up 'other-window))
(put 'dp-scroll-up-other-window 'isearch-command t)

(defun dp-scroll-down-other-window (&optional num)
  (interactive "_p")
  (dp-op-other-window nil 'dp-scroll-down))
;;  (dp-scroll-up-down num nil 'down 'other-window))
(put 'dp-scroll-down-other-window 'isearch-command t)

;; .if, etc, are for Berkley makefiles.
(defvar dp-ifx-re-alist 
  '((dp-if .    "[.#][ 	]*if")		; gets #if, #ifdef and #endif.
    (dp-else .  "[.#][ 	]*else")
    (dp-elif .  "[.#][ 	]*elif")	; ignored by the hideif stuff.
    (dp-endif . "[.#][ 	]*endif")
    (dp-fi    . "[.#][ 	]*fi")
;;@todo;     (dp-ss-do    . "[ 	]*do")
;;@todo;     (dp-ss-done  . "[ 	]*done")
;;@todo;     (dp-ss-if    . "[ 	]*if")
;;@todo;     (dp-ss-fi    . "[ 	]*fi")
;;@todo;     (dp-ss-else  . "[ 	]*else")
;;@todo;     (dp-ss-elif  . "[ 	]*elif")
;;@todo;     (dp-ss-case  . "[ 	]*case")
;;@todo;     (dp-ss-esac  . "[ 	]*esac")
    )
  "An alist of regexps to find and identify CPP conditional directives.
Should work for if/else in Berkley makefiles.  Should work for shell scripts
as long as they're formatted with the if,else,elif,fi agin the left margin.")

(defun dp-get-ifdef-item (&optional re-alist)
  "Identify the CPP conditional directive on the current line.
Return nil of not on a supported directive."
  (interactive)
  (save-excursion
    (beginning-of-line)
    (dolist (el (or re-alist dp-ifx-re-alist) nil)
      (when (looking-at (cdr el))
        ;;(message "found>%s<" (car el))
        (return (car el))))))

(autoload 'hif-endif-to-ifdef "hideif" "hide ifdef functions")
(autoload 'hif-ifdef-to-endif "hideif" "hide ifdef functions")

(defun dp-matches-paren-p (&rest rest)
  "MAKE THIS GOTO and CHECK it, returning point of matching paren."
  (point))

(defun* dp-find-matching-paren0 (&optional re-alist open-paren-string
                                 (ding-p t))
  "Goto matching paren type character.
Also, if on a CPP conditional directive, find complementary part:
{if[xx]|else|elif} -> endif, endif -> if[xx].
Inspired (now distantly) by `vi-find-matching-paren'."
  (interactive "_")
  (let (ifdef-item)
    ;;(dmessage "0, st>%s<" (syntax-table))
    ;;(dmessage "0, %s" (char-syntax ?<))
    (cond 
     ((looking-at "[[({<]")
      (goto-char (1- (scan-sexps (point) 1)))
      (dp-matches-paren-p 'throw-error))
     ((looking-at "[])}>]") 
      (goto-char (scan-sexps (1+ (point)) -1))
      (dp-matches-paren-p 'forward 'throw-error))
     ((setq ifdef-item (dp-get-ifdef-item re-alist))
      (cond
       ((memq ifdef-item '(dp-if dp-else dp-elif)) (hif-ifdef-to-endif) t)
       ((eq ifdef-item 'dp-endif) (hif-endif-to-ifdef) t)
       (t (if ding-p (ding)) nil)))
     (t (if ding-p (ding)) nil))))

(defvar dp-matching-<-syntax-table nil
  "Syntax table for matching < and > as parenthentical delimiters.")
(let ((table (make-syntax-table)))
  (modify-syntax-entry ?< "(>" table)
  (modify-syntax-entry ?> ")<" table)
  (setq dp-matching-<-syntax-table table))
;; it needs this to make it go.
;; if this isn't done, then the char-syntax with dp-matching-<-syntax-table
;; as syntax-table isn't correct.
;; ??? What does char-syntax do?
(message "%s" (char-syntax ?< dp-matching-<-syntax-table))

(defun dp-find-matching-paren-including-<0 (unbalanced-ok-p)
  "Find and goto matching paren, including ?< and ?>.
We need to modify the syntax table to make this work.  But since that can
cause too many other side effects, we only do it for the duration of the
matching operation and only if we are on a ?< or ?>."
  (interactive "_")
  (with-syntax-table (if (looking-at "[<>]") 
                         dp-matching-<-syntax-table
                       (syntax-table))
	;;(dmessage "1, st>%s<" (syntax-table))
	;;(dmessage "1, %s" (char-syntax ?<))
    (let ((pt (point))
          pt2)
      (dp-find-matching-paren0 nil (buffer-substring (point) (1+ (point)))
                               (not unbalanced-ok-p))
                               ;; (match-string 0))
      (setq pt2 (point))
      ;; Return nil if we didn't move, else pos to which we moved.
      (if (equal pt pt2)
          nil
        pt2))))

(defun dp-find-matching-paren-including-< (&optional unbalanced-ok-p)
  "Find a matching \"paren\", which here inclues ?< and ?>"
  (interactive "_P")
  (condition-case err-data
      (dp-find-matching-paren-including-<0 unbalanced-ok-p)
    ;; err-data: (syntax-error Unbalanced parentheses)
    (syntax-error (if unbalanced-ok-p 
                      nil
                    (apply 'error err-data)))
    (t (apply 'error err-data))))

(defalias 'dp-find-matching-paren 'dp-find-matching-paren-including-<)
(defalias 'dp-c++-find-matching-paren 'dp-find-matching-paren-including-<)

(defun* dp-matching-paren-pos (&optional (unbalanced-ok-p t))
  (save-excursion
    (and (dp-find-matching-paren unbalanced-ok-p)
         (point))))

(defun dp-true (&rest r)
  t)

(defun* dp-mk-completion-list (list &key (pred 'dp-true) pred-args
                               ctor ctor-args
                               listifier listifier-args)
  "Turn LIST into a completion list, filtering on PRED and CONS-ifying as needed.
If CTOR is non-nil then it is assumed to be a function that will create
completion list members.  It is called for each element in LIST with the
element as the parameter.  If CTOR is nil, then the default is to return the
element if it is not an atom, otherwise a cons of the element and the symbol
'dp-mk-completion-list-default-ctor.
If LISTIFIER is non-nil, then it is passed LIST and is expected to return a
list.  It is useful, e.g. for splitting a string into a list.
The elements of the returned list are used in place of LIST."
  (delq nil
        (mapcar (function 
                 (lambda (element)
                   (if (apply pred (if (atom element) element (car element))
                              pred-args)
                       (if ctor
                           (apply ctor element ctor-args)
                         (if (atom element)
                             (cons element 'dp-mk-completion-list-default-ctor)
                           element))
                     nil)))
                (if listifier
                    (apply listifier list listifier-args) 
                  list))))

(defvar dp-temp-*mode-buffer-alist '()
  "AList keyed by mode of all buffers made w/ `dp-make-temp-*mode-buffer'.")

(defun dp-temp-*mode-buffer-alist (mode)
  (if mode
      (cdr (or (assoc mode dp-temp-*mode-buffer-alist)
               (assoc (format "%s" mode) dp-temp-*mode-buffer-alist)))
    (loop for mode-list in dp-temp-*mode-buffer-alist
      append (cdr mode-list))))

(defun* dp-temp-*mode-read-buffer-name (mode-func &key
                                        (prompt 
                                         (format "temp %s buf name: " 
                                                 (or mode-func "*")))
                                        (pred 'dp-true)
                                        (ctor nil))
  (interactive)
  (completing-read prompt (dp-mk-completion-list
                           (dp-temp-*mode-buffer-alist mode-func)
                           :ctor (or ctor
                                     (function
                                      (lambda (item)
                                        (cons (format "%s" item)
                                              (format "mode: %s"
                                                      (or mode-func
                                                          "*")))))))))

(defun* dp-remove-from-temp-*mode-buffer-alist (&key (mode major-mode) 
                                                (name (buffer-name)))
  (dp-delete-from-alist-list 'dp-temp-*mode-buffer-alist mode name))

(defun* dp-append-to-temp-*mode-buffer-alist (&key (mode major-mode) 
                                              (name (buffer-name)))
  (dp-append-to-alist-list 'dp-temp-*mode-buffer-alist mode name))


(defvar dp-make-temp-*mode-buffer)  

(defun* dp-temp-*mode-read-mode (&optional mode-func (def-mode major-mode))
  (unless mode-func
    (setq mode-func (read-function (format "mode-func (default: %s): "
                                           def-mode))
          ;; read-function can result in an unbound variable.
          mode-func (if (fboundp mode-func)
                        mode-func
                      def-mode)))
  mode-func)
    
(defun* dp-make-temp-*mode-buffer (&optional buffer-name mode-func (ext "") 
                                   (comment-beg "//     ")
                                    (comment-end ""))
  "Create a temporary buffer named BUFFER-NAME and then call MODE-FUNC.
It WILL NOT be asked to be saved.
Returns the buffer created."
  (interactive)
  (dmessage "Add `other-window' stuff and clean up alist as buffers go away.")
  (unless buffer-name
    (setq buffer-name
          (dp-temp-*mode-read-buffer-name mode-func)))
  
  (let* ((buffer-name (if (and buffer-name
                               (not (string= buffer-name "")))
                          buffer-name
                        ;; If we're here, then there is no buffer name to use
                        ;; to guess the mode.
                        (dp-serialized-name
                         (format "*tmp-%s-buffer*%s"
                                 (or mode-func "*")
                                 (or ext ""))
                         "%s<%s>")))
         (existsp (get-buffer buffer-name))
         (temp*-buf (get-buffer-create buffer-name))
         (temp*-buf-name (format "%s" temp*-buf))
         
         (auto-mode-func (cdr-safe (dp-assoc-regexp buffer-name 
                                                    auto-mode-alist)))
         (mode-func (dp-temp-*mode-read-mode
                     (or mode-func 
                         (and auto-mode-func 
                              (message "Guessed %s mode from file name." 
                                       auto-mode-func)
                              auto-mode-func))))
         (mode-func-name (format "%s" mode-func))
         (ebang-name (save-match-data 
                       (when (posix-string-match "\\(.*\\)-mode" mode-func-name)
                         (match-string 1 mode-func-name)))))
    (switch-to-buffer temp*-buf)
    (if existsp
        (if (not (eq mode-func major-mode))
            (message "buffer %s is already a %s mode buffer." 
                     buffer-name major-mode))
      ;; New buffer
      (when (and ebang-name
                 (equal (point-max) (point-min)))
        (dp-insert-ebang ebang-name comment-beg comment-end))
      (funcall mode-func)
      (dp-set-auto-mode)
      ;; Set after mode setup since it's a local variable.
      (add-local-hook 'kill-buffer-hook 'dp-remove-from-temp-*mode-buffer-alist)
      (dp-append-to-temp-*mode-buffer-alist :mode mode-func 
                                            :name (format "%s" temp*-buf))
      (dp-define-buffer-local-keys '([(meta ?-)] dp-bury-or-kill-buffer
                                     "\ew" dp-deactivated-key 
                                     "\C-x\C-s" dp-deactivated-key
                                     "\C-c\C-c" dp-maybe-kill-this-buffer))
      (goto-char (point-max)))
    temp*-buf))
             
(defun dp-make-temp-c++-mode-buffer (&optional buffer-name)
  "Helper to create a C++ mode buffer using `dp-make-temp-*mode-buffer'."
  (interactive)
  (dp-make-temp-*mode-buffer buffer-name 'c++-mode ".cc" "// " ""))
(defalias 'dptc 'dp-make-temp-c++-mode-buffer)
(defalias 'tmpc 'dp-make-temp-c++-mode-buffer)
(defalias 'ctmp 'dp-make-temp-c++-mode-buffer)

(defun dp-make-temp-python-mode-buffer(&optional buffer-name)
  "Helper to create a python mode buffer with `dp-make-temp-*mode-buffer'."
  (interactive)
  (dp-make-temp-*mode-buffer buffer-name 'python-mode ".py" "!# " ""))

(defun dp-make-temp-text-mode-buffer(&optional buffer-name)
  "Create a text mode buffer using `dp-make-temp-*mode-buffer'."
  (interactive)
  (dp-make-temp-*mode-buffer buffer-name 'text-mode ".txt" "!# " ""))
(defalias 'dptt 'dp-make-temp-text-mode-buffer)

(defun dp-make-temp-fundie-mode-buffer(&optional buffer-name)
  "Create a fundamental mode buffer with `dp-make-temp-*mode-buffer'."
  (interactive (list (completing-read 
                      "temp buf name: " 
                      (dp-mk-completion-list dp-temp-*mode-buffer-alist))))
  (dp-make-temp-*mode-buffer buffer-name 'fundamental-mode "" "!# " ""))
(defalias 'dptf 'dp-make-temp-fundie-mode-buffer)

(defun dp-make-temp-emacs-lisp-mode-buffer (&optional buffer-name)
  "Create an emacs lisp mode  mode buffer using `dp-make-temp-*mode-buffer'."
  (interactive)
  (dp-make-temp-*mode-buffer buffer-name 'emacs-lisp-mode ".el" ";; " ""))
(defalias 'dpte 'dp-make-temp-emacs-lisp-mode-buffer)

(defun dp-make-temp-lisp-interaction-mode-buffer (&optional buffer-name)
  "Create an emacs lisp mode  mode buffer using `dp-make-temp-*mode-buffer'."
  (interactive)
  (dp-make-temp-*mode-buffer buffer-name 'lisp-interaction-mode 
                             ".el" ";; " ""))
(defalias 'dpti 'dp-make-temp-lisp-interaction-mode-buffer)

(defun dp-deactivated-key (&optional message mode key)
  (interactive)
  (let ((key-msg (format "\"%s\" " (or key 
                                       (key-description (this-command-keys)))))
        (mode-msg (format "in %s" (or mode "this"))))
    (message (format "%skey %sis disabled in %s mode." 
                     (if message
                         (concat message " ")
                       "") 
                     key-msg mode-msg))))
        
(defun dp-deactivate-key (key &optional message)
  (interactive (list (setq key (read-key-sequence "disable key: "))
                     ;; We can't pass this message since elisp has no closures.
                     ;;(read-string "message: ")
                     ))
  (and (stringp message)
       (string= message "")
       (setq stringp nil))
  (global-set-key key (kb-lambda
                          (dp-deactivated-key)))
  (message "deactivated key: %s" (key-description key)))
  
(defun dp-toggle-mark ()
  "Toggle the mark activation state."
  (interactive)
  (if (dp-mark-active-p)
      (dp-deactivate-mark)
    (dp-set-mark (point))))

(defun dp-get-char-previous-line ()
  "Copy character from the line above the cursor to point."
  (interactive "*")
  (let (gotChar 
	(oldgCol temporary-goal-column) ; We want to go up in same col.
	(col (current-column)))
    (save-excursion
      (setq temporary-goal-column (current-column))
      (previous-line 1)			; previous-line uses goal column
      ; if the col we were at is less than the col we've gone to,
      ; then we've moved up to the character *after* the virtual
      ; space printed when a tab is expanded on the screen,
      ; so we fake things by returning a space
      (if(< col (current-column))		; We've upped to a tab.
	  (setq gotChar ?\ )
	(setq gotChar (following-char))))
    (setq temporary-goal-column oldgCol)
    gotChar))

(defun dp-dupe-char-prev-line ()
  "`dp-get-char-previous-line' and insert @ point."
  (interactive "*")
  (insert-char (dp-get-char-previous-line) 1))


(defun dp-dupe-chars-prev-line (&optional arg action)
  "Copy character from the line above the cursor to point.
ARG == nil ==> one char,
ARG == '(4) == C-u ==> word, (C-1 is easy now that >0 --> n words)
ARG == '(16) == C-uC-u ==> rest of line up to but not including the newline.
ARG is `charp': copy up to but NOT including char ARG,
ARG is positive: number of words to copy (words turn out to be more common).
ARG is negative: number of chars to copy.
ARG is 0: copy up to next space(included) or eol(excluded).
ARG is '- (ie [(control ?-)]) copy to eol.
!<@todo Should just vector to routines which do what we want rather than
executing the cond again and again and..."
  (interactive "P")
  (let* ((num&action (cond 
                      (action (cons arg action))
                      ((not arg) (cons 1 'char))
                      ((and (integerp arg)
                            (not (= arg 0)))
                       (if (> arg 0)
                           (cons (abs arg) 'word)
                         (cons arg 'char)))
                      ((member arg '(0 (4))) (cons 1 'word))
                      ((member arg '(- (16))) (cons 1 'line))
                      ((characterp arg) (cons 1 'up-to-arg))
                      (t (cons 1 'char))))
         (num (car num&action))
         (action (cdr num&action))
         char todo)
    (loop while (> num 0) do
      (setq char (dp-get-char-previous-line))
      (setq todo (cond
                  ((eq action 'char) '(insert count))
                  ((eq action 'up-to-arg)
                   (if (char= arg char) ;!<@todo Include target char?
                       '(insert-if-not-last count)
                     ;; Terminate @ EOL, otherwise trying to copy up to a
                     ;; nonexistent character will cause an infinite loop.
                     ;; And it most likely indicates a mistake.
                     (if (char= char ?\n)
                         (progn
                           (warn 
                            "Couldn't find copy-to char>%s< by end of line." 
                                 arg)
                           '(break))
                       '(insert))))
                  ((and (memq action '(line word))
                        (eq char ?\n)) ;; Newline ends lines and words.
                   '(insert-if-not-last count))
                  ((eq action 'line)
                   '(insert))
                  ((eq action 'word)
                   (if (eq (char-syntax char) ?\ )
                       '(insert count)
                     '(insert)))
                  (t (ding)
                     (error 'invalid-argument "bad action" ))))
      (when (memq 'insert todo)
        (insert char))
      (when (memq 'count todo)
        (setq num (1- num)))
      (when (and (memq 'insert-if-not-last todo)
                 (> num 0))
        (insert char))
      (when (memq 'break todo)
        (return))
      )
    )
  )

(defun dp-dupe-words-prev-line (&optional arg)
  "Duplicate ARG words from the line above point."
  (interactive "p")
  (dp-dupe-chars-prev-line arg 'word))

(defun dp-dupe-n-chars-prev-line (num arg)
  "Call dp-copy-char NUM times using ARG as its arg."
  (loop repeat num do 
    (dp-get-char-prev-line arg)
    (insert char))
  (delete-backward-char 1))

(defun dp-dupe-prev-line-up-to-char (arg char)
  (interactive "*p\ncDupe up to what char: ")
  (if (equal arg '(4))
      (dp-dupe-chars-prev-line 
       (read-from-minibuffer "Num chars to copy: " 4))
    (dp-dupe-n-chars-prev-line arg char)))

(defun dp-copy-char-to-minibuf ()
  (interactive)
  ;; (dp-go-back-top-buffer) wasn't really a good choice. It worked for the
  ;; case where we were editing an isearch string because I pushed the go
  ;; back before the isearch started. But in other cases, it just gets the
  ;; last buffer pushed as a go back.
  (let ((buffer (or (cadr (buffer-list))
                    (dp-go-back-top-buffer)))
        ch)
    (when buffer
      (with-current-buffer buffer
        (setq ch (following-char))
        (forward-char))
      (insert-char ch))))

(defvar dp-c-hard-coded-symbol-char0 "[a-zA-Z_]")
(defvar dp-c-hard-coded-symbol-char1... "[a-zA-z_0-9]")

(defvar dp-c-hard-coded-symbol-chars (concat dp-c-hard-coded-symbol-char0 
                                             dp-c-hard-coded-symbol-char1... 
                                             "*")
  "Chars making up a C-language-like symbol.")

(defvar dp-c-hard-coded-symbol-regexp (concat "\\("
                                   "\\(^\\|\\(^" dp-c-hard-coded-symbol-char1... "\\)\\)"
                                   "\\(" dp-c-hard-coded-symbol-chars "\\)"
                                   "\\($\\|^" dp-c-hard-coded-symbol-char0 "\\)"
                                   "\\)")

  "Chars making up a C-language-like symbol.")

(defvar dp-c-symbol-regexp "\\(\\([^0-9]\\|^\\)\\(\\sw\\(\\sw\\|\\s_\\)*\\)\\)")

(defvar dp-c-add-comma-@-eol-of-regions 
  '(brace-list-entry arglist-cont arglist-intro member-init-intro
    member-init-cont arglist-cont-nonempty brace-list-intro 
    brace-list-entry statement-case-intro brace-list-open)
  "Syntax regions after which we may want to put a comma.")

(defun dp-c-statement-terminated-p ()
  (interactive)
  (save-excursion
    (dp-c-end-of-line)
    ;; Do we want to add "}"?
    (dp-looking-back-at ";")))
  
(defvar dp-c-statement-syntaxes '(statement)
  "C syntax regions that indicate we're in a statement")

(defun* dp-stream-op-needed-p (&optional (anywhere-p nil))
  "Are we in an iostream statement? If so, return which kind \(<<|>>\).
NB! the caller expects that, if there is a match, then the matching op is in
\1 and the remainder in \2, such that a (replace-match \"\2\") effectively
deletes the op.
Non-nil ANYWHERE-P means to return the kind if a stream op is anywhere in the
statement so far.
Otherwise, only return the kind if the stream op is at EOS so far and just
terminate and eol/nl+indent."
  (interactive)
  (when (and (dp-in-c)
             ;;(dp-c-in-syntactic-region '(stream-op))
             (not (dp-c-statement-terminated-p))
             (save-excursion
               (dp-c-end-of-line)
               (if anywhere-p
                   (dp-c-looking-back-at-sans-eos-junk     
                    "\\(<<\\|>>\\)\\([^=]*\\)")
                 ;; This needs to return <<|>> only if it is the last part
                 ;; of the statement.
                 ;; e.g. cout << a << b <<  // \\s-*\\(comment-regexp\\)?
                 (dmessage "@todo !!! Fix anywhere-p eq nil")
                 (dp-looking-back-at 
                  ;; stream op in \1 rest of match in \2
                  "\\(<<\\|>>\\)\\(\\s-*\\(\\(//.*$\\)\\|$\\)\\)"))))
    (dmessage "mstrings: %s" (dp-all-match-strings-string))
    (match-string 1)))

(defun dp-in-c-iostream-statement-p ()
  (save-excursion
    (beginning-of-line)
    ;; Sometimes, either I or cc-mode gets confuzed about iostream-ed-ness.
    (or (dp-stream-op-needed-p)
        (dp-c-in-syntactic-region '(stream-op)))))

(defun dp-in-c-statement ()
  "Are we in a C/C++ statement?"
  (interactive)
  (save-excursion
    (dp-c-beginning-of-statement)
    (dp-c-in-syntactic-region dp-c-statement-syntaxes)))

;;;(defun dp-c-looking-back-at-outermost-closing-paren-p ())

(defun dp-open-newline (&optional open-newline-func)
  "Add a new line below the current one, ala `o' in vi. Do mucho magick, too.
Pass t for `open-newline-func' to get the basic open below behavior."
  (interactive "*P")
  (let* ((open-newline-func (or open-newline-func
                                (dp-mode-local-value 'dp-open-newline-func)
                                (bound-and-true-p dp-open-newline-func)))
         (do-default (if (or (and open-newline-func (listp open-newline-func))
                             (Cu0p open-newline-func)
                             (Cu--p open-newline-func)
                             (memq open-newline-func '(t nil default 
                                                       eol-newline-and-indent)))
                         t
                       ;; Perform some mode specific actions.
                       ;; This can return non-nil as well in order to do
                       ;; defaultactions either because it couldn't find a
                       ;; special case or because the default actions are
                       ;; useful in addition.
                       ;; Trap any errors and fall back to a simple 
                       ;; eol, nl, indent operation.
                       ;; !<@todo XXX Try to undo any misguided changes made
                       ;; before we bailed out.
                       (condition-case nil
                           (progn
                             (undo-boundary)
                             (funcall open-newline-func current-prefix-arg))
                         (error
                          (undo)
                          t)))))
    (when do-default
      (end-of-line)
      (newline-and-indent))))

(defvar dp-c++-symbol-regexp-guts
  ;; No open paren of any kind
  "\\(%s\\s_\\|\\sw\\)*\\(%s::\\)?\\(%s\\s_\\|\\sw\\)+")

(defvar dp-c++-symbol-regexp (replace-in-string dp-c++-symbol-regexp-guts
                                                "%s" ""))

(defvar dp-c++-symbol-shy-regexp (replace-in-string dp-c++-symbol-regexp-guts
                                                    "%s" "?:" 'LITERAL))

(defun dp-c-find-stmt-closing-paren (&optional limit)  ; <:ctcp:>
  (interactive)
  (save-excursion
    (dp-c-beginning-of-statement)
    (when (search-forward "(" limit t)
      (goto-char (match-beginning 0))
      (condition-case nil
          (dp-find-matching-paren)
        (error
         nil)))))

(defun dp-c-goto-stmt-closing-paren (&optional limit)
  (interactive)
  (let ((p (dp-c-find-stmt-closing-paren)))
    (when p (goto-char p))))

(defun dp-c-looking-back-at-sans-eos-junk (regexp &optional from-eol-p limit)
  "Look back for REGEXP ignoring stuff like closed comments, spaces, etc.
See `dp-c*-junk-after-eos*'."
  (save-excursion
    (when from-eol-p
      (dp-c-end-of-line))
    (dp-looking-back-at (concat regexp dp-c*-junk-after-eos*) limit)))

(defun dp-c-looking-at-sans-eos-junk (regexp &optional from-bol-p limit)
  (save-excursion
    (when from-bol-p
      (beginning-of-line))
    (looking-at (concat regexp dp-c*-junk-after-eos*))))

(defun* dp-looking-back-at-close-paren-p (&optional final-p)
  (when (dp-c-looking-back-at-sans-eos-junk "\\()\\)")
    (let ((close-paren-pos (match-beginning 0))
          close-paren-pos2)
      (unless final-p
        (return-from dp-looking-back-at-close-paren-p close-paren-pos))
      (and (setq close-paren-pos2 (save-match-data
                                    (dp-c-find-stmt-closing-paren)))
           (= close-paren-pos close-paren-pos2)
           close-paren-pos))))

(defun* dp-make-n-replacements (n &optional (first-n 0))
  (loop for i from first-n to (1- (+ first-n n))
    concat (format "\\%d" i)))

(defvar dp-c-open-brace-present-regexp
  ;; // handles case where we have a {  // followed by a comment.
  "\\s-*\\(const\\)?\\s-*\\({.*$\\|\\s-*\\(//.*\\|\\s-*\\)\n[ \n\t]*{\\)"
;;;  "\\s-*\\(const\\)?\\s-*\\({.*$\\|\\s-*//.*\n[ \n\t]*{\\)"
;;;  "\\s-*\\(const\\)?\\s-*\\($\\|{.*$\\|\\s-*//.*\n[ \n\t]*{\\)"
  "Regular expression to determine if an opening brace is present.")


(defun* dp-c-ensure-opening-brace (&key ; <:eob:>
                                   (regexp dp-c-open-brace-present-regexp)  
                                   (newline-before-brace t)
                                   (ignore-eos-junk-p t)
                                   (regexp-prefix "")
                                   ;; the following default has problems
                                   ;; whether nil or non-
                                   ;; Find the error CALLERS and set
                                   ;; appropriately.
                                   (force-newline-after-brace-t nil)
                                   (replacement ""))
  "!<@todo XXX Add a force blank line after brace predicate.
I added the idea that this would return a valuing telling the caller if
anything was done to prevent double newlines. I need to determine then this
is the case.
non-nil tells the caller there is nothing more to do.
aa bb(
    aa,
    bb,
    cc)
{
    -!-f(1,1);
If off, point is at f.
If on, transform to:

aa bb(
    aa,
    bb,
    cc)
{
    -!-
    f(1,1);

"
  (interactive)
  (let ((ret 'unset))
    (if (looking-at (concat regexp-prefix regexp))
        (progn
          (goto-char (match-end 0))
          (when (= (forward-line 1) 0)
            ;; We know we have a newline after the brace. We don't want to
            ;; force another one.
            (setq force-newline-after-brace-t nil)
            (dp-c-indent-command)
            (setq ret t)))        ; Did nothing. Don't want dp-cob to add one.
      (dp-c-end-of-line)
      (if (dp-looking-back-at ";\\s-*")
          ;;(dp-c-newline-and-indent t)
          ;; Results in 2 (two, ii, 0010) newlines.
          (setq ret t)
        (end-of-line)
        (if (not newline-before-brace)
            (let ((last-command-char ?\{))
              (dp-c-end-of-line)
              (dp-c-electric-brace nil))
          (dp-c-newline-and-indent)
          (insert "{")
          (dp-c-indent-command)
;   (if (looking-at "[ \n\t]+")
;       (replace-match ""))
          (newline)
          (insert " ")           ; A comment at the left margin won't indent.
          (dp-c-indent-command)))
      ;; !!! added t to see if it helps with if/for/while/etc w/o hurting
      ;;     function defs too much. There are far fewer function defs than the
      ;;     others.
      (when (or force-newline-after-brace-t
                ;; (looking-at (concat dp-ws-regexp* "$"))
                )
        (c-newline-and-indent)
        (previous-line 1)
        (dp-c-indent-command)
        t))
    ret))                              ; I'm confused about this whole thing.

(defun dp-c-context-line-break ()
  "Do special things at the end of a line."
  (interactive "*")
  (if (and (dp-c-in-syntactic-region dp-c-add-comma-@-eol-of-regions)
           (looking-at "\\s-*$")
           (save-excursion
             (not (dp-point-follows-regexp "[-,:\\&;+=|.!@#$%^*(_/?]\\s-*"))))
      (dp-open-newline)
    (call-interactively 'c-context-line-break)))

(defun* dp-open-above (&optional open-newline-p)
  "Newline before current line."
  (interactive (list (not current-prefix-arg)))
  (if open-newline-p
      (progn
        (forward-line -1)
        (dp-open-newline))
    (beginning-of-line)
    (if (dp-in-c)
        (c-context-line-break)
      (newline-and-indent)
      (forward-line -1))
    (indent-for-tab-command)))

(defun dp-beginning-of-buffer (&optional no-save-pos-p)
  "Goto beginning of buffer, quickly, and
remember where we were in bookmarks: tbbm* and gbbm* and
on the go back ring."
  (interactive "_P")
  (unless no-save-pos-p
    (dp-push-go-back "dp-beginning-of-buffer"))
  (goto-char (point-min)))

(defun dp-blank-line-p ()
  "Pretty much what the name says: return non-nil if the line is blank.
`Blank' is henceforth defined as a region which is entirely white space or
empty."
  (save-excursion
    (beginning-of-line)
    (looking-at "^\\s-*$")))

(defun dp-end-of-buffer (&optional no-save-pos-p)
  "Goto end of buffer, quickly, and
remember where we were in bookmarks: tbbm* and gbbm* and
on the go back ring."
  (interactive)
  (dp-set-zmacs-region-stays t)
  ;; set top/bottom bookmark, a way to go back quickly
  (unless no-save-pos-p
    (dp-push-go-back "dp-end-of-buffer"))
  (goto-char (point-max)))

(dp-deflocal dp-il&md-dont-fix-comments-p nil
  "Some icky language [major modes] simply do not understand how to indent a
  comment on a line of its own using either, in the case of perl, # or ##.")

(defun dp-func-and-move-down (func pred new-this-command &rest func-args)
  "Perform an op on a line and move to the next. 
Motivated by `dp-indent-line-and-move-down'."
  (interactive "*")
  ;;(beginning-of-line)
  (let ((goal-column nil))
    (when (or (eq pred t)
              (funcall pred))
      (apply func func-args))
    (next-line 1))

  ;; python-mode does different things if the previous command was an indent
  ;; command, so we make sure this isn't true.  This should be OK since this
  ;; command is supposed to emulate the key sequence <tab><down>, so the
  ;; `this-command' would not be an indent function.
  (when new-this-command
    (setq this-command new-this-command)))
;;
;; A bunch of these often works better than indent-region.
;; I've seen indent-region get confused and make mistakes,
;; but indenting line-by-line seems to always work.
(defun dp-indent-line-and-move-down (arg)
  "Indent line mode as per mode, tidy it up and move to then next line.
Tidying includes: re `indent-for-comment' and fixing up white space."
  (interactive "*p")
  (loop repeat arg do
    (dp-func-and-move-down
     (function
      (lambda ()
        (back-to-indentation)           ;shell mode needs this
        ;; Sadly, many modes don't handle TAB consistently. Sometimes it's
        ;; `indent-for-tab-command' or `indent-according-to-mode' or...
        ;; Since this is very much like a keystroke macro of
        ;; BOL, TAB, NEXT-LINE, we'll just use the tab key itself.
        ;;(indent-according-to-mode)
        (dp-press-tab-key)
        (unless (or (Cu--p)
                    dp-il&md-dont-fix-comments-p)
          (dp-with-saved-point nil
            (dp-fix-comment)))
        (dp-cleanup-line)))
     t
     'forward-line)))

(defun dp-fix-comment-and-move-down ()
  (interactive)
  (dp-func-and-move-down
   (function
    (lambda ()
      (dp-with-saved-point nil
        (dp-fix-comment))))
   t
   'forward-line))

(defun dp-delete-indentation-and-move-down (&optional arg)
  "Delete the current line's indentation whitespace.
Then fix any comments, and move to then next line."
  (interactive "*")
  (beginning-of-line)
  (when (looking-at "\\s-+")
    (delete-region (match-beginning 0) (match-end 0))
    (unless (Cu--p)
      (dp-with-saved-point nil
        (dp-fix-comment))))
  (forward-line 1))

(defun dp-delete-word (arg)
  "Delete characters forward until encountering the end of a word.
With argument, do this that many times.  Main change is to allow a
sequence of white-space at point to be deleted with this command.
Based (now, loosely) on kill-word from simple.el"
  (interactive "*p")
  ;; XXX look at skip-chars-forward/backward
  (let ((ws "\\(\\s-\\|\n\\)+")
	(opoint (point)))
    (if (or
	 ;; kill forward, sitting on white space.  kill using match
	 ;; data from looking-at
	 (and (> arg 0)
	      (looking-at ws))
	 ;; kill backwards.
	 ;; move back a char (if possible).
	 ;; if on whitespace, continue
	 ;;  else return to where we were
	 ;; go back to non-whitespace
	 ;; match ws up to where we started
	 ;; use that match data to delete.
	 (and (< arg 0)
	      (not (bobp))
	      (not (backward-char 1))	; return nil when successful (always?)
	      (if (looking-at ws)
		  t
		(forward-char 1))
	      (re-search-backward "[^ 	\n]" nil t)
	      (not (forward-char 1))
	      (re-search-forward ws opoint t)))
	(delete-region (match-beginning 0) (match-end 0))
      ;; if we're not killing white space, kill a word in
      ;; the requested direction.
      (delete-region (point) (progn (forward-word arg) (point))))))
  
(defun dp-backward-delete-word (arg)
  "Delete characters backward until encountering the end of a word.
With argument, do this that many times.  Based on backward-kill-word
from simple.el"
  (interactive "*p")
  (dp-delete-word (- arg)))

(defun dp-point-to-top (arg)
  "Put line containing point at the top of the window."
  (interactive "P")
  (dp-set-zmacs-region-stays t)
  (if (eq arg '-)
      (dp-point-to-bottom nil)
    (let ((line (if arg
                    (prefix-numeric-value arg)
                  0)))
      (recenter line))))
(put 'dp-point-to-top 'isearch-command t)
(put 'recenter 'isearch-command t)

(defun dp-point-to-bottom (arg)
  "Scroll the current window so that the line containing point is at the bottom of the window."
  (interactive "P")
  (if (eq arg '-)
      (dp-point-to-top)
    (recenter (- (window-displayed-height) 1))))
(put 'dp-point-to-bottom 'isearch-command t)

(defvar dp-center-to-top-divisor 2
  "Divide frame height by this to get new line for top of screen.")

(defun dp-center-to-top (&optional arg recursing-p)
  (interactive "_P")
  (if (and (not (eq arg '-))
           (or (memq last-command 
                    '(dp-center-to-top dp-center-to-bottom
                      dp-center-to-top-other-window 
                      dp-center-to-bottom-other-window))
               recursing-p))
      (setq dp-center-to-top-divisor (* 2 dp-center-to-top-divisor))
    (setq dp-center-to-top-divisor 2))
  (let* ((orig-arg arg)
         (arg-down (eq arg '-))
         (going-down (or arg-down
                         (eq last-command 'dp-center-to-bottom)))
         (arg (if arg-down nil arg))
         (win-start (window-start))
         (recenter-N (funcall (if going-down '- '+) 
                              (/ (window-height) dp-center-to-top-divisor))))
    (if arg
        (progn
          (recenter (prefix-numeric-value prefix-arg))
          (setq this-command 'recenter))
      (if (eq recenter-N 0)
          (progn
            (move-to-window-line nil)
            (setq dp-center-to-top-divisor 2))
        (recenter (if (eq dp-center-to-top-divisor 2) 
                      nil               ;redraws as per standard ^L
                    recenter-N))
        ;; don't recenter if we're already centered.
        (if (and (not recursing-p)
                 (= win-start (window-start)))
            (dp-center-to-top orig-arg 'recursing-p)))
      (setq this-command (if going-down 
                             'dp-center-to-bottom
                           'dp-center-to-top)))))
(put 'dp-center-to-top 'isearch-command t)

(defun dp-center-to-top-other-window (&optional arg recursing-p)
  (interactive "_P")
  (dp-op-other-window nil 'call-interactively 'dp-center-to-top))

(put 'dp-center-to-top-other-window 'isearch-command t)

(defun* dp-bound-rest-of-line (&key from-beginning-p (no-newline-p t) 
                               all-if-@-eolp text-only-p
                               ignore-eol-punctuation-p)
  "Very minor convenience function."
  (dp-line-boundaries text-only-p 
                      no-newline-p 
                      (if (or from-beginning-p
                              (and (eolp) all-if-@-eolp))
                          (line-beginning-position)
                        (point))
                      ignore-eol-punctuation-p))
  
(defun dp-delete-to-end-of-line ()
  (interactive "*")
  (delete-region (point) (line-end-position)))

(defun* dp-mark-to-end-of-line (&optional from-beginning-p (no-newline-p t))
  "Mark rest of line.  Leaves region active.
if FROM-BEGINNING-P, mark entire line. Leaves cursor @ end-of-region."
  (interactive "_P")
  (let ((region (dp-bound-rest-of-line :from-beginning-p from-beginning-p
                                       :no-newline-p no-newline-p)))
    (dp-set-mark (car region))
    (goto-char (cdr region))))
  

(defun dp-copy-to-end-of-line (&optional beginning include-newline)
  "Copy chars from point to the end of the current line to the kill ring."
  (interactive "P")
  ;;(copy-region-as-kill
  (kill-ring-save
   (cond
    ((memq beginning '(from-beginning -))
     (line-beginning-position))
    ((number-or-marker-p beginning) beginning)
    ((null beginning) (point))
    ((functionp beginning) (funcall beginning))
    (t (line-beginning-position)))
   (+ (line-end-position)
      (if (and include-newline 
               (< (line-end-position)
                  (point-max)))
          1
        0))))

;;
;; dp-push tag and friends are now retired (in peace).
;; the *emacs guys added their own version
;; my old code is in odds'n'ends.
;;

(defun dp-toggle-kb-macro-def ()
  "Toggle keyboard macro definition."
  (interactive)
  (if defining-kbd-macro
      (end-kbd-macro)
    (start-kbd-macro nil)))

(defvar dp-buffer-menu-invocation-arg nil
  "Arg that dp-buffer-menu was invoked with.")

(defun* dp-buffer-menu (&optional arg (listing-function 'buffer-menu))
  "Invert the arg to buffer-menu so that ARG is required
to have buffer-menu show non-file buffers."
  (interactive "P")
  (setq dp-buffer-menu-invocation-arg arg)
  (funcall listing-function (not arg)))

(defun dp-refresh-buffer-menu ()
  (interactive)
  (dp-buffer-menu dp-buffer-menu-invocation-arg))

(defun dp-list-buffers (&optional arg)
  (interactive "P")
  (dp-buffer-menu (not arg) 'list-buffers))

(defun* dp-comment-out-region (&optional sexp-p (comment-comment-text "")
                               comment-tag
                               bracket-p)
  "Comment out the region if active, else the current line.
If no comment syntax is defined, prompt for beginning and ending
syntax strings.
COMMENT-COMMENT-TEXT is some extra text to place between the `comment-start'
string and another string which I forget how it is determined.
E.g. ;; commented out by dp-comment-out-sexp;"
  (interactive "P")
  ;; make local vars in case start or end are not set.
  (let* (we-set-comment-start
         (comment-start0 (or block-comment-start comment-start
                             (progn (setq we-set-comment-start "") nil)
                             (read-from-minibuffer "Comment start: " "# ")))
         (comment-start (or (dp-build-co-comment-start comment-tag
                                                       comment-start0)))
         (ce (or block-comment-end comment-end))
         (comment-end (concat (or (and ce
                                       (not (string-equal ce ""))
                                       ce)
                                  (cond
                                   ;; known rest of line comments
                                   ;; (comment-end is "")
                                   ((or 
                                     (string-equal comment-start "#")
                                     (string-equal comment-start ";"))
                                    ""))
                                  (if we-set-comment-start nil "")
                                  (read-from-minibuffer "Comment end: " "")
                                  "")
                              comment-comment-text)))
    (if sexp-p
        (call-interactively 'dp-comment-out-sexp)
      (let* ((region (dp-region-or... :bounder 'line-p))
             (beg (car region))
             (end (cdr region))
             text)
        (if (not bracket-p)
            (comment-region beg end)
          (setq text (format "%s%s"
                             comment-start
                             (if (or (not comment-end)
                                     (string= comment-end ""))
                                 ""
                               (concat " " comment-end))))
          (io-region beg end text text t))))))

(defun dp-comment-bracket-with-tag (tag)
  (interactive "sComment bracket tag: ")
  (dp-comment-out-region nil nil tag t))
(dp-defaliases 'cob 'dp-comment-bracket-with-tag)

(defun* dp-comment-out-region-olde (&optional sexp-p (comment-comment-text "")
                               comment-tag)
  "Comment out the region if defined, else the current line.
If no comment syntax is defined, prompt for beginning and ending
syntax strings.
COMMENT-COMMENT-TEXT is some extra text to place between the `comment-start'
string and another string which I forget how it is determined.
E.g. ;; commented out by dp-comment-out-sexp;"
  (interactive "P")
  ;; make local vars in case start or end are not set.
  (let* (we-set-comment-start
         (comment-start0 (or block-comment-start comment-start
                             (progn (setq we-set-comment-start "") nil)
                             (read-from-minibuffer "Comment start: " "# ")))
         (comment-start (or (dp-build-co-comment-start comment-tag
                                                       comment-start0)))
         (ce (or block-comment-end comment-end))
         (comment-end (concat (or (and ce
                                       (not (string-equal ce ""))
                                       ce)
                                  (cond
                                   ;; known rest of line comments
                                   ;; (comment-end is "")
                                   ((or 
                                     (string-equal comment-start "#")
                                     (string-equal comment-start ";"))
                                    ""))
                                  (if we-set-comment-start nil "")
                                  (read-from-minibuffer "Comment end: " "")
                                  "")
                              comment-comment-text)))
    (cond 
     ((dp-mark-active-p) (call-interactively 'comment-region))
     (sexp-p (call-interactively 'dp-comment-out-sexp))
     (t (dp-func-on-region-or-line 'comment-region)))))

(dp-safe-alias 'co 'dp-comment-out-region)

;CO; (defun dp-comment-out-sexp ()
;CO;   "Comment out the sexp we are in without clobbering parens from enclosing sexps."
;CO;   (interactive)
;CO;   (unless (dp-looking-back-at "^\\s-*")
;CO;     (newline-and-indent))
;CO;   (save-excursion 
;CO;     (paren-forward-sexp)
;CO;     (when (looking-at "\\s-*\\()\\|,\\)")
;CO;       (goto-char (match-end 0))
;CO;       ;;(forward-char)
;CO;       (newline-and-indent)))
;CO;   (mark-sexp)
;CO;   (dp-comment-out-region)
;CO;   (dp-deactivate-mark))

(defun dp-comment-out-sexp (&optional add-tag-p)
  "Comment out the sexp we are in without clobbering parens from enclosing sexps."
  (interactive "P")
  (save-excursion 
    (when (dp-in-code-space-p)
      (undo-boundary)
      (if (dp-looking-back-at "^\\s-*")
          (beginning-of-line)
        (newline))
      (let ((mark (dp-mk-marker))
            point-delta)
        (paren-forward-sexp)
        (setq point-delta
              (cond
               ((looking-at "\\s-*)") -1)
               ((looking-at "\\s-*,") 1)
               ((looking-at "\\s-*\\($\\|;\\)") 1)
               (t (error "Confuzed in `dp-comment-out-sexp'"))))
        (when point-delta
          (goto-char (match-end 0))
          (backward-char)
          (newline-and-indent))
        (save-excursion
          (dp-mark-region (cons mark (+ point-delta (point))))
          (if add-tag-p
              (let (current-prefix-arg)
                (call-interactively 'dp-comment-out-with-tag))
            (dp-comment-out-region)))
        (when (dp-in-code-space-p)
          (indent-for-tab-command))
        (dp-deactivate-mark)))))
(dp-safe-alias 'cosexp 'dp-comment-out-sexp)

(defun dp-comment-out-with-tag (tag)
  (interactive "sComment out tag: ")
  (dp-comment-out-region nil nil tag))
(defalias 'co-tag 'dp-comment-out-with-tag)
(defalias 'co-w/tag 'dp-comment-out-with-tag)
(defalias 'cow/tag 'dp-comment-out-with-tag)
(defalias 'co+tag 'dp-comment-out-with-tag)
(defalias 'co&tag 'dp-comment-out-with-tag)
(defalias 'cotag 'dp-comment-out-with-tag)
(defalias 'cot 'dp-comment-out-with-tag)

(defsubst cot-old ()
  (interactive)
  (dp-comment-out-with-tag "old"))
(defalias 'coto 'cot-old)

(defun cot-exp ()
  (interactive)
  (dp-comment-out-with-tag "exp"))

(defun cot-oem ()
  (interactive)
  (dp-comment-out-with-tag "OEM"))

(defun cot-debug ()
  (interactive)
  (dp-comment-out-with-tag "debug"))

(defun cot-remove ()
  (interactive)
  (dp-comment-out-with-tag "remove"))

(defun cot-asap-remove ()
  (interactive)
  (dp-comment-out-with-tag "REMOVE ASAP!"))

(defun cot-needed ()
  (interactive)
  (dp-comment-out-with-tag "needed?"))

(defun cot-stale? ()
  (interactive)
  (dp-comment-out-with-tag "stale?"))

(defun cot-b0rked? ()
  (interactive)
  (dp-comment-out-with-tag "b0rked?"))

  
(defsubst dp-comment-out-with-tag-OEM (&optional no-kill-first-p
                                       append-p)
  "Comment out, marked with OEM to indicate as installed code.
By default, copy the selection (or current line) to the kill ring since we
often use this kind of command before changing an original value. "
  (interactive "P")
  (unless no-kill-first-p
    (dp-kill-ring-save append-p))
  (dp-comment-out-with-tag "OEM"))

(dp-safe-alias 'cooem 'dp-comment-out-with-tag-OEM)
(dp-safe-alias 'coem 'dp-comment-out-with-tag-OEM)
(dp-safe-alias 'coorig 'dp-comment-out-with-tag-OEM)
(dp-safe-alias 'corig 'dp-comment-out-with-tag-OEM)

(defun io-region (m p start-text end-text 
                  &optional no-complaints-p no-deactivate-mark-p)
  "Ifdef out a region."
  (if (and (not no-complaints-p)
           (not (dp-in-c))
           (not (y-or-n-p "Buffer does not look C-like, continue?")))
      (message "Canceled,")
    (save-excursion
      (let* (a b c
             (beg-end (dp-region-or... :beg m :end p))
             (m (car beg-end))
             (p (cdr beg-end)))
        ;; insert ending chars first so we don't scoot the end to somewhere
        ;; else
        (goto-char p)
        (setq c (dp-mk-marker))
        (if (bolp)
            (insert end-text "\n")
          (end-of-line)
          (insert "\n" end-text)
          (setq p (line-beginning-position)))
        ;; Give any inserted comment proper indentation.
        (save-excursion
          (goto-char p)
          (dp-c-fix-comment))
        (setq end (point-marker))
        (goto-char m)
        (beginning-of-line)
        (setq beg (point-marker))
        (setq a (dp-mk-marker))
        (insert start-text)
        (insert "\n")
        (setq b (dp-mk-marker))
        (save-excursion
          (goto-char beg)
          (dp-c-fix-comment))
        (unless no-deactivate-mark-p
          (dp-deactivate-mark))
        (list (cons beg end) a b c)))))

(defconst io-start-text-default "#if 0"
  "Default value for io-start-text")

(defconst io-end-text-default   "#endif"
  "Default value for io-end-text")

;; @todo make these defcustoms and change name to dp-...
(defvar io-start-text io-start-text-default
"*Value used to start the #ifdef out of a region.
Used and set by \\[io] and used by \\[io-region].")

(defvar io-end-text io-end-text-default
"*Value used to end the #ifdef out of a region.
Used and set by \\[io] and used by \\[io-region].")

(defun dp-simple-C-uncomment (s &optional open-repl close-repl)
  (interactive)
  (replace-in-string (replace-in-string s 
                                        "/\\*" 
                                        (or open-repl "/."))
                     "\\*/" 
                     (or close-repl "./")))

(defun fo (beg end)
  (interactive "r")
  (folding-fold-region beg end)
  (folding-shift-out)
  (folding-show-current-entry))

(defun cfo (beg end)
  (interactive "r")
  (folding-mode 1)                      ; We need it on for the following.
  (fo beg end)
  (folding-comment-fold))

(defvar dp-ifdef-region-function nil
  "Function to call to do actuall if-deffing out.")

(defvar dp-if-region-function nil
  "Function to call to do actuall iffing out.")

(defun dp-lisp-if-region (beg end)
  "Wrap the region in \(when nil ...)"
  (interactive "r")
  (save-excursion
    (goto-char end)
    (end-of-line)
    (insert "\n)")
    (goto-char beg)
    (insert "(when nil\n")))

(defun dp-if-region ()
  "If out a region."
  (interactive)
  (dp-funcall-if 'dp-if-region-function
      (error 'void-function '(or variable) 'dp-if-region-function)))

(defvar dp-ifdef-region-read-arg-history '()
  "Previously read #ifdef args.")

(defun dp-ifdef-region-read-arg ()
  (list (if (Cu--p current-prefix-arg)
            (read-string "#ifdef text: " 
                         nil 'dp-ifdef-region-read-arg-history)
          (prefix-numeric-value current-prefix-arg))))

(defun* dp-ifdef-region (&optional arg else-p tss-prefix)
  "Ifdef out a line or region.
ARG is value to use as start text of the ifdef.  
If ARG starts with a DIGIT, you get #if ARG.
If ARG starts with a LETTER, you get #ifdef ARG.
If interactive and ARG is C--, prompt for #ifdef TEXT.
If ARG is 0, e.g. C-0 or C-u0, reset `io-start-text' to `io-start-text-default'.
   Ditto for end-text.
Otherwise you get ARG.
ARG is saved for future use in `io-start-text'.
It is initialized to #if 0"
  (interactive (dp-ifdef-region-read-arg))
  (if (and (not (dp-in-c))
           (not (and 
                 (y-or-n-p "Buffer does not look C-like, comment out? ")
                 (progn 
                   (call-interactively 'dp-comment-out-region)
                   (return-from dp-ifdef-region))))
           (not (y-or-n-p "Buffer does not look C-like, continue? ")))
      (and (message "Canceled.") nil)
    (if (and arg (numberp arg)
             (/= arg 1))
        (if (or (eq arg 0)        ;C-0 seems natural for requesting resetment
                (> arg 4))              ;e.g. 2xC-u
            (setq io-start-text io-start-text-default
                  io-end-text io-end-text-default)
          ;; @todo what would a sensible completion list be?
          (let ((dp-use-region-as-INITIAL-CONTENTS nil))
            (setq arg (read-from-minibuffer "arg: ")))
          (if (string= arg "")
              (setq io-start-text io-start-text-default
                    io-end-text io-end-text-default))))
    (if (and (numberp arg)
             (= arg 1))
        (setq arg ""))
    (cond
     ((and (stringp arg)
           (posix-string-match "^[0-9]" arg))
      (setq io-start-text (format "#if %s" arg)))
     
     ((and (stringp arg)
           (posix-string-match "^[a-zA-Z_]" arg))
      (setq io-start-text (format "#ifdef %s" arg)))
     
     ((string-equal arg "")
      nil)
     
     (t
      (setq io-start-text arg)))
    (let* ((else-string (if else-p "
#else"
                         ""))
           (tss-prefix (if tss-prefix
                           (concat tss-prefix " ")
                         ""))
           (tss-comment (format " /* %s%s */"
                                tss-prefix
                                (dp-timestamp-string)))) ; Keep 'em identical.
      (setq io-end-text (format "#endif /* %s */" 
                                (dp-simple-C-uncomment io-start-text)))
      (save-excursion
        (dp-mark-line-if-no-mark)
        ;;(message (format "using %s" io-start-text))
        (io-region (mark) (point) 
                   (concat io-start-text tss-comment else-string)
                   (concat io-end-text tss-comment))))))

(defun dp-ifdef-out (&optional arg)
  (interactive (dp-ifdef-region-read-arg))
  (let ((locations (dp-ifdef-region arg nil)))
    (when locations
      (goto-char (nth 1 locations)))))

(dp-defaliases 'if0 'io0 'io 'dp-ifdef-out)

(defun dp-ifdef-new (&optional arg)
  "#ifdef a block of code out and define a region where alternate code can go.
E.g.
#if 1                           /* 2012-06-21T09:12:56 */
/* Trying replacement code */

#else
<old/orig code is here>
...
#endif"
  (interactive (dp-ifdef-region-read-arg))
  (let ((locations (dp-ifdef-region "1" 'else-p)))
    (goto-char (nth 1 locations))
    (dp-open-newline)
    (insert "/* Trying replacement code */")
    (dp-open-newline)))

(dp-defaliases 'if1 'io1 'ioin 'ionew 'dp-ifdef-new)

(defun* dp-ifdef-region-because (excuse &optional (not ""))
  (interactive "sExcuse text: ")
  (setq excuse (dp-c-namify-string excuse))
  (dp-mark-line-if-no-mark)
  (io-region (mark) (point) 
             (format "#if %sdefined(%s) && 0 /* @todo as of %s :dp */"
                     not
                     (dp-c-namify-string excuse)
                     (dp-timestamp-string))
             (format "#endif /* %s %s */" not excuse)))
(defalias 'iob 'dp-ifdef-region-because)

(defun dp-ifdef-tag (&optional tag)
  (interactive "sTag: ")
  (dp-ifdef-region-because tag))
;; Adding longer aliases can help identify the command.
(dp-defaliases 'iotag 'iot 'dp-ifdef-tag)

(defun dp-notyet ()
  (interactive)
  (dp-ifdef-region-because "notyet"))
(dp-defaliases 'notyet 'not-yet 'later 'ny 'dp-notyet)

(defun dp-maybe-later ()
  (interactive)
  (dp-ifdef-region-because "maybe_later"))
(dp-defaliases 'maybe 'possibly 'consider 'maybe-later 'dp-maybe-later)

(defun dp-io-for-now ()
  (interactive)
  (dp-ifdef-region-because "for_now"))
(defalias 'for-now 'dp-io-for-now)

(defun dp-io-ideas ()
  (interactive)
  (dp-ifdef-region-because "ideas"))
(defalias 'ioideas 'dp-io-ideas)

(defun dp-io-exp ()
  (interactive)
  (dp-ifdef-region-because "exp"))
(dp-defaliases 'ioexp 'dp-io-exp)

(defun dp-io-commentary ()
  (interactive)
  (dp-ifdef-region-because "commentary"))
(defalias 'iocommentary 'dp-io-commentary)

(defun dp-io-example ()
  (interactive)
  (dp-ifdef-region-because "example"))
(dp-defaliases 'ioeg 'ioexample 'dp-io-example)

(defun dp-io-noodling ()
  (interactive)
  (dp-ifdef-region-because "noodling"))
(dp-defaliases 'ionoodle 'iodoodle 'ioidle 'dp-io-noodling)

(defun dp-io-needed ()
  (interactive)
  (dp-ifdef-region-because "is this needed?"))
(dp-defaliases 'ioneeded 'dp-io-needed)

(defun dp-io-xxx ()
  (interactive)
  (dp-ifdef-region-because "XXX_@Todo"))

(defun xxx()
  (interactive)
  (if (dp-region-active-p)
      (dp-io-xxx)
    ;; The doxygen element syntax is different when it comes after a line vs
    ;; before it.
    ;; e.g.
    ;; /*!
    ;;  *!@todo blah
    ;;  */
    ;; vs:
    ;; bad_thing(tm);   //!<@todo.
    ;; So fix it.
    (dp-insert-for-comment+ "XXX " "@todo " :sep-char ""
                            :doxy-prefix (if (dp-in-a-c*-comment)
                                             ""
                                           "!<"))))

(defvar dp-ifdef-debug-level 0
  "Current debug level to use in debug ifdefs.")

(defvar dp-ifdef-debug-const "DEBUG"
  "Current debug manifest constant to use in debug ifdefs.")

(defun dp-ifdef-debug-code (&optional debug-level)
  (interactive)
  (if (numberp debug-level)
      ()
    (setq debug-level
          (cond 
           ((not current-prefix-arg) dp-ifdef-debug-level)
           
          (if current-prefix-arg
              (setq dp-ifdef-debug-level
                    (1- (prefix-numeric-value current-prefix-arg)))
            dp-ifdef-debug-level))))
  (dp-c-mark-statement-if-no-mark)
  (io-region (mark) (point)
             (format "#if defined(%s) && (%s > %s)" dp-ifdef-debug-const 
                     dp-ifdef-debug-const debug-level)
             (format "#endif /* %s */" dp-ifdef-debug-const)))
(defalias 'difd 'dp-ifdef-debug-code)
(defalias 'iodebug 'dp-ifdef-debug-code)

(defun dp-ifdef-comment ()
  (interactive)
  (dp-mark-line-if-no-mark)
  (io-region (mark) (point)
             "#if defined(THIS_IS_A_BIG_OL_COMMENT) && 0"
             "#endif /* THAT_WAS_A_BIG_OL_COMMENT */"))

(defalias 'idc 'dp-ifdef-comment)

(defun dp-ifdef-for-testing ()
  (interactive)
  (dp-mark-line-if-no-mark)
  (io-region (mark) (point)
             (format "#if 0  /* XXX @todo ifdef'd out on %s out for TESTING */"
                     (dp-timestamp-string))
             "#endif /* commented out for testing */"))
(defalias 'idt 'dp-ifdef-for-testing)

(defun dp-is-this-code-*-ed (xxx-ed)
  "Wrap an #ifdef 0 around some code, telling why it is #ifdeffed out.
XXX-ED tells us why, e.g. `wanted' `needed', etc."
  (interactive "sIs this code? ")
  (dp-mark-line-if-no-mark)
  (io-region (mark) (point) 
             (format "#if 0 /* @todo: is this code %s? %s :dp */" 
                     xxx-ed (dp-timestamp-string))
             (format "#endif /* is this code %s? */" xxx-ed)))

(defun dp-is-this-code-needed ()
  (interactive)
  (dp-is-this-code-*-ed "needed"))
  
(defalias 'needed 'dp-is-this-code-needed)

(defun dp-is-this-code-wanted ()
  (interactive)
  (dp-is-this-code-*-ed "wanted"))
(defalias 'wanted 'dp-is-this-code-wanted)

(defun dp-is-this-code-used ()
  (interactive)
  (dp-is-this-code-*-ed "used"))
(defalias 'used 'dp-is-this-code-used)

(defun dp-c-mark-current-token ()
  (interactive "_")
  (dp-activate-mark)
  (dp-c-beginning-of-current-token))

(defun dp-c-mark-statement ()
  (interactive)
  (let ((region (dp-c-delimit-statement)))
    (dp-set-mark (car region))
    (goto-char (cdr region))
    (dp-set-zmacs-region-stays t)))

(defun dp-c-mark-statement-if-no-mark ()
  (interactive)
  (unless (dp-mark-active-p)
    (dp-c-mark-statement)))

(defvar dp-c*-junk-after-eos*
  ;; 1  2          3                        4  x
  "\\(\\(\\s-*\\)\\(const\\)?\\(?:\\s-*\\)\\(\\(?:$\\|//\\|/\\*\\|$\\).*\\)?\\)"
;;"\\(\\(\\s-*\\)\\(const\\)?\\(?:\\s-*\\)\\(\\(?://\\|/\\*\\|$\\).*\\)\\)$"
  
  "Legal junk that can come after/delimit a statement.
Match strings (any may be \"\"):
1: whole thing (same as ms(0)?),
2: intervening white space
3: const keyword if one is present
4: Comment text from // or /* (inclusive) to end of line.
e.g. Looking for \")\" followed by dp-c-junk-after-eos is better than just
looking for \\s-*.  Also, the junk match can be retained so a replace-match
could, in this case, use: \";\\1\n\" which would leave comments, etc, in
place.
NB: You must count any parenthesized groups in your regexp when using functions like
")

(defvar dp-c*-junk-after-eos+
  ;; 1  2          3                        4  x
  "\\(\\(\\s-*\\)\\(const\\)?\\(?:\\s-*\\)\\(\\(?://\\|/\\*\\).*\\)\\)\n"
;;  "\\(\\(\\s-*\\)\\(const\\)?\\(?:\\s-*\\)\\(\\(?://\\|/\\*\\).*\\)\\)$"
  
  "Like `dp-c*-junk-after-eos*' but won't allow an empty match,")

(defvar dp-c*-junk-all 1)               ; Or "".
(defvar dp-c*-junk-ws 2)                ; If any.
(defvar dp-c*-junk-const 3)             ; If one.
(defvar dp-c*-junk-comment 4)           ; If one.

(defvar dp-c*-junk-all-grp (format "\\\\%s" dp-c*-junk-all))
(defvar dp-c*-junk-ws-grp (format "\\\\%s" dp-c*-junk-ws))
(defvar dp-c*-junk-const-grp (format "\\\\%s" dp-c*-junk-const))
(defvar dp-c*-junk-comment-grp (format "\\\\%s" dp-c*-junk-comment))

(defvar dp-c*-keywords-needing-parens
  (concat "else\\s-+if\\|"
          (regexp-opt '("for" "if" "while" "switch")))
  "Keywords that have parenthesized expressions after them.  
Like function calls they look.")

(defvar dp-c*-keywords-with-stmt-blocks
  (concat "\\(?:" 
          "else\\s-+if\\|"
          (regexp-opt '("do" "for" "if" "while" "switch"))
          "\\)")
  "Keywords that have statement blocks, {..} after them.")

(defun dp-c-beginning-of-statement ()
  "`c-beginning-of-statement' can leave us in previous cpp code. Move out of it.
Also, it will move backwards into a closed class (ie has a };)."
  (interactive)
  (if (dp-in-cpp-construct-p)
      ;; If we are already on a cpp line, then don't move off of it.
      (beginning-of-line)
    (let ((class-state (dp-in-c++-class))
          (pos (point)))
      (c-beginning-of-statement)
      (cond 
       ((not (eq class-state (dp-in-c++-class) ))
        ;; We backed into a class.  This is bad.
        (goto-char pos)
        (beginning-of-line))
       ((dp-in-cpp-construct-p)
        (while (dp-in-cpp-construct-p)
          (forward-line 1)))))))

(defun dp-c-beginning-of-statement-pos()
  "Return the point to which `dp-c-beginning-of-statement' would like to go."
  (let (end)
    (dp-with-saved-point end
      (dp-c-beginning-of-statement))
    end))

(defun dp-c-end-of-line (&optional dont-skip-eos-junk)
  "Go to the end of line, ignoring trailing WS and comments."
  (interactive)
  (if dont-skip-eos-junk
      (end-of-line)
    (beginning-of-line)
    (if (re-search-forward (concat ".*?\\(" dp-c*-junk-after-eos* "\\)$")
                           (line-end-position) t)
        (goto-char (match-beginning 1))
      (end-of-line))))

(defun* dp-c-terminate-function-stmt () ; <:ctf|cfts:>
  (interactive)
  (save-excursion
    (dp-c-beginning-of-statement)
    (when (looking-at dp-c*-keywords-needing-parens)
      (return-from dp-c-terminate-function-stmt)))
  (dp-c-end-of-line)
  (when (dp-looking-back-at-close-paren-p 'final)
    (replace-match (format "\\1;%s" ; The ) above
                           (if (> (length (match-string (1+ dp-c*-junk-ws))) 1)
                               (substring (match-string (1+ dp-c*-junk-ws)) 1)
                             "\\2")))
    t)                        ; We still need to do the eol/newline thing.
  )
  
(defun dp-c-finish-function ()
  (interactive)
  (dp-open-newline)
  (insert "NOT_WRITTEN_YET();      //!<@todo Finish this!"))
(defalias 'ffun 'dp-c-finish-function)

(defsubst dp-in-indentation-p ()
  "Return non-nil if point is white space at beginning of line."
  (<= (current-column) (current-indentation)))

(defun* dp-c*-pure-comment-line-p (&optional (start (line-beginning-position)))
  "Return non-nil if there is nothing on the current line but a comment."
  (interactive)
  (save-match-data
    (save-excursion
      (goto-char start)
      (or (re-search-forward "^\\s-*//" (line-end-position) t)
          ;; Cheesy!
          (progn
            (goto-char start)
            ;; We were getting non-nil on empty lines.
            (when (dp-in-a-c*-comment)
              (loop repeat (- (line-end-position) start)
                always (dp-in-a-c*-comment)
                do (forward-char 1))))))))

;       (let* ((lep (line-end-position))
;              (line-has-/*-p (re-search-forward "^\\s-*/\\*" lep t)))
;         ;; Only a 1 line comment.
;         (or (re-search-forward "^\\s-*//" lep t)
;             ;; No opening /* but a */ followed by only ws?
;             (and (not line-has-/*-p)
;                  (re-search-forward "\\*/\\s-*$" lep t))
;             ;; Opening /* and not */?
;             (and line-has-/*-p
;                  (or (not (re-search-forward "\\*/" lep t))
;                      (re-search-forward "\\*/\\s-*$" lep t)))))))
    

(defsubst is-c++-one-line-comment ()
  "Determine if this is a C++ one line comment."
  (when (dp-in-c)
    (save-match-data
      (save-excursion
        (end-of-line)
        (re-search-backward "//" (line-beginning-position) t)))))

(defun dp-in-a-c-/**/-comment (&optional syntax-el)
  "A rose is rose."
  (and (dp-in-c)
       (dp-in-a-c*-comment nil syntax-el)
       (not (is-c++-one-line-comment))))

(defvar dp-c-comment-syntax-list '(comment-intro comment))

(defun dp-in-a-c*-comment (&optional intro-too c-syntax c-syntax-ignore-list)
  "Determine if we are inside a C/C++ comment."
  (save-match-data
    (setq-ifnil c-syntax (dp-c-get-syntactic-region c-syntax-ignore-list))
    (and (dp-in-c)
         (or (memq (buffer-syntactic-context) '(comment block-comment))
             (memq c-syntax dp-c-comment-syntax-list)
             (c-got-face-at (point) '(font-lock-comment-face))
             (and (dmessage "C") nil)
             (save-excursion 
               (beginning-of-line)
               (looking-at "^\\s-*//"))
             (and intro-too
                  (dp-c-in-syntactic-region '(comment-intro)))))))

;; cc-mode does this itself now
;; a bit more sophisticatedly, too.
;; c-context-line-break
(defun dp-c-newline-and-indent (&optional end-of-line-first-p)
  "Enter a newline, and indent, and if in C-mode and in
a comment add a comment prefix to the line."
  (interactive "*P")
  (if (not (dp-in-c))
      (newline-and-indent)
    (when end-of-line-first-p
      (end-of-line))
    (let ((syntax-el (dp-c-get-syntactic-region))
          (is-one-liner (is-c++-one-line-comment)))
      ;; we need to preserve the syntax before we indent.
      ;; and the one-liner-ness of the *current* line
      (newline-and-indent)
      (dmessage "syntax-el: %s, is-one-liner: %s, old-C comment: %s"
                syntax-el is-one-liner
                (dp-in-a-c-/**/-comment syntax-el))
      (when (and (dp-in-a-c-/**/-comment syntax-el)
                 (not is-one-liner)
                 ;; This syntax stuff is so fucking hackish, it makes me
                 ;; queasy.  For some reason, the /**/ check returns t
                 ;; because c-got-face-at says that the face at point is
                 ;; 'font-lock-comment-face.  So, eliminate stuff I know to
                 ;; be non-comment. And, if I print the current line, it's
                 ;; empty.
                 (not (memq syntax-el '(access-label))))
        (insert "* ")
        (c-indent-line)))))

(defvar dp-c-electric-slash-fills nil
 "If non-nil, then `dp-c-electric-slash' fills the comment when it closes it.")

(defun dp-c-electric-slash (arg)
  "Close a block comment if we are in one, else do regular electric slashing."
  (interactive "*P")
  (if (dp-in-c)
      (let ((syntax-el (dp-c-get-syntactic-region)))
	(if (and 
	     (dp-in-a-c-/**/-comment syntax-el)
	     (save-excursion
	       (re-search-backward "\*[ \t]+" nil t))
	     (= (match-end 0) (point)))
	    (progn
	      (replace-match "*/")
              (when dp-c-electric-slash-fills
                (save-excursion
                  (beginning-of-line)
                  (c-fill-paragraph)))
	      (newline-and-indent))
	  (c-electric-slash arg)))
    (c-electric-slash arg)))

(defvar dp-doxy-syntax-map
  '((arglist-intro . "@arg")
    (arglist-cont . "@arg")
    (member-init-intro . "@arg")
    (member-init-cont . "@arg")
    (topmost-intro . (dp-c*-doxy-handle-topmost-intro ""))
    (topmost-intro-cont . "@arg"))
  "Mapping from cc-mode syntax to a doxygen type.
The cdr is eval'd; and strings eval to themselves.
All in all, not a very functional table.")

(defvar dp-c-control-keywords "\\(if\\|else\\|while\\|for\\|return\\|do\\)")
(defvar dp-c-control-keywords-bounded 
  (concat "\\<" dp-c-control-keywords "\\>"))

(defvar dp-c-type-list 
  '("auto" "char" "const" "double" "float" "int" "long" "register" "short" 
    "signed" "struct" "union" "unsigned" "void" "volatile" "mutable" "bool"
    "byte" "FILE"
    "int8" "int16" "int32" "int64")
"List of keywords that imply types.
Using both uint16 and int16 break the regexp when this list is passed to 
`regexp-opt'. Same for 32 and 64.
int8 and uint8 seem to work together.
A simple `dp-looking-back-at' using `dp-<type>*-regexp' returns nil.
!<@todo XXX try a simple regexp join rather than opt?")

;; (defvar dp-c-type-list 
;;   (dp-add-list-to-list
;;    'dp-c-type-list
;;    '("auto" "char" "const" "double" "float" "int" "long" "register" "short" 
;;      "signed" "struct" "union" "unsigned" "void" "volatile" "mutable" "bool"))
;;    "List of keywords that imply types.")
  
(defvar dp-c-function-type-decl-re
    (concat
     "\\(?:"
     "\\s-*"
     "\\<"
     ;;   "\\(?:\\(?:static\\|virtual\\|explicit\\)\\<\\S_+\\)?"
     "\\(?:"
     "\\(?:\\(?:static\\|virtual\\|explicit\\)\\>\\)"
     "\\|"
     (regexp-opt dp-c-type-list 'paren)
     "\\|"
     "\\(?:\\sw\\|\\s_\\)+_[ta]"
     "\\)"
     "\\>"
     "\\)+")
    "Junk that can come before a function name.  The whole thing is shy.")

(defvar dp-c-no-comma-after-these (concat dp-c-function-type-decl-re
                                          "\\|"
                                          "\\s-*\\("  ; Added 2009-05-07T18:35:44
                                          dp-c-control-keywords-bounded
                                          "\\)" ; Added 2009-05-07T18:35:44
                                          ));

(defvar dp-doxy-guess-map
  `(("^\\s-*typedef" . "")
    (,dp-c-function-type-decl-re . "") ;this results in //<! which is correct
    )
  "Regular expressions to guess doxy context based on current line.")

(defun dp-isa-type-p ()
  "Return cdr of a dp-doxy-guess-map cons if line re-matches its car.
Point must be before word to match.  In general this means bol.  And some
reg-exps are anchored at bol."
  (interactive)
  (dolist (elt dp-doxy-guess-map nil)
    (if (looking-at (car elt))
        (return (cdr elt)))))

(defun dp-isa-type-line-p ()
  (save-excursion
    (beginning-of-line)
    (dp-isa-type-p)))


(defun dp-c*-insert-doxy-comment ()
  (unless (dp-mark-active-p)
    (let* ((doxy-val (dp-map-context-to-doxy-cmd))
           (doxy-cmd (if (listp doxy-val)
                         (car-safe doxy-val)
                       doxy-val))
           (doxy-args (cdr-safe doxy-val))
           (doxy-cmd (dp-apply-if doxy-cmd
                         doxy-args
                       doxy-cmd)))
      ;; functional handlers will return 'done if they've handled all of the
      ;; commenting duties.
      (unless (eq doxy-cmd 'done)
        (dp-indent-for-comment)
        (when (and doxy-cmd
                   (not (string= doxy-cmd ""))
                   (looking-at (concat (regexp-quote comment-end) "\n")))
          (backward-char)
          (if (looking-at " ")
              (delete-char))
          (undo-boundary)
          (insert dp-c*-doxy-command-prefix doxy-cmd " "))))))

(defun dp-c*-doxy-handle-topmost-intro (default-return)
  "A topmost-intro can contain parameters or just an open paren.
Handle those cases appropriately."
  (end-of-line)
  (if (not (dp-c-looking-back-at-sans-eos-junk "[)({]"))
      default-return
    (dp-insert-tempo-comment)
    'done))

(defun dp-map-context-to-doxy-cmd ()
  "Map the current cc-mode syntax to a doxygen command."
  (or (cdr (assoc (dp-c-get-syntactic-region)
                  dp-doxy-syntax-map))
      ;; make a guess based on text on the line
      (save-excursion
        (beginning-of-line)
        (dp-isa-type-p))))

(setq dp-c*-insert-doxy-cmd-p t)

(defun dp-c-indent-for-comment (&optional arg)
  "Call `indent-for-comment' and then possibly add a Doxygen annotation.
Current annotations are:
@arg if comment is in the arglist."
  (interactive "*P")
  (if (dp-region-active-p)
      (call-interactively 'dp-lineup-comments)
    (if dp-c*-insert-doxy-cmd-p
        (dp-c*-insert-doxy-comment)
      (dp-indent-for-comment arg))))

(defun* dp-c-fill-paragraph (&optional arg)
  "Fill according to C/C++ syntactical context."
  (interactive "*P")
  (let* ((region (dp-mark-active-p))
         (beg-end-list (and region (dp-region-boundaries-ordered-list)))
         (syntax (save-excursion
                   (when region (goto-char (car region)))
                   (end-of-line)
                   (dp-c-get-syntactic-region))))
    (when (and region
               (apply 'dp-c*-in-doxy-comment beg-end-list))
      (apply 'dp-c*-align beg-end-list)
      (return-from dp-c-fill-paragraph))
    (save-excursion
      (save-restriction
        (when region
          (goto-char (car region))
          (narrow-to-region (line-beginning-position) (cdr region))
          (dp-deactivate-mark))
        (cond
         ;; Comment?
         ((dp-in-a-c*-comment 'INTRO-TOO syntax) 
          (if (memq arg '(- 0))
              (with-narrow-to-region (line-beginning-position) (point-max)
                                     (c-fill-paragraph))
            (c-fill-paragraph)))
         ((memq syntax '(member-init-intro))
          (dp-c-fill-statement nil 'rest-of-statement))
         ;; Function definition?
         ((dp-c-in-syntactic-region 
           '(topmost-intro topmost-intro-cont arglist-intro arglist-cont
             func-decl-cont))
          (dp-c-format-func-decl))
         ;; Function call?
         ((memq syntax 
                '(statement statement-block-intro defun-block-intro 
                  statement-case-intro
                  arglist-cont-nonempty substatement stream-op))  
          (dp-c-fill-statement))
         ;; Other.
         (t (ding) (message "dp-c-fill-paragraph, syntax: %s" syntax)
            (call-interactively 'c-fill-paragraph)))))))
(defalias 'cfp 'dp-c-fill-paragraph)

(defun dp-tabdent (&optional indent-width)
  "Tab by specified indent-width, using system tabwidth size tabs.
Replaces all preceeding whitespace up to new tab position with 
spaces and tabs as generated by `indent-to'."
  (interactive "*")
  (setq-ifnil indent-width (if (dp-in-c)
			       c-basic-offset
			     tab-width))
  (let* ((col (current-column))
	 (pt (point))
	 (target-col (* (1+ (/ col indent-width)) indent-width)))
    (skip-chars-backward " \t")
    (delete-region (point) pt)
    (indent-to target-col)))

(defun dp-phys-tab (&optional num)
  "Insert a real, gen-u-ine, bona-fide TAB."
  (interactive "*p")
  (setq-ifnil num 1)
  (dotimes (i num)
    (insert "\t")))

(defun dw (&optional backwards-too-p)
  "Delete all whitespace after point up to next non-white char."
  (interactive "*")
  (if backwards-too-p
      (skip-chars-backward dp-ws))
  (if (looking-at "\\s-+")
      (delete-region (match-beginning 0) (match-end 0))))

(defun dp-one-tab (&optional just-forwards-p)
  "Convert all ws to a single tab."
  (interactive "*P")
  (dw (not just-forwards-p))
  (insert "\t"))
;;  (dp-tabdent))
(defalias 'ot 'dp-one-tab)

(defun dp-c-namify-region (beg end &optional say-dot)
  "Convert region to legitimate C identifier."
  (interactive "*r")
  (if (> beg end)
      (let ((tmp end))
	(setq end beg
	      beg tmp)))
  (goto-char beg)
  (when say-dot
    (while (re-search-forward "[.]" end t)
      (replace-match "_DOT_"))
      (goto-char beg))
  (while (re-search-forward "[^a-zA-Z0-9_\n]" end t)
    (replace-match "_")))

(defun* dp-c-namify-string (string &optional (repl-str "_"))
  (replace-in-string (replace-in-string string "^[0-9]" repl-str)
                     "[^0-9A-Za-z_]" repl-str))

(defstruct dp-parenthesize-region-info
  (first "I'm first")
  (sticky-p nil)
  (index 0)
  region
  pre-len
  suf-len
  paren-list
  (last "I'm last")
  )

(defvar dp-current-parenthesize-region-info (make-dp-parenthesize-region-info)
  "Information so that we can iterate of the various kinds of parens.")

(defvar dp-parenthesize-region-paren-list
  '(("(" . ")")                         ; 0
    ("\"" . "\"")                       ; 1
    ("'" . "'")                         ; 2
    ("{" . "}")                         ; 3
    ("[" . "]")                         ; 4
    ("<" . ">")                         ; 5
    ("<:" . ":>")                       ; 6
    ("*" . "*")                         ; 7
    ("`" . "'")                         ; 8
    ("" . "")                           ; ...last (Undoish)
    )
  "Parenthesizing pairs to try, in order.
The list is buffer local so the order or the contents can be tailored.
@todo: make this an alist so that you can choose the pair without hoping the
indices are unchanged.
@todo: Add a way to list the current mode's list, and show the indices.
@todo: make more mode-local.  get from alist of (mode list) with default")

(defun dp-to-end-of-line-cons (&optional from-beginning-p)
  (cons (if from-beginning-p
            (line-beginning-position)
          (point))
        (line-end-position)))


(defun dp-add-mode-paren-list (major-mode paren-list)
  (dp-set-mode-local-value 'dp-parenthesize-region-paren-list paren-list 
                           major-mode))

;; lisp mode test: "some-text"

;; !<@todo Merge this into  `defstruct dp-parenthesize-region-info'
(dp-deflocal-permanent dp-parenthesize-region-original-text-info nil
  "Original text we parenthesized.")

(defun dp-parenthesize-region-restore-orginal-text (info suffix-len)
  "Put it back."
  (let ((beg (nth 1 info))
        (end (nth 2 info)))
    ;; So next time starts from scratch.
    (setq this-command nil)
    (save-excursion
      (goto-char beg)
      (delete-region beg end)
      (insert (nth 0 info)))))

;; (defun* dp-parenthesize-region-old (index &optional (trim-ws-p t)
;;                                 &key pre suf
;;                                 (region-bounder-func 'rest-or-all-of-line-p)
;;                                 (region-bounder-func-args '())
;;                                 iterating-p
;;                                 parenthesize-region-list)
;;   "Wrap the region in paren like characters. INDEX is 1 based when called.
;; @todo -- add functionality: parenthesize and jump (remain?) at inserted close
;; paren."
;;   (interactive "*P")
;;   ;;(dmessage "lc: %s, tc: %s" last-command this-command)
;;   (let* ((orig-raw-index index)
;;          (iterating-p (or (eq iterating-p t)
;;                           (eq last-command this-command)))    
;;          (shrinking-p (and iterating-p
;;                            (> 0 (prefix-numeric-value orig-raw-index))))
;;          (sticky-p (or (and (not index)
;;                             (dp-parenthesize-region-info-sticky-p
;;                              dp-current-parenthesize-region-info))))
         
;;          (first-go-round-p (not iterating-p))
;;          (paren-list (or parenthesize-region-list
;;                          (and iterating-p 
;;                               (dp-parenthesize-region-info-paren-list
;;                                dp-current-parenthesize-region-info))
;;                          (dp-mode-local-value 
;;                           'dp-parenthesize-region-paren-list 
;;                           major-mode)
;;                          dp-parenthesize-region-paren-list))
;;          (restore-p (eq index 0))
;;          (index (cond
;;                  (shrinking-p (1- (dp-parenthesize-region-info-index 
;;                                    dp-current-parenthesize-region-info)))
;;                  ((eq index '-)
;;                   ;; INDEX doesn't matter since we check for pre and suf
;;                   ;; being set before we use INDEX.  But this must be done
;;                   ;; before INDEX is used numerically.
;;                   (setq trim-ws-p nil)
;;                   1)
;;                  ;; Setting to {} doesn't seem too useful.
;;                  ;;(setq pre "{\n" suf "}\n")
                 
;;                  ;; We need to check for index < 0 down here and set
;;                  ;; sticky-p so that we can initialize INDEX rather than
;;                  ;; grabbing what is currently in the info structure.  But,
;;                  ;; if we have no INDEX set, then we want to use the last
;;                  ;; value of the sticky bit and, if set, the last value of
;;                  ;; INDEX.
;;                  ((and (numberp index) 
;;                        (< index 0))
;;                   (setq sticky-p t)
;;                   (abs index))
;;                  ((or iterating-p
;;                       sticky-p)
;;                   ;; Below, STICKY-P leaves index alone while ITERATING-P
;;                   ;; increments it.  In either case, INDEX is set properly.
;;                   (dp-parenthesize-region-info-index 
;;                    dp-current-parenthesize-region-info))
;;                  ((numberp index) (abs index))
;;                  ((and index (listp index)) (dp-num-C-u index))
;;                  ;; Make it one based so we can use C-0 to modify behavior.
;;                  (t 1)))
;;          ;; Zero base it.
;;          (index (1- index))
;;          (index-offset (if restore-p 1 0))
;;          (parens (nth (% (+ index index-offset) (length paren-list)) paren-list))
;;          (pre (or pre (car parens)))
;;          (suf (or suf (cdr parens)))
;;          (beg-end (if iterating-p 
;;                       (dp-parenthesize-region-info-region 
;;                        dp-current-parenthesize-region-info)
;;                     (dp-region-or... :bounder region-bounder-func
;;                                      :bounder-args region-bounder-func-args)))
;;          (beg (dp-mk-marker (car beg-end)))  ; ??? IS THIS OK ????
;;          (end (dp-mk-marker (cdr beg-end) nil t))
;;          (add-parens-p t))
;;     ;; Do we want to shorten the parenthesized region?
;;     (if shrinking-p
;;         (progn
;;           ;; Reset to original state.
;;           (dp-parenthesize-region-restore-orginal-text
;;            dp-parenthesize-region-original-text-info
;;            (dp-parenthesize-region-info-suf-len 
;;             dp-current-parenthesize-region-info))
;;           ;; Shrink region.
;;           (setq end (dp-mk-marker (+ end 
;;                                      (prefix-numeric-value orig-raw-index))
;;                                   nil t)
;;                 iterating-p nil
;;                 ;; Save text from new, smaller region.
;;                 dp-parenthesize-region-original-text-info
;;                       (list (buffer-substring beg end) beg end)
;;                 this-command last-command))
;;       (if restore-p
;;         (if (not (and dp-parenthesize-region-original-text-info))
;;             (dmessage "Nothing to restore.")
;;           (dp-parenthesize-region-restore-orginal-text
;;            dp-parenthesize-region-original-text-info
;;            (dp-parenthesize-region-info-suf-len 
;;             dp-current-parenthesize-region-info))
;;           ;;(setq dp-parenthesize-region-original-text-info nil)
;;           )
;;         (when first-go-round-p
;;           (setq dp-parenthesize-region-original-text-info
;;                 (list (buffer-substring beg end) beg end))
;;           (when (equal end (line-end-position))
;;             ;; Trim trailing white space at end of line which is most likely
;;             ;; desired.
;;             (undo-boundary)
;;             (save-excursion
;;               (goto-char beg)
;;               (when (and trim-ws-p
;;                          (re-search-forward ".*?\\(!+\\)$" (line-end-position) t))
;;                 (setq end (dp-mk-marker (match-beginning 1) nil t))
;;                 (replace-match "" nil nil nil 1)
;;                 ;;               (setq end (+ 2 (line-end-position)))
                
;;                 ))))))
;;     (when add-parens-p
;;       (save-excursion
;;         (goto-char beg)
;;         (when iterating-p
;;           (delete-char (dp-parenthesize-region-info-pre-len 
;;                         dp-current-parenthesize-region-info)))
;;         (insert pre)
;;         (goto-char end)
;;         (if iterating-p
;;             (delete-char (- 0 (dp-parenthesize-region-info-suf-len
;;                                dp-current-parenthesize-region-info))))
;;         (insert suf)
;;         (when (dp-in-c)
;;           (c-indent-region beg (point))))
;;       (setq dp-current-parenthesize-region-info
;;             (make-dp-parenthesize-region-info
;;              :sticky-p sticky-p
;;              :index (if sticky-p
;;                         (1+ index)
;;                       (+ 2 index))
;;              :region (cons (dp-mk-marker beg) end)
;;              :pre-len (length pre)
;;              :suf-len (length suf)
;;              :paren-list paren-list))))
;;   )

;; test: 
(defun* dp-parenthesize-region (index &optional (trim-ws-p t)  ; <:<::>
                                &key pre suf
                                (region-bounder-func 'rest-or-all-of-line-p)
                                (region-bounder-func-args 
                                 '(:ignore-eol-punctuation-p t))
                                iterating-p sticky-p
                                parenthesize-region-list)
  "Wrap the region in paren like characters. INDEX is 1 based when called with a prefix arg.
@todo -- add functionality: parenthesize and jump (remain?) at inserted close
paren.
@todo -- add the ability to select the pair with my selection code.
@todo -- add a echo area display of all the pairs with some indication of
where we are in the list... like flyspell does."
  (interactive "*P")
  ;;(dmessage "lc: %s, tc: %s" last-command this-command)
  (let* ((orig-raw-index index)
         (iterating-p (or (eq iterating-p t)
                          (eq last-command this-command)))    
         ;; If we're iterating, and not sticky yet, we can stick at the
         ;; current (which would've been considered the previous pair if we
         ;; were iterating), pair by iterating with a C-- prefix arg.  I
         ;; think this should be easier than counting in order to select the
         ;; pair.
         (stuck-p (dp-parenthesize-region-info-sticky-p
                   dp-current-parenthesize-region-info))
         (sticky-p (and (null index)    ; Any prefix unsticks us.
                        stuck-p))
         (stick-last-p (and iterating-p (not stuck-p)
                            ;; Single [(control ?u)] (()
                            (or (C-u-p) (Cu--p))
                            (setq this-command nil stick-p t)
                            t))
         (shrinking-p (and iterating-p
                           (not stick-last-p)
                           (> 0 (prefix-numeric-value orig-raw-index))))
         (first-go-round-p (not iterating-p))
         (paren-list (or parenthesize-region-list
                         (and iterating-p 
                              (dp-parenthesize-region-info-paren-list
                               dp-current-parenthesize-region-info))
                         (dp-mode-local-value 
                          'dp-parenthesize-region-paren-list 
                          major-mode)
                         dp-parenthesize-region-paren-list))
         (restore-p (eq index 0))
         (index (cond
                 (shrinking-p (1- (dp-parenthesize-region-info-index 
                                   dp-current-parenthesize-region-info)))
                 ((and (not iterating-p) (eq index '-))
                  ;; INDEX doesn't matter since we check for pre and suf
                  ;; being set before we use INDEX.  But this must be done
                  ;; before INDEX is used numerically.
                  ;; This is used to reset the INDEX after a sticky one is
                  ;; used.
                  (setq trim-ws-p nil)
                  1)
                 ;; Setting to {} doesn't seem too useful.
                 ;;(setq pre "{\n" suf "}\n")
                 
                 ;; We need to check for index < 0 down here and set
                 ;; sticky-p so that we can initialize INDEX rather than
                 ;; grabbing what is currently in the info structure.  But,
                 ;; if we have no INDEX set, then we want to use the last
                 ;; value of the sticky bit and, if set, the last value of
                 ;; INDEX.
                 ((and (numberp index) 
                       (< index 0))
                  (setq sticky-p t)
                  (abs index))
                 ((or iterating-p
                      stick-last-p
                      sticky-p)
                  ;; Below, where we set up the iteration object,
                  ;; STICKY-P leaves index alone while ITERATING-P
                  ;; increments it.  In either case, INDEX is set properly.
                  ;; STICK-LAST-P pretends that we're already sticky.  But it
                  ;; also implies that we're going to stop iterating after
                  ;; sticking at the previous pair.
                  (dp-parenthesize-region-info-index 
                   dp-current-parenthesize-region-info))
                 ((numberp index) (abs index))
                 ((and index (listp index)) (dp-num-C-u index))
                 ;; Make it one based so we can use C-0 to modify behavior.
                 (t 1)))
         ;; Zero base it and possibly adjust for the previous increment that
         ;; is not needed if we want to stick the parens used on the last
         ;; iteration.
         (index (- index (cond (stick-last-p 2)
                               (t 1))))
         (index-offset (if restore-p 1 0))
         (parens (nth (% (+ index index-offset) (length paren-list)) 
                      paren-list))
         (pre (or pre (car parens)))
         (suf (or suf (cdr parens)))
         (beg-end (if iterating-p 
                      (dp-parenthesize-region-info-region 
                       dp-current-parenthesize-region-info)
                    (dp-region-or... :bounder region-bounder-func
                                     :bounder-args region-bounder-func-args)))
         (beg (dp-mk-marker (car beg-end)))  ; ??? IS THIS OK ????
         (end (dp-mk-marker (cdr beg-end) nil t))
         (add-parens-p (not stick-last-p)))
    
    ;; Do we want to shorten the parenthesized region?
    (if shrinking-p
        (progn
          ;; Reset to original state.
          (dp-parenthesize-region-restore-orginal-text
           dp-parenthesize-region-original-text-info
           (dp-parenthesize-region-info-suf-len 
            dp-current-parenthesize-region-info))
          ;; Shrink region.
          (setq end (dp-mk-marker (+ end 
                                     (prefix-numeric-value orig-raw-index))
                                  nil t)
                iterating-p nil
                ;; Save text from new, smaller region.
                dp-parenthesize-region-original-text-info
                      (list (buffer-substring beg end) beg end)
                this-command last-command))
      (if restore-p
        (if (not (and dp-parenthesize-region-original-text-info))
            (dmessage "Nothing to restore.")
          (dp-parenthesize-region-restore-orginal-text
           dp-parenthesize-region-original-text-info
           (dp-parenthesize-region-info-suf-len 
            dp-current-parenthesize-region-info))
          ;;(setq dp-parenthesize-region-original-text-info nil)
          )
        (when first-go-round-p
          (setq dp-parenthesize-region-original-text-info
                (list (buffer-substring beg end) beg end))
          (when (equal end (line-end-position))
            ;; Trim trailing white space at end of line which is most likely
            ;; desired.
            (undo-boundary)
            (save-excursion
              (goto-char beg)
              (when (and trim-ws-p
                         (re-search-forward ".*?\\(!+\\)$" (line-end-position) t))
                (setq end (dp-mk-marker (match-beginning 1) nil t))
                (replace-match "" nil nil nil 1)
                ;;               (setq end (+ 2 (line-end-position)))
                
                ))))))
    (when add-parens-p
      (save-excursion
        (goto-char beg)
        (when iterating-p
          (delete-char (dp-parenthesize-region-info-pre-len 
                        dp-current-parenthesize-region-info)))
        (insert pre)
        (goto-char end)
        (if iterating-p
            (delete-char (- 0 (dp-parenthesize-region-info-suf-len
                               dp-current-parenthesize-region-info))))
        (insert suf)
        (when (dp-in-c)
          (c-indent-region beg (point)))))
    (setq dp-current-parenthesize-region-info
          (make-dp-parenthesize-region-info
           :sticky-p (or sticky-p stick-last-p)
           ;; A 1 based index is provided by the user, then converted to 0
           ;; based. But for the sake of the iteration case, we convert
           ;; back to 1 based for the next go round.
           :index (if (or sticky-p stick-last-p)
                      (1+ index)      ; Keep index `unchanged.'
                    (+ 2 index))      ; Increment index.
           :region (cons (dp-mk-marker beg) end)
           :pre-len (length pre)
           :suf-len (length suf)
           :paren-list paren-list))
    (when (or stick-last-p sticky-p)
      (message "%s at paren set %s , %s.  Use C-0 to reset."
               (if stick-last-p "Sticking" "Stuck")
               pre suf ))
    (when (and stuck-p (not (or sticky-p stick-last-p)))
      (message "Unsticking from  paren set %s , %s."
               pre suf))))

(put 'dp-parenthesize-region 'self-insert-defer-undo 
     (* 3 (length dp-parenthesize-region-paren-list)))

;; test: ()
(defun* dp-insert-parentheses (&optional index allow-iteration-p
                               ignore-region-p)
  (interactive "*P")
  (if (and (not ignore-region-p)
           (dp-mark-active-p))
      ;;(setq this-command 'dp-parenthesize-region)
      (call-interactively 'dp-parenthesize-region)
    (let ((iterate-p (or (and allow-iteration-p
                              (eq last-command this-command))
                         (setq last-command nil))))
      (when iterate-p
        (forward-char -1))
      (dp-parenthesize-region index
                              t
                              :region-bounder-func 'zero-len-p
                              :iterating-p (or iterate-p 'no)
                              :parenthesize-region-list '(("(" . ")")
                                                          ("[" . "]")))
      (forward-char 1))))
  
(defun* dp-undo-while (predicate)
  (interactive)
  ;; !<@todo this really needs to save off `buffer-undo-list' in case there
  ;; is no where in the list that causes the buffer to be unmodified.  This
  ;; will also cause an infinite loop.
  (loop repeat (length buffer-undo-list)
    while (and (not (eq this-command t))  ; Did the last undo fail?
               (funcall predicate))
    do
    (call-interactively 'undo)
    ;; `undo' leaves `this-command' t when it fails.
    (setq last-command this-command)))

(defun dp-undo-till-unmodified ()
  (interactive)
  (dp-undo-while 'buffer-modified-p))

(defun dp-dot-h-reinclusion-protection (&optional dont-comment-endif-p)
  "Add reinclusion protection sequence to a header file.
The sequence looks like this:
#ifndef xx
#define xx

<header file contents...>

#endif [/* #ifndef xx */]

and is inserted around current file based on buffer's filename.
DONT-COMMENT-ENDIF-P, obtained from the prefix arg when called
interactively,  says to leave the /* xx */ 
off of the closing #endif
If the region is active, then the sequence is placed around the region.
Otherwise, the sequence begins at \(point-min) and ends at \(point-max)."
  (interactive "*P")
  (save-excursion
    (save-restriction
      (if (dp-mark-active-p)
	  (narrow-to-region (point) (mark)))
      (let* ((filename (upcase (file-relative-name (buffer-file-name))))
	     (def-name (concat filename "_INCLUDED"))
	     comment-text
             ifdef-start)
	(goto-char (point-min))
        ;; Skip past any header comments. In particular the mode comment:
        ;; // -*- mode: C++; c-file-style: "intel-c-style" -*-
        (while (and (dp-in-a-c*-comment)
                    (= 0 (forward-line 1)))
          )
        (beginning-of-line)
        (setq ifdef-start (point))
	(insert def-name "\n")
	(insert def-name "\n\n")
	(dp-c-namify-region ifdef-start (point) 'say-dot)
	(goto-char ifdef-start)
	(setq comment-text
	      (if dont-comment-endif-p
		  ""
		(concat " /* #ifndef "
			(buffer-substring (point) (line-end-position))
                        " Reinclusion protection."
			" */")))
	(insert "#ifndef ")
        (end-of-line)
        (insert " /* Reinclusion protection. */")
	(forward-line 1)
	;;(beginning-of-line) ; not needed w/forward-line
	(insert "#define ")
        (end-of-line)
        (insert " /* Reinclusion protection. */")
	(goto-char (point-max))
	(insert "\n#endif" comment-text "\n"))))
  (dmessage "@todo: Delete any existing ifdef lines first."))
(dp-safe-alias 'idef 'dp-dot-h-reinclusion-protection)

(defun dp-insert-file-relative-name (&optional buf)
  (interactive)
  (insert (file-relative-name (buffer-file-name buf))))

(defun dp-find-or-create-sb-guts ()
  "Find or create a scratch buffer."
  (let ((buf (get-buffer-create "*scratch*")))
    (set-buffer buf)
    (unless (eq major-mode 'lisp-interaction-mode)
      (lisp-interaction-mode)
      (font-lock-set-defaults))
    buf))
  
(defun dp-find-or-create-sb (&optional same-buffer-p)
  "Switch to existing or make a new scratch buffer in 
lisp-interaction mode."
  (interactive "P")
  ;; goes to existing one if there, otherwise creates one with the right mode."
  (if same-buffer-p
      (switch-to-buffer (dp-find-or-create-sb-guts))
    (sb2)))
(dp-defaliases 'sbo 'sb 'dp-find-or-create-sb)

(defun dp-find-or-create-sb-same-buffer ()
  (interactive)
  (dp-find-or-create-sb 'same-buffer-p))
(dp-defaliases 'sb. 'sbd 'sb0 'sb1 'dp-find-or-create-sb-same-buffer)

(defun sb2 ()
  "Split the window, do an `sb' on one of them."
  (interactive)
  ;;(switch-to-buffer-other-window (dp-find-or-create-sb-guts))
  (dp-display-buffer-select (dp-find-or-create-sb-guts) nil nil nil t))

(defun pyb ()
  "Create or switch to an IPython buffer."
  (interactive)
  (let ((pybuffer (get-buffer "*Python*")))
    (if pybuffer
        (switch-to-buffer-other-window pybuffer)
      (py-shell))))
        
(defvar dp-hyper-apropos-buffer-name "*Hyper Apropos*")

(defun* hab (&optional (other-window-p t))
  (interactive)
  (when (get-buffer dp-hyper-apropos-buffer-name)
    (funcall
     (if other-window-p
         'switch-to-buffer-other-window'
       'switch-to-buffer) (get-buffer dp-hyper-apropos-buffer-name))))

(defun dp-view-buffer (buf-or-name &optional same-window-p post-hook
                       scroll-with-output-p)
  (interactive)
  (let ((view-win
         (if (not same-window-p)
             (display-buffer buf-or-name)
           (switch-to-buffer buf-or-name)
           (dp-get-buffer-window))))
    (when scroll-with-output-p
      (save-window-excursion
        (select-window view-win)
        (goto-char (point-max)))))
  
  (when post-hook
    ;; Call in context of new buffer.
    ;; Not doing so messed up my (*&@(*&#(*!!! key bindings.
    (with-current-buffer buf-or-name
      (funcall post-hook))))

(defun dp-display-message-buffer (&optional same-window-p tallest-window-p)
  "Display the message buffer, defaulting to another window."
  (interactive "P")
  (dp-view-buffer dp-message-buffer-name 
                  same-window-p 
                  (function
                   (lambda ()
                     (local-set-key [(meta ?-)] 'dp-bury-or-kill-buffer)))
                  'follow-output))

(dp-defaliases 'mb 'mb2 'mb-other 'dp-display-message-buffer)

(defun dp-display-message-buffer-same-window ()
  "Display the message buffer in this window."
  (interactive)
  (dp-display-message-buffer 'same-window))

(dp-defaliases 'mbd 'mb0 'mb. 'mb1 'dp-display-message-buffer-same-window)

(defun dp-backtrace-buffer (&optional same-window-p)
  "Go to *Backtrace* buffer."
  (interactive)
  (dp-view-buffer "*Backtrace*" same-window-p))

(dp-defaliases 'bt 'bt2 'bt-other 'dp-backtrace-buffer)

(defsubst dp-backtrace-buffer-same-window ()
  "Go to *Backtrace* buffer in this window."
  (interactive)
  (bt 'same-window-p))
(dp-defaliases 'bt0 'bt. 'bt1 'dp-backtrace-buffer-same-window)

(defun mbm ()
  "Mark beginning of set of output."
  (interactive)
  (mb)
  (dp-end-of-buffer)
  (dp-timestamp)
  (dp-set-or-goto-bm "mbbm" :reset t))

(defvar dp-ephemeral-dir (expand-file-name "~/ephemeral.d"))
(defvar dp-lisp-dir (expand-file-name "~/lisp"))
(defvar dp-current-elisp-devel-filename nil
  "Last elisp devel filename visited.")

(defvar dp-current-elisp-devel-dirname nil
  "Last elisp devel directory name visited.")

(defconst dp-default-elisp-devel-file "elisp-devel.el"
  "*File in which to do elisp development and noodling.")

(defconst dp-default-elisp-devel-dir (expand-file-name "devel" dp-lisp-dir)
    "*Dir in which the file resides in which to do elisp development and noodling.")

(defvar dp-elisp-devel-files-history (list dp-default-elisp-devel-file)
  "A RisR")

(defun* dp-elisp-devel-filename (&key dev-name dev-dir (use-current-p t)
                                 &allow-other-keys)
  (when dev-name
    (setq dp-current-elisp-devel-filename dev-name)
    (when dev-dir
      (setq dp-current-elisp-devel-dirname dev-dir)))
  ;; (paths-construct-path COMPONENTS &optional EXPAND-DIRECTORY)
  (paths-construct-path (list(or dp-current-elisp-devel-dirname 
                                 dp-default-elisp-devel-dir)
                             (or dp-current-elisp-devel-filename 
                                 dp-default-elisp-devel-file))))

(defvar dp-elisp-devel-candidate-file-names
  '("./dp-elisp-devel.el" "./devel/dp-elisp-devel.el" "./dev/dp-elisp-devel.el"
    "./elisp-devel.el" "./devel/elisp-devel.el" "./dev/elisp-devel.el"))

(defun dp-candidate-files (candidates &optional dir)
  (delq nil (mapcar (dp-flambda (file)
                      (and (file-exists-p (expand-file-name file dir))
                           (expand-file-name file dir)))
                      candidates)))

(defun dp-elisp-devel-candidate-files (&optional dir candidates)
  (interactive)
  (or (dp-candidate-files (or candidates
                              dp-elisp-devel-candidate-file-names)
                          dir)
      (list (expand-file-name dp-default-elisp-devel-file dir))))

(defun* dp-get-ld-file-interactive (&rest rest &key dev-name dev-dir 
                                    (use-current-p t) prompt-p
                                    &allow-other-keys)
    (let ((deffile (apply 'dp-elisp-devel-filename rest)))
      (list
       (if (and dp-current-elisp-devel-filename
                dp-current-elisp-devel-dirname
                (not prompt-p))
           deffile
         ;; (read-file-name PROMPT &optional DIR DEFAULT MUST-MATCH
         ;; INITIAL-CONTENTS HISTORY)
         (setq deffile 
               (expand-file-name 
                (substitute-in-file-name 
                 (read-file-name (format "Dev file (%s): " 
                                         (or dp-current-elisp-devel-filename
                                             dp-default-elisp-devel-file))
                                 (or dp-current-elisp-devel-dirname 
                                     dp-default-elisp-devel-dir)
                                 deffile nil nil
                                 'dp-elisp-devel-files-history))
                dp-default-elisp-devel-dir)
               
               ;; if dirname is nil, then we'll continue to use the default
               ;; devel dir.  If the user wants to set a current devel dir,
               ;; then they must specify one.  If relative, then we
               ;; canonicalize with the current dir.  If the user wants
               ;; another location, then they must give an absolute path
               ;; name.
               dp-current-elisp-devel-dirname (file-name-directory deffile)
               dp-current-elisp-devel-filename (file-name-nondirectory deffile))
         deffile)
       current-prefix-arg)))

(defun* dp-lisp-devel (file-name &rest rest &key
                       (one-window-p nil one-window-p-passed-p) 
                       prompt-p &allow-other-keys)
  "Open an elisp devel buffer in lisp interaction mode.
This buffer is attached to a file so that we don't inadvertently exit.
Developing in `*scratch*' can result in lost work."
  (interactive (dp-get-ld-file-interactive))
  (if (Cu--p)
      (ielm)
    (if (and (not (interactive-p))
             (not file-name))
        (let ((fname (apply 'dp-get-ld-file-interactive rest)))
          (setq one-window-p (if one-window-p-passed-p
                                 one-window-p
                               (cadr file-name))
                file-name (car fname))))
    (if (not file-name)
        (error "no file-name")
      (if one-window-p
          (find-file file-name)
        (find-file-other-window file-name))
      (unless (eq major-mode 'lisp-interaction-mode)
        (lisp-interaction-mode))
      (font-lock-mode)
      (font-lock-set-defaults))))
(defalias 'ld 'dp-lisp-devel)

(defun* ld1 (&key file-name (prompt-p nil prompt-p-p))
  (interactive)
  (ld file-name :one-window-p t 
      :prompt-p (if prompt-p-p prompt-p current-prefix-arg)))
(dp-defaliases 'ldd 'ld. 'ld0 'ld1)

(defun* ld2 (&key file-name (prompt-p nil prompt-p-p))
  (interactive)
  (ld file-name :one-window-p nil 
      :prompt-p (if prompt-p-p prompt-p current-prefix-arg)))
  
(defun* ldp (&key file-name (one-window-p nil one-window-p-p))
  (interactive)
  (ld file-name 
      :one-window-p (if one-window-p-p one-window-p current-prefix-arg)
      :prompt-p t))
(defalias 'ld-new 'ldp)

(defun dp-local-lisp-devel ()
  (interactive)
  (dp-lisp-devel (car (dp-elisp-devel-candidate-files))))
(defalias 'ldl 'dp-local-lisp-devel)

(defun ldl0 ()
  (interactive)
  (dp-lisp-devel (car (dp-elisp-devel-candidate-files))
                 :one-window-p t))
(defalias 'ldl1 'ldl0)
(defalias 'ldl. 'ldl0)



(defun dp-metamail (&optional force-to-file-p)
  "Metamail a buffer, forcing output to a fixed buffer.
Optional prefix arg instructs us to force the output into a file."
  (interactive "P")
  (require 'metamail)
  (let ((cbuf (current-buffer))
	(metamail-switches metamail-switches) ; make a local copy we can modify
	mbuf)
    ; have we been requested to simply write the decoded data?
    (if force-to-file-p
	  (setq metamail-switches (append metamail-switches '("-w"))))
    ;; make sure buffer exists
    (switch-to-buffer dp-metamail-buffer)
    (setq mbuf (current-buffer))
    (switch-to-buffer cbuf)
    (save-restriction
      (if (dp-mark-active-p)
	  (narrow-to-region (mark) (point)))
      (metamail-buffer nil mbuf nil))
    (switch-to-buffer dp-metamail-buffer)
    (goto-char (point-min))))

(defun dp-vc-head (kwords)
  (interactive "*")
  (beginning-of-line)
  (let* ((c-start (or comment-start "# "))
	(c-end (or comment-end ""))
	(block-it (not (string-equal c-end "")))
	line-prefix)

    (if (not block-it)
	(setq line-prefix c-start)
      (if (dp-in-a-c*-comment)
	  (setq block-it nil)		;don't close the comment block
	(insert c-start "\n"))
      (setq line-prefix " * "))
 
    (mapcar (function (lambda (kword)
			(insert line-prefix "$" kword "$\n")))
	    kwords)

    (if block-it
	(insert comment-end "\n")
      (end-of-line))))

(defun rcs-head ()
  (interactive "*")
  (dp-vc-head dp-rcs-headers))

;;
(defun scan-re-list (target match-list)
  "Search thru match-list, a list of lists.
Each sublist is a list of strings.  The car is the return value, and
the cdr is a list of regexps.  The target is tried with each regexp
and if there is a match, the car of the sublist is returned."
  (let* ((lst match-list)
	 sub-list re-lst re-el)
    (catch 'found
      (while lst
	(setq sub-list (car lst))
	(setq re-lst (cdr sub-list))
	(while re-lst
	  (setq re-el (car re-lst))
	  (setq re-lst (cdr re-lst))
	  ;;(message (format "re-el>%s<, targ>%s<" re-el target))
	  (when (posix-string-match re-el target)
	    ;;(message (format "match>%s<" (car sub-list)))
	    (throw 'found (car sub-list))))
	(setq lst (cdr lst)))
      nil)))

(defun dp-in-exe-path-p (prog &optional path)
  "Return t if PROG is an executable file in path.  
Use exec-path if PATH is nil."
  (interactive)
  (let ((exec-path (or path exec-path)))
    (executable-find prog)))

(defun dp-find-first-exe (list-of-prog-names)
  "Search, in order, for the first executable program in LIST-OF-PROG-NAMES."
  (catch 'up
    (mapc (function (lambda (prog-name)
                      (if (dp-in-exe-path-p prog-name)
                          (throw 'up prog-name))))
          list-of-prog-names)
    nil))

(defun dp-init-spellin ()
  "Set up spellig thnigs."
  (when (and (dp-val-if-boundp dp-use-spell-p)
             (dp-val-if-boundp dp-spell-programs))
    ;; Look for the first existing spelling program.
    (dmessage "Searching for spelling program.")
    (let ((spellr (dp-find-first-exe dp-spell-programs)))
      (if spellr
          (setq ispell-program-name spellr)
        ;; We couldn't find one in our preferred list, so try the default
        ;; specified in the ispell package.
        (dmessage "checking default ispell program: %s" ispell-program-name)
        (unless (executable-find ispell-program-name)
          (dmessage "No spelling program found. flyspell is disabled.")
          (setq ispell-program-name nil)
          (setq dp-use-flyspell-p nil)) ;no spellr --> canna flyspel.
        ))))

(defun dp-find-pydb-file (file &optional other-window-p dir)
  (setq file (expand-file-name 
	      (concat (or dir
			  (getenv "pydb") 
			  (concat (or (getenv "HOME") "~") 
				  "/etc/pydb"))
		      "/"
		      file)))
  ;;(message "file>%s<" file)
  (funcall (if other-window-p
               'find-file-other-window
             'find-file)
           file))

(defun notes (&optional other-window-p note-file)
  (interactive "P")
  (or note-file
       (setq note-file (concat 
			(or (getenv "HOME") "/home/davep") 
			"/etc/pdb/notes.pdb")))
  (funcall (if other-window-p
               'find-file-other-window
             'find-file)
           note-file)
  (goto-char (point-max)))

(defun work (&optional other-window-p note-file)
  (interactive)
  (or note-file
       (setq note-file (concat 
			(or (getenv "HOME") "/home/davep") 
			"/etc/pdb/work.pdb")))
  (funcall (if other-window-p
               'find-file-other-window
             'find-file)
           note-file)
  (goto-char (point-max)))

(defun dp-visit-phone-book (&optional other-window-p note-file)
  "Open the phonebook."
  (interactive "P")
  (dp-find-pydb-file (or note-file "phonebook.py") other-window-p))
(defalias 'pb 'dp-visit-phone-book)

(defun hi (&optional other-window-p note-file)
  "Open the host-info database."
  (interactive "P")
  (dp-find-pydb-file (or note-file "host_info.py") other-window-p))

(defsubst hi2 (&optional note-file)
  (interactive)
  (hi t note-file))

(defun todo (&optional other-window-p note-file)
  "Open the (obsolete, use the journal instead) todo file."
  (interactive "P")
  (dp-find-pydb-file (or note-file "todo_db.py") other-window-p)
  (goto-char (point-max)))

(defun dp-insert-fc (fc-file)
  "Read a function comment header block after point.
XXX: use tempo for this?"
  (interactive "*")
  (beginning-of-line)
  (insert-file fc-file)
  ;; goto cursor position if specified...
  (when (re-search-forward "<cursor>" nil t)
    (replace-match "" nil nil)
    (message "done with %s" fc-file )))

;;
;; FE: Make these detect whether we are in a class def or not and insert 
;; proper header
;; in c++ && syntax is inclass --> cfc else fc
;;
(defun fc ()
  "Read the function definition comment header block after point."
  (interactive "*")
  (if (and (dp-in-c++)
	   (dp-in-c++-class))
      (cfc)
    (dp-insert-fc dp-function-comment-file)))

(defun cfc ()
  "Read the class function definition comment header block after point."
  (interactive "*")
  ;; ??? mark region and indent it???
  (dp-insert-fc dp-class-function-comment-file))

(defun fh ()
  "Read the file comment/copyright, etc header block after point."
  (interactive "*")
  (insert-file digital-header-file)
  ;; goto cursor position if specified...
  (when (re-search-forward "<cursor>" nil t)
    (replace-match "" nil nil)
    (message "done")))

(defun dp-indent-region-line-by-line (beg end &optional indentor)
  "Indent the region line-by-line.
I've seen some mode-specific indentors get confuzed.
Indents with INDENTOR if non-nil, else `indent-according-to-mode'.
Leaves region active."
  (interactive "r")
  (let ((ordered (dp-order-cons (cons beg end))))
    (setq beg (dp-mk-marker (car ordered))
          end (dp-mk-marker (cdr ordered))))
  ;;;(dp-set-zmacs-region-stays)
  (save-excursion
    (goto-char beg)
    (unless (bolp)
      (error "region does not start at left margin."))
    (goto-char end)
;     (if (/= end (line-beginning-position))
;         (error "region does not end at left margin."))
    (goto-char beg)
    (while (< (point) end)
      (funcall (or indentor 'indent-according-to-mode))
      (forward-line 1)
      (goto-char (line-beginning-position)))))
(defvar dp-c-stupid-indent-p nil
  "I used to like the associated indentation style, but now it bugs me.")

(defun dp-c-indent-command ()
  "Indent region if active, otherwise indent if in indentation space, otherwise tabdent."
  (interactive "*")
  (if (dp-mark-active-p)
      (if (and-boundp 'dp-c-indent-region-line-by-line t)
          (dp-indent-region-line-by-line (mark) (point) 'c-indent-line)
        (let ((ordered (dp-region-boundaries-ordered)))
          (setq beg (dp-mk-marker (car ordered))
                end (dp-mk-marker (cdr ordered)))
          (c-indent-region beg end)))
    (if (not dp-c-stupid-indent-p)
        (c-indent-line)
      (if (and dp-c-stupid-indent-p
               (not c-tab-always-indent))
          ;; try to make the indenter smarter.  I like using TAB to space out
          ;; vars from types, e.g. int  x;
          ;; but it's a pain to indent a line properly.
          ;; this tried to do an indent if on non-space and tab over if 
          ;; over a space.  But there are times when this is wrong, so I
          ;; punt for now.
          (if (or (not (dp-isa-type-line-p))
                  (dp-in-indentation-p))
              (c-indent-line)             ;simple indentation
            ;; not so simple case...
            ;; lets try:
            ;; If over non-whitespace:
            ;;   going to beginning of current word and then indenting.
            (if abbrev-mode
                (expand-abbrev))
            (if (and (not (eolp))
                     (not (looking-at "[ 	]"))
                     (save-excursion 
                       (backward-char) 
                       (not (looking-at "[ 	]"))))
                (backward-word)
              (delete-region (point) 
                             (progn (skip-chars-forward " \t") (point))))
            (dp-tabdent c-basic-offset))))))


(defun compile-succeeded-p (&optional status-string)
  "Must be in the correct compile buffer for this to work if STATUS-STRING is nil."
  (string= (or status-string mode-line-process) ":exit OK"))

(defun fcd ()
  "Mark a function header as a documentation header."
  (interactive "*")
  (save-excursion
    (if (not (dp-in-a-c*-comment))
	(message "not in a c comment")
      (if (re-search-backward "^/\\*\\(.*\\)" nil t)
	  (if (and (match-beginning 1)
		   (posix-string-match ":fcd:" (match-string 1)))
	      (message "already an fcd")
	    (end-of-line)
	    (insert ":fcd:"))
	(message "canna find comment start.")))))

(defun* dp-insert-for-comment+ (msg
                                prefix
                                &key
                                (clean-up-p nil)
                                (sep-char "")
                                (remain-@-end-point-p t)
                                (remove-preceding-ws-p nil)
                                (doxy-prefix ""))
  "Indent for comment, \\[indent-for-comment], and append a PREFIX and MSG.
Add the strings immediately after the mode's default comment start.
Defaults are:
MSG: a traditional \"XXX\" (TO BE DONE or LOOKED AT) comment.
PREFIX: Doxygen comment indicator \"!@\"."
  (interactive "*sComment text: \nsPrefix: \nsSeparator: ")
  (let ((msg (concat doxy-prefix prefix sep-char msg))
        end-point)
    (if (or (dp-in-a-string)
            (dp-in-a-c-/**/-comment))
        (progn 
          (when (dp-looking-back-at dp-ws-regexp+ 
                                    (line-beginning-position))
            (replace-match ""))
          ;; @todo XXX look into this. Seems like  " " vs "" is bad.
          (insert msg ""))
      (save-excursion
        ;; Use the function bound to the key to make this DTRT in each mode.
        ;; (as long as M-; is a universal binding)
        (let ((comment-start (or comment-start ""))
              (comment-end (or comment-end "")))
          ;; Don't clean up if there's no comment-start.  I don't think there
          ;; will ever be a comment-end without a comment-start.
          ;;(setq clean-up-p (not (string= comment-start "")))
          (dp-call-function-on-key [(meta \;)])
          (when (and remove-preceding-ws-p
                     (dp-looking-back-at dp-ws-regexp+ 
                                         (line-beginning-position))
                     (replace-match "")))
          ;; Not always true, but almost always as far as we're concerned.
          (skip-chars-forward "!"))
        ;;(indent-for-comment)
        (when clean-up-p
          (just-one-space))
        (unless (search-forward msg (line-end-position) t)
;;          (skip-chars-forward dp-ws)
          (insert msg))
        ;; "!<@todo XXX" XXX comes after so we fit Doxygen standard format.
        (and clean-up-p
             (just-one-space))          ; !<@todo XXX 
        ;; Save our resulting end point.
        (if (not remain-@-end-point-p)
            (dp-push-go-back "dp-insert-for-comment+"))
        (setq end-point (dp-mk-marker)))
      ;; we are now where we began.
      ;; Should we stay there or go to the end of our changes?
      ;; In other words, go to the beginning of the original text.
      (when remain-@-end-point-p
        ;; we're where this all started
        ;; Go back to where we added our junk.
        (goto-char end-point)))))

;; e.g.s follow...
;; first
;; 2.a: preserve-end-point-p t
;; !<@todo XXX do we stay here?-!- Yes.
;; !<@todo XXX -!-do we-stay-here?-!- No. We stat the first -!-

(defun ehand ()
  "Insert a message about error handling being needed."
  (interactive)
  (xxx)
  (insert "Error handling needed."))

(defun* dp-interactive-insert-for-comment+ (string)
  "Insert a comment meant to draw attention."
  (interactive "sinsert: ")
  (dp-insert-for-comment+ string))

(defun* wtf (&optional (msg "WTF is going on!!??"))
  (interactive)
  (dp-insert-for-comment+ msg))

(defun* ick (&optional (msg "ick! Fix this ASAP!!"))
  (interactive)
  (dp-insert-for-comment+ msg))

;; !<@todo XXX!<@todo XXX!<@todoXXX dslkdjlskjdlskjdlsjd
;;    !<@todo XXX ubbakdflkdfj  ldkjflkdf  ldkjflkj 
;; !<@todo XXX 
(defun dp-comment-experimental-code (&optional prompt-for-message-p)
  (interactive "P")
  (dp-insert-for-comment+ "dp:experimental: "))

(defalias 'exp 'dp-comment-experimental-code)

(defun dp-c-add-data-comment ()
  (interactive "*")
  (dp-insert-for-comment+ "<:data:>"))
(defalias 'data 'dp-c-add-data-comment)

(defun dp-add-for-now-comment ()
  (interactive "*")
  (dp-insert-for-comment+ "Just for now. Remove ASA fixed."))

(defun dp-c-electric-brace (reindent-p)
  "Insert a brace \"intelligently.\"  
By this I mean if I put a brace in the ``proper'' place (on a line by
itself, under the keyword) move to K&R's incorrect place (after the
control construct)"
  (interactive "*P")
  (if (c-fast-in-literal)               ;(dp-in-a-string)
      (insert "{")
    (let ((syntax (dp-c-get-syntactic-region))
          (extra "")
          here
          mbeg
          mend)
      ;;
      ;; basically, let the c-electric-brace command run and then
      ;; replace the { and all preceding ws (incl newlines) 
      ;; with a single { and then do a newline and indent.
      (unless (and reindent-p
                   (not (dp-looking-back-at "\s-+" (line-beginning-position))))
        (insert " "))
      (c-electric-brace reindent-p)
      (setq here (point))
      ;;(message (format "eb syntax: %s" syntax)
      ;;(dmessage "(= last-command-char ?\{): %s\n" (= last-command-char ?\{))
      (if (and (memq 'knr-open-brace c-cleanup-list)
               (or t c-auto-newline)    ;@todo XXX look into this!
               (= last-command-char ?\{)
               (not (c-in-literal))
               (or (and (eq syntax 'substatement)
                        (re-search-backward "\n[ \t]*{\n?[ \t]*" nil t))
                   (and (memq syntax '(statement block-close defun-block-intro
                                       else-clause statement-case-intro
                                       statement-block-intro))
                        (re-search-backward ")\\s-*{\\s-*\n?\\s-*" nil t)
                        (setq extra ")")))
               (setq mbeg (match-beginning 0)
                     mend (match-end 0))
               ;; (message "here: %d, mend: %d" here mend)
               (= mend here))
          (progn
            (delete-region mbeg mend)
            (backward-char 1)
            (dp-c-end-of-line)
            (insert extra " {")
            (dp-c-fix-comment)
            (end-of-line)
            (dp-c-newline-and-indent))
        (goto-char here)))))

(defun dp-c-close-brace ()
  "Add a closing brace on the NEXT line if point is in the indentation zone and the line is not blank/empty."
  (interactive)
  (let ((pt (point)))
    (when (save-excursion
            ;; before text and not an empty line.
            (back-to-indentation)
            (and (<= pt (point))
                 (not (looking-at "\\s-*$"))))
      (dp-open-newline)))
  (setq last-command-char ?\})
  (call-interactively 'c-electric-brace))
  
(defvar dp-debugging-code-tag "@todo:debug:REMOVE"
  "Intro to debug code identifying comment.")

(defun dp-find-debugging-code-tag ()
  "Find the next line with debug code."
  (interactive)
  (search-forward dp-debugging-code-tag nil))

(defun dp-encomment-string (s &optional timestamp-p)
  "Put string in a mode specific comment."
  (interactive)
  (format "%s %s%s %s"
          (or comment-start "NO-COMMENT-SYNTAX")
          s
          (if timestamp-p
              (format " %s" (dp-timestamp-string))
            "")
          (or comment-end "")))

(defun dp-insert-debugging-code-tag (&optional no-squiggle pmsg smsg 
                                     no-timestamp-p)
  "Add clearly identified debug code.
Inserts an opening line (open { and comment) a closing line.  If the
region is inactive, the cursor is placed between the opening and
closing lines.  If the region is active, then it is placed inside the
opening and closing lines and is indented correctly.  The cursor is
placed after the last line in the region."
  (interactive "*P")
  (let* ((ts-p (not no-timestamp-p))
         (beg-mark (make-marker)) (end-mark (make-marker))
         (pmsg (dp-encomment-string (or pmsg
                                        dp-debugging-code-tag)
                                    ts-p))
         (smsg (if smsg
                   (dp-encomment-string smsg ts-p)
                 pmsg))
         (squig-open "")
         (squig-close ""))
    (when (and (not no-squiggle)
	       (dp-in-c))
      (setq squig-open  "{ "
	    squig-close "} "))
  
    (if (dp-mark-active-p)
	(progn
	  (if (> (point) (mark))
	      (exchange-point-and-mark))
	  (set-marker end-mark (mark))
	  (goto-char (point)))
      (set-marker end-mark (+ 1 (point))))

    (set-marker beg-mark (point))
    (insert squig-open pmsg)
    (newline)
    (goto-char (marker-position end-mark))
    (insert squig-close smsg)
    (newline)
    (c-indent-region (marker-position beg-mark) (point))
    (forward-line -2)
    ;;(beginning-of-line) ; not needed w/forward-line
    (c-indent-line)
;     (save-excursion
;       (goto-char beg-mark)
;       (dp-c-indent-for-comment)
;       (goto-char end-mark)
;       (dp-c-indent-for-comment))
    (set-marker beg-mark nil)
    (set-marker end-mark nil)))
(defalias 'db 'dp-insert-debugging-code-tag)

(defun dp-current-month (&optional date)
  (setq-ifnil date (current-time))
  (let* ((dlist (decode-time date))
	 (month (nth 4 dlist)))
    month))

(defun dp-current-year (&optional date)
  (setq-ifnil date (current-time))
  (let* ((dlist (decode-time date))
	 (year  (nth 5 dlist)))
    year))

(defun dp-date-to-month-num (&optional date)
  "Convert a date to a month number since the year 0000."
  (setq-ifnil date (current-time))
  (let* ((dlist (decode-time date))
	 (month (nth 4 dlist))
	 (year  (nth 5 dlist)))
    (+ month -1 (* year 12))))
  
(defun* dp-make-dated-note-file-name (name-base &key extension year-first-p 
                                      amon ayear note-base-dir)
  "Make a date note file name from the passed in pieces.
NAME-BASE is the base of the newly created name.
EXTENSION is the extension (with `.' if desired) defaults to `.text'.
YEAR-FIRST-P says to put the year before the month if non-nil.
AMON is the month to use if non-nil.  Otherwise the current month is used.
AYEAR is like amon, except for the year."
  (interactive)
  (setq-ifnil note-base-dir dp-note-base-dir)
  (let* ((dlist (decode-time (current-time)))
	 (month (or amon (nth 4 dlist)))
	 (year  (or ayear (nth 5 dlist))))
    (if year-first-p
	(format "%s/%s-%s-%02d%s" note-base-dir name-base year
		month (or extension ".text"))
      (format "%s/%s-%02d-%s%s" note-base-dir name-base month
	      year (or extension ".text")))))

(defun dp-insert-timestamp (&rest args)
  "Insert a timestamp formatted thus: 2009-09-27T18:28:32
ARGS are passed thru to `dp-timestamp-string'."
  (interactive)
  (insert (apply 'dp-timestamp-string args)))
(defalias 'dits 'dp-insert-timestamp)

(defun dp-insert-for-comment-as-of ()
  (interactive)
  "Add something along the lines of 'as of: <timestamp>"
  (dp-insert-for-comment+ (concat "as of: " (dp-timestamp-string)) ""))
(dp-defaliases 'dpao 'dpasof 'dp-as/of 'as/of 'asof 
               'dp-insert-for-comment-as-of)

(defun dp-insert-for-comment-at-this-time ()
  (interactive)
  "Add something along the lines of 'at this time: <timestamp>"
  (dp-insert-for-comment+ (concat "at this time: " (dp-timestamp-string))
                          "" ""))
(dp-defaliases 'dp-at-this-time 'dp-att 'att 'dp-insert-for-comment-at-this-time)

(defvar dp-timestamp-len
  (length (dp-timestamp-string)))

(defun dp-datestamp-string (&optional time)
  "Return a consistently formatted datestamp string."
  (interactive)
  (format-time-string "%A %B %d %Y" time))

(defsubst dp-maybe-str-to-int (val)
  "Given a number or a string, return the value as an int"
  (cond
   ((stringp val) (string-to-int val))
   ((integerp val) val)
   (t 0)))

(defvar dp-month-names ["Jan" "Feb" "Mar" "Apr" "May" "Jun"
			"Jul" "Aug" "Sep" "Oct" "Nov" "Dec"])

(defun dp-month-num-to-name (mon-num)
  (aref dp-month-names (- (dp-maybe-str-to-int mon-num) 1)))

(defvar dp-day-names ["Sun" "Mon" "Tue" "Wed" "Thu" "Fri" "Sat"])
(defun dp-day-num-to-name (day-num)
  (aref dp-day-names (dp-maybe-str-to-int day-num)))

(autoload 'calendar-day-of-week "calendar" "Compute day of week.")
(defun dp-parse-timestamp (timestamp)
  "Parse timestamp, return (day-of-week month day-num-in-month year-num time)."

  (let* ((date-pieces (split-string timestamp "-"))
	 (time-pieces (split-string (nth 2 date-pieces) "T")))
    ;; return list(day-of-week month day-num-in-month year-num time
    (list (calendar-day-of-week (list (string-to-int (nth 1 date-pieces))
				      (string-to-int (nth 0 time-pieces))
				      (string-to-int (nth 0 date-pieces))))
	  (string-to-int (nth 1 date-pieces)) ;month
	  (string-to-int (nth 0 time-pieces)) ;day
	  (string-to-int (nth 0 date-pieces)) ;year
	  (nth 1 time-pieces))))	;time

(defun dp-timestamp-to-datestr (timestamp)
  "Convert a kind of unreadable timestamp to a more readable format.
E.g.: 2002-02-26T00:56:42 --> Feb 26, 2002 00:56:42"
  (let* ((pieces (dp-parse-timestamp timestamp)))
    (format "%s %s %s, %s %s" 
	    (dp-day-num-to-name (nth 0 pieces))	;day-of-week
	    (dp-month-num-to-name (nth 1 pieces)) ;month
	    (nth 2 pieces)		;day
	    (nth 3 pieces)		;year
	    (nth 4 pieces))))		;time
	    
(defconst dp-stamp-leader "========================\n"
  "Date and time stamp leader, a const for uniformity")

(defconst dp-stamp-leader2 "======================== "
  "Date and time stamp leader, a const for uniformity")

(defconst dp-stamp-leader-regexp 
  (format "\\(?:%s\\|%s\\)" dp-stamp-leader dp-stamp-leader2))

(defvar dp-stamp-leader-len
  (length dp-stamp-leader))

(defconst dp-stamp-trailer "\n--"
  "Date and time stamp trailer, a const for uniformity")

(defun dp-mk-stamp (stamp &optional pre suf extra v2-leader-p)
  "Construct a highly parameterized stamp and insert @ point."
  (interactive "*sstamp: \nspre: \nssuf: \nsextra: \nSv2-leader: ")
  (if (not extra)
      (setq extra "")
    (setq extra (concat "\n" extra)))
  (concat (or pre (if v2-leader-p dp-stamp-leader2 dp-stamp-leader))
	  stamp extra 
	  (or suf dp-stamp-trailer) "\n")) ; newline is part of stamp

(defun dp-insert-stamp (stamp &optional pre suf extra v2-leader-p)
  "Put a stamp in file at point."
  (interactive "*sstamp: \nspre: \nssuf: \nsextra: \nSv2-leader: ")
  (insert (dp-mk-stamp stamp pre suf extra v2-leader-p)))

(defun dp-mk-timestamp (&optional pre suf topic v2-leader-p)
  "Make a `dp-journal'-like timestamp, eg:
========================
2009-09-27T18:22:20
--
"
  (dp-mk-stamp (dp-timestamp-string) pre suf topic v2-leader-p))

(defun dp-timestamp (&optional pre suf topic v2-leader-p)
  (interactive "*")
  (insert (dp-mk-timestamp pre suf topic v2-leader-p)))
(defalias 'dp-ins-ts 'dp-timestamp)
(defalias 'ts 'dp-timestamp)		;<t>ime<s>tamp

(defun dp-mk-datestamp (&optional pre suf)
  "Make a nice, standard date stamp."
  (dp-mk-stamp (dp-datestamp-string) pre suf))
  
(defun dp-tf (&optional pre suf force-p)
  "Put a datestamp in a file iff it is not already there unless FORCE-P.
FORCE-P forces a new datestamp, regardless."
  (interactive "*")
  (goto-char (point-min))
  (let* ((date-stamp (dp-mk-datestamp pre suf))
	 (found (re-search-forward date-stamp nil t)))
    (goto-char (point-max))
    (when (or current-prefix-arg
              force-p
              (not found))
      (insert (concat "\n" date-stamp "\n"))
      (backward-char))))

(defalias 'ds 'dp-tf)			;<d>ate<s>tamp

(defun dnf (&optional note-file-arg extension skip-tf-p year-first other-win)
  "Edit a dated note file, derived from the current date.
Create a note filename based on the current date in the default notes
dir `dp-note-base-dir'.  Call `dp-tf' to possibly add a datestamp if
SKIP-TF is nil and today's stamp is not already in the file."
  (interactive)
  (let ((note-file  (if (null note-file-arg)
			(read-from-minibuffer "note file base: ")
		      note-file-arg)))
    (setq note-file (dp-make-dated-note-file-name 
                     note-file :extension extension :year-first-p t))
    (if other-win
	(find-file-other-window note-file)
      (find-file note-file))
    (unless skip-tf-p
      (dp-tf))))
    
(defun staff ()
  (interactive)
  (dnf "staff"))

(defun daily ()
  (interactive)
  (dnf "daily"))
(defalias 'dn 'daily)

; the journal code now depends on journals being named daily-yyyy-mm.jxt
;(defun djf ()
;  (interactive)
;  (dnf nil ".jxt" nil 'year-first))

; use journal instead
;(defun dp-tstreams-notes ()
;  (interactive)
;  (interactive)
;  (dnf "tstreams"))
;(defalias 'tsn 'dp-tstreams-notes)

(defvar dp-nmz-query-history '()
  "A rose is a rose.")

(defun* dp-prompt-with-symbol-near-point-as-default (prompt 
                                                     &key hist-sym
                                                     ;; symbol-type as per
                                                     ;; `interactive'
                                                     (symbol-type 's)
                                                     (require-match-p t)
                                                     (reader-args nil)
                                                     (default-default-p t)
                                                     (initial-contents-p nil))
  "\(name-to-doc 'dp-prompt-with-symbol-near-point-as-default\)
==> prompt with symbol near point as default.
INITIAL-CONTENTS-P: 
nil: no initial contents.
t: default is initial contents.
other: other is value of initial contents."
  (let* ((default (or (and (consp symbol-type)
                           (cdr symbol-type))
                      (dp-get--as-string--region-or...)))
         (symbol-type (if (consp symbol-type)
                          (car symbol-type)
                        symbol-type))
          (prompt (if default-default-p
                      (concat prompt " " "(default: %s): ")
                    prompt))
          (prompt (if (string-match "%s" prompt)
                      (format prompt default)
                    prompt)))
    (cond
     ((eq 'f symbol-type)
      ;; We want a file-name
      (apply 'read-file-name prompt (if reader-args
                                        reader-args
                                      (list nil nil t))))
     ((eq 'a symbol-type) (read-function prompt))
     ((eq 'S symbol-type)
      (let (tem (prev-tem default) unbound-p)
        ;; This *always* sees the variable via `intern-soft' even when
        ;; unbound.  I seem to not understand this function, since I've seen
        ;; this before.
        (dmessage "fix me!!!")(ding)
        (while (and (not unbound-p)
                    (not tem))
          (setq tem (completing-read prompt obarray nil require-match-p 
                                     nil nil (intern-soft prev-tem)))
          (setq prev-tem tem)
          (setq tem (intern-soft tem))
          (setq tem (and tem
                         (or (not require-match-p)
                             (setq unbound-p (not (boundp tem))))
                         tem)))
        
        tem))
     (t (read-string prompt (cond
                             ((eq t initial-contents-p)
                              default)
                             (initial-contents-p
                              initial-contents-p)
                             (t nil))
                     hist-sym default)))))

(defun dp-nmz-notes (query)
  (interactive (list (dp-prompt-with-symbol-near-point-as-default 
                      "notes nmz query" :hist-sym 'dp-nmz-query-history)))
  (namazu 0 dp-note-index-dir query))
(defalias 'nng 'dp-nmz-notes)

(defun dp-nmz-mail (query)
  (interactive (list (dp-prompt-with-symbol-near-point-as-default 
                "mail nmz query" :hist-sym 'dp-nmz-query-history)))
  (namazu 0 dp-mail-index-dir query))
(defalias 'nmg 'dp-nmz-mail)

(defun dp-nmz-ports (query)
  (interactive (list (dp-prompt-with-symbol-near-point-as-default 
                      "ports nmz query" :hist-sym 'dp-nmz-query-history)))
  (namazu 0 dp-port-index-dir query))
(defalias 'npg 'dp-nmz-ports)

(defun dp-make-typedef (suffix type)
  (interactive "ssuffix: \nstype")
  (let ((word (current-word))
	el
	; list of the parts of a typedef.
	; we will only add the ones that are not already present
	; each element is a list. the car is what we search for, the
	; cdr, if present, is what we'll insert.
	(wlist (list '("typedef") '("\\s-+" " ") (list type) '("\\s-+" " "))))
    (beginning-of-line)
    (while wlist
      (setq el (car wlist)
	    wlist (cdr wlist))
      (message "el>%s<, wlist>%s< car el>%s<" el wlist (car el))
      (if (not (looking-at (car el)))
	  (insert (or (car (cdr el))
		      (car el)))
	(goto-char (match-end 0))))
      
    (end-of-line)
    (insert (format "_%s\n{\n\n}\n%s_t;\n" suffix word))
    ;;(beginning-of-line) ; not needed w/forward-line
    (forward-line -3)
    (dp-tabdent)))
	
(defun td ()
  "Convert identifier at point into a typedef for a struct."
  (interactive)
  (dp-make-typedef "s" "struct"))

(defun tde ()
  "Convert identifier at point into a typedef for an enum."
  (interactive)
  (dp-make-typedef "e" "enum"))

(defun dp-kill-comment (arg)
  (interactive "p")
  (when (or (Cu--p arg) (numberp arg))
    (when (< arg 0)
      (forward-line arg))
    (kill-comment (abs arg))
    t))
  
(defun dp-indent-for-comment (&optional arg)
  "Comment out region if mark is active, else do a normal indent-for-comment.
With optional ARG (interactively with prefix-arg) eq '-, remove any comment
on the line with `kill-comment`.
If ARG is a positive non-nil and and not '- not < 0 align the comment with
the one on the previous line."
  (interactive "*P")
  ;;(dmessage "dmap>%s<" (dp-mark-active-p))
  (let* (num
         (be (dp-mark-active-p))
         (region-beg (car be))
         (region-end (cdr be)))
    (cond
     ((dp-kill-comment arg))
     ((if be
        ;; Mark is active
        (if (or t posix-string-match mode-name "C")
            (io-region region-beg region-end io-start-text io-end-text)
          (comment-region region-beg region-end (prefix-numeric-value arg)))
      ;;(dmessage "arg>%s<" arg)
      (if arg
          (let (comment-column)
            (set-comment-column 'align-with-previous))
        (indent-for-comment)))))))

(defun dp-delimit-func-args (&optional prefix suffix)
  "Return list (useful for `apply'ing) of positions of open and close parens."
  (interactive)
  (save-excursion
    (end-of-line)
    (dp-c-beginning-of-statement)
    (if prefix (insert prefix))
    (let (point mark)
      (if (re-search-forward "(" nil t)
          (progn
            (goto-char (match-beginning 0))
            (setq point (point))
            (forward-sexp 1)
            (setq mark (1- (point)))
            (if suffix (insert suffix)))
        (dmessage "*** No open paren found."))
      (list point mark))))
  
(defun* dp-mk-proto (prefix &key (fill-proto-p t) (direction 'down dir-set-p)
                     &allow-other-keys)
  "Turn a func declaration into a prototype."
  (interactive "*sprefix: ")
  (when (and (not dir-set-p)
             (eq '- current-prefix-arg))
    (setq direction 'up))
  (unless (eobp)
    (forward-char))
  ;; Move up until we're IN the decl
  (while (not (dp-c-in-syntactic-region '(arglist-cont arglist-intro 
                                          topmost-intro-cont)))
    (case direction
      ('down (next-line 1))
      ('up (previous-line 1))))

  (dp-c-beginning-of-statement)
;   (when (dp-looking-back-at "^\\s-+")
;     (replace-match "")
;     (c-indent-line))
  (let ((bof (point))
        point)  
    (if (and prefix (not (looking-at (regexp-quote prefix))))
        (insert prefix " "))
    (if (re-search-forward "(" nil t)
        (progn
          (setq point (goto-char (match-beginning 0)))  ;opening paren
          (when (not (looking-at ";"))
            (save-excursion
              ;; add ';' first to make sure dp-c-format-func-decl stops at the
              ;; right place.
              (forward-sexp 1)
              (insert ";")))
          (when fill-proto-p            ;doesn't fix some filling problems
            (dp-c-format-func-decl nil 'no-open-brace))
          (case direction
            ('down (goto-char point)
                   ;; ??? Redundant w/following? (forward-sexp 1)
                   (c-end-of-statement)
                   (dp-c-newline-and-indent)
                   (if (< (point) (point-max))
                       (forward-char)))
            (t (goto-char bof)
               (unless (bobp)
                 (backward-char 1)))))
      (message "*** No open paren in definition."))))

(defun* dp-mk-protos (arg prefix &rest rest &key &allow-other-keys)
  (save-excursion
    (if (dp-mark-active-p)
        (let ((beg-end (dp-region-boundaries-ordered nil nil 'EXCHANGE)))
          (undo-boundary)
          ;;!<@todo Maybe do an `flet' of `undo-boundary' so one undo undoes it
          ;;all?
          (condition-case cc
              (with-narrow-to-region (car beg-end) (cdr beg-end)
                (goto-char (point-min))
                (y-or-n-p (format "0:pm: %s, pt: %s" (point-min) (point)))
                (while t
                  (dp-mk-proto prefix :direction 'down rest)))
            ((end-of-buffer beginning-of-buffer) (dmessage "boop!")))
          (dp-deactivate-mark))
      (let ((dir (if (or (eq current-prefix-arg '-)
                         (<  (prefix-numeric-value current-prefix-arg) 0))
                     'up
                   'down))
            (arg (abs arg)))
        (loop for x from 1 to arg do
          (dp-mk-proto prefix rest))))))
  
(defun dp-mk-extern-proto (arg)
  (interactive "*p")
  (dp-mk-protos arg (if (dp-in-c++-class) nil "extern")))
(defalias 'dpp 'dp-mk-extern-proto)

(defun dp-mk-ecos-proto (arg)
  (interactive "*p")
  ;; used by eCOS, extern a function w/C linkage
  (dp-mk-protos arg "externC"))
(defalias 'dppc 'dp-mk-ecos-proto)

(defun 2up-buffer ()
  "Lpr buffer w/2 columns, sideways."
  (interactive)
  (let* ((lpr-command "a2ps")
	 (lpr-headers-switches nil)
	 (lpr-add-switches nil)
	 (title-command (concat "--center-title=" (buffer-name)))
	 (lpr-switches (list title-command)))
    (lpr-buffer)))

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
      (call-interactively dp-orig-python-tab-binding))))

(defun dp-gen-unique-delimitter (text)
  "Generate a delimitter that definitely does not match any complete
line within text.  Text is a bunch of lines separated by newlines."
  (interactive)
  (let ((lines (split-string text "\n"))
	(i 1)
	(delim "^>"))
    (mapconcat
     (function
      (lambda (s)
        ;; see if we match the first part of this line
        ;; if we're a perfect match, then we'll add a(ny) char
        ;; if we're a substring, then we'll add a char that is NOT the
        ;;  char immediately after the last matched char.  this ensures
        ;;  a non-match
        (message "delim>%s< s>%s<" delim s)
        (let ((ch (if (string-match delim s)
                      (if (>= i (length s))
                          t
                        (substring s i (1+ i)))
                    nil)))
          (when ch
            (setq i (1+ i))
            (setq delim (concat delim (cond
                                       ((eq ch t) ">")
                                       ((string= ch "x") "X")
                                       (t "x"))))))
        ""))
     lines
     "")
    ;; chop off the leading ^
    (substring delim 1)))

(defun dp-make-cl-note (&optional note-text)
  "Construct a new pydb note.
Use NOTE-TEXT if present, the marked region or the current line.  Set
the creation location to emacs + the file's name"
  (interactive "*")
  (unless note-text
      (dp-mark-line-if-no-mark t)
      (setq note-text (buffer-substring (mark) (point)))
      (delete-region (mark) (point)))
  ;;(message "note-text>%s<" note-text)
  (let* ((eof-text (dp-gen-unique-delimitter note-text))
	 (here-file (format "<<'%s'\n%s\n%s" eof-text note-text eof-text))
	 (cmd (format "notes.py -nt -c 'emacs: %s' - %s" 
		      (or (buffer-file-name) (buffer-name)) here-file)))
    ;;(message "cmd>%s<" cmd)
    (shell-command-to-string cmd)))

(defun dp-insert-new-note (&optional note-text)
  (interactive "*")
  (insert (dp-make-cl-note note-text)))

(defun dp-kill-new-note (&optional note-text)
  "Take the TEXT if given, region if set or prompt for text.
Create a dppydb note and the kill it from the buffer.  It can now be
pasted easily into a dppydb notes file."
  (interactive "*")
  (unless note-text
    (if (dp-mark-active-p)
	(setq note-text (buffer-substring (mark) (point)))
      (setq note-text (read-from-minibuffer "note: "))))
  ;;(message "note-text>%s<" note-text)
  (kill-new (dp-make-cl-note note-text)))

(defvar dp-go-back-ring (make-ring dp-go-back-ring-max)
  "Ring of markers to go back to.
Set by motion commands from which one may wish to return from whence they came.")

(defun dp-go-back-ring-init ()
  "[Re]initialize the go back ring."
  (interactive)
  (setq dp-go-back-ring (make-ring dp-go-back-ring-max)))
(defalias 'clr-gbr 'dp-go-back-ring-init)

;;;(make-variable-buffer-local 'dp-go-back-stack)

;; something like this: "^[ 	]*\\*"
(defvar dp-system-buffer-regexp "^[ 	]*\\*")
(defvar dp-go-back-inhibit-regexp dp-system-buffer-regexp
  "*Do not push go-backs into these buffers.")

(defvar dp-go-back-allow-regexp 
  (concat (regexp-opt '("Man:" "GTAGS SELECT"))
          "\\|"
          ;; <asterisk>name<asterisk>
          "\\(\\*\\("
          (regexp-opt '("scratch" "shell" "Python" "Hyper Apropos" "cscope"))
          ".*\\)\\*\\)")
  "*Do push go-backs into these buffers.")

(defvar dp-go-back-min-distance 120
  "*Minimum distance to push a go back position.")

(defconst dp-go-back-confirm-file-change nil
  "If non-nil, ask before visiting a different file.")

;; @todo!!! Make a struct.
(defsubst dp-mk-gbi (reason &optional marker file-name)
  (vector (or marker (point-marker))
          reason
          (buffer-name)
          (or file-name (buffer-file-name))))

(defsubst dp-gbi-get-field (gbi fnum)
  (and gbi
       (aref gbi fnum)))

(defsubst dp-gbi-marker (gbi)
  (dp-gbi-get-field gbi 0))

(defsubst dp-gbi-marker-position (gbi)
  (marker-position (dp-gbi-marker gbi)))

(defsubst dp-gbi-reason (gbi)
  (dp-gbi-get-field gbi 1))

(defsubst dp-gbi-buffer-name (gbi)
  (dp-gbi-get-field gbi 2))

(defsubst dp-gbi-file-name (gbi)
  (dp-gbi-get-field gbi 3))

(defsubst dp-gb-top ()
  "Return top of go-back-ring."
  (if (> (ring-length dp-go-back-ring) 0)
      (ring-ref dp-go-back-ring 0)
    nil))

(defsubst dp-gb-top-pos ()
  "Return position of marker on top of go-back-ring."
  (dp-gbi-marker-position (dp-gb-top)))

(defsubst dp-gb-top-marker ()
  "Return position of marker on top of go-back-ring."
  (dp-gbi-marker (dp-gb-top)))

(dp-deflocal dp-gb-ask-for-context-p nil
  "Should I ask for context when fluttering off to another place.
I've been very bad by doing this way too much.
Like adding this while doing something else that came from somewhere else...")

(defun* dp-push-go-back (&optional reason marker allow-dammit-p marker-type
                         (ask-for-context-p dp-gb-ask-for-context-p))
  "Push (or MARKER (point-marker)) onto the go-back-stack."
  (interactive)
  ;; Preserve historical behavior.
  (setq marker-type (not marker-type))
  (unless reason
      (setq reason "unspecified"))
  
  (when ask-for-context-p
    (setq reason (concat reason ": "
                         (let ((context ""))
                           (while (string= "" context)
                             (setq context (read-string 
                                            "Some context please: ")))
                           context))))
  (setq marker
        (if (not marker)
            (dp-mk-marker nil nil marker-type)
          (if (markerp marker)
              (progn
                (set-marker-insertion-type marker marker-type)
                marker)
            ;; Are we assuming marker is a position?
            (dp-mk-marker marker nil marker-type))))
  (if (marker-buffer marker)
      (if (equal marker (dp-gb-top-marker))
          ;; Why did I not check buffer and pos?
          ;;(equal (marker-position marker) (dp-gb-top-pos))
          (dmessage "Not pushing duplicate go-back marker.")
      (let ((buf-name (buffer-name (marker-buffer marker))))
        (if (or allow-dammit-p
                (and dp-go-back-allow-regexp
                     (string-match dp-go-back-allow-regexp buf-name))
                (not (and dp-go-back-inhibit-regexp
                          (string-match dp-go-back-inhibit-regexp buf-name))))
            ;;(dmessage "dp-push-go-back")
            ;;(ding)
            (ring-insert dp-go-back-ring (dp-mk-gbi reason marker)))))
    (message "Not pushing because (marker-buffer %s) is nil." marker)))

(defsubst* dp-pop-go-back-ring (&optional (index 0))
  (ring-remove dp-go-back-ring index))

;; @todo !!! add ability to go back to a closed file.
;; Add flag to gbi that says this item was recalled from a save hist.  Clear
;; as files are visited.  Add various global defaults and parameters and
;; predicates.
(defun dp-pop-go-back (&optional arg &key silent-p)
  "Pop the top of `dp-go-back-ring' and go there.
If ARG is '- discard the top entry.
Otherwise, if ARG is non-nil, move forward thru the ring.
!<@todo make C-u0, C-0 prefix go forward and discard."
  (interactive "_P")
  (if (ring-empty-p dp-go-back-ring)
      (message "Go back ring is empty.")
    (if (and arg
             (not (Cu--p)))
        (call-interactively 'dp-go-fwd)
      (let* ((gbi (ring-ref dp-go-back-ring 0)) ; get most recent item
             (marker (dp-gbi-marker gbi))
             (buffer (marker-buffer marker))
             (reason (dp-gbi-reason gbi))
             (do-it t)
             (pop-it t))
        (if (or (not buffer)
                (Cu--p arg))
            ;; pop-it is already true
            (message "%sbuffer %s that %s file %s"
                     (if (Cu--p arg)
                         "User discard: "
                       "nil buffer discard: ")
                     (if buffer
                         (buffer-name buffer)
                       (dp-gbi-buffer-name gbi))
                     (if buffer
                         "holds"
                       "held")
                     (if buffer
                         (buffer-file-name buffer)
                       (dp-gbi-file-name gbi)))
          
          ;; dest buffer still exists
          (when (and dp-go-back-confirm-file-change
                     (not (equal buffer (current-buffer))))
            (ding)
            (setq do-it (y-or-n-p (format "Leave buffer for `%s'? " 
                                          (buffer-name buffer)))))
          (if do-it
              (progn
                ;; save where we were at end of ring
                ;; 1. toss-oldest
                (dp-pop-go-back-ring 0)
                ;; 2. save pos as oldest
                (ring-insert-at-beginning 
                 dp-go-back-ring (dp-mk-gbi 
                                  (format "%s%s" 
                                          (if (posix-string-match 
                                               "^\\[cycled\\] " 
                                               (dp-gbi-reason gbi))
                                              ""
                                            "[cycled] ")
                                          (dp-gbi-reason gbi))))
                (setq pop-it nil)
                ;;;(switch-to-buffer buffer)
                (dp-goto-marker marker)
                (unless silent-p
                  (message "back from %s" reason))
                (set-marker marker nil)) ; hasten GC of marker
            (setq pop-it (y-or-n-p "Discard marker?"))))
        (if pop-it
            (dp-pop-go-back-ring 0))))))
(put 'dp-pop-go-back 'isearch-command t)

(defun dp-go-fwd ()
  (interactive)
  (let ((t-point (dp-gbi-marker (ring-remove dp-go-back-ring))))
    (ring-insert dp-go-back-ring (dp-mk-gbi "*dp-go-fwd"))
    (goto-char t-point)))

(defun dp-go-back-top-buffer ()
  (interactive)
  (if (ring-empty-p dp-go-back-ring)
      nil
    (marker-buffer (dp-gbi-marker (ring-ref dp-go-back-ring 0)))))
         
(add-hook 'dp-post-dpmacs-hook 
          (lambda ()
            (dp-make-highlight-point-function 
             'dp-pop-go-back 
             :colors dp-highlight-point-other-window-faces)))

(defalias 'pg 'dp-pop-go-back)

(defun dp-push-onto-bounded-stack (stack item &optional bound)
  "Push ITEM onto the size bounded stack STACK.  
If BOUND is non-nil, then don't let STACK get larger than BOUND."
  (let ((stackv (symbol-value stack)))
    (set stack (cons item stackv))
    (when (and bound 
	       (>= (length stackv) bound))
      (setcdr (nthcdr (- bound 2) stackv) nil))
    (symbol-value stack)))

(defun dp-add-list-to-list (old-list list-of-new-elements)
  "Add each element of NEW-LIST to OLD-LIST using `add-to-list'."
  (dolist (list-el (reverse list-of-new-elements))
    (dp-add-to-list old-list list-el))
  (symbol-value old-list))

(defun dp-add-to-list (list-sym new-el)
  "Like `add-to-list' except it will create new list if LIST-SYM is void.
The newly created list contains just new-el."
  (if (not (boundp list-sym))
      (set list-sym (list new-el))
    (add-to-list list-sym new-el)))

(defun* dp-add-to-alist-if-new-key (list-sym item &key force-update-p
                                    &allow-other-keys)
  "Add item to an alist iff its key is not already present.
!<@todo Merge/replace with `dp-add-to-alist?' ?"
  (unless (assoc (car item) (symbol-value list-sym))
    (add-to-list list-sym item)))

(defun dp-optionally-require (feature &optional file-name)
  "Wrap `require' in condition-case to allow us to
continue in the case of an error.
Prints a warning if anything goes wrong.  Useful for trying to load
features which may have missing dependencies, etc.
Return t if successful, nil otherwise."
  (interactive)
  (condition-case error-info
      (progn
	(require feature file-name)
	t)
    (error 
     (message "**** Problem in (require %s %s): %s" 
	      feature file-name error-info)
     nil)))

(defface dp-less-bg-face
  '((((class color) (background light)) 
     (:background "linen"))) 
  "Face for file being less viewed."
  :group 'faces
  :group 'dp-vars)

(defface dp-wp-face
  '((((class color) (background light)) 
     (:background "lightsalmon2"))) 
  "Face for write protected regions. A write protected *file* may be colored differently."
  :group 'faces
  :group 'dp-vars)

(defun less (file-name &optional buffer-name q-key-command program)
  "``Less'' a file.  
Interpret and display file contents as text.
Do this by executing PROGRAM or `dp-less-program' (e.g. lesspipe.sh).  
After the translated file is inserted, clear the modified flag,
mark the buffer read-only and bind ?q, ?Q, ?x and ?X to Q-KEY-COMMAND."
  (interactive "ffile: \nP")
  ;; we don't just process a region or buffer since lesspipe.sh
  ;; uses the file name to make type guesses
  (when file-name
    (setq file-name (expand-file-name file-name))
    (setq buffer-name
	  (cond
	   ((eq buffer-name t)
	    (read-from-minibuffer "buf name: " "*less*"))
	   ((eq buffer-name nil)
	    (generate-new-buffer-name 
	     (format "*lessl(%s)*" 
		     (file-name-nondirectory file-name))))
	   (t
	    buffer-name)))
    ;;(message "buffer-name>%s<" (buffer-name))
    (dp-simple-viewer buffer-name
		      (function
                       (lambda ()
                         (setq rc (call-process (or program dp-less-program) 
                                                nil t nil file-name))
                         (unless (eq rc 0)
                           (message "call-process: rc>%s<" rc))
                         ;;
                         ;; if lesspipe can find nothing to do
                         ;; (e.g. for a text file) then it emits
                         ;; nothing.  In this case we just read the
                         ;; original file.
                         (if (eq (point) (point-min))
                             (insert-file-contents file-name))))
		      nil		;quit-keys
		      q-key-command	;q-key-command
		      nil		;key-map
		      'dp-less-bg-face)	;text-face
    (goto-char (point-min))
      (let ((inhibit-read-only t))
	(if (fboundp 'ununderline-and-unoverstrike-region)
	    (ununderline-and-unoverstrike-region (point-min) (point-max))
	  (message "Cannot remove underlines and overstrikes inside emacs.")))
      ;; clear modified flag so user doesn't accidentally nuke original file
      (set-buffer-modified-p nil)))

(defun unlessl ()
  "Restore original contents of lessl'd file."
  (interactive)
  (dp-delete-extents (point-min) (point-max) 'dp-less-bg-extent)
  (revert-buffer nil t))

(defun lessl ()
  "Lesslify a buffer.  
Interpret buffer contents by calling `less' on the buffer's file."
  (interactive)
  (if (buffer-modified-p)
      (error "Buffer is modified: please save or revert the buffer first."))
  (less (buffer-file-name) (buffer-name) 'unlessl))

(defvar dp-contrib-site-packages (expand-file-name 
                                  "~/lisp/contrib/site-packages")
  "My local site packages root.")

(defun dp-mk-site-package-dir (&rest names)
  (expand-file-name (paths-construct-path 
                     (cons dp-contrib-site-packages names))))

(defvar dp-site-package-info (dp-mk-site-package-dir "info")
  "My local site packages info root.")

(defvar dp-site-package-lisp (dp-mk-site-package-dir "lisp")
  "My local site packages lisp root.")

(defun dp-mk-site-package-lisp-dir (&rest names)
  (expand-file-name (paths-construct-path (cons dp-site-package-lisp names))))

(defvar dp-contrib-package-root "~/lisp/contrib")

(defun dp-mk-contrib-subdir (&rest subdir-components)
  (expand-file-name (paths-construct-path
                     (cons dp-contrib-package-root subdir-components))))
                    
(defun dp-mk-contrib-pkg-child (&rest pkg-names)
  (expand-file-name (paths-construct-path  
                     (cons dp-contrib-site-packages pkg-names))))

(defun dp-mk-contrib-site-pkg-child (&rest pkg-names)
  (expand-file-name (paths-construct-path  
                     (cons dp-contrib-site-packages pkg-names))))

;;; ??? emacs days??? (defvar dp-hyperbole-dir "/usr/yokel/share/emacs/site-lisp/hyperbole")
(defvar dp-hyperbole-dir 
  (concat (getenv "HOME")
	  "/lisp/contrib/site-packages/lisp/hyperbole"))
(defvar hyperb:dir (concat dp-hyperbole-dir "/"))
(defun dp-setup-hyperbole ()
  "Set up hyperbole info system."
  (interactive)
;   (setq hyperb:dir (concat dp-hyperbole-dir "/"))
   (load (expand-file-name "hversion" hyperb:dir))
   (load (expand-file-name "hyperbole" hyperb:dir)))

(defun dp-setup-slime ()
  "Set up SLIME, a lisp inferior mode environment. 
See http://www.cliki.net/SLIME as of: 2010-05-20T08:16:39"
  (interactive)
  (add-to-list 'load-path (dp-mk-contrib-subdir "slime")) ; your SLIME directory
  (setq inferior-lisp-program "/usr/bin/sbcl") ; your Lisp system
  (require 'slime)
  (slime-setup))

(defun dp-setup-scala-mode ()
  "Set up programming mode for Scala files."
  (interactive)
  (add-to-list 'load-path (dp-mk-contrib-subdir "scala-mode"))
  (dp-add-to-auto-mode-alist "scala" 'scala-mode t)
  (require 'scala-mode-auto))

(defun dp-setup-emacs-jabber ()
  "Set up emacs' jabber client."
  (interactive)
  (add-to-list 'load-path (dp-mk-contrib-subdir "emacs-jabber"))
  (require 'jabber)
  (require 'jabber-autoloads))

;(defun dp-eldoc-get-help-str ()
;  "Get help string eldoc would print."
;  (interactive)
;  (require 'eldoc)
;  (autoload 'eldoc-print-current-symbol-info "eldoc" "name says it all...")
;  (autoload 'eldoc-display-message-p "eldoc")
;  (eldoc-display-message-p)		;force the autoload
;  (let (dpe-message)
;    (flet ((eldoc-display-message-p () t)
;	   (eldoc-message (&rest args) (setq dpe-message args)))
;      (eldoc-print-current-symbol-info))
;    dpe-message))

(defun dp-insert-elisp-func-template (doc)
  "Insert function template extracted from an eldoc help message."
  (interactive "*")
  (message "%s" doc)
  ;(setq doc (car doc))
  (if (not doc)
      (error "could not find doc.")
    (if (string-match "[^(]*(\\(.*\\))[^)]*" doc)
	(save-excursion
	  (insert (substring doc (match-beginning 1) (match-end 1)) ")"))
      (message "Cannot find args, none?"))))

(defun dp-eldoc (&optional insert-template)
  "Display simple help summary in echo area, ala eldoc, except only on demand.
If INSERT-TEMPLATE is non-nil (interactively with prefix arg) then insert a
function template at point.
@todo can we add possibility of specifying what to get help on?"
  (interactive "P")
  (let ((doc (eldoc-get-doc)))
    (if insert-template
	(dp-insert-elisp-func-template doc)
    (message "%s" (or doc 
		      (format "No doc for `%s'" (eldoc-current-symbol)))))))

(defun 2man (topic &optional arg silent)
  "Display a man page in another window."
  (interactive (list (let ((default (symbol-near-point)))
                       (read-string
                        (if (equal default "") "Manual entry: "
			  (concat "Manual entry: (default " default ") "))
			nil 
                        (and-boundp 
                            'Manual-page-minibuffer-history
                            'Manual-page-minibuffer-history)
                        default))
                     (prefix-numeric-value current-prefix-arg)))
  (let ((obuf (current-buffer)))
    (if (one-window-p 'NOMINIBUFFER)
        (split-window))
    (save-excursion
      (with-selected-window (next-window)
        (manual-entry topic arg)))))

(defun auctex-setup ()
  (interactive)
  (require 'tex-site)
  (add-to-list 'auto-mode-alist '("\\.latex$" . LaTeX-mode))
  (if window-system
      (progn
	(require 'font-latex)
	(add-hook 'latex-mode-hook 'turn-on-font-lock 'append)
	(add-hook 'LaTeX-mode-hook 'turn-on-font-lock 'append))))

(defun dp-file-link-at-point ()
  "Return the longest string of non-spaces at point."
  (interactive)
  (save-excursion
    (let (str str-end)
      (if (looking-at "\\s-\\|\n")
	  (skip-chars-backward dp-ws)
	(skip-chars-forward "^ 	\n"))
      (setq str-end (point))
      (skip-chars-backward "^ 	\n")
      (setq str (buffer-substring (point) str-end))
      (message "str>%s<" str)
      str)))

(defun dp-goto-file+re (&optional str)
  "Visit a file and search for the specified reg-exp."
  (interactive)
  (dp-push-go-back "dp-goto-file+re")
  (setq-ifnil str (dp-file-link-at-point))
  ;;(dmessage "str>%s<" str)
  (let* ((nlist (split-string str "#"))
	 (fname (car nlist))
	 (pat (car (cdr nlist))))
    (message "fname>%s<, pat>%s<" fname pat)
;    (dp-push-go-back "dp-goto-file+re")
    (find-file fname)
    (goto-char (point-min))
    (if (re-search-forward (concat "^" pat "(") nil t)
	(beginning-of-line)
      (message "Cannot find definition of `%s'" pat)))) 

; (defadvice dp-goto-file+re (before dp-goto-file+re-A act)
;   "dp-push-go-back advised `dp-goto-file+re'."
;   (dp-push-go-back "advised dp-goto-file+re"))

(defvar dp-orig-efs-ftp-program-name nil
  "Save the original efs prog name.")
(defvar dp-efs-ssh-ftp-program-name "ftp-over-ssh.py"
  "My ftp over ssh emulator.")

(defun dp-ssh-efs ()
  (interactive)
  "Toggle efs prog name."
  (require 'efs)
  (setq-ifnil dp-orig-efs-ftp-program-name efs-ftp-program-name)
  (if (string= dp-orig-efs-ftp-program-name efs-ftp-program-name)
      (setq efs-ftp-program-name dp-efs-ssh-ftp-program-name)
    (setq efs-ftp-program-name dp-orig-efs-ftp-program-name))
  (message "using %s" efs-ftp-program-name))

(defun* dp-prompt-string-with-default (prompt &optional default 
                                       &key prompt-args default-args )
  "Useful for putting a DEFAULT value in a PROMPT string.
DEFAULT is added like so \"(default: DEFAULT): \"
not DEFAULT just gets the \": \".
Note the spaces."
  (format "%s%s: " 
          (if (functionp prompt)
              (apply prompt prompt-args)
            (or prompt ""))
          (let ((default (if (functionp default)
                             (apply default default-args)
                           default)))
            (if default
                (format " (default: %s)" default)
              ""))))

(defun dp-insert-ebang (&optional md-name cbeg cend)
  "Add the elisp mode comment to a file"
  (interactive 
   (list                         ; "smode name: \nscbeg: \nscend: ")
    (read-from-minibuffer (dp-prompt-string-with-default "mode name" mode-name)
                          nil nil nil nil nil mode-name)
    (read-from-minibuffer (dp-prompt-string-with-default 
                           "comment start" comment-start)
                          nil nil nil nil nil comment-start)
    (read-from-minibuffer (dp-prompt-string-with-default 
                           "comment end" comment-end)
                          nil nil nil nil nil comment-end)))
    
  (when (and (string-match "^\\(.*\\)\\(-mode\\)$" md-name)
             (y-or-n-p
              (format
               "mode name ends with `%s' which usually isn't needed. Nuke it? "
               (match-string 2 md-name))))
    (setq md-name (match-string 1 md-name)))
  (save-excursion
    (goto-char 0)
    (let ((ebang (format "%s-*-%s-*-%s" (or cbeg "") md-name (or cend "")))
          (newl "\n"))
      (if (re-search-forward "-\\*-.*-\\*-\\(\n\\)?" nil t)
          (progn
            (delete-region (match-beginning 0) (match-end 0))
            (unless (match-beginning 1)	; did we del a newline?
              (setq newl "")))
        (setq newl "\n"))
      (insert ebang newl)
      (dp-set-auto-mode))
    (goto-char 0)
    (when (and (not cbeg) (not cend))
      (ding)
      (message "You need to insert the appropriate comment chars"))))

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

(defun dp-find-element-containing-pos (target-pos pos-list)
  "Convert offset in buffer to an index in a list of buffer positions.
TARGET-POS is the position we wish to locate.  
POS-LIST is a list of buffer positions in ascending order."
  (let ((ret -1))
    (loop for pos in pos-list
      until (> pos target-pos)
      do (setq ret (1+ ret)))
    ret))

;; @todo Once one pos is >= delta, all remaining are too.  So loop once
;; looking for the first, then loop unconditionally after that.
(defun dp-left-shift-position-list (pos-list delta)
  "Left shift POS-LIST by DELTA."
  (interactive)
  (loop for pos in pos-list
    when (>= pos delta) collect (- pos delta)))

(defun dp-find-most-specific-file (base extensions)
  "Find the most specific file which exists.
Files are constructed from BASE and each element of EXTENSIONS.
EXTENSIONS is a list of extensions with dots from most specific
to least."
  (catch 'done
    (let (file)
      (while extensions
	(setq file (format "%s%s" base (car extensions)))
	(if (file-readable-p file)
	    (throw 'done file))
	(setq extensions (cdr extensions)))
      nil)))

(defun dp-specific-extensions ()
  "Return list of locale suffixes if it exists, otherwise the system name."
  (cons ".site" 
        (split-string (or (getenv "locale_rcs")
                          (concat "." (car (split-string 
                                            (system-name) "\\.")))))))

(defun dp-find-diary-file ()
  "Find the most specific diary file, set `diary-file' and return the value."
  (let ((dfile (dp-find-most-specific-file 
		"~/diary"
		(append (nreverse (dp-specific-extensions)) '("")))))
    (when dfile
      (setq diary-file dfile))
    dfile))

(defun dp-update-alist (old-alist-var new-alist)
  "Modify the old-alist-var with values of new-alist.
Replace the values of existing associations and add new ones
to old-alist-var."
  (let ((tlist new-alist)
	(new-el)
	(new-el-key)
	(old-el))
    (while tlist
      (setq new-el (car tlist))		;grab next pair from new-alist
      (setq tlist (cdr tlist))		;move to next in list
      (setq new-el-key (car new-el))	;get the key from the new element
      ;; see if the old list has an element with the same key
      (setq old-elem (assoc new-el-key (symbol-value old-alist-var)))
      (if old-elem
	  (progn
	    ;; replace old value with new one
	    (setcdr old-elem (cdr new-el)))
	;; no such element in the old list, add the new element
	(set old-alist-var 
	     (append (list new-el) (symbol-value old-alist-var))))))
  (symbol-value old-alist-var))

(defun* dp-append-to-alist-list (alist-sym key new-elements
                                 &optional (initial-elements 
                                            (cdr (assoc key (symbol-value alist-sym)))))
  "Append NEW-ELEMENTS to ALIST-SYM's KEY value.
ALIST-SYM's format is: ((k1 kv1 kv2...) (kn kn1 kn2...))."
  (unless (listp new-elements)
    ;; C'mon man... its name is new-elementSSSSSS!
    (setq new-elements
          (if (consp new-elements) 
              (list (car new-elements) (cdr new-elements))
            (list new-elements))))
  (set-modified-alist alist-sym 
                      (list (cons key (append new-elements initial-elements)))))

(defun* dp-delete-from-alist-list (alist-sym key doomed-elements
                                   &optional (initial-elements 
                                              (cdr (assoc key (symbol-value alist-sym)))))
  "Remove DOOMED-ELEMENTS from ALIST-SYM's KEY value.
ALIST-SYM's format is: ((k1 kv1 kv2...) (kn kn1 kn2...))."
  (unless (listp doomed-elements)
    ;; C'mon man... its name is doomed-elementsSSSSS!
    (setq doomed-elements
          (if (consp doomed-elements) 
              (list (car doomed-elements) (cdr doomed-elements))
            (list doomed-elements))))
  (let ((new-list (delq nil (mapcar (function
                                     (lambda (elt)
                                       (unless (member elt doomed-elements)
                                         elt)))
                                    initial-elements))))
    (set-modified-alist alist-sym
                        (list (cons key new-list)))))

(defun dp-face-list-at (&optional pos)
  "Return list of faces at POS or (point) if nil."
  (delq nil
        (mapcar (function
                 (lambda (extent)
                   (extent-face extent)))
                (extents-at (or pos (point))))))

(defun dp-face-at (&optional pos)
  "Print name(s) of face(s) at POS or (point) if nil."
  (interactive)
  (message "%s"
	   (mapconcat (function
                       (lambda (face)
                         (format "%s; " face)))
                      (or (dp-face-list-at)
                          (list (format "No faces @ %s" (or pos (point)))))
                      "")))

(defalias 'dp-faces-at 'dp-face-at)

(defun dp-extent-list-at (&optional pos object property before at-flag)
  (setq-ifnil pos (point))
  (with-current-buffer (if (markerp pos)
                           (marker-buffer pos)
                         (current-buffer))
    (extents-at pos object property before at-flag)))

(defun dp-pretty-format-extent (extent sep raw-p)
  (format "%s... %s: %s%s%s"
          (extent-start-position extent)
          (extent-end-position extent)
          (extent-properties extent)
          (if raw-p
              (format "[raw:%S]" extent)
            "")
          (or sep "; ")))
  
(defun dp-extents-at (&optional pos object property before at-flag sep)
  "Describe all extents at POS, which defaults to `point'."
  (interactive)
  (setq-ifnil pos (point)
              sep "; ")
  (with-current-buffer (if (markerp pos)
                           (marker-buffer pos)
                         (current-buffer))
    (message "exts: %s"
             (mapconcat (function 
                         (lambda (extent)
                           (dp-pretty-format-extent extent sep 
                                                    current-prefix-arg)))
                        (extents-at pos object property before at-flag)
                        ""))))

(defun dp-extent-prop-match (ext prop prop-val)
  (let ((ext-prop-val (extent-property ext prop)))
    (when (or (equal prop-val ext-prop-val)
              (and ext-prop-val
                   (listp ext-prop-val)
                   (member prop-val ext-prop-val)))
      ext)))

(defun* dp-extents-at-with-prop (prop &optional value pos (at-flag 'at))
  "Find extents with property PROP, optionally with VALUE.
POS, if non-nil, can be a position or a marker.  If it's a marker, then the
action takes place in the marker's buffer.  If it's nil, then we use point in
the current buffer.
VALUE is either nil which means don't care about the values,
or a cons (unused . val-to-check-for).  These hoops are so
we can tell nil meaning don't check vs checking for a value
of nil, i.e. nil vs (unused . nil)."
  (interactive)
  (setq-ifnil pos (point))
  (with-current-buffer (if (markerp pos)
                           (marker-buffer pos)
                         (current-buffer))
    (delq nil (mapcar (function
                       (lambda (ext)
                         (when (memq prop (extent-properties ext))
                           ;; if there's a value then it must match as well
                           (if value
                               (when (dp-extent-prop-match ext prop 
                                                           (cdr value))
                                 ext)
                             ext))))
                      (extents-at (or pos (point)) nil nil nil 'at)
                      ))))

(defun dp-first-extent-boundaries (&rest rest)
  "Simple helper to to return the first extent found by `dp-extents-at-with-prop'.
This is the first matching extent eventually returned by `extents-at'.
Here, first means the car of the list."
  (car-safe (apply 'dp-extents-at-with-prop rest)))

(defun dp-set-minor-mode-modeline-id (minor-mode &optional id)
  (interactive)
  (setq-ifnil id "")
  (let ((mm (assoc minor-mode minor-mode-alist)))
    (when mm
      (cond
       ((listp (car (cdr mm)))
	(let ((cdr-to-set (cdr (cadr mm))))
	  (if cdr-to-set
	      (setcdr cdr-to-set id))))
       ((stringp (car (cdr mm))) (setcdr mm (list id)))))))


(dp-deflocal dp-last-line-or-bm "1" "Last line or bookmark gone to.")

;; @todo Allow man suffixen, and allow n < 0 to mean backwards n: 
;; {f -> defuns, l -> lines, s -> statements, S -> sentences, ...} and
;; other units that emacs understands.
(defun dp-goto-line (line-or-bm &optional nada) ;<:dgl|goto line:>
  "Save current position on go-back stack, then goto line or bookmark.
\[0-9]+c ==> goto that char."
  (interactive (dp-get-bm-interactive 
                (format "line# (or w/suffix: c -> char) or bm (%s): " 
                        dp-last-line-or-bm)
                :completions (dp-bm-rebuild-completion-list)))
  (let ((starting-point (point)))
    (dp-push-go-back "dp-goto-line")
    (dp-set-zmacs-region-stays t)
    (if (string-equal "" line-or-bm)
        (setq line-or-bm dp-last-line-or-bm)
      (setq dp-last-line-or-bm line-or-bm))
    (cond
     ((string-match "\\(^[0-9]+c$\\)\\|\\(^[.#][0-9]+$\\)" line-or-bm)
      (if (match-string 1 line-or-bm)
          (goto-char (string-to-int line-or-bm))
        (goto-char (string-to-int (substring (match-string 2 line-or-bm) 1)))))
     ((string-match "^=\\s-*\\([0-9]+\\)$" line-or-bm)
      (goto-char (string-to-int (match-string 1 line-or-bm))))
     ((string-match "^[0-9]" line-or-bm) 
      (goto-line (string-to-int line-or-bm)))
     (t (dp-set-or-goto-bm (if (string-match "\\([>/:]\\)\\([0-9]+\\)" 
                                             line-or-bm)
                               (match-string 2 line-or-bm) 
                             line-or-bm)
                           :reset nil 
                           :action-if-non-existent(if current-prefix-arg
                                                      'set
                                                    'ask))))
    (unless (equal starting-point (point))
       (dp-what-cursor-position))))

; WHY THE FUCK did I do it this way?
; (defadvice dp-goto-line (before dp-goto-line-A act)
;   "dp-push-go-back advised `dp-goto-line'."
;   (dp-push-go-back "advised dp-goto-line"))
  
(defvar dp-yank-indent-override-p nil
  "Force inserts (yanks) to never do indentation after insertion.")

(defun dp-yank (&optional arg)
  "Hack workaround for bug that cause yanks to be inserted into the kill ring.
The bug is enabled by, among other things, getting an argument of zero
as index into the kill-ring. Since the code mods the index, passing
the size of the ring gets the same item as zero, but doesn't trigger
the bug.
Also, it seems to me that if interprogram-paste-function is non-nil,
then yank never returns anything else but the clipboard text.
Calling with \C-0 as prefix arg yields original ARG-as-nil behavior."
  (interactive "*P")
  (when (and (not (Cu--p))
             (> 0 (prefix-numeric-value arg)))
     (previous-line (abs (prefix-numeric-value arg)))
     (setq arg nil))
  (cond
   ((and (not arg)
         interprogram-paste-function)
    ;; Fix the index-0 problem (q.v.)
    (yank (1+ (length kill-ring))))
   ((Cu--p)
    (dp-insert-isearch-string))
   ;; Result is same as default ARG-as-nil behavior.
   ((Cu0p)
   (setq current-prefix-arg nil)
   (call-interactively 'yank))
   ;; original behavior when arg is an integer >0
   (t (call-interactively 'yank)))
  (when (and (not dp-yank-indent-override-p)
             (dp-in-c))
    (let* ((b-e (dp-region-boundaries-ordered (point) (mark t)))
           (b (car b-e))
           (e (cdr b-e)))
      (undo-boundary)
      (c-indent-region b e)))
  (setq last-command this-command))

(defun dp-c-yank-pop (arg)
  (interactive "P")
  (let ((indent-p (equal arg '(4)))
        (arg (prefix-numeric-value arg)))
    (if (not indent-p)
        (call-interactively 'yank-pop arg)
      (dp-yank))))
  
(defun dp-set-auto-mode (&optional mode)
  "Interactive version of `set-auto-mode'
MODE, if non-nil, is assumed to be the mode init function and is called
directly instead of asking set-auto-mode to deduce it.
This makes it easy to set modes in scripts, etc., that use no extension after
you've added enough info for set-auto-mode to figure it out.."
  (interactive)
  (if mode
      (funcall mode)
    (set-auto-mode))
  (normal-mode)				;read the file vars, if any
  (turn-on-font-lock)
  (dp-found-file-setup))

(defalias 'sam 'dp-set-auto-mode)

(defun* dp-reset-major-mode (&optional (full-p t))
  (interactive)
  (if full-p
      (dp-set-auto-mode major-mode)
    (funcall major-mode)))
(defalias 'rmm 'dp-reset-major-mode)

(defun dp-nuke-fill-prefix ()
  "If `fill-prefix' gets set somehow, it fucks up `lisp-mode's ability to, for one thing, fill docstrings properly."
  (interactive)
  (setq fill-prefix nil))

(defun dp-current-pmark-pos (&optional buffer)
  "Return buffer pos of current process mark."
  (marker-position (process-mark (get-buffer-process (or buffer
							 (current-buffer))))))

;;
;; try for more feature filled gnuserv and fall back
;; to the regular server if gnuserv is not available.
;;
(defun dp-start-server (&optional leave-or-make-dead-p)
  "Start up an editing server.  Try for gnuserv, then server.
This is a func so it can specified on the command line as something to run or
not."
  (condition-case nil
      (progn
	(require 'gnuserv)
	(message "using gnuserv")
	(let ((frame (car (frame-list))))
          (if (gnuserv-start leave-or-make-dead-p)
              t                         ; Deeniiiiiiied!
            (setq gnuserv-frame frame)
            nil)))
    (error (unless (in-windwoes)
	     (message "using regular server")
	     (server-start)))))
  
(defun* dp-start-editing-server (&optional (leave-or-make-dead-p t))
  "Start a server to edit files for remote clients.  Prefer `gnuserv'.
LEAVE-OR-MAKE-DEAD-P (prefix arg) says nuke any existing server and start a
new one."
  (interactive "P")
  (when leave-or-make-dead-p
  ;; Nuke any possible existing server.
    (dp-start-server t))
  ;; Start gnu (har, har!) one.
  (dp-start-server))
(dp-defaliases 'gserv 'xserver 'eserver 'gnuserve 'dp-start-editing-server)

(defun dp-never-cleanup-buffer-p (buf)
  (string-match "Minibuf" (buffer-name buf)))

;; !<@todo XXX Rework, possibly using `dp-choose-buffers'
(defun* dp-cleanup-buffers (&optional with-extreme-prejudice-p
                            &key list kill-pred1 kill-pred2
                            keep-pred
                            (cleanup-mode-list dp-cleanup-buffers-mode-list))
  "For each buffer in LIST, compare to kill regexp and kill if matches.
!<@todo XXX Rework, possibly using `dp-choose-buffers'."
  (interactive "P")
  (setq-ifnil list (buffer-list))
  (while list
    (let* ((buf (car list))
	   (name (buffer-name buf)))
      (setq list (cdr list))
      ;;(message "look at>%s<" (buffer-name buf))
      (with-current-buffer buf
        (when (and (not (dp-never-cleanup-buffer-p buf))
                   (or (not keep-pred) 
                       (not (funcall keep-pred buf))))
          (and (if kill-pred1
                   (or (eq kill-pred1 t)
                       (funcall kill-pred1 buf))
                 ;; inline default predicate 1
                 (or (not (buffer-modified-p))
                     (not (buffer-file-name))))
               (if kill-pred2
                   (or (eq kill-pred2 t)
                       (funcall kill-pred2 buf))
                 ;; inline default predicate 2
                 (memq major-mode cleanup-mode-list))
               (message "ta-ta>%s<" (buffer-name))
               (if with-extreme-prejudice-p
                   (kill-buffer buf)
                 (call-interactively
                  (key-binding [(meta ?-)])))))))))

(defun dp-kill-all-but-shells ()
  (interactive)
  (dp-cleanup-buffers nil :kill-pred1 t :kill-pred2 t
                      :keep-pred 'dp-shell-shell-buffer-p))

(defun dp-maybe-set-face (face val &optional force)
  "Set FACE to VAL if it is not already set."
  (if (or force (not (face-differs-from-default-p face)))
      (cond
       ((symbolp val) (copy-face val (symbol-value face)))
       ((listp val) (custom-set-faces (list face val t)))
       (t (error "Unknown val type in dp-maybe-set-face")))))

; ;;
; ;; stick a space at the beginning of each line so the indent function
; ;; doesn't ignore the line.  In the case where the comment shoud be at
; ;; the beginning of the line, it will be moved backwards correctly.
; ;;!<@todo get and insert class name?  Or does doxy do it already?
; (defvar doxy-python-class-member-comment-elements '("
;  /*********************************************************************/" > "
;  /*!" > "
;   * @brief " (P "brief desc: " desc nil) > "
;   */" > % >)
;   "Elements of a class function comment template")

; (defvar doxy-python-function-comment-elements '("
;  /*********************************************************************/" > "
;  /*!" > "
;   * @brief " (P "brief desc: " desc nil) > "
;   */" > % >)
;   "Elements of a C/C++ function comment template")

; (defvar doxy-python-class-comment-elements '("
;  /*********************************************************************/" > "
;  /*!" > "
;  * @class " p > "
;  * @brief " p > "
;  */" > % >)
;   "Elements of a C/C++ class comment template")
          
; (tempo-define-template "doxy-python-class-member-comment"
; 		        doxy-python-class-member-comment-elements)
; (tempo-define-template "doxy-python-function-comment"
; 		        doxy-python-function-comment-elements)
; (tempo-define-template "doxy-python-class-comment"
; 		        doxy-python-class-comment-elements)

;;
;; stick a space at the beginning of each line so the indent function
;; doesn't ignore the line.  In the case where the comment shoud be at
;; the beginning of the line, it will be moved backwards correctly.
;;!<@todo get and insert class name?  Or does doxy do it already?
(defvar doxy-c-class-member-comment-elements '(
" /*********************************************************************/" > "
 /*!" > "
  * @brief " (P "brief desc: " desc nil) > "
  */" > % >)
  "Elements of a class function comment template")

(defvar doxy-c-function-comment-elements '("
 /*********************************************************************/" > "
 /*!" > "
  * @brief " (P "brief desc: " desc nil) > "
  */" > % >)
  "Elements of a C/C++ function comment template")

(defvar doxy-c-class-comment-elements '("
 /*********************************************************************/" > "
 /*!" > "
 * @class " p > "
 * @brief " (P "brief desc: " desc nil) > "
 */" > % >)
  "Elements of a C/C++ class comment template")
          
(tempo-define-template "doxy-c-class-member-comment"
		        doxy-c-class-member-comment-elements)
(tempo-define-template "doxy-c-function-comment"
		        doxy-c-function-comment-elements)
(tempo-define-template "doxy-c-class-comment"
		        doxy-c-class-comment-elements)

(defun dp-insert-tempo-template-comment (template-func &optional 
                                         no-indent no-bol indent-to
                                         beginning-of-statement)
  "Use TEMPLATE-FUNC to add a comment. Typically a tempo template.
Often context sensitive.
Please enter a brief description of the function at the prompt.
If NO-INDENT is non-nil (interactively with prefix arg) then
do not indent the newly inserted comment block."
  (or no-bol
      (and beginning-of-statement
           (goto-char beginning-of-statement))
      (end-of-line)
      (if (dp-in-c)
          (dp-c-beginning-of-statement)))
  
  ;; '% in tempo handles adding a newline
  ;;   (if (not (looking-at "^\\s-*$"))
  ;;      (save-excursion (insert "\n")))
  (let ((beg (dp-mk-marker))
        (end (dp-mk-marker (1+ (point)))))
    (funcall template-func)
    (when (and (not no-indent)
	       (fboundp 'c-indent-region))
      (indent-region beg (1- end) indent-to)))
  (setq beg nil end nil))

(defun dp-c-tempo-insert-member-comment (&optional no-indent)
  "Add a tempo class function comment."
  (interactive "*")
  (dp-insert-tempo-template-comment 
   'tempo-template-doxy-c-class-member-comment no-indent))
(defalias 'tcfc 'dp-c-tempo-insert-member-comment)

(defun dp-c-tempo-insert-function-comment (&optional no-indent)
  "Add a tempo function comment."
  (interactive "*")
  (dp-insert-tempo-template-comment 
   'tempo-template-doxy-c-function-comment no-indent))
(defalias 'tfc0 'dp-c-tempo-insert-function-comment)


(defun dp-c-insert-class-comment ()
  "Insert a tempo class comment, using the class name from the current line."
  (save-match-data
    (save-excursion
      (beginning-of-line)
      ;; find the class name
      ;; @todo templates *WILL* break this.
      ;; Apparently not. 
      (re-search-forward 
       "\\s-*\\(enum\\|class\\|struct\\)\\s-+\\(\\S-+?\\)\\s-*\\(:\\|{\\|$\\)"))
    (let ((class-name (match-string 2)))
      ;;(tempo-template-doxy-c-class-comment)
      (dp-insert-tempo-template-comment 
       'tempo-template-doxy-c-class-comment nil
       nil nil (match-beginning 0))
      (insert class-name)
      (tempo-forward-mark))))

(defun dp-c-insert-tempo-comment (&optional no-indent-p)
  "Insert a C/C++ mode tempo comment in a syntax sensitive manner."
  (interactive "*P")
  (if (dp-in-c++-class)
      (dp-c-tempo-insert-member-comment)
    (if (save-excursion
          (beginning-of-line)
          (looking-at "\\s-*\\(enum\\|class\\|struct\\|template\\)"))
        (dp-c-insert-class-comment)
      ;; not in C++, just insert a function comment
      (dp-c-tempo-insert-function-comment))))

(dp-deflocal dp-insert-tempo-comment-func nil
  "Function to call when adding a tempo template based comment.")

(defun dp-insert-tempo-comment (&optional no-indent)
  "Add a tempo comment.
Insert a context sensitive comment using a tempo template.
This is vectored via the buffer local variable `dp-insert-tempo-comment-func' 
so each mode can have its own logic."
  (interactive "*P")
  (when dp-insert-tempo-comment-func
    (funcall dp-insert-tempo-comment-func no-indent)))
(defalias 'tc 'dp-insert-tempo-comment)

(defun pyman ()
  "Browse the python docs."
  (interactive)
  ;; @todo locate doc dir more intelligently
  ;; done in shell profile
  (w3m (paths-construct-path (list (getenv "PYTHONDOCS") "index.html"))))

(defun dp-untabify (&optional beg end)
  "Untabify the current region if mark is set, the entire buffer otherwise."
  (interactive "*")
  (let ((beg-end (dp-region-or... :bounder 'buffer-p)))
    (untabify (car beg-end) (car beg-end))))

(defvar dp-save-dp-disable-interprogram-paste-function 
  interprogram-paste-function 
  "Saved value of `interprogram-paste-function'.")
(defvar dp-save-dp-disable-interprogram-cut-function interprogram-cut-function
  "Saved value of `interprogram-cut-function'.")

(defun dp-disable-interprogram-functions (&optional new-paste new-cut)
  "Set dp-disable-interprogram-paste-function."
  (setq interprogram-paste-function new-paste
	interprogram-cut-function new-cut))

(defun dp-restore-interprogram-functions (&optional new-paste new-cut)
  "Set dp-disable-interprogram-paste-function."
  (setq interprogram-paste-function  
        dp-save-dp-disable-interprogram-paste-function 
	interprogram-cut-function 
         dp-save-dp-disable-interprogram-cut-function))

(defun dp-laptop-rc ()
  "Set up things for the laptop."
  (interactive)
  (message "dp-laptop-rc()...")
  ;;(dp-disable-interprogram-functions)
  ;;(setq browse-url-browser-function 'w3m-browse-url)
  (when (in-windwoes)
    (add-hook 'kill-emacs-query-functions 
	      (function
               (lambda ()
                 (y-or-n-p "Really exit(windows [key] sucks)?")))))
    (message "dp-laptop-rc()...finished"))

(defun dp-main-rc ()
  "NB: This runs after `dp-post-dpmacs-hook'. Sets us up as a primary emacs:
run server and activate appointments."
  (interactive)
  (message "dp-main-rc()...")
  (dp-start-server)
  ;; This runs after dpmacs has completed.
  ;;(add-hook 'dp-post-dpmacs-hook 'dp-activate-appts)
  (dp-activate-appts)
  (dp-appt-initialize)
  ;; the -geometry arg doesn't work quite right under kde.
  (message "dp-main-rc()...finished.")
)		       ; MAC + flat panel in ll office
;;;??? why did I add this here?  (dp-run-post-dpmacs-hooks))
;;; For one thing, it fixed the window config that was set in the hook var
;;; which was set by the dp-post-dpmacs-hook.  This is not a good way to do
;;; it since some of the hook functions may not be able to handle being run
;;; twice.

(defvar dp-gdb52-cmd-name "gdb52")
(defun gdb52 (gdb-cmd)
  "Run gdb52 in gdb mode.
With prefix arg prompt for gdb program name.
With prefix arg more than once, remember the gdb program for the remainder
of the Emacs session."
  (interactive (list (if current-prefix-arg
			 (read-from-minibuffer "gdb command: " 
					       dp-gdb52-cmd-name)
		       dp-gdb52-cmd-name)))
	
  ;; if >1 C-u is used, save the specified value for future use.
  (if (> (prefix-numeric-value current-prefix-arg) 4)
      (setq dp-gdb52-cmd-name gdb-cmd))
  (let ((gdb-command-name (or gdb-cmd dp-gdb52-cmd-name)))
    (call-interactively 'gdb)))


(defvar dp-gdb-sudo-history '()
  "History for commands run with `gdb-sudo' or `gdb-cf'.")
(defvar dp-gdb-sudo-run-dir nil
  "Change to this dir, if non nil, before executing`dp-gdb-sudo-cmd-name'.")

(defvar dp-gdb-sudo-cmd-name "sudo-gdb"
  "Use this command to get an sudo'd gdb session.")

(defun gdb-sudo (gdb-cmd)
  "Run gdb with sudo.
With prefix arg prompt for gdb program name.
With prefix arg more than once, remember the gdb program for the remainder
of the Emacs session."
  (interactive (list (if current-prefix-arg
			 (read-from-minibuffer "gdb command: " 
					       dp-gdb-sudo-cmd-name)
		       dp-gdb-sudo-cmd-name)))
	
  ;; if >1 C-u is used, save the specified value for future use.
  (if (> (prefix-numeric-value current-prefix-arg) 4)
      (setq dp-gdb-sudo-cmd-name gdb-cmd))
  (let ((gdb-command-name (or gdb-cmd dp-gdb-sudo-cmd-name)))
    (when dp-gdb-sudo-run-dir
      (cd dp-gdb-sudo-run-dir))
    (call-interactively 'gdb)))

(defun dp-distribute-dir (dir globs)
  "Distribute dir over glob-list."
  (let* ((glob-list (split-string globs))
	 (dir-list (make-list (length glob-list) dir)))
    (dp-string-join (mapcar* (lambda (dir glob)
			       (concat dir "/" glob))
			     dir-list
			     glob-list)
		    " ")))

(defun dp-dir-grep (dir glob &optional regexp)
  "Grep dir+glob regexp."
  (if current-prefix-arg
      (setq dir (read-directory-name "dir: "  
				     nil dir t)
	    glob (read-from-minibuffer "glob: " glob)))
		 
  (let* ((pat (or regexp
		  (read-from-minibuffer "egrep regexp: " (symbol-near-point))))
	 (cmd (format "egrep -n -i '%s' %s" 
		      pat 
		      (dp-distribute-dir dir glob))))
    ;;(dmessage "grep cmd>%s<" cmd)
    (grep cmd)))

(defvar dp-lgrep-globs '("~/lisp/dp*.el" "~/lisp/custom.el" "~/lisp/init.el")
  "Lisp files of most interest.
@todo make this a defcustom list o' strings.")

(defvar dp-lgrep-lesser-globs '("~/.go.emacs" "~/lisp/devel/*.el")
  "Lisp files of less interest.
@todo make this a defcustom list o' strings.")  

; (defun lgrep-old (&optional regexp)
;   "Grep my lisp dir."
;   (interactive)
;   (dp-dir-grep "~/lisp" "dp*.el custom.el init.el" regexp))

(defvar dp-grep-history '())

(defun dp-grep-lisp-files (command-args &optional lesser-globs-too-p)
  "Grep my lisp dir, or more precisely, files in `dp-lgrep-globs'.
LESSER-GLOBS-TOO-P says to grep files in `dp-lgrep-lesser-globs' as well. "
  (interactive
   (list (read-shell-command
	  (format "lgrep (lisp%s globs will be appended): "
                  ;; Can't use lesser-globs-too-p here.
                  ;; Interactive is who will set it.
                  (if current-prefix-arg
                      " (and lesser)"
                    ""))
	  (format "egrep -n -i -e %c%s%c "
                  ?\'
                  (dp-get--as-string--region-or...)
                  ?\')
	  'dp-grep-history)
         current-prefix-arg))
  (setq command-args 
        (format "%s %s" 
                command-args 
                (dp-string-join (append dp-lgrep-globs
                                        (and lesser-globs-too-p
                                             dp-lgrep-lesser-globs)))))
  (save-some-buffers)
  (grep command-args))

(dp-defaliases 'lgrep 'dp-grep-lisp-files)

(defvar dp-cedet-grep-find-history '())
(defvar dp-cedet-grep-find-dir "/home/davep/lisp/contrib/site-packages/cedet/")
(defvar dp-cedet-grep-find-sans-svn-args 
  "\\( -type d -name '.svn' -prune \\) -o -type f -name '*.el'")


(defun dp-cedet-grep-find (command)
  (interactive 
   (list (read-shell-command
          "grep-find(cedet/...): "
	  (format "%s %c%s%c "
                  (concat (replace-in-string 
                           grep-find-command 
                           "find \\(\\.\\) "
                           (concat "find " 
                                   dp-cedet-grep-find-dir
                                   " "
                                   dp-cedet-grep-find-sans-svn-args
                                   " ")))
                  ?\"
                  (dp-get--as-string--region-or...)
                  ?\")
	  'dp-cedet-grep-find-history)))
  (grep-find command))

(dp-safe-alias 'dpcgf 'dp-cedet-grep-find)


(defvar dp-rcgrep-command "rcgrep -- -n -e \"%s\""
  "How to call my rcgrep function.
It greps through all of my current rc files.")

;; XXX @todo FINISH!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
(defun dp-build-rcgrep-command ()
  (format dp-rcgrep-command (dp-get--as-string--region-or...)))


(defun rcgrep (&optional command-args )
  (interactive)
  (let ((grep-command dp-rcgrep-command))
    (call-interactively 'grep)))

(defvar dp-use-flags-grep-root "/usr/portage/profiles"
  "Where we grep for use flags.")

(defvar dp-use-flags-grep-args "")

(defun use-grep (command-args)
  "Grep for Gentoo use flags in /usr/portage/profiles ..."
  (interactive "sreg-exp: ")
  (setq command-args (format "%s %s" 
			     command-args 
			     dp-use-grep-args))
  (save-some-buffers)
  (cd "dp-use-flags-grep-root")
  (grep-find command-args))

(defun dp-notes-grep ()
  "Grep notes files for PAT."
  (interactive)
  (dp-dir-grep dp-note-base-dir "*"))
(defalias 'ng 'dp-notes-grep)

(defun dp-daily-notes-grep ()
  "Grep the daily notes files for PAT."
  (interactive)
  (dp-dir-grep dp-note-base-dir "daily-*"))
(defalias 'dng 'dp-daily-notes-grep)

(defun dp-search-file-re (search-re)
  (interactive)
  (dmessage "sfe: re>%s<" search-re)
  (let ((opoint (point)))
    (goto-char (point-min))
    (if (re-search-forward search-re nil t)
        (progn
          (goto-char (match-beginning 1))
          (dp-push-go-back "Found re" 
                           (dp-mk-marker opoint)))
      (goto-char opoint))))

(defun* dp-search-re-with-wrap (regexp &optional point limit error save
                               (search-fun 're-search-forward))
  "Search forward from point, and then wrap if no match."
  (interactive)
  ;;(dmessage "hi!  who called me?" how-about-a-stack-trace???)
  (let ((point (or point (point)))
        (opoint (point))
        p2)
    (goto-char point)
    (if (eq 'not-found
            (if (funcall search-fun regexp limit (not error))
                (goto-char (match-beginning 0))
              (message "wrapped...")
              (goto-char (point-min))
              ;; Only search up to where we started.
              (unless (re-search-forward regexp point (not error))      
                (message "%s not found." regexp)
                (goto-char opoint)
                'not-found)))
        ()
      (dp-push-go-back "dp-search-re-with-wrap" (dp-mk-marker opoint))
      (isearch-update-ring regexp 'regexp))))

(defun dp-search-with-wrap (string &optional point limit error save)
  (dp-search-re-with-wrap string point limit error save 'search-forward))

(defun dp-switch-to-buffer0 (bufname &optional find-word-p other-window-p)
  "Switch buffers and optionally search for the word at point in original buffer."
  (interactive "Bdp:Switch-to-buf: \nP")
  (let* ((find-word-p (or find-word-p 
                          (and-boundp 'dp-c-auto-find-symbol dp-in-c)))
         (word-regexp (if find-word-p
                          (format "\\<\\(%s\\)\\>" 
                                  (symbol-near-point)))))
    (cond
     ;; Check for and handle explicit requests first.
     (other-window-p 
        ;(switch-to-buffer-other-window bufname)
        (dp-display-buffer-select bufname nil nil nil other-window-p))
     ;; Now try to be `clever.'
     ((dp-display-buffer-if-visible bufname))
     ((unless (dp-pop-up-window-buffer-p bufname))
      (switch-to-buffer bufname))
     (t (switch-to-buffer bufname)))
    (when find-word-p
      (dp-search-re-with-wrap word-regexp))))

(defun dp-switch-to-buffer (bufname &optional find-word-p)
  "Switch to another buffer *my* way.
If `current-prefix-arg` is 0 then force file to be in the current window.
Otherwise, if `current-prefix-arg` is non-nil then don't search for the
current word in the switched-to buffer."
  (interactive "Bdp:Switch-to-buf: \nP")
  (if (eq find-word-p 0)
      (switch-to-buffer bufname)
    (dp-switch-to-buffer0 bufname find-word-p)))

(defun dp-switch-to-buffer-other-window (bufname &optional find-word-p)
  (interactive "Bdp:Switch-to-buf: \nP")
  (dp-switch-to-buffer0 bufname find-word-p 'other-window))

(defun dp-goto-marker (marker)
  (interactive)
  ;;(dp-display-buffer-select (marker-buffer marker))
  (dp-visit-or-switch-to-buffer (marker-buffer marker))
  (goto-char marker))

(defun dp-find-similar-file (&optional prompt file-name)
  "@toto: ? Actually make this do something? Prompt for and visit a file
  whose name is \"similar\" to FILE-NAME's.
Similar here means the same file-name with a user specified completion."
  (interactive)
  (setq-ifnil prompt "file-name: "
              file-name (buffer-file-name))
  (find-file (read-file-name prompt nil nil nil 
                             (file-name-sans-extension 
                              (file-name-nondirectory file-name)))))

(defun dp-add-eof-spacing ()
  "Add spacing to EOF to ensure at least one blank line."
  (let (add-str)
    (goto-char (- (point-max) 2))
    (unless (looking-at "\n\n")
      (if (looking-at ".[^\n]")
	  (setq add-str "\n\n")
	(setq add-str "\n")))
    (goto-char (point-max))
    (if add-str
	(insert add-str))))
  
(defun dpmisc ()
  "Edit dpmisc.el"
  (interactive)
  (find-file "~/lisp/dpmisc.el"))
(defalias 'dp-misc 'dpmisc)

(defun dpmisc2 ()
  "Edit dpmisc.el in another window."
  (interactive)
  (dp-find-file-other-window "~/lisp/dpmisc.el"))
(defalias 'dp-misc2 'dpmisc2)

(defun dpmacs ()
  "Edit dpmacs.el"
  (interactive)
  (find-file "~/lisp/dpmacs.el"))
(defalias 'dp-macs 'dpmacs)

(defun dpmacs2 ()
  "Edit dpmacs.el"
  (interactive)
  (dp-find-file-other-window "~/lisp/dpmacs.el"))
(defalias 'dp-macs2 'dpmacs2)

(defun dp-last-edit-position (undo-list)
  "Determine position of last edit."
  (interactive)
  (if (eq buffer-undo-list t)
      (error "No undo information in this buffer"))
  (let ((ul undo-list)
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
	       ((stringp undo-car) (setq pos (abs (cdr undo-item)))) ; deletion
	       ((eq undo-car t)  nil))	; mod time change?
	      (if (not pos)
                  ()
                  ;(message "NO: ui: %s, uc: %s, pos: %s" undo-item undo-car pos)
                ;(message "YES: ui: %s, uc: %s, pos: %d" undo-item undo-car pos)
		(throw 'done (cons pos ul))))
	    nil))
    stat))

(dp-deflocal dp-undo-list-copy '()
  "My copy so I can go walk the list w/o trashing the original.")

(defun dp-goto-last-edit (&optional reset-p)
  "Goto position of last edit. RESET-P says to keep reset the walk after
  a non-consecutive command."
  (interactive "P") 
  (setq reset-p (not reset-p))
  (if (eq buffer-undo-list t)           ; Interesting way to be empty.
      (message "No undo list.")
    (let* ((pos (dp-last-edit-position
                 (if (and reset-p (not (dp-consecutive-command-p)))
                     buffer-undo-list
                   (dmessage "faux-undo continuing...%s" (if reset-p
                                                             ""
                                                           " forcibly."))
                   dp-undo-list-copy))))
      (if (not pos)
          (message "No location found in undo info.")
        (goto-char (car pos))
        ;; `dp-last-edit-position' may have had to examine >1 item in order
        ;; to find a position.  So we let it return its next position.  We
        ;; only need to wrap when we see our copy go to nil.
        (setq dp-undo-list-copy (cdr pos))))))

(defun dp-bracketed-buffer-substring (open close 
					   &optional left-limit right-limit)
  "Find and return substring that is bracketed by open and close."
  (interactive "sopen: \nsclose: ")
  (setq-ifnil left-limit (line-beginning-position)
	      right-limit (line-end-position))
  (let (start end)
    ;; @todo BUG: only works if at start of open or completly past it
    (unless (looking-at open)
      (re-search-backward open left-limit))
    (setq start (1+ (match-end 0)))
    (re-search-forward close right-limit)
    (setq end (1- (match-beginning 0)))
    (buffer-substring start end)))

(defun dp-beginning-of-line-if-not-bolp ()
  (interactive)
  (if (and (not defining-kbd-macro)
           (bolp))
      'dp-consecutive-key-skip
    (beginning-of-line)))

(defun dp-end-of-line-if-not-eolp ()
  (interactive)
  (if (eolp)
      'dp-consecutive-key-skip
    (end-of-line)))

(defvar dp-consecutive-key-command-initial-point nil
  "The value of (point) when the command sequence began.")

(defun dp-consecutive-key-command (cmd-cursor cmd-list consecutive-command
                                       &optional recursing-p)
  "Execute a command that changes based on the number of consecutive keystrokes that has invoked it.
CMD-CURSOR: Initial item in the list, usually the beginning. Should this be
optiona and default to CMD-LIST?
CMD-LIST: List of commands to cycle through.
CONSECUTIVE-COMMAND: The command which triggers the consecutive cycling, like
`dp-brief-home'.
E.g. home->beginning_of_line, 
     home*2->beginning-of-screen, 
     home*3->beginning-of-buffer.
When beginning a sequence, (point) is saved.  This can be pushed onto
`dp-go-back-stack' by one of the commands in the sequence."
  (interactive)
  ;;  (dmessage "last-command>%s<, recursing-p>%s<" last-command recursing-p)
  (dp-set-zmacs-region-stays t)
  ;; is the command sequence continuing or beginning?
  (if (or (eq last-command consecutive-command)
          recursing-p)
      (set cmd-cursor (cdr-safe (symbol-value cmd-cursor)))
    (setq dp-consecutive-key-command-initial-point (point-marker))
    (set cmd-cursor cmd-list))
  (let* ((cmd-el (symbol-value cmd-cursor))
         (cmd (car-safe cmd-el))
         (args (unless (dp-lambda-p cmd)
                 (cdr-safe cmd))))
    (when cmd
      ;;(dmessage "cmd>%s<" cmd)
      (when (and (eq (apply cmd args)
                     'dp-consecutive-key-skip)
                 (not recursing-p))
        (dmessage "recursing")
        ;;(setq last-command 'dp-consecutive-key-command)
        (dp-consecutive-key-command cmd-cursor 
                                    cmd-list consecutive-command
                                    'RECURSING-P)))))
(defvar dp-brief-home-command-list
  '(beginning-of-line
    (lambda () (move-to-window-line 0))
    (lambda () 
      (dp-push-go-back "home^3" dp-consecutive-key-command-initial-point)
      (dp-beginning-of-buffer 'no-save-pos)))
  "Commands to run based on number of consecutive keys pressed.")

(defvar dp-brief-home-command-ptr dp-brief-home-command-list
  "Points to next command to run during a `dp-brief-home' consecutive
  key-sequence command.")

(defun dp-brief-home ()
  "Go bol, bow, bof."
  (interactive)
  (dp-consecutive-key-command 'dp-brief-home-command-ptr
			      dp-brief-home-command-list
			      'dp-brief-home))

(defvar dp-brief-end-command-list
  '(end-of-line
    (lambda () (move-to-window-line -1))
    (lambda () 
      (dp-push-go-back "end^3" dp-consecutive-key-command-initial-point)
      (dp-end-of-buffer 'no-save-pos)))
  "Commands to run in sequence based on number of consecutive keys pressed.")

(defvar dp-brief-end-command-ptr dp-brief-end-command-list
  "Command to run.")

(defun dp-brief-end ()
  "Go eol, eow, eof."
  (interactive)
  (dp-consecutive-key-command 'dp-brief-end-command-ptr
			      dp-brief-end-command-list
			      'dp-brief-end))

(defun dp-func-this-buffer-with-conf (&optional func prompt)
  "Perform FUNC after asking for confirmation."
  (interactive)
  (if (y-or-n-p (or prompt (format "Really %s? " func)))
      (funcall func)))

(defun dp-push-go-back&call-interactively (func &optional record-flag keys
                                           reason)
  (interactive)
  (dp-push-go-back reason (point-marker))
  (condition-case error
      (call-interactively func record-flag keys)
    (error
     ;; Undo in case of error.
     (dp-pop-go-back-ring)
     (message "%s" (car-safe (cdr error))))))

(defun dp-push-go-back&apply (reason func &optional args)
  (interactive)
  (condition-case error
      (let ((pmarker (point-marker)))
	(apply func args)
	(dp-push-go-back (or reason "dp-push-go-back&apply") pmarker))
    (error (message "%s" (car-safe (cdr error))))))

(defun dp-find-function ()
  "Add some useful stuff wrapped about `find-function'."
  (interactive)
  (if (dp-window-dedicated-p)
      (ff2)
    (dp-push-go-back&call-interactively 'find-function nil nil "ff")))

; Consistency w/other functions which can use other windows.
(dp-defaliases 'ff0 'ff. 'ff 'dp-find-function) 

(defun dp-find-function2 ()
  "Push a go-back and then `find-function-other-window'."
  (interactive)
  (dp-push-go-back&call-interactively 'find-function-other-window 
                                      nil nil "ff2"))
(dp-defaliases 'ff2 'dp-find-function2)

(defun dp-find-variable ()
  (interactive)
  (dp-push-go-back&call-interactively 'find-variable nil nil "fv"))
(dp-defaliases 'fv 'fv. 'fv1 'fv0 'fv-same  'dp-find-variable)

(defun fv2 ()
  (interactive)
  (dp-push-go-back&call-interactively 'find-variable-other-window 
                                      nil nil "fv2"))

(defun dp-ff-key (key &optional same-window-p)
  "Do a `find-function-on-key' but with my kind of window prefs."
  (interactive "kFind function on key: \nP")
  (dp-push-go-back "dp-ff-key")
  ;; `find-function-on-key' unconditionally uses the other window.
  (let ((o-ffow (symbol-function 'find-function-other-window)))
    (flet ((find-function-other-window (&rest rest)
             (if same-window-p
                 (apply 'find-function rest)
             (apply o-ffow rest))))
      (dp-push-go-back "dp-ff-key-->find-function-on-key")
      (find-function-on-key key))))
             
(defun dp-info (&optional file same-window-p)
  (interactive)
  (let* ((my-Cu* (or (Cu0p)))
         (same-window-p (or same-window-p my-Cu*))
         (current-prefix-arg (if my-Cu* nil current-prefix-arg)))
    (unless same-window-p
      (when (one-window-p 'NOMINIBUFFER)
        (split-window))
      (other-window 1))
    (call-interactively 'info)))

(defalias 'info2 'dp-info)

(defun info1 ()
  (interactive)
  (dp-info nil 'SAME-WINDOW-P))

(defalias 'info0 'info1)
;; e for eye which sounds like i which starts info.
(global-set-key [(control h) (control e)] 'info1)

(defun dp-make-extent0 (buffer-or-string from to id-prop &rest props)
  "Make an extent.  Give it a property of ID-PROP for easy identification.
Also give it the property 'dp-extent with value t.
In addition, add the PLIST from PROPS to the extent."
  (let ((extent (make-extent from to buffer-or-string))
	(prop-list (append (list id-prop t 
                                 'dp-extent-id id-prop 
                                 'dp-extent t) 
                           props)))
    ;; put a unique property on every extent we make for easy,
    ;; positive identification of all of our extents
    ;;(dmessage "props>%s<" props)
    (set-extent-properties extent prop-list)
    extent
    ))

(defun dp-make-extent (from to id-prop &rest props)
  ;;(dmessage "dme: props>%s<" props)
  (apply 'dp-make-extent0 (current-buffer) from to id-prop props))

(defun dp-extent-with-property-exists (property &optional from to object)
  "Return \(list prop-val\) if the current buffer contains an extent with 
property PROPERTY, otherwise nil.
NB a PROPERY with value of nil results in \(nil\), not nil."
  (interactive)
  (map-extents (function
                (lambda (ext arg)
                  (list (extent-property ext property))))
	       object from to nil nil property))

(defun dp-delete-extents-from (obj from to &rest props)
  "Delete any extent in [FROM, TO) that has a non-nil valued property in PROPS.
PROPS is a list, each element of which can be a property name or a cons of
property name and value to look for."
  (map-extents (function
                (lambda (ext maparg)
                  (catch 'deleted
                    ;; Check all props in PROPS.
                    (mapc (function
                           (lambda (prop-in)
                             (let ((isa-cons (consp prop-in))
                                   prop val xp-val)
                               (if isa-cons
                                   (setq prop (car prop-in)
                                         val (cdr prop-in))
                                 (setq prop prop-in))
                               (when (and (setq xp-val (extent-property ext prop))
                                          (or (not isa-cons)
                                              (equal val xp-val)))
                                 (delete-extent ext)
                                 (setq ext nil)
;                                (dp-message-no-echo 
;                                 "%s"
;                                 (dp-dump-extent-list 
;                                  (extent-list obj from to nil 'dp-extent t)))
                                 ;; @todo ??? keep going and get 'em all?
                                 ;; Why? If the extent is deleted, it's gone.
                                 (throw 'deleted t)
                                 ))))
                          maparg))
                  nil))
               obj                      ; buffer or string
               from to                  ; from, to
               ;; maparg: List of properties any one of which, by its
               ;; existence, sill cause the deletion of the extent.
               props                    ; list of prop or (prop . val)
               nil                      ; flags
               nil                      ; prop
               nil                      ; value if prop given
               ))

(defun dp-delete-extents (from to &rest props)
  (apply 'dp-delete-extents-from 
	 (append (list nil from to) props)))

(defun* dp-clear-all-dp-extents (&key (key-prop 'dp-extent) (key-prop-val t)
                              obj (from (point-min))
                              (to (point-max)))
  "Clear all 'dp-extent type extents."
  (dp-delete-extents-from obj from to key-prop))

(defun dp-delete*ALL*extents (&optional from to obj)
  (map-extents (function
                (lambda (ext maparg)
                  (delete-extent ext)))
	       obj from to))

(defun dp-get-next-search-property (secondary-key-p &optional then else)
  "Search for next dp extent containing a particular key.
Search keys may be specified in THEN and ELSE. The key to use is predicated
on the value of SECONDARY-KEY-P. 
if SECONDARY-KEY-P is non-nil, then use THEN
else use ELSE.
THEN defaults to dp-extent-search-key2.
ELSE defaults to dp-extent-search-key."
  (interactive)
  (if secondary-key-p
      (or then 'dp-extent-search-key2)
    (or else 'dp-extent-search-key)))

;;; 
;;; !<@todo LOTS of this extent stuff needs to be re-written.  It was hacked
;;; out pretty quickly.
;;;
(defun dp-map-next-extents (func pos &rest args)
  "Map FUNC over extents from POS.  Scans thru extents in `next-extent' order.
Functions can return a cons \('done-p . real-ret-val\) to exit the mapping."
  (let ((ext (extent-at (setq pos (or pos (point)))))
        ret)
    ;; loop until we see a ret of ('done-p . real-ret-val)
    (while (and (not (eq (car-safe ret) 'done-p)) 
                ext)
      (setq ret (apply func ext args))
      (when (not (eq (car-safe ret) 'done-p))
        (setq ext (next-extent ext))
        ;; Move to next extent, ignoring any extents that begin before POS.
        (while (and ext
                    (< (extent-start-position ext) pos))
          (setq ext (next-extent ext)
                pos (extent-start-position ext)))))
    (when ret
      (cdr ret))))

(defun dp-map-previous-extents (func pos &rest args)
  "Map FUNC over extents from POS.  Scans thru extents in `previous-extent' order.
Functions can return a cons \('done . real-ret-val\) to exit the mapping."
  (let ((ext (extent-at (setq pos (or pos (point)))))
        ret)
    ;; loop until we see a ret of ('done-p . real-ret-val)
    (while (and (not (eq (car-safe ret) 'done-p)) 
                ext)
      (setq ret (apply func ext args))
      (when (not (eq (car-safe ret) 'done-p))
        (setq ext (previous-extent ext))
        ;; Move to prev extent, ignoring any extents that end after POS.
        (while (and ext
                    (> (extent-end-position ext) pos))
          (setq ext (previous-extent ext)))))
    (when ret
      (cdr ret))))

(defun dp-find-next-extent-with-prop (starting-here prop 
                                      &optional value at-point-p
                                      starting-extent)
  "Find the next extent with the desired properties.
If AT-POINT-P is non-nil, then we check to see if the extent at point has the
desired properties. If so, then a cons is returned to indicated that special
case. Otherwise the next extent is return or nil if there are no more
matching ones."
  (let* ((exts (dp-extents-at-with-prop prop value starting-here))
         (ext (car-safe exts)))
    (if (and at-point-p
             (not (eq starting-extent ext))
             ext)
        (cons 'at ext)
      (dp-map-next-extents (function
                            (lambda (ext prop &optional value)
                              (when (and (not (eq starting-extent ext))
                                         (memq prop (extent-properties ext))
                                         (> (extent-start-position ext)
                                            starting-here))
                                ;; if there's a value then it must match
                                (if value
                                    (when (dp-extent-prop-match ext prop 
                                                                (cdr value))
                                      (cons 'done-p ext))
                                  (cons 'done-p ext)))))
                           starting-here
                           prop
                           value))))

(defun* dp-goto-next-matching-extent (prop &optional val 
                                      (at-point-p 'at-point))
  (let* ((this-extent (dp-find-next-extent-with-prop (point)
                                                     prop val
                                                     at-point-p))
         start)
    ;;(dmessage "this-extent: %s" this-extent)
    ;;Did we find an extent at the current position?
    (when this-extent
      (setq start
            (if (and this-extent (not (consp this-extent)))
                ;; No. Since we used 'at-point, which returns a cons if an
                ;; extent is found at the current value of point, this means
                ;; that we had to move and so this is the extent we're
                ;; interested in.  Or nil, so we return that to indicate no
                ;; more extents of this type.
                this-extent
              ;; We were in a matching extent. Move out of it and look again.
              (dp-find-next-extent-with-prop (1+ (extent-end-position 
                                                  (cdr this-extent)))
                                             prop val
                                             'at-point)))
      (and (consp start)
	   (setq start (cdr start)))
      (when (and (extentp start)
		 start)
	(goto-char (extent-start-position start))))))

(defun dp-find-previous-extent-with-prop (starting-here prop 
                                          &optional value at-point-p
                                          starting-extent)
  (let* ((exts (dp-extents-at-with-prop prop value starting-here))
         (ext (car-safe exts)))
    (if (and at-point-p
             (not (eq starting-extent ext))
             ext)
        (cons 'at ext)
      (dp-map-previous-extents 
       (function
        (lambda (ext prop &optional value)
          (when (and (not (eq starting-extent ext))
                     (memq prop (extent-properties ext))
                     (< (extent-end-position ext)
                        starting-here))
            ;; if there's a value then it must match
            (if value
                (when (equal (cdr value) 
                             (extent-property ext prop))
                  (cons 'done-p ext))
              (cons 'done-p ext)))))
       starting-here
       prop
       value))))

(defun dp-next-dp-extent-from-point (arg)
  (interactive "P")
  (let* ((search-prop (dp-get-next-search-property (equal '(4) arg)))
         (this-extent (dp-find-next-extent-with-prop (point)
                                                     search-prop nil 
                                                     'at-point))
         search-val)
    ;;(dmessage "this-extent: %s" this-extent)
    ;; Did we find an extent at the current position?
    (if (and this-extent (not (consp this-extent)))  ;NO
        ;; No. This means that we had to move and so this is the extent we're
        ;; interested in.  Or nil, so we return that to indicate no more
        ;; extents of this type.
        this-extent
      ;; Yes.  This means we want the next matching extent.
      (when (and this-extent
                 (setq this-extent (cdr this-extent))
                 (setq search-val (extent-property this-extent search-prop)))
;;                 (setq this-extent (next-extent this-extent))) ;Move along...
        (setq this-extent 
              (dp-find-next-extent-with-prop 
               (extent-start-position this-extent) 
               search-prop 
               (cons 'unused-car search-val) t this-extent))
        (if this-extent
            (if (consp this-extent)
                (cdr this-extent)
              this-extent)
          (message "No next extent with %s == %s" search-prop search-val)
          (ding)
          nil)))))

(defun dp-previous-dp-extent-from-point (arg)
  (interactive "P")
  (let* ((search-prop (dp-get-next-search-property (equal '(4) arg)))
         (this-extent (dp-find-previous-extent-with-prop 
                       (point) search-prop nil 'at-point))
         search-val)
    ;;(dmessage "this-extent: %s" this-extent)
    ;;Did we find an extent at the current position?
    (if (and this-extent (not (consp this-extent)))  ;NO
        ;;No. This means that we had to move and so this is the extent we're
        ;;interested in.  Or nil, so we return that to indicate no more
        ;;extents of this type.
        this-extent
      ;;Yes.  This means we want the previous matching extent.
      (when (and this-extent
                 (setq this-extent (cdr this-extent))
                 (setq search-val (extent-property this-extent search-prop)))
        ;; (setq this-extent (previous-extent this-extent))) ;Move along...
        (setq this-extent 
              (dp-find-previous-extent-with-prop 
               (extent-start-position this-extent) 
               search-prop 
               (cons 'unused-car search-val) nil this-extent))
        (if this-extent
            (if (consp this-extent)
                (cdr this-extent)
              this-extent)
          (message "No previous extent with %s == %s" search-prop search-val)
          (ding)
          nil)))))

(defun dp-goto-next-dp-extent-from-point (arg)
  (interactive "P")
  (let ((extent (dp-next-dp-extent-from-point arg))
        col)
    (when extent
      (dp-push-go-back "dp-goto-next-dp-extent-from-point")
      (setq col (current-column))
      (goto-char (extent-start-position extent))
      (move-to-column col))))

(defun dp-goto-previous-dp-extent-from-point (arg)
  (interactive "P")
  (let ((ext (dp-previous-dp-extent-from-point arg))
        col)
    (when ext
      (dp-push-go-back "dp-goto-previous-dp-extent-from-point")
      (setq col (current-column))
      (goto-char (extent-start-position ext))
      (move-to-column col))))

(defun dp-next-dp-extent (&optional extent-prop)
  (interactive "Sprop: ")
  (catch 'up
    (map-extents (function
                  (lambda (ext maparg)
                    (and maparg
                         (throw 'up (goto-char (extent-start-position ext))))))
                 nil
                 (1+ (point)) 
                 (point-max) 
                 extent-prop
                 'start-in-region 
                 'dp-extent t)))

(defun dp-beginning-of-toppest-ext (&optional pos prop prop-val)
  (interactive "d\nSprop? \nXprop-val? ")
  (loop for e in (dp-extents-at-with-prop prop prop-val pos)
    minimize (extent-start-position e)))
  
(defun dp-goto-beginning-of-toppest-ext (&optional pos prop prop-val)
  (interactive "d\nSprop? \nXprop-val? ")
  (goto-char (or (dp-beginning-of-toppest-ext pos prop prop-val)
                 (point))))

(defun dp-hide-excluding (&optional pos prop prop-val)
  "Hide parts of the buffer except specified extents."
  (interactive)
  (setq-ifnil pos (point)
              prop 'dp-extent-search-key
              prop-val (cons 'unused 'dp-colorized-region))
  (let* ((estart pos) eend at-extents
         (p-val (cdr-safe prop-val))
         (pred (if prop-val
                   (function
                    (lambda (ext)
                      ;; prop and val
                      (and (memq prop (extent-properties ext))
                           ;;(dmessage "past memq")
                           ;;(dmessage "p-val: %s, ep: %s" 
                           ;;          p-val (extent-property ext prop))
                           (equal p-val (extent-property ext prop)))))
                 (function
                  (lambda (ext)
                    (memq prop (extent-properties ext)))))))
    (fset 'pred pred)
         (when (setq at-extents 
                     (dp-extents-at-with-prop prop prop-val pos))
           (setq estart
                 (1+ (loop for e in at-extents
                       maximize (extent-end-position e)))))
         (dp-map-next-extents
          (function
           (lambda (ext)
             (when (pred ext)
               (let ((es (extent-start-position ext))
                     (ee (extent-end-position ext)))
                 (cond
                  ((and (< es estart) (> ee estart) (setq estart ee)))
                  ((< ee estart) nil)      ;nop/continue
                  (t (dmessage "hiding from %s to %s" estart (- es 1))
                     (dp-hide-region estart (- es 1))
                     (setq estart (1+ ee))))))
             nil))
          pos)
         (dp-hide-region estart (point-max))))

(defun dp-in-write-protected-region (&optional pos)
  "Determine if POS (def point) is in a write protected region."
  (dp-extents-at-with-prop 'dp-write-protected-region nil pos))
  
(defun dp-write-protect-region (beg end)
  (interactive "r")
  (dp-make-extent beg end 'dp-write-protected-region 'read-only t 
                  'face 'dp-wp-face 'dp-extent t 
                  'dp-write-protected-region t 'priority 1))
(defalias 'dp-ro-region 'dp-write-protect-region)

(defun dp-wp-buffer-or-region ()
  (interactive)
  (if (dp-mark-active-p)
      (dp-write-protect-region (point) (mark))
    (dp-write-protect-region (point-min) (point-max))))

;; When called w/o region, we get the whole buffer.
;; If this turns out to be inconvenient, we can:
;; 1) Set point and mark to beginning and end of file.
;; 2) Pass in a flag which forces whole file.
;; r* rw, ro
;; w* wr, wp
(dp-defaliases 'dp-ro-buffer 'dp-wp-buffer 
               'dp-r*-bor 'dp-w*-bor 'dp-wp-buffer-or-region)

(defun* dp-unextent-region (region-id &optional beg end buf-or-string
                            (region-bounder 'buffer-p)
                            (verbose-p nil))
"REGION-ID: is a lisp expr: prop-name symbol or \(prop-name . prop-val).
The expr is `eval'd when read. Quoting (') may be required.
The property name prop-name is examined. If it exists (symbol) or exists and
has value \(cdr region-id), then that extent is matched."
  (interactive "sregion-id(lisp expr): ")
  ;; Region first.
  (when verbose-p
    (message "dp-unextent-region: region-id: %s" region-id))
  (let* ((check-val-p (consp region-id))
         (prop (if check-val-p (car region-id) region-id))
         (prop-val (cdr-safe region-id))
         (num-deleted 0)
         (be (dp-region-or... :beg beg :end end :bounder region-bounder)))
    (when be
      (mapcar-extents (lambda (ext)     ; Do this...
                        (incf num-deleted)
                        (when verbose-p
                          (message "deleting extent>%s<" 
                                   (dp-pretty-format-extent ext "; " nil)))
                        (delete-extent ext))
                      (lambda (ext)           ; ...if this is non-nil
                        (or (not check-val-p)  ; Do all extents.
                            (equal prop-val  ; Or just these
                                   (extent-property ext prop))))
                      buf-or-string     ; Where the extents live.
                      (car be) (cdr be)
                      nil
                      prop))
    (message "%s %s deleted." num-deleted 
             (dp-pluralize-num num-deleted nil nil "extent"))))

(defun dp-rw-region (&optional beg end)
  (interactive)
  (dp-unextent-region 'dp-write-protected-region beg end))
(defalias 'dp-wr-region 'dp-rw-region)
(defun dp-rw-buffer ()
  (interactive)
  (dp-rw-region (point-min) (point-max)))
(defalias 'dp-wr-buffer 'dp-rw-buffer)

(defun dp-toggle-region-writable-status (&optional beg end)
  (interactive)
  "Toggle a region as writable or read only (write protected)."
  (if (and (not beg) (not end) (not (dp-mark-active-p)))
      (if (dp-in-write-protected-region beg)
          (dp-rw-region)
        (call-interactively 'toggle-read-only)
        (dp-colorize-buffer-if-readonly nil t))
    (let* ((b-e (dp-region-or... :bounder 'buffer-p))
           (beg (car b-e))
           (end (cdr b-e)))
      (if (dp-in-write-protected-region beg)
          (dp-rw-region beg end)
        (dp-ro-region beg end)))))

(defalias 'dp-rw/ro-region 'dp-toggle-region-writable-status)

(dp-deflocal-permanent dp-colorize-region-default-color-index 0
  "Name says it all.")

(dp-deflocal-permanent dp-colorize-region-default-priority 7
  "Name says it all.")

(defvar dp-colorize-region-roll-colors t
  "Should `dp-colorize-region' increment the color after each invocation.")

(defvar dp-colorize-region-num-colors (length dp-faces))

(dp-deflocal dp-dont-overwrite-existing-colors nil
  "*What more can I say?")

(defun dp-invisible-color-p (color)
  "Return t if COLOR implies invisibility."
  (and color
       (eq color '-)))

(defun dp-colorize-roll-colors (&optional color)
  (interactive)
  (when (not (dp-invisible-color-p color))
    (when color
      (setq dp-colorize-region-default-color-index color))
    (setq dp-colorize-region-default-color-index
          (mod (1+ dp-colorize-region-default-color-index) 
               dp-colorize-region-num-colors))))

(defun dp-invisible-face-p (face)
  (or (memq (car face) '(invisible invis))
      (memq (cdr face) '(invisible invis))))

(defun dp-get-color-and-face (color)
  "Convert COLOR index to colorization color and a face.
COLOR_INDEX can be <=0 or '- to indicate invisibility."
  (let* ((arg (cond
               ((and color (symbolp color)) nil)
               ((not color) dp-colorize-region-default-color-index)
               ((or (and (integerp color)
                         (<= color 0))
                    (eq color '-))
                'invis)
               (t (setq dp-colorize-region-default-color-index
                        (1- color)))))
         (face (cond
                ((and color (symbolp color)) color)
                ((integerp arg) (nth arg dp-faces))
                (t arg))))
    (cons arg face)))

(defun dp-region-is-colorized (from to)
  (dp-extent-with-property-exists 'dp-colorized-region from to nil))

(defun dp-colorize-pluck-color (&optional pos)
  "Grab color of colorized region at \(or pos \(point\)\)"
  (interactive "d")
  (let ((ext-list (dp-extents-at-with-prop 'dp-colorized-region-color-num))
        m)
    (if ext-list 
        (progn
          (setq dp-colorize-region-default-color-index
                (extent-property (car ext-list) 
                                 'dp-colorized-region-color-num))
          (setq m (format "Plucked color index %d." 
                          dp-colorize-region-default-color-index))
          ;; The face doesn't make it to the message area.
          (dp-make-extent0 m 0 (length m) 'dp-colorized-string 
                           'face (cdr (dp-get-color-and-face nil))
                           'duplicable t)
          (message m))
      (message "No colorized region at pos=%s" pos)
      (ding))))
  
(defun dp-colorize-region (color &optional beg end no-roll-colors-p overwrite-p
                           &rest props)
  "COLOR can be an integer index or a symbol representing a face."
  (interactive "P")
  (let* ((beg-end (dp-region-or... :bounder 'line-p))
         (beg (or beg (car beg-end)))
         (end (or end (cdr beg-end)))
         (color-and-face (dp-get-color-and-face color))
         (arg (car color-and-face))
         extent
         (face (cdr color-and-face)))
    ;;(dmessage "beg: %s, end: %s" beg end)
    (setq overwrite-p (or overwrite-p 
                          (not dp-dont-overwrite-existing-colors)))
    (when (or overwrite-p 
              (dp-region-is-colorized beg end))
      (unless (memq 'priority props)
        (setq props 
              (append props 
                      (list 'priority dp-colorize-region-default-priority))))
      (if (dp-invisible-face-p color-and-face)
          (setq face-sym 'invisible
                face-val 'y
                props (append props (list 'read-only t)))
        (setq face-sym 'face
              face-val face))
      (setq extent (apply 'dp-make-extent beg end 
                          'dp-colorized-region
                          'dp-colorized-p t
                          face-sym face-val
                          ;;'invisible 'dp-colorize-region
                          'dp-colorized-region-color-num arg
                          'dp-extent-search-key 'dp-colorized-region
                          'dp-extent-search-key2 (list 'dp-colorized-region arg)
                          props))
      (when (and (not no-roll-colors-p)
                 arg ; ARG nil: called w/specific face, so we can't rotate.
                 (not (symbolp arg))    ; Don't roll when a color is passed in.
                 dp-colorize-region-roll-colors)
        (dp-colorize-roll-colors)))
    extent))

(defun dp-colorize-region-line-by-line (beg end color)
  (interactive "r\np")
  (let ((beginning-of-last-line (save-excursion 
                                  (goto-char end) 
                                  (line-end-position))))
  (goto-char beg)
  (while (<= (point) beginning-of-last-line)
    (dp-colorize-region color (line-beginning-position) (line-end-position)
                        nil nil nil
                        'dp-func 'dp-colorize-region-line-by-line
                        'dp-args (list beg end color))
    (setq color nil)                    ;So we actually roll colors.
    (next-line 1))))
    
(defun dp-set-extent-priority (arg &optional pos prop extents)
  "Put a priority on EXTENTS or the extents at (or POS (point))
with prop if set else 'dp-extent."
  (interactive "Npriority: \nXpos: ")
  (mapc (function
         (lambda (ext)
           (set-extent-property ext 'priority arg)))
        (or extents 
            (dp-extents-at-with-prop (or prop 'dp-extent) 
                                     nil (or pos (point))))))

(defun dp-set-colorized-extent-priority (arg &optional pos extents)
  (interactive "Npriority: \nXpos: ")
  (dp-set-extent-priority arg pos 'dp-colorized-region extents))

(defun dp-uncolorize-region (&optional beg end preserve-current-color-p 
                             region-id)
  "Remove all of my colors in the region. 
The region is determined by `dp-region-or...'."
  (interactive)
  (dp-unextent-region (or region-id 'dp-colorized-region) beg end nil 'line-p)
  (unless preserve-current-color-p
    (setq dp-colorize-region-default-color-index 0)))

;; C-u --> prompt for shrink-wrap and roll colors
;; current-prefix-arg < 0 --> color and prompt
(defun dpcml-get-args ()
  (let* ((pnv (prefix-numeric-value current-prefix-arg))
         (prompt-for-others (and current-prefix-arg
                                 (not (eq current-prefix-arg '-))
                                 (or (< pnv 0)
                                     (listp current-prefix-arg)))))
    (list (read-from-minibuffer "regexp: "  ;regexp
                                nil nil nil 
                                dp-colorize-bracketing-regexps-history)
          (if prompt-for-others
              (read-number "color index: " 'ints-only 1)  ; color
            (cond 
             ((not current-prefix-arg) nil)
             ((eq current-prefix-arg '-) '-)
             (t (abs pnv))))            ;color
          nil                           ;end-regexp
          (and prompt-for-others (y-or-n-p "Shrink-wrap? "))
          (and prompt-for-others (y-or-n-p "Roll colors? ")))))

(defvar dp-colorize-lines-shrink-wrap-p-default t
  "*Should we colorize just the matching text or the entire line?
We make this t by default because it's easy to force a full line match by
wrapping the match string in ^.* & .*$
We also make this a global default so I can change it when the mood strikes.")

(defun* dp-colorize-matching-lines (regexp &optional color end-regexp
                                    (shrink-wrap-p 
                                     dp-colorize-lines-shrink-wrap-p-default)
                                    roll-colors-p non-matching-p
                                    (line-oriented-p t))
  "Colorize lines matching REGEXP.
SHRINK-WRAP-P says to only colorize the exact match. Add ^.* && .*$ to get
the entire line.
END-REGEXP - If given, colorize all lines from REGEXP to END-REGEXP.
See `dpcml-get-args' for details of the following:
COLOR - the color to use. 
ROLL-COLORS-P - make each match a different color.
NON-MATCHING-P - ??? Doesn't seem to be used."
  ;; We use `read-from-minibuffer' so we can use our own history list.
  (interactive (dpcml-get-args))
  (let ((starting-point (point))
        (num-matches 0)
        (pair-matches 0)
        first-match
        match-region
        match-begin
        match-end)
    (catch 'up
      (while (setq match-region 
                   (dp-match-contiguous-lines regexp shrink-wrap-p))
        (setq num-matches (1+ num-matches))
        (unless first-match
          (setq first-match (match-beginning 0)))
        (setq match-begin (car match-region)
              match-end (if (not end-regexp)
                            ;; Coloring newline has issues, so shrink
                            ;; wrapping may result in artifacts.
                            (cdr match-region) 
                          (end-of-line)
                          (if (re-search-forward end-regexp nil t)
                              (progn
                                (setq pair-matches (1+ pair-matches))
                                (if shrink-wrap-p
                                    (match-end 0)
                                  (line-end-position)))
                            (throw 'up nil))))
        (dp-colorize-region color match-begin match-end (not roll-colors-p) nil
                            'dp-func 'dp-colorize-matching-lines
                            'dp-args (list regexp color end-regexp
                                           shrink-wrap-p roll-colors-p))
        ;; Clear color here, so `dp-colorize-region' won't reset its rolled
        ;; color back to our starting color
        (if roll-colors-p
            (setq color nil))
        ;; If we're shrink wrapping the matches, then don't move to the end
        ;; of the line.  This will allow us to highlight any other matches on
        ;; the current line.
        (when (or line-oriented-p (not shrink-wrap-p))
          (end-of-line))))
    (if (not first-match)               ; No matches.
        (progn
          (goto-char starting-point)
          (error (format "no matching lines for re: %s" regexp)))
      (dp-push-go-back "dp-colorize-region" starting-point)
      (goto-char first-match)
      (message "matched %s %s w/regexp: %s" 
               (if end-regexp pair-matches num-matches)
               (if end-regexp "pairs" "lines")
               regexp)
      (unless roll-colors-p
        (dp-colorize-roll-colors color)))))

(defun dp-colorize-matching-lines-from-isearch ()
  "Use the last regexp from the last `isearch-\(for\|back\)ward\(-regexp\)?'."
  (interactive)
  ;;!<@todo Fix this so we can request shrink wrapping of the string.
  ;; The problem is that colors are specified with the prefix arg.
  (call-interactively 'dp-colorize-matching-lines isearch-string))

(defvar dp-colorize-bracketing-regexps-history nil
  "History for `dp-colorize-bracketing-regexps'.")

(defun dp-colorize-bracketing-regexps(color regexp1 regexp2 roll-colors-p)
  "Colorized region [REGEXP1, REGEXP2] with COLOR."
  (interactive (list (prefix-numeric-value current-prefix-arg)
                     (read-from-minibuffer 
                      "beginning regexp: "
                      nil nil nil dp-colorize-bracketing-regexps-history)
                     (read-from-minibuffer 
                      "ending regexp: "
                      nil nil nil dp-colorize-bracketing-regexps-history)
                     (y-or-n-p "roll-colors? ")))
  (dp-colorize-matching-lines regexp1 color regexp2 nil roll-colors-p))
(defalias 'dcbr 'dp-colorize-bracketing-regexps)

(defun dp-goto-next-colorized-region ()
  "Add ability to specify color. This would require us to use the secondary
  search key and the color number."
  (interactive)
  (dp-goto-next-matching-extent 'dp-extent-search-key 
                                '(unused . dp-colorized-region)))

(defun dp-list-minus-eq (list-in elt-in)
  "Delete all instances of ELT-IN from LIST-IN."
  (delq niil (mapcar (function
                      (lambda (elt)
                        (if (eq elt elt-in)
                            nil
                          elt)))
		     list-in)))

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

(defun dp-rotate-and-delq (l-in m)
  (dp-rotate-and-func l-in m 'delq))

(defsubst dp-rotate-to (l-in m)
  "Rotate L-IN s.t. M is the new head."
  (dp-rotate-and-func l-in m))

(defun dp-list-rot (list)
  "Rotate a list left."
  (let ((ret (cdr list)))
    (append ret (list (car list)))))

(defun dp-lineup-comments (begin end)
  "Line up all comments in region to column of the beginning of the region."
  (interactive "*r")
  (let ((comment-column comment-column)
        ;; Use `comment-indent-default' because it doesn't do any fancy mode
        ;; specific things which tend to not use the currently defined
        ;; comment-start stuff.
        (comment-indent-function 'comment-indent-default)
	(endm (set-marker (make-marker) end)))
    (goto-char begin)
    (when (/= 0 (current-column))
      (setq comment-start (current-column)))
    (indent-for-comment)
    (next-line 1)
    (set-comment-column 'align-with-previous)
    (while (<= (point) endm)
      (set-comment-column 'align-with-previous)
      ;;(beginning-of-line)
      ;;(indent-for-comment)
      (next-line 1))
    (setq end nil)))

(defun dp-lineup-assignments (begin end)
  "Line up assignments (blecch) by pretending `=' is the comment character.
!<@todo XXX Make this work for op=
??? Loop over all op aligning for each? = by itself will need to be special."
  (interactive "*r")
  (let ((comment-start (save-excursion
                         (goto-char begin)
                         (dp-c-get-current-token)))
        (comment-end ""))
    (dp-lineup-comments begin end)))

(defun dp-assoc-regexp (key regexp-alist)
  "Find KEY in REGEXP-ALIST, an alist who's keys are regexps.
REGEXP-ALIST is a list of (regexp . whatever).  When matched, the cons
cell is returned."
  (save-match-data
    (dolist (el regexp-alist nil)
      (when (string-match (car el) (format "%s" key))
        (return  el)))))

(defun dp-wildcards-exist (wildcards)
  (let ((matches (file-expand-wildcards wildcards)))
    (if (and (string= (car matches) wildcards) ; Possible non-match
             ;; The pattern was returned unchanged.
             ;; Now see if wildcards were given. If so, this most likely
             ;; means no matches.  I could try to open the returned files
             ;; (since, e.g. a file named file* may actually exist (made by a
             ;; weenie).  assume there was no match and return nil.
             (string-match "[*?]" wildcards))
        ()
      matches)))

(defun dp-search-up-dir-tree (start-dir file-name 
                              &optional top-dir treat-as-globs-p)
  "Search for FILE-NAME up dir tree beginning at START-DIR."
  (if (string-match "/$" start-dir)
      (setq start-dir (substring start-dir 0 -1)))
  (if (and top-dir (string-match "/$" top-dir))
      (setq top-dir (substring top-dir 0 -1)))
  (catch 'found
    (let ((dir-list (split-string start-dir "/"))
          glob
	  path-name)
      (while dir-list
	(setq path-name (format "%s/%s" 
				(dp-string-join dir-list "/")
				file-name))
	;;(dmessage "pn>%s<" path-name)
        (cond
         ((and treat-as-globs-p
               (setq glob (dp-wildcards-exist)))
          glob)
         ((file-exists-p path-name)
	  (throw 'found path-name))
         ((and top-dir
               (string= top-dir (dp-string-join dir-list "/")))
          (throw 'found nil)))
	(setq dir-list (butlast dir-list)))
      nil)))

(defun dp-multi-search-up-dir-tree (start-dir file-names 
                                    &optional top-dir treat-as-globs-p)
  (loop for file-name in file-names
    with ret
    when (setq ret (dp-search-up-dir-tree start-dir file-name top-dir
                                          treat-as-globs-p))
    return ret))

(defun dp-find-util-data-file (result-sym file-name &optional 
					  location-alist 
					  start-dir
					  ignore-current)
  "Look for a utility's data file. 
RESULT-SYM is a place to store the result.  It will be returned if non-nil.
FILE-NAME is the name of the data file for which to search.
LOCATION-ALIST is an alist of like `tag-table-alist'.
IGNORE-CURRENT, if non-nil, says to ignore the value of RESULT-SYM."
  ;; if RESULT-SYM has a value and IGNORE-CURRENT is nil return
  ;;    the value of RESULT-SYM.
  ;; else try to match the cwd against the LOCATION-ALIST
  ;; else if that doesn't work, walk up the dir tree to /
  ;; set and return newly set value of RESULT-SYM.
  (let* ((start-dir (expand-file-name (or start-dir (default-directory))))
	 (id-file (cond 
		   ((and (not ignore-current) (symbol-value result-sym))
		    (symbol-value result-sym))
		   ((and location-alist 
			 (setq id-file (cdr-safe (dp-assoc-regexp 
						  start-dir
						  location-alist))))
		    (concat id-file file-name))
		   ((dp-search-up-dir-tree start-dir file-name)))))
    (if result-sym
	(set result-sym id-file))
    id-file))

(defun dp-point-follows-regexp (regexp &optional limit)
  "Return non-nil if point follows directly after regexp.
LIMIT, if in \(t 'nolimit 'no-limit),  says to search backwards with no limit.
LIMIT, if nil --> use default of `line-beginning-position'.
LIMIT, otherwise, has a buffer pos that is the limit."
  (interactive "sregexp: ")
  (save-excursion
    (let ((p (point))
          (limit (cond
                  ((memq limit '(t nolimit no-limit)) nil)
                  (t (or limit (line-beginning-position))))))
      (and (re-search-backward regexp limit t)
           ;; If found, `match-' `end', `beginning' can be used to delimit
           ;; the regex match.
           (= p (match-end 0))
           ;; Useful, non-nil return
           (cons (match-beginning 0) (match-end 0))))))
(defalias 'dp-looking-back-at 'dp-point-follows-regexp)

(defun dp-toggle-truncate (&optional arg)
  "Toggle value of `truncate-lines'."
  (interactive "P")
  (dp-toggle-var arg 'truncate-lines))
(defalias 'trunc 'dp-toggle-truncate)

(defun rcc (arg)
  (interactive "p")
  (repeat-complex-command (if current-prefix-arg  ; User provided arg?
                              arg
                            ;; 2 skips this command (our `rcc') since it
                            ;; seems to be put onto the `command-history'
                            ;; list before this function is called.
                            ;; Uses 1 based indexing.
                            ;; Handle case of empty command-history.
                            (if (> (length command-history) 1 ) 
                                2
                              1))))

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
      

(defun dp-select-next-tab ()
  (interactive)
  (let ((buf (dp-next-in-tab-list)))
    (when buf
      (switch-to-buffer (aref buf 0)))))

(defun dp-view-passwords ()
  (interactive)
  (find-file dp-passwords-file)
  (mc-decrypt)
  (sam)
  ;; Prevent changes until I learn how to re-encrypt.
  (set-buffer-modified-p nil)
  (setq buffer-read-only t))

(defalias 'vpw 'dp-view-passwords)

(defun iding ()
  (interactive)
  (ding))

(when (and (boundp 'dp-backup-dir)
	   dp-backup-dir)
  ;; verify [?and create?] dp-backup-dir
  (defun make-backup-file-name (file)
    "Override the standard `make-backup-file-name'.
It lives in /usr/local/lib/xemacs-<ver>/lisp/files.el
This version puts all backups in a single directory.
Is this a good idea?"
    ;; FSF has code here for MS-DOS short filenames, not supported in XEmacs.
    (concat dp-backup-dir (auto-save-escape-name file))))

(when (and (boundp 'dp-numeric-backup-dir)
	   dp-numeric-backup-dir)
  ;; verify [?and create?] dp-backup-dir
  (defun make-backup-file-name (file)
    "Override the standard `make-backup-file-name'.
It lives in /usr/local/lib/xemacs-<ver>/lisp/files.el
This version puts all backups in a single directory.
Is this a good idea?"
    ;; FSF has code here for MS-DOS short filenames, not supported in XEmacs.
    (concat dp-backup-dir (auto-save-escape-name file))))

(defun de-dos (&optional begin end)
  (interactive)
  ;;(dmessage "b: %s, e: %s, ma-p: %s" begin end (dp-mark-active-p))
  (save-excursion
    (if (dp-mark-active-p)
	(setq begin (region-beginning)
	      end (region-end))
      (unless begin
	(setq begin (point-min)
	      end (point-max))))
    (if (> begin end)
	(let ((tmp end))
	  (setq end begin
		begin tmp)))
    (goto-char begin)
    (while (search-forward "
" end t)
      (replace-match "" nil t))))

(defun dp-x-insert-selection (prompt-if-^Ms &optional no-insert-p)
  "Insert the current X Window selection at point, and put text into kill ring."
  (interactive "P")
  (let ((text (dp-with-all-output-to-string
	       (insert-selection))))
    (when (and (string-match "" text)
	       (or (ding) t)
	       (or (not prompt-if-^Ms)
		   (y-or-n-p "^Ms in text; dedosify")))
      (setq text (replace-in-string text "" "" 'literal))
      (message "dedos'd"))
    (push-mark (point))
    (unless no-insert-p
      (insert text))
    (setq this-command 'yank)
    (kill-new text)))

(defun dp-x-copy-to-kill-selection (prompt-if-^Ms)
  (interactive "P")
  (dp-x-insert-selection prompt-if-^Ms 'no-insert-p))

;; url looks like this:
;; http://www.google.com/search?hl=en&ie=ISO-8859-1&q=aslan
;;                                                  ^^^^^^^
;; Quote query for url transmission.
(defun google (&optional query)
  (interactive "P")
  (if (stringp query)
      ()
    (if query
	(setq query (read-from-minibuffer "query? " 
					  (thing-at-point 'symbol)))))
  (let ((url (if (and query (boundp 'dp-preferred-web-search-url+query))
		 (format dp-preferred-web-search-url+query 
			 (browse-url-file-url query))
	       dp-preferred-web-search-site)))
    (funcall dp-preferred-web-search-browser-function url)))

(defun dp-maybe-get-region ()
  "Return string containing region if mark is active, else nil."
  (if (dp-mark-active-p)
      (buffer-substring (region-beginning) (region-end))
    nil))

(defconst dp-simple-viewer-def-quit-keys '(?q ?Q ?x ?X ))

(dp-deflocal dp-simple-viewer-exit-func nil
  "Function to call when the viewer exits.")

(dp-deflocal dp-simple-viewer-exit-func-args nil
  "Args for function called when the viewer exits.")

;; called with view buffer as the current buffer
(defun dp-simple-viewer-exit ()
  (interactive)
  (dp-delete-extents (point-min) (point-max) 'dp-less-bg-extent)
  (if dp-simple-viewer-exit-func
      (call-interactively dp-simple-viewer-exit-func)))

(defun dp-simple-viewer (buf-or-name 
			 &optional fill-func quit-keys 
			 q-key-command key-map text-face
                         &rest q-key-command-args)
  "View something in a buffer.
FILL-FUNC specifies contents.  If it is a string, insert it.  If it is
a function, call it. Otherwise do nothing.
QUIT-KEYS is a list of keysyms to bind to Q-KEY-COMMAND.  If nil, use
`dp-simple-viewer-def-quit-keys' (== '(?q ?Q ?x ?X)).  If t, use no
quit-keys.  If a list and the first element is 'add, then append the cdr of
QUIT-KEYS to `dp-simple-viewer-def-quit-keys'.
Q-KEY-COMMAND is a function to bind to each keysym in QUIT-KEYS.  It is
called with Q-KEY-COMMAND-ARGS.
If KEY-MAP is non-nil, use that in place of a copy of the current keymap.
QUIT-KEYS, if neq t, are added to this map."
  (switch-to-buffer buf-or-name)
  (setq buffer-read-only t)
  (let ((inhibit-read-only t)
	rc)
    (erase-buffer)
    (goto-char (point-min))
    (cond
     ((stringp fill-func) (insert fill-func))
     ((functionp fill-func) (funcall fill-func))
     (t nil))
    (goto-char (point-min))
    (let* ((kmap (or key-map
		     (copy-keymap (car (current-keymaps)))))
	   (key-message))
      (cond
       ;; We use nil to imply that we want the default quit-keys,
       ;; so we use t if we do not wish to use any quit-keys.
       ((eq quit-keys t) nil)
       (quit-keys
	(if (eq (car quit-keys) 'add)
	    (setq quit-keys (append (cdr quit-keys)
				    dp-simple-viewer-def-quit-keys))))
	((eq quit-keys nil)
	 (setq quit-keys dp-simple-viewer-def-quit-keys)))
      (when (listp quit-keys)
	(setq q-key-command (or q-key-command 'kill-this-buffer)
	      dp-simple-viewer-exit-func q-key-command
              dp-simple-viewer-exit-func-args q-key-command-args 
	      key-message (mapconcat (function
                                      (lambda (key)
                                        (define-key kmap key 
                                          'dp-simple-viewer-exit)
                                        (format "%c" key)))
                                     quit-keys
                                     ", ")))
      (use-local-map kmap)
      (when text-face
	(unless (dp-extent-with-property-exists 'dp-less-bg-extent)
	  (dp-set-text-color 'dp-less-bg-extent text-face)))
      (message "Press %s to exit view mode" key-message))))

(defun dp-interactive-info-p-arg (&optional arg)
  "Show what interactive returns."
  (interactive "p")
  (message "\"p\">%s<, \"P\" (aka current-prefix-arg)>%s<" 
           arg current-prefix-arg))
(defalias 'itest 'dp-interactive-info-p-arg)

(defun dp-interactive-info-P-arg (&optional arg)
  "Show what interactive returns."
  (interactive "P")
  (message "\"P\": argument to function >%s<, current-prefix-arg>%s<" 
           arg current-prefix-arg))
(defalias 'raw-itest 'dp-interactive-info-P-arg)

(defun dp-interactive-info-no-arg (&optional arg)
  "Show what interactive returns."
  (interactive)
  (message "nil: argument to function >%s<, current-prefix-arg>%s<" 
           arg current-prefix-arg))
(defalias 'nil-itest 'dp-interactive-info-no-arg)


(defun dp-mark-sexp (&optional arg)
  "Do a mark-sexp the way I like it: if on close 'paren' mark the sexp that that 'paren' closes.  Otherwise, mark as usual"
  (interactive "p")
  (setq-ifnil arg 1)
  ;; need to look at char behind point?
  (save-match-data
    (when (looking-at "[])}]")
      ;; mark-sexp w/-arg marks sexp *before* point
      ;; so if we're looking at a closing "paren" go fwd once.
      (forward-char 1)
      (setq arg (- arg))))
  ;; otherwise, let mark-sexp handle things
  (mark-sexp arg))

(defun dp-copy-sexp ()
  "Copy sexps marked with dp-mark-sexp."
  (interactive)
  (save-excursion
    (call-interactively 'dp-mark-sexp)
    ;;;(copy-region-as-kill 
    (kill-ring-save (mark) (point))
    (dp-deactivate-mark)))

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
      (dp-push-go-back "dp-bm-cycle"))
    (goto-char pos)))
(defalias 'bmc 'dp-bm-cycle)

(defun dp-regexp-dequote (str)
  "Very simplistic quoted regexp dequoter."
  (replace-in-string str "\\\\" ""))

(defun dp-set-text-color (tag face &optional begin end detachable-p 
			      start-open-p end-open-p)
  "Set a region's background color to FACE.
Identify the extent w/TAG.
Use BEGIN and END as the limits of the extent."
  ;;(dmessage "b>%s<, e>%s<" begin end)
  (unless (dp-extent-with-property-exists tag begin end)
    (dp-make-extent (or begin (point-min)) (or end (point-max))
                    tag
                    'face face
                    'start-open start-open-p
                    'end-open end-open-p
                    'detachable detachable-p
                    'dp-end nil)))

(defun clhs ()
  (interactive)
  (w3m 
   "/usr/local/share/doc/CommonLisp-HyperSpec/HyperSpec/Front/Contents.htm"))

(defun dp-string-search-or-apply (pred &rest pred-args)
  "If PRED is a string, PRED-ARGS is the remaining args to `string-match'.
Else `(apply pred pred-args)'."
  (if (stringp pred)
      ;; Same as (dp-re-search-or-apply 'string-match string &optional ...)
      (apply 'string-match pred pred-args)
    (apply pred pred-args)))

(defvar dp-recently-killed-files-max 128
  "Keep the names of the last N files whose buffers were killed.")

(defstruct dp-killed-file-state
  (point nil))

(defvar dp-killed-file-states nil
  "Info about all recently killed files.")

(defun* dp-save-killed-file-state (&optional (buffer (current-buffer)))
  (let* ((file-name (file-truename (buffer-file-name buffer)))
         ;; Just state info
         (new-state (make-dp-killed-file-state
                     :point (point)))
         ;; Assoc cons, (file-name . state)
         (old-state (dp-find-file-state buffer)))
    (if old-state
        (setcdr old-state new-state)
      ;; Keep resultant list trimmed to a max length.
      (when (> (length dp-killed-file-states) dp-recently-killed-files-max)
        ;; Keep the newest, so nuke the earliest, since we are a stack
        (setq dp-killed-file-states (butlast dp-killed-file-states)))
      ;; We unconditionally add the new name even if it's already in the list
      ;; because the most recent state is required.
      (setq dp-killed-file-states
            (cons (cons file-name new-state)
                  dp-killed-file-states)))))

(defun dp-find-file-state (&optional file-name-or-buffer)
  ;; Use file-name-or-buffer
  (let* ((r-file-name (cond
                       ((nilp file-name-or-buffer)
                        (buffer-file-name (current-buffer)))
                       ((stringp file-name-or-buffer)
                        file-name-or-buffer)
                       ((bufferp file-name-or-buffer)
                        (buffer-file-name file-name-or-buffer)))))
    (assoc (and r-file-name
                (file-truename r-file-name))
           dp-killed-file-states)))

(defun dp-restore-file-state (&optional file-name-or-buffer)
  ;; Use file-name-or-buffer
  (let ((state (dp-find-file-state file-name-or-buffer)))
    (when state
      (goto-char (dp-killed-file-state-point (cdr state))))))

(defun* dp-restore-file-state-old (&optional (buffer (current-buffer)))
  (let ((state (assoc (file-truename (buffer-file-name buffer))
                      dp-killed-file-states)))
    (when state
      (goto-char (dp-killed-file-state-point (cdr state))))))

(defun dp-push-killed-file-name (buffer-file-name)
  (dp-push-onto-bounded-stack 'dp-recently-killed-files 
                              buffer-file-name
                              dp-recently-killed-files-max))

;; I just changed from a ring to a stack, and I had to change too much.
;; Not having this was one problem.
(defun dp-get-recently-killed-file-list ()
  dp-recently-killed-files)

(defun dp-set-recently-killed-file-list (new-list)
  (setq dp-recently-killed-files new-list))

(defun dp-init-recently-killed-files ()
  (dp-set-recently-killed-file-list nil))

(defvar dp-recently-killed-files (dp-init-recently-killed-files)
  "File names of most recently killed buffers.")

(defun* dp-revisit-killed-file (&optional (pred ".*") pred-args)
  (interactive)
  (let* ((tmp (dp-get-recently-killed-file-list))
	 (table (dp-mk-completion-list tmp)))
    (find-file (completing-read "Resurrect file: " 
                                table
                                nil t))
    (dp-set-recently-killed-file-list tmp)))

(dp-defaliases 'dp-resurrect 'dprd 'raise-dead 'resurrect 
               'dp-revisit-killed-file)


(defun dp-kill-this-buffer ()
  "Undedicates window, saves file name in `dp-recently-killed-files' and kills current buffer."
  (set-window-dedicated-p (dp-get-buffer-window) nil)
  (when buffer-file-name
    (dp-save-killed-file-state (current-buffer))
    (dp-push-killed-file-name buffer-file-name))
  ;; Buffer local which will go away with the buffer.
  ;; Also means there's no need to clear the variable.
  (let ((saved-win-conf dp-saved-window-config))
    (kill-this-buffer)
    (run-hooks 'dp-after-kill-this-buffer-hook)
    (when saved-win-conf
      (set-window-configuration saved-win-conf))))

(defun dp-kill-buffer (&optional buffer)
  (with-current-buffer (or buffer (current-buffer))
    (dp-kill-this-buffer)))

(defun dp-func-or-kill-buffer (&optional func kill-func-in prompt 
					 preserve-pred-func
					 kill-pred-func)
  "Call FUNC or KILL-FUNC-IN on buffer predicated on prefix-arg.
Return name of function that was actually used.
No prefix arg: call FUNC.
Prefix arg == 4 (one C-u) : query to perform KILL-FUNC-IN.
Prefix arg >  4 (>one C-u): call KILL-FUNC-IN.
An example is `dp-bury-or-kill-buffer' which uses `bury-buffer' and
`kill-this-buffer'.  This is useful for sensitive buffers that you would
prefer to bury in general rather than kill.  But killing is available if
desired.
prefix arg is highest priority.
preserve-pred-func forces func
kill-pred-func forces kill-func-in."
  (interactive)
  ;; prefix arg overrides preserve-pred-func
  (let ((prefix-killp (prefix-numeric-value current-prefix-arg))
	(preservep (and (functionp preserve-pred-func) 
			(funcall preserve-pred-func)))
	(killp2 (cond
		 ((functionp kill-pred-func) (funcall kill-pred-func))
		 (t nil)))
	(kill-func (or kill-func-in 'dp-kill-this-buffer)))
    (cond
     ((> prefix-killp 4) (setq func kill-func))
     ((= prefix-killp 4) (setq func
                               (function
                                (lambda ()
                                  (dp-func-this-buffer-with-conf 
                                   kill-func prompt)))))
     (killp2 (setq func kill-func)))

    (dmessage "%s'd: %s" func (buffer-name))
    (funcall func)
    (format "%s" func)))

(defun dp-buffer-name (&optional buf-or-name)
  "Return name of buf, or name if name is the name of a buffer.
If BUF-OR-NAME is nil, use the current buffer's name."
  (cond
   ((or (null buf-or-name) 
        (bufferp buf-or-name)) (buffer-name buf-or-name))
   ; Can return nil.  Won't recurse again.
   ((stringp buf-or-name) buf-or-name)
   (t (error 'wrong-type-argument 
             buf-or-name "Neither a buffer nor a name."))))

(defun* dp-buffer-process-live-p (&optional buffer &key (default-p t))
  "See if BUFFER, def `current-buffer' has a live process. 
BUFFER is name or buffer object."
  (when (or default-p buffer)
    (setq-ifnil buffer (current-buffer))
    (process-live-p (and (dp-buffer-live-p buffer)
                         (get-buffer-process buffer)))))

(defalias 'dp-get-buffer-process-safe 'dp-buffer-process-live-p)

(defun dp-buffer-live-p (buf-or-name-or-nil)
  "Return the buffer of BUF-OR-NAME-OR-NIL if live, else nil.
BUF-OR-NAME-OR-NIL may be nil, a buffer or a buffer name."
  (and buf-or-name-or-nil
       (or (bufferp buf-or-name-or-nil)
           (stringp buf-or-name-or-nil))
       ;; `get-buffer' works with both names and buffer objects.
       (buffer-live-p (get-buffer buf-or-name-or-nil))
       (get-buffer buf-or-name-or-nil)))

(defun dp-bury-or-kill-buffer (&optional kill-pred-func)
  "Call `dp-func-or-kill-buffer' with `bury-buffer' and  `kill-this-buffer'."
  (interactive)
  (dp-func-or-kill-buffer 'bury-buffer nil ;`kill-this-buffer' is the default.
                          nil nil kill-pred-func))


(defun dp-bury-or-kill-process-buffer-0 (&optional buffer)
  (dp-bury-or-kill-buffer (function
                           (lambda ()
                             (and
                              (not (dp-buffer-process-live-p buffer))
                              (message "Nuking process buffer (%s)" 
                                       (buffer-name buffer)))))))

(defun dp-bury-or-kill-process-buffer (&optional buffer)
  "Given BUFFER, if it has a live process, bury it, else kill it. nil BUFFER is OK."
  (interactive)
  (when buffer
    (setq buffer (get-buffer buffer))
    (when buffer
      (with-current-buffer buffer
        (dp-bury-or-kill-process-buffer-0 buffer)))))

(defun dp-bury-or-kill-this-process-buffer ()
  (interactive)
  (dp-bury-or-kill-process-buffer (current-buffer)))

(defun dp-turn-on-auto-fill ()
  (if (fboundp 'turn-on-filladapt-mode)
      (turn-on-filladapt-mode))
  (turn-on-auto-fill))

(defun dp-turn-off-auto-fill ()
  (if (fboundp 'turn-off-filladapt-mode)
      (turn-off-filladapt-mode))
  (auto-fill-mode 0))

(defvar dp-filladapt-state-stack nil
  "Stack of filladapt on/off statii")

(defun dp-push-filladapt-state (on-p)
  (setq dp-filladapt-state-stack 
	(cons filladapt-mode dp-filladapt-state-stack))
  (if on-p
      (turn-on-filladapt-mode)
    (turn-off-filladapt-mode)))

(defun dp-pop-filladapt-state ()
  (let ((on-p (car dp-filladapt-state-stack)))
    (setq dp-filladapt-state-stack 
	  (cdr dp-filladapt-state-stack))
    (if on-p
	(turn-on-filladapt-mode)
      (turn-off-filladapt-mode))))

(defun dp-longest-line-in-region (&optional beg end)
  "Return (max-len . line-number-of-max-line) of 1st longest line in region.
Use BEG END if given, else (mark) (point)."
  (interactive)
  (save-excursion
    (let* ((region (if beg (cons beg end) (dp-region-boundaries-ordered)))
           (reg-end (cdr region))
           (line-num-of-max)
           (max 0)
           len)
      (save-excursion
        (goto-char (car region))
        (beginning-of-line)
        (while (and (not (eobp)) 
                    (< (point) reg-end))
          (setq len (- (line-end-position) (line-beginning-position)))
          (dmessage "len: %s, max: %s" len max)
          (if (> len max)
              (setq max len
                    line-num-of-max (line-number)))
          (forward-line 1))
        (dp-deactivate-mark)
        (cons (1+ max) line-num-of-max)))))

(defun dp-longest-line-in-list (list)
  "Find the longest line in the list."
  (let ((max 0)
	(max-line "")
	llen)
    (dolist (line list)
      (setq llen (length line))
      (when (> llen max)
	(setq max llen
	      max-line line)))
    max-line))
      
  
(defvar dp-default-sfw-width 80)
(defvar dp-sfw-width dp-default-sfw-width
  "Last width set via `dp-set-frame-width'.")
(defvar dp-max-frame-width 232
  "Can set this in a spec-macs.")
(defvar dp-last-sfw-width dp-default-sfw-width)

(defun dp-set-frame-width (width &optional frame col-mode-win-width)
  "Sets (or FRAME (selected-fram)) to WIDTH.
If region is active, set width to that of the longest line in the region."
  (interactive (list (or
                      (and (dp-mark-active-p)
                           (1+ (car (dp-longest-line-in-region))))
                      (read-number 
                       (format 
                        "width(current: %s; default: %s; 0 for max: %s): "
                        (frame-width)
                        dp-last-sfw-width
                        dp-max-frame-width)
                       'ints-only (format "%s" dp-last-sfw-width)))))
  (setq dp-last-sfw-width (frame-width))
  (set-frame-width (or frame (selected-frame))
                   (setq dp-sfw-width
                         (if (eq width 0)
                             dp-max-frame-width
                           width))))

(defalias 'sfw 'dp-set-frame-width)

(defvar dp-sfh-to-compile-win-height 4
  "*The part of the frame height used for the compile window.")

(defvar dp-sfh-height 71
  "*Initial frame height.")

(defun dp-set-frame-height (&optional height frame)
  (interactive (list (read-number 
                       (format "height(current: %s; default: %s): " 
                               (frame-height) dp-sfh-height )
                       'ints-only (format "%s" dp-sfh-height))))
  (set-frame-height
   (or frame (selected-frame))
   (setq dp-sfh-height
         (or height (dp-maybe-str-to-int dp-sfh-height))))
  (setq compilation-window-height (/ (frame-height frame)
                                     dp-sfh-to-compile-win-height)))

(defalias 'sfh 'dp-set-frame-height)

(defun sfw-fit-region (&optional entire-file-p)
  (interactive "P")
  (save-excursion
    (if entire-file-p
        (mark-whole-buffer)
      (dp-mark-line-if-no-mark))
    (let ((ll (min dp-max-frame-width (1+ (car (dp-longest-line-in-region))))))
      (sfw ll)
      (message "new width: %s" ll))))
      
(defun dp-up-with-wrap (arg &optional command args)
  (interactive "p")
  ;;(dmessage "arg>%s<" arg)
  (let ((col (current-column)))
    (setq this-command 'previous-line)
    (condition-case nil
	(previous-line arg)
      (error 
       (let ((wrap-lines (- (line-number) arg))
	     (max-lines (line-number (point-max))))
	 (goto-line (- max-lines wrap-lines))
	 (move-to-column col)))))
  (if command
      (apply command args)))

(defun dp-down-with-wrap (arg &optional command args)
  (interactive "p")
  ;;(dmessage "arg>%s<" arg)
  (let ((col (current-column)))
    (setq this-command 'next-line)
    (condition-case nil
	(next-line arg)
      (error 
       (let* ((max-lines (line-number (point-max)))
	      (wrap-lines (- max-lines (line-number) arg)))
	 (goto-line wrap-lines)
	 (move-to-column col)))))
  (if command
      (apply command args)))

;; useful in mew-draft-mode, since the fill results in the citation being
;; the fill prefix.
(defun dp-fill-paragraph-or-region-preserving-fill-prefix ()
  (interactive "*")
  (let ((fill-prefix fill-prefix))
    (call-interactively 'fill-paragraph-or-region)))

(defun dp-region-boundaries-ordered (&optional beg? end? exchange-pt-and-mark-p)
  "Return the boundaries of the region ordered in a cons: \(low . hi\)"
  ;; I never knew about these functions.
  ;; (cons (region-beginning) (region-end)))
  ;; But here they're not very useful since beg? and end? may not be ordered.
  ;; Au contraire, they seem to always return beg as the lower, and end as
  ;; the higher, position-wise.
  (if (and beg? end?)
      (if (> end? beg?)
          (cons beg? end?)
        (cons end? beg?))
    (when (and exchange-pt-and-mark-p
               (< mark (point)))
      (exchange-point-and-mark))
    (cons (region-beginning) (region-end))))

(defsubst dp-region-boundaries-ordered-list (&rest args-to-passthru)
  (dp-cons-to-list (apply 'dp-region-boundaries-ordered args-to-passthru)))

(defun* dp-nuke-newline (string &optional (nuke-p t))
  "Remove newline, if one, @ end of string.
Extra pred NUKE-P makes this more convenient when called in common circumstances."
  (when string
    (if (and (< 1 (length string))
             (string= (substring string -1) "\n")
             nuke-p)
        (substring string 0 -1)
      string)))
    
; (defun dp-bq (&optional nuke-command hack-newline)
;   "Replace region w/command output using region as command."
;   (interactive "*P")
;   (let* ((region (dp-region-boundaries-ordered))
; 	 (beg (car region))
; 	 (end (cdr region))
; 	 (command (buffer-substring beg end))
;          (x (message "Running `%s'..." command))
; 	 (output (shell-command-to-string command))
;          (x (message "%s done." x command)))
;     (when output
;       (if (not nuke-command)
;           (progn
;             (goto-char end)
;             (newline))
; 	(kill-region beg end)
; 	(goto-char beg))
;       (insert output)
;       ; mark the newly inserted text.
;       (dp-set-mark beg))))

(defun* dp-bq (&optional nuke-command-p (nuke-newline-p t) (mark-p t)
               &key (bounder 'line-p))
  "Replace region w/command output using region (or line if no region) as command.
If NUKE-NEWLINE-P is non-nil, remove the newline from the end of the output.
If MARK-P is non-nil, then mark the region containing the output of the
command."
  (interactive "*P")
  (let* ((region (dp-region-or... :bounder bounder))
	 (beg (car region))
	 (end (cdr region))
	 (command (buffer-substring beg end))
         (x (message "Running `%s', region: %s..." command region))
	 (output (shell-command-to-string command))
         (output (if (and nuke-newline-p
                          (<= 1 (length output))
                          (string= "\n" (substring output -1)))
                     (substring output 0 -1)
                   output))
         (x (message "%s done." x command)))
    (when output
      (if (not nuke-command-p)
          (progn
            (goto-char end)
            (newline))
	(kill-region beg end)
	(goto-char beg))
      (setq beg (point))
      (insert output)
      (setq end (point))
      ; mark the newly inserted text.
      (when mark-p
        (dp-mark-region (cons beg end))))))

(defun dp-bq-rest-of-line (&optional nuke-command-p nuke-newline-p mark-p)
  "`dp-bq' (q.v.) on the rest of the line."
  (interactive "P")
  (dp-bq nuke-command-p nuke-newline-p mark-p
         :bounder 'rest-or-all-of-line-p))

;; Don't define if collision
(dp-safe-alias 'bq 'dp-bq)

(defun dp-shell-command-to-list (command &optional split-chars)
  "Run command, split output into a list of lines."
  (split-string (shell-command-to-string command) (or split-chars "[\n]")))

(defun dp-shell-command-in-minibuffer (command)
  "Interactive version of `shell-command-to-string' Output goes to minibuffer.
ALL trailing white space is nuked.
Really only useful for commands with 0 or 1 line of output.
Motivation was the ability to run commands like this \"mpc play\"."
  (interactive (list (read-from-minibuffer "shell cmd> "
                                       (if (Cup)
                                           ""
                                         "mpc "))))
  (let ((white-space-stripper (concat "\\(^.*\\)\\("
                        dp-ws+newline-regexp+
                        "$\\)"))
        (shell-output-string (shell-command-to-string command)))
  (string-match white-space-stripper shell-output-string)
  ;; Avoid anything in the output which may confuse message's formatting.
  ;; eg this string: "%s"
  (message "%s" (match-string 1 shell-output-string))))

; (defun dp-ffap-file-finder ()
;   "Recognize /file/name:<linenum>.
; Visit /file/name and then goto <linenum>."
;   (interactive)
;   (let ((name (ffap-string-at-point 'file))
; 	line-num
; 	filename)
;     (string-match "\\(.*\\)[@:]\\([0-9][0-9]*\\)$" name)
;     (setq line-num (match-string 2 name))
;     (setq filename (match-string 1 name))
;     (if (and line-num
; 	     (file-exists-p filename)
; 	     (y-or-n-p (format "visit %s and goto %s? " filename line-num))
; 	     (find-file filename))
; 	(goto-line (string-to-int line-num))
;       (call-interactively dp-file-finder))))

(defvar dp-ffap-ask-to-goto-line nil
  "What more can I say than the variable name?")

(defun dp-ffap-file-finder2 (&optional name-in)
  "Recognize /file/name:<linenum>.
Visit /file/name and then goto <linenum>."
  (interactive)
  (if (not name-in)
      (call-interactively dp-ffap-ffap-file-finder)
    (let ((name (ffap-string-at-point 'file))
          (file-name-in (file-name-nondirectory name-in))
          line-num
          filename)
      (when (string-match "\\(.*\\)[@:]\\([0-9][0-9]*\\)\\s-?" name)
        (setq line-num (match-string 2 name))
        (setq filename (file-name-nondirectory (match-string 1 name))))
      (if (and line-num
               (string= filename file-name-in)
               (file-exists-p name-in)
               (if dp-ffap-ask-to-goto-line
                   (y-or-n-p (format "goto %s in %s? " line-num filename))
                 t)                       ;keeps the (and) going
               (funcall dp-ffap-ffap-file-finder name-in))
          (progn
            (if (find-buffer-visiting name-in)
                (dp-push-go-back "dp-ffap-file-finder2"))
            (goto-line (string-to-int line-num)))
        (funcall dp-ffap-ffap-file-finder name-in)))))

(defun dp-ffap (&optional file-name)
  (interactive "P")
  (cond
   ((not (interactive-p))
    (find-file file-name))
   ((Cu--p)
    (call-interactively 'dp-search-path))
   (t (call-interactively dp-file-finder)))
;;   (dp-restore-file-state)
  )

(defun dp-ffap-other-window (&optional file-name)
  (interactive "P")
  (cond
   ((not (interactive-p))
    (find-file-other-window file-name))
   ((Cu--p)
    (call-interactively 'dp-search-path-other-window))
   (t (call-interactively dp-file-finder-other-window)))
;;   (dp-restore-file-state)
  )

(defvar dp-highlight-point-buffer nil
  "Last buffer that was highlighted.")
(defvar dp-highlight-point-marker nil
  "Last marker that was highlighted.")

(defvar dp-highlight-point-id-prop 'dp-highlight-point-id
  "Use this property to differentiate between multiple users.")

(defun* dp-highlight-point (&key (pos (point)) (priority 777)
                            (id-prop dp-highlight-point-id-prop)
                            colors)
  "Highlight the line on which point resides.
The line is highlighted with three faces:
`dp-highlight-point-before-face'
`dp-highlight-point-face'
`dp-highlight-point-after-face'
This makes point very visible."
  (interactive)
  (let* ((buffer (or (and (markerp pos) 
                          (marker-buffer pos))
;                      (or (dp-buffer-live-p dp-highlight-point-buffer)
;                          (setq dp-highlight-point-buffer nil))
                     (current-buffer)))
         (colors (or colors dp-highlight-point-default-faces))
         (before-face (dp-highlight-point-faces-before colors))
         ;; Nil says to `inherit' previous color.
         (at-face (or (dp-highlight-point-faces-at colors)
                      before-face))
         (after-face (or (dp-highlight-point-faces-after colors) 
                         at-face))
         bol eol pp ext) 
    (unless pos
      (setq pos (point)))
    (setq bol (line-beginning-position)
          eol (line-end-position)
          pp (+ pos (if (eobp) 0 1))
          exts (when (buffer-live-p buffer)
                 (with-current-buffer buffer
                   (list 
                    (if (< bol pp)
                        (dp-make-extent bol pp
                                        id-prop
                                        'face before-face
                                        'priority priority))
                    (if (<= pp eol)
                        (dp-make-extent pos pp
                                        id-prop
                                        'end-open t
                                        'start-open t
                                        'face at-face
                                        'priority priority))
                    (if (> eol pp)
                        (dp-make-extent pp eol
                                        id-prop
                                        'face after-face
                                        'priority priority))))))
    (when exts
      (setq dp-highlight-point-buffer buffer
            dp-highlight-point-marker (dp-mk-marker pos buffer)))
    exts))

(defvar dp-highlight-in-set-buffer nil
  "if non-nil, highlight the current line in the new buffer.")

(defvar dp-highlight-in-other-window nil
  "*When non-nil, highlight the current line in the new window.")

(defvar dp-unhighlight-hook-one-shot-lambda nil
  "When new buffer highlighted line: ((extent...) . one-shot-hook)")

(defun dp-dump-extent-list (&optional elist)
  (mapconcat (function
              (lambda (ext)
                (when ext
                  (format "dump ext: %S" ext))))
             (or elist (extent-list))
             "\n  "))

;; 12345-!-6789
;;   
;; this is a one-shot-hook
(defun dp-unhilight-point-hook ()
  "Unhighlight the highlighted point line."
  (interactive)
  (mapcar (function
           (lambda (ext)
             (when ext
               (delete-extent ext))))
          (car dp-unhighlight-hook-one-shot-lambda))
  (remove-hook 'pre-command-hook (cdr dp-unhighlight-hook-one-shot-lambda))
  (setq dp-unhighlight-hook-one-shot-lambda nil))

(defun* dp-highlight-point-until-next-command (&key point colors)
  "Highlight the line on which point resides using `dp-highlight-point'.
The highlight will be removed after the next command."
  (interactive)
  ;; Previous hook hasn't fired yet. E.g. switch-buffer, switch-buffer back
  ;; to back.
  (when dp-unhighlight-hook-one-shot-lambda
;     (dmessage "dp-highlight-point-until-next-command: YOPP!
; dp-unhighlight-hook-one-shot-lambda: %S" dp-unhighlight-hook-one-shot-lambda)
    (dp-unhilight-point-hook))
  (setq dp-unhighlight-hook-one-shot-lambda
        (cons (dp-highlight-point :pos point :colors colors)
              (car (add-one-shot-hook 'pre-command-hook 
                                      'dp-unhilight-point-hook)))))

(defun* dp-unhighlight-point (&key (pos (point)) (buffer (current-buffer))
                              (id-prop dp-highlight-point-id-prop)
                              ;; clr-hook show-line-num-p  ; For debugging.
                              )
  (interactive)
  (let ((buffer (or (and (markerp pos) 
                         (marker-buffer pos))
                    buffer
                    (error 'invalid-argument "I need a marker or a buffer"))))
    (setq pos nil)                      ;Hasten gc in case pos is a marker.
    (when (buffer-live-p buffer)
      (with-current-buffer buffer
        (setq dp-highlight-point-buffer nil
              dp-highlight-point-marker nil)
        (dp-delete-extents (point-min) (point-max) id-prop)))))

(defun* dp-rehighlight-point (&key (pos (point))
                              (id-prop dp-highlight-point-id-prop)
                              set-done)
  (interactive)
  (dp-unhighlight-point :id-prop id-prop :pos pos)
  (dp-highlight-point :id-prop id-prop :pos pos))
  

;; toggle algorithm copped from view-mode
(defun dp-toggle-var (arg var-sym &optional quiet-p)
"Toggle value of VAR-SYM in the canonical manner as a function of ARG.
If ARG is nil, toggle value of VAR-SYM.
If ARG is > 0, or t then set value of VAR-SYM to t.
If ARG is <= 0, set value of VAR-SYM to nil.
If QUIET-P is non-nil, show new value of VAR-SYM."
  (interactive "P")
  (let ((val (symbol-value var-sym)))
    (set var-sym (if arg
		     (or (equal arg t)  ; t if, well, t.
			 (> arg 0))	; t if >, nil if <=
                   ;; Just toggle.
		   (not val))))
  (unless quiet-p
    (message "%s is now %s." var-sym (symbol-value var-sym))))

(defun key-id ()
  (interactive)
  (where-is-internal 'key-id))

(defun dp-nil-message (format &rest args)
  (interactive)
  (apply 'message format args)
  nil)

(defun dp-embedded-lisp-regexp-p (&optional regexp prefix suffix)
  (concat (or prefix dp-embedded-lisp-prefix)
          "\\((" (or regexp "\\(?:.\\|[\n]\\)*?") ")\\)"
          (or suffix dp-embedded-lisp-suffix)))

(defun* dp-delimit-embedded-lisp (&key start regexp prefix suffix
                                  (entire-regexp-p t)  ; Find ):
                                  ;; More than a single line can be dangerous.
                                  ;; For regions, `dp-eval-tagged-lisp' is to
                                  ;; be preferred.
                                  (single-line-p t)
                                  (lazy-bastard-p t)
                                  complain-p
                                  limit)
  "Find the limits of the embedded sexp surrounding point.
LAZY-BASTARD-P: Since embedded (although quoted) parens confuse
`dp-find-matching-paren', and since I'm not in the mood to write something
better, LAZY-BASTARD-P, if non-nil (default) says to use the end of line as
the limit and re-search forward for a closing construct, e.g. `):'
This is really meant to find embedded lisp on the current line.
I'm over stretching it to find it anywhere."
  (interactive)
  (if (functionp limit) 
    (setq limit (funcall limit)))
  (setq-ifnil limit (and single-line-p (line-end-position)))
  (let* ((go t)
         incr
         (prefix (or prefix dp-embedded-lisp-prefix))
         (suffix (or suffix dp-embedded-lisp-suffix)))
    (save-excursion
      (cond 
       (start (goto-char start))
       (single-line-p (beginning-of-line)
                      (setq limit (line-end-position))))
      (save-excursion
        (if (and (looking-at suffix)
                 ;; Yes, <suffix>(
                 (not (looking-at (format "%s(" suffix))))
            (forward-char 1))
        (when (and entire-regexp-p
                   (re-search-forward prefix limit t))
          ;; We should be on the ( after the prefix.  Now, try to find the
          ;; closing paren.
          (if (setq limit (or (and (setq incr 2)
                                   ;; `dp-matching-paren-pos' will be
                                   ;; confused if the embedded lisp has
                                   ;; unmatched closing parens, so for now
                                   ;; I'll take the lazy-bastard(tm) way out
                                   ;; and assume `line-end-position'
                                   ;; (dp-matching-paren-pos 'noerror)
                                   nil)
                              (and (setq incr 0)
                                   lazy-bastard-p
                                   (re-search-forward (concat ")" suffix) 
                                                      (line-end-position) t))))
              (incf limit incr)
            (return-from dp-delimit-embedded-lisp (1+ (point))))))
      (if (not (re-search-forward
                (or regexp
                    (dp-embedded-lisp-regexp-p regexp prefix suffix))
                limit
                t))
          ;; No match
          ;; Try at next char.
          (return-from dp-delimit-embedded-lisp (1+ (point)))
        (cons (+ (length prefix) (match-beginning 0))
              (- (match-end 0) (length suffix) 1))))))

;; Make these buffer local in case we have some syntactic conflicts.
;; !<@todo XXX why not use dp-deflocal?
(defvar dp-embedded-lisp-prefix ":"
  "Embedded lisp prefix.")
(make-local-variable 'dp-embedded-lisp-prefix)
(defvar dp-embedded-lisp-suffix ":"
  "Embedded lisp suffix.")
(make-local-variable 'dp-embedded-lisp-suffix)

(defun dp-embedded-lisp-open-string (&optional prefix)
  "Create a string which introduces an embedded lisp string"
  (setq-ifnil prefix dp-embedded-lisp-prefix)
  (concat (and-stringp prefix "") "("))

(defun dp-embedded-lisp-close-string (&optional prefix)
  "Create a string which introduces an embedded lisp string"
  (setq-ifnil prefix dp-embedded-lisp-prefix)
  (concat (and-stringp prefix "") ")"))

(defun dp-mk-tag-delimiters (tag)
  (cons (format "<%s>" tag)
        (format "</%s>" tag)))

;;
;; Hack to find any lines matching the tag delimited format:
;; (progn
;;   (if (save-excursion
;;         (re-search-forward "<\\([^>]*\\)>\\(.*?\\)</\\1>" nil t))
;;       (dp-all-match-strings)
;;     ("No match")))

(defun* dp-guess-tag-delimiters (&optional beg end (bounder 'line-p))
  "Guess what the specific tag value for tag-delimited-lisp is.
E.g. <a-tag>...</a-tag> --> tag"
  (interactive)
  (let* ((region (dp-region-or... beg end :bounder bounder))
         (beg (car region))
         (end (cdr region)))
    (save-excursion
      (goto-char beg)
      (if (save-excursion
            (re-search-forward "<\\([^>]*\\)>\\(.*?\\)</\\1>" nil t))
          (match-string 1)))))

(defun* dp-map-tag-delimited-strings (tag operator
                                      opener closer
                                      &key beg end 
                                      (bounder 'rest-of-buffer-p)
                                      (op-args '()))
  "Scan for all strings of the form <TAG>string</TAG>
Call OPERATOR for each match, sans delimiters."
  (let* ((be (dp-region-or... :beg beg :end end :bounder bounder))
         (beg (car be))
         (end (cdr be))
         lisp-bounds)
  (save-excursion
    (goto-char beg)
    ;; !<@todo XXX Allow sexp to be spread over >1 lines.
    (let ((regexp (format "%s\\(.*\\)%s" opener closer)))
      (while (re-search-forward regexp end t)
        (apply operator (match-string 1) op-args))))))

(defun* dp-eval-tagged-lisp (tag &optional beg end 
                             (bounder 'rest-of-buffer-p))
  "Eval all lines delimited by <TAG>... </TAG>.
Use prefix-arg to prompt for a different TAG."
  (interactive "P")
  (if (and (not tag)
           (interactive-p))
      (read-string "tag: " "ae"))
  (setq-ifnil tag "ae")
  (save-excursion
    (let* ((region (dp-region-or... :bounder bounder :beg beg :end end))
           (beg (car region)) (end (cdr region))
           (delimiters (dp-mk-tag-delimiters tag)))
      (goto-char beg)
      (dp-map-tag-delimited-strings tag
                                    (lambda (s)
                                      (eval (car (read-from-string s))))
                                    (car delimiters) (cdr delimiters)
                                    :beg beg :end end))))

(defun dp-auto-eval-tagged-lisp (&optional beg end)
  "Guess the tag on this line and eval it and all others within the desired region."
  (interactive)
  (let* ((be (dp-region-or... :beg beg :end end :bounder
                              (cond
                               ((Cu--p) 'line-p)
                               ((Cu0p) 'buffer-p)
                               (t 'rest-of-buffer-p))))
         (beg (car be))
         (end (cdr be))
         (tag (dp-guess-tag-delimiters (line-beginning-position)
                                       (line-end-position))))
    (if tag
        (dp-eval-tagged-lisp tag beg end))))

(defvar dp-embedded-lisp-eval@point-prefix-arg nil
  "Holds copy of prefix arg when dp-embedded-lisp-eval@point was called.
In reality, this var is local to dp-embedded-lisp-eval@point, but this 
prevents unbound var errors.")

(defun* dp-find-embedded-lisp (&rest args-for-delimitter
                               &key only-if-at-point-p
                               &allow-other-keys)
  "Search forward for an embedded lisp sexp.
The lisp code must be prefixed by `dp-embedded-lisp-prefix' and suffixed by
`dp-embedded-lisp-suffix'.
Sets MATCH-DATA. 
Return a `cons' of start end of match or a pos at which to continue the
search."
  (interactive)
  ;;(dmessage "pat>%s<" pat)
  (save-excursion
    (let* ((be (apply 'dp-delimit-embedded-lisp args-for-delimitter)))
      (if only-if-at-point-p
          ;; be might be just a number or marker.  The `car-safe' will save
          ;; us from an error and result in a mismatch, which is what we
          ;; want.
          (and (eq (point) (car-safe be))
               be)
        be))))

(defun dp-embedded-lisp-eval@point0 (&optional from-point regexp prefix suffix)
  "Eval the embedded lisp sexp surrounding point."
  (interactive "P")
  (save-excursion
    (unless from-point
      (beginning-of-line))
    (let ((lisp-bounds (dp-find-embedded-lisp :regexp regexp :prefix prefix 
                                              :suffix suffix)))
      (when (dp-and-consp lisp-bounds)
        (eval (car (read-from-string
                    (buffer-substring-no-properties (car lisp-bounds)
                                                    (1+ (cdr lisp-bounds)))))))
      lisp-bounds)))

(defun dp-embedded-lisp-eval-over-region (&optional from-point regexp 
                                          prefix suffix strictly-contained-p)
  "Eval the embedded lisp sexp surrounding point."
  (interactive "P")
  (let* ((be (dp-region-or... :beg beg :end end :bounder 'rest-of-buffer-p))
      ;   (be '(16478 . 18040))                ; debugger can't handle regions
         (beg (car be))
         (end (cdr be))
         (loop-p t)
         b e
         lisp-bounds)
    (dmessage "be: %s" be)
    (save-excursion
      (goto-char beg)
      (unless from-point
        (beginning-of-line))
      (while loop-p
        (setq lisp-bounds (dp-find-embedded-lisp :regexp regexp :prefix prefix 
                                                 :suffix suffix)
              b (car-safe lisp-bounds)
              e (cdr-safe lisp-bounds))
        (setq loop-p (and b e (< b end)
                          (or (not strictly-contained-p)
                              (< e end))))
        (when loop-p
          (eval (car (read-from-string
                      (buffer-substring-no-properties b (1+ e)))))
          (goto-char (1+ e)))))))

(defun dp-embedded-lisp-eval@point (&optional no-delimitter)
  "Eval an embedded lisp string.
An embedded lisp string is delimited by dp-embedded-lisp-open-string and
dp-embedded-lisp-close-string. In addition the string can be tagged so that
it can be referred to in other embedded strings."
  (interactive "P")
  (setq dp-embedded-lisp-eval@point-prefix-arg current-prefix-arg)
  (let* ((region-p (dp-mark-active-p))
         (region (save-excursion
                   (beginning-of-line)
                   (dp-region-or... :bounder 'rest-of-buffer-p)))
         (beg (car region))
         (end (cdr region))
         (delimiters (dp-mk-tag-delimiters (if no-delimitter "" ":"))))
     (if (save-excursion
           (goto-char beg)
           ;; !<@todo XXX use the function to build the :(
           (re-search-forward (concat ".*"
                                       (dp-embedded-lisp-open-string
                                        no-delimitter))
                              (line-end-position) t))
         (call-interactively 'dp-embedded-lisp-eval@point0)
       (dp-auto-eval-tagged-lisp beg end))
     (when region-p
       (message "eval'd embedded region."))))

(defun dp-eval-embedded-lisp-region (&optional beg end regexp prefix suffix)
  "Eval the embedded lisp in the region as determined by `dp-region-or...'."
  (interactive)
  (let* ((be (dp-region-or... :beg beg :end end :bounder 'rest-of-buffer-p))
         (beg (car be))
         (end (cdr be))
         (no-lisp-seen-p t)
         find-results)
    (save-excursion
      (goto-char beg)
      (while (and (> end beg)
                  (setq find-results
                        (dp-find-embedded-lisp :start beg :limit end 
                                               :regexp regexp
                                               :complain-p no-lisp-seen-p
                                               :prefix prefix :suffix suffix)))
        (if (or (numberp find-results)
                (markerp find-results))
            (incf beg)
          (setq end -1)))
      (when (= end -1)
        (setq no-lisp-seen-p nil)
        (goto-char (match-beginning 1))
        (dmessage "`eval'ing %s" (match-string 1))
        (eval (car (read-from-string (match-string 1))))
        (when (match-end 1)
          (setq beg (goto-char (match-end 1))))))))


(defun dp-eval-naked-embedded-lisp ()
  "Eval unadorned embedded lisp. E.g. \(xxx) vs :(xxx):"
  (interactive)
  (let ((dp-embedded-lisp-prefix "")
        (dp-embedded-lisp-suffix ""))
    (call-interactively 'dp-embedded-lisp-eval@point)))

;;is this used???; (defun* dp-eval-embedded-lisp (exact-regexp-p &optional (regexp "") 
;;is this used???;                                (bounder 'line-p))
;;is this used???;   "@todo -- allow an option to say `let us eval this in a buffer of its own'."
;;is this used???;   (interactive "P")
;;is this used???;   (let ((region (dp-region-or... :bounder bounder)))
;;is this used???;     (dp-eval-embedded-lisp-region (car region) (cdr region) 
;;is this used???;                                   (if (string= regexp "")
;;is this used???;                                       nil
;;is this used???;                                     (if (not exact-regexp-p)
;;is this used???;                                         (concat ".*" regexp ".*")
;;is this used???;                                       regexp)))))

(defun dp-op-on-rect-line (start end funcp &rest rest)
  "Operate on a line from a rectangular region.
See `apply-on-rectangle' for meaning of args.
This is meant to be used thus:
\(apply-on-rectangle 'dp-op-on-rect-line 68584 68637 'dp-rfun\)"
  (let* ((pt (point)))
    (apply funcp (nconc (list (+ pt start) (+ pt end)) rest))))

(defun dp-hide-rectangle (start end)
  (interactive "r")
  (if current-prefix-arg
      (apply-on-rectangle 'dp-op-on-rect-line start end 
                          'dpj-highlight-region 'unhide)
    (apply-on-rectangle 'dp-op-on-rect-line start end 
                        'dpj-highlight-region 'hide)))

(defun dp-fill-string (string max &optional no-fill-p)
  "Fill STRING to MAX, splitting at words with newlines as needed."
  (with-string-as-buffer-contents string
    (unless no-fill-p
      (let ((default-fill-column max))
	(fill-region (point-min) (point-max))))
    (untabify (point-min) (point-max))))

(defun dp-copy-rectangle-as-killed (start end)
  (interactive "*r")
  (setq killed-rectangle (extract-rectangle start end)))

(defun dp-untabify-string (str)
  (dp-fill-string str nil 'dont-fill))

(defun dp-fill-lines (lines max)
  "Fill list of lines into list of lines."
  (split-string (dp-fill-string (dp-string-join lines) max) "[\n]"))

(defun dp-fill-shell-command (command max)
  "Fill (as in fill-mode) the output of a shell command into a string."
  (dp-fill-string (shell-command-to-string command) max))

(defcustom dp-underscore-region-char "_"
  "Character that replaces spaces in `dp-underscore-region'."
  :group 'dp-vars
  :type 'string)

(defun* dp-underscore-region (&optional n &key (char nil defaulted-p)
                              as-title-p)
  "Convert spaces to `dp-underscore-region-char'."
  (interactive "P")
  (setq char 
        (if (and (not char) 
                 (not defaulted-p))     ; nil on purpose doesn't counc.
            dp-underscore-region-char
          (if char
              char
            (read-string "Underline char: "))))
  (dp-mark-line-if-no-mark)
  (let* ((reg (dp-region-boundaries-ordered))
	 (start (car reg))
	 (end (cdr reg)))
    (when as-title-p
      (save-excursion
        (goto-char start)
        (insert char)
        (goto-char (1+ end))
        (insert char)))
    (untabify start end)
    (goto-char start)
    (while (search-forward " " end t)
      (replace-match char nil t))))

(defun dp-underscore-region-use-to-revert (&optional char set-def-p as-title-p)
  "Convert spaces to `dp-underscore-region-char'."
  (interactive "P")
  (setq char 
        (if (not char)
            dp-underscore-region-char
          (prog1
              (read-string ("Underline char%s: "
                            (if set-def-p
                                " (will become session default)"
                              "")))
            (when (or set-def-p 
                      ;; At least 2 C-u
                      (< 4 (prefix-numeric-value current-prefix-arg))) 
              (setq dp-underscore-region-char char)))))
  (dp-mark-line-if-no-mark)
  (let* ((reg (dp-region-boundaries-ordered))
	 (start (car reg))
	 (end (cdr reg)))
    (when as-title-p
      (save-excursion
        (goto-char start)
        (insert char)
        (goto-char (1+ end))
        (insert char)))
    (untabify start end)
    (goto-char start)
    (while (search-forward " " end t)
      (replace-match dp-underscore-region-char nil t))))

(defun dp-underscore-region-as-title (&optional char)
  (interactive)
  (dp-underscore-region 1 :char char :as-title-p as-title-p t))

(defun dp-hyphenate-region (&optional num-pairs)
  (interactive "p")
  (loop for i from 1 to num-pairs do
    (dp-underscore-region 1 :char "-")))

(defun dp-delta-t (timestamp &optional now length)
  "Compute and format a delta t from a dp standard timestamp to NOW.
If NOW is nil, then use current-time.
NOW is expected to be in the format returned by `current-time' (q.v.)"
  (interactive "sstart: ")
  (unless now
    (setq now (current-time)))
  (let* ((then (dp-encode-timestamp timestamp))
	 (diff (time-subtract now then))
	 str
	 (fdiff (+ (* (car diff) 65536)
		   (nth 1 diff)))
	 (time-str (cond 
		    ((< fdiff 60.0) (format "%4.2f seconds" fdiff))
		    ((< fdiff 3600.0) (format "%4.2f minutes" (/ fdiff 60.0)))
		    ((< fdiff 86400) (format "%4.2f hours" (/ fdiff 3600.0)))
		    ((< fdiff 3.139e+07) 
		     (format "%5.2f days" (/ fdiff 86400.0)))
		    (t (format "%5.2f years" (/ fdiff 3.139e+07)))))
	 )
    ;;(dmessage "now>%s<, then>%s<, fdiff>%s<" now then fdiff)
    (setq str (format "%s" time-str))
    (unless (eq length 'short)
      (setq str (format "%s (%f seconds)" str fdiff)))
    str))

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

(defun dp-remote-file-p (&optional file-name)
  "Return non-nil if FILE-NAME indicates a remote file.
FILE-NAME defaults to `buffer-file-name' if not specified or is nil.
e.g. efs: /davep@sybil:/home/davep/.bashrc.
     tramp: /[scp/davep@tc-le5]/home/davep/tsat-bin/tc-le5.in"
  ;; The "" is for buffers with no name.  This forces them 
  ;; to be considered local.  We can revisit this if need be,
  ;; by changing the "" to "@:" which will force remoteness.
  (let ((fname (if (stringp file-name)
		   file-name
		 (or (buffer-file-name) ""))))
    (string-match dp-remote-file-regexp fname)))

(defun dp-not-remote-file-p (&optional file-name)
  (not (dp-remote-file-p file-name)))

(defun dp-maybe-kill-other-window-buffer (&optional arg)
  "`dp-maybe-kill-this-buffer' in the `other-window'."
  (interactive "p")
  (save-window-excursion
    (other-window arg)
    (dp-maybe-kill-this-buffer nil)))

(defun dp-maybe-kill-this-buffer (&optional other-window-count)
  "Kill buffer if local, else ask to kill for remote files.
This can save bandwidth.  Also good if remote site is down, since we will
keep the file around."
  (interactive "p")
  (if (Cu--p)                           ; '-
      (delete-window)
    (if (and current-prefix-arg other-window-count)
        (dp-maybe-kill-other-window-buffer (abs other-window-count))
      (if (dp-remote-file-p)
          (call-interactively 'dp-bury-or-kill-buffer)
        (when (and (not dp-save-buffer-save-p)
                   (eq last-command 'dp-save-buffer)
                   (buffer-modified-p))
          (message "Saving buffer after `dp-save-buffer'...")
          (save-buffer)
          (message "Saving buffer after `dp-save-buffer'...done."))
        (dp-kill-this-buffer)))))

(defun dp-maybe-kill-buffer (buffer)
  "Kill buffer if local, else ask to kill for remote files.
This can save bandwidth.  Also good if remote site is down, since we will
keep the file around."
  (interactive)
  (with-current-buffer buffer
    (dp-maybe-kill-this-buffer)))

(defun dp-parse-prompt-regexp (&optional ssh-prefix user-name)
  (format "^\\(%s\\)?\\(\\(%s\\)@\\(.*\\):\\([~/].*$\\)\\)"
          (or ssh-prefix dp-ssh-PS1_prefix)
          (or user-name
              (user-login-name)
              "CANNOT-DETERMINE-USERNAME")))

          
(defun dp-parse-prompt (prompt-str &optional regexp ssh-prefix user-name)
  (when prompt-str
    (string-match (dp-parse-prompt-regexp ssh-prefix user-name)
                  prompt-str))
  (dp-all-match-strings prompt-str))

(defun dp-parse-prompt-remcwd (prompt-str &optional regexp ssh-prefix user-name)
  (let ((matches (dp-parse-prompt prompt-str regexp ssh-prefix user-name)))
    (when matches
      (nth 2 matches))))

(defun dp-parse-prompt-user (prompt-str &optional regexp ssh-prefix user-name)
  (let ((matches (dp-parse-prompt prompt-str regexp ssh-prefix user-name)))
    (when matches
      (nth 3 matches))))

(defun dp-parse-prompt-host (prompt-str &optional regexp ssh-prefix user-name)
  (let ((matches (dp-parse-prompt prompt-str regexp ssh-prefix user-name)))
    (when matches
      (nth 4 matches))))

(defun dp-parse-prompt-cwd (prompt-str &optional regexp ssh-prefix user-name)
  (let ((matches (dp-parse-prompt prompt-str regexp ssh-prefix user-name)))
    (when matches
      (nth 5 matches))))

(defun dp-get-rsh-prompt (&optional buf)
  ;;
  ;; @todo-low-priority add some safety/sanity checks that the buffer
  ;; is a shell type buffer.
  (interactive)
  ;; counting on buffer order is risky...
  (let (;; E.g.: davep@sybil:~/work/timings/timer-bug/tstreams
	(prompt-regexp (dp-parse-prompt-regexp))
	cwd)
    ;;(dmessage "dp-rsh-cwd, buf>%s<" (buffer-name prev-buf))
    (with-current-buffer (or buf (dp-minibuffer-invoking-buffer))
      (goto-char (point-max))
      ;; davep@sybil:~/work/timings/timer-bug/tstreams
      (if (re-search-backward prompt-regexp nil t)
          (match-string 0)))))

(defun dp-rsh-cwd (&optional buf)
  "Go into a \(hopefully) rsh/ssh/telnet buffer and grab the prompt which gives
username@host/cwd.
Useful for editing remote files being manipulated in a rsh/telnet buffer.
The `cadr' of `buffer-list' is assumed to hold the buffer from which we wish
to extract the cwd.  This works in the assumed case of working in the 
rsh/telnet buffer before issuing a command which wants a file from the
vicinity of the cwd in the rsh/ssh/telnet buffer."
  ;;
  ;; @todo-low-priority add some safety/sanity checks that the buffer
  ;; is a shell type buffer.
  (interactive)
  (let ((wd (dp-get-rsh-prompt buf)))
    (if (string= "/" (substring wd -1))
        wd
      (concat wd "/"))))

(defvar dp-rsh-insert-tramp-cwd-p t
  "*Use `tramp' remote file name syntax.")

(defun dp-this-host-p (host)
  (or (not host)
      (string= host "")
      (string= host (dp-short-hostname))))

(defun dp-rsh-insert-cwd (&optional cwd)
  "Insert (or cwd (dp-rsh-cwd)) into current buffer surrounded by `/'s."
  (unless cwd 
    (setq cwd (dp-rsh-cwd)))
  (if cwd
      ;; Remote prompt appears thus: davep@tc-le5:~/tsat-bin
      ;; Also need to handle the case where the node needs to be fully
      ;; qualified or translated.  E.g. (until I figure out better
      ;; tunneling), at Vanu I have:
      ;; davep@timberwolves:~/work/vanu/code/c++/src.  I really read stuff
      ;; off of sentinels[aka owls].vanu.com whilst in my meduseld.net
      ;; domain.
      ;; ??? Hook into the DNS @ work?
      ;; But for now I'll make a `dp-rsh-cwd-xlat-host-name'
      ;;
      (cond
       ((dp-this-host-p (dp-parse-prompt-host cwd))
        (insert (dp-parse-prompt-cwd cwd)))
      (dp-rsh-insert-tramp-cwd-p
       (insert "/[" (replace-in-string cwd ":" "]" 'LITERAL)))
      (t
        (insert "/" cwd "/")))))

(defun dp-rsh-expand-replace-cwd ()
  "Replace preceding word with value of cwd in nearest rsh/telnet buf.
Can be called directly or by an abbrev's hook.
`wd' is defined in the minibuffer's abbrev table just so."
  (interactive)
  (dp-when-rsh-cwd
    (backward-kill-word)
    (dp-rsh-insert-cwd /cwd/)))

(defun dp-rsh-cwd-to-minibuffer ()
  "Replace the contents of the minibuffer with the cwd in the nearest rsh buf."
  (interactive)
  (dp-when-rsh-cwd
    (dp-delete-entire-line)
    (dp-rsh-insert-cwd /cwd/)))

(defun dp-find-dmessages ()
  (interactive)
  ;;^\s-*[^;\n 	].*dmessage
  (dp-grep-lisp-files "^[^;]*dmessage"))

(defun* dp-find-regexp-in-list (regexp list &optional (gettor 'identity))
  "Try REGEXP on each element of LIST using GETTOR to get the match string from the list item."
  (catch 'up
    (save-match-data
      (dolist (item list)
	(when (string-match regexp (funcall gettor item))
	  (throw 'up item))))))

(defun dp-regexp-assoc (key-regexp alist)
  "Return 1st item in ALIST where \(string-match KEY-REGEXP ALIST-key) is true."
  (dp-find-regexp-in-list key-regexp alist 'car-safe))

(defvar dp-use-saveconf-p t
  "Should we use it or not?")

(when (and dp-use-saveconf-p (dp-optionally-require 'saveconf nil))
  (setq saveconf-file-name (concat (saveconf-make-file-name)
                                   "."
                                   (dp-short-hostname)))

  (defvar dp-save-context-exclusion-regexp "\\(^/\\[\\)"
    "Regexp of filenames we DON'T want to save. E.g. remote files.")
  (setq save-context-buffer-file-name-predicate
        (function (lambda (file-name)
                    (if (not (and file-name
                                  (boundp 
                                   'dp-save-context-exclusion-regexp)
                                  dp-save-context-exclusion-regexp))
                        t
                      (not (string-match dp-save-context-exclusion-regexp
                                         file-name))))))

  (defun dp-save-context (&optional save-in-home-p current-buffer-only-p)
    (interactive "P")
    (save-excursion
      (let ((debug-on-error nil)
            (save-buffer-context (not current-buffer-only-p)))
        (with-temp-buffer			;since cd changes buffer's cd
          ;; WTF is this cd stuff? `save-context' uses
          ;; `original-working-directory' as save file's directory.
          (cd (if save-in-home-p 
                  (getenv "HOME")
                default-directory))
          (save-context)))))

  ;; Recovering context is currently not automatically done.
  (defalias 'where-was-i 'recover-context)
  (defalias 'wwi 'recover-context)

  (defun dp-recover-context-from-file (file-name)
    (interactive (list
                  (dp-prompt-with-symbol-near-point-as-default 
                   "Context file:" 
                   :symbol-type (cons 'f saveconf-file-name)
                   :reader-args (list "~/" nil t))))
    (let ((saveconf-file-name file-name))
      (recover-context)))
  (defalias 'wwif 'dp-recover-context-from-file)
  
  (defun dp-recover-context (&optional prompt-for-file-name-p)
    (interactive "P")
    (if prompt-for-file-name-p
        (call-interactively 'dp-recover-context-from-file)
      (recover-context)))
  (defalias 'wwi 'dp-recover-context)
  
  (defun dp-edit-recover-context-file ()
    (interactive)
    (find-file (saveconf-get-filename)))
  (defalias 'ewwi 'dp-edit-recover-context-file)
  
  ;; A pretty sensible place to save the context.
  ;; Others would be when a file is unvisited (no hook)
  ;; When a file is saved? I save a **LOT**. But this is pretty lightweight.
  (loop for hook in '(find-file-hooks after-save-hook 
                      dp-after-kill-this-buffer-hook)
    do (add-hook hook 'dp-save-context)))

;;
;; // Add new macros
;;

;;;
;;; temporary, unique variable name support.
;;;
(defconst dp-gentemp-prefix "dp-gentemp-")
(defun dp-gentemp (&optional prefix oba)
  "Generate a tmp unique variable and return its symbol.
Use `gentemp' and pass PREFIX and the obarray OBA if non-nil.  If PREFIX
begins with a single plus `+', then PREFIX is concatenated to the end of the
default PREFIX `dp-gentemp-prefix'.  If you want a PREFIX that begins with
one or mode pluses (q.v.) then escape it. A leading \ is the only escape I
handle here.  Putting a backslash in a variable name is just plain stupid and
I refuse to allow you to do it.  For your own good.

PREFIX    result
------    ------
+xxx  --> DEF<xxx>
++xxx --> DEF+<xxx>
\+xxx --> +xxx
"
  (let ((obarray (or oba obarray)))
    (and prefix
         (string-match "%s.*" prefix)
         (or (and (string= (substring prefix 0 1) "+")
                  (setq prefix (concat dp-gentemp-prefix (substring prefix 1))))
             (and (string= (substring prefix 0 1) "\\")
                   (setq prefix (substring prefix 1)))))
    (gentemp (or prefix dp-gentemp-prefix))))

(defun dp-setq-tmp-name (val &optional arg oba)
  "Create, set and return the name of a unique generated tmp variable.
Set the new var to VAL.  
Return the variable's name as a string.
ARG is passed to `gentemp' (q.v.).
The var is interned into obarray OBA if non-ni, 
 otherwise the global `obarray'."
  (let ((sym (dp-gentemp arg oba)))
    (set sym val)
    (format "%s" sym)))

(defun dp-gentemp-uninterned (prefix &optional buffer-local-p bl-default)
  (let ((sym (make-symbol (dp-serialized-name prefix nil))))
    (when buffer-local-p
      (make-variable-buffer-local sym)
      (set-default sym bl-default))
    sym))

(defun dp-deref-symbol-name (name &optional oba)
  "Get the value of the variable named NAME, from obarray OBA.
If OBA is nil, use `obarray'."
  (eval (intern name oba)))

(defun pbtemp1 ()
  (interactive "*")
  (beginning-of-line)
  (forward-line -2)
  (py-newline-and-indent)
  (pbtemp))

(defun dp-mk-shell-script ()
  (interactive)
  (dp-end-of-buffer)
  (insert "#
### Local Variables: ***
### mode:sh ***
### comment-start: \"#\" ***
### comment-end: \"\" ***
### End: ***
"))

;;; don't let the above force us into shell script mode!!!!!!!
;;; make sure it isn't on the last page.


(defun dp-set-eof-spacing (&optional num-lines)
  "Add spacing to EOF to ensure `num-lines' blank lines at eof."
  (interactive "*")
  (let* (add-str
         (num-lines (or num-lines 1))
         (lines (mapconcat 'identity (make-list (1+ num-lines) "\n") ""))
         (bs0 (concat "[^" dp-ws+newline "]"))
         (bs (concat bs0 bs0 "*"))
         (fs (concat "[" dp-ws+newline "]*")))
    (goto-char (point-max))
    ;; ensure we have at least one newline to match at EOB
    (insert "\n")
    (when (re-search-backward bs (point-min) t)
      (forward-char)
      ;;(insert "<<<<<<<<<<<<<<<<<<<")
      (re-search-forward fs (point-max))
      ;;(dmessage "match-string>%s<" (match-string 0))
      (replace-match lines))))

(defun dp-str-sub (index string &optional len)
  (interactive "Nindex: \nsstring: ")
  (substring string index (+ (or len 1) index)))
            
(defun other-window1 ()
  "Convenience func for IPython mode"
  (other-window 1))

(defadvice mouse-track (around dp-mouse-track activate)
  "dp-push-go-back advised `mouse-track'."
  (interactive "e")  
  (let* (text
         (event (ad-get-arg 0))
         (e-window (event-buffer event))
         (c-window (current-buffer))
         (e-point (event-point event))
         (c-point (point)))
;     (dmessage "event: %s" event)
;     (dmessage "e-window: %s, c-window: %s" e-window c-window)
;     (dmessage "e-point: %s, c-point: %s" e-point c-point)
;     (dmessage "w-diff: %s, p-diff: %s" (not (equal e-window c-window))
;               (> (abs (- (or e-point 0) (or c-point 0)))
;                  dp-go-back-min-distance))
    (when (or (not (equal e-window c-window))  ; In different window?
              (> (abs (- (or e-point 0) (or c-point 0)))
                 dp-go-back-min-distance)) ; Far enough away?
      (dmessage "squeak!")
      (dp-push-go-back "advised mouse-track"))
    ad-do-it
    (when (and (eq (event-button event) 2)
               (not (eq c-point (point))))
      (setq text (buffer-substring c-point (point)))
      (when (and text kill-ring 
                 (not (string= text (current-kill (length kill-ring) t))))
        ;;(dmessage "kill-new>%s<" text)
        (kill-new text)))))

(defun dp-beginning-of-def-or-class (&optional no-class-precedence-p visible-p)
  (interactive "_P")
  (let ((opoint (point-marker))
        (re (concat "^\\(" (if nil
                               "\\s-*"
                             "")
                    "\\("
                    "\\(def\\|class"
                    (if (eq major-mode 'ruby-mode)
                        "\\|module"
                      "")
                    "\\)\\s-+"
                    "\\)"
                    "\\|\\("
                    "if\\s-+__name__\\s-+==\\s-+.__main__."
                    "\\)"
                    "\\)")))
    ;; WTFF was this supposed to do?"\\|\\(^[a-zA-Z_].*:\\s-*\\)$")))
    (dmessage "re>%s<" re)
    ;; most convenient for me is to go to the previous top-level
    ;; construct
    
    (re-search-backward re nil t)
    (redisplay-frame)
    (unless (and visible-p 
                 (pos-visible-in-window-p opoint))
      ;;(message "go back saved(%s)." opoint)
      (when (/= (point) opoint)    ;Don't set if we didna go anywhere.
        (dp-push-go-back "dp-py-beginning-of-def-or-class" opoint)))))

(defun dp-capitalize-position-point ()
  "Determine the position at which I'd like to perform one of my non-standard capitalization functions."
  (interactive)
  (save-excursion
    (when (and (not (looking-at "\\<"))
               (or (not (looking-at "\\b\\|\\s-"))
              (dp-looking-back-at "\\S-")))
      (backward-word))
    (point)))
  
(defun dp-goto-capitalize-position-point ()
  "Go to the brilliantly factored `dp-capitalize-position-point'."
  (interactive)
  (goto-char (dp-capitalize-position-point)))

(defun dp-capitalize-word (count &optional buffer)
  "Go to beginning of word unless already there or between words.
Was done by `defadvice' but that breaks other things.  Change all
`capitalize-word' to use this new function.  I suppose I could conditionalize
on interactiveness, but due to cases like this, I'm trending away from
`defadvice'."
  (interactive )
  (dp-goto-capitalize-position-point)
  (capitalize-word))

;;moving away from defadvice; (defadvice capitalize-word (before dp-capitalize-word activate)
;;moving away from defadvice;   "Go to beginning of word unless already there or between words."
;;moving away from defadvice;   (dp-goto-capitalize-position-point))

(defun dp-toggle-capitalization (num-words)
  "Toggle case of character at the beginning of the current NUM-WORDS words."
  (interactive "*p")
  (save-excursion
    (dp-goto-capitalize-position-point)
    (with-narrow-to-region (point) (1+ (point))
      (call-interactively
       (if  (let (case-fold-search)
              (looking-at "[A-Z]"))
           'downcase-region-or-word
         'capitalize-region-or-word)))
      ;; Give 'em point so they can undo the `save-excursion'
    (point)))

(defadvice join-line (before dp-join-line activate)
  "Invert sense of arg  since I prefer joining next line to current."
  (interactive "*P")
  (ad-set-arg 0 (not (ad-get-arg 0))))

(defadvice zap-to-char (before dp-zap-to-char (arg char) activate)
  "Change ^M to newline so <Enter> as the zapped to char works better."
  (interactive "*p\ncZap to char: ")
  (if (eq ?
 char)
      (setq char ?
)))

(defadvice zap-up-to-char (before dp-zap-up-to-char (arg char) activate)
  "Change ^M to newline so <Enter> as the zapped up to char works better."
  (interactive "*p\ncZap up to char: ")
  ;Convert CR to newline.
  (if (eq ?
 char)
      (setq char ?
)))                                     ;A quoted newline is above after the ?.

; (defadvice beginning-of-defun (around dp-beginning-of-defun activate)
;   "Advised to push-go-back."
;   (let ((pt (point-marker)))
;      ad-do-it
;      (when (save-excursion
;           (beginning-of-line)
;           (looking-at "(def"))
;        (dp-push-go-back "beginning-of-defun" pt))))

(defun dp-try-to-fix-effin-isearch (&optional keep-ext)
  (interactive "P")
  (call-interactively 'describe-bindings)
;   (with-current-buffer (get-buffer "*scratch*")
;     (dp-end-of-buffer)
;     (ts)
;     (describe-bindings-1))

  (dmessage "minor-mode-alist>%s<" minor-mode-alist)
  (dmessage "minor-mode-map-alist>%s<" minor-mode-map-alist)
  (dmessage "overriding-local-map>%s<" overriding-local-map)
  (dmessage "current-local-map>%s<" (current-local-map))
  (setq overriding-local-map nil)
  (use-local-map nil)
  (setq minor-mode-alist
        (delete '(isearch-mode isearch-mode-line-string) minor-mode-alist)
        minor-mode-map-alist
        (delete (list 'isearch-mode isearch-mode-map) minor-mode-map-alist))
  (isearch-done)
  (isearch-exit)
  (isearch-cancel)
  (isearch-abort)
  (isearch-dehighlight)
  (setq isearch-mode nil)
  (setq isearch-string nil)
  (define-key isearch-mode-map "\C-s" 'isearch-forward)

  (and (not keep-ext)
       (extentp isearch-extent)
       (extent-live-p isearch-extent)
       (delete-extent isearch-extent))
)

(defvar orig-tabify 'tabify)
(defun dp-tabify (&optional s e)
  (interactive "*")
  (if (dp-mark-active-p)
      (call-interactively 'tabify)
    (tabify (point-min) (point-max))))

(defun dp-cb-string-match (string regexp &rest rest)
  "A predicate function used by `dp-choose-buffers'."
  (apply 'string-match regexp string rest))

(defun* dp-choose-buffers (predicate &optional (buffer-list (buffer-list))
                           &rest pred-args)
  "Return the subset of BUFFER-LIST that pass PREDICATE.
If BUFFER-LIST is nil, then use `buffer-list'.
If PREDICATE is a string, then it is assumed to be a regexp.
Otherwise, PREDICATE is `apply'd to the buffer and PRED-ARGS."
  (interactive "sreg-exp: ")
  (let* (regexp)
    (when (stringp predicate)
      (setq pred-args (list predicate) ;the regexp
            predicate (function
                       (lambda (buf regexp &rest rest)
                         (apply 'dp-cb-string-match 
                                (buffer-name buf) regexp rest)))))
    (delq nil
          (mapcar (function
                   (lambda (buf)
                     (if (apply predicate buf pred-args)
                         buf
                       nil)))
                  buffer-list))))

(defun dp-regexp-find-buffer (regexp &optional buffer-list)
  "Return first BUFFER matching regexp in BUFFER-LIST.
If BUFFER-LIST is nil, get the buffer list with `buffer-list'."
  (interactive "sregexp? ")
  (when regexp
    (car (dp-choose-buffers regexp buffer-list))))

(defun dp-find-primary-makefile-buffer ()
  "Find a buffer marked as containing our favorite makefile."
  (interactive)
  (dp-choose-buffers
   (function
    (lambda (buf &rest args)
      (buffer-local-value 'dp-primary-makefile-p buf)))))

(defun dp-choose-buffers-names (predicate &optional buffer-list
                                &rest pred-args)
  (interactive "sreg-exp: ")
  (mapcar (function
           (lambda (buf)
             (buffer-name buf)))
          (dp-choose-buffers predicate buffer-list pred-args)))

(defun dp-get-dired-visited-dir (buf)
  "Get the directory name in a buffer dired is visiting.
`dired-directory' is buffer local and defaults to nil so we need to get it in
the context of BUF."
  (with-current-buffer buf
    dired-directory))

;; !<@todo XXX Change dired-too-p to something more generic.
;; Like another regexp for exclusion.
(defun dp-choose-buffers-file-names (name-regexp &optional dired-too-p)
  "Return a list of buffers whose name match NAME-REGEXP.
DIRED-TOO-P means to match directory names in dired buffers."
  (interactive "sname reg-exp: \nP")
  (dp-choose-buffers (function
                      (lambda (buf &rest rest)
                        (let* ((file-name (buffer-file-name buf))
                               (dired-dirname
                                (and dired-too-p
                                     (not file-name)
                                     (dp-get-dired-visited-dir buf))))
                          (or (and file-name
                                   (string-match name-regexp file-name))
                              (and dired-dirname
                                   (string-match name-regexp
                                                 dired-dirname))))))))

(defvar dp-kill-these-file-buffers-case-fold-search nil
  "Should we fold case when matching file/buffer names?
I like to be more precise in certain cases; such as when deleting things.")

(defun dp-choose-buffers-mode-names (mode-name-regexp)
  "Return a list of buffers whose major mode name matches MODE-NAME-REGEXP."
  (interactive "sname reg-exp: ")
  (dp-choose-buffers (function
                      (lambda (buf &rest rest)
                        (with-current-buffer buf
                          (string-match mode-name-regexp mode-name))))))

(defun dp-kill-chosen-buffers (buffer-list)
  (mapcar (function
           (lambda (buf)
             (kill-buffer buf)))
          buffer-list)
  (when (eq major-mode 'Buffer-menu-mode)
    (dp-refresh-buffer-menu)))

(defun dp-kill-buffers-by-name (name-regexp &optional
                                skip-dired-buffers-p
                                all-p)
  (interactive "sname regexp: \nP")
  (with-case-folded dp-kill-these-file-buffers-case-fold-search
    (when all-p
      (concat name-regexp "<[0-9]+>"))
    (dp-kill-chosen-buffers
     (dp-choose-buffers-file-names
      name-regexp (not skip-dired-buffers-p)))))

;;     (mapcar (function
;;              (lambda (buf)
;;                (kill-buffer buf)))
;;             (dp-choose-buffers-file-names
;;              name-regexp (not skip-dired-buffers-p)))))

(defun dp-kill-.el-buffers (&optional with-extreme-prejudice-p)
  "Kill all of the buffers holding elisp files."
  (interactive "P")
  (mapcar (function
           (lambda (buf)
             (if with-extreme-prejudice-p
                 (kill-buffer buf)
               (call-interactively
                (key-binding [(meta ?-)])))))
          (dp-choose-buffers-file-names ".*\\.el$")))

(defun dp-kill-buffers-by-mode (mode-name-regexp)
  (interactive "sname reg-exp: ")
  (dp-kill-chosen-buffers
   (dp-choose-buffers-mode-names mode-name-regexp)))

;;   (mapcar (function
;;            (lambda (buf)
;;              (kill-buffer buf)))
;;           (dp-choose-buffers-mode-names mode-name-regexp)))

(defun dp-kill-dired-buffers ()
  (interactive)
  (dp-kill-buffers-by-mode "Dired"))

(defun dp-kill-code-indexer-data-buffers (all-p)
  (interactive "P")
  (dp-kill-buffers-by-name
   (dp-regexp-concat dp-code-indexer-data-files
                     nil t)
   nil all-p))

(defun dp-kill-sandbox-buffers (sandbox-name &optional all-p)
  "Kill all buffers visiting files in SANDBOX-NAME."
  (interactive "ssandbox of buffers to kill: \nP")
  (dp-kill-buffers-by-name
   (concat "/davep/work/" sandbox-name "/")
   t all-p))
(dp-safe-alias 'dp-kill-buffers-by-sandbox 'dp-kill-sandbox-buffers)

(defalias 'dp4-kill-client-buffers 'dp-kill-sandbox-buffers)

(defvar dp-default-makefile-name '()
  "List of functions to call, in order, until one returns a file name.")

(defvar dp-default-makefile-names '("Makefile" "makefile")
  "Regexp(s) that identify files as make files.")

(defun dp-default-make-makefile-name (&optional starting-dir top-dir)
  "Default function to try to find a makefile."
  (setq-ifnil starting-dir (default-directory))
  (dp-multi-search-up-dir-tree starting-dir dp-default-makefile-names top-dir))

(add-hook 'dp-default-makefile-name 'dp-default-make-makefile-name)


(defun dp-buffer-name< (b1 b2)
  (interactive)
  (string< (buffer-name b1) (buffer-name b2)))

(defvar dp-make-command "make -k"
  "Default command used to `make' systems.")

(defun dp-make-make-command (&optional makefile)
  (interactive)
  (let* ((def-makefile (or makefile
                           (and-boundp 'dp-default-makefile-name
                             (stringp dp-default-makefile-name)
                             (expand-file-name dp-default-makefile-name))
                           (and-boundp 'dp-default-makefile-name
                             (listp dp-default-makefile-name)
                             (run-hook-with-args-until-success 
                              'dp-default-makefile-name))
                           (and-fboundp 'dp-default-makefile-name
                             (funcall dp-default-makefile-name))))
         (buf (or (and (not makefile)
                       (car-safe (dp-find-primary-makefile-buffer)))
                  (when def-makefile
                    (or (find-buffer-visiting def-makefile)
                        (when (file-readable-p def-makefile)
                          (find-file-noselect def-makefile)
                          (find-buffer-visiting def-makefile))))
                  (car-safe 
                   (sort (dp-choose-buffers
                          "^[Mm]akefile.*$") 
                         'dp-buffer-name<))))
         (file-name (if buf (buffer-file-name buf))))
    (if file-name
        (list (format "%s -f %s" dp-make-command file-name) 
              file-name buf)
      nil)))

(defvar dp-make-targets-history nil
  "History for make targets. There's no benefit to sharing the entries.")

(defvar dp-make-makefile-relative-name t
  "*Tells dp-make to show the make-file's name relative to the default dir.")

(dp-deflocal-permanent dp-primary-makefile-p nil
  "Non-nil if this is the currently chosen makefile buffer.
This buffer will be used preferentially.")

;; The compilation process seems to kill all local variables, so the config
;; is saved before all compiles even if the compilation buffer isn't killed
;; in between.
(dp-deflocal-permanent dp-saved-window-config nil
  "Have we pushed a window config for this buffer yet?")

(defvar dp-mru-make-target nil
  "The most recent thing we asked make to make.")

(defvar dp-mru-make-makefile nil
  "The most recently used makefile.")

(defvar dp-mru-make-command nil
  "The last make command.")

(defvar dp-mru-make-compile-arg nil
  "The last arg to `compile'.
Just for informational purposes.")

(defvar dp-make-makefile-history ()
  "Makefiles I have known.")

(defun* dp-make (&optional choose-make-file-p remake-p
                 (absolute-makefile-name-p t))
  (interactive "P")
  (let* ((chosen-make-file (when choose-make-file-p
                             (expand-file-name
                              (read-file-name "Makefile: " nil t nil))))
         (make-command (if (and remake-p dp-mru-make-command)
                           dp-mru-make-command
                         (dp-make-make-command chosen-make-file)))
         (original-window-config (current-window-configuration))
         (makefile-buffer (nth 2 make-command))
         (target (and remake-p dp-mru-make-target))
         prompt)
    (when (Cu-p 2)
      (dp-set-primary-makefile t makefile-buffer))
    (setq dp-make-targets-history (delete "" dp-make-targets-history))
    (when (and dp-use-dedicated-make-windows-p
               (or (eq major-mode 'compilation-mode)
                   (dp-buffer-live-p compilation-last-buffer)))
      (set-window-dedicated-p (dp-get-buffer-window compilation-last-buffer)
                              nil))
    (if make-command
        (progn
          (setq prompt (format "target in %s: " (nth 1 make-command))
                target (or target (read-from-minibuffer 
                                   prompt dp-mru-make-target nil nil 
                                   'dp-make-targets-history)))
                
          ;; cannot remake if there's no target.
          (when (and dp-mru-make-target 
                     (member target '("=" "==" ".")))
            ;; We won't ask for the target name again so we won't loop
            ;; keep recursing.
            (dp-remake)
            (return-from dp-make))
          (setq dp-mru-make-target target)
          (with-current-buffer makefile-buffer
            (setq dp-mru-make-makefile (buffer-file-name))
            ;;Protect this buffer from unintentional killing
            (dp-define-buffer-local-keys '([(meta ?-)] 
                                           dp-bury-or-kill-buffer))
            ;; If this is set, then makes in other dirs which have their own
            ;; makefiles will still use this buffer as their base of
            ;; compilations. This can be good or bad, depending on the
            ;; situation.
            ;;(dp-set-primary-makefile 1)
            (setq dp-mru-make-compile-arg 
                  (format "%s %s" (car make-command) target)
                  dp-mru-make-command make-command)
            (compile dp-mru-make-compile-arg)))
      (call-interactively 'compile))
    (dp-layout-compile-windows original-window-config)
;     (unless (one-window-p)
;       (end-of-buffer-other-window nil))
    )
  )

;; !<@todo XXX Refactor more from dp-make.
(defun dp-remake ()
  "Remake using last setup."
  (interactive)
  (if (not dp-mru-make-compile-arg)
      (dp-ding-and-message "No last make information")
    (message "remaking: %s" dp-mru-make-command)
    (dp-make nil t)))

(dp-safe-aliases 'remk 'rmk 'remake 'dp-remake)

(defun dp-find-compilation-buffer (&optional creat-p)
  "Go to the compilation buffer."
  (interactive "P")
  ;; Don't want to use `compilation-last-buffer' since it considers greps,
  ;; etc, to be compilation buffers.
  (if (setq b (funcall (if creat-p
                           'get-buffer-create
                         'get-buffer)
            "*compilation*"))
      (switch-to-buffer b)
    (message "No compilation results buffer yet.")))

(defalias 'cb 'dp-find-compilation-buffer)

(defun dp-maybe-select-other-frame ()
  "Select another frame it one exists.
Return t if there is only one frame."
  (interactive)
  (eq (selected-frame) (select-frame (next-frame))))

(defun dp-c-semi&comma-nada ()
  "Suppress ALL ;-instigated new-linery.
I like the other things (e.g. cleanups) that are available in auto-newline
mode but not the new lines themselves.  Hence, this."
  (interactive)
  (if (eq last-command-char ?\;)
      'stop
    ;; not a semi, keep trying.
    nil))

(defalias 'cabbrev 'define-mode-abbrev)
(defalias 'labbrev 'define-mode-abbrev)

(defun dma ()
  "Help insert a `define-mode-abbrev' into a file."
  (interactive "*")
  (let ((p (point)))
    (insert comment-start
            ":(define-mode-abbrev "
            "\"\" "
            "\"\" ): "
            comment-end)
    (goto-char p)
    (search-forward "\"")))

(defun dp-chase-file-link (file-name point &optional regexp limit error)
  (interactive)
  (dp-push-go-back "dp-chase-file-link")
  (apply (if current-prefix-arg
             'find-file
           'find-file-other-window)
         (list (expand-file-name file-name)))
  (when regexp
    (with-saved-match-data
     (dp-search-with-wrap regexp point limit error))))
  
(defalias 'cfl 'dp-chase-file-link)

(defun dp-c-delimit-statement (&optional beg end)
  "Returns cons of first char and last char of (not after) statement, or
the boundaries region if it is active."
  (or (dp-mark-active-p)
      (if beg
          (cons beg end)
        (save-excursion
          (end-of-line)
          (cons (progn
                  (dp-c-beginning-of-statement)
                  (point))
                (progn
                  (c-end-of-statement)
                  (1- (point))))))))

(defun dp-mk-marker (&optional pos buffer type)
  "Make a marker at POS or (point) in BUFFER or (current...) if nil.
Set type of marker to TYPE (see `set-marker-insertion-type')."
  (let ((m (set-marker (make-marker) (or pos (point)) buffer)))
    (set-marker-insertion-type m type)
    m))
      
(defun dp-c-flatten-statement (&optional beg end)
  "Put all of a statement on one line."
  (interactive "*")
  (let* ((beg-end (dp-c-delimit-statement))
         (beg (dp-mk-marker (or beg (car beg-end))))
         (end (dp-mk-marker (or end (cdr beg-end)))))
    (save-excursion
      (goto-char beg)
      (while (< (line-end-position) end)
        (join-line))
      (beginning-of-line)
      (dp-c-indent-command))))

(defun* dp-match-contiguous-lines (regex &optional 
                                   (shrink-wrap-p 
                                    dp-colorize-lines-shrink-wrap-p-default))
  "Return a \(cons beg end) of a contiguous range of matching lines.
Beginning is the beginning of line of the first matching line and
end is the end of the last matching line."
  (interactive "sregex: ")
  (when (re-search-forward regex nil t)
    (cons (if shrink-wrap-p
              (match-beginning 0)
            (line-beginning-position))
          (if shrink-wrap-p
              (match-end 0)
            (beginning-of-line)
            (forward-line 1)
            (while (re-search-forward regex (line-end-position) t)
              (forward-line 1))
            (forward-line -1)
            (if shrink-wrap-p
                (match-end 0)
              (line-end-position))))))

(defun dp-re-search-forward-not-in-a-string (&rest re-search-args)
  "Search forward using RE-SEARCH-ARGS for a match not in a string."
  (let (mpos)
    (while (and (setq mpos (apply 're-search-forward re-search-args))
                (dp-in-a-string)))
    mpos))

(defun dp-c-stack-statement (&optional split-at-regexp repl 
                             before-p after-first-p
                             beg end)
  "Split statement at split-at-regexp, before regexp else before if before-p non nil."
  (interactive "*")
  (let* ((split-at-regexp (or split-at-regexp "\\s-*,\\s-*"))
         (repl (or repl ","))
         (beg-end (dp-c-delimit-statement))
         (beg (or beg (dp-mk-marker (car beg-end))))
         (end (or end (dp-mk-marker (cdr beg-end))))
         (repl (if before-p (concat "\n" repl)
                 (concat repl "\n"))))
    (dp-c-flatten-statement beg end)
    (save-excursion
      (goto-char beg)
      (if after-first-p
          (dp-re-search-forward-not-in-a-string split-at-regexp end t))
      (while (dp-re-search-forward-not-in-a-string split-at-regexp end t)
        (save-excursion
          (replace-match repl)
          (beginning-of-line)
          (dp-c-indent-command)))
      (list beg end))))
(defalias 'css 'dp-c-stack-statement)

(defun dp-c-stack-rest-of-statement (&optional end beg)
  (interactive)
  (dp-c-stack-statement nil nil
                        nil nil 
                        (or beg (point))
                        (or end (save-excursion
                                  (c-end-of-statement)
                                  (point)))))

(defun dp-c-stack-iostream ()
  (interactive "*")
  (dp-c-stack-statement "\\s-*\\(<<\\|>>\\)\\s-*" "\\1 " 'before 'after-first))
(defalias 'csi 'dp-c-stack-iostream)

(defun dp-c-fill-statement (&optional max-line-len rest-of-statement beg end)
  (interactive)
  (dmessage "HANDLE spaces after opening (")
  (save-excursion
    (unless rest-of-statement
      (end-of-line)
      (dp-c-beginning-of-statement))
    (let* ((beg-end (if (re-search-forward "<<\\|>>" (line-end-position) t)
                        (dp-c-stack-iostream)
                      (if rest-of-statement
                          (dp-c-stack-rest-of-statement)
                        (dp-c-stack-statement nil nil nil nil beg end))))
           (end (dp-mk-marker (car (cdr beg-end))))
           (max-line-len (dp-c-fill-column max-line-len)))
      (while (< (line-end-position) end)
        (join-line)
        (unless (<= (- (line-end-position) (line-beginning-position)) 
                    max-line-len)
          (c-context-line-break))))))
(defalias 'cfs 'dp-c-fill-statement)
    

(defun* dp-c-delimit-func-decl (&optional use-markers-p)
  "Find boundaries of a function definition."
  (save-excursion
    (let (beg end)
      (beginning-of-line)
      (if (looking-at ".*{")
          (goto-char (1- (match-end 0)))
        (end-of-line))
      (dp-c-beginning-of-statement)
      (setq beg (point))
      (unless (re-search-forward "(" nil t)
        (dp-ding-and-message "No opening paren in `dp-c-delimit-func-decl'.")
        (return-from dp-c-delimit-func-decl))
      ;; See if we moved into a different statement.
      (unless (= (dp-c-beginning-of-statement-pos) beg)
        (dp-ding-and-message "Problem finding beginning of statement.")
        (return-from dp-c-delimit-func-decl))
      (backward-char 1)
      (dp-find-matching-paren-including-<)
      (setq end (point))
      (cons (if use-markers-p
                (dp-mk-marker beg)
              beg)
            (if use-markers-p
                (dp-mk-marker end)
              end)))))
  
(defun dp-mark-region (beg-end-cons &optional end-if-not-a-cons)
  "Mark the region indicated by BEG-END-CONS.
BEG-END-CONS has the form: \(beginning-of-region . end-of-region\).
Do nothing if BEG-END-CONS is nil.
As an bonus feature, if BEG-END-CONS is not a cons, then assume BEG-END-CONS
is the region's beginning and END-IF-NOT-A-CONS is the region's end.
Returns the ultimate value BEG-END-CONS."
  ;; 
  (unless (consp beg-end-cons)
    (setq beg-end-cons (cons beg-end-cons end-if-not-a-cons)))
  (when (and (car beg-end-cons) (cdr beg-end-cons))
    (dp-set-mark (car beg-end-cons))
    (goto-char (cdr beg-end-cons)))
  beg-end-cons)

;; new
(defun dp-c-flatten-func-decl ()
  "Put all function parameters on the same line."
  (interactive "*")
  (undo-boundary)
  (let* ((beg-end (dp-c-delimit-func-decl t))
         (beg (car beg-end))
         (end (cdr beg-end)))
    ;; Only do this if we could delimit a decl.
    (when (and beg end)
      (with-narrow-to-region beg end
        (goto-char beg)
        (while (< (point) (point-max))
          (beginning-of-line)
          (join-line)))
      (goto-char end)
      (when (looking-at "\\s-*{\\s-*")
        (replace-match "\n{"))
      (beginning-of-line)
      (dp-c-indent-command)
      (goto-char beg)
      (cons beg end))))

(defun dp-look-ahead (&rest re-search-fwd-args)
  "Do a re-search-forward inside a `save-excursion'."
  (save-excursion
    (apply 're-search-forward re-search-fwd-args)))

(defvar dp-c-format-func-decl-align-p-default nil
  "Should the args be lined up with `align'?")

(defconst dp-c-format-func-decl-packed-p nil
  "Fill a function declaration by putting as many parameters on each line as
will fit.  Like filling a function currently as of: 2011-11-18T10:21:02
is done.")

;; Older version here:
;; :(cfl "devel/elisp-devel.el" 344636 "^"):
(defun* dp-c-format-func-decl (&optional 
                               (add-nl-after-open-paren-p
                                dp-c-add-nl-after-open-paren-default-p)
                               (add-opening-brace-p t)
                               (type-on-separate-line-p nil)
                               (align-p dp-c-format-func-decl-align-p-default))
  "Format a C/C++ function definition header *my* way."
  (interactive (list current-prefix-arg))
  (undo-boundary)
  (let ((start-pos (dp-mk-marker))
        (final-position (point-marker))
        ;;; ???syntactic-region
        old-point
        decl-bounds
        open-paren-marker close-paren-marker)
    (end-of-line)
    ;; Don't do anything if we backup into a different syntactic region.
    ;; This is b0rked.
    ;; 
    ;; -!-function(a,
    ;;          b,
    ;; -!-      c)
    ;; Lower point is arglist-cont
    ;; upper, got to by dp-c-beginning-of-statement, is topmost intro.
    ;; We'll need something else to say if we've gone too far.
    ;; Fixed this case. In class. Don't know if it's a problem outside.
    ;;    void pmsg_start_seq_sync(
    ;;-!-     FTCI_message_t* response,
    ;;    {
    ;; M-ret packs waaaay too much junk.
    ;; !<@todo XXX 
    ;; This seems wrong in too many places. I'm removing it and will look for
    ;; a more specific fix to the original problem.
    ;; at this time: 2012-03-08T12:00:27 
    ;; It seems like this is a problem when we move into a new region *after*
    ;; point. Lets try adding that condition.
    ;;(setq syntactic-region (dp-c-get-syntactic-region))
    (setq old-point (point))
    (dp-c-beginning-of-statement)
    ;;(unless (or (equal syntactic-region (dp-c-get-syntactic-region))
    ;;            (<= (point) old-point))
    ;;  (goto-char old-point)
    ;;  (return-from dp-c-format-func-decl nil))
    (beginning-of-line)
    (setq decl-bounds (dp-c-flatten-func-decl))
    ;; Or skip past any member init before looking for {.
    (dmessage 
     "look for \"<ws>*:\" to detect member init and suppress adding \"{\"")
    (unless decl-bounds
      (goto-char old-point)
      (return-from dp-c-format-func-decl nil))
    ;;!<@todo why do I have void here?  To shrink wrap w/o spaces?
    (if (dp-look-ahead "(\\s-*\\(void\\)?\\s-*)" (line-end-position) t)
        (progn
          (setq open-paren-marker (match-beginning 0))
          (replace-match "(void)")
          (setq close-paren-marker (dp-mk-marker (1- (point)))))
      (if (not (search-forward "(" (line-end-position) t))
          (error "No open paren found."))
      (setq open-paren-marker (1- (dp-mk-marker)))
      (when add-nl-after-open-paren-p
        (replace-match "(\n")
        (beginning-of-line)
        (c-indent-line))
      (if dp-c-format-func-decl-packed-p
          (let* ((be (dp-c-delimit-func-decl))
                 (e (dp-mk-marker(cdr be))))
            (dp-c-fill-statement nil nil nil
                                 (dp-mk-marker (1+ e)))
            ;; Leave ourselves position for the ) check which allows us
            ;; to add an opening { if needed.
            (goto-char e)
            (beginning-of-line))
        (while (re-search-forward ",\\|\\([^:]\\)\\(:\\)\\([^:].*,\\)"
                                  (line-end-position) t)
          ;; Handle constructor initializers.
          (if (string= (match-string 2) ":")
              (save-excursion
                (replace-match "\\1\n:\n\\3")
                (forward-line -1)
                (beginning-of-line)
                (c-indent-line))
            (replace-match ",\n"))
          (c-indent-line)))
      (beginning-of-line)
      (c-indent-line)
      (unless close-paren-marker
        (setq close-paren-marker
              (dp-mk-marker (save-excursion
                              (beginning-of-line)
                              ;; No match (ie failure) is not an option.
                              (search-forward ")" (line-end-position))))))
      (when (and add-opening-brace-p
                 (re-search-forward ")" (line-end-position) t))
        (dp-c-ensure-opening-brace :force-newline-after-brace-t nil)))
    (goto-char open-paren-marker)
    ;; Put function name on a line by itself after any preceding type, etc,
    ;; info.
    (when (and type-on-separate-line-p
               (re-search-backward "\\(\\S-+\\)\\s-+"
                                   (line-beginning-position) t))
      (replace-match "\\1\n")
      (c-indent-line))
    (beginning-of-line)
    (when (and (dp-in-c++-class)
               (re-search-forward (format "%s::" (symbol-near-point))
                                  (line-end-position) t))
      (dmessage "only remove this class's name")
        ;;;(replace-match "")
      )
    ;; If we were(are) positioned at the closing paren, move down a line.
    ;; This is useful for typing in all args and then filling after.  This
    ;; puts the cursor into the function definition area.
;     (when (and close-paren-marker
;                (equal close-paren-marker (point)))
;       (forward-line 1))
    (goto-char close-paren-marker)
    (unless (eobp) (forward-char 1))
    (and add-opening-brace-p
         (dp-c-ensure-opening-brace :force-newline-after-brace-t t))
    (when align-p
      (align (car decl-bounds) (1+ (cdr decl-bounds)))))
  t)

(defalias 'ffd 'dp-c-format-func-decl)

(defun dp-c-format-func-decl-packed ()
  (interactive)
  (let ((dp-c-format-func-decl-packed-p t))
    (dp-c-format-func-decl)))

(defalias 'ffdp 'dp-c-format-func-decl-packed)

(defun dp-c-format-func-call (&optional max-line-len)
  "Format a C/C++ function call *my* way."
  (interactive "*P")
  (setq-ifnil max-line-len (dp-c-fill-column 
                        (and max-line-len (prefix-numeric-value max-line-len))))
  (undo-boundary)
  (save-excursion
    (dp-c-format-func-decl)
    (end-of-line)
    (dp-c-beginning-of-statement)
    (while (not (re-search-forward ")\\s-*\\([;]\\)\\s-*$\\|{" ;??? Only ; ???
                                   (line-end-position) t))
      (beginning-of-line)
      (join-line)
      (if (<= (- (line-end-position) (line-beginning-position)) 
              (dp-c-fill-column max-line-len))
          ()
        (c-context-line-break)))
    (when (string= (match-string 0) "{")
      (replace-match "\n{")
      (dp-c-indent-command)
      (when (not (looking-at "\\s-*$"))
        (end-of-line)
        (insert "\n")))))

(defun dp-choose-efl-insertion-buffer ()
  "Choose a buffer into which we will insert an external bookmark.
The most common dest is the (most) current journal file."
  (interactive)
  (read-buffer "Put link in which buffer: "
               ;; Default.
               ;; Preferred is (most) current journal buffer.
               ;; Next is the `next window's buffer
               ;; xor the `other-buffer'
               (or (let ((jname (dpj-current-journal-file)))
                     (and jname
                          (get-file-buffer jname)))
                   (if (not 
                        (eq (next-window)
                            (dp-get-buffer-window)))
                       (window-buffer (next-window))
                     (other-buffer (current-buffer))))))

(defun* dp-mk-external-file-link (insertion-buffer 
                                  &optional (copy-to-kill-p t) fmt 
                                  relative-file-name-p)
  "Insert an \"external bookmark\".
Insert some embedded lisp  which allows for easy visiting of another file.  
A bookmark, in this context, is:
1) A filename relative to the buffer that will have the bookmark ins erted,
2) An optimistic file offset (the line may move around.)
3) A short regexp consisting of characters from the beginning line."
  (interactive "P")
  (let* ((regexp-prefix "")             ; or "^"
         inserted-p
         (insertion-buffer 
          (or (and (not (interactive-p)) insertion-buffer)
              ;; Should copy-to-kill-p mean to ONLY copy-to-kill-p ?
              (and (interactive-p) 
                   (not insertion-buffer) 
                   ;;(not copy-to-kill-p)
                   (dp-choose-efl-insertion-buffer))
              ;; If there's no suitable buffer,
              ;; then force the bm onto to kill ring.
              (progn
                (setq copy-to-kill-p t)
                nil)))
         (filename (buffer-file-name))
         (line-len (- (line-end-position) (line-beginning-position)))
         (id-match-string (buffer-substring (line-beginning-position)
                                            (+ (line-beginning-position)
                                               (min line-len 32))))
         ;; ^$( *
         (offset (line-beginning-position))
         (bm-string (format (or fmt 
                                ":(cfl \"%s\" %d \"%s%s\" %s):\n")
                            (if relative-file-name-p
                                (file-relative-name filename)
                              (expand-file-name filename))
                            offset
                            regexp-prefix
                            ;; e.g. blah *xxx becomes blah \\*xxx, but when
                            ;; format/insert is done, there is only 1 \ left."
                            ;;(dmessage "this quoting is broken:")
                            (dp-simple-quote-escape id-match-string
;;                              (regexp-quote id-match-string)
                             )
                            ;; 
                            nil ; regexp-p? not present --> yes (but not yet.)
                            )))
    (when insertion-buffer
      (with-current-buffer insertion-buffer
        (insert bm-string)
        (end-of-line)
        (dp-maybe-set-window-point)
        (setq inserted-p t)))
    (when copy-to-kill-p
      (unless (string= (car kill-ring) bm-string)
        (kill-new bm-string))
      (message "bm is %son the kill-ring: %s"
               (if inserted-p "" "ONLY ")
                bm-string))))

(defun dp-simple-quote-escape (s)
  (replace-in-string s "\"" "\\\""))

(defun dp-c-whattam-I-in()
  "Tell me what class/function/etc that I'm in."
  (interactive)
  (save-excursion
    (call-interactively 'dp-c-beginning-of-defun)
    (let ((region (dp-line-boundaries 'text-only)))
    (message (buffer-substring (car region) (cdr region))))))


;;; DUMMY
(defun dp-setup-indentation-colorization (&rest r)
  "DUMMY"
  )

(defun dp-wide-enough-for-2-windows-p (&optional current-width 
                                       threshold-width)
  (>= (or current-width (frame-width))
      ;; 2 windows w/80 col and decorations
      (or threshold-width 164)))

(defun dp-primary-frame-width ()
  (frame-width dp-primary-frame))

(defvar dp-2w-frame-width 174
  "Default frame width for 2w -- 2 vertical windows 80 columns wide.  
Also used by split window advice to determine when to force a horizontal
split.")

;; I cannot believe I really need to write this. I must've missed it.
;; And I did indeed: CL function `member-if'
;; (defun dp-first-with-pred (pred list &rest pred-args)
;;   (while (and list 
;;               (not (apply pred (car list) pred-args)))
;;     (setq list (cdr list)))
;;   list)

(defun dp-list-subtract (l1 l2)
  "Return L1 with all elements of L2 removed."
  (loop for b in l1
    when (not (member b l2))
    collect b))

(defun dp-push-window-config ()
  (interactive)
  (call-interactively 'wconfig-ring-save))

(defun dp-pop-window-config (n)
  (interactive "p")
  ;; Real pop vs rotate. The yank pop acts, to me, counter-intuitively.
  (call-interactively 'wconfig-delete-pop))

(defun dp-all-window-buffers (&optional win-list frame first-window)
  (mapcar (lambda (win)
            (window-buffer win))
          (window-list frame 'no-minibuffers first-window)))

(defun dp-non-window-buffers (&optional buf-list win-list)
  (setq-ifnil buf-list (buffer-list)
              win-list (dp-all-window-buffers))
  (dp-list-subtract buf-list win-list))


(defun* dp-distribute-buffers (priority-buffers
                               &key buf-list win-list frame first-window
                               skip-these-windows)
  "Distribute the buffers, 1 per window until no more buffers."
  (setq-ifnil buf-list (buffer-list)
              win-list (window-list frame 'no-minibuffers
                                    first-window))
  (let* ((buf-list (dp-list-subtract buf-list priority-buffers))
         (all-buffers (append priority-buffers buf-list)))
    (loop for w in win-list
      until (not all-buffers)
      unless (memq w skip-these-windows)
      do (let ((good-bufs (member-if
                           (lambda (b)
                             (and b
                                  (not (memq b (dp-all-window-buffers)))
                                  (not (dp-minibuffer-p b))))
                           all-buffers)))
           (when good-bufs
             (set-window-buffer w (car good-bufs)))
           (setq all-buffers (cdr good-bufs))))))

(defun* dp-layout-windows (op-list &optional other-win-arg
                           (push-window-config-p t)
                           (delete-other-windows-p t))
  "Layout windows trying to keep as many buffers visible as possible.
!<@todo XXX MAKE SURE THE CURSOR STAYS IN THE SAME PLACE."
  ;; Save the original list of buffers displayed in windows.
  (when push-window-config-p
    (dp-push-window-config))
  (let ((original-window-buffers (dp-all-window-buffers)))
    (when delete-other-windows-p
      (delete-other-windows))
    ;; Set up the new window pattern.
    (let ((skip-these-windows (list (get-buffer-window (current-buffer))))
          (win-list (window-list))
          (buf-list (buffer-list)))
      (loop for op in op-list
        do (let (op-args)
             (unless (listp op)
               (setq op (list op)))
             (dp-aif (op)
               (eval op))))
      (when other-win-arg
        (other-window other-win-arg))
      (dp-distribute-buffers original-window-buffers
                             :skip-these-windows skip-these-windows))))

(defun dp-1-window-normal-width ()
  (interactive)
  ;; Yes, this leaves 1/2 of the extra space that was added for extra frame
  ;; decoration.
  (dp-one-window++)
  (dp-set-frame-width (/ dp-2w-frame-width 2)))
(defalias '1w 'dp-1-window-normal-width)

(defun dp-win-layout-2-left-of-1 ()
  "Make a layout:
| | |
|-| |
|_|_|"

  (interactive)
  (dp-layout-windows '(split-window-horizontally
                       split-window-vertically)
                     1))

(defalias 'dp-win-layout=| 'dp-win-layout-2-left-of-1)

(defun dp-win-layout-2-over-1 ()
  "Give us a layout:
| | |
| | |
|---|
|___|"
  (interactive)
  (dp-layout-windows '(split-window-vertically
                       split-window-horizontally)
                     -1))

;; 
;; | |, | - one window
;; |-|, : - two horizontal
;; |||, || - two vertical
;; 
(defun dp-2-v-or-h-windows (&optional horizontal-p frame-width)
  "Make 2 windows whose arrangement is determined by the frame-width.
Frame width may be increased but will never be decreased.
Uses `dp-2w-frame-width' to increase width.
|| or :
If wide enough: | | |, otherwise: |-|"
  (interactive)
  (delete-other-windows)
  (when (< (frame-width) (or frame-width dp-2w-frame-width))
    (dp-set-frame-width (or frame-width dp-2w-frame-width)))
  (dp-set-frame-height)
  (if horizontal-p
      (split-window-vertically)
    (split-window-horizontally)))
(defalias 'dp-2-vertical-windows 'dp-2-v-or-h-windows)
(defalias '2w 'dp-2-v-or-h-windows)

(defun dp-2-horizontal-windows (&optional width)
  (interactive)
  (dp-2-v-or-h-windows 'horizontal-p width))
(defalias '2h 'dp-2-horizontal-windows)

(defun dp-2x2-windows ()
  "Set up a 2x2 grid of windows.
::
|-|-|"
  (interactive)
  (dp-layout-windows '(split-window-horizontally
                       split-window-vertically
                       ;; Go to other window and split it, too.
                       (other-window -1)
                       ;; Go to the upper left window.
                       split-window-vertically
                       (other-window 2))
                     nil))

(dp-defaliases '2x2 '2+2 '2|2 '2/2 '-- '-|- '4w 'dp-2x2-windows)

(defun dp-1+2-wins ()
  "Set up a 1+2 window arrangement: | |-|"
  (interactive)
  (dp-layout-windows '(split-window-horizontally
                       (other-window 1)
                       split-window-vertically
                       ;; Go to upper left. A single vertical window can be
                       ;; considered uppermost and lowermost.
                       (other-window -1))
                     nil))
                     
(dp-defaliases '1,2 '1x2 '1+2 '1|2 'dp-1x2 'dp-1+2-wins)

(defun dp-2+1-wins ()
  "Set up a 1+2 window arrangement: |-| |"
  (interactive)
  (dp-layout-windows '(split-window-horizontally
                       split-window-vertically)))
                     
(dp-defaliases '2,1 '2|1 'dp-2+1 '2x1 '2+1 '>| 'dp-2+1-wins)

(defun dp-2-over-1-wins ()
  "|-|
   | |"
  (interactive)
  (dp-layout-windows '(split-window-vertically
                       split-window-horizontally)))

(dp-defaliases '2/1 'dp-2/1-wins 'dp-2-over-1-wins)

(defun dp-1-over-2-wins ()
  "| |
   |-|"
  (interactive)
  (dp-layout-windows '(split-window-vertically
                       (other-window 1)
                       split-window-horizontally
                       (other-window -1))))
                     
(dp-defaliases '1/2 'dp-1/2-wins 'dp-1-over-2-wins)

(defun dp-1-beside-1-wins ()
  "Basically C-x3, but will go through my layout function which will leave
  the windows without n duplicated buffers. Also, it does the C-x1 for me."
  (interactive)
  (dp-layout-windows '(split-window-horizontally)))

(dp-defaliases '1|1 '1+1 '1x1 'dp-1-beside-1-wins)

(defun dp-2-shells ()
  "Open two new shell buffers. NB: flaky."
  (interactive)
  (dp-2-horizontal-windows)
  (dp-shell0 'primary)
  (other-window 1)
  (dp-shell0 2)
  ;; If both shells are being created, they end up in one window.
  (other-window 1)
  (dp-shell0 'primary))

(defun dp-2-vertical-windows-do-cmd (cmd &optional interactive-p)
  (dp-2-vertical-windows)
  (other-window 1)
  (if interactive-p
      (call-interactively cmd)
    (funcall cmd)))
  
(defun dp-2-vertical-windows-cmd (cmd &optional interactive-p)
  (interactive "aCmd: ")
  (dp-2-vertical-windows-do-cmd cmd interactive-p))

(defun dp-multiple-windows-on-frame-p (&optional frame)
  "Return non-nil if FRAME currently has more than one window in it."
  (interactive)
  (> (length (window-list frame 'dont-count-minibuf)) 1))

;;(defadvice display-buffer (around dp-display-buffer activate)
  ;;(let* ((buf (ad-get-arg 0))
         ;;(pop-up-windows (dp-pop-up-window-p buf))
         ;;(pop-up-frames (and (not pop-up-windows)
                             ;;(dp-pop-up-frame-p buf))))
    ;;ad-do-it))

; (defun dp-display-buffer-select (buf &optional not-this-window-p 
;                                  override-frame shrink-to-fit pop-up-wins)
;   "Switch to a buffer after displaying it with `display-buffer'.
; The args are those of `display-buffer'.
; By default, sets `pop-up-windows' to be nil.
; `display-buffer' prefers by default to use a window in which the buffer is 
; already displayed, if such a one exists."
;   (interactive)
;   (let ((pop-up-windows pop-up-wins)
;         (pop-up-frames (dp-pop-up-frame-p buf pop-up-frames)))
;     (select-window (display-buffer buf not-this-window-p override-frame 
;                                    shrink-to-fit))))

(defvar dp-max-preferred-frames 1
  "*Don't let any commands implicity make more frames than this.")

(defun dp-max-preferred-frames-opened-p (&optional num device op)
  (funcall (or op '<=) (or num dp-max-preferred-frames)
      (length (device-frame-list device))))

(defvar dp-prefer-independent-frames-p t
  "Treat visiting buffers and such as closely as possible to having 2 instances of xemacs running.
I like this for keeping a frame on each desktop.")

(defvar dp-buffers-allowed-in-other-frames '(" SPEEDBAR"))

(defun* dp-display-buffer-if-visible (buffer &optional (norecord t))
  (interactive "Bbuffer name? ")
  (when (dp-buffer-live-p buffer)
    (let* ((buf-win (get-buffer-window buffer t))
           (buf-name (if (stringp buffer)
                         buffer
                       (buffer-name buffer)))
           (buf-frame (and buf-win (window-frame buf-win)))
           (orig-frame (window-frame (get-buffer-window (current-buffer))))
           (same-frame-p (eq buf-frame orig-frame)))
      (when (and buf-win 
                 (or same-frame-p
                     (member buf-name dp-buffers-allowed-in-other-frames)
                     (not dp-prefer-independent-frames-p)))
        (select-window buf-win)
        (set-window-buffer buf-win buffer norecord)
        (unless same-frame-p
          (select-frame buf-frame)
          (raise-frame buf-frame))
        buffer))))

(defun dp-visit-or-switch-to-buffer (buf &optional switch-func)
  "Switch to BUF's window if visible, else switch to the buffer in the
current window."
  (interactive "bbuf? ")
  (unless (dp-display-buffer-if-visible buf)
    (funcall (or switch-func 'switch-to-buffer) buf)))

(defun dp-visit-or-bury-buffer (buf-to-visit)
  "Switch to BUF-TO-VISIT if visible, else bury current buffer."
  (interactive "bbuf? ")
  (dp-visit-or-switch-to-buffer buf-to-visit (function
                                              (lambda (buf)
                                                (bury-buffer)))))

(dp-deflocal dp-simple-buffer-select-p t
  "Do we want to use the A.S. routine to guess what window we want our buffer to display in or do it simply?")

(defun dp-display-buffer-select (buffer &optional not-this-window-p 
                                 override-frame shrink-to-fit other-window-p)
  "Try to pick new windows/frames for buffers in the way I would prefer."
  (interactive "Bbuffer name? ")
  ;; buffer can be a name
  (setq buffer (get-buffer-create buffer))
  (if (not 
       ;; We always want to visit the buffer where it is already
       ;; visible. `display-buffer' does this, but I think my wankish logic
       ;; here screws that up, so force it here.
       ;; But do try if they call has specified anything "extra."
       (dp-display-buffer-if-visible buffer))
      (if (and dp-simple-buffer-select-p
               (not (or not-this-window-p override-frame shrink-to-fit 
                        other-window-p)))
          (switch-to-buffer buffer)
        (let* ((orig-frame (window-frame (get-buffer-window (current-buffer))))
               (one-window-p (one-window-p 'NOMINIBUFFER))
               (pop-up-frames (and one-window-p
                                   (dp-pop-up-frame-p)
                                   (not (dp-max-preferred-frames-opened-p))))
               (pop-up-windows (or other-window-p
                                   (and one-window-p
                                        dp-likes-other-open-windows-p)))
               (new-frame (if (or dp-override-use-other-frames-p
                               (not one-window-p))
                              orig-frame
                            (and (not pop-up-frames) (next-frame)))))
          ;; already in some window on some frame, select that frame.
          ;;(pop-to-buffer buffer nil new-frame)
          ;; `display-buffer-function' does not replace `display-buffer' but is
          ;; called from within it after some preliminary code.  So we must set
          ;; it to nil to prevent infinite recursion.
          (let ((display-buffer-function nil)
                (win (display-buffer buffer not-this-window-p 
                                     new-frame shrink-to-fit)))
            (when win
              (select-window win)))
          (when (not (equal orig-frame
                            (window-frame)))
            (raise-frame (window-frame))))))
  buffer)

;; @todo Someday...
;;(setq display-buffer-function 'dp-display-buffer-select)

(dp-deflocal dp-visited-defun nil
  "The function which caused this file to be visited.")

(defvar dp-find-file-exclude-dedicated-windows-p t
  "Controls loading files into dedicated windows.
If the current window is dedicated AND this variable is non-nil then do a 
\"find-file-other-window\" kind of action.")

(defun* dp-find-file (file-name &optional &key
                     ;; `find-file-noselect' args
                     nowarn rawfile wildcards
                     ;; `dp-display-buffer-select' args
                     not-this-window-p override-frame 
                     shrink-to-fit other-window-p
                     visitor)
  "Find a file, preferring (by default) to display an existing buffer in another window.
Uses `dp-display-buffer-select' which uses `select-window' to select the
buffer to be displayed as determined by `display-buffer'.  The args are
basically the union of the args to `find-file-noselect' and
`dp-display-buffer-select'. "
  (interactive "Fdp:file? ")
  (when visitor
    (unless (get-file-buffer file-name)
      (setq dp-visited-defun visitor)))
  (dp-display-buffer-select 
   (find-file-noselect file-name nowarn rawfile wildcards)
   not-this-window-p override-frame shrink-to-fit 
   (or other-window-p
       (and (dp-window-dedicated-p)))))

(defun dp-find-file-this-window  (file-name &optional codesys wildcards)
  "Find a file in this window unless it is displayed in another."
  (interactive (list (read-file-name "dp:Find file in this window: ")
		     (and current-prefix-arg
			  (read-coding-system "Coding system: "))
		     t))
  (let ((buf (get-buffer (file-name-nondirectory file-name))))
    (if (and buf (get-buffer-window buf))
        (switch-to-buffer-other-window buf))
    (if t ;; codesys
        ;; Punt if one of the optional variables are set, since I don't know
        ;; what I want to do with them.
        (find-file file-name codesys wildcards)
      (dp-find-file file-name))))

(defun dp-find-file-other-window (file-name &rest rest)
  "Try to be clever (ARG!) about find a file into another window."
  (interactive (list (read-file-name "dp:Find file in other window: ")
		     (and current-prefix-arg
			  (read-coding-system "Coding system: "))
		     t))
  (if rest
      ;; Punt if one of the optional variables are set, since I don't know
      ;; what I want to do with them.
      (apply 'find-file-other-window file-name rest)
    (dp-find-file file-name :other-window-p t)))

(defun dp-force-read-only-by-file-name-regexp ()
  "Make buffers with file names matching `dp-force-read-only-regexps' READ-ONLY."
  ;; Nothing to do for buffers w/o files.
  (when buffer-file-name
    ;; Force expansion since find-file-use-truenames may not be.
    (let ((bfn (expand-file-name buffer-file-name)))
      (dolist (r dp-force-read-only-regexps)
        (when (string-match r bfn)
          (dmessage "Forcing %s to be read-only." bfn)
          (toggle-read-only 1)
          (return))))))

(defun dp-remove-file-state-colorization ()
  (interactive)
  (dp-unextent-region (cons 'dp-file-state-colorization t)))
                                   
(defun dp-colorize-found-file-buffer ()
  "Set a buffer's color after the file has been loaded into it."
  (dp-remove-file-state-colorization)
  (dp-colorize-buffer-if-remote nil t)
  ;;(dmessage-todo "Name the colors in my palette!!!")
  (dp-colorize-buffer-if-readonly nil t))

(defvar dp-found-file-pre-hook nil
  "A one shot hook to call on the next found file.
This is useful for giving gnuclient & co more control over the editing process.")

(defvar dp-found-file-post-hook nil
  "A one shot hook to call on the next found file.
This is useful for giving gnuclient & co more control over the editing process.")

(defun dp-found-file-setup ()
  "Perform actions on a `new'ly found file.
Suitable for a find file hook (`dp-find-file-hooks')
and for setting up a buffers mode (`dp-set-auto-mode')."
  (dp-funcall-if dp-found-file-pre-hook ())
  (setq dp-found-file-pre-hook nil)
  (dp-force-read-only-by-file-name-regexp) 
  (dp-colorize-found-file-buffer)
  (dp-set-file-group)
  (dp-funcall-if dp-found-file-post-hook ())
  (setq dp-found-file-post-hook nil))

(defun dp-find-file-hooks ()
  "My hooks added to `find-file-hooks'."
  (interactive)
  ;;(dp-make-local-keymap-extent)
  ;; Make RO before colorizing, so RO colors will be used.
  (dp-found-file-setup)
  (dp-restore-file-state (current-buffer)))

(defun dp-stealth-time-stamp ()
  (dp-without-undo-in-current-buffer
   (time-stamp)))

;; New style for hooks:  Add the hooking to the dp-post-dpmacs-hook so
;; we don't run into any void vars/functions.
(add-hook 'dp-post-dpmacs-hook (lambda ()
                                 (add-hook 'find-file-hooks 
                                           'dp-find-file-hooks)
                                 (add-hook 'write-file-hooks 
                                           'dp-stealth-time-stamp)))

(defun dp-set-primary-makefile (&optional toggle-var buf-or-name-of-makefile)
  "Cause the Makefile in the current buffer to be the one to use in this tree."
  (interactive "P")
  (with-current-buffer (dp-get-buffer buf-or-name-of-makefile)
    (setq buffer-read-only (not toggle-var))
    (dp-toggle-var toggle-var 'dp-primary-makefile-p)
    (when dp-primary-makefile-p
      (dp-define-buffer-local-keys '([(meta ?-)] 
                                     dp-bury-or-kill-buffer)))))

(defun 411f (&optional name-regex case-unfold-p)
  "Find NAME-REGEX in phone book."
  (interactive "sname-regex: \nP")
  (dp-push-go-back "going to phone-book")
  (dp-visit-phone-book)
  (goto-char (point-min))
  (let ((pt (point))
        (case-fold-search (not case-unfold-p))
        found-phone
        close-paren-pos
        limit)
    (while (eq found-phone nil)
      (if (not (re-search-forward name-regex))
          (progn
            (setq found-phone 'fell-off-end)
            nil)
        (re-search-backward "^\\s-*e\\s-*(" nil t)
        (goto-char (match-end 0))
        (backward-char 1)
        ;; `dp-find-matching-paren' needs to return matched paren pos.
        (when (setq close-paren-pos (save-excursion 
                                      (dp-find-matching-paren)))
          (let ((limit close-paren-pos))
            ;; We must needs keep the main number first.
            (if (not (re-search-forward "phone.*:" limit t))
                ;; This entry has no phone number...
                ;; Keep looking.
                ;; !<@todo XXX Add 411f-next to pick-up search from the next
                ;; record.
                (goto-char (1+ close-paren-pos))
              (setq found-phone (match-beginning 0))
              (goto-char found-phone)
              (beginning-of-line)
              (dp-highlight-point-until-next-command)
              t)))))
    (when (eq found-phone 'fell-off-end)
      (goto-char pt))))
  
(defcustom dp-invisible-text-glyph-string nil
  "*String from which to make the `invisible-text-glyph'."
  :type 'string
  :group 'dp-vars)

(defcustom dp-invisible-text-glyph-file nil
  "*File from which to make the `invisible-text-glyph'.  
nil says to use the default builtin image."
  :type '(file :must-match t)
  :group 'dp-vars)

(defcustom dp-invisible-text-glyph-color "blue"
  "*Color to make the `invisible-text-glyph' when using the builtin default."
  :type 'string
  :group 'dp-vars)

(defcustom dp-dont-use-invisible-text-glyph nil
  "*Flag telling whether or not to use our own value for
`invisible-text-glyph'."
  :type 'boolean
  :group 'dp-vars)

(defun dp-set-buffer-invisible-text-glyph (spec)
  "Set the invisible text glyph for this buffer."
  (set-glyph-image invisible-text-glyph 
		   spec))

;; This localizes the glyph to the current buffer
;;		   (current-buffer) 'x))
;;

(defun dp-setup-invisibility (&optional invisible-text-glyph-string
                              dont-use-invisible-text-glyph
                              invisible-text-glyph-file
                              invisible-text-glyph-color)
  "Make a nice glyph for invisible text regions."
  (interactive)
  
  (setq-ifnil invisible-text-glyph-string dp-invisible-text-glyph-string
              dont-use-invisible-text-glyph dp-dont-use-invisible-text-glyph
              invisible-text-glyph-file dp-invisible-text-glyph-file
              invisible-text-glyph-color dp-invisible-text-glyph-color)
  ;; show the dots... or whatever
  (setq-default buffer-invisibility-spec (list (cons t t)))
  ;; @todo ??? Change 'y from a constant to a var???
  (setq-default buffer-invisibility-spec (list (cons 'y t)))
  (setq buffer-invisibility-spec (list (cons 'y t)))
  ;;(make-variable-buffer-local 'invisible-text-glyph)
  ;;Doc cautions that this can be slow...
  (setq line-move-ignore-invisible t)
  (cond
   (invisible-text-glyph-string 
    (dp-set-buffer-invisible-text-glyph 
     `[string :data ,invisible-text-glyph-string]))
   ((null dont-use-invisible-text-glyph)
    (dp-set-buffer-invisible-text-glyph 
     (dp-setup-invisible-glyph invisible-text-glyph-file
                               invisible-text-glyph-color)))))

(defun dp-make-highlight-region-extent-id (symbol-prefix)
  "Make a symbol ID'ing extents made by `dp-highlight-region'.
Uses SYMBOL-PREFIX to make the symbol unique to the caller(s)."
  (interactive)
  (intern (format "%s-dhr-extent" symbol-prefix)))

(defun dp-highlight-region (from to op symbol-prefix
                            &optional hi-face lo-face priority &rest props)
  "Highlight a region according to OP.
Ignore repeated requests to set the same properties. Idempotentize."
  (interactive "r\nSop: \nsprefix: \nShi-face: \nSlo-face: \np")
  (let* ((extent-id (dp-make-highlight-region-extent-id symbol-prefix))
         (helper (function
                  (lambda (id-prop-name &rest rest)
                    (apply 'dp-make-extent 
                           from to extent-id 
                           'dph-op op
                           (intern (format "%s-%s" 
                                           symbol-prefix id-prop-name)) t
                                           rest)))))
    (cond
     ((memq op '(showall sa))
      ;; delete all extents we've added
      (dp-delete-extents from to extent-id)
      )
     
     ((memq op '(highlight hl h))
      ;; create the indicated extent and give it the selected face.
      (apply helper "highlight" (apply 'list 'face hi-face props))
      )
     
     ((memq op '(lowlight ll l))
      ;; create the indicated extent and give it the selected face.
      (apply helper "lowlight" (apply 'list 'face lo-face props))
      )
     
     ((memq op '(hide invis i))
      ;; create an extent and mark it as invisible
      ;; identify it as made invisible by this module
      ;; apply 'list appends contents of props into the list
      (apply helper "invisible" (apply 'list 'invisible 'y 'read-only t props))
      )
     
     ((memq op '(show unhide s))
      ;; delete all invisible extents
      (dp-delete-extents from to (intern (format "%s-invisible" 
                                                 symbol-prefix)))
      )
     
     ((memq op '(unhighlight unhl u))
      ;; remove all hilghlighting extents in the specified region
      (dp-delete-extents from to (intern (format "%s-highlight" 
                                                 symbol-prefix)))
      )
     
     ((memq op '(nop))
      ;; do nothing
      ;; (dmessage "nop")
      )
     )))
(defalias 'dphr 'dp-highlight-region)

(defvar dp-hidden-region-keymap (make-sparse-keymap "Hidden region keymap.")
  "Keymap active in one of my hidden regions. The region is read-only.")

(dp-define-keys dp-hidden-region-keymap
                '(?U dp-unhide-region
                  ?u dp-unhide-region
                  ?/ dp-unhide-region
                  ?- dp-unhide-region
                  ?\' dp-unhide-region
                  ?V dp-unhide-region
                  ?v dp-unhide-region
                  ?S dp-unhide-region
                  ?s dp-unhide-region
                  ;; This needs to be on the glyph itself.
                  ;;[button2] dp-unhide-region
                  ?R dp-unhide-region
                  ?r dp-unhide-region))

(defun* dp-hide-region (&optional from to 
                        (keymap dp-hidden-region-keymap ) &rest props)
  "Hide region by setting color to 0, aka invis."
  (interactive)
  ;; Add keymap to allow for easy un-hiding
  (apply 'dp-colorize-region 0 from to 'no-roll-colors nil 
         (append props
                 (list 'keymap keymap
                       (dp-make-highlight-region-extent-id "dp-hidden") t))))

(defalias 'dhr 'dp-hide-region)

(defun dp-show-region ()
  (interactive)
  (dp-unextent-region (dp-make-highlight-region-extent-id "dp-hidden")))
(dp-defaliases 'dp-unhide-region 'dur 'dsr 'dv 'dp-show-region)

(defun dp-log-base-b (base num)
  (interactive)
  (/ (log num) (log base)))

(defun dp-num-C-u (&optional prefix-arg)
  (interactive "P")
  (setq-ifnil prefix-arg current-prefix-arg)
  (and (listp prefix-arg)        ; Ensure it's a list ==> true C-u vs C-<num>
       (truncate (dp-log-base-b 4 (prefix-numeric-value prefix-arg)))))

(defun* C-u-p (&optional num-C-u prefix-arg (op 'eq))
  "Return non-nil if number of C-us in `current-prefix-arg' == NUM-C-U.
If PREFIX-ARG is non-nil, use that instead of `current-prefix-arg'.
Essentially return whether log base4 of `current-prefix-arg' == NUM-C-U."
  (setq-ifnil prefix-arg current-prefix-arg)
  (and prefix-arg (listp prefix-arg)
       (funcall op (expt 4 (or num-C-u 1))
                (let ((a prefix-arg))
                  (if (listp a)
                      (car a)
                    a)))))
(dp-defaliases 'Cu-p 'Cup 'C-u-p)

(defun Cup> (num &optional prefix-arg)
  (C-u-p num prefix-arg '<))

(defun Cup< (num &optional prefix-arg)
  (C-u-p num prefix-arg '>))

(defun Cup>= (num &optional prefix-arg)
  (C-u-p num prefix-arg '<=))

(defun Cup<= (num &optional prefix-arg)
  (C-u-p num prefix-arg '>=))

(defun Cu0p (&optional prefix-arg n)
  "Check to see if the numeric value of the prefix arg is N.
Most used to check for C-0 as a command flag."
  (setq-ifnil prefix-arg current-prefix-arg)
  (eq (prefix-numeric-value prefix-arg) (or n 0)))

(defun Cu--p (&optional prefix-arg)
  "See if current-prefix-arg `equal' ARG. ARG defaults to '-"
  (setq-ifnil prefix-arg current-prefix-arg)
  (equal '- prefix-arg))

(defun Cu-val (&optional prefix-arg)
  (prefix-numeric-value (or prefix-arg current-prefix-arg)))

(defun Cu*p (memq-list &optional prefix-arg)
  "Return non-nil if CURRENT-PREFIX-ARG or PREFIX-ARG is in MEMQ-LIST.
The return value is the result of `memq' on MEMQ-LIST"
  (interactive)
  (member (or prefix-arg current-prefix-arg) memq-list))

(defun dp-del-dups (l1)
  (let (lf)
    (mapcar
     (function
      (lambda (el)
        (if (member el lf)
            nil
          (setq lf (cons el lf)))))
     l1)
    lf))

(defvar dp-one-window++-last-register 1
  "Last register used to store a config.")

(defun* dp-one-window++ (&optional (arg 1))
  "Toggle between one window and previously saved window configurations.
Saves window configurations in registers. Default is reg `\(int-to-char 1\)'
@todo ??? Save last used register as default?"
  (interactive "_p")
  (let* ((force-set-p (< arg 0))
         (arg (if current-prefix-arg (abs arg) dp-one-window++-last-register))
         (reg (int-to-char arg))
         (reg-val (car-safe (get-register reg))))
      (if (and reg-val 
               (one-window-p 'nomini)
               (not force-set-p))
          (if (window-configuration-p reg-val)
              (progn
                (set-window-configuration reg-val)
                (unless (eq arg 1)
                  (message "Used window config in register %s (0%o, %d, 0x%x)" 
                           reg arg arg arg)))
            (ding)
            (message "register %s does not contain a window configuration."
                     reg))
        (if (and (or t (/= 1 reg))      ; !<@todo XXX ??? or t ???
                 reg-val
                 (not (window-configuration-p reg-val))
                 (not (y-or-n-p 
                       (format 
                        "Reg %s isn't empty and isn't a win cfg; Continue? "
                        reg))))
            (message "Not setting window config.")
          (window-configuration-to-register reg)
          (setq dp-one-window++-last-register arg)
          (unless (eq arg 1)
            (message "Saved window config to register %s (0%o, %d, 0x%x)" 
                     reg arg arg arg))
          (delete-other-windows)))))
(put 'dp-one-window++ 'isearch-command t)


(defun dp-get-file-owner (file-name)
  "Get a file's owner"
  (interactive "fFile name? ")
  (dp-nuke-newline (shell-command-to-string 
                    (format dp-get-file-owner-program file-name))))

(defun dp-user-owns-this-file-p (&optional file-name user-name)
  "Return non-nil if USER owns FILENAME.
USER default to the current user.
FILENAME defaults to the name of the current buffer or 
\"\" if the `current-buffer' has no associated file."
  ;; So much promptage code for the 0.000001% of the time this'll be called
  ;; interactively (not counting the number of calls during development).
  (interactive (let* ((def-file-name (or (buffer-file-name (current-buffer))
                                         ""))
                      (fn-def-prompt (if (string= "" def-file-name)
                                         "%s"
                                       "[%s]")))
                 (list
                  (read-file-name 
                   (format (concat "File name" fn-def-prompt "? ")
                           (file-name-nondirectory def-file-name))
                   nil nil 'must-match)
                   (read-string 
                    (format "User name[%s]? " (user-login-name))
                    nil nil (user-login-name)))))
  (let ((status (string= (or user-name (user-login-name))
                         (dp-get-file-owner 
                          (or file-name 
                              (buffer-file-name (current-buffer)))))))
    (when (interactive-p)
      (message "%s is%s owned by %s." file-name (if status "" " NOT") 
               (or user-name (user-login-name))))))


(defun dp-balance-horizontal-windows ()
  "Assumes windows are all from horizontal splits.
There is something going on that makes the windows resize themselves
in a very bizarre fashion."
  (interactive)
  (let* ((win-list (window-list nil 'no-minibufs-at-all))
         (num-wins (length win-list))
         (total-cols (apply '+ (mapcar (function
                                        (lambda (w)
                                          (window-width w)))
                                       win-list)))
         (min-width (+ window-min-width 3))
         (target-win-inc (- (/ total-cols num-wins) min-width))
         win
         (wl win-list))
    (while wl
      (setq win (car wl)
            wl (cdr wl))
      (shrink-window (- (window-width win) min-width) 'horiz win)
      (enlarge-window target-win-inc 'horiz win))))

(defun dp-get-win-list-buffers (&optional win-list frame minibuf window)
  "Return a list of \(buffer . point) for each window in WIN-LIST.
This is like `window-list' with added window position information.
WIN-LIST defaults to all windows in FRAME, beginning with WINDOW.
FRAME is where we get the windows, default: current frame.
MINIBUF says to include minibuffer windows."
  (mapcar (function
           (lambda (win)
             (cons (window-buffer win)
                   ;;;(point (window-buffer win))
                   ;;; Why did I change the below to the above?
                   ;;; Now it looks like below is better.
                   (window-point win)
                   )))
          (or win-list (window-list frame minibuf window))))

(defun dp-rotate-windows (&optional to-vertical-set)
  "Convert a horizontal(vertical) set of windows into the 
equivalent vertically(horizontally) split set."
  (interactive "_P")
  (let* ((split-func (if (or to-vertical-set
                             (= (frame-width) (window-width)))
                         'split-window-horizontally
                       'split-window-vertically))
         (win-list (window-list nil 'no-minibufs-at-all))
         (num-wins (length win-list))
         (buf-list (dp-get-win-list-buffers win-list nil 'no-minibufs-at-all)))
    (delete-other-windows)
    (while (> num-wins 1)
      (funcall split-func)
      (setq num-wins (1- num-wins)))
    (balance-windows)
    (while buf-list
      (switch-to-buffer (buffer-name (caar buf-list)))
      (goto-char (cdar buf-list))
      (other-window 1)
      (setq buf-list (cdr buf-list)))))
(put 'dp-rotate-windows 'isearch-command t)

(defun dp-num-frames (&optional device)
  "How many frames are currently open on DEVICE or current device?"
  (length (device-frame-list device)))

(defun dp-one-frame-p (&optional Device)
  "Non-nil if only one frame exits on \(or DEVICE <current device>\)."
  (eq 1 (dp-num-frames)))

(defvar dp-override-pop-up-windows-p t
  "*Never allow pop up windows.")

(defun dp-pop-up-window-buffer-p (buf &optional pop-up-wins which-frames)
  (interactive)
  (and (not dp-override-pop-up-windows-p)
       (or (or pop-up-wins pop-up-windows)
           ;; t if (not frame) , else frame
           ;; t --> check all frames
           (and (not (get-buffer-window buf which-frames))
                (dp-multiple-windows-on-frame-p)))))

(defvar dp-likes-pop-up-windows t
  "My version of pop-up-windows.  Why? I don't know.")

(defun dp-pop-up-window-p ()
  (and (not dp-override-pop-up-windows-p)
       (or pop-up-windows dp-likes-pop-up-windows)))

(defvar dp-override-pop-up-frames-p nil
  "*Never allow pop up frames.")

(defvar dp-override-use-other-frames-p t
  "*Never allow a command to implicitly use another frame.")

(defun dp-pop-up-frame-p (&optional pop-up-frames device)
  "Determine if I want to set `pop-up-frames' in order to visit a buffer in
another frame."
  (and (not dp-override-pop-up-frames-p)
       (not (dp-max-preferred-frames-opened-p))
       (or pop-up-frames
           (and (dp-one-frame-p device)
                ;;(not (get-buffer-window buf t))
                (< (frame-width) dp-2w-frame-width)))))

(defun dp-first-buf-besides (&optional buf)
  (interactive "Bbuf? ")
  (setq buf (if buf
                (get-buffer buf)        ;Allows buf to be a name
              (current-buffer)))
  (loop for b on (buffer-list)
    until (and (not (buffers-menu-omit-invisible-buffers (car b)))
               (not (equal (car b) buf)))
    finally return (car b)))

(defun dp-count-matches-string (s &optional regexp)
  "Count the matches of regexp (default newlines) in a string."
  (let ((count 0)
        (start 0)
        (regexp (or regexp "\n")))
    (while (posix-string-match regexp s start)
      (setq count (1+ count)
            start (match-end 0)))
    count))

(defun dp-kill-protect-status (&optional message fun fun-args)
  "Display Kill Protect(tm) status in BUFFER (current-buffer)."
  (interactive)
  (setq-ifnil message 
              (format "%s is Kill Protected(tm). But it has been buried." 
                      (buffer-name)))
  (let* ((this-buf (current-buffer))
         (fun-name  (if fun
                        (apply fun fun-args)
                      (dp-bury-or-kill-buffer))))
    (when (dp-buffer-live-p this-buf)
      (message "%s%s" message (if fun-name
                                (format " with `%s'." fun-name)
                              "")))))


(defun dp-kill-protect (&optional buffer)
  "Protect this buffer from being killed by setting Meta-- to `dp-bury-or-kill-buffer'."
  (interactive)
  (when buffer
    (set-buffer buffer))
  ;; dp-bury-or-kill-buffer
  ;; Redefine (meta -) to not really kill the buffer.
  (dp-define-buffer-local-keys '([(meta ?-)] dp-kill-protect-status) buffer))

(dp-deflocal dp-use-whence-buffers-p nil
  "KEEP NIL... system is b0rked.
Should certain commands remember an return to the buffers they were in
when the command was issued?")

(defun dp-visit-whence (whence-buf &optional arg)
  "Try to go back the place from whence we came in a most convenient manner."
  (interactive "bWhence? \nP")
  (if (dp-buffer-live-p whence-buf)
      (progn 
        (dmessage "Visit or switch...")
        (dp-visit-or-switch-to-buffer whence-buf))
    (dmessage "Burying buffer.")
    (bury-buffer)))
;; Other functionality for this function in version control.

(defalias 'dp-return-whence 'dp-visit-whence)

(defun dp-non-dedicated-win-list (win-list)
  "Return a list of all whindows which are not dedicated to a particular buffer."
  (delq nil (mapcar (lambda (win)
                      (unless (dp-window-dedicated-p win)
                        win))
                    win-list)))

(defun* dp-other-non-dedicated-window (&optional (dir 1))
  "Move to \"other\" window, skipping dedicated ones. DIR may be 1 or -1."
  (let ((this-window (dp-get-buffer-window)))
    (other-window dir)
    (while (and (dp-window-dedicated-p)
                (not (equal this-window (dp-get-buffer-window))))
      (other-window dir))))

(defun dp-shift-windows-0 (dir)
  "Move each buffer into its next window."
  (let* ((win-list (dp-non-dedicated-win-list 
                    (window-list nil 'no-minibufs-at-all)))
         (win-list (if (eq dir 'left) 
                       (reverse win-list) 
                     win-list))
         (buf-list (dp-get-win-list-buffers win-list nil 'no-minibufs-at-all))
         w b)
    (setq buf-list (append (cdr buf-list) (list (car buf-list))))
    (while win-list
      (setq w (car win-list)
            win-list (cdr win-list)
            b (car buf-list)
            buf-list (cdr buf-list))
      (set-window-buffer w (car b)))
    (dp-other-non-dedicated-window)))

(defun dp-shift-windows (num)
  "Move each buffer into its NUM-th next window."
  (interactive "_p")
  (let ((dir (if (< num 0) 'left 'right)))
    (loop repeat num do
      (dp-shift-windows-0 dir))))

;; Copped from describe-variable
(defun* dp-read-variable-name (&optional def-prompt prompt history-symbol 
                               confirm-name-p
                               (void-var-format "Describe variable (%s is void): "))
  (let* ((v (variable-at-point))
         (val (let ((enable-recursive-minibuffers t))
                (if (and v (not confirm-name-p))
                    (format "%s" v)
                  (completing-read
                   (if v
                       (format (or def-prompt 
                                   "Describe variable (default %s): ") 
                               v)
                     (gettext (or (when void-var-format 
                                    (format void-var-format 
                                            (symbol-near-point)))
                                  prompt "Describe variable: ")))
                   obarray 'boundp t nil (or history-symbol 'variable-history)
                   (symbol-name v))))))
    (list (intern val))))

(defun dp-show-variable-value (var-sym &optional confirm-name-p
                               copy-as-kill-p no-history-p)
  "Show the value of VAR-SYM in the echo area."
  (interactive (dp-read-variable-name "Show var (def %s): "
                                      "Show var: " nil 
                                      current-prefix-arg))
  (if (not var-sym)
      (error "No value for %s" (current-word))
    (if current-prefix-arg
        (dp-symbol-info var-sym)
      (let* ((value (eval var-sym))
             (fun-too (fboundp var-sym))
             (fun-too-str "")
             (oq (if (stringp value) "\"" "" ))
             (cq (if (stringp value) "\"" "" )))
        (if (boundp var-sym)
            (progn
              (when copy-as-kill-p
                (kill-new "%s" value))
              (unless no-history-p
                (dp-add-to-history 'variable-history var-sym))
              (message "%s%s%s: %s%s%s" 
                       var-sym
                       (if (local-variable-p var-sym (current-buffer) 
                                             'AFTER-SET)
                           " [buf-local]"
                         "")
                       (if fun-too
                           " (also a defun)"
                         "")
                       oq value cq)
              (cons 'ret-val value))
          (if (fun-too)
              (and (warn "%s is a function: %s" (current-word) 
                         (eldoc-get-doc))
                   nil)))))))

(defun dp-show-variable-value-and-copy ()
  (interactive)
  (let ((val (call-interactively 'dp-show-variable-value)))
    (when val
      (kill-new (format "%S" (cdr val))))))

(defun dp-describe-variable (&optional variable)
  (interactive)
  (call-interactively (if (Cu*p '(0 -))
                          'dp-show-variable-value
                        'describe-variable)))

(defun* dp-calc-eval-region (results-only-p &optional beg end (insert-=-p t)
                             (clean-cruft-p t))
  "Run quick calc on the region."
  (interactive "P")
  (let* ((region (dp-region-or... 
                  :bounder 'rest-or-all-of-line-p
                  :bounder-args '(:text-only-p nil 
                                  :no-newline-p 'NO-NEWLINE)))
	 (beg (car region))
	 (end (cdr region))
         results
         ;; Get a clean expr for calc.
         (expr (let ((e (buffer-substring beg end)))
                 (if (string-match "\\(.*?\\)\\(=\\|\\s-\\)+$" e)
                     (progn
                       ;; We have cruft.  Insert = if we clean the cruft.
                       (setq insert-=-p clean-cruft-p)
                       (match-string 1 e))
                   e))))
    (save-excursion
      (cond
       (results-only-p                 ; We just want the results.
        (kill-region beg end)
            (goto-char beg))
       (clean-cruft-p
        (kill-region beg end)
        (goto-char beg)
        (insert expr))
       (t (goto-char end)))
      (dmessage "expr>%s<" expr)
      (setq results (calc-eval expr))
      (when insert-=-p
        (insert " = "))
      (insert results))))

(defun* dp-dc-eval (expr &optional (nuke-newline-p t))
  (dp-nuke-newline
   (shell-command-to-string (format "echo '%s%s' | dc" 
                                    expr
                                    (if (string-match "p\\s-*$" expr)
                                        ""
                                     " p")))
   nuke-newline-p))

(defun* dp-dc-eval-string (expr &optional (nuke-newline-p t))
  (interactive "\sdc expr: ")
  (message "%s ==> %s" expr (dp-dc-eval expr nuke-newline-p)))
(defalias 'dp-rpn-eval 'dp-dc-eval-string)

(defun* dp-dc-eval-region (kill-region-p
                           &key beg end no-=-p (nuke-newline-p t))
  "Run dc on the region."
  (interactive "P")
  (let* ((region (dp-region-or... :bounder 'rest-of-line-p 
                                  :bounder-args '(nil 'NO-NEWLINE)))
	 (beg (car region))
	 (end (cdr region))
         results
         (expr (buffer-substring beg end)))
    (save-excursion
      (if kill-region-p
          (progn
            (kill-region beg end)
            (goto-char beg))
        (goto-char end))
      (dmessage "expr>%s<" expr)
      (setq results (dp-dc-eval expr nuke-newline-p))
      (unless no-=-p
        (insert " = "))
      (insert results))))

(defun dp-in-a-string (&optional buf)
  "Return non-nil if BUF.POS is in a string."
  (eq 'string (dp-buffer-syntactic-context buf)))

(defvar dp-xemacs-start-stamp-str "' started: xemacs'"
  "String in log file telling us that this is an xemacs startup time stamp.")

(defun dp-log-end-of-session (session-start-time &optional log-file-name 
                              session-stop-time start-stamp)
  (interactive)
  (setq-ifnil  session-start-time (dp-get-first-emacs-start-time))
  (dp-log-message-to-file dp-def-time-log-file-name  "xemacs logout:\n")
  (dp-log-time-to-file (or start-stamp dp-xemacs-start-stamp-str) 
		       session-start-time 
		       (or log-file-name dp-def-time-log-file-name))
  (dp-log-time-to-file "' finished: xemacs'" session-stop-time
		       (or log-file-name dp-def-time-log-file-name))
  (dp-log-message-to-file dp-def-time-log-file-name
			  (dp-1/4-hours-since-string 
			   session-start-time
			   " ==> Total session hours (%3.2f): %3.2f\n--\n")))

(defun dp-ipython-dedent ()
  (interactive)
  (when (and (equal (point) (save-excursion (comint-bol nil) (point)))
             (dp-looking-back-at "     "))
    (delete-backward-char 4)
    t))

(defun dp-ipython-backward-delete-word ()
  (interactive)
  (unless (dp-ipython-dedent)
    (call-interactively 'dp-backward-delete-word)))

(defvar dp-serialized-name-alist '())

(defun dp-serialized-name (prefix format &rest rest)
  (interactive)
  (let ((el (assoc prefix dp-serialized-name-alist))
        n)
    (if el
        (setq n (incf (cadr el)))
      (setq n 0
            dp-serialized-name-alist (cons (list prefix n 
                                                 'rest: rest 
                                                 'maj-mode: (major-mode-str)
                                                 'bufname: (buffer-name))
                                           dp-serialized-name-alist)))
    (format (or format "%s%s") prefix n)))

(defun dp-buffer-syntactic-context-hack-around (&optional buffer)
"`buffer-syntactic-context' seems buggy.  I've seen it go into a mode where
it only returns 'string.  It was doing this and I switched to a lisp buffer
and used the command and when I went back, it was working.  It seems that
wasn't it.  But going to bof seems to reset it to a less broken state.
I'm not sure what modes are affected."
  (save-excursion
    (goto-char (point-min))
    (dp-buffer-syntactic-context))
  (dp-buffer-syntactic-context))

(defun dp-buffer-syntactic-comment-p ()
  (interactive)
  (eq (dp-buffer-syntactic-context-hack-around) 'comment))

(defun dp-buffer-syntactic-string-p ()
  (interactive)
  (eq (dp-buffer-syntactic-context-hack-around) 'string))

(defun* dp-in-code-space-p (&optional (pos (point)))
  "Non-nil if we're in `real' code space vs a string, comment, etc."
  (interactive)
  (save-excursion
    (goto-char pos)
    (and (not (dp-buffer-syntactic-string-p))
         (not (dp-buffer-syntactic-comment-p)))))

(defun* dp-py-got-colon? (&key (start (point)) (limit (line-end-position)))
  (save-excursion
    (goto-char start)
    (save-match-data
      (while (re-search-forward ":" limit t)
        (when (and (not (eq (dp-buffer-syntactic-context-hack-around) 'comment))
                   (not (eq (dp-buffer-syntactic-context-hack-around) 'string))
                   (not (looking-at "\\s-*[]]"))) ; Add more chars as needed.
          (return-from dp-py-got-colon? t)))
      nil)))

(defvar dp-py-block-keywords (dp-regexp-concat  ;  (regexp-opt 
                              '("def"
                              "for"
                              "if"
                              "else"
                              "elif"
                              "while"
                              "class"
                              "try"
                              "except"
                              "finally")))

(defun dp-trim-spaces (str &optional start-p end-p)
  "Trim spaces at begin (START-P) and/or (END-P)."
  (let (start-regexp end-regexp or)
    (if (not (or start-p end-p))
        (setq start-regexp "^\\s-+"
              end-regexp "\\s-+$")
      (setq start-regexp (if start-p "^\\s-+" "")
            end-regexp (if end-p "\\s-+$" "")))
    (setq or
          (if (or (string= "" start-regexp)
                  (string= "" end-regexp))
              ""
            "\\|"))
    (replace-in-string str (format "%s%s%s" start-regexp or end-regexp) "")))

(defun dp-comment-only-line (&optional c-start c-end except-block-comments-p)
  (interactive)
  (if (functionp c-start)
      (c-start)
    (setq-ifnil c-start (or comment-start "") 
                c-end (or comment-end ""))
    (save-excursion
      ;; Fix block comments (##), but not single (#). elisp style.
      (beginning-of-line)
      (when (looking-at (format "\\s-*%s.*%s\\s-*" 
                                (dp-trim-spaces c-start nil 'end-p)
                                c-end))
        (not (and except-block-comments-p
                  (looking-at (format "\\s-*%s.*%s\\s-*" 
                                      (dp-trim-spaces block-comment-start 
                                                      nil 'end-p)
                                      c-end))))))))

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

(defun dp-py-cleanup-class ()
  (interactive)
  ;; For some reason, I see `buffer-syntactic-context' getting hosed
  ;; such that it thinks it's in a string, when it's not.  It seems
  ;; like some kind of latch-up, since it will do that for a while
  ;; and then stop.  Going to `point-min' and calling
  ;; `buffer-syntactic-context' and returning seems to fix it, but...
  ;;  For now, I'll just make sure there's no colon where I want to
  ;;  put one.
  (save-excursion
    (beginning-of-line)
    (when (re-search-forward dp-py-cleanup-class-re (line-end-position) t)
      (replace-match (format "\\1 \\2(%s)\\9"
                             (or (dp-non-empty-string (match-string 6)) 
                                 "object"))))))


(defun dp-line-has-comment-p ()
  (dp-with-saved-point nil
    (beginning-of-line)
    (comment-search-forward (line-end-position) t)))

(defun dp-fix-comment ()
  "Doesn't use `save-excursion'. It doesn't seem to work here."
  ;; `save-excursion' doesn't work here.
  ;; ??? marker vs number?
  (interactive)
  (let ((pt (point)))
    (end-of-line)
    ;;(when (memq (buffer-syntactic-context) '(block-comment comment))
    (when (dp-line-has-comment-p)
      (indent-for-comment))
    (goto-char pt)))

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

(defun* dp-py-code-text-ends-with-special-char-p (&key except special-chars new-pos)
  "Are we on a \"special\" character? E.g. one which should not be followed by a comma.
The characters are classified as good or bad by `looking-at' and so EXCEPT
must be compatible with that function.
Chars in EXCEPT are always OK. 
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
        (open-paren "")
        (close-paren "")
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
     ((let ((stat (dp-add-comma-or-close-sexp :beg (py-point 'bos) 
                                              :end (line-end-position)
                                              :caller-cmd this-command
                                              :add-here add-here)))
        (if (not (eq stat 'force-colon))
            stat
          (beginning-of-line)
          (setq something-special-p t
                colon-pos (dp-py-end-of-code-pos))
          nil))
      ;; In a `cond' , nothing here causes the last return value (ie of
      ;; predicate) to be propagated.
      )
     (t (when (and (setq something-special-p
                         (re-search-forward 
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
                colon-pos (dp-mk-marker (match-end 1))
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
            (setq colon-pos (+ (match-end 1) (length parameters) 2))
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
                       :except ")"))                 
;;                  (or (not parameters)
;;                      block-kw-p)
                 )
            (progn
              (undo-boundary)
              (goto-char colon-pos)
              (dp-fake-key-presses ?:)) ; (py-electric-colon 1) << didn't work.
          (dmessage "figure out when to insert a ,"))))
    ;; Fix regardless since it won't do anything if it's not needed.
    (dp-py-fix-comment)
    (unless no-newline-&-indent-p
      (end-of-line)
      (py-newline-and-indent)
      (dp-py-fix-comment))))            ; Fix any hosed comment spacing.
    
    
(defun* dp-func-then-exec-key-binding (func keys &optional func-args)
  (interactive)
  (apply func func-args)
  (call-interactively (key-binding keys))) 

(defun dp-end-of-line-and-enter ()
  "Go to the end of the current line and execute the command bound to the return key."
  (interactive)
  (dp-func-then-exec-key-binding 'end-of-line [return]))
;;   (end-of-line)
;;   (call-interactively (key-binding [return])))

(defun* dp-on-last-line-p (&optional (pt (point))
                           (buffer (current-buffer)))
  "Return if POINT is on the last line of the shell buffer."
  (interactive)
  (save-excursion
    (set-buffer buffer)
    (goto-char pt)
    (not (re-search-forward "\n" (point-max) t))))

(defun dp-plist-put0 (no-flip-p plist-in &rest props)
  "Just in case some day they turn plists into some fancy hash or something.
If the only item in PROPS is a list, assume the user passed in list for PROPS.
Sometimes quoted lists are easier to make when most/all elements are quoted."
  (interactive)
  (when (and (listp (car props))
             (eq (length props) 1))
    (setq props (car props)))
  (let ((plist (nconc plist-in props))
        (flip-p (not no-flip-p))
        olist)
    (loop for (prop val) on plist by 'cddr 
      do (setq olist (plist-put olist 
                                (if flip-p val prop)
                                (if flip-p prop val))))
    olist))

(defun dp-plist-put (plist &rest props)
  "Put a bunch of properties on a plist."
  (setq plist (nconc plist
                      (if (listp (car props))
                          (car props)
                        props))
        ;; We'll want to put them in in order.
        props (reverse plist))
  (apply 'dp-plist-put0 nil nil props))

(defun dp-get-mode-local-breakpoint-command0 (tmp-p)
  "So far, the defaults work for gdb and pdb."
  (if tmp-p
      (or (bound-and-true-p dp-tmp-breakpoint-command)
          (dp-mode-local-value 'dp-mode-local-tmp-breakpoint-command)
          "tbreak")
    (or (bound-and-true-p dp-breakpoint-command)
        (dp-mode-local-value 'dp-mode-local-breakpoint-command)
        "break")))

(defun dp-get-mode-local-breakpoint-command (tmp-p)
  (let ((v (dp-get-mode-local-breakpoint-command0 tmp-p)))
    (if (functionp v)
        (funcall v)
      v)))
    
(defun* dp-mk-breakpoint-command (&optional tmp-p &key (fmt "%s %s:%s") 
                                  (pos (point)))
  (interactive "P")
  (format fmt
          (dp-get-mode-local-breakpoint-command tmp-p)
          buffer-file-truename (line-number-at-pos)))

;; !<@todo XXX Make the 'here' to run-to-here kind of command by putting a
;; tbreak on the current line and issuing a 'c' command. Look to `gdb-break'
;; to see how to stuff commands into a running gdb process.
(defun* dp-copy-breakpoint-command-as-kill (&optional tmp-p &key 
                                            (fmt "%s %s:%s") (pos (point)))
  (interactive "P")
  (kill-new (message (dp-mk-breakpoint-command tmp-p :fmt fmt :pos pos))))


;;
;; This functionality must exist in the system lisp somewhere.
(defvar dp-default-round-n-places 2)

(defun dp-round-n-places (n &optional n-places)
  "Round a number N to N-PLACES.  N-PLACES defaults to 2."
  (interactive)
  (setq-ifnil n-places 2)
  (let ((factor (expt 10 n-places)))
    (/ (fround (* factor (float n))) factor)))

(defun dp-fractional-part (num &optional round-to-n-places)
  "Grab something close to the (decimal) fractional part of N.
Optionally round to ROUND-TO-N-PLACES.  If ROUND-TO-N-PLACES is t,
return the raw results of the arithmetic. By default round to
`dp-default-round-n-places'
FLOATING POINT(tm):  When close is good enough!."
  (interactive)
  (let ((frac (- (float num) (ftruncate (float num))))
        (round-to-n-places (cond
                            ((eq round-to-n-places t) nil)  ; don't round
                            ((eq round-to-n-places nil) 
                             dp-default-round-n-places)
                            (t round-to-n-places))))
    (if round-to-n-places
        (dp-round-n-places frac round-to-n-places)
      frac)))

(defun dp-round-to-1/4-hr (hours)
  (interactive)
  (* 0.25 (fround (/ (+ 0.001 hours) 0.25))))


(defvar dp-nslookup-command "host %s")
(defun dp-nslookup (host-name)
  "Lookup HOST-NAME using `dp-nslookup-command'"
  (interactive "shost-name? ")
  (let ((output (shell-command-to-string (format dp-nslookup-command 
                                                 host-name))))
    (when (posix-string-match "\\(\\S-+\\)\\s-+has address \\([0-9.]+\\)" 
                              output)
      (match-string 2 output))))

(defvar dp-/etc/hosts-list '()
  "Alist of HOSTNAME . IP-ADDR for machines where I can't edit /etc/hosts.")

(defun dp-resolve-host (host-name)
  "Resolve a HOST-NAME.  Look at dp-/etc/hosts-list as a last resort."
  (interactive "sHost? ")
)

(defun dp-win-config ()
  "Configure my windows if a config function is defined."
  (if (fboundp 'dp-initial-window-config)
      (dp-initial-window-config)))

(defun dp-queue-evals-then-top-level (events &optional cmd)
  (loop for arg in args do
    (enqueue-eval-event (or cmd 'eval) arg))
  (top-level))

(defun dp-turn-off-newbuf-hilighting ()
  (interactive)
  (remove-hook 'pre-idle-hook 'dp-pre-cmd-for-highlight-hook)
  (remove-hook 'pre-command-hook 'dp-pre-cmd-for-highlight-hook)
  (remove-hook 'post-command-hook 'dp-post-cmd-for-highlight-hook))

(defun dp-turn-on-newbuf-hilighting ()
  (interactive)
  ;; Things dying in pre/post command hooks can leave the hooks hosed and,
  ;; for me, this variable hosed.
  (when-and-boundp 'dp-highlight-point-in-new-buffer/window-p
    (setq dp-highlight-point-buffer nil)
    (add-hook 'pre-idle-hook 'dp-pre-cmd-for-highlight-hook)
    (add-hook 'pre-command-hook 'dp-pre-cmd-for-highlight-hook)
    (add-hook 'post-command-hook 'dp-post-cmd-for-highlight-hook)))

(defun dp-newbuf-hilighting (&optional off-p)
  (interactive "P")
  (if off-p 
      (dp-turn-off-newbuf-hilighting) 
    (dp-turn-on-newbuf-hilighting)))

(add-hook 'dp-post-dpmacs-hook 'dp-turn-on-newbuf-hilighting)

(defun dp-fix-cmd-hook-stuff ()
  (interactive)
  (dp-turn-on-newbuf-hilighting)
  (paren-activate))

(dp-safe-alias 'dpfch 'dp-fix-cmd-hook-stuff)

(defun dp-minibuffer-invoking-buffer (&optional buf)
  "Riskily get what we hope is the buffer we were in when we invoked the mb.
@todo ??? advise lowest level minibuffer function just before the change to
the minibuffer."
  (or buf (cadr (buffer-list))))

(defun dp-clone-frame ()
  (interactive)
  (select-frame (make-frame))
  (dp-win-config))

;;<:broken keyboard work arounds:>
;; (defun dp-broken-keyboard-bs ()
;;   (interactive)

;;   (global-set-key "\e1" (lambda () (interactive) (insert "e")))
;;   (global-set-key "\e!" (lambda () (interactive) (insert "E")))
;;   (global-set-key "\e2" (lambda () (interactive) (insert "c")))
;;   (global-set-key "\e@" (lambda () (interactive) (insert "C")))

;;   (defun isearch-process-search-char-e ()
;;     ;; Append the char ?e to the search string, update the message and
;;     ;; re-search.
;;     (interactive)
;;     (isearch-process-search-char ?e))
;;   (put 'isearch-process-search-char-e 'isearch-command t)
;;   (defun isearch-process-search-char-c ()
;;     ;; Append the char ?c to the search string, update the message and
;;     ;; re-search.
;;     (interactive)
;;     (isearch-process-search-char ?c))
;;   (put 'isearch-process-search-char-c 'isearch-command t)
;;   (defun isearch-process-search-char-E ()
;;     ;; Append the char ?E to the search string, update the message and
;;     ;; re-search.
;;     (interactive)
;;     (isearch-process-search-char ?E))
;;   (put 'isearch-process-search-char-E 'isearch-command t)
;;   (defun isearch-process-search-char-C ()
;;     ;; Append the char ?C to the search string, update the message and
;;     ;; re-search.
;;     (interactive)
;;     (isearch-process-search-char ?C))
;;   (put 'isearch-process-search-char-C 'isearch-command t)
  
;;   ;; Each command has to be a symbol so we can put the isearch-command
;;   ;; property on it.
;;   (define-key isearch-mode-map "\e1" 'isearch-process-search-char-e)
;;   (define-key isearch-mode-map "\e2" 'isearch-process-search-char-c)
;;   (define-key isearch-mode-map "\e!" 'isearch-process-search-char-E)
;;   (define-key isearch-mode-map "\e@" 'isearch-process-search-char-C)

;;   (defalias 'mdsm 'mew-draft-send-message)
;;   (defalias 'mdpa 'mew-draft-prepare-attachments)
;;   (defalias 'mak 'mew-attach-copy)
;;   (defalias 'mds 'mew-draft-cite)
;;   (defalias 'msx 'mew-summary-execute-command)
;;   (defalias 'msks 'mew-summary-kill-subprocess)

;;   (dmessage "EA!"))

;;(add-hook 'dp-post-dpmacs-hook 'dp-broken-keyboard-bs)

(defun dp-add-new-file-template (&optional template &rest template-args)
  (interactive "\sname: ")
  ;; template can be a simple string or a list:
  ;; \(function args).
  (cond
   ;; The function calls return the 'added-junk-p or not as they see fit.
   ((functionp template)
    (undo-boundary)
    (apply template template-args))
   ((and template (listp template))
    (apply (car template (cdr template))))
   ;; Simple string.  Just insert and tell the caller.
   ;; To get a simple string to control the return, do use a simple
   ;; function like so...
   ;; :template (lambda (s r) (insert s) r) &rest s r
   ((symbolp template)
    (insert (symbol-value template)))
   ((stringp template) 
    (insert template)
    'added-junk)
   ;; Nada adda
   (t nil)))
;; This indirect method of getting the template is kinda on the obfuscated
;; side.
;;;   (let ((template-sym (intern-soft (format "dp-%s-template" name))))
;;;     (if (not (bound-and-true-p template-sym))
;;;         (when default-string (insert default-string))
;;;       (let ((template (or template (symbol-value template-sym)))
;;;         (undo-boundary)
;;;         (if (listp template)
;;;             (progn 
;;;               (apply (car template (cdr template)))
;;;               nil)
;;;           ;; The template string has total control of all text (especially
;;;           ;; newline whitespace) so that a simple string can do ~anything.
;;;           (insert template)
;;;           'add-junk)))))

(defvar dp-script-buffers-to-ignore-regexp "^\*\\| "
  "Buffers usually not associated with a file.  
If it is indeed a script name <script>-it can be called interactively.")

(defun* dp-script-it (&key interpreter 
                      run-with-/usr/bin/env-p
                      (make-executable-p t) 
                      comm-start
                      (add-to-svn-p 'check)
                      template 
                      template-args)
  (interactive "sinterpreter: \nP")
  (when (string-match dp-script-buffers-to-ignore-regexp
                      (buffer-name))
    (return-from dp-script-it))
  (goto-char (point-min))
  (unless (re-search-forward (regexp-quote interpreter) (line-end-position) t)
    (unless (string-match interpreter "^#!")
      (insert "#!"))
    (insert (if run-with-/usr/bin/env-p 
                "/usr/bin/env "
              "") 
            ;; Let template determine the spacing after the #! line
            ;; ? and newline?
            interpreter "\n"))
  (dp-set-auto-mode)
  (let (added-junk-p)
    (when dp-time-stamps-in-new-file-templates-p
      ;; Don't clobber the real value of comment-start.
      (let ((comment-start (or comm-start comment-start)))
        (dp-insert-time-stamp-field))
      (setq added-junk-p 'added-junk)
      (insert "\n"))
    ;; If we added junk to the file, we'll want to add a newline. Unless we
    ;; don't.
    (when (eq 'added-junk (or (dp-add-new-file-template template
                                                        template-args)
                              added-junk-p))
      (insert "\n")
      (previous-line 1)))                  ; Don't want to be on the [EOF] line
  (when make-executable-p
    (dp-cx-file-mode))
  (dp-push-go-back (format "dp-script-it %s" interpreter) (- (point-max) 1))
  ;; Let the user quit without having to muck about with undos or
  ;; confirmations. Since everything was added magically, there's really
  ;; nothing to lose.
  (set-buffer-modified-p nil))

(defcustom dp-sh-new-file-template
  "
source script-x
set -u

"
  "A string to stuff into each new fire created with `dp-script-it'
or a list: \(function args).
An `undo-boundary' is done before the template is used."
  :group 'dp-vars
  :type '(repeat string))

(defun shit ()
  (interactive)
  (dp-script-it :interpreter "/bin/sh"
                :template dp-sh-new-file-template))

(defun bashit ()
  (interactive)
  (dp-script-it :interpreter "/bin/bash"
                :template dp-sh-new-file-template))

(defun perlit ()
  (interactive)
  (dp-script-it :interpreter "perl" 
                :run-with-/usr/bin/env-p 'RUN-WITH-/USR/BIN/ENV-P))

;;
;; #############################################################################
;; ## @package 
;; ##
;; Don't insert the doxy package comment now.  It's better to do it by hand
;; when all of tempo prompting and such can help you out.

(defcustom dp-python-new-file-template
  "
import sys, os

def main(argv):
    import getopt
    opt_string = \"\"
    opts, args = getopt.getopt(argv[1:], opt_string)
    for o, v in opts:
        #if o == '-<option-letter>':
        #    # Handle opt
        #    continue
        pass

    for arg in args:
        # Handle arg
        pass

if __name__ == \"__main__\":
    main(sys.argv)

"
  "A string to stuff into each new file created with `dp-script-it'
or a list: \(function args).
An `undo-boundary' is done before the template is used."
  :group 'dp-vars
  :type '(repeat string))

;;what was this?; (defun dp-lang-new-file-template-any-old-hack-string-matches (&optional 
;;what was this?;                                                               rest-o-hack-line 
;;what was this?;                                                               mode)
;;what was this?;   (interactive)
;;what was this?;   ;; E.g. /* -*- mode: c++; c-file-style: "crl-c-style" -*- */
;;what was this?;   (let* ((hack-format-string "%s -*- mode: %s; %s -*- %s\n")
;;what was this?;          (hack-regexp (format (regexp-quote hack-format-string)
;;what was this?;                               ".*" ".*" ".*" ".*"))
;;what was this?;          (mode (or mode mode-name (error "No mode name!"))))
;;what was this?;     (unless (save-excursion (re-search-backward hack-regexp nil t))
;;what was this?;       (insert 
;;what was this?;        (format hack-format-string 
;;what was this?;                (or comment-start "NO COMMENT START")
;;what was this?;                mode
;;what was this?;                (or rest-o-hack-line "")
;;what was this?;                (or comment-end ""))))))

(defun dp-lang-new-file-template (&optional rest-o-hack-line 
                                  any-mode-line-p 
                                  mode)
  "Put language specific template code into a new file."
  (interactive)
  ;;(regexp-quote hack-format-string)
  ;; E.g. /* -*- mode: c++; c-file-style: "crl-c-style" -*- */
  (let* ((hack-format-string "%s-*- mode: %s;%s-*-%s")
         (mode (or mode mode-name (error "No mode name!")))
         ;; Regexp to check for an existing mode line.
         (hack-regexp (if any-mode-line-p
                          ;; Here we consider *any* hack with a "mode:" in to
                          ;; be an existing mode line.
                          (format (regexp-quote hack-format-string)
                                  ".*" ".*" ".*" ".*")
                        ;; Here, we ignore comment chars when looking for an
                        ;; existing hack line.
                        (format (regexp-quote hack-format-string)
                                ".*"    ; Any open comment chars.
                                (regexp-quote mode)
                                (if rest-o-hack-line
                                    (regexp-quote (concat " " 
                                                          rest-o-hack-line 
                                                          " "))
                                  " ")
                                ".*"))) ; Any ending comment chars.
         (hack-string (format hack-format-string
                               (or comment-start "NO COMMENT START")
                              mode
                              (if rest-o-hack-line
                                  (concat " " rest-o-hack-line " ")
                                " ")
                              (concat (or (and comment-end
                                               (concat " " comment-end))
                                          "")))))
         (unless (save-excursion
                   (goto-char (point-min))
                   (re-search-forward hack-regexp nil t))
           (insert hack-string "\n"))
         ;; This needs to be conditionalized so we don't get more'n one.
         (if (bound-and-true-p dp-apel-time-stamp-enabled-p)
             (insert (or comment-start 
                         (error "AHHH! No comment start char(s))"))
                     "Time-stamp: <> "
                     (or comment-end "")
                     "\n\n"))
         (insert "\n")
         (goto-char (point-max))))

(defun dp-c-new-file-template (&optional rest-o-hack-line any-mode-line-p 
                               mode)
  (interactive)
  ;; E.g. /* -*- mode: c++; c-file-style: "crl-c-style" -*- */
  (dp-lang-new-file-template (or rest-o-hack-line 
                                 (concat  "c-file-style: "
                                          "\"" 
                                          dp-default-c-style-name
                                          "\""))
                             (or any-mode-line-p current-prefix-arg)
                             mode))

(defun pyit ()
  "Set up a buffer as a Python language buffer.
Inserts `dp-python-new-file-template' by default."
  (interactive)
  (let ((comment-start "###"))
    (dp-script-it :interpreter "python" 
                  :run-with-/usr/bin/env-p t
                  :comm-start comment-start
                  :template dp-python-new-file-template)))


(defun* dp-get-buffer-local-value (&optional var buffer 
                                   &key (pred 'dp-nilop)
                                   (default nil)
                                   (default-args nil))
  (interactive "svar: \nbbuffer: ")
  (dmessage "gblv: buffer: %s" buffer)
  (with-current-buffer (if buffer
                           (get-buffer buffer)
                         (current-buffer))
    
    (setq default (dp-apply-if 
                      default default-args
                    default))
    (cond
     ((and (symbolp var)
              (boundp var))
      (symbol-value var))
     ((not var) default)
     ((funcall pred var) var)
     ((stringp var)
      (if (string= var "") 
          default
        (setq var (intern-soft var))
        (if var
            (setq var (symbol-value var))
          (error (format "var not found: %s" var)))))
     ;; Or do we just want to return var here?
     (t var)
     (nil (error (format "can't figure out what var >%s< is." var))))))


(defun dp-get-buffer-local-syntax-table (&optional tab buffer)
  (interactive "ssyntax-table name: \nbbuffer(return for current): ")
  (dp-get-buffer-local-value tab buffer
                             :pred 'syntax-table-p
                             :default 'syntax-table))
                             

(defun* dp-pp-bracketed (value &key (prefix ">") (suffix "<") 
                         (stream standard-output) (newline-p t))
  (princ prefix stream)
  ;; How to put this on stream?
  (with-current-buffer (if (bufferp stream) stream (current-buffer))
    (cl-prettyprint value))
  (princ suffix stream)
  (when newline-p
    (princ "\n")))

(defun dp-symbol-info (symbol-name)
  (interactive (list (dp-prompt-with-symbol-near-point-as-default 
                      "symbol name")))
  (with-output-to-temp-buffer (format "*Symbol Info: `%s'*" symbol-name)
    (with-current-buffer standard-output
      (let ((symbol (intern-soft (format "%s" symbol-name))))
        (princf "Info about %s\n\n" symbol-name)
        (if (not symbol)
            (princf "Don't know symbol: %s\n" symbol-name)
          (dp-pp-bracketed (symbol-plist symbol) :prefix "symbol-plist:" 
                           :suffix "\n--")
          (when (boundp symbol)
            (dp-pp-bracketed (symbol-value symbol) :prefix "symbol-value:" 
                             :suffix "\n--"))
          (when (fboundp symbol)
            (dp-pp-bracketed (symbol-function symbol) 
                             :prefix "symbol-function:" 
                             :suffix "\n--"))
          (when ())
          (unless (or (boundp symbol)
                      (fboundp symbol))
            (princ "Symbol isn't *boundp.\n"))))
      (help-mode))))
(defalias 'dsi 'dp-symbol-info)

(defun dp-c-reformat-buffer (&optional file-name)
  (interactive)
  (when file-name
    (find-file file-name))
  (dp-untabify (point-min) (point-max))
  (c-indent-region (point-min) (point-max)))

(defun dp-c-reformat-buffers ()
  (interactive)
  (mapc (function
         (lambda (buf)
           (set-buffer buf)
           (princf "woulda formatted: %s\n" buffer-file-name)
           ;(dp-c-reformat-buffer)
           (when (noninteractive)
             (save-buffer)
             (kill-buffer))))
        (dp-choose-buffers 
         (function
          (lambda (buf &rest unused)
            (memq (buffer-local-value 'major-mode buf) 
                  '(c-mode c++-mode))))))
  (when (noninteractive)
    (kill-emacs)))

(defun dp-mk-mode-obarray-name (mode-name-or-sym)
  "Make a mode specific obarray name."
  (format "dp-%s-obarray" mode-name-or-sym))

(defun dp-mode-local-obarray (mode-name-or-sym)
  "Get the mode specific obarray for MODE-NAME-OR-SYM if there is one."
  (let ((mob-name (dp-mk-mode-obarray-name mode-name-or-sym)))
    (intern-soft mob-name)))

(defun* dp-mk-mode-obarray (mode-name-or-sym &optional (size 32))
  "Create a new mode specific obarray."
  (let ((mob-name (dp-mk-mode-obarray-name mode-name-or-sym)))
    (unless (intern-soft mob-name)
      (set (intern mob-name) (make-vector size 0))
      (put (intern mob-name) 'variable-documentation 
           (format "mode local obarray for %s" mode-name-or-sym)))
    (intern mob-name)))

(defun dp-mode-local-value (var-sym &optional mode-name-or-sym)
  "Get a mode local variable VAR-SYM's value.
Returns nil if there is either no mode obarray or no VAR-SYM in the mode's obarray.
!<@todo Should this throw an error?"
  (let* ((mob (dp-mode-local-obarray (or mode-name-or-sym major-mode)))
         (vsym (when mob (intern-soft (format "%s" var-sym)
                                      (symbol-value mob)))))
    (if vsym
      (symbol-value vsym))))

(defun dp-mode-local-value-p (var-sym &optional mode-name-or-sym)
  "Return nil if there is not a mode local variable VAR-SYM.
Otherwise return \('mode-local-value . value\).  This allows us to
differentiate twixt no variable and an unset variable. "
  (let* ((mob (dp-mode-local-obarray (or mode-name-or-sym major-mode)))
         (vsym (when mob (intern-soft (format "%s" var-sym)
                                      (symbol-value mob)))))
    (when vsym
      (cons 'mode-local-value (symbol-value vsym)))))

(defun dp-set-mode-local-value (var-sym value &optional mode-name-or-sym-list)
  "Make VAR-SYM have a separate value for each mode.
Set VAR-SYM to VALUE for all buffers with modes in MODE-NAME-OR-SYM-LIST.
The variable bindings are kept in MLOs: mode local obarray(s).
MLOs are created as needed.
MODE-NAME-OR-SYM-LIST can be a single mode symbol, or a list of them.
VAR-SYM is interned in the MLOs of the given modes. 
MODE-NAME-OR-SYM-LIST defaults to the current `major-mode'.
This is useful for, say, setting `dp-open-newline-func' in multiple languages
with C type syntax.
!<@todo XXX Is this better than setting a buffer local var in each mode's
hook? A minus is needing to use a special accessor.
!<@todo XXX Would this be better done via properties on the mode name symbol?"
  (setq mode-name-or-sym-list 
        (cond
         ((not mode-name-or-sym-list) (list major-mode))
         ;; For the lazy ones
         ((not (listp mode-name-or-sym-list))
               (list mode-name-or-sym-list))
         (t mode-name-or-sym-list)))
  (let (mob vsym)
    (loop for mode in mode-name-or-sym-list
      do
      (setq mob (symbol-value (dp-mk-mode-obarray mode))
            vsym (intern (format "%s" var-sym) mob))
      (set vsym value)))
  value)


(defun dp-eol-and-eval ()
  (interactive)
  (end-of-line)
  (eval-print-last-sexp))

(defun dp-isa-face-p (face)
  (condition-case nil
      (or (facep face) (find-face face))
    (t nil)))

(defun dp-what-cursor-position (&optional no-highlight-p)
  (interactive "_P")
  (call-interactively 'what-cursor-position)
  (unless no-highlight-p
    (dp-highlight-point-until-next-command)))

(defun* dp-grep-vars (regexp &key symbol-name-regexp (pred 'boundp) 
                      (prompt-p nil) (buffer (current-buffer)))
  "Grep for REGEXP in all variables whose name matches SYMBOL-NAME-REGEXP."
  (interactive "svalue regexp: ")
  (when (or prompt-p (and (interactive-p) current-prefix-arg))
    (setq symbol-name-regexp (dp-prompt-with-symbol-near-point-as-default
                              "symbol regexp"))
    (when (Cup 2)
      (setq pred
            (read-function (format "symbol pred (default: #'%s)" 
                                   pred) 
                           pred))))
  (with-current-buffer buffer
    (delq nil
          (mapcar (function 
                   (lambda (atom)
                     (when (and (string-match regexp 
                                              (format "%s" 
                                                      (symbol-value atom)))
                                ;; Don't include matches on the var holding
                                ;; the regexp itself.
                                (not (eq atom 'regexp)) 
                                )
                       atom)))
                  (apropos-internal (or symbol-name-regexp ".*") 
                                    pred)))))
  
(defun* dp-grep-stringified-sym-vals (regexp &key symbol-name-regexp 
                                      (prompt-p t))
  "Find stringified values matching REGEXP of all symbols matching SYMBOL-NAME-REGEXP.
SYMBOL-NAME-REGEXP defaults to \".\"."
  (interactive)
  (dmessage "dp-grep-string-vars: NEEDS WORK!")
  (dp-grep-vars regexp :pred (lambda (sym)
                               (and (boundp sym)
                                    (stringp (symbol-value sym))))
                :symbol-name-regexp symbol-name-regexp
                :prompt-p (not regexp))
  )



(defun dp-eval-defun-or-region ()
  (interactive)
  (prog1
      (call-interactively (if (dp-mark-active-p) 'eval-region 'eval-defun))
    (when (dp-mark-active-p)
      (message "eval'd region."))))

(defun* dp-flatten-list (l &optional (pred 'dp-nop-t))
  "Flatten a list which may have lists as elements (which may...) into a list of atoms.
By its nature, all nils will be discarded.
I'm sure I've missed an already existing function that does this."
  (interactive)
  (mapcan (lambda (x)
            (if (listp x)
                (dp-flatten-list x pred)
              (if (funcall pred x)
                  (list x)
                nil)))
          l))

(defun dp-make-local-hooks (hooks &optional buffer)
  (with-current-buffer (or buffer (current-buffer))
    (loop for hook in hooks
      do (make-local-hook hook))))

(defun ascii ()
  (interactive)
  (manual-entry "ascii"))

(defun dp-replace-last-kill (&optional killed-text)
  "Replace the most recent kill with the region.
Uses way too much inside info."
  (interactive "r")
  (kill-new (or killed-text (buffer-substring (mark) (point))) t))

(autoload 'id-select-symbol "id-select" "Return the symbol about point." "" t)
(defun dp-id-select-thing ()
  (interactive)
  (call-interactively 'id-select-thing))

(defun dp-id-select-and-copy-thing ()
  (interactive "_")
  ;; `id-select-thing' expands selection if mark is active; doesn't use
  ;; last-command.  So we just call it and copy it.
  (if (eq last-command 'dp-id-select-and-copy-thing)
      (progn
        (dp-activate-mark)
        (call-interactively 'dp-id-select-thing)
        (dp-replace-last-kill (buffer-substring (mark) (point))))
    (call-interactively 'dp-id-select-thing)
    ;;;(copy-region-as-kill 
    (kill-ring-save (mark) (point)))
  (if (sit-for 1)
      ;; A `sit-for' interrupted by (at least) another
      ;; `dp-id-select-and-copy-thing' plus a `dp-deactivate-mark' messes up
      ;; the state of the zmacs region, so we only deactivate when the
      ;; `wait-for' completes with a timeout.
      (dp-deactivate-mark)))

(defun dp-sizeof-match-data (&optional match-data)
  (/ (length (or match-data (match-data))) 2))

(defun dp-all-match-strings (&optional match-string match-data)
  "Return a list of all match strings. 
MATCH-STRING is required when the match data was produced by a string match.
Optionally use MATCH-DATA instead of the existing match-data."
  (interactive)
  (let ((match-data (or match-data (match-data)))
        (access-fun (if match-data
                        (lambda (index &rest junk)
                          (nth i match-data))
                      'match-string)))
    (loop for i from 0 to (1- (dp-sizeof-match-data))
      collect (funcall access-fun i match-string))))

(defun* dp-all-match-strings-string (&key (match-string-args nil) 
                                     (string-join-args nil))
  "Concat all match data into a single string.
MATCH-STRING-ARGS are passed through to `dp-all-match-strings'. 
A matched against string here is common.
STRING-JOIN-ARGS are passed through to `dp-string-join'. "
  (interactive)
  (apply 'dp-string-join 
         (apply 'dp-all-match-strings match-string-args) 
         string-join-args))

(defun dp-window-dedicated-p (&optional win buffer)
  (window-dedicated-p (or win (dp-get-buffer-window buffer))))
                       
(defun dp-get-buffer-window (&optional buffer frames devices)
  "Like `get-buffer-window' but allows buffer to be a name, too.
Also allows BUFFER to be nil and will then use `current-buffer'.
Uses `get-buffer' to get the buffer."
  (when buffer
    (setq buffer (get-buffer buffer)))  ; Let "names" work, too.
  (get-buffer-window (or buffer (current-buffer)) frames devices))

(defun dp-layout-compile-windows-func ()
  "Split the frame into multiple windows based on the current frame width."
  (if (dp-wide-enough-for-2-windows-p)
      (dp-win-layout-2-left-of-1)
    (dp-layout-windows '(delete-other-windows
                         split-window-vertically
                         (other-window -1)))))

(defvar dp-layout-compile-windows-func 'dp-layout-compile-windows-func
  "*Function to partition frame for compilation.
It is called after `delete-other-windows', but should do that anyway so it
can be called from other places.  It should leave point in the window that
will become the compilation window.")

(defun dp-layout-compile-windows (&optional original-window-config)
  "Setup window layout for compling/Make-ing programs."
  (interactive)
  ;;(delete-other-windows)
  (when (eq major-mode 'compilation-mode)
    ;; Splitting up the compilation buffer makes it impossible to know which
    ;; resulting window is the one I want.
    (switch-to-next-buffer))
  (funcall (or dp-layout-compile-windows-func 'split-window-vertically))
  (dp-find-compilation-buffer 'creat)  ; Leaves us in the compilation buffer.
  (when (and (not dp-saved-window-config)
             original-window-config)
    (dmessage "saving win config, buffer>%s<" (current-buffer))
    (setq dp-saved-window-config original-window-config))
  (when dp-use-dedicated-make-windows-p
    (set-window-dedicated-p (dp-get-buffer-window) t))
  ;;(compilation-set-window-height (dp-get-buffer-window)))
  (dp-compilation-set-window-height (dp-get-buffer-window))
  (dp-end-of-buffer 'no-save))
(defalias 'cw 'dp-layout-compile-windows)



(defun dp-compilation-set-window-height (window)
  "Don't have `make' bail if window isn't full frame width."
  (and compilation-window-height
       ;; Check if the window is split horizontally.
       ;; Emacs checks window width versus frame-width:
       ;;   (= (window-width window) (frame-width (window-frame window)))
       ;; But XEmacs must take into account a possible left or right
       ;; toolbar:
;        (and (window-leftmost-p (selected-window))
; 	    (window-rightmost-p (selected-window)))
       ;; If window is alone in its frame, aside from a minibuffer,
       ;; don't change its height.
       (not (eq window (frame-root-window (window-frame window))))
       ;; This save-excursion prevents us from changing the current buffer,
       ;; which might not be the same as the selected window's buffer.
       (save-excursion
	 (let ((w (selected-window)))
	   (unwind-protect
	       (progn
		 (select-window window)
		 (enlarge-window (- compilation-window-height
				    (window-height))))
	     (select-window w))))))

(defun dp-edit-spec-macs (&optional file-name)
  "Load one of my location (I say, ?incorrectly?, locale.) specific config files.
The default FILE-NAME is the most specific config file.  The other
spec-macsen are used for the completion list."
  (interactive)
  (setq-ifnil file-name dp-most-specific-spec-macs)
  (find-file (completing-read 
              (format "spec macs: %s: " (if file-name 
                                        (format "(default: %s)" file-name)
                                      ""))
              (dp-mk-completion-list dp-loaded-spec-macsen) 
              nil t nil 'file-name-history
              file-name)))
(defalias 'esm 'dp-edit-spec-macs)

(defvar dp-major-mode-to-shebang
  ;; Symbol for key, plist for value
  '((python-mode i-name "python" env-p run-with-/usr/bin/env-p 
                 comment-start "### " template dp-python-new-file-template)
    ;;(sh-mode i-name "/bin/sh")
    (sh-mode it shit)
    (c-mode it dp-c-new-file-template)
    (c++-mode it dp-c-new-file-template)
    ;; Just point to a *it function
    (example-mode it example-it)
    ;; can't guess bash mode since #!/bin/bash puts buffer into regular
    ;; sh-mode.
    ;;;(bash-mode "/bin/bash" nil)
    (perl-mode i-name "perl" env-p run-with-/usr/bin/env-p))
  "Association List keyed by major mode symbol.
Items are a list: 
\(key plist\)
Where plist has elements:
'i-name - interpreter name as a string
'env-p - run interpreter with /usr/bin/env <interpreter-name>
'comment-start - for customizing the comment chars preceding the time-stamp
'make-exe-p - should we make the file executable?")

(defvar dp-auto-it-found-buffer-empty-p nil
  "Hack for empty/new file initialization. If we use this, then >1
  initializers can run. Otherwise, the first one makes the buffer non-empty
  for the rest. Dealing with ordering will be a bitch. Another way should be
  found to run them all at once, in one place. Duh.")

(defun dp-auto-it ()
  "Automagically determine what interpreter we should put in the shebang."
  (interactive)
  (let ((info-plist (cdr (assoc major-mode dp-major-mode-to-shebang))))
    (undo-boundary)
    (if info-plist
        (if (plist-get info-plist 'it)
            (let ((it (plist-get info-plist 'it)))
              (apply it (plist-get info-plist 'it-args)))
          (dp-script-it :interpreter (plist-get info-plist 'i-name) 
                        :run-with-/usr/bin/env-p (plist-get info-plist 'env-p)
                        :make-executable-p (plist-get info-plist 'make-exe-p t)
                        :comm-start (plist-get info-plist 'comment-start)
                        :template (plist-get info-plist 'template )
                        :template-args (plist-get info-plist 'template-args)))
      (call-interactively 'dp-script-it))
    (set-buffer-modified-p nil)))

(defun dp-auto-it? ()
  "Automagically call `dp-auto-it' on empty fileses."
  (interactive)
  (and (dp-buffer-empty-p)
       (setq dp-auto-it-found-buffer-empty-p t)
       (dp-auto-it)))
;;replaced by the above;   (and (eq (point-min) 1)
;;replaced by the above;        (equal (point-min) (point-max))
;;replaced by the above;        (dp-auto-it)))

(defvar dp-cx-mode-bits #o110
  "Who do we want to allow to execute this thing.")

(defvar dp-cx-numask #o776
  "Directly AND-able mask, unlike umask\(1)'s negated mask.
We'll do \(logand dp-cx-mode-bits dp-cx-numask)")

(defun dp-decoded-file-mode (file-name)
  "Return a string of a decoded file mode like ls -l would show.
FILE-NAME is a string file-name.
@todo - is there an elisp function to do this?"
  (let ((res (substring 
              (shell-command-to-string 
               (format "ls -ld %s | cut -f1 -d' '" file-name)) 0 -1)))
    ;; (length "drwxr-xr-x") 10
    ;; The only way I can (quickly) think of to determine if an error
    ;; occurred.
    (and (= (length res) 10)
         res)))

(defun dp-cx-file-mode (&optional file-name new-file-hook)
  "Give file in current buffer execute permissions.
new-file-hook will only be used when calling this as a one-shot hook.  It
tells the hook function that this file did not exist when this function was
originally called.  We use this so that we can do things like add files to a
vc system, etc. When I figure out how to do closure like things."
  (interactive)
  (setq-ifnil file-name buffer-file-truename)
  (let ((orig-decoded-file-mode (dp-decoded-file-mode file-name))
        (file-modes (file-modes file-name)))
    ;; File doesn't exist, defer action until after it is saved.
    ;; When this is called after the save, the file will (should, MUST!) 
    ;; exist so we won't (shan't, CAN'T) recurse.
    (if (not file-modes)
        (add-local-one-shot-hook 'after-save-hook (lambda ()
                                                    (dp-cx-file-mode)))
      (set-file-modes file-name
                      ;; Add our bits (or) to the existing bits.
                      (logior (file-modes file-name)
                              (logand dp-cx-numask dp-cx-mode-bits)))
      (message "%s's mode is now: %s (was%s: %s)" 
               (file-name-nondirectory file-name)
               (dp-decoded-file-mode file-name)
             (if (string= (dp-decoded-file-mode file-name) 
                          orig-decoded-file-mode)
                 " already"
               "")
             orig-decoded-file-mode))))

(defun dp-fake-key-presses (&rest keys)
  "Create and dispatch key events for KEYS.
If any element of KEYS is a string, then recursively call ourself with the
string's characters.
** I know there must be a function to do this."
  (loop for k in keys do
    (if (stringp k)
        (apply 'dp-fake-key-presses (string-to-list k))
      (dispatch-event (make-event 'key-press (list 'key k))))))

(defun dp-other-frame (lower-frame-p)
  "Add the ability to request that the new frame be lowered.
\(I'd prefer to be able to say don't raise or lower, but I don't know how.)
Raised is already done by XEmacs. Is this an FSF holdover or just a brain-fart?"
  (interactive "P")
  (other-frame 1)
  (when (eq lower-frame-p '-)
    (lower-frame)))

(defun dp-other-frame-up (arg)
  "Other frame, up."
  (interactive "p")
  (other-frame (- arg)))

(defun dp-delimit-function-like-statement (&optional beg)
  (interactive)
  (if beg
      (goto-char beg)
    (beginning-of-line))
  (when (search-forward "(" nil t)
    (backward-char)
    (cons (point) (dp-matching-paren-pos))))

(defun dp-fill-region (&optional line-breaker max-line-len)
  (interactive)
  (setq-ifnil line-breaker 'c-context-line-break)
  (let* ((region (dp-region-or... 
                  :bounder 'dp-delimit-function-like-statement))
         (dumby (dmessage "region: %s" region))
         (beg (dp-mk-marker (car region)))
         ;; If they're in col 0, then we will assume that they don't want the
         ;; current line to be included and so we don't use
         ;; `line-end-position'.
         (end (dp-mk-marker (save-excursion 
                              (goto-char (cdr region))
                              (if (bolp)
                                  (if (bobp)
                                      (cdr region)
                                    (1- (cdr region)))
                                (line-end-position)))))
         (max-line-len (dp-c-fill-column max-line-len)))
    (dmessage "b: %s, e: %s" beg end)
    (if (not (and beg end))
        (error "Cannot determine region.")
      (dp-deactivate-mark)
      (goto-char beg)
      (dp-c-stack-rest-of-statement end)
      (while (< (line-end-position) end)
        (join-line)
        (when (> (- (line-end-position) (line-beginning-position)) 
                 max-line-len)
          (funcall line-breaker))))))


(defun dp-backword ()
  "Like `backward-word' except we'll stay put @ bol and 1st char of word."
  (cond
   ((bolp) nil)
   ((and (looking-at "\\S-")
         ;; We're at the first char of the word, just where `backword'
         ;; would've taken us.
         (dp-looking-back-at "\\W")) nil)
   (t (backward-word))))

    
(defvar dp-py-insert-self-re (concat "^\\(?:\\s-*\\)def\\s-+"
                                          "\\("  ; ms[1]
                                             "\\("  ; ms[2]
                                                ".*(\\s-*"
                                             "\\)" ; ms[2]
                                          "\\|"
                                             "\\("  ; ms[3]
                                                "\\(?:"  ; ms[x]
                                                   "\\w\\|\\s-"
                                                "\\)+"
                                             "\\)"  ; ms[3]
                                          "\\)"  ; ms[1]
                                          )
  "Regex to determine if a `self,' needs to be inserted for a method call.")
  
(defvar dp-py-data-member-prefix "d_"
  "Prefixed to data members to:
1) Clearly ID data members (This Is NOT Hungarian!)
2) Prevent clashes with method names.")

(defun dp-py-insert-self? (initialize-p)
  "Insert the bane of Python: self, before the current/preceding word.
INITIALIZE-P says to do the common Python __init__() operation:
def __init__(var):
  var<M-s> ==> self.var = var"
  (interactive "P")
  (if (let ((pt (dp-mk-marker)))
        ;; Inside args parens, e.g. def imafunc(-!-
        ;; OR at the end of what looks like a def:
        ;; def imgonnabeafunc-!-
        (when (dp-looking-back-at dp-py-insert-self-re)
          (if (string= "" (match-string 1)) 
              (goto-char pt)
            (undo-boundary)
            (when (< 0 (length (match-string 3)))
              (insert "(self, "))
            (when (< 0 (length (match-string 2)))
              (insert "self, ")))
          t))
      ()                              ; Everything was done in the predicate.
    ;; We need the marker to stay in front of the insertion.
    (let ((pt (dp-mk-marker nil nil t)))
      (undo-boundary)
      (dp-backword)
      (unless (dp-looking-back-at "\\<self\\.")
        (insert (format "self.%s" dp-py-data-member-prefix)))
      (goto-char pt)))
  (when initialize-p
    (save-excursion
      (dp-backword)            ; @ self.-!-<prefix>var_name, e.g. self.d_blah
      ;; Skip past the prefix
      (forward-char (length dp-py-data-member-prefix))
      (mark-word)
      (let ((var-name (dp-get--as-string--region-or...)))
        (forward-word)
        (if (looking-at "\\s-*=")
            (progn
              (replace-match " =")
              (unless (looking-at "\\s")
                (insert " ")))
          (insert " = "))
        (insert var-name)))
    (dp-deactivate-mark)))

(defsubst dp-xor (a b)
  "I can't believe there's not logical xor... or that they call bitwise xor, et.al. log*"
  ;; The nots of a & b guarantee they are t or nil.
  (not (eq (not a) (not b))))

(defun dp-looking-at-with-re-search-params (regexp &optional limit noerror 
                                            count buffer)
  (with-narrow-to-region (point) (or limit (point-max))
    (looking-at regexp)))


(defun dp-column-at (&optional pos)
  "Given a position in a file, determine which column it is in.
Assuming 1 character per column. This is useful when TAB chars are present
because then the relationship between chars and columns isn't 1:1."
  (save-excursion
    (when pos
      (goto-char pos))
    (current-column)))

(defun dp-num-chars-to-column (col)
  "Given a column, how many characters does it take to get to this column.
For example, if the first character on a line is a TAB character, and the TAB
width is 8, then the number of chars to get to column 8 is 1 (the TAB)."
  (save-excursion
    ;; `move-to-column' returns nil if not enough columns
    (when (>= (move-to-column col) col)
      ;; There are at least col columns on the line
      (- (point) (line-beginning-position)))))

(defun dp-non-empty-string (str)
  (and str (stringp str)
       (not (string= "" str))
       str))

(defconst dp-time-stamp-preferred-style "Time-stamp: <>")
(defconst dp-time-stamps-in-new-file-templates-p nil)

(defun* dp-comment-string (str &optional 
                           (cs (or comment-start ""))
                           (ce (or comment-end "")))
  (interactive "stext: ")
  (concat cs str ce))

(defun dp-insert-time-stamp-field ()
  (interactive)
  (if (> (line-number) time-stamp-line-limit)
      (error (format "you are past the time-stamp-line-limit: %s"
                     time-stamp-line-limit))
    (beginning-of-line)
    (insert (dp-comment-string dp-time-stamp-preferred-style))))

(defun* dp-maybe-kill-process-buffer-and-window (&optional 
                                                 (buffer (current-buffer))
                                                 (proc-live-func
                                                  'comint-interrupt-subjob))
  (interactive)
  (if (dp-buffer-process-live-p buffer)
      (call-interactively proc-live-func)
    (let ((win (get-buffer-window buffer)))
      ;; `kill-buffer-and-window' prompts.
      (dp-kill-buffer buffer)
      (delete-window win))))

(defun dp-canonical-window-list (&optional frame minibuf window)
  "I think it returns a window list beginning with the current window."
  (interactive)
  (let* ((first-win (or window (car (window-list frame minibuf window))))
         (win-list (list first-win))
         (win nil))
    (if (equal first-win (setq win (next-window first-win)))
        win-list                        ; Done.
      (while (not (equal win first-win))
        (setq win-list (cons win win-list))
        (setq win (next-window win)))
      (nreverse win-list))))

(defun dp-rest-of-buffer-cons (&rest ignored)
  (cons (point) (point-max)))

(defun* dp-func-on-region-or... (&rest args-for-dp-region-or...
                                 &key (func (lambda ()
                                              (error "I need a func!")))
                                 (mark-p nil)
                                 (narrow-p nil)
                                 (dont-pass-region-args-p nil)
                                 (a-list-of-func-args '())
                                 &allow-other-keys)
  "Usually DONT-PASS-REGION-ARGS-P will be used with MARK-P or NARROW-P."
  (let* ((region (apply 'dp-region-or... args-for-dp-region-or...))
         (beg (car region))
         (end (cdr region)))
    (when mark-p
      (dp-mark-region region))
    (when narrow-p
      (narrow-to-region beg end))
    (if dont-pass-region-args-p
        (apply func a-list-of-func-args)
      (apply func beg end a-list-of-func-args))))

(defun* dp-narrow-to-region-or... (&rest args-for-dp-region-or...)
  (interactive)
  ;; This was the inspiration for dp-func-on-region-or..., where I was gonna
  ;; pass 'narrow-to-region, but I added the :narrow-p arg and so this became
  ;; trivial.
  (apply 'dp-func-on-region-or... :narrow-p t :bounder'rest-of-buffer-p
         :func 'dp-nop
         args-for-dp-region-or...))

(defun dp-uniq-lines1 (&optional text-only-p)
  "Removed duplicate lines from (point-min) to (point-max).
Actually until `forward-line' goes nowhere."
  (goto-char (point-min))
  (let (regexp
        (go-p t))
    (while go-p
      (setq regexp (regexp-quote
                    (dp-nuke-newline
                     (dp-func-on-region-or-line 
                      'buffer-substring text-only-p))))
      (when (setq go-p (eq 0 (forward-line 1)))
        (beginning-of-line)
        (delete-matching-lines (concat "^" regexp "$"))))))

(defun* dp-uniq-lines (&optional beg end text-only-p (sort-p t))
  "Sort and remove duplicate lines from the region or rest of file."
  (interactive "P")
  (undo-boundary)
  (save-excursion
    (save-restriction
      (dp-narrow-to-region-or... :beg beg :end end)
      (dp-deactivate-mark)
      (dp-uniq-lines1 (or current-prefix-arg text-only-p)))))


(defun* dp-define-overridden-key (keymap key-seq new-def
                                  &optional 
                                  (orig-keymap dp-original-bindings-map))
  "Like `define-key' except it saves any original binding on key-seq into ORIG-KEYMAP."
  (let ((current-function (key-binding key-seq nil)))
    (when (and (fboundp new-def) 
               (not (get current-function 'dp-overridden-binding-p)))
      ;; Save original definition for this key in my original bindings map.
      (when orig-keymap
        (define-key orig-keymap key-seq current-function))
      (define-key keymap key-seq new-def)
      (put new-def 'dp-overridden-binding-p current-function))))

(defun* dp-slide-window (dir &optional (num 1) prompt-for-buffer-p)
  (dp-shift-windows-0 dir)
  (let ((start-mark (dp-mk-marker)))
    (dp-other-non-dedicated-window (if (eq dir 'right) 1 -1))
    (switch-to-buffer (other-buffer (current-buffer)))
    (dp-goto-marker start-mark)
    (setq start-mark nil)))

(defun dp-slide-window-next (arg)
  (interactive "p")
  (dp-slide-window 'right arg))
(dp-safe-alias 'dp-slide-window-right 'dp-slide-window-next)


(defun dp-slide-window-left (arg)
  (interactive "p")
  (dp-slide-window 'left arg))

(defun dp-nuniqify-list (list-sym)
  "Uniqify \"in place\" as in set the value of the symbol before returning.
NB: `list-sym' will always point to another place, so any aliases won't see
the changes. This is really just a convenience function to replace
\(setq x (dp-uniqify-list x\).  This is nice given my absurdly long variable
names.
Also return the modified list."
  (set list-sym (dp-uniqify-list (symbol-value list-sym))))

(defun dp-nuniqify-lists (symbol-list)
  "`dp-nuniqify-list' each list referred to in SYMBOL-LIST.
Return SYMBOL-LIST.  ? Would returning a list of the new list *values* be
more useful?"
  (mapc 'dp-nuniqify-list symbol-list)
  symbol-list)

(defun dp-uniqify-list (list-val)
  "Return a copy of list-val with any dupe items after the first deleted."
  (let (ulist)
    (mapc (lambda (elt)
            (unless (memq elt ulist)
              (setq ulist (cons elt ulist))))
          list-val)
    (nreverse ulist)))

(defun dp-apply-or-value (x &optional x-args)
  "If X is callable, call it with X-ARGS, else return X.
Allows a predicate to be a simple variable or a function."
  (dp-apply-if x x-args
    (if (non-nil-symbolp x)
        (and-boundp x (symbol-value x))
      x)))

(defun dp-shrink-wrap-frame (&optional frame)
  "Shrink FRAME and assumed only window to num LINES if frame is > LINES.
Assumes frame is in assumed configuration."
  (interactive)
  (setq-ifnil frame (selected-frame))
  (with-selected-frame frame
    (with-selected-window (frame-root-window)
      (with-current-buffer (current-buffer)
        (let* ((buf-lines (+ 4 (count-lines (point-min) (point-max)))))
          (when (< buf-lines (frame-width))
            (set-frame-height (selected-frame) buf-lines)))))))

(require 'dp-appt)
(when (bound-and-true-p dp-use-timeclock-p)
  (error "AHHHHHHHHHHHHHHHHH!!!!!!!!!!!!!!!!!")
  (require 'dp-timeclock))

(defun dp-add-apel-time-stamp (&optional mode &rest time-stamp-function-args)
  (when (Cu--p)
    (dp-write-this 'prompt-for-mode))
  (when (bound-and-true-p 'dp-add-time-stamp)
    (apply 'dp-add-time-stamp time-stamp-function-args)))

(defvar dp-alloc-register-base 255
  "Highest register number to allocate.")

(defvar dp-alloc-register-num 16
  "Total number to allocate.")

;; The above are only used for default initialization of free register list.

(defvar dp-alloc-register-free-list 
  (loop for r below dp-alloc-register-num
    collect (- dp-alloc-register-base r)))
  
(defun dp-register-alloc ()
  (unless dp-alloc-register-free-list
    (error "Out o registers."))
  (pop dp-alloc-register-free-list))

(defun dp-register-free (reg)
  (when (eq dp-alloc-register-free-list
            (pushnew reg dp-alloc-register-free-list))
    ;; If member is in the list `dp-alloc-register-free-list' returns the
    ;; list unchanged.  Otherwise the new member is cons'd onto the front of
    ;; the list which will always return a different value.
    (error "Double free in dp-free-register."))
  dp-alloc-register-free-list)


(defun dp-vec-to-list (vec)
  "I'm sure I've missed a standard function to do this."
  (loop for v across vec
    collect v))

(defun dp-indent-region-as-if-by-hand (&optional beg end)
  "Indent region doesn't work in all cases where manual indentation of all lines does.
I think this is different than `dp-indent-region-line-by-line', at least
because the indentation region need not begin at the bol."
  (let* ((beg-end (dp-region-or... :beg beg :beg end))
         (beg (car beg-end))
         (end (cdr beg-end)))
    (save-excursion
      (goto-char beg)
      (while (< (point) end)
        (dp-indent-line-and-move-down)))))

(defun dp-preceding-symbol-end (&optional pos)
  (save-excursion
    (when pos
      (goto-char pos))
    (while (not (memq (char-syntax (char-before)) '(?w ?_)))
      (forward-char -1))
    (when (char-before)
      (forward-char -1)
      (point))))

(defun dp-upcase-preceding-symbol (&optional start)
  "@todo -- upcase region if active."
  (interactive)
  (save-excursion
    (when start (goto-char start))
    (let ((p (dp-preceding-symbol-end)))
      (when p
        (goto-char p)
        (let ((beg-end (id-select-symbol (point))))
          (upcase-region (car beg-end) (cdr beg-end))
          (point))))))

(defun dp-upcase-preceding-symbols (&optional num)
  (interactive "p")
  (save-excursion
    (let ((p (point)))
      (loop for n from 1 to num
        while p do
        (setq p (dp-upcase-preceding-symbol p))))))

(defun dp-mk-periodic-list (num from by &optional skip-zeroth-p)
  "Small, eh?  Requiring `progn' is failure."
  (let* ((first (if skip-zeroth-p 1 0))
        (last (1- (+ first num))))
    (loop for off from first to last
      collect (+ from (* off by)))))

(defun dp-trunc-stack-push (stack el &optional max)
  (trunc-stack-push stack el)
  (when (and max (> (trunc-stack-length stack) max))
    (trunc-stack-truncate stack (- (trunc-stack-length stack) max))))

(defun portage-man ()
  (interactive)
  (w3m (car (file-expand-wildcards "/usr/share/doc/portage*/html/index.html"))))

(dp-deflocal-permanent dp-save-inhibited-p nil
  "For buffers we don't want to save, such as *scratch*.")

(defun* dp-save-inhibited-p (&optional (buffer (current-buffer)))
  (buffer-local-value 'dp-save-inhibited-p buffer))

(dp-deflocal-permanent dp-save-buffer-save-p nil
  "Act like `save-buffer' mod `dp-save-inhibited'")

(dp-deflocal-permanent dp-save-buffer-really-save-every-nth 10
  "Really save after N calls without a real save in between.")

(dp-deflocal dp-num-save-buffer-cmds-since-last-real-save 0
  "N calls since last real save.")

;;
;;!<@todo Add regexps for auto exclusion and forced saving.
;;

(dp-deflocal-permanent dp-save-buffer-auto-NOT-p nil
  "Don't do the auto-save phase.  !<@todo Should we not keep last-command set
to `dp-save-buffer'?  This will result in this command doing nothing except
when explicitly requested \(see 1st conditional\) since last-command will
never eq this command.")

(defun dp-save-buffer (&optional args)
  (interactive "_p")
  ;; `save-buffer' uses prefix arg, so call it with `current-prefix-arg' so
  ;; it can do the special actions requested.
  ;; Buffer local override.
  (if (or current-prefix-arg
          (>= (1+ dp-num-save-buffer-cmds-since-last-real-save) 
              dp-save-buffer-really-save-every-nth)
          dp-save-buffer-save-p
          ;; >= 2nd consecutive save.
          (eq last-command this-command))
      ;; User wants to save this buffer.
      (unless (dp-you-cant-save-you-silly)
        ;; Do a real write
        (call-interactively 'save-buffer)
        (setq dp-num-save-buffer-cmds-since-last-real-save 0)
        ;; And pretend we were called that way.
        (dmessage "Really saved this buffer.")
        (setq this-command 'save-buffer))
      ;; Nothing special, just one of my all-too-often saves.  Call the
      ;; autosave function, which will autosave *all* buffers, humoring my
      ;; paranoia even more. 2 in a row will really save the buffer.  Contrary
      ;; to my earlier belief, saving a lot does not churn through the bumbered
      ;; backups since the file is backed up only after the first save.  See if
      ;; I like this.  An alternative is to save the current buffer but still
      ;; autosave all else.
      ;; This may have strange effects on undo.
      ;; Buffer local override.
    (unless (bound-and-true-p dp-save-buffer-auto-NOT-p)
      (do-auto-save)
      (incf dp-num-save-buffer-cmds-since-last-real-save)
      (dmessage "auto-saved all buffers. Real save after %s more."
                (- dp-save-buffer-really-save-every-nth 
                       dp-num-save-buffer-cmds-since-last-real-save)))))

(defvar dp-rename-def*-replace-command-history '()
  "Keep a list of `replace-*' commands that could be used to fix up other
  occurrances of the renamed def."
)
(defun* dp-rename-def* (&optional skip-sarah-p new-name edebug-it-p pos
                        cocky-p
                        eval-it-p
                        force-replace-command-p
                        (allow-replace-command-p t)
                        (vars-too-p t))
  "Rename the defun name at POS \(default \(point)) to NEW-NAME.
The main thing here is to `fmakunbound' the original name.  This causes
functions using the old name to fail ASAP, which helps prevent a disaster at
the next session."
  (interactive "P")
  (let* ((beg-end (dp-cons-to-list (id-select-symbol (or pos (point)))))
         (old-name (apply 'buffer-substring beg-end))
         (old-name-sym (intern-soft old-name))
         replace-cmd
         (defined-as (and old-name-sym
                          (list (and (fboundp old-name-sym) 'function)
                                (and (boundp old-name-sym) 'variable))))
         (undefined-msg (if defined-as
                            ""
                          (format "`%s' is undefined: " old-name)))
         ask-about-replace-p)
    (setq-ifnil new-name
                (completing-read (format "%sNew def name: " undefined-msg)
                                 nil nil nil old-name nil old-name))
    (when (fboundp old-name-sym)
      (fmakunbound old-name-sym))
    (when (and vars-too-p
               old-name-sym
               (boundp old-name-sym))
      (makunbound old-name-sym))
    (apply 'delete-region beg-end)
    (goto-char (car beg-end))
    (insert new-name)
    (cond
     ;; Just do it (tm)
     ((Cu0p skip-sarah-p)
      (setq eval-it-p t
            allow-replace-command-p nil
            ask-about-replace-p nil))
     ((Cu--p skip-sarah-p)
      (setq allow-replace-command-p t
            force-replace-command-p t
            eval-it-p t
            ask-about-replace-p nil))
     (t (setq ask-about-replace-p t)))
    (setq created-replace-cmd
          (when allow-replace-command-p
            (format "(progn (dp-push-go-back \"renamed def\") (%s \"%s\" \"%s\"))"
                    (if cocky-p "replace-string" "query-replace")
                    old-name new-name)))
    (kill-new old-name)
    (when (or eval-it-p
              (y-or-n-p (format "%sEval new definition? " undefined-msg)))
      (eval-defun edebug-it-p))
    (if (or (and created-replace-cmd
                 force-replace-command-p)
            (and ask-about-replace-p
                 created-replace-cmd
                 (y-or-n-p (format
                            "Put a replace command for `%s' on kill ring?"
                            created-replace-cmd))))
        (kill-new created-replace-cmd)
      (setq created-replace-cmd nil))
    (if created-replace-cmd
        (message
         "I put a `%s' on kill ring (\"for ya. <cute>Wink</cute\" --SP)."
         created-replace-cmd)
      (message "Done."))))

(defvar dp-default-co-tag ""
  "What we stick, by default, in a comment added by `co'.
Use \\[dp-comment-out-with-tag] to specify a tag string.")

(defun dp-build-co-comment-start (&optional tag start end
                                  read-as-last-resort-p
                                  recursing)
  (setq-ifnil tag dp-default-co-tag
              start comment-start
              end comment-end)
  (cond
   ((or (not tag) (string= tag ""))
    start)
   ;; !<@todo XXX why did I force this clause to always be used?
   ((or t (not end) (string= end ""))
    ;; Why? Trying to make sure the comments can't be indented?
    ;; Or to force them to match the indentation upon indenting.
    ;; Good for languages like Python.
    ;; e.g. ; --> ;C;, ;; --> ;;C;,
    (string-match "^\\(.*?\\)\\(\\s-*\\)$" start)
    (concat (match-string 1 start) tag (substring start 0 1) 
            (or (match-string 2 start) "")))
    (read-as-last-resort-p 
     (read-from-minibuffer "Comment start: " (format "#%s# " tag)))))

(defun dp-canonicalize-pathname (name)
  (expand-file-name (substitute-in-file-name name)))

(defun dp-mk-pathname (&rest components)
  ;; Handle case where a list is passed in.
  (expand-file-name (paths-construct-path (or (and-listp (car components))
                                              components))))

(defun* dp-save-buffer-contents (&key
                                 file-name
                                 (start (point-min))
                                 (end (point-max))
                                 (file-name-sticky-p t)
                                 (confirm-save-p 'ask)
                                 (dir dp-default-save-buffer-contents-dir) 
                                 (name-transformer 'dp-shellify-shell-name)
                                 (append-p t)
                                 (transformer-args '())
                                 &allow-other-keys)
  "Useful when called from a `kill-buffer-hook' for buffers with no associated file, esp shell buffers."
  (setq dir (dp-canonicalize-pathname dir))
  (make-directory dir t)
  (let ((file-name (or file-name
                       (expand-file-name
                        ;; A / is required after the dir name the way I'm
                        ;; calling this.
                        (append-expand-filename
                         dir
                         (apply name-transformer (buffer-name)
                                transformer-args))))))
    (if (not file-name)
        (error 'invalid-argument "buffer name not transformed.")
      (when (or (not (memq confirm-save-p '(ask ask-p t)))
                (not (file-exists-p file-name))
                append-p                ; Nothing will be lost
                (y-or-n-p (format "File exists: name>%s<. Overwrite? " 
                                  file-name)))
        (setq file-name (expand-file-name (read-file-name "Save to: "
                                                          ""
                                                          file-name
                                                          nil
                                                          file-name)))
        (write-region start end file-name append-p))
      (when file-name-sticky-p
        (setq dp-save-buffer-contents-file-name file-name)))))

(defun* dp-in-completion-list-p (list target &optional pred)
  (setq-ifnil pred 'equal)
  (loop for el in list do
    (funcall pred (car el) target)
    (return-from dp-in-completion-list-p el)))

(defun dp-oprofile-doc (&optional file-name)
  (interactive)
  (setq-ifnil file-name "/usr/share/doc/oprofile/oprofile.html")
  (w3m "/usr/share/doc/oprofile/oprofile.html"))
(defalias 'opdoc 'dp-oprofile-doc)
(defalias 'odoc 'dp-oprofile-doc)

(defun dp-other-window-up (arg)
  "Other window, up."
  (interactive "p")
  (other-window (- arg)))

(defun dp-not-empty-p (obj)
  (cond
   ((and (stringp obj)
         (equal obj ""))
    nil)
   ((and (arrayp obj)
         (equal obj []))
    nil)
   (nil nil)                            ; duh.
   (t t)))

(defvar dp-find-function-after-hook-hist-map 
  '(("^def" . variable-history)
    (".*" . minibuffer-history))
  "Map the `find-function-do-it' type to a history variable.
`find-function' and `find-variable' simply use `minibuffer-history'.")

(defun dp-find-function-after-hook ()
  "Save symbol name into appropos history."
  ;; Dynamic scoping has advantages if you choose to explore the dark side.
  ;; From here I can see the args to `find-function-do-it',
  ;; symbol, type and switch-fn
  (let* ((symbol (bound-and-true-p symbol))
         (type (bound-and-true-p type))
         (switch-fn (bound-and-true-p switch-fn))
         (hist-list (and type 
                         (cdr-safe (dp-assoc-regexp 
                                    type 
                                    dp-find-function-after-hook-hist-map)))))
    (dp-add-to-history
     (or hist-list 'minibuffer-history)
     symbol
     :pred (lambda (hist-sym string &rest r)
             (dp-not-empty-p string)))))

(add-hook 'find-function-after-hook 'dp-find-function-after-hook)

(defun dp-find-function-on-key (&optional key)
  (interactive)
  (dp-push-go-back&call-interactively 'find-function-on-key nil nil 
                                      "find-function-on-key"))
  
(defun dp-fill-paragraph-or-region-with-no-prefix ()
  (interactive)
  (let ((fill-prefix nil))
    (call-interactively 'fill-paragraph-or-region)))

(defun dp-kill-ring-save-variable-value (var-name)
  (interactive (list
                (dp-prompt-with-symbol-near-point-as-default 
                 "Variable name:" :hist-sym 'variable-history)))
  (let ((sym (intern-soft var-name)))
     (if sym
         (let ((val (symbol-value sym)))
           (kill-new (format "%s" val))
           (message "%s: %s" var-name val))
       (message "%s is void." var-name))))

(defun dp-read-file-as-string (file-name)
  "Return contents of FILE-NAME as a string."
  (dp-with-all-output-to-string
   (insert-file file-name)))

(defun dp-fmakunbound (&optional function-name)
  (interactive (list (dp-prompt-with-symbol-near-point-as-default 
                      "Victim function:" :symbol-type 'a)))
  (fmakunbound function-name))

(defun dp-makunbound (&optional var-name)
  (interactive (list (dp-prompt-with-symbol-near-point-as-default 
                      "Victim variable:" :symbol-type 'S)))
  (makunbound var-name))

(defun* dp-buffer-local-setq (var-sym new-val 
                              &optional (pred 
                                         (lambda (vsym new-val)
                                           (not (equal (symbol-value vsym) 
                                                       new-val))))
                              (new-default nil new-default-set-p))
  "Make VAR-SYM buffer local if pred is non-nil and either t or a function returing non-nil.
PRED, if non-nil and not t, takes two arguments: VAR-SYM and NEW-VAL.
Eitherwise set var-sym's value to new-val.
If new-default is passed (as predicated by NEW-DEFAULT-SET-P being non-nil)
set VAR-SYM's default value to NEW-DEFAULT."
  (when (and pred (or (eq pred t)
                      (funcall pred var-sym new-val)))
    (make-variable-buffer-local var-sym)
    (set var-sym new-val)
    (when new-default-set-p
      (set-default var-sym new-default-set-p)))
  new-val)

(defun dp-file-readable-p (file-name)
  (and file-name (file-readable-p file-name)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun dp-listify-thing (thing)
  "Ensure THING is a list (or nil) if it isn't one ALREADY.
e.g. \"a\" --> '(\"a\")
     '(a b) --> '(a b)"
  (when thing
    (cond
     ((listp thing) thing)
     ((consp thing) (list (car thing) (cdr thing)))
     ((atom thing) (list thing))
     (t nil))))

(defun dp-listify-things (&rest things)
  "Apply `dp-listify-thing' to each member of THINGS, removing all top-level nils."
  ;;(princf "things>%s<" things)
  (delq nil (mapcar 'dp-listify-thing things)))

(defun dp-match-a-regexp (string &rest regexp-list)
  "Each element of REGEXP-LIST can be an atom or nil or a list of regexp atoms."
  (loop for regexps in (apply 'dp-listify-things regexp-list)
    thereis (loop for regexp in regexps
              ;; do (princf "regexp>%s<, filename>%s<" regexp string)
              thereis (string-match regexp string))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun* dp-file-name-implies-readonly-p (filename 
                                         &optional regexp-in 
                                         (mode-local-list-p t))
  "Call this from a mode hook to make sure that FILENAME is known to match the mode regexp."
  (and (dp-match-a-regexp filename 
                          (and mode-local-list-p
                               (dp-mode-local-value 
                                'dp-implied-read-only-filename-regexp))
                          regexp-in)
       (< 0 (length (match-string 0 filename)))))

(defun dp-local-set-keys (key-func-list)
  "Do a bunch of `local-set-key' ops @ once.
KEY-FUNC-LIST looks like \(key def key def...\)."
  (loop for (key def) on key-func-list by 'cddr do
    (local-set-key key def)))

(defun dp-call-pred-or-pred (pred &rest pred-args)
  (if (functionp pred)
      (apply pred pred-args)
    pred))

(defun dp-quit-other-window (arg)
  (interactive "p")
  (save-window-excursion
    (other-window arg)
    (dp-fake-key-presses ?q)))

(defun* dp-path-len (dels &optional (delimitter "/") (omit-nulls t))
  (length (split-string dels delimitter omit-nulls)))

(defun dp-longest-delimited-string-len (list-o-strings)
  ;; Dir names must be Absolut.
  (or (loop for dels in list-o-strings
        maximize (dp-path-len dels))
      -1))

(defun dp-index-of-max (seq)
  (let ((max -11)
        (i-of-max -1)
        (i 0))
    (loop for x in seq
      if (> x max) do (setq i-of-max i
                            max x)
      do (incf i))
    i-of-max))


(defun dp-edit-current-mailer-config ()
  (interactive)
  (find-file dp-current-mailer-config-file)
  (when (string= dp-current-mailer-config-file dp-generic-mail-code)
    (re-search-forward "dp-current-mailer-config-file")
    (dp-ding-and-message 
     "Set your mailer's config file name and re-run %s." this-command)))
(dp-safe-alias 'emc 'dp-edit-current-mailer-config)

(defun* dp-completing-read (prompt table 
                            &key predicate require-match initial-contents 
                            history default (dp-match-ret-fun 'dp-identify)
                            (dp-no-match-ret-fun 'dp-identify))
  "Extend `completing-read' to give us access to all info in the completion list.
Return cons: (completion-assoc-from-completion-list . t)
or (raw-return-from-completing-read-if-not-in-completion-list . nil)"
  (let* ((ret0 (completing-read prompt table predicate require-match 
                                initial-contents history default))
         (table-item (and table (assoc ret0 table))))
    (if (and table-item
             (cdr table-item))
        (funcall dp-match-ret-fun (cons table-item t))
      (funcall dp-no-match-ret-fun (cons ret0 nil)))))

(defvar dp-show-indentation-last-arg 'no-arg
  "Previous arg given to `dp-show-indentation-last-arg'.
By remembering this, consecutive invocations can replace the front item on
the kill ring rather than adding many number to the ring.
'no-arg cannot be passed via the prefix arg mechanism.
")

(defvar dp-show-indentation-last-kill-cmd nil
  "Last command which killed something.")

(add-hook 'kill-hooks (lambda (&rest r)
                        (setq dp-show-indentation-last-kill-cmd this-command)
;;CO;                         (dmessage "dp-show-indentation-last-kill-cmd: %s" 
;;CO;                                   dp-show-indentation-last-kill-cmd)
                        ))

(defun dp-show-indentation (&optional select-p)
  (interactive "P")
  (let* ((indentation (current-indentation))
         (repeated-kill-command (eq dp-show-indentation-last-kill-cmd
                                    this-command))
         (dummy (setq dp-show-indentation-last-arg (if repeated-kill-command
                                                       select-p
                                                     'no-arg)))
         (repeated-arg (eq select-p dp-show-indentation-last-arg))
         (exact-repeated-command (and repeated-kill-command repeated-arg))
         (suffix "."))
    (when (cond
           ((Cu--p select-p)            ; To kill ring, unconditionally.
            (kill-new (format "%s" indentation))
            (setq suffix "; kill-new'd.")
            t)                          ; Show indentation
           ((Cu0p select-p)             ; Kill to front iff exactly repeated.
            (kill-new (format "%s" indentation) exact-repeated-command)
            (setq suffix (format"; kill'd(%s)." 
                                (if exact-repeated-command
                                    "replace"
                                  "new")))
            t)                          ; Show indentation
           (select-p
            (dp-mark-region-or... :bounder 'indentation-p)
            (setq suffix "; marked.")

            t)
           (t t))
      (message "Indentation col: %s%s" indentation suffix))))

(defvar dp-sp-extra-dirs (concat (or (bound-and-true-p dp-work-dirs) "")
                                 (or (getenv "DP_WORK_DIRS") ""))
  "Other dirs, in addition to $PATH in which sp should look to find files.")

(defun dp-filter-dirs-by-file (dirs file &optional root)
  "Return the subset of DIRS which contain a readable FILE."
  (loop for dir in dirs
    when (file-readable-p (paths-construct-path (list dir file) root))
    collect (paths-construct-path (list dir) root)))

(defun dp-search-path (file-name &optional other-window-p)
  "Use my sp utility to find FILE-NAME in the PATH.
@todo: ?? Make a `dp-find-file' function that tries a normal
find-file\(-at-point) and then, if it fails, this function??"
  ;;; trying the following instead; (interactive "sFile name for sp: \nP")
  (interactive (list
                (dp-prompt-with-symbol-near-point-as-default "File name for sp")
                current-prefix-arg))
  (let ((output (shell-command-to-string (format "sp -1 %s" file-name))))
    (if (string= output "")
        ;; Wasn't found, just try to edit it normally.
        (call-interactively (if other-window-p
                                'ffap-other-window
                              'find-file-at-point))
      (setq file-name (substring output 0 -1))
      (funcall (if other-window-p 'find-file-other-window 'find-file)
               file-name)
      (message "found: %s" file-name))))
(dp-safe-alias 'sp 'dp-search-path)

(defsubst dp-search-path-other-window (&optional file-name)
  "Do `dp-search-path' in `other-window'."
  (interactive)
  (let ((current-prefix-arg (not current-prefix-arg)))
    (call-interactively 'dp-search-path)))
(dp-safe-alias 'sp2 'dp-search-path-other-window)

(defun dp-tidy-ego (dest-col)
  (interactive (list
                ;; DEST-COL
                (cond 
                 ((Cu--p)
                  (read-number "dest col: "))
                 ((dp-region-active-p)
                  'compute)
                (t (read-number "dest col: ")))))
  (dp-mark-line-if-no-mark)
  (let ((compute-dest-col-p (eq dest-col 'compute))
        beg-end num-repeats)
    (setq beg-end (dp-region-boundaries-ordered)
          num-repeats (- (line-number-at-pos (cdr beg-end))
                         (line-number-at-pos (car beg-end))))
    (when (eq 0 num-repeats)
      ;; One line marked within the line, e.g. 
      ;; (line-beginning-position)... (line-end-position)
      (setq num-repeats 1))
    (goto-char (car beg-end))
    (when compute-dest-col-p
      (goto-char (car beg-end))
      (setq dest-col
            (save-excursion
              (loop repeat num-repeats
                maximize (progn
                           (beginning-of-line)
                           (search-forward "| ")
                           (fixup-whitespace)
                           (delete-char)
                           (tab-to-tab-stop)
                           (tab-to-tab-stop)
                           (prog1 
                               (current-column)
                             (forward-line)))))))
    (loop repeat num-repeats do
      (beginning-of-line)
      (search-forward "| ")
      (fixup-whitespace)
      (insert (make-string (1- (- dest-col (current-column))) ? ))
      (forward-line))))

(defun dp-get-buffer (buffer-or-name &optional else-nil-p)
  "Like `get-buffer' except BUFFER-OR-NAME, if nil returns `current-buffer'."
  (if buffer-or-name
      (get-buffer buffer-or-name)
    (if else-nil-p
        nil
      (current-buffer))))

(defun dp-file-in-dirs-and (dirs &optional buffer file-name is-glob-p
                            &rest preds)
  (setq-ifnil is-glob-p (or is-glob-p
                            (and dirs
                                 (not (listp dirs))
                                 (setq dirs (list dirs)))))
      (when (and (setq buffer (if buffer
                                  (get-buffer buffer)
                                (current-buffer)))
                 (setq file-name (if file-name
                                     (file-truename file-name)
                                   (compute-buffer-file-truename buffer))))
        (when (loop for dir in dirs
                thereis (if is-glob-p   ; In this case len dirs == 1.
                            (string-match dir file-name)
                          (string-match (concat "^" (file-truename dir))
                                        file-name)))
          (if (not preds)
              t
            (loop for pred in preds
              thereis (or (and (functionp pred) 
                               (apply pred dirs))
                          (and (symbolp pred) pred)))))))

(defun dp-buffer-menu-mark-for-kill-matching-buffers (regexp 
                                                      &optional kill-immed-p)
  "Skips modified buffers."
  (interactive "sRegexp: \nP")
  ;; ^\.??[ %]+?.*?ice.*? \{2\}
  (setq regexp (concat "^\\.??[ %]+? .*?" regexp ".*? \\{2\\}"))
  (beginning-of-line)
  (let ((n-matches 0))
    (while (re-search-forward regexp nil t)
      (Buffer-menu-delete)
      (incf n-matches))
    (when kill-immed-p
      (Buffer-menu-execute))
    (message "%d buffer%s %sed." n-matches
             (if (= n-matches 1) "" "s")
             (if kill-immed-p "kill" "mark"))))

(defun dp-verbose-require (feature &optional filename noerror)
  (let ((msg (format "requir%%s %s%s%s%s.%%s"
                     feature
                     (if filename
                         (concat " from filename: " filename)
                       "")
                     (if noerror
                         (format " with noerror: %s" noerror)
                       "")
                     (if (featurep feature)
                         ". NB: It Is Already Provided"
                       ""))))
    (message msg "ing" "..")
    (require feature filename noerror)
    (message msg "ed " "")))

(defun dp-map-prefix (fix things &optional join-p join-string)
  (let ((ret (delq nil (mapcar (dp-flambda (string)
                                 ;; `format' lets things be anything.
                                 (format "%s%s" fix string))
                               things))))
    (if join-p
        (dp-string-join ret join-string)
      ret)))
(defun dp-map-suffix (fix things &optional join-p join-string)
  (let ((ret (delq nil (mapcar (dp-flambda (string)
                                 ;; `format' lets things be anything.
                                 (format "%s%s" string fix))
                               things))))
    (if join-p
        (dp-string-join ret join-string)
      ret)))

(defun dp-n-windows-p (num &optional frame minibuf window)
  (= num (length (window-list frame minibuf window))))

(defun dp-switch-to-buffer-other-window-if->1-windows-showing (buffer)
  (interactive "bBuffer: ")
  (if (dp-n-windows-p 1)
      (switch-to-buffer buffer)
    (switch-to-buffer-other-window buffer)))

(defun dp-work-file-name-p-in-a-work-type-dir (&optional dirs buffer 
                                               file-name is-glob-p
                                               &rest preds)
  (dp-file-in-dirs-and (or dirs "/work-??.*?/\\|/devel/\\/dev[^/]\\|play")
                       buffer
                       file-name))

;; hyperbole/oobrowser locations and vars
(defvar dp-oo-browser-dir (dp-mk-site-package-lisp-dir "oo-browser")
  "oo-browser's home.")

(defun dp-setup-ootags ()
  "Set up ootags source browsing system."
  (interactive)
  (add-to-list 'load-path dp-oo-browser-dir) 
  ;;;(add-to-list 'load-path (concat dp-oo-browser-dir "/hypb"))
  (load "br-start")
  (global-set-key "\C-c\C-o" 'oo-browser))

(defvar dp-cxfer-separator "================="
  "Just so happened.")

(defun cxfer (&optional add-new-p timestamp-p)
  (interactive "P")
  (dp-push-go-back "cxfer")
  (dp-find-file (expand-file-name "cx-xfer.txt" "~"))
  (dp-define-buffer-local-keys '([(meta ?-)] dp-bury-or-kill-buffer))
  (setq-ifnil timestamp-p (Cup> 1))
  (if (not dp-cxfer-separator)
      (goto-char (point-max))
    (goto-char (point-min))
    (search-forward dp-cxfer-separator)
    (beginning-of-line)
    (when add-new-p
      (previous-line 1)
      (end-of-line)
      (newline)
      (insert dp-cxfer-separator)
      (newline))
    (when timestamp-p
      (unless (bolp)
        (dp-open-newline))
      (newline)
      (dp-open-above t)
      (dp-timestamp))))




                                        ; does it work in lisp? does the
                                        ; newly added filling via the binding
                                        ; on meta ?q work? We hopes so.
(defun dp-move-too-long-comment-above-current-line ()
  (interactive)
  (beginning-of-line)
  (indent-for-comment)
  (backward-char (length comment-start))
  (kill-line)
  (dp-cleanup-line)
  (dp-open-above t)
  (dp-yank)
  (beginning-of-line)
  ;; !<@todo XXX put @ column of line it was taken from before
  ;; `indent-for-comment'
  ;; at this time: 2012-02-24T09:04:54 WTF was I thinking up there?
  (insert " ")       ; Needed for some modes. Does the wrong thing in others.
  (indent-for-comment)
  (dp-call-function-on-key [(meta ?q)]))

(defalias 'mtlcu 'dp-move-too-long-comment-above-current-line)

(defun* dp-jobs-annotate-dice-listing (text &optional (prefix "** ")
                                       (suffix " ** ")
                                       (next-item-search-regexp "http://seeker"))
  (interactive "stext: ")
  (beginning-of-line)
  (insert prefix text suffix)
  (when next-item-search-regexp
    (end-of-line)
    (if (re-search-forward next-item-search-regexp nil t)
        ()
      (dp-ding-and-message "No more >%s< items." next-item-search-regexp))))

(defun dp-jobs-adl-applied-for ()
  (interactive)
  (dp-jobs-annotate-dice-listing "APPLIED FOR"))
(dp-safe-alias 'Jaf 'dp-jobs-adl-applied-for)
(dp-safe-alias 'jaf 'dp-jobs-adl-applied-for)

(defun dp-jobs-adl-mismatch ()
  (interactive)
  (dp-jobs-annotate-dice-listing "MISMATCH"))
(dp-safe-alias 'Jm 'dp-jobs-adl-mismatch)

(defun dp-jobs-adl-removed ()
  (interactive)
  (dp-jobs-annotate-dice-listing "REMOVED FROM LISTINGS"))
(dp-safe-alias 'Jrm 'dp-jobs-adl-removed)

(defun* dp-number-lines-region (beg end &optional (start-num 1)
                                (width nil)
                                (open "[") (close "] "))
  (interactive "r\np")
  ;; Nuke existing numbers
  (let* (;; End needs must be a marker since we are inserting text.
         (end (dp-mk-marker end))
         (num-lines (count-lines beg end))
         (width (or width (length (concat open 
                                          (int-to-string 
                                           (+ start-num num-lines))
                                          close))))
         new-num new-len new-fill new-fill-len)
    ;;(dmessage "beg: %s, end: %s, start-num: %s, regexp: %s"
    ;;          beg end start-num regexp)
    (goto-char beg)
    (while (< (point) end)
      (setq new-num (concat open (int-to-string start-num) close)
            new-len (length new-num)
            new-fill-len (- width new-len)
            new-fill (if (>= 0 new-fill-len) "" (make-string new-fill-len ? )))
      (beginning-of-line)
      (insert (concat new-num new-fill))
      (forward-line 1)
      (incf start-num))))

(defun* dp-renumber-bracketed-list (beg end &optional (start-num 1)
                                    (width nil)
                                    (open "[") (close "]"))
  (interactive "r\np")
  ;; Nuke existing numbers
  (let* ((regexp (concat (regexp-quote open) "[^]]*" (regexp-quote close)))
         ;; End needs must be a marker since we are inserting text.
         (end (dp-mk-marker end))
         (num-lines (count-lines beg end))
         (width (or width (length (concat open 
                                          (int-to-string 
                                           (+ start-num num-lines))
                                          close))))
         new-num new-len new-fill new-fill-len)
    ;;(dmessage "beg: %s, end: %s, start-num: %s, regexp: %s"
    ;;          beg end start-num regexp)
    (goto-char beg)
    (while (re-search-forward regexp end t)
      (setq new-num (concat open (int-to-string start-num) close)
            new-len (length new-num)
            new-fill-len (- width new-len)
            new-fill (if (>= 0 new-fill-len) "" (make-string new-fill-len ? )))
      (replace-match (concat new-num new-fill))
      (incf start-num))))

(defun* dp-in-work-dir-p (file-name &optional (regex "/work/"))
  "Trivial function to determine if we are in a work directory."
  (string-match regex file-name))

(defun dp-path-filter (path pred)
  (delq nil
        (mapcar (lambda (p)
                  (when (funcall pred p)
                    p))
                path)))

(defun dp-path-filter:existing (path)
  (dp-path-filter path 'file-exists-p))

;;; copped from (defun flyspell-minibuffer-p (buffer)
(defun dp-minibuffer-p (&optional buffer)
  "Is BUFFER a minibuffer?"
  (let ((ws (get-buffer-window-list (dp-get-buffer buffer) t)))
    (and (consp ws) (window-minibuffer-p (car ws)))))

(defun dp-set-indent/tab-style0 ()
  ;; tab stuff: just use spaces, make 'em small
  (make-variable-buffer-local 'tab-stop-list)
  (setq indent-tabs-mode nil
	tab-width 2
	tab-stop-list (loop for i from 2 to 120 by 2
			collect i))
  ;; set up mode specific indentation function
  (make-local-variable 'indent-line-function)
  (setq indent-line-function 'indent-relative))

(defun dp-save-wconfig-by-name-or-ring (&optional arg)
  "Save by name if C--, else ring-save."
  (interactive "p")
  (call-interactively
   (if (Cu--p)
       'wconfig-add-by-name
     'wconfig-ring-save)))

(defun dp-delimit-embedded-block (&optional limit-text skip-n-lines)
  (interactive)
  (setq-ifnil limit-text "ebo-block-end")
  (save-excursion
    (when skip-n-lines
      (beginning-of-line)
      (next-line skip-n-lines))
    (let ((block-start (line-beginning-position))
          (block-end (save-excursion
                       (end-of-line)
                       (if (not (re-search-forward limit-text nil t))
                           (error (format "Cannot find end of block>%s<."
                                          limit-text))
                         ;;(beginning-of-line)  ; Include newline?
                         ;;(next-line 1)
                         (end-of-line)  ; Just to end of last line in block.
                         (point)))))
      (dp-order-cons (cons block-start block-end)))))

(defun dp-delimit-embedded-block-backwards (&optional limit-text)
  (interactive)
  (setq-ifnil limit-text "block begin")
  (let ((block-start (line-end-position))
        (block-end (save-excursion
                     (beginning-of-line)
                     (if (not (re-search-backward limit-text nil t))
                         (error (format "Cannot find beginning of block>%s<."
                                        limit-text))
                       (beginning-of-line)
                       (point)))))
    (dp-order-cons (cons block-start block-end))))

(defun dp-embedded-block-op (op &optional limit-text skip-n-lines)
  (interactive)
  (let ((beg-end (dp-delimit-embedded-block limit-text skip-n-lines)))
    (funcall op (car beg-end) (cdr beg-end))))
(dp-defaliases 'dp-ebo 'dpebo 'ebo 'embo 'dp-embedded-block-op)

(defun dp-set-file-group ()
  "Set a file's group id. Something to tie buffers together in some way.
Eg: per project, major mode, location, name...
Anything that would make selecting the \"next\" buffer more convenient."
  (interactive)
  )

(defun dp-switch-to-next-buffer ()
  "Pick a next buffer in some way. It should always be the one I want. 
No matter what. A DWIM-ish thing."
  (interactive)
  ;; For now, combine switch-to-next-buffer[-in-group]?
  ;; Next in group, next.
  (if (eq current-prefix-arg '-)
      (switch-to-next-buffer 1)
    (call-interactively 'switch-to-next-buffer-in-group)))

(defun dp-switch-to-previous-buffer ()
  "Pick a previous buffer in some way. It should always be the one I want. 
No matter what. A DWIM-ish thing."
  (interactive)
  ;; For now, combine switch-to-next-buffer[-in-group]?
  ;; Next in group, next.
  (if (eq current-prefix-arg '-)
      (switch-to-next-buffer -1)
    (call-interactively 'switch-to-next-buffer-in-group)))

(defun dp-add-to-auto-mode-alist (extension mode &optional add-transparent-p)
  (add-to-list 'auto-mode-alist 
               (cons (if add-transparent-p
                         (dp-mk-mode-transparent-regexp extension)
                       extension)
                     mode)))

(defvar dp-ssh-home-node "VILYA")

(defun ssh-home ()
  "Ssh to my current home address. 
IP address is kept in environment var named by `dp-ssh-home-node'."
  (interactive)
  (let ((ip-addr (getenv dp-ssh-home-node)))
    (ssh ip-addr (format "ssh-home: %s[%s]" dp-ssh-home-node ip-addr))))

(defun dp-maybe-set-window-point (&optional buffer pos)
  "Do `set-window-point' iff BUFFER, `current-buffer' if nil, has a window."
  (let ((w (dp-get-buffer-window buffer)))
    (when w
      (set-window-point w (or pos (point))))))

;;  (interactive "ssuffix: \nstype")

(defun dp-list-grep (regexp list)
  "`string-match' each element of LIST against REGEXP. Return list of matches."
  (interactive "sregexp: \nSlist: ")
  (let ((list (if (symbolp list)
                  (symbol-value list)
                list))
        matches)
    (if (not (listp list))
        (error "%s is not a list." list)
      (setq matches (delq nil
                          (mapcar (lambda (n)
                                    (if (string-match regexp n)
                                        n
                                      nil))
                                  list)))
      (if matches (message "matches: %s" matches)
        (message "No matches.")))))
  
(defun dp-file-name-history-grep (regexp &optional list)
  (interactive "sfile name regexp: ")
  (dp-list-grep regexp (or list file-name-history)))

(defun dp-pathadd (path new-el &optional append)
  (let ((pparts (if path
                    (split-string path ":")
                  nil)))
    (when append (setq pparts (nreverse pparts)))
    (funcall
     (if (listp new-el)
         'dp-add-list-to-list
       'dp-add-to-list)
     'pparts
     new-el)
    (dp-string-join (if append
                        (nreverse pparts)
                      pparts)
                    ":")))

(defun dp-lisp-dir ()
  "Find my lisp dir."
  (or user-init-directory
      (dp-mk-pathname (getenv "HOME")
                      "lisp")))

(defun dp-one-space ()
  (interactive)
  (delete-horizontal-space)
  (insert " "))

(defun dp-find-file-non-dedicated-window (&optional file-name)
  "Find FILE-NAME in this window if it is not dedicated, else another."
  (interactive)
  (let ((fun (if (dp-window-dedicated-p)
                 'dp-find-file-other-window
               'dp-find-file)))
    (if (interactive-p)
        (call-interactively fun)
      (funcall fun file-name))))

(defun dp-looking-at-whitespace-violation ()
  (car-safe
   (dp-extents-at-with-prop 'face '(blah . dp-trailing-whitespace-face))))

;; (defun dp-whitespace-next-violation ()
;;   (interactive)
;;   (let ((start (point)))
;;     (dp-goto-next-matching-extent 'face '(t . whitespace-highlight-face))
;;     (when (= start (point))
;;       (message "No more whitespace violations."))))
(defun dp-whitespace-next-violation ()
  "Replacement for whitespace package's function."
  (interactive)
  (let* ((prop-val '(blah . dp-trailing-whitespace-face))
         (ext (save-excursion
                (goto-char (line-end-position))
                (dp-looking-at-whitespace-violation))))
    (if ext
        (goto-char (extent-start-position ext))
      (dp-goto-next-matching-extent 'face prop-val))))

(defun dp-whitespace-cleanup-line ()
  "Clean up trailing whitespace on the current line. Uses my whitespace hack."
  (interactive)
  (save-excursion
    (beginning-of-line)
    (when (re-search-forward "\\s-+$" (line-end-position) t)
      (replace-match ""))))

(defun dp-whitespace-next-and-cleanup (&optional ask-per-line-p)
  (interactive "P")
  (let ((start (point)))
    (dp-whitespace-next-violation)
    (if (and (or (dp-looking-at-whitespace-violation)
                 (not (= start (point))))
             (or (not ask-per-line-p)   ; Don't even ask.
                 (or (y-or-n-p "Clean up this line?") ; Yes?
                     ;; No... goto end of line but do nothing else.
                     (and (end-of-line) nil))))
        (dp-whitespace-cleanup-line)
      (message "No more violations"))))

(defun dp-whitespace-checker ()
  (interactive)
  (beginning-of-buffer)
  (whitespace-buffer)
  (beginning-of-buffer)
  (dp-whitespace-next-violation))

(defun dp-whitespace-cleanup-line-by-line (&optional ask-per-line-p
                                           goto-beginning-of-buffer-p)
  (interactive "P")
  (dp-push-go-back "dp-whitespace-cleanup-line-by-line")
  (when goto-beginning-of-buffer-p
    (goto-char (point-min)))
  (let ((first-p t)
        (num -1)                        ; We always loop at least once.
        (last-pt nil))
    (while (or first-p
               (not (= (point) last-pt)))
      (setq first-p (dp-looking-at-whitespace-violation)
            last-pt (point))
      (incf num)
      (dp-whitespace-next-and-cleanup ask-per-line-p))
    (message "%d whitespace %s." num (dp-pluralize-num num nil "es" "fix"))))

(defun dp-whitespace-cleanup-buffer (&optional ask-per-line-p)
  (interactive "P")
  (dp-whitespace-cleanup-line-by-line ask-per-line-p t)
  (dp-pop-go-back nil :silent-p t))

(defun dp-whitespace-buffer-ask-to-cleanup (&optional line-by-line-p)
  "Check a buffer for whitespace errors. Prompt for cleanup if any are found."
  (interactive "P")
  (when (and (call-interactively 'whitespace-buffer)
             (y-or-n-p "Cleanup whitespace errors? "))
    (if line-by-line-p
        (dp-whitespace-cleanup-line-by-line)
      (whitespace-cleanup))))

(defun dp-cleanup-line ()
  "Clean up line, what ever that means. For now, it's whitespace.
Add/move other things here.
!<@todo XXX Make this just delete my trailing WS extent.
I'm trying to stop using whitespace due to massive suckage. Which may be due
to me or my other packages like flyspell which seems to be involved in the
command hook errors."
  (dp-whitespace-cleanup-line))

(defun dp-apply-function-on-key (key-seq args)
  "Apply the command currently bound to KEY-SEQ to ARGS.
See `dp-call-function-on-key'."
  (apply (key-binding key-seq) args))

(defun dp-call-function-on-key (key-seq &optional record-flag keys)
  "Run the command currently bound to KEY-SEQ interactively.
See `call-interactively' for information on RECORD-FLAG and KEYS.
Use this to run commands on keys that DTRT based on context.
E.g. in C/++ mode, M-q is bound to `dp-c-fill-paragraph' whereas in
emacs-lisp-mode, M-q is bound to M-q `fill-paragraph-or-region'."
  (call-interactively (key-binding key-seq) record-flag keys))

(defsubst dp-press-tab-key (&optional goto-bol)
  "Pretend we've pressed the tab key; its behavior varies according to mode.
There is also no standard function bound. The native bindings often mostly do
the right thing. When I personalize the behavior, I often want the original
functionality somewhere. Advice is often problematic."
  (dp-call-function-on-key [tab]))


(defun dp-call-interactively-function-on-key (key-seq)
  (call-interactively (key-binding key-seq)))

(defun* dp-concise-size-spec (&optional num)
  "Print a number concisely by using multiplier suffixes like M, K, G, etc.
Powers of 2 are used, e.g. 1024, etc.  NB: XEmacs requires numbers of the
magnitudes we are dealing with to be floating point. This means that large
numbers cannot be passed in directly without a decimal point. Large integer
values must be passed in as stings."
  (interactive (list (dp-prompt-with-symbol-near-point-as-default 
                      "number"
                      :initial-contents-p t)))
  (let ((num (* (if (not (stringp num))
                    num
                  (string-to-number
                   (if (string-match "\\.[0-9]+$" num)
                       num
                     (concat num ".0"))))
                1.0)))
    (loop for (power suffix) on 
      '(40 T 30 G 20 M 10 K) by 'cddr 
      do (let* ((factor (expt 2.0 power))
                (div (/ num factor))
                str-val)
           (when (>= div 1.0)
             (setq str-val (format "%.4f%s" div suffix))
             ;; Icky, icky, hack.
             (when (string-match "^\\(.*?\\)\\.0+\\([TGMK]?\\)$" str-val)
               (setq str-val (concat (match-string 1 str-val)
                                     (match-string 2 str-val))))
             (when (interactive-p)
               (message "%s" str-val))
           (return-from dp-concise-size-spec str-val)))))
  (when (interactive-p)
    (message "%s" num))
  num)

(defun dp-add-force-read-only-regexp (regexp)
  "Add a regexp to the list of regexps which determine if a file is read only."
  (interactive "sRegexp: ")
  (add-to-list 'dp-force-read-only-regexps regexp))

(defun dp-delete-force-read-only-regexp (regexp)
  "Delete a regexp from the list of regexps which determine if a file is read only."
  (interactive (list (completing-read 
                      "Regexp to delete: "
                      (mapcar (lambda (regexp)
                                (cons regexp "Blah"))
                              dp-force-read-only-regexps)
                      nil t)))
  (setq dp-force-read-only-regexps 
        (delete regexp dp-force-read-only-regexps)))

(defun* dp-insert-if-regexp-not-present (text regexp 
                                        &key search-from
                                        insert-at
                                        limit)
  "Insert text into a file iff regexp isn't found."
  (interactive "stext: \nsregexp: ")
  (setq-ifnil search-from (point-min)
              insert-at (point))
  (unless (dp-do-thither search-from nil
                         (re-search-forward regexp limit t))
    (goto-char insert-at)
    (insert text)))

(defun dp-insert-if-text-not-present (text1 text2 &rest rest)
  (interactive "sinsert this: \nsif no that: ")
  (message "%s" (interactive-p))
  (apply 'dp-insert-if-regexp-not-present text1 (regexp-quote text2) rest))

(defun dp-revert ()
  "Revert a buffer so that the revert hooks are always called.
This is done by marking the buffer as modified.
This is good for things like forcing recolorization of files which have
changed their writability, changing the [git] version information, etc."
  (interactive)
  (when (or (not (buffer-modified-p))
            (yes-or-no-p "Buffer is modified, revert anyway?"))
    ;; Make the buffer look modified so that revert will call its hooks.
    ;; This gives us the FILE changed on disk; really change edit the buffer?
    ;; Do I want this? I'll probably just `y' it reflexively anyway.
    (set-buffer-modified-p t)
    (revert-buffer t t)))

(defun dp-eob-all-windows ()
  "Goto the end of the buffer in all visible windows.
Clumsy but effective method."
  (interactive)
  (let ((win-num 0)
        (win-list (window-list nil 'no-minibufs-at-all)))
    (loop for win in win-list
      do
      (dp-op-other-window win-num 'end-of-buffer)
      (incf win-num))))

;; This was pulled out of `dp-c*-add-extra-faces' where it was used by
;; `dp-save-orig-n-set-new' as the function to call to add new font lock 
;; elements. It may be useful in other circumstances, hence the extraction.
(defun dp-append-to-list-symbol (save-sym &rest append-arg)
  "Append \(car APPEND-ARG) to the value of save sym.
The APPEND-ARG is a list wrapped around the real list to append."
  (interactive)
  (append (symbol-value save-sym)
          (car append-arg)))

(defun and-stringp (string &optional if-not)
  "If STRING is \(stringp), return STRING, otherwise IF-NOT"
  (if (stringp string)
      string
    if-not))

(defun dp-visit-header-doc ()
  "Visit the documentation of the following function.
Assume it's in the corresponding header file."
  (interactive)
  ;; Icky, but functional
  (dp-push-go-back "dp-visit-header-doc")
  (end-of-line)
  (search-forward "(")
  (skip-chars-backward (concat "(" dp-ws+newline))
  ;;(let ((function-name symbol-near-point))
  (dp-edit-cf-other-window t))

;;
;; Meta- is my kill-buffer key. But it is bound in a file/buffer specific
;; manner. In order to mimic the functionality of that binding within buffer,
;; I call the function bound to the key.
;; !<@todo XXX Have this call use a mode/buffer local variable which contains
;; the function which would be bound to the M-- key.

(dp-deflocal dp-kill-buffer-func (lambda ()
                                   (interactive)
                                   (call-interactively 
                                    (key-binding [(meta ?-)])))

"What should be called when the user wishes to kill a buffer?
Different functions are used depending on some context such as minor-mode.
Some examples are:
`dp-maybe-kill-this-buffer', `dp-bury-or-kill-buffer', etc.")
(defun dp-meta-minus ()
  (interactive)
  (call-interactively dp-kill-buffer-func))
  
  
(defun dp-kill-buffer-and-pop-window-config (&optional nth-config)
  (interactive "p")
  (dp-meta-minus)
  (dp-pop-window-config nth-config))

(defun dp-split-and-continue-line (&optional sep term replacement)
  "Replace regexp SEP with REPLACEMENT. Add TERM to end of original line.
Continue to end of region if active, else end of original line.
Like when you have some long var in a Makefile:
SRCS = a.c b.c d.c ...
-->
SRCS = a.c \
       b.c \
       d.c
..."
  (interactive)
  (setq-ifnil sep "\\s-+"
              term " \\"
              replacement "\n")
  (let* ((b&e (dp-region-or... :bounder 'rest-of-line-p))
         (end-marker (dp-mk-marker (cdr b&e) nil t)))
    (goto-char (car b&e))
    (dmessage "em: %s lep: %s" end-marker (line-end-position))
    (while (re-search-forward sep end-marker t)
      (dmessage "ms>%s<" (match-string 0) end-marker)
      (replace-match replacement)
      (goto-char (match-beginning 0))
      (dp-delete-to-end-of-line)
      (end-of-line)
      (dmessage "me: %s, em: %s" (match-end 0) end-marker)
      (unless (>= (match-end 0) end-marker)
        (insert term))
      (next-line 1)
      (beginning-of-line)
      (when (looking-at sep)
        (replace-match ""))
      ;; !<@todo XXX run command on TAB?
      (indent-for-tab-command))
    (undo-boundary)
    (align (car b&e) (cdr b&e))))

(defun dp-refresh-tags (&optional preserve-files-p)
  "Jump through hoops the kill the fucking tags buffers.
See `dp-shell-*TAGS-changers' rant. "
  (interactive "P")
  ;; Nuke the pesky completion buffer, which seems to be obnoxiously
  ;; permanent.
  ;;;;;;;;;;; WTF??!?!?!! all by itself(make-vector 511 0)
  (setq tag-completion-table (make-vector
                              (or (and (bound-and-true-p tag-completion-table)
                                       (length tag-completion-table))
                                  511)
                              0))
  (loop for buf in (buffer-list)
    do (when (and (buffer-file-name buf)
                  (string-match "^.?TAGS$" (file-name-nondirectory
                                            (buffer-file-name buf))))
         ;; !<@todo XXX Change this to use the new `dp-kill-buffers-by-name'
         ;; But it will need to be able to force the mod status of the buffer
         ;; to nil.
         (let ((file-name (buffer-file-name buf))
               status-msg)
           (setq status-msg (format "killing %s" buf))
           (set-buffer-modified-p nil buf)
           (kill-buffer buf)
           (unless (or preserve-files-p
                       (not file-name))
             (setq status-msg (format "%s, deleting: %s" status-msg file-name))
             (delete-file file-name))
           (message status-msg)))))

(defun dp-next-line (count)
  "Add trailing white space removal functionality."
  (interactive "_p")
  (if (not dp-cleanup-whitespace-p)
      (call-interactively 'next-line)
    (loop repeat count do
      (if (or (eq dp-cleanup-whitespace-p t)
              (eolp))
          (dp-func-and-move-down 'dp-cleanup-line
                                 t
                                 'next-line)
        (call-interactively 'next-line)))))

;;;;; <:functions: add-new-ones-above:>
;;; @todo Write a loop which advises functions with simple push go back
;;; commands.
(defadvice replace-string (before dp-replace-string activate)
  (dp-push-go-back "replace string"))
(defadvice query-replace (before dp-query-replace-string activate)
  (dp-push-go-back "query replace string"))
(defadvice replace-regexp (before dp-replace-regexp activate)
  (dp-push-go-back "replace regexp"))
(defadvice query-replace-regexp (before dp-query-replace-regexp activate)
  (dp-push-go-back "query-replace regexp"))

;;;;; <:simple defadvice definitions: add-new-ones-above:>
(require 'dp-ephemeral)

(dp-defaliases 'mkdir 'md 'make-directory)
(dp-defaliases 'rep-re 'repre 'repr 'rerep 'replace-regexp)
(dp-defaliases 'rep-str 'repstr 'str-rep 'strrep 'reps 'srep 'replace-string)
(dp-defaliases 'qrep-str 'qrepstr 'qstr-rep 'qstrrep 'qreps 'qsrep
               'rep-strq 'repstrq 'str-repq 'strrepq 'repsq 'srepq 
               'query-replace)
(dp-defaliases 'qrep-re 'qrepre 'qrepr 'qrerep
               'rep-req 'repreq 'reprq 'rerepq
               'query-replace-regexp)

;;;;; <:aliases: add-new-ones-up-there:>

(require 'dp-abbrev)
(require 'dp-bookmarks)
(when (bound-and-true-p dp-wants-cedet-et-al-p)
  (require 'dp-cedet-hacks))
(require 'dp-buffer-local-keys)
(require 'dp-time)

;;;;; <:requires unreferenced @ startup:>
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Keep this last.
;;;
;;; The hooks, etc., that I define need a lot of my functions to operate
;;; properly.  It's a major PITA to arrange things to guarantee definitions
;;; come in the right order in some of these cases.  So I just arrange for
;;; that code to run here.  The code is added to the hook nearby to the other
;;; code to which is related.
;;; Most of the things (hooks, etc) that I do are not needed during
;;; initialization, so it is much easier to just add their setup to this
;;; hook.
(add-hook 'dp-post-dpmacs-hook 'dp-win-config)

;;;
;;;
;;;
(provide 'dpmisc)
(message "dpmisc.el... finished")
;; 
;; Local variables:
;; folded-file: t
;; folding-internal-margins: nil
;; end:

