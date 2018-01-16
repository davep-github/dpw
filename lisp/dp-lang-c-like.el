;;;--------------------------------------------------------------------------
;;;
;;; Lang: C/C++ <:c|c++|c language macros:>
;;;
;;;--------------------------------------------------------------------------

;;;
;;; Saved macros. See dpmisc.el for process of adding new ones.
;;;

(defalias 'dp-prepare-to-move-c++-method
  (read-kbd-macro 
   (concat "C-a M-a C-s ( <left> M-[ <right> M-C-1 <right> M-o"
           " C-s { <left> M-[ <down> <up> C-a C-s } <left> M-[ M-a"
           " M-[ 2*<right> M-C-o C-x C-x DEL <up> C-e ; ")))

(defalias 'dp-move-c++-method-olde
  (read-kbd-macro 
   (concat "C-a M-a C-s ( <left> M-[ <right> M-C-1 <right> M-o"
           " C-s { <left> M-[ <down> <up> C-a C-s } <left> M-[ M-a"
           " M-[ 2*<right> M-C-o C-x C-x DEL <up> C-e ; C-x 4 M-b <C-next>"
           " <up> C-e RET RET M-y")))

(defalias 'dp-move-c++-method
  (read-kbd-macro 
   (concat "C-a M-a C-s ( <left> M-[ <right> M-C-1 C-e <right> M-o"
           " C-a C-s { <left> M-[ <down> <up> C-a C-s } <left> M-[ M-a"
           " M-[ 2*<right> M-C-o C-x C-x DEL <up> C-e ; 2*<down> C-x 4 M-b"
           " <C-next> <up> C-e RET RET M-y C-x C-x C-a M-q")))

(defalias 'dp-fix-class-dox
  (read-kbd-macro 
   (concat "C-a C-s @class RET C-T <up> <C-right> <C-backspace>"
           " class 2*<C-s> RET <C-backspace> brief SPC")))

(defalias 'dp-cpp-remove-inclass-body
  (read-kbd-macro 
   (concat "C-s ) RET C-s { RET <left> M-a M-[ <right>"
           " DEL <C-backspace> ; <down> C-a")))


;;;--------------------------------------------------------------------------
;;;
;;; Lang: C/C++ <:c|c++|c language functions:>
;;;
;;;--------------------------------------------------------------------------

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

(defun dp-c++-goto-access-label ()
  "Find the next access label after point."
  (interactive)
  (let ((p (point))
        (label-regxep "\\<\\(protected\\|private\\|public\\):"))
    (when (looking-at label-regxep)
      (forward-char 1))
    (if (dp-re-search-forward label-regxep nil t)
        (dp-push-go-back "dp-c++-goto-access-label" p)
      ;; Go back, just in case we moved.  Just go w/o seeing if we moved.
      (goto-char p))))
                      
(defun dp-c-get-class-name (&optional kill-name-p)
  "Display name of enclosing class/struct in echo area. Works with C structs."
  (interactive "P")
  (save-excursion
    (dp-c-beginning-of-defun 1 'real-bof)
    (beginning-of-line)
    (when (looking-at "\\(^\\s-*template\\s-*\\)<")
        (goto-char (match-end 1))
        (dp-c++-find-matching-paren)
        (forward-line 1)
        (beginning-of-line))
    (when (dp-re-search-forward (concat "^\\s-*"
                                     (dp-mk-c++-symbol-regexp "struct\\|class")
                                     "\\s-*\\(\\S-+\\)\\s-*")
                             (line-end-position) t)
      (when kill-name-p
        (kill-new (match-string 2)))
      (cons (match-string 1) (match-string 2)))))

(defun dp-c-show-class-name ()
  "Find the class' name and display it."
  (interactive)
  (let ((name (dp-c-get-class-name)))
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

(defun dp-c-in-syntactic-region (syntax-list 
                                 &optional ignore-inclass c-syntax)
  (and (dp-in-c)
       (member (or c-syntax 
                   (dp-c-get-syntactic-region 
                    (and ignore-inclass 
                         '(inclass))))
               syntax-list)))

(defun dp-c-in-brace-list-p ()
  (dp-c-in-syntactic-region '(brace-list-entry brace-list-intro)))

(defun dp-c++-in-class-p ()
  "Are we in a C++ class definition?"
  (let ((bpos (c-least-enclosing-brace (c-parse-state))))
    (when bpos
      (save-excursion
        (goto-char bpos)
        (dp-c-in-syntactic-region '(class-open)))))) 

(defalias 'dp-in-c++-class-p 'dp-c++-in-class-p)

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

(defun dp-c-beginning-of-defun (&optional arg original-cc-mode-bof)
  "If preceeding command was `c-end-of-defun' do a go-back.  
If ARG is none of C-0, C-u or t then use `c-beginning-of-defun'.  This will
call the orginal code and currently that takes us back to the beginning of
the class, not an inlined defun.  Otherwise use a really cheap but not
entirely ineffective regexp to find the beginning of a defun like construct.
Also, leave the region active."
  (interactive "p")                     ; find fix for fsf not having "_"
  ;; This allows this command to ignore `dp-scroll-down' and `dp-scroll-up'
  ;; as far as returning the the starting point vs going to back to where we
  ;; were before we went to the function boundary. Same applies to
  ;; 'dp-c-end-of-defun'.
  (dp-set-zmacs-region-stays t)
  (if (memq last-command '(dp-c-end-of-defun dp-scroll-down dp-scroll-up))
      (progn
        (dp-pop-go-back)
        (setq this-command nil))
    ;; May want to change sense of arg to mean plain defun when true.
    (cond 
     ((or original-cc-mode-bof
          (not (member current-prefix-arg '(0 (4) - t))))
      (dp-push-go-back "`real c-beginning-of-defun'")
      (c-beginning-of-defun 1)
      ;; if this is called by a `kb-lambda' then we need to make sure
      ;; that the last-command var is correct so the toggling works.
      (setq this-command 'dp-c-beginning-of-defun))
     ((and (numberp arg) (< arg 0))
      (dp-push-go-back "`real c-beginning-of-defun'")
      (c-beginning-of-defun (- arg)))
     ((dp-looking-back-at dp-c-beginning-of-defun-regexp)
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

(defun dp-c-beginning-of-defun-pos (&rest rest)
  (save-excursion
    (apply 'dp-c-beginning-of-defun rest)
    (point)))
  
(defun dp-c-end-of-defun (&optional arg original-cc-mode-bof)
  "Inverse of `dp-c-beginning-of-defun'."
  (dp-set-zmacs-region-stays t)
  (interactive "p")                     ;fsf need "_"
  (if (memq last-command '(dp-c-beginning-of-defun dp-scroll-down dp-scroll-up))
      (progn
        (dp-pop-go-back)
        (setq this-command nil))
    ;; May want to change sense of arg to mean plain defun when true.
    (cond ((or original-cc-mode-bof 
               (not (member current-prefix-arg '(0 (4) '- t))))
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
             (dp-re-search-forward "^\\s-*{" nil t))
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


;;nuke? (defun dp-c-perform-action-upon-keyword (kw-action)
;;nuke?   (save-excursion
;;nuke?     ;; (concat "^\\s-*" (dp-mk-c++-symbol-regexp "return\\|break")))
;;nuke?     (let ((action (dp-c-kw-action-action kw-action))
;;nuke?           (regex (concat "^\\(?:\\s-*\\)\\(" 
;;nuke?                          (dp-mk-c++-symbol-regexp 
;;nuke?                           (dp-c-kw-action-keyword-regexp kw-action))
;;nuke?                          "\\)")))
;;nuke?       (when (save-excursion
;;nuke?               (beginning-of-line)
;;nuke?               (dp-re-search-forward regex (line-end-position) t))
;;nuke?         (if (not (stringp action))
;;nuke?             (funcall action)
;;nuke?           (dp-c-end-of-line)
;;nuke?           (unless (dp-looking-back-at action)
;;nuke?             (insert action)))
;;nuke?         kw-action))))

;;nuke? (defun* dp-c-action-upon-keyword? (&optional (kw-action-list 
;;nuke?                                               dp-c-kw-action-list))
;;nuke?   (if (let ((kw-ret (loop for kw in kw-action-list
;;nuke?                       if (dp-c-perform-action-upon-keyword kw) 
;;nuke?                       return kw)))
;;nuke?         kw-ret)
;;nuke?   nil))

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
  (dp-re-search-forward dp-c-struct-suffix-regexp limit noerror count buffer))

(defun dp-c-looking-back-at-comma-killers-p ()
"Look backwards for characters which should never be followed by a comma."
  (dp-looking-back-at "[)(\\\\&|,:;!@#$%^*'{}.]\\s-*"))

;;nuke? (defun dp-c-handle-keyword-lines ())

(require 'dp-open-newline)

(defun dp-change-one-hump ()
  (interactive)
  (when (looking-at "_")
    (forward-char 1))
  (if (dp-looking-back-at "_\\w*")
      (progn
        (goto-char (dp-toggle-capitalization 1))
        (backward-char-command)
        (delete-backward-char))
    (dmessage-ding "Not looking at humpworthy text.")))

(defalias 'one-hump 'dp-change-one-hump)

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

;; There's no simple C/C++ token regexp.
(defvar dp-default-hump-selector "[a-zA-Z_]+_[a-zA-Z0-9_]*"
  "What to look for when no hump pattern is provided... a language token.
This doesn't suck too much.")

(defun* dp-hump-region (&optional (selector-pattern dp-default-hump-selector) 
                        query-p capitalize-p)
  (interactive "sName: \nP")
  (when (string= "" selector-pattern)
    (setq selector-pattern dp-default-hump-selector))
  (let (hump hump-end)
    ;; We can use the selector to make sure that we are always positioned at
    ;; the name we want to change. The following search will always find our
    ;; target..
    (while (dp-re-search-forward selector-pattern nil t)
      (when (or (not query-p)
                (y-or-n-p (format "Hump %s " (match-string 0))))
        (goto-char (match-beginning 0))
        (setq hump-end (dp-mk-marker(match-end 0)))
        (while (dp-re-search-forward "_\\(.\\)" hump-end t)
          ;; x_y --> xY
          (replace-match (upcase (match-string 1)))
          (when capitalize-p
            (save-excursion
              (capitalize-word))))))))

(defun* dp-c-classic-to-camel (&optional query-p (capitalize-p nil))
  "Very crudely convert classic vars (xx_yy) to camel case (xxYy).
Will miss many instances and do it in comments, too. "
  (interactive "P")
  (save-excursion
    (save-restriction
      (dp-narrow-to-region-or... :bounder 'rest-of-buffer-p)
      (goto-char(point-min))
      (dp-hump-region query-p nil capitalize-p))))

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
        (while (dp-re-search-forward "\\([a-z]\\)\\([A-Z]\\)" end t)
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
                "\\("
                "[a-zA-Z_][a-zA-Z_0-9]*_[tase]"
                "\\|"
                "\\(?:\\(?:struct\\|class\\)\\s-+[a-zA-Z_][a-zA-Z0-9_]*\\)"
                (if dp-c-type-list
                    (concat "\\|" (regexp-opt dp-c-type-list 'paren))
                  "")
                (if dp-c*-additional-type-list
                    (concat "\\|" (regexp-opt dp-c*-additional-type-list 'paren))
                  "")
                "\\)"
                "\\s-*"
                "\\)"
                "\\("
                "\\*"
                "\\s-*"
                "\\)"
                )))

(defun dp-c*-make-ugly-pointer-decl (post-func &rest post-func-args)
  "Convert proper code, to improper, eg: char* p --> char *p.
We say: \" p is a pointer to char\", not 
\"p is a variable which when dereferenced is a char.\""
  (interactive)
  (when (dp-looking-back-at (or dp-<type>*-regexp-memo
                                (dp-<type>*-regexp)))
    (replace-match "\\1")
    (apply post-func post-func-args)
    (insert "*")
;;      (when (looking-at " ")
;;        (delete-char))
      t))

(defun dp-c*-electric-space ()
  (interactive)
  (or (dp-c*-make-ugly-pointer-decl
       'insert " ")
      ;; Add other things to try here. We will stop after the first non-nil
      ;; return.
      (insert " ")))

(defun dp-c*-electric-tab ()
  (interactive)
  (or (dp-c*-make-ugly-pointer-decl
       'call-interactively 'c-indent-command)
      ;; Add other things to try here. We will stop after the first non-nil
      ;; return.
      (and-boundp dp-c-using-kernel-style-p
        (dp-kernel-style-var-name-align))
      ;; default.
      (c-indent-command)))

(defun dp-kernel-style-var-name-align ()
  (interactive)
  ;;@todo XXX Breaks if first tab takes us past the type...name indentation.
  (unless (dp-in-indentation-p)
    (let ((next-char (dp-get-char-previous-line))
          (did-something-p nil))
      ;; tab past the preceding variable type.
      (while (and (not (eq ?\n next-char))
                  (not (member
                        next-char
                        (list ?\ ?\t))))
        (insert ?\t)
        (setq next-char (dp-get-char-previous-line)
              did-something-p t))
      ;; tab past the preceding type... name indentation.
      (while (and (not (eq ?\n next-char))
                  (member
                   (dp-get-char-previous-line)
                   (list ?\ ?\t)))
        (dp-dupe-char-prev-line)
        (setq next-char (dp-get-char-previous-line)
              did-something-p t))
      did-something-p)))

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
                                           (lambda (s)  ; ensure stringiness.
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
    (dp-re-search-forward "@\\S-+\\s-+" end t)))

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

(defun dp-next-line-with-cleanup (count)
  "Add trailing white space removal functionality."
  (interactive "p")                     ;fsf need "_"
  (loop repeat count do
    (if (eolp)
        (dp-func-and-move-down 'dp-cleanup-line
                               t
                               'preserve-column
                               'next-line)
      (call-interactively 'next-line))))

(defun dp-c++-member-init ()
  "Lazy func. Convert the symbol at point to a C++ standardized initializer.
E.g. \"some_var\" --> \"m_some_var(some_var)\"."
  (interactive)
  (let ((symbol-name (symbol-near-point)))
    (c-simple-skip-symbol-backward)
    (insert "m_")
    (forward-char (length symbol-name))
    (insert "(" symbol-name ")")))

(defun dp-c-electric-colon (arg)
  (interactive "*P")
  (when arg
    (end-of-line))
  (c-electric-colon nil)
  (when (and (dp-syntax-c++-member-init-p)
             (dp-looking-back-at ":"))
    (insert " ")))

(defvar dp-arglist-syntax-list '(arglist-intro arglist-cont 
                                 arglist-cont-nonempty
                                 defun-block-intro
                                 topmost-intro topmost-intro-cont
                                 member-init-intro member-init-cont)
  "List of syntax regions that constitute an arg or decl list.
@todo XXX Do we want separate arg, param and decl lists?")

(defun* dp-c*-in-arglist-p (&key
                            syntax
                            c-syntax-ignore-list
                            class-only-p)
  (setq-ifnil syntax (dp-c-get-syntactic-region c-syntax-ignore-list))
  (save-excursion
    (beginning-of-line)
    (and (or (not class-only-p)
             (dp-c++-in-class-p))
         (dp-c-in-syntactic-region dp-arglist-syntax-list))))

(defun* dp-c*-goto-end-of-arglist (&key
                                   limit
                                   class-only-p)
  (setq-ifnil limit (point-max))
  (while (and (<= (point) limit)
              (dp-c*-in-arglist-p)
              (equal 0 (forward-line 1))))
  ;; If this is non-nil, then we aborted before we found the end.
  (let ((in-arglist-p (dp-c*-in-arglist-p)))
    (unless in-arglist-p
      (previous-line 1)
      (dp-c-end-of-line))
    in-arglist-p))

(defun* dp-c-ensure-opening-brace (&key
                                   ;; the following default has problems
                                   ;; whether nil or non-
                                   ;; Find the error CALLERS and set
                                   ;; appropriately.
                                   (newline-before-brace-p t)
                                   (block-keyword-p nil)
                                   (force-newline-after-brace-p nil)
                                   (ensure-newline-after-brace-p nil))
  "!<@todo XXX Add a force blank line after brace predicate.
I added the idea that this would return a valuing telling the caller if
anything was done to prevent double newlines. I need to determine when this
is the case.
Returns the `point' where things ended up.
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
  (let ((brace-finder "\\(\n\\|\\s-\\)*{"))
    (if block-keyword-p
        (goto-char (1+ (dp-c-find-stmt-closing-paren)))
      (dp-c*-goto-end-of-arglist))
    ;; Same line, possibly followed by eol junk.
    (if (looking-at brace-finder)
        (progn
          (goto-char (match-end 0))
          (end-of-line))
;;      (end-of-line)
;;      (call-interactively 'dp-c-electric-brace ?{)
      (when newline-before-brace-p
        (end-of-line)
        (newline-and-indent))
      (if (looking-at brace-finder)
          (progn
            (goto-char (match-end 0))
            (end-of-line))
	(insert " {")
        (newline-and-indent)
        (forward-line -1)
        (dp-c-fix-comment)
        (save-excursion
          (back-to-indentation)
          (dp-c-indent-command)))
      )
    (end-of-line)
    (if (or force-newline-after-brace-p
            (and ensure-newline-after-brace-p
                 (not (looking-at "\n"))))
        (c-newline-and-indent)
      (next-line 1))
    (unless (dp-blank-line-p)
      (beginning-of-line)
      (newline-and-indent)
      (previous-line 1))
    (dp-c-indent-command))
  (point))

(defun dp-c-beginning-of-current-token (&rest rrr)
  "Just insulation from `c-beginning-of-current-token'.
In short, if point is in a token then back up to beginning.
Otherwise, nothing."
  (apply 'c-beginning-of-current-token rrr)
  (dp-set-zmacs-region-stays t))

;;(defvar dp-protection-section-id-format 
;;  " ///////////////// <:%s%sdata:> /////////////////"
;;  "String to indicate the location of a class's data.")

(defun* dp-format-protection-section-id (&key name prot-level
                                         (start-col 4) (end-col)
                                         (section-desc "data"))
  ;; If end-col is nil, `dp-flanked-string' will use `current-fill-column'.
  
  (setq-ifnil start-col (current-column)
              end-col fill-column)
  ;; It would be better to specify things like "protected data" or 
  ;; "protected code" rather than a vague "protected section."
  (let* ((name (format "<:%s%s%s:>" name prot-level section-desc)))
    (dp-flanked-string name ?* :start start-col :end end-col
                       :prefix "/" :suffix "/")))

(defvar dp-protection-section-id-formatter 'dp-format-protection-section-id)

(defun* dp-c++-make-protection-section-id (&key 
                                           (prot-level 0) 
                                           (section-desc "data"))
  "Make a data section identifier for the current class."
  (interactive "p")
  (let ((name (if (dp-c-get-class-name)
                  (format "%s: " (cdr (dp-c-get-class-name)))
                "")))
    (if (functionp dp-protection-section-id-formatter)
        (funcall dp-protection-section-id-formatter 
                 :name name
                 :prot-level (concat (dp-prot-level-name prot-level) " ")
                 :section-desc section-desc)
      (format dp-protection-section-id-formatter name 
              (concat (dp-prot-level-name prot-level) " ") section-desc))))

(defvar dp-c++-default-data-protection "private")

(defvar dp-c++-class-protection-names '("private" "protected" "public")
  "In order of access.  Order must be maintained.")

(defun dp-prot-level-name (prot-level)
  (if (integerp prot-level)
      (nth (mod prot-level 
                (length dp-c++-class-protection-names))
           dp-c++-class-protection-names)
    prot-level))

(defun dp-prot-name-level (prot-name)
  (- (length dp-c++-class-protection-names)
   (length (member prot-name dp-c++-class-protection-names))))

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
  (when (and (dp-c++-in-class-p)
             (dp-c-looking-back-at-sans-eos-junk
              (concat "^\\s-*"
                      dp-c++-class-protection-level-regexp
                      "\\s-*")))
    (if (dp-class-protection-name-colon-p (match-string 0))
        ""
      ":")))

(defun dp-c++-class-protection-label (&optional skip-empty-lines)
  (when (dp-c++-class-protection-label-p)
   (match-string dp-c++-class-protection-label-match-string-index)))

(defun* dp-c++-comment-protection-section (&optional prompt-for-section-desc 
                                           &key
                                           (section-desc "data"))
  (interactive "P")                     ;fsf - need "_" support
  (when prompt-for-section-desc
    (let ((default-section-desc "data"))
      (setq section-desc (completing-read
                          (format "Section type (%s): " default-section-desc)
                          (dp-mk-completion-list '("data" "code"))
                          nil nil nil nil
                          default-section-desc))))
  (beginning-of-line)
  (when (looking-at "\\(\\s-*\\|\n\\)*\\(public\\|private\\|protected\\)\\(\\s-*:\\)?")
    (goto-char (match-beginning 2))
    (let* ((prot-label (match-string 2))
           (colon (match-string 3))
           (id (dp-c++-make-protection-section-id
                :prot-level (dp-prot-name-level prot-label)
                :section-desc section-desc)))
      (unless colon
        (forward-char (length prot-label))
        (insert ":"))
      (forward-line -1)
      (unless (looking-at (concat "^\\s-*" (regexp-quote id)))
        (unless (dp-blank-line-p)
          (dp-c-newline-and-indent 1))
        (insert " " id)
        (dp-c-indent-command))
      (forward-line 1)
      (Simple-forward-line-creating-newline)
      (if (dp-blank-line-p)
          (dp-c-indent-command)
        (forward-line -1)
        (dp-c-newline-and-indent 1)))))

;; May need to require being at the protection label to avoid many
;; annoying syntax searches.
(defun* dp-c++-mk-protection-section (&key
                                      (prot-level 
                                       dp-c++-default-data-protection)
                                      (section-desc "data")
                                      (prompt-for-section-desc nil)
                                      (indent-p t)
                                      (add-protection-label-p t)
                                      (stay-put-p nil)
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
                          (dp-mk-completion-list 
                           dp-c++-class-protection-names)
                          nil           ; predicate
                          t             ; require match
                          nil           ; initial contents
                          nil           ; history
                          dp-c++-default-data-protection)))))
  (when prompt-for-section-desc
    (let ((default-section-desc "data"))
      (setq section-desc (completing-read 
                          (format "Section type (%s): " default-section-desc)
                          (dp-mk-completion-list '("data" "code"))
                          nil nil nil nil
                          default-section-desc))))

  (if (not (dp-c++-goto-protection-section 
            :prot-level prot-level
            :section-desc section-desc
            :missing-ok-p 'missing-ok 
            :stay-put-p stay-put-p))
      (progn
        (dp-c-indent-command)
        (insert (dp-c++-make-protection-section-id 
                 :prot-level prot-level
                 :section-desc section-desc))
        (when indent-p
          (beginning-of-line)
          (insert " ") ; No indentation is done if comment is in the 1st col.
          (dp-c-indent-command)
          (dp-c-newline-and-indent 1))
        (when add-protection-label-p
          (let* ((limit (dp-mk-marker (save-excursion
                                        ;; So we don't do a go-back.
                                        (setq last-command nil)
                                        (dp-c-end-of-defun 1 (quote real-bof))
                                        (line-beginning-position))))
                 (anything-pos (save-excursion
                                 (when (dp-re-search-forward "[^ 	\n\r]" limit 
                                                          t)
                                   (line-beginning-position))))
                 (prot-level-pos (and anything-pos
                                      (save-excursion 
                                        (when (dp-re-search-forward 
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
            ;; WTF did I do this?(dp-open-newline t)
            (end-of-line)
            (newline-and-indent)
            (dp-c-indent-command)))
        (when show-help-p
          (message
           ;; default goes with [1] because that is the default argument.
           "prefix arg:  0|- --> private, 1 --> protected, 2 --> public (or none)")))
    ;; else
    ;; We're at end of comment line.
    (unless (looking-at (concat "\\s-*\n\\(^\\s-*\n\\)*\\s-*"
                                dp-c++-class-protection-level-regexp))
      (insert prot-level ":")
      (dp-c-indent-command)
      (dp-c-newline-and-indent))))


(defun* dp-c++-find-protection-section-id (&key prot-level 
                                           stay-put-p
                                           (section-desc "data"))
  (save-excursion
    ;; We need to get the sec-id before we goto the beginning of the function.
    (let ((sec-id (dp-c++-make-protection-section-id 
                   :prot-level prot-level
                   :section-desc section-desc))
          (bof (dp-c-beginning-of-defun-pos 1 'real-bof)))
      (when (if stay-put-p
                (search-backward sec-id bof t)
              (goto-char bof)
              (search-forward sec-id nil t))
        (forward-line 1)
        (point)))))

(defun* dp-c++-goto-protection-section (&key
                                        (prot-level 1)
                                        (section-desc "data")
                                        missing-ok-p
                                        stay-put-p)
  "Goto the current class's data section."
  (interactive "p")
  (let ((p (dp-c++-find-protection-section-id 
            :prot-level prot-level
            :section-desc section-desc
            :stay-put-p stay-put-p)))
    (if p
        (progn
          (dp-push-go-back "dp-c++-goto-protection-section")
          (goto-char p))
      (unless missing-ok-p
        (message "cannot find: %s" 
                 (dp-c++-make-protection-section-id 
                  :prot-level prot-level
                  :section-desc section-desc))
        (ding)
        nil))))

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

(defalias 'dp-c++-find-matching-paren 'dp-find-matching-paren-including-<)

(defvar dp-c-hard-coded-symbol-char0 "[a-zA-Z_]")
(defvar dp-c-hard-coded-symbol-char1... "[a-zA-z_0-9]")

(defvar dp-c-hard-coded-symbol-chars (concat dp-c-hard-coded-symbol-char0 
                                             dp-c-hard-coded-symbol-char1... 
                                             "*")
  "Chars making up a C-language-like symbol.")

(defvar dp-c-hard-coded-symbol-regexp 
  (concat "\\("
          "\\(^\\|\\(^" dp-c-hard-coded-symbol-char1... "\\)\\)"
          "\\(" dp-c-hard-coded-symbol-chars "\\)"
          "\\($\\|^" dp-c-hard-coded-symbol-char0 "\\)"
          "\\)")
  "Chars making up a C-language-like symbol.")

(defvar dp-c-symbol-regexp "\\(\\([^0-9]\\|^\\)\\(\\sw\\(\\sw\\|\\s_\\)*\\)\\)")

(defvar dp-c-add-comma-@-eol-of-regions 
  '(brace-list-entry 
    arglist-intro arglist-cont arglist-cont-nonempty
    member-init-intro member-init-cont 
    brace-list-intro brace-list-open brace-list-entry 
    statement-case-intro)
  "Syntax regions after which we may want to put a comma.")

(defun dp-c-statement-terminated-p ()
  (interactive)
  (save-excursion
    (dp-c-end-of-line)
    ;; Do we want to add "}"?
    (dp-looking-back-at ";")))
  
(defvar dp-c-statement-syntaxes '(statement)
  "C syntax regions that indicate we're in a statement")

;; Needed should be: in stream and ends w/o <<|>>
(defun* dp-stream-op-needed-p (&optional (anywhere-p nil))
  "Are we in an iostream statement? If so, return which kind \(<<|>>\).
NB! the caller expects that, if there is a match, then the matching op is in
\1 and the remainder in \2, such that a (replace-match \"\2\") effectively
deletes the op.
Non-nil ANYWHERE-P means to return the kind if a stream op is anywhere in the
statement so far.
Otherwise, only return the kind if the stream op is at EOS so far and just
terminate and eol/nl+indent."
  (interactive "P")
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

(defun* dp-in-c-iostream-statement-p (&optional (anywhere-p t))
  (save-excursion
    (beginning-of-line)
    ;; Sometimes, either I or cc-mode gets confuzed about iostream-ed-ness.
    (or (dp-stream-op-needed-p anywhere-p)
        (dp-c-in-syntactic-region '(stream-op)))))

(defun dp-in-c-statement ()
  "Are we in a C/C++ statement?"
  (interactive)
  (save-excursion
    (dp-c-beginning-of-statement)
    (dp-c-in-syntactic-region dp-c-statement-syntaxes)))

(defvar dp-c++-symbol-regexp-guts
  ;; No open paren of any kind
  "\\(%s\\s_\\|\\sw\\)*\\(%s::\\)?\\(%s\\s_\\|\\sw\\)+")

(defvar dp-c++-symbol-regexp (replace-regexp-in-string 
                              "%s" "" 
                              dp-c++-symbol-regexp-guts))

(defvar dp-c++-symbol-shy-regexp (replace-regexp-in-string
                                  "%s" "?:" dp-c++-symbol-regexp-guts 
                                  nil 'LITERAL))

(defun dp-c-find-stmt-closing-paren (&optional limit)  ; <:ctcp:>
  "LIMIT limits search for the OPENING paren whose closing paren we want."
  (interactive)
  (save-excursion
    (dp-c-beginning-of-statement)
    (when (search-forward "(" limit t)
      (goto-char (match-beginning 0))
      (condition-case appease-byte-compiler
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

(defvar dp-chars-which-cannot-follow-a-function-open-brace
  "[%]"
  "The name is pretty clear. The % is from mmm-mode's delimiters:
{%<mode-name>%}"
)

;; 
;; One nvidia style for constructors is to have *leading* commas in the
;; initializer list. I can actually see some usefulness, especially when
;; having to delete the last, unused, comma.
;; 
;; This can be contolled crudely by putting the member init syntax symbols in
;; the eol list (trailing commas) or the bol list (leading)
;; XXX @todo Needs to be conditionalized better.
;;

(defvar dp-c-member-init-leading-commas t
  "One nvidia style for constructors is to have *leading* commas in the
  initializer list. I can actually see some usefulness, especially when
  having to delete the last, unused, comma.")

(defvar dp-c-add-comma-@-bol-of-regions 
  '(member-init-intro member-init-cont)
  "Syntax regions before which we may want to put a comma.")

(defun dp-c-context-line-break ()
  "Do special things at the end of a line."
  (interactive "*")
  (let ((syntactic-region 
         (dp-c-get-syntactic-region)))
    (if (and (dp-c-in-syntactic-region dp-c-add-comma-@-eol-of-regions)
             (looking-at "\\s-*$")
             (save-excursion
               (not (dp-looking-back-at "[-,:\\&;+=|.!@#$%^*(_/?]\\s-*"))))
        (dp-open-newline)
      (call-interactively 'c-context-line-break)
      (if (and (member syntactic-region dp-c-add-comma-@-bol-of-regions)
               (dp-looking-back-at "^\\s-*"))
          (insert ",")))))

(defun dp-c-mark-current-token ()
  (interactive)                         ; restore "_" functionality--fsf
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
NB: You must count any parenthesized groups in your regexp when using 
functions like ???")

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

(defun dp-c-beginning-of-statement (&optional count)
  "`c-beginning-of-statement' can leave us in previous cpp code. Move out of it.
Also, it will move backwards into a closed class (ie has a };)."
  (interactive "p")
  (if (dp-in-cpp-construct-p)
      ;; If we are already on a cpp line, then don't move off of it.
      (beginning-of-line)
    (let ((class-state (dp-c++-in-class-p))
          (pos (point)))
      (call-interactively 'c-beginning-of-statement)
      (cond 
       ((not (eq class-state (dp-c++-in-class-p) ))
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
    (if (dp-re-search-forward (concat ".*?\\(" dp-c*-junk-after-eos* "\\)$")
                           (line-end-position) t)
        (goto-char (match-beginning 1))
      (end-of-line))))

(defun* dp-c-terminate-function-stmt (&optional ; <:ctf|cfts:>
                                      (trailer-string ""))
  "Terminate a function statement by adding a ; after the C* text.
Preserve any junk past the end of the C* code, e.g. // comments.  Insert
trailer-string after everything. This make a good cheap place to add a
newline."
  (interactive)
  (save-excursion
    (dp-c-beginning-of-statement)
    (when (looking-at dp-c*-keywords-needing-parens)
      (return-from dp-c-terminate-function-stmt)))
  (dp-c-end-of-line)
  ;;;; This helps with multi-line statements, but sucks otherwise.
  ;;;; (c-end-of-statement) 
  (when (dp-looking-back-at-close-paren-p 'final)
    (replace-match (format "\\1;%s%s" ; 1st %s: The ) and other eol-junk above
                           (if (> (length (match-string (1+ dp-c*-junk-ws))) 1)
                               (substring (match-string (1+ dp-c*-junk-ws)) 1)
                             "\\2")
                           trailer-string))
    t)                        ; We still need to do the eol/newline thing.
  )
  
(defun dp-c-finish-function ()
  (interactive)
  (dp-open-newline)
  (insert "NOT_WRITTEN_YET();      //!<@todo Finish this!"))
(defalias 'ffun 'dp-c-finish-function)

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
    (when (dp-in-c)
      (setq-ifnil c-syntax (dp-c-get-syntactic-region c-syntax-ignore-list))
      ;; Need to reconcile differences twixt versions of cc-mode.
      (or ;; (memq (buffer-syntactic-context) '(comment block-comment))
          (memq c-syntax dp-c-comment-syntax-list)
          (c-got-face-at (point) '(font-lock-comment-face))
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
              (when (looking-at "[ \t]*\\*/[ \t]*$")
                (kill-line))
              (when dp-c-electric-slash-fills
                (save-excursion
                  (beginning-of-line)
                  (c-fill-paragraph)))
	      (newline-and-indent))
	  (c-electric-slash arg)))
    (c-electric-slash arg)))

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

(defvar dp-c-function-type-decl-re
    (concat
     "\\(?:"
     "\\s-*"
     "\\<"
     ;;   "\\(?:\\(?:static\\|virtual\\|explicit\\)\\<\\S_+\\)?"
     "\\(?:"
     "\\(?:\\(?:static\\|virtual\\|explicit\\)\\>\\)"
     "\\|"
     "\\(?:struct\\|class\\)\\s-+[a-zA-Z_][a-zA-Z0-9_]*"
     "\\|"
     (regexp-opt dp-c-type-list 'paren)
     "\\|"
     "\\(?:\\sw\\|\\s_\\)+_[tase]"
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

(defun dp-c-namify-region (beg end &optional say-dot)
  "Convert region to legitimate C identifier."
  (interactive "*r")
  (if (> beg end)
      (let ((tmp end))
	(setq end beg
	      beg tmp)))
  (goto-char beg)
  (when say-dot
    (while (dp-re-search-forward "[.]" end t)
      (replace-match "_DOT_"))
      (goto-char beg))
  (while (dp-re-search-forward "[^a-zA-Z0-9_\n]" end t)
    (replace-match "_")))

(defun* dp-c-namify-string (string &optional (repl-str "_"))
  (replace-regexp-in-string 
   "[^0-9A-Za-z_]"
   repl-str
   (replace-regexp-in-string "^[0-9]" repl-str string)))

(defun* dp-dot-h-reinclusion-protection (dont-comment-endif-p
                                         &key
                                         (comment t)
                                         (prefix "")
                                         (suffix "_INCLUDED")
                                         (format-str "%s%s%s")
                                         formatter)
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
  (let (old-pos)
    (save-restriction
      (if (dp-mark-active-p)
	  (narrow-to-region (point) (mark)))
      (let* ((comment-endif-p (not dont-comment-endif-p))
             (filename (upcase (file-relative-name (buffer-file-name))))
	     (def-name (if formatter
                           (funcall formatter (buffer-file-name) prefix suffix)
                         (format format-str prefix filename suffix)))
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
	      (if (and comment comment-endif-p)
                  (concat " /* #ifndef "
                          (buffer-substring (point) (line-end-position))
                          " Reinclusion protection."
                          " */")
                ""))
	(insert "#ifndef ")
        (end-of-line)
        (when comment
          (insert " /* Reinclusion protection. */"))
	(forward-line 1)
	;;(beginning-of-line) ; not needed w/forward-line
	(insert "#define ")
        (end-of-line)
        (when comment
          (insert " /* Reinclusion protection. */"))
	(goto-char (point-max))
        (setq old-pos (dp-mk-marker))
	(insert "\n#endif" comment-text "\n")))
    (goto-char old-pos)
    (forward-line -1))
  (dmessage "@todo: Delete any existing ifdef lines first."))
(dp-safe-alias 'idef 'dp-dot-h-reinclusion-protection)

(defun dp-insert-fc (fc-file)
  "Read a function comment header block after point.
XXX: use tempo for this?"
  (interactive "*")
  (beginning-of-line)
  (insert-file fc-file)
  ;; goto cursor position if specified...
  (when (dp-re-search-forward "<cursor>" nil t)
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
	   (dp-c++-in-class-p))
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
  (when (dp-re-search-forward "<cursor>" nil t)
    (replace-match "" nil nil)
    (message "done")))

(defvar dp-c-stupid-indent-p nil
  "I used to like the associated indentation style, but now it bugs me.")

(defun dp-c-indent-command ()
  "Indent region if active, otherwise indent if in indentation space, otherwise tabdent."
  (interactive "*")
  (if (dp-mark-active-p)
      (if (and-boundp 'dp-c-indent-region-line-by-line
            dp-c-indent-region-line-by-line)
          (dp-indent-region-line-by-line (mark) (point) 'c-indent-line)
        (let ((ordered (dp-region-boundaries-ordered)))
          (setq beg (dp-mk-marker (car ordered))
                end (dp-mk-marker (cdr ordered)))
          (c-indent-region beg end)))
    (if (not dp-c-stupid-indent-p)
        (c-indent-command)
      (if (and dp-c-stupid-indent-p
               (not c-tab-always-indent))
          ;; try to make the indenter smarter.  I like using TAB to space out
          ;; vars from types, e.g. int  x;
          ;; but it's a pain to indent a line properly.
          ;; this tries to do an indent if on non-space and tab over if 
          ;; over a space.  But there are times when this is wrong, so I
          ;; punt for now.
          (if (or (not (dp-isa-type-line-p))
                  (dp-in-indentation-p))
              (c-indent-line)           ; simple indentation
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

(defun dp-c-add-data-comment ()
  (interactive "*")
  (dp-insert-for-comment+ "<:data:>"))
(defalias 'data 'dp-c-add-data-comment)

(defsubst dp-syntax-c++-member-init-p (&optional syntax)
  (memq (or syntax (dp-c-get-syntactic-region))
        '(member-init-intro member-init-cont)))

(defun dp-c-electric-brace (reindent-p)
  "Insert a brace \"intelligently.\"  
By this I mean if I put a brace in the ``proper'' place (on a line by
itself, under the keyword) move to K&R's incorrect place (after the
control construct)"
  (interactive "*P")
  (if (c-in-literal)               ;(dp-in-a-string)
      (insert "{")
    (let ((syntax (dp-c-get-syntactic-region))
          (extra "")
          here
          mbeg
          mend)
      
      ;; If we're in a C++ member init section and we're using the funky (but
      ;; kind of nice) leading , style, then we clear out the , and then
      ;; proceed .
      (when (and (dp-syntax-c++-member-init-p syntax)
                 (dp-looking-back-at "^\\s-*,\\s-*"))
        (replace-match ""))
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
               (= (dp-last-command-char) ?\{)
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
            (dp-c-newline-and-indent 1))
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
  (setq (dp-last-command-char) ?\})
  (call-interactively 'c-electric-brace))

(defun dp-delimit-func-args (&optional prefix suffix)
  "Return list (useful for `apply'ing) of positions of open and close parens."
  (interactive)
  (save-excursion
    (end-of-line)
    (dp-c-beginning-of-statement)
    (if prefix (insert prefix))
    (let (point mark)
      (if (dp-re-search-forward "(" nil t)
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
    (if (dp-re-search-forward "(" nil t)
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
  (dp-mk-protos arg (if (dp-c++-in-class-p) nil "extern")))
(defalias 'dpp 'dp-mk-extern-proto)

(defun dp-mk-ecos-proto (arg)
  (interactive "*p")
  ;; used by eCOS, extern a function w/C linkage
  (dp-mk-protos arg "externC"))
(defalias 'dppc 'dp-mk-ecos-proto)

(defun dp-c-semi&comma-nada ()
  "Suppress ALL ;-instigated new-linery.
I like the other things (e.g. cleanups) that are available in auto-newline
mode but not the new lines themselves.  Hence, this."
  (interactive)
  (if (eq (last-command-char ?\;))
      'stop
    ;; not a semi, keep trying.
    nil))

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

(defun* dp-c-stack-statement (&key split-at-regexp repl 
                              before-p after-first-p
                              beg end
                              minimal-indentation-p)
  "Split statement at split-at-regexp, before regexp else before if before-p non nil.
BEFORE-P says to split like we do in a c-tor initialization list, 
with commas first:
C::C(
  int a,
  char* b,
  : m_a(a)
  , m_b(b)
{}
This makes it much easier to add and remove initializers.
MINIMAL-INDENTATION-P says to use minimal indentation per line; it's not the
best term, but so it goes. It acts thus:
afunction(a, b, c)
becomes:
afunction(
    a, 
    b, 
    c);
The indentation is minimal, but nothing in the name implies that there is one
arg per line, although that is implied by the name of the function.
"
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
      (when after-first-p
          (dp-re-search-forward-not-in-a-string split-at-regexp end t))
      ;; @todo XXX We should add a regexp used to find where we want to do
      ;; the initial split. For example, a funcall needs a "(" an io-stream
      ;; would use a space, e.g cout -!-<<
      (when (and minimal-indentation-p
                 (dp-re-search-forward-not-in-a-string "(" end t))
        (dp-c-newline-and-indent))
      (while (dp-re-search-forward-not-in-a-string split-at-regexp end t)
        (save-excursion
          (replace-match repl)
          (beginning-of-line)
          (dp-c-indent-command)))
      (list beg end))))
(defalias 'css 'dp-c-stack-statement)

(defun dp-c-stack-rest-of-statement (&optional end beg)
  (interactive)
  (dp-c-stack-statement
   :beg (or beg (point))
   :end (or end (save-excursion
                  (c-end-of-statement)
                  (point)))))

(defun dp-c-stack-iostream (&optional minimal-indentation-p)
  (interactive "*P")
  (dp-c-stack-statement 
   :split-at-regexp "\\s-*\\(<<\\|>>\\)\\s-*" 
   :repl "\\1 " 
   :before-p 'before 
   :after-first-p 'after-first
   :minimal-indentation-p minimal-indentation-p))

(defalias 'csi 'dp-c-stack-iostream)

(defvar dp-c-fill-statement-minimal-indentation-p t
  "Stack statements:
g()
{
    some_function_i_need_to_call(
        int a,
        int b);
}"
)

(defun* dp-c-fill-statement (&optional 
                             max-line-len 
                             rest-of-statement 
                             beg 
                             end 
                             (minimal-indentation-p 
                              dp-c-fill-statement-minimal-indentation-p))
  (interactive)
  (dmessage "HANDLE spaces after opening (")
  (save-excursion
    (unless rest-of-statement
      (end-of-line)
      (dp-c-beginning-of-statement))
    (let* ((beg-end (if (dp-re-search-forward "<<\\|>>" (line-end-position) t)
                        (dp-c-stack-iostream)
                      (if rest-of-statement
                          (dp-c-stack-rest-of-statement)
                        (dp-c-stack-statement 
                         :beg beg 
                         :end end
                         :minimal-indentation-p minimal-indentation-p))))
           (end (dp-mk-marker (car (cdr beg-end))))
           (max-line-len (1- (dp-c-fill-column max-line-len))))
      (unless minimal-indentation-p
        ;; Pack things into maximally filled lines.
        (while (< (line-end-position) end)
          (join-line)
          (unless (<= (- (line-end-position) (line-beginning-position))
                      max-line-len)
            (c-context-line-break)))))))

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
      (unless (dp-re-search-forward "(" nil t)
        (dp-ding-and-message "No opening paren in `dp-c-delimit-func-decl'.")
        (return-from dp-c-delimit-func-decl))
      ;; See if we moved into a different statement.
      (unless (= (dp-c-beginning-of-statement-pos) beg)
        (dp-ding-and-message "Problem finding beginning of statement.")
        (return-from dp-c-delimit-func-decl))
      (backward-char 1)
      (if (dp-find-matching-paren-including-< t)
          (progn
            ;; `dp-find-matching-paren-including-<' returns non-nil if it
            ;; finds a matching paren.
            ;; XXX !!! oddness!!! If (at least) COB calls this and
            ;; `dp-find-matching-paren-including-<' fails, something does an
            ;; UNDO operation.
        (setq end (point))
        (cons (if use-markers-p
                  (dp-mk-marker beg)
                beg)
              (if use-markers-p
                  (dp-mk-marker end)
                end)))
        (dp-ding-and-message "Cannot find closing parenthesis.")
        nil))))

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

(defun dp-c*-delimit-template-construct ()
  "Delimit a template<a b> construct. \(point\) is @ t in template."
  (save-excursion
    (let ((beg (point))
          end)
      (when (search-forward "<" nil t)
        (goto-char (match-beginning 0))
        (dp-find-matching-paren)
        (forward-char 1)
        (cons beg (point))))))

(defun dp-c*-break-after-template ()
  (when (looking-at "template")
    (let ((limits (dp-c*-delimit-template-construct)))
      (when limits
        (goto-char (cdr limits))
        (insert "\n")
        (dp-c-indent-command)
        limits))))

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
        is-decl-p
        pos-after-ensured-brace
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
    ;; Is this a declaration?
    ;; extern is one way to tell.
    (when (looking-at "extern")
      (unless (eq add-opening-brace-p 'always)
        (setq add-opening-brace-p nil
              is-decl-p t)))
    ;;(unless (or (equal syntactic-region (dp-c-get-syntactic-region))
    ;;            (<= (point) old-point))
    ;;  (goto-char old-point)
    ;;  (return-from dp-c-format-func-decl nil))
    (beginning-of-line)
    (setq decl-bounds (dp-c-flatten-func-decl))
    ;; Handle template <xxx>
    (when (looking-at "template")
      (dp-c*-break-after-template))
    ;; Or skip past any member init before looking for {.
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
            ;; Leave ourselves positioned for the ) check which allows us
            ;; to add an opening { if needed.
            (goto-char e)
            (beginning-of-line))
        (while (dp-re-search-forward ",\\|\\([^:]\\)\\(:\\)\\([^:].*,\\)"
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
                 (dp-re-search-forward ")" (line-end-position) t))
        (setq pos-after-ensured-brace
              (dp-c-ensure-opening-brace :force-newline-after-brace-p nil))))
    (goto-char open-paren-marker)
    ;; Put function name on a line by itself after any preceding type, etc,
    ;; info.
    (when (and type-on-separate-line-p
               (re-search-backward "\\(\\S-+\\)\\s-+"
                                   (line-beginning-position) t))
      (replace-match "\\1\n")
      (c-indent-line))
    (beginning-of-line)
    (when (and (dp-c++-in-class-p)
               (dp-re-search-forward (format "%s::" (symbol-near-point))
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
    (when is-decl-p
      ;; Terminate the statement.
      (dp-c-terminate-function-stmt "\n")
      (return-from dp-c-format-func-decl t))
    ;; Why did I want to do this twice?
    ;; Let's find out what breaks...
    ;; --> we get stuck on the opening brace.
    (when add-opening-brace-p
      (if pos-after-ensured-brace
          (goto-char pos-after-ensured-brace)
        (dp-c-ensure-opening-brace :ensure-newline-after-brace-p nil)))
    (when align-p
      (align (car decl-bounds) (1+ (cdr decl-bounds)))))
  ;; Unless we know we did nothing, assume we did something.
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
    (while (not (dp-re-search-forward ")\\s-*\\([;]\\)\\s-*$\\|{" ;??? Only ; ???
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

(defun dp-c-whattam-I-in()
  "Tell me what class/function/etc that I'm in."
  (interactive)
  (save-excursion
    (call-interactively 'dp-c-beginning-of-defun)
    (let ((region (dp-line-boundaries 'text-only)))
    (message (buffer-substring (car region) (cdr region))))))


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

(defun* dp-c*-pure-comment-line-p (&optional (start (line-beginning-position)))
  "Return non-nil if there is nothing on the current line but a comment."
  (interactive)
  (save-match-data
    (save-excursion
      (goto-char start)
      (or (dp-re-search-forward "^\\s-*//" (line-end-position) t)
          ;; Cheesy!
          (progn
            (goto-char start)
            ;; We were getting non-nil on empty lines.
            (when (dp-in-a-c*-comment)
              (loop repeat (- (line-end-position) start)
                always (dp-in-a-c*-comment)
                do (forward-char 1))))))))

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

(defun dp-map-context-to-doxy-cmd ()
  "Map the current cc-mode syntax to a doxygen command."
  (or (cdr (assoc (dp-c-get-syntactic-region)
                  dp-doxy-syntax-map))
      ;; make a guess based on text on the line
      (save-excursion
        (beginning-of-line)
        (dp-isa-type-p))))

(defun dp-c*-pure-type-line ()
  (save-excursion
    (dp-c-end-of-line)
    (dp-looking-back-at (concat "^\\s-*"
                                dp-c-function-type-decl-re 
                                "\\s-*"))))

;;;
(provide 'dp-lang-c-like)
