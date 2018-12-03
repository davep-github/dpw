;;; This parsing stuff sucks.  But the CEDET stuff don't really work
;;; w/XEmacs.  At least it don't with the beta XEmacs code.

;;-----------------------------------------------------------------------------
;;
;; Lang: python <:Python|python:>
;;
;;-----------------------------------------------------------------------------

; ; (defvar doxy-py-method-comment-elements-old '("
; ;  #######################################################################" > "
; ;  ##" > "
; ;  ## @brief " (P "brief desc: " desc nil) > "
; ;  ##" > % >)
; ;   "Elements of a Python method comment template")

; (defvar doxy-py-method-comment-elements-old-1 '("
;  #######################################################################" > "
;  ##" > "
;  ## @brief " p > "
;  ##" > % >)
;   "Elements of a Python method comment template")

; (defvar doxy-py-class-comment-elements-good '("
;  #######################################################################" > "
;  ##" > "
;  ## @class " p > "
;  ## @brief " p > "
;  ##" > % >)
;   "Elements of a Python class comment template")

(defvar doxy-py-prelude-comment-elements '("
 #######################################################################" > "
 ##" > "
 ## @brief " (P "brief desc: " desc nil) > "
 ## " > % >)
  "Elements of a Python prelude comment template")


(defvar doxy-py-class-comment-elements '("
 #######################################################################" > "
 ##" > "
 ## @class " p > "
 ## @brief " (P "brief desc: " desc nil) > "
 ##" > % >)
  "Elements of a Python class comment template")


(defvar doxy-py-method-comment-elements '("
 #######################################################################" > "
 ##" > "
 ## @brief " (P "brief desc: " desc nil) > "
 ## " > % >)
  "Elements of a Python method comment template")

(defvar doxy-py-function-comment-elements '("
 #######################################################################" > "
 ##" > "
 ## @brief " (P "brief desc: " desc nil) > "
 ## " > % >)
  "Elements of a Python function comment template")

(tempo-define-template "doxy-py-prelude-comment"
		        doxy-py-prelude-comment-elements)
(tempo-define-template "doxy-py-class-comment"
		        doxy-py-class-comment-elements)
(tempo-define-template "doxy-py-method-comment"
		        doxy-py-method-comment-elements)
(tempo-define-template "doxy-py-function-comment"
		        doxy-py-function-comment-elements)


;;;
;;; info @todo Make it a struct fer Knuth's sake.
;;; <:info structure:>
;;; (marker@beginning-of-construct 
;;;  marker@end 
;;;  type{class, def, method, prelude}
;;;  def-or-class-name-or-"prelude")
;;; 

(defsubst dp-py-def-or-class-begin (info &optional nth)
  (nth (or nth 0) info))

(defsubst dp-py-def-or-class-end (info)
  (dp-py-def-or-class-begin info 1))


(defsubst dp-py-def-or-class-type (info)
  (dp-py-def-or-class-begin info 2))

(defsubst dp-py-def-or-class-name (info)
  (when (< 3 (length info))
    (dp-py-def-or-class-begin info 3)))


(defun dp-py-delimit-prelude (backward-p search-fun &optional limit)
  (list (dp-mk-marker                   ; Find beginning 
         (save-excursion
           (goto-char (point-min))
           (if (not (dp-re-search-forward "^#!.*python"
                                       (line-end-position)
                                       t))
               ;; No interpreter line.  Use `point'
               (point)                  ; Beginning
             ;; In a file with some chars and no newline, NB: There is no
             ;; [BOF] in the file, but there is an [EOF] eof glyph.
             
             ;; e.g. [BOF]hi there[EOF] If point is on any of "hi there" and
             ;; you say `forward-line' it returns 0 and puts point @
             ;; [EOF]-!-.  I don't like this.  It may be because of my EOF
             ;; text. If point is @ [EOF]-!-, `forward-line' returns 1.  So
             ;; doing an `end-of-line' seems to make more sense.
             (end-of-line)
             ;; Forward line returns how many lines it didn't move.
             (unless (equal (forward-line 1) 0)
               ;; Need to add a line.
               (end-of-line)
               (newline))
             (line-beginning-position)  ; Beginning
             )))
        (dp-mk-marker                   ; Find end
         (save-excursion
           (let ((next-thing-info (dp-py-next-def-or-class 
                                   nil nil 
                                   'dont-call-me-again! limit)))
             ;; If we found something, use it.
             (if next-thing-info
                 (save-excursion
                   (goto-char (dp-py-def-or-class-begin next-thing-info))
                   (previous-line 1)
                   (point))
               ;; Otherwise, EOF seems a good alternative.
               (point-max)))))
        'prelude
        "prelude"))

(defun dp-py-next-def-or-class (&optional backward-p search-fun 
                                dont-try-prelude-p limit)
  "SEARCH-FUN must have the same function signature ad re-search-*ward."
  (interactive)
  (save-excursion
    (let ((search-fun (or search-fun
                          (if backward-p 
                              're-search-backward 
                            'dp-re-search-forward))))
      (if (funcall 
           search-fun
           "\\(^def\\s-+\\)\\|\\(^\\s-+\\(def\\s-+\\)\\)\\|\\(^\\s-*class\\)" 
           limit t)
          (list (dp-mk-marker (save-excursion
                              (goto-char (match-beginning 0))
                              (skip-chars-forward " ")
                              (point)))
              (dp-mk-marker (match-end 0))
              (cond
               ((match-string 1) 'function)
               ((match-string 3) 'method)
               ((match-string 4) 'class)))
        ;; We found nothing.  We be in the region between the BOF and the
        ;; first (if any) construct.  The prelude.
        ;; We'll consider the top of this region the line after the she-bang.
        (unless dont-try-prelude-p
          (dp-py-delimit-prelude backward-p search-fun limit))))))


(defsubst dp-py-prev-def-or-class (&optional search-fun dont-try-prelude-p
                                   limit)
  (interactive)
  (dp-py-next-def-or-class 'backward search-fun dont-try-prelude-p limit))
  
(defun dp-py-find-next-def-or-class (type &optional other-end-o-match backward)
  (interactive)
  (save-excursion
    ;; computing backward.
    ;; backward
    ;; 
    (let (info)
      ;; other-end-o-match is needed here so that calling back in has the same
      ;; params. Icky.
      (while (and (setq info (dp-py-goto-next-def-or-class 
                              other-end-o-match nil backward))
                  (not (eq (dp-py-def-or-class-type info) type))))
      info)))

(defun dp-py-goto-next-def-or-class (&optional other-end-o-match type backward
                                     limit)
  (interactive)
  (let ((info (if type
                  (dp-py-find-next-def-or-class type nil backward)
                (dp-py-next-def-or-class backward nil nil limit))))
    (when info
      (dp-push-go-back "Python def/class hopping")
      ;; The xor makes it work like re-search-*
      (if (not (dp-xor other-end-o-match backward))
          (goto-char (dp-py-def-or-class-end info))
        (goto-char (dp-py-def-or-class-begin info))))
    info))

(defun dp-py-goto-prev-def-or-class ()
  (interactive)
  (dp-py-goto-next-def-or-class nil nil 'backward))

(defun dp-py-in-xxx-p (type)
  (interactive)
  (eq type (dp-py-def-or-class-type (dp-py-prev-def-or-class))))

(defun dp-py-in-class-p ()
  (interactive)
  (dp-py-in-xxx-p 'class))

(defun dp-py-in-method-p ()
  (interactive)
  (dp-py-in-xxx-p 'method))

(defun dp-py-in-function-p ()
  (interactive)
  (dp-py-in-xxx-p 'function))

(defun dp-py-in-prelude-p ()
  "Are we above all classes and defs?"
  (interactive)
  (dp-py-in-xxx nil))

(defun dp-py-looking-at-def-or-class-p ()
  (looking-at "\\s-*\\(class\\|def\\)\\s-+\\([^(:]+\\)"))

  
(defun dp-py-get-def-or-class-name (&optional pos)
  (interactive)
  (save-excursion 
    (when pos (goto-char pos))
    ;; Works by hand.
    ;; \s-*\(def\|class\)\s-*\(.*?\)\((\|:\)
    ;; \\s-*\\(def\\|class\\)\\s-*\\(.*?\\)\\((\\|:\\)
    (when (looking-at "\\s-*\\(class\\|def\\)\\s-+\\([^(:]+\\)")
      (match-string 2))))

(defun dp-py-get-nearest-def-or-class-name (&optional check-current-line-p)
  "CHECK-CURRENT-LINE-P says to check the current line for a def or class
keyword.  Normally, we don't check the current line so multiple nearest def
commands don't get stuck on the current def once we've moved to one.  When
non-nil we only look forward on the current line, ie. the search limit is
`line-end-position'."
  (interactive) 
  (let* ((info (or (and check-current-line-p
                        (dp-py-next-def-or-class 
                         nil
                         'dp-looking-at-with-re-search-params
                         'DONT-TRY_PRELUDE
                         (line-end-position)))
                   (dp-py-prev-def-or-class)))
         (def-or-class-name (when info
                              (dp-py-get-def-or-class-name 
                               (dp-py-def-or-class-begin info)))))
    (if def-or-class-name
        (append info (list def-or-class-name))
      info)))
  
(defun dp-py-insert-tempo-comment (begin end type name tempo-func
                                   &optional insert-name)
  (interactive)
  (let ((indent-col (dp-column-at begin)))
    (goto-char begin)
;;    (newline-and-indent)
    (previous-line 1)
    (dp-insert-tempo-template-comment tempo-func nil nil indent-col)
    (when insert-name
      (insert name))
    (tempo-forward-mark)))

(defvar dp-py-tempo-doxy-comment-type-function-map
  '((prelude tempo-template-doxy-py-prelude-comment)
    (class  tempo-template-doxy-py-class-comment insert-name)
    (method  tempo-template-doxy-py-method-comment nil)
    (function  tempo-template-doxy-py-function-comment nil))
"Map a Python syntactic location to a doxy comment template.")

(defun* dp-py-insert-tempo-doxy-comment (&optional no-indent-p 
                                         (check-current-line-p 
                                          'check-current-line))
  "Insert a Python mode tempo doxygen comment in a syntax sensitive manner."
  (interactive "*P")
  ;;!<@todo Fix cad*rs: make map-info a struct.

  (save-excursion
    (beginning-of-line)
    (let* ((info (dp-py-get-nearest-def-or-class-name check-current-line-p))
           (map-info (assoc (dp-py-def-or-class-type info)
                            dp-py-tempo-doxy-comment-type-function-map))
           (fun (when info
                  (cadr map-info))))
      (if fun
          (dp-py-insert-tempo-comment
           (dp-py-def-or-class-begin info)
           (dp-py-def-or-class-end info)
           (dp-py-def-or-class-type info)
           (dp-py-def-or-class-name info)
           fun
           (caddr map-info))
        (ding)
        (message "Can't figure out what to do.")))))


(defun dp-paren-depth (&optional beg end)
  "How many unmatched open parens precede END."
  (interactive)
  ;; It is, after all, a *functional* language.
  (let ((beg-end (dp-region-or... :beg beg :end end)))
    (car (parse-partial-sexp (car beg-end) (cdr beg-end)))))

(defun dp-paren-depth-save-excursion (&rest rest)
  "`save-excursion' before calling `dp-paren-depth'."
  (save-excursion
    (apply 'dp-paren-depth rest)))

(defun dp-region-op (op &optional beg end &rest op-args)
  "`apply' OP on region as per `dp-open-region-or...' with OP-ARGS as args."
  (let (beg-end (dp-region-or...))
    (apply op (car beg-end) (cdr beg-end) op-args)))

(defun* dp-paren-depth-op (op &optional beg end &rest op-args)
  "`apply' OP to a region with OP-ARGS as args."
  (apply op (dp-paren-depth beg end) op-args))

(defun dp-paren-depth== (depth &optional beg end)
  "Does the current paren depth (q.v.) == DEPTH?"
  (dp-paren-depth-op '= beg end depth))

(defun dp-py-end-of-block-stmt (&optional close-up-p)
  "Are we at the end of a full closed, paren-wise, block statement?
RETURNS:
Non-nil if so.
If not but we are at a place where some number of closing parens would fully
close us up, then return a cons of the number of closers and the closer.
CLOSE-UP-P says to go ahead and shut us up.
Otherwise non-nil."
  (interactive "P")
  (dp-with-saved-point nil
    (let* ((point (point))
           (bos (py-point 'bos))
           (closable-p 
            (not (dp-py-code-text-ends-with-special-char-p 
                  :except ")(")))
           (depth (dp-paren-depth bos (point)))
           (fully-closed-p (= depth 0)))
      (cond
       ((not (dp-in-code-space-p)) nil)
       ((and fully-closed-p (dp-looking-back-at ")"))
        t)
       (closable-p
        (if (not close-up-p)
            (cons depth ")")
          (insert (make-string depth ?\)))
          t))))))

(defstruct dp-py-split-block-stmt-info
  indent
  keyword
  class-or-def-p
  block-kw-p
  parens
  parameters
  class-def-p
  def-p
  method-p
  open-paren-only-p
  end-of-code-pos
  rest-of-line
  comment-string
  debug
  one
  two
  three
  four
  five
  six
  seven
  eight
  nine
  ten
  eleven)


(defun dp-pps (&optional beg end)
  (interactive)
  (setq-ifnil beg (line-beginning-position)
              end (line-end-position))
  (let ((p (point))
        (pps (parse-partial-sexp beg end)))
;;     (dmessage "p: %s, beg: %s, end: %s, pps: %s" p beg end pps
;;               )
    pps))

(defun dp-py-comment-start-pos (&optional beg end)
  (interactive)
  (destructuring-bind (beg . end) (dp-region-or... :beg beg :end end
                                                   :bounder 'line-p
                                                   :bounder-args '(nil t))
    (dp-with-saved-point nil
      ;;!<@todo should I use py-parse-state here? 
      (let ((pps (dp-pps beg end)))
        (when pps
          (setq dpv-x pps)
          (nth 8 pps))))))

(defun* dp-py-goto-comment-start (&rest rest &key q &allow-other-keys)
  (interactive)
  (let ((pos (apply 'dp-py-comment-start-pos rest)))
    (when pos
      (goto-char pos))))
  
(defun* dp-py-end-of-code-pos (&rest rest &key q &allow-other-keys)
  (save-excursion
    (let ((p (apply 'dp-py-comment-start-pos rest)))
      (if p
          (progn
            (goto-char p)
            (skip-syntax-backward "-" (line-beginning-position))
            (point))
        ;; No comment... use last non-blank character
        (beginning-of-line)
        (when (dp-re-search-forward "\\s-*$" (line-end-position) nil)
          (match-beginning 0))))))

(defun* dp-py-goto-end-of-code (&rest rest &key q &allow-other-keys)
  (interactive)
  (let ((pos (apply 'dp-py-end-of-code-pos rest)))
    (when pos
      (goto-char pos))))
  
(defun* dp-py-split-block-stmt (&optional pos)
  (when pos
    (goto-char pos))
  (when (dp-looking-back-at dp-py-block-stmt-split-regexp)
    ;; Pick apart the bits of a class or def line
    (let* ((indent (match-string 2))
           (keyword (match-string 3))
           (parens (match-string 4))
           (info (make-dp-py-split-block-stmt-info
                  :indent indent
                  :keyword keyword
                  :class-or-def-p (save-match-data
                                    (string-match dp-py-class-or-def-kw-regexp 
                                                  keyword))
                  ;; :block-kw-p (not class-or-def-p)
                  :parens parens
                  :parameters (or (dp-non-empty-string (match-string 5))
                                  (dp-non-empty-string (match-string 6))
                                  "")
                  :class-def-p (string= "class" keyword)
                  :def-p (string= "def" keyword)
                  ;; Classes can be inside other classes and so have leading
                  ;; WS.
                  :method-p (and (string= "def" keyword)
                                 (dp-non-empty-string indent))
                  :open-paren-only-p (string= "(" parens)
                  :end-of-code-pos (dp-py-end-of-code-pos)
                  :rest-of-line (match-string 9)
                  :comment-string (match-string 10)
                  :debug "debug start:"
                  :one (match-string 1)
                  :two (match-string 2)
                  :three (match-string 3)
                  :four (match-string 4)
                  :five (match-string 5)
                  :six (match-string 6)
                  :seven (match-string 7)
                  :eight (match-string 8)
                  :nine (match-string 9)
                  :ten (match-string 10)
                  :eleven (match-string 11))))
      ;; Set some derived things.  I'm sure the defstruct can do it somehow,
      ;; but the doc bites.
      (setf (dp-py-split-block-stmt-info-block-kw-p info)
            (not (dp-py-split-block-stmt-info-class-or-def-p info)))
      info)))
    

(defun* dp-py-keyword (&optional (point (point)))
  (interactive)
  (save-excursion
    (goto-char (py-point 'bos))
    (if (looking-at (concat
                     "^\\(\\s-*\\)" ; Leading spaces determine func or method.
                     "\\(" dp-py-block-keywords "\\)")) ; Specific keyword.
        (list (match-string 2)          ; Keyword
              ;; Indentation, "" ==> method-p if in class
              (match-string 1)))))

(defun dp-in-open-sexp (&optional beg end)
  (dp-paren-depth-op '> beg end 0))

(defun dp-py-goto-bos ()
  (interactive)
  (goto-char (py-point 'bos)))

(defstruct dp-add-comma-or-close-sexp-info
  (states '(add-sep add-clozer add-newline))
  ;; 1st go round (add sep)
  ;; 2nd (add clozer), 
  ;; 3rd (just eol, newline, indent)
  ;; ? repeat
  ;; FSF doesn't seem to like referencing previously initialized slots.  let
  ;; vs let*
  (state '(add-sep add-clozer add-newline)) ; `car' is state
  ;; Where we added the junk.
  (add-here nil)
  ;; Where we were when we started.
  (starting-point nil)
  ;; Where we want the sexp scan to start.
  (beg nil)
  ;; Where we want the sexp scan to end.
  (end nil))

(defvar dp-acocs-info (make-dp-add-comma-or-close-sexp-info)
  "State information about how this current sequence of comma or closings
  began.")

(defun dp-add-comma-or-close-sexp-info-shift-state (info)
  (setf (dp-add-comma-or-close-sexp-info-state info)
        (or (cdr (dp-add-comma-or-close-sexp-info-state info))
            (dp-add-comma-or-close-sexp-info-states info))))


(defun* dp-add-comma-or-close-sexp (&key beg (end (point))
                                    add-here
                                    ;; clozer, not nearer
                                    (separator ",") (clozer ?\))
                                    (caller-cmd 'dp-add-comma-or-close-sexp)
                                    (n-clozers-p t))
  (interactive)
  (if (eq this-command last-command)
      ;; Doing (or pretending to do) it again.
      (progn
        ;; Try to return to the initial conditions...
        (undo)
        (setq beg (dp-add-comma-or-close-sexp-info-beg dp-acocs-info)
              end (dp-add-comma-or-close-sexp-info-end dp-acocs-info)
              add-here (dp-add-comma-or-close-sexp-info-add-here 
                        dp-acocs-info))
        (goto-char (dp-add-comma-or-close-sexp-info-add-here 
                    dp-acocs-info))
        (dp-add-comma-or-close-sexp-info-shift-state dp-acocs-info))
    ;; First go round
    (setq dp-acocs-info
          (make-dp-add-comma-or-close-sexp-info
           :add-here (dp-mk-marker add-here)
           :starting-point (dp-mk-marker (point))
           :beg (dp-mk-marker beg)
           :end (dp-mk-marker end))))
  
  (let* ((depth (dp-paren-depth-save-excursion beg end))
         (num-clozers (if n-clozers-p depth 1))
         (state (or nil ;; Support current-prefix-arg later
                    (car (dp-add-comma-or-close-sexp-info-state 
                          dp-acocs-info))))
         ret)
    (dmessage "Don't do anything if funky chars @ end of line.")
    (if (not (and depth (> depth 0)))       ; Open sexp... not!
        (and (dp-py-keyword end) 'force-colon)
      (goto-char (or add-here end))
      (undo-boundary)
      (if (and (eq state 'add-sep)
               (dp-py-code-text-ends-with-special-char-p
                     :except "])"))
          (setq ret 'skipped-due-to-special-char)
        (setq ret state)
        (case state
          ('add-sep (insert separator))
          ('add-clozer 
           (insert (make-string num-clozers clozer))
           (when (dp-py-keyword end)
             (setq ret 'force-colon)))
          ('add-newline t))
        ;; If this was a keyword command, and we just inserted a clozer,
        ;; continue so we can ":" it if needed.
        (setq this-command caller-cmd))
      ret)))

(defvar dp-py-main+getopt-template
  "    import getopt
    options, args = getopt.getopt(sys.argv[1:], 'd:')

    for o, v in options:
        print 'o>%s<, v>%s<' % (o, v)
        if o == '-d':
            debug = debug + 1
            continue
        
    main(sys.argv[1:], sys.argv[0])
" 
"*A template for making a main in a Python program since I can never remember
the fiddly bits.")


(defun dp-py-insert-main+getopt-template ()
  (interactive)
  (beginning-of-line)
  (when (not (looking-at "$"))
    (end-of-line)
    (py-newline-and-indent))
  (insert dp-py-main+getopt-template))

;; @todo XXX make all indent-for-comment functions call a common dp- routine
;; which supports all of my added semantics, like handling regions, doing
;; line ups, etc.
(defun dp-py-indent-for-comment (&optional continue)
  "Fix Python's commenting to not always leave the comment at comment-column.
Python's `indent-for-comment' always puts the comment at the comment column
even if it's on an empty line. Most others put it at the current indent when
the line is blank."
  (interactive)
  (if current-prefix-arg
      (call-interactively 'indent-for-comment)  ; We don't do continues.
    ;; We need to know if the line was blank before we start
    (let ((blank-line-p (dp-blank-line-p)))
      (indent-for-comment)
      (when blank-line-p
        ;; This does the right thing on a blank line.
        (dp-press-tab-key)))))

;;;
;;; perl sucks. Perl sucks. perl Sucks. Perl Sucks. PERL sucks. perl SUCKS.
;;; PERL SUCKS.
;;; 

;; Take a list of perl parameters with a `,' added to the last one (eg $a,
;; $b, $c,) and convert it into a vertical list of @param doxygen lines.
(defalias 'dp-perl-@param-defs 
  (read-kbd-macro
   "C-a # SPC @param SPC C-d C-s , RET <backspace> RET <M-backspace>"))


;;;
;;; Fuck fucking [c]perl you fucking fuck.
;;;

(defun dp-cperl-indent-comments-fucking-correctly ()
  "Cperl sucks. Fix comment only indentation.
`cperl-indent-for-comment' on a comment only line puts us at comment column.
`cperl-indent-command' does what I think is right and puts it at the current
indentation level. So to fix it, I `indent-for-comment' and if I'm looking
back at `comment-start' and whitespace to beginning of line, then I do a
`cperl-indent-command.' I do this with brute force and no insulation against
changes."
  (interactive)
  (call-interactively 'cperl-indent-for-comment)
  (when (dp-looking-back-at (concat "^\\s-*" comment-start))
    (cperl-indent-command)))


(provide 'dp-lang)
