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
           (if (not (re-search-forward "^#!.*python"
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
                            're-search-forward))))
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
        (when (re-search-forward "\\s-*$" (line-end-position) nil)
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
  (state states)                        ; `car' is state
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

;;-----------------------------------------------------------------------------
;;
;; Lang: C/C++ <:c|c++|c language functions:>
;;
;;-----------------------------------------------------------------------------

(defstruct dp-c-kw-action
  (keyword-regex)                       ; Finds keywords
  ;; What to do?
  ;; If string
  (action)
  ;; Eg for protection labels. If `:' is added, do another open-newline
  (recurse))

(defvar dp-c-kw-action-list 
  (list
   (make-dp-c-kw-action :keyword-regex "return\\|break" 
                        :action ";" 
                        :recurse nil)
   (make-dp-c-kw-action :keyword-regex "public\\|private\\|protected" 
                        :action ":" 
                        :recurse t)))

(defvar dp-c-symbol-start-chars "a-zA-Z_")
(defvar dp-c-non-symbol-start-chars (concat "^" dp-c-symbol-start-chars))

(require 'cc-mode)
(when (>= (string-to-number c-version) 5.17)
  (require 'cc-vars)
  (require 'cc-langs)
  (require 'cc-cmds)
  (require 'cc-engine))
(dp-define-my-map-prefixes c-mode-map)
(dp-define-my-map-prefixes c++-mode-map)

(defsubst dp-in-plain-c ()
  "Are we in C and not C++?"
  (eq major-mode 'c-mode))

(defsubst dp-in-c++ ()
  "Are we in C++ and not C?"
  (eq major-mode 'c++-mode))

(defsubst dp-in-c ()
  "Are we in a C-like langauge buffer?"
  (or (dp-in-plain-c)
       (dp-in-c++)))

(defun dp-c-de-capitalize-symbol ()
  "RemoveCapitalizationInOrderToFixCamelCase."
  (interactive)
  (save-excursion
    (when (and (or (dp-c-beginning-of-current-token)
                   (progn 
                     (backward-word)
                     (dp-c-beginning-of-current-token)))
               (looking-at "[A-Z]"))
      (replace-match (downcase (match-string 0)) t))))

(defun dp-c-goto-access-label ()
  "Find the next access label after point."
  (interactive)
  (let ((p (point))
        (label-regxep "\\<\\(protected\\|private\\|public\\):"))
    (when (looking-at label-regxep)
      (forward-char 1))
    (if (re-search-forward label-regxep nil t)
        (dp-push-go-back "dp-c-goto-access-label" p)
      ;; Go back, just in case we moved.  Just go w/o seeing if we moved.
      (goto-char p))))
                      
(defun dp-c++-get-class-name (&optional kill-name-p)
  "Get the name of the class we're in and put in echo area."
  (interactive "P")
  (save-excursion
    (dp-c-beginning-of-defun 1 'real-bof)
    (beginning-of-line)
    (if (looking-at "^\\s-*template\\s-*<")
        (forward-line 1))
    (when (re-search-forward (concat "^\\s-*"
                                     (dp-mk-c++-symbol-regexp "struct\\|class")
                                     "\\s-*\\(\\S-+\\)\\s-*")
                             (line-end-position) t)
      (when kill-name-p
        (kill-new (match-string 2)))
      (cons (match-string 1) (match-string 2)))))

(defun dp-c-show-class-name ()
  "Find the class' name and display it."
  (interactive)
  (let ((name (dp-c++-get-class-name)))
    (if name
        (message "%s: %s" (car name) (cdr name))
      (ding)
      (message "Cannot determine class name."))))

;; Can't use `dp-c-get-syntactic-region'.
(defun dp-in-cpp-construct-p (&optional current-syntax)
  "!<@todo Convert syntax to string and look for \"^cpp\" ???"
  (setq current-syntax (dp-flatten-list (or current-syntax 
                                            (c-guess-basic-syntax))
                                        'symbolp))
  (loop for syntax in '(cpp-macro cpp-define-intro)
    when (memq syntax current-syntax)
    return syntax))

(defun dp-c-get-syntactic-region (&optional ignore-list)
  "Where in the C are we?"
  (interactive)
  (catch 'up
    (let* ((cgbs (c-guess-basic-syntax))
           (dummy (when (dp-in-cpp-construct-p cgbs)
                    (throw 'up (dp-in-cpp-construct-p cgbs))))
           (syntax (caar cgbs))
           ;; Syntax classes which can have sub-syntaxes.
           (sub-syntax-list 
            '(inclass defun-block-intro statement-case-intro))
           sub-syntax)
      ;; Some syntaxes returned are grouped into an enclosing syntax,
      ;; e.g. inclass and statement-case-intro (? statement-case-* ?)
      ;; e.g e.g.: ((statement-case-intro 57790) (comment-intro))
      ;; vs ((comment-intro 9827))
      ;; another eg: ((inclass 395) (topmost-intro 397))
      ;;!<@todo looks like returning car of LAST item in syntax list is what
      ;;we want ???
      ;; syntactic analysis: ((inclass 3727) 
      ;;                      (topmost-intro 9897) (comment-intro))
      ;; Are we in the sub-syntax-list?
      (if (and (memq syntax sub-syntax-list)
               ;; And not ignored?
               (not (memq syntax ignore-list))
               ;; And is there a sub-syntax anyway?
               (setq sub-syntax (caadr cgbs)))
          (throw 'up sub-syntax))
      syntax)))
      
(defun dp-c-show-syntactic-region (&optional ignore-list)
  (interactive)
  (message "dp: %s; cbgs: %s" 
           (dp-c-get-syntactic-region ignore-list)
           (c-guess-basic-syntax)))

(defun dp-c-in-syntactic-region (syntax-list &optional ignore-inclass c-syntax)
  (and (dp-in-c)
       (member (or c-syntax 
                   (dp-c-get-syntactic-region (and ignore-inclass '(inclass))))
               syntax-list)))

(defun dp-c-in-brace-list-p ()
  (dp-c-in-syntactic-region '(brace-list-entry brace-list-intro)))

(defun dp-in-c++-class ()
  "Are we in a C++ class definition?"
  (let ((bpos (c-least-enclosing-brace (c-parse-state))))
    (when bpos
      (save-excursion
        (goto-char bpos)
        (dp-c-in-syntactic-region '(class-open)))))) 

(defsubst dp-in-c-arglist ()
  "Are we in a C/C++ function's arglist?
We are assumed to be in a C-like buffer."
  (dp-c-in-syntactic-region '(arglist-intro arglist-cont)))

(defvar dp-c-beginning-of-defun-regexp "^\\s-*{\\s-*$"
  "Cheesy, but easy regexp to find the beginning of a defun.
VERY accurate given my indentation style.")

(defun* dp-c-prev-eol-regexp (&optional regexp goto-eol-p)
  "Look for REGEXP at the end of the first preceding non empty line."
  (interactive)
  (setq-ifnil regexp dp-ws+newline-regexp+-not)
  (save-excursion
    (when goto-eol-p
      (dp-c-end-of-line))
    (while
        ;; Look back for any non-ws chars
        (if (dp-looking-back-at dp-ws+newline-regexp+-not)
            ;; Got something. Return nil if it's not what we want.
            (return-from dp-c-prev-eol-regexp
              (if (dp-looking-back-at regexp)
                  (list (match-beginning 0)
                        (buffer-substring-no-properties (match-beginning 0)
                                                        (match-end 0)))
                nil))
          (previous-line 1)
          (dp-c-end-of-line)))))

(defun dp-c-beginning-of-defun (&optional arg real-bof)
  "If preceeding command was `c-end-of-defun' do a go-back.  
If ARG is C-0, C-u or t then use `c-beginning-of-defun'.  This will call the
orginal code and currently that takes us back to the beginning of the class,
not an inlined defun.  Otherwise use a really cheap but not entirely
ineffective regexp to find the beginning of a defun like construct.  
Also, leave the region active."
  (interactive "_p")
  (if (memq last-command '(dp-c-end-of-defun dp-scroll-down dp-scroll-up))
      (progn
        (dp-pop-go-back)
        (setq this-command nil))
    ;; May want to change sense of arg to mean plain defun when true.
    (cond ((or real-bof
               (member current-prefix-arg '(0 (4) '- t)))
           (dp-push-go-back "`real c-beginning-of-defun'")
           (c-beginning-of-defun 1)
           ;; if this is called by a `kb-lambda' then we need to make sure
           ;; that the last-command var is currect so the toggling works.
           (setq this-command 'dp-c-beginning-of-defun))
          ((and (numberp arg) (< arg 0)) 
           (dp-push-go-back "`real c-beginning-of-defun'")
           (c-beginning-of-defun (- arg)))
          ((dp-point-follows-regexp dp-c-beginning-of-defun-regexp)
           (dp-push-go-back "`after dp-c-beginning-of-defun-regexp'")
           (beginning-of-line)
           (dp-c-beginning-of-statement))
          ((save-excursion
             (beginning-of-line)
             (re-search-backward dp-c-beginning-of-defun-regexp nil t))
           (dp-push-go-back 
            "`re-search-backward  dp-c-beginning-of-defun-regexp'")
           (goto-char (match-end 0)))
          (t (call-interactively 'c-beginning-of-defun)
             (dp-push-go-back "`real c-beginning-of-defun'")))))

(defun dp-c-end-of-defun (&optional arg real-bof)
  "Inverse of `dp-c-beginning-of-defun'."
  (interactive "_p")
  (if (memq last-command '(dp-c-end-of-defun dp-scroll-down dp-scroll-up))
      (progn
        (dp-pop-go-back)
        (setq this-command nil))
    ;; May want to change sense of arg to mean plain defun when true.
    (cond ((or real-bof 
               (member current-prefix-arg '(0 (4) '- t)))
           (dp-push-go-back "`dp-c-end-of-defun'")
           (c-end-of-defun 1)
           ;; if this is called by a `kb-lambda' then we need to make sure
           ;; that the last-command var is currect so the toggling works.
           (setq this-command 'dp-c-end-of-defun))
          ((and (numberp arg) (< arg 0)) 
           (dp-push-go-back "`real c-end-of-defun'")
           (dp-c-beginning-of-defun (- arg)))
          ((save-excursion
             (end-of-line)
             (re-search-forward "^\\s-*{" nil t))
           (dp-push-go-back "`forward to { dp-c-end-of-defun'")
           (goto-char (match-end 0)))
          (t (call-interactively 'c-end-of-defun)
             (dp-push-go-back "`real c-beginning-of-defun'")))))

(defun dp-mk-c++-symbol-regexp (sym &optional quote-p)
  "Make a regexp that will match the C++ symbol SYM.
Using it in `*search*' will, if found, result in (match-data 1) being the
symbol name.
QUOTE-P cause SYM to be `regexp-quote'd. 
Of course, you'll need to adjust the number for any preceding regexps."
  (format "\\(?:\\s_\\|\\sw\\)*\\(%s\\)\\(?:\\s_\\|\\sw\\)*"
          (if quote-p
              (regexp-quote sym)
            sym)))

(defun* dp-c-delimit-symbol (&key limit noerror count buffer 
                             (skip-non-symbol-chars t))
  "Assumes you are at the symbol or leading non-symbol chars.
e.g.
-!-return
-!-  return
\(-!-\(\(\(a+2 "
  (interactive)
  (let ((ret-list
         (list
          (point)                         ; Starting position. 0
          (progn 
            (if skip-non-symbol-chars
                (skip-chars-forward dp-c-non-symbol-start-chars))
            (point))                      ; First symbol char. 1
          (progn
            (skip-syntax-forward "w_")
            (point))                      ; Last symbol char+1. 2
          )))
    ret-list))

(defun* dp-c-get-symbol@point (&rest rest &key sym-name &allow-other-keys)
  (interactive)
  (save-excursion
    (let ((pos-list (apply 'dp-c-delimit-symbol rest)))
      (if (eq (nth 1 pos-list) (nth 2 pos-list))
          nil
        (cons (buffer-substring (nth 1 pos-list) (nth 2 pos-list))
              pos-list)))))

(defun* dp-c-looking-at-symbol (sym-name &rest rest &key regexp-p 
                                &allow-other-keys)
  (interactive)
  (let ((sym-info (dp-c-get-symbol@point)))
    (when sym-info
      (if regexp-p
          (string-match sym-name (car sym-info))
        (string= sym-name (car sym-info))))))

(defun dp-c-open-after-kw (&optional key-word regexp-p)
  (interactive)
  (let* (fpoint
         (found-p (dp-with-saved-point fpoint
                    (dp-c-looking-at-symbol (or key-word ".*")
                                            (or regexp-p (not key-word))))))
    (when found-p
      (dp-c-limited-end-of-statement)
      (skip-chars-backward " \t\r")
      (unless (dp-looking-back-at "[;,:]")
        (insert ";"))
      (dp-c-fix-comment)
      t)))

(defun dp-c-open-after-any-kw (kw-action-list)
  (interactive)
  (if (loop for kw in kw-action-list
        if (dp-c-open-after-kw kw) return t)
      t
  nil))


(defun dp-c-perform-action-upon-keyword (kw-action)
  (save-excursion
    ;; (concat "^\\s-*" (dp-mk-c++-symbol-regexp "return\\|break")))
    (let ((action (dp-c-kw-action-action kw-action))
          (regex (concat "^\\(?:\\s-*\\)\\(" 
                         (dp-mk-c++-symbol-regexp 
                          (dp-c-kw-action-keyword-regexp kw-action))
                         "\\)")))
      (when (save-excursion
              (beginning-of-line)
              (re-search-forward regex (line-end-position) t))
        (if (not (stringp action))
            (funcall action)
          (dp-c-end-of-line)
          (unless (dp-looking-back-at action)
            (insert action)))
        kw-action))))

(defun* dp-c-action-upon-keyword? (&optional (kw-action-list 
                                              dp-c-kw-action-list))
  (if (let ((kw-ret (loop for kw in kw-action-list
                      if (dp-c-perform-action-upon-keyword kw) 
                      return kw)))
        kw-ret)
  nil))

(defun* dp-c-limited-end-of-statement (&key limit (stay-put-p t)
                                       (no-error-p t) (limit-eol-p t)
                                       (goto-limit-p t))
  "Find the end of the language line. Eg char before comment.
STAY-PUT-P: c++-mode's end of *statement*. Can be many lines away.
GOTO-LIMIT-P: leave point @ limited-end-pos
STAY-PUT-P and GOTO-LIMIT-P are mutually exclusive. If both are non-nil, the
results are undefined.
LIMIT-EOL-P: force arg LIMIT to be line end position."
  (interactive)
  (setq limit (cond
               (limit-eol-p (line-end-position))
               ((not limit) (point-max))
               (t limit)))
  (let (fpoint
        (comment-pos (or (comment-search-forward (line-end-position) t)
                         (point-max))))
    (dp-with-saved-point fpoint
      (c-end-of-statement))
    (if (< fpoint limit)                ; Found it.
        (goto-char fpoint)
      ;; Didn't find it.  What ever shall we do?
      (when limit
        (setq limit (min comment-pos fpoint limit)))
      (cond
       (goto-limit-p
        (and limit
             (goto-char limit))
        (cons 'limit limit))
       (stay-put-p 
        (goto-char fpoint)
        (cons 'stay-put fpoint))
       (no-error-p (cons 'error "Ignoring argument errors"))
       (t (error 'invalid-argument))))))
      
(defun dp-c-fix-comment ()
  "Fix up the location of a comment in a C like language."
  (interactive)
  ;; `save-excursion' doesn't work here.
  ;; ??? marker vs number?
  (when (comment-search-forward (line-end-position) t)
    (indent-for-comment)))

(defvar dp-c-classname-suffix "t"
  "User defined type.  Ugly, I know.
Other possibilities to ponder...
?? _s: struct
   _c: class
   _u: (udt) no: --> union
   _t: ANSI syntaxanistas say NO. But I'm gonna fly in the face of authority.
   _a: `aggregate'... I didn't like the way it looked.
   _cls: verboser class")

;; !<@todo XXX Differentiate between classes (aka structs) and other typedefs?
(defvar dp-c-classname-suffix-list '("t" "cls" "c" "a" "s" "tn" "td")
  "User defined type.  Ugly, I know.
?? _s: struct
   _c: class
   _u: no: --> union
   _t: ANSI syntaxanistas say NO.
   _a: `aggregate'... I didn't like the way it looked.
   _cls: verboser class")

(defvar dp-c-struct-suffix-regexp
  (concat "^\\s-*\\(\\(?:struct\\|class\\)\\s-+\\)"
          "\\(\\(\\sw\\|\\s_\\)*?\\)"
          
          "\\(?:\\s-*:"
          "\\s-*"
          "\\(?:\\(public\\|private\\|virtual\\)\\s-*\\)*"
          "\\s-*"
          "\\(\\(\\sw\\|\\s_\\)*?\\)\\)?"

          (format "\\(\\(%s\\)\\{0,1\\}\\)\\(\\s-*\\)$"
                  (concat "_" dp-c-classname-suffix)))
  "Recognize a class/struct and possibly my desired suffix.
Needs to be fixed when subclassing.")

(defun dp-c-looking-at-struct-decl-p (&optional limit noerror count buffer)
  (re-search-forward dp-c-struct-suffix-regexp limit noerror count buffer))

(defun dp-c-looking-back-at-comma-killers-p ()
"Look backwards for characters which should never be followed by a comma."
  (dp-looking-back-at "[)(\\\\&|,:;!@#$%^*'{}.]\\s-*"))

(defun dp-c-handle-keyword-lines ())

(require 'dp-open-newline)

;; (defstruct dp-cob-state-t
;;   last-sub-command
;;   mod-begin-pos
;;   mod-end-pos
;;   next-suffix
;;   (under-score ""))

;; (defvar dp-cob-state (make-dp-cob-state-t)
;;   "State of last cob modification.")

;; (defun* dp-cob-repeat-sub-command-p (cob-state sub-cmd &key l-last-command
;;                                      l-this-command)
;;   (and (eq (or l-this-command this-command)
;;            (or l-last-command last-command))
;;        (eq (dp-cob-state-t-last-sub-command cob-state) sub-cmd)
;;        sub-cmd))


;; !<@todo XXX Going to have to add style stuff here, eg:
;; permabit likes: margin>|static void func(void)
;; And I like: margin>|static void
;;             margin>|verifyIndex(void)

(defun dp-c-camel-to-classic-str (string)
    "Very crudely convert camel case (xxYy) to classic vars (xx_yy).
Will miss many cases and do it in comments, too.
Uses strict definition of camel case."
  (with-case-folded nil
    (while (string-match "\\([a-z]\\)\\([A-Z]\\)" string)
      (setq string
            (replace-match (concat (match-string 1 string)
                                   "_"
                                   (downcase (match-string 2 string)))
                           nil nil
                           string)))
    string))

(defun* dp-c-classic-to-camel (&optional (capitalize-p nil))
  "Very crudely convert classic vars (xx_yy) to camel case (xxYy).
Will miss many instances and do it in comments, too. "
  (interactive "P")
  (save-excursion
    (save-restriction
      (dp-narrow-to-region-or... :bounder 'rest-of-buffer-p)
      (goto-char(point-min))
      (let (hump)
        (while (re-search-forward "_\\(.\\)" nil t)
          ;; x_y --> xY
          (replace-match (upcase (match-string 1)))
          (when capitalize-p
            (save-excursion
              (capitalize-word))))))))

(defun dp-c-camel-to-classic (&optional keep-beginning-capital-p)
  "Very crudely convert camel case (xxYy) to classic vars (xx_yy).
Will miss many cases and do it in comments, too. "
  (interactive "P")
  (let* ((case-fold-search nil)
         (be (dp-region-or... :bounder 'rest-of-buffer-p))
         (end (cdr be))
         (beg (car be)))
    (when end
      (goto-char beg)
      (save-excursion
        ;; xY --> x_y
        (while (re-search-forward "\\([a-z]\\)\\([A-Z]\\)" end t)
          (replace-match (concat (match-string 1)
                                 "_"
                                 (downcase (match-string 2))))
          (unless keep-beginning-capital-p
            (save-excursion
              (dp-c-de-capitalize-symbol))))))))

(dp-defaliases 'dp-kill-camel 'dp-fix-symbol 'kill-camel 'kamel 
               'dpkc 'dp-c-camel-to-classic)

(defvar dp-<type>*-regexp-memo nil)
(defun dp-<type>*-regexp ()
  (setq dp-<type>*-regexp-memo
        (concat "\\("
                "[a-zA-Z_][a-zA-Z_0-9]*_[tse]"
                "\\|" (regexp-opt dp-c-type-list 'paren) 
                "\\|" (regexp-opt dp-c*-additional-type-list 'paren)
                "\\)"
                "\\(\\*\\)"
                )))

(defun dp-c*-make-ugly-pointer-decl ()
  "Convert proper code, to improper, eg: char* p --> char *p.
We say: \" p is a pointer to char\", not 
\"p is a variable which when dereferenced is a char.\""
  (interactive)
  (when (dp-looking-back-at (or dp-<type>*-regexp-memo
                                (dp-<type>*-regexp)))
      (replace-match "\\1 *")
      (when (looking-at " ")
        (delete-char))
      t))


(defun dp-c*-electric-space ()
  (interactive)
  (or (dp-c*-make-ugly-pointer-decl)
      ;; Add other things to try here. We will stop after the first non-nil
      ;; return.
      (insert " ")))

;;
;; Doc stuff
;;
(defun q.v.-header-doc ()
  "Meet naming convention for q.v. functions."
  (dp-visit-header-doc))

(defun q.v.f (what)
  "q.v. which see. Go and see it."
  (let* ((what-name (concat "q.v.-"
                           (dp-string-join what "-" 
                                           nil nil nil
                                           (lambda (s)
                                             (format "%s" s)))))
         ;; Do this or make an assoc?
         (what-sym (intern-soft what-name)))
    (when what-sym
      (funcall what-sym))))


(defmacro q.v. (&rest rest)
  "Quote the args in REST and call the q.v. function"
  `(q.v.f (quote ,rest)))

(defun dp-doxy-align-comment-doc (begin end)
  "Align doxygen comments for readability in the source. E.g.:
@arg this -- this is what this is.
@retval this_results -- f(this).
Becomes:
@arg    this         -- this is what this is.
@retval this_results -- f(this).
"
  (interactive "r")
  ;; Hacked together from simple align interactive commands
  (unless (markerp end)
    (setq end (dp-mk-marker end nil t)))
  (align-regexp begin end "@\\S-+\\(\\s-+\\)" 1 1 nil)
  (align-regexp begin end  "\\(\\s-*\\)--" 1 1 nil))

(defun dp-doxy-directives-in-range (begin end)
  "Does the range include doxygen directives?"
  (interactive "r")
  (save-excursion
    (goto-char begin)
    (re-search-forward "@\\S-+\\s-+" end t)))

(defun dp-c*-in-doxy-comment (begin end)
  "Are we in a C/C++ comment which includes doxygen directives??"
  (interactive "r")
  (and (dp-in-a-c*-comment)
       (dp-doxy-directives-in-range begin end)))


(defun dp-c*-align (begin end &optional separate rules exclude-rules)
  "Simple mod to `align' for c++-mode to change behavior in a doxygen comment."
  (interactive "r")
  (if (dp-c*-in-doxy-comment begin end)
      (dp-doxy-align-comment-doc begin end)
    (align begin end separate rules exclude-rules)))

(defun dp-c*-next-line (count)
  "Add trailing white space removal functionality."
  (interactive "_p")
  (loop repeat count do
    (if (eolp)
        (dp-func-and-move-down 'dp-cleanup-line
                               t
                               'next-line)
      (call-interactively 'next-line))))

;;-----------------------------------------------------------------------------
;;
;; Lang: C/C++ <:c|c++|c language functions end:>
;;
;;-----------------------------------------------------------------------------

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
