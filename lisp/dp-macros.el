(message "dp-macros.el loading...")

(defvar dp-macros-obarray (make-vector 32 0)
  "We intern generated symbol names used in macros here.")

(defun* dp-macros-gentemp (&optional (prefix "dp-macros-gentemp-"))
  (dp-gentemp prefix dp-macros-obarray))

(defun dp-put-pv-list (var-sym pv-list)
  "Put the prop/vals in plist PV-LIST into VAR-SYM's plist."
  (loop for (p v) in pv-list
    do (put var-sym p v)))

(defun dp-aboundp (symbol newdef)
  (and (functionp symbol) 
       (fboundp newdef)))

(defun dp-alias-eq (symbol newdef)
  (and (fboundp symbol)
       (eq (symbol-function symbol) newdef)))
  

(defvar dp-unsafe-alias-is-fatal-p nil
  "Should a previously defined alias be considered an error or warning?")

(eval-when-compile
;;fsf;;  (load "bytecomp-runtime")

  (defmacro dp-activate-mark ()
    ())

  (defmacro kb-lambda (docstring &rest body)
    "Define a lambda suitable for binding to a key.
Defines an interactive lambda taking 1 optional arg."
    (unless (stringp docstring)
      (setq body (cons docstring body)
            docstring ""))
    ;; An &rest would be best, but then getting at the args'd be a PITA.
    `(lambda (&optional arg arg1 arg2 arg3 arg4 arg5)
       ,docstring
       (interactive "P")
       ,@body))
  (put 'kb-lambda 'lisp-indent-function lisp-body-indent)

  (defmacro kb-lambda-rest (docstring &rest body)
    "Define a lambda suitable for binding to a key.
Defines an interactive lambda taking 1 optional arg."
    (unless (stringp docstring)
      (setq body (cons docstring body)
            docstring ""))
    ;; An &rest would be best, but then getting at the args'd be a PITA.
    ;; Really?  Even with `nth'?
    `(lambda (&rest args)
       ,docstring
       (interactive "P")
       ,@body))
  (put 'kb-lambda-rest 'lisp-indent-function lisp-body-indent)

  (defmacro kb-lambda-new (docstring &rest body)
    "Define a lambda suitable for binding to a key.
Defines an interactive lambda taking 5 optional args.
If DOCSTRING is a cons, then the car holds a string that consists of flags to
`interactive' and the cdr is the docstring."
    (let ((interactive-flags ""))
      (when (and (consp docstring)
                 (not (true-list-p docstring)))
        (psetq docstring (cdr docstring)
               interactive-flags (car docstring)))
      (unless (stringp docstring)
        (setq body (cons docstring body)
              docstring ""))
      ;; an &rest would be best, but then getting at the args'd be a PITA.
      `(lambda (&optional arg arg1 arg2 arg3 arg4 arg5)
         ,docstring
         (interactive ,(format "%sP" interactive-flags))
         ,@body)))
  (put 'kb-lambda-new 'lisp-indent-function lisp-body-indent)

  (defmacro kb-warning (docstring &optional message)
    (unless message
      (setq message docstring
            docstring "Attach a warning message to a key binding."))
    `(kb-lambda 
      ,docstring
      (error "kb-warning: %s" ,message)))

  (defmacro dp-defvar-sym (name init-val &optional docstring)
    (setq docstring (or (eval docstring) "dp-defvar-sym"))
    `(defvar ,(eval name) ,init-val ,docstring))
  (put 'dp-defvar-sym 'lisp-indent-function lisp-body-indent)

;   (defmacro dp-save-n-set-var (var-name var-new-val &optional docstring)
;     (let ((docstring (or docstring
;                          (format "Original value of `%s'." var-name))))
;       (list 'progn
;             (list 'defvar (dp-ify-symbol var-name)
;                   `(and (boundp (quote ,var-name)) ,var-name) docstring)
;             (list 'setq var-name var-new-val))))
;   (put 'dp-save-n-set-var 'lisp-indent-function lisp-body-indent)


  (defmacro dp-sel2:with-target-buffer (&rest forms)
    `(save-excursion
      (let ((point (or (dp-sel2:target-position) (point))))
        (set-buffer (dp-sel2:target-buffer))
        (goto-char point)
        ,@forms)))
  (put 'dp-sel2:with-target-buffer 'lisp-indent-function lisp-body-indent)

  (defmacro with-narrow-to-region (beg end &rest body)
    "Execute BODY after doing a `narrow-to-region' over BEG END."
    `(progn
      (save-restriction
        (narrow-to-region ,beg ,end)
        ,@body)))
  (put 'with-narrow-to-region 'lisp-indent-function 2)

  (defmacro with-narrow-to-region-when (pred-form beg end &rest body)
    "Execute BODY after doing a `narrow-to-region' over BEG END."
    `(progn
      (if (eval ,pred-form)
          (with-narrow-to-region ,beg ,end
            ,@body)
        ,@body)))
  (put 'with-narrow-to-region-when 'lisp-indent-function 2)

  (defmacro dp-conditionally-save-excursion (pred &rest body)
    "`save-excursion' if PRED is non-nil.
Otherwise, after the `save-excursion' completes, go to the `point-marker' where
the `save-excursion' ended up."
    `(let ((point (save-excursion
                    ,@body
                    (dp-mk-marker)))) 
      (unless (dp-callable-pred ,pred)
        (goto-char point))))
  (put 'dp-conditionally-save-excursion 'lisp-indent-function 1)

;   (defmacro dp-safe-alias (symbol newdef &optional fatal-p)
;     "Make sure this alias doesn't clobber/shadow something else."
;     `(if (or (and (functionp ,newdef) (fboundp ,symbol)))
;       (funcall (if ,fatal-p 'error 'warn)
;                "dp-safe-alias: %ssymbol: %s is already bound to %s."
;                (if (functionp ,newdef) "function " "")
;                ,symbol ,newdef)
;       (defalias ,symbol ,newdef)))

;;   (defmacro* dp-safe-alias (symbol newdef 
;;                             &optional (fatal-p 
;;                                        (quote dp-unsafe-alias-is-fatal-p)))
;;     "Make sure this alias doesn't clobber/shadow something else.
;; !<@todo Make this smart enough to not complain (or to complain quietly and
;; let the definition succeed) if it was defined by this routine."
;;     `(if (dp-aboundp ,symbol ,newdef)
;;       (funcall (if ,fatal-p 'error 'warn)
;;                "dp-safe-alias: %ssymbol: `%s' is already fbound to `%s'."
;;                (if (functionp ,newdef) "function " "")
;;                ,symbol ,newdef)
;;       (defalias ,symbol ,newdef)
;;       (put ,symbol 'dp-safe-alias t)))
;;   (put 'dp-safe-alias 'lisp-indent-function 1)

  (defvar dp-safe-alias-not-fatal-if-interactive-p t
    "What's in a name?  Documentation.")
  
  (defmacro* dp-safe-alias (symbol newdef 
                            &optional (fatal-p 
                                       (quote dp-unsafe-alias-is-fatal-p)))
    "Make sure this alias doesn't clobber/shadow something else.
However if we are `interactive-p' and
`dp-safe-alias-not-fatal-if-interactive-p' is non-nil, then it's OK. "
    `(if (fboundp ,symbol)
      (if (get ,symbol 'dp-safe-alias-p)
          (if (dp-alias-eq ,symbol ,newdef)
              (dmessage "dp-safe-alias: Identical redefinition of %s."
                        ,symbol)
            (dmessage-ding
             "dp-safe-alias: Allowing redefinition of %s from %s to %s" 
             ,symbol (symbol-function ,symbol ),newdef)
            (defalias ,symbol ,newdef))
        (funcall (if ,fatal-p 'error 'warn)
                 "dp-safe-alias: DENIED! %ssymbol: `%s' is already fbound to `%s'."
                 (if (functionp ,newdef) "function " "")
                 ,symbol ,newdef))
      (defalias ,symbol ,newdef)
      (put ,symbol 'dp-safe-alias-p t)))

  (defmacro dp-with-all-output-to-string (&rest forms)
    "Collect output to `standard-output' while evaluating FORMS and return
it as a string."
    ;; by "William G. Dubuque" <wgd@zurich.ai.mit.edu> w/ mods from Stig
    `(with-current-buffer (get-buffer-create
                           (generate-new-buffer-name 
                            " *dp-with-all-output-to-string*"))
      (dp-toggle-read-only 0)
      (buffer-disable-undo (current-buffer))
      (dp-erase-buffer)
      (unwind-protect
          (progn
            (let ((standard-output (current-buffer)))
              ,@forms)
            (buffer-string))
        (set-buffer-modified-p nil)
        (kill-this-buffer))))

  (defmacro dp-defcustom-local (symbol value docstring &rest args)
    "Define a custom variable and make it buffer local."
    (if (stringp docstring)
        (setq docstring (format "%s\n(buffer-local)" docstring))
      (setq args (cons docstring args)
            docstring "(buffer-local)"))
    `(progn 
      (defcustom ,symbol ,value ,docstring ,@args)
      (make-variable-buffer-local ',symbol)
      ;; @todo XXX Should we predicate this on interactive evaluation?
      ;; @todo Is a custom value `defconst' or `defvar'?
      (unless custom-dont-initialize
	(setq-default ,symbol ,value))))
  (put 'dp-defcustom-local 'lisp-indent-function lisp-body-indent)

  (defmacro dp-deflocal (name init-val &optional docstring)
    "Define a variable and make it buffer local."
    (setq docstring
          (if docstring
              (setq docstring (format "%s\n(dp-deflocal)" docstring))
            "Undocumented. (dp-deflocal)"))
    `(progn
      (defvar ,name ,init-val ,docstring)
      (make-variable-buffer-local ',name)
      (setq-default ,name ,init-val)))
  (put 'dp-deflocal 'lisp-indent-function lisp-body-indent)

  (defmacro dp-deflocal-permanent (name init-val &optional docstring)
    "Define a variable and make it buffer local and permanent."
    (setq docstring
          (if docstring
              (setq docstring (format "%s\n(permanent-local)" docstring))
            "(permanent-local"))
    `(progn
      (dp-deflocal ,name ,init-val ,docstring)
      (put ',name 'permanent-local t)))
  (put 'dp-deflocal-permanent 'lisp-indent-function lisp-body-indent)

  (defmacro setq-ifnil (&rest arglist)
    "Setup default values for args which are nil."
    (if (not (= 0 (mod (length arglist) 2)))
        (error "setq-ifnil: arglist len must be a multiple of 2."))
    (let (arg init-val result)
      (while arglist
        (setq arg (car arglist)
              arglist (cdr arglist)
              init-val (car arglist)
              arglist (cdr arglist))
        (setq new-elem `(if ,arg ,arg (setq ,arg ,init-val)))
        (setq result (cons new-elem result)))
      (cons 'progn (reverse result))))
;;(put 'setq-ifnil 'lisp-indent-function 0)  ; setq uses no special indent
  (defalias 'setq-unless 'setq-ifnil)

  (defmacro setq-if-unbound (&rest arglist)
    "Setup default values for args which are nil."
    (if (not (= 0 (mod (length arglist) 2)))
        (error "setq-ifnil: arglist len must be a multiple of 2."))
    (let (arg init-val result)
      (while arglist
        (setq arg (car arglist)
              arglist (cdr arglist)
              init-val (car arglist)
              arglist (cdr arglist))
        (setq new-elem `(if (boundp (quote ,arg))
                         ,arg 
                         (setq ,arg ,init-val)))
        (setq result (cons new-elem result)))
      (cons 'progn (reverse result))))
  
  ;;!<@todo Be there common code twixt this and -ifnil? 
  (defmacro setq-ifnil-or-unbound (&rest arglist)
    "Setup default values for args which are nil or unbound."
    (if (not (= 0 (mod (length arglist) 2)))
        (error "setq-ifnil: arglist len must be a multiple of 2."))
    (let (arg init-val result)
      (while arglist
        (setq arg (car arglist)
              arglist (cdr arglist)
              init-val (car arglist)
              arglist (cdr arglist))
        (setq new-elem `(if (and-boundp (quote ,arg) ,arg) 
                         ,arg (setq arg ,init-val)))
        (setq result (cons new-elem result)))
      (cons 'progn (reverse result))))


  (defmacro dp-defaliases0 (def-type &rest symbols-followed-by-newdef)
    "Define a list of aliases. SYMBOLS-FOLLOWED-BY-NEWDEF ends with 'newdef.
SYMBOLS-FOLLOWED-BY-NEWDEF is an &rest list: SYMB0 SYMB1... NEWDEF.
Ie, NEWDEF is \(last symbol-followed-by-newdefs).
Emits a series of defaliases:
\(defalias SYMB0 NEWDEF)
\(defalias SYMB1 NEWDEF)
\(defalias SYMBn NEWDEF)
NEWDEF is last to match the order of args to `defalias'."
    (unless (>= (length symbols-followed-by-newdef) 2)
      (error "dp-defaliases: requires 2 or more args."))
    (let ((newdef (car (last symbols-followed-by-newdef)))
          (symbols-followed-by-newdef (butlast symbols-followed-by-newdef))
          arg init-val bunch-of-defalias-calls)
      (while symbols-followed-by-newdef
        (setq arg (car symbols-followed-by-newdef)
              symbols-followed-by-newdef (cdr symbols-followed-by-newdef))
        (setq new-elem `(,def-type ,arg ,newdef))
        (setq bunch-of-defalias-calls (cons new-elem bunch-of-defalias-calls)))
      (cons 'progn (reverse bunch-of-defalias-calls))))
  (put 'dp-defaliases0 'lisp-indent-function
       (get 'defalias 'lisp-indent-function))


  (defmacro dp-defaliases (&rest symbols-followed-by-newdef)
    `(dp-defaliases0 defalias ,@symbols-followed-by-newdef))
  (put 'dp-defaliases 'lisp-indent-function
       (get 'defalias 'lisp-indent-function))

  (defmacro dp-safe-aliases (&rest symbols-followed-by-newdef)
    `(dp-defaliases0 dp-safe-alias ,@symbols-followed-by-newdef))
  (put 'dp-safe-aliases 'lisp-indent-function
       (get 'defalias 'lisp-indent-function))

  (defmacro dp-callable0 (vsym)
    `(and
      ;;    (symbolp ',vsym)
      ;;    (symbolp ,vsym)
      (or (and (fboundp ',vsym)
               (functionp ',vsym)
               (symbol-function ',vsym))
          (and (boundp ',vsym)
               (functionp ,vsym)
               (symbol-function ,vsym))
          (and (boundp ',vsym)
               (fboundp ,vsym)
               (symbol-function ,vsym)))))

  (defmacro dp-callable (vsym)
    `(let ((x (dp-callable0 ,vsym)))
      (when x
        (while (symbolp x)
          (setq x (symbol-function x))))
      x))

  (defmacro if-and-boundp (var then &rest else)
    "If VAR is `boundp' and non-nil do THEN else do ELSE. See `if' for details.
VAR must be a symbol."
    `(if (and-boundp ,var (symbol-value ,var))
      ,then
      ,@else))
  (put 'if-and-boundp 'lisp-indent-function lisp-body-indent)

  (defmacro when-and-boundp (var &rest body)
    "When version of `if-and-boundp'."
    `(if-and-boundp ,var
      (progn
        ,@body)))
  (dp-put-pv-list 'when-and-boundp 
                  '((lisp-indent-hook 1) (lisp-indent-function 1)))

  (defmacro unless-and-boundp (var &rest body)
    "Unless version of `if-and-boundp'."
    `(if-and-boundp ,var
      nil
      ,@body))
  (dp-put-pv-list 'unless-and-boundp 
                  '((lisp-indent-hook 1) (lisp-indent-function 1)))

  (defmacro if-and-fboundp (fun then &rest else)
    "If FUN is `fboundp' and non-nil do THEN else do ELSE. See `if' for details."
    `(if (and (fboundp ,fun) (symbol-function ,fun))
      ,then
      ,@else))
  (put 'if-and-fboundp 'lisp-indent-function lisp-body-indent)

  (defmacro def-pkg-dmessage (&optional prefix-in)
    "Define a pkg/file specific dmessage func and control var."
    (let* ((prefix (or prefix-in
                       (file-name-sans-extension 
                        (file-relative-name (buffer-file-name)))))
           (fun (intern (format "%s-dmessage" prefix)))
           (var (intern (format "%s-dmessage-on-p" prefix)))
           (func-docstr (format "dmessage func for %s." prefix))
           (var-docstr (format "dmessage control var for %s." prefix))
           (prefix-str (format "%s: " prefix)))
      `(progn
        (defvar ,var nil ,var-docstr)
        (defun ,fun (fmt &rest args)
          ,func-docstr
          (if ,var
              (apply (quote message) (concat ,prefix-str fmt) args))))))
  
  (defmacro dp-current-error-function-advisor (fun next-thing 
                                               &optional next-thing-arg)
    (let* ((efunc (eval fun))
           (next-thing-arg (or (eval next-thing-arg) efunc))
           (enext-thing (eval next-thing)))
      `(defadvice ,efunc
        (before next-error-function-stuff activate)
        (dp-set-current-error-function ,next-thing
                                       nil
                                       (quote ,next-thing-arg)))))
  
  (defmacro dp-current-error-function-advisor-after (fun
						     next-thing
						     &optional next-thing-arg)
    (let* ((efunc (eval fun))
           (next-thing-arg (or (eval next-thing-arg) efunc))
           (enext-thing (eval next-thing)))
      `(defadvice ,efunc
        (after next-error-function-stuff-after activate)
        (dp-set-current-error-function ,next-thing
                                       nil
                                       (quote ,next-thing-arg)))))

)

;; There is some *very* bizzare parenthesis closing problem up there.
;; e.g. (defmacro foo (fargs) "I am a fucked up file" (stuff))
;; has a close paren problem with the eval-when-compile up there, but
;; (defmacro foo (fargs) "I a") fucked up file...
;;                            ^ this closes the parens fine, but "I am a "
;; doesn't."
(eval-when-compile

  (defmacro dp-when-rsh-cwd (&rest body)
    "Execute BODY with the CWD extracted from the nearest shell type buffer.
/CWD/ is bound to the a string holding the buffer's CWD.
Execute BODY if /CWD/ is non-nil.  
Forms in BODY can use /CWD/."
    `(let ((/cwd/ (dp-rsh-cwd)))
      (if /cwd/
          (progn
            ,@body)
        (message "Duuude, like no prompt/path found, man.")
        (ding))))
  (put 'dp-when-rsh-cwd 'lisp-indent-function lisp-body-indent)

  (defmacro dp-funcall-if  (func func-args &rest else-body)
    "`funcall' FUNC with unquoted list FUNC-ARGS if FUNC is bound and a function,
otherwise do ELSE.
E.g.
\(dp-funcall-if 'good-things 
    \(puppy-dogs rainbows)
  \(woe-is-me)
  \(ho-ho-ho-to-the-bottle-I-go))

Yields:

\(if \(functionp 'good-things)
    \(funcall 'good-things puppy-dogs rainbows)
  \(woe-is-me)
  \(ho-ho-ho-to-the-bottle-I-go))"
    (unless (listp func-args)
      (setq func-args (list func-args)))
    `(if (functionp ,func)
      (funcall ,func ,@func-args)
      ,@else-body))
  (put 'dp-funcall-if 'lisp-indent-function lisp-body-indent)
  
  (defmacro dp-apply-if (func func-args &rest else-body)
    "Like `dp-funcall-if', but uses `apply'."
    `(if (functionp ,func)
      (apply ,func ,func-args)
      ,@else-body))
  (put 'dp-apply-if 'lisp-indent-function lisp-body-indent)
  
  (defmacro dp-aif-old (if-body &rest else-body)
    "Does this form please you?
IF-BODY is a list: \(an-fset-var-or-sym REST..). "
    (let ((func (car if-body))
          (func-args (cdr if-body)))
      `(if (functionp ,func)
        (apply (symbol-function ,func) (when ,func-args
                                         (list ,@func-args)))
        ,@else-body)))
  (put 'dp-aif-old 'lisp-indent-function 1)

  (defmacro dp-aif (if-body &rest else-body)
    "Does this form please you?
IF-BODY is a list: \(an-fset-var-or-sym REST..). "
    (let* ((func (car if-body))
           (func-args (cdr if-body))
           (fp (dp-callable func)))
      `(progn
        (if ,fp
            (apply ,fp ,@func-args)
          ,@else-body))))
  (put 'dp-aif 'lisp-indent-function 1)

  (defmacro dp-callable-pred (pred &optional pred-args)
    "If PRED is \(functionp\), \(apply PRED PRED-ARGS\).  Else return pred."
    `(dp-aif
      (,pred ,pred-args)
      ,pred))

  (defmacro dp-call-interactively-if+ (func func-args &rest else-body)
    "Apply FUNC to FUNC-ARGS if FUNC is a function, otherwise do ELSE."
    `(if (and (functionp ,func)
              (or (interactive-form ,func)
                  (error 
                   'invalid-function
                   (format 
                    "%s is a function, but not an interactive function." ,func))))
      (call-interactively ,func ,@func-args)
      ,@else-body))
  (put 'dp-call-interactively-if+ 'lisp-indent-function lisp-body-indent)

  (defmacro dp-call-interactively-if (func &rest else-body)
    "Call FUNC interactively is it is, else eval ELSE-BODY.
NO extra parameters can be passed to `call-interactively'.  See
`dp-call-interactively-if+' if you needs must have parameters."
    `(dp-call-interactively-if+ ,func () ,@else-body))
  (put 'dp-call-interactively-if 'lisp-indent-function lisp-body-indent)

;; This is the same as dp-apply-if.  Gotta pay more attention to what I've
;; written.
;   (defmacro dp-if-functionp (func args &rest else-body)
;     "If \(functionp FUNC\) call it w/ARGS, else execute ELSE-BODY.
; If FUNC takes no args, ARGS must be set to nil."
;     `(if (functionp ,func)
;       (apply ,func ,func-args)
;       ,@else-body))

  (defmacro setg (place value)
  "Set PLACE to VALUE.  Place can be a variable, a symbol or void."
  (if (symbolp (eval place))
      `(set ,place ,value)
    `(setf ,place ,value)))
  
  (defmacro dp-val-if-boundp (var-sym)
    `(and-boundp ',var-sym (symbol-value ',var-sym)))

  (defmacro dp-val-if-fboundp (var-sym)
    `(or (and-fboundp ',var-sym (symbol-function ',var-sym))
      (and-fboundp ',var-sym (symbol-function ',var-sym))))

  (defmacro dp-without-undo-in-current-buffer (&rest body)
    `(let* ((buffer-undo-list t))
      ,@body))

  (defmacro dp-lambda-p (definition)
    ;; Stolen from advice
    ;;"non-nil if DEFINITION is a lambda expression."
    `(eq (car-safe ,definition) 'lambda))

  (defmacro dp-with-saved-point (var &rest forms)
    "Lightweight version of `save-excursion'. Save point and execute FORMS.
Return value of FORMS.
If VAR is non-nil, put the *final* value of `point' as a marker in it.
@todo use generated temp var so we don't shadow another variable.
@todo we could have it barf if variable is `boundp'."
    `(let ((**%original%point%** (dp-mk-marker)))
      (prog1
          (progn
            ,@forms)
        ,(when var
           `(setq ,var (dp-mk-marker)))
        (goto-char **%original%point%**))))  
  (put 'dp-with-saved-point 'lisp-indent-function 
       (get 'while 'lisp-indent-function))
  (defalias 'dp-save-excursion-lite 'dp-with-saved-point)
  
  (defmacro dp-do-thither (thither final-point &rest forms)
    "Go THITHER in this buffer, execute FORMS and return whence we came.
FINAL-POINT, if non-nil, should be a symbol into which `point' is saved when
FORMS complete."
    (let ((whither (dp-gentemp "+dp-do-thither-"))
          (thither (if (listp thither)
                       (car thither)
                     thither))
          (final-point (if (listp thither)
                           (cadr thither)
                         nil)))
      `(let ((,whither (point)))
        (prog1
            (progn
              (goto-char ,thither)
              ,@forms)
          ,(when final-point
             `(setq ,final-point (point)))
          (goto-char ,whither)))))
  (put 'dp-do-thither 
       'lisp-indent-function (get 'save-excursion 'lisp-indent-function))
  
  (defmacro* dp-defwriteme (name arg-list docstring &rest body &aux args-str)
    ;; Handle docstring cases:
    (setq docstring (concat "WRITE THIS FUNCTION!\n" docstring))
    (setq args-str (if arg-list 
                       (format "%s" `(,@arg-list))
                     "()"))
    `(defun ,name ,arg-list
      ,docstring
      (interactive)
      (message "%s: WRITE ME!!!: %s %s" 
               (quote ,name)
               (quote ,name)
               ,args-str)
      ,@body))
  (put 'dp-defwriteme 'lisp-indent-function 'defun)
  
  (defmacro dp-working... (msg enable-p &rest forms)
    (if (not enable-p)
        '()
      `(progn
        (message ,msg)
        ,@forms
        (message (concat ,msg "done")))))
    (put 'dp-working... 'lisp-indent-function (get 'when 'lisp-indent-function))

  (defmacro with-marker-buffer (pos &rest forms)
    "Exec FORMS in POS's buffer if one, else `current-buffer'."
    `(with-current-buffer (if (markerp ,pos)
                              (marker-buffer ,pos)
                            (current-buffer))
      ,@forms))
  (put 'with-marker-buffer 'lisp-indent-function 
       (get 'when 'lisp-indent-function))

  (defmacro dp-advise-for-go-back (func &optional doc reason)
    "Wrap FUNC with 'before advice that does a `dp-push-go-back'"
    (let* ((doc (or (and doc (eval doc))
                    (format 
                     "Add 'before advice that first does a `dp-push-go-back.'")))
           (efunc (eval func))
           (advice-name (intern (format "dp-ad-%s" efunc)))
           (reason (or (and reason (eval reason))
                       (format "`dp-push-go-back' advised  `%s'" efunc))))
      `(defadvice ,efunc (before ,advice-name activate)
        ,doc
        (dp-push-go-back ,reason))))

  (defmacro dp-flambda (args docstring &rest forms)
    (unless (stringp docstring)
      (setq forms (cons docstring forms)
            docstring "Too lazy to add doc."))
    `(function 
      (lambda (,@args)
        ,docstring
        ,@forms)))
  (put 'dp-flambda 'lisp-indent-function (get 'lambda 'lisp-indent-function))

  (defmacro dp-cycle&setf-list (list-name new-list)
    "Advance LIST-NAME, wrapping to NEW-LIST.  Set and return LIST-NAME."
    `(progn
      (unless (setf ,list-name (cdr ,list-name))
        (setf ,list-name ,new-list))
      ,list-name))
  (put 'dp-cycle&setf-list 'lisp-indent-function 
       (get 'setf 'lisp-indent-function))


  (defmacro with-case-folded (fold-p &rest body)
    "Execute BODY with `case-fold-search' set to FOLD-P"
    `(let ((case-fold-search ,fold-p))
      ,@body))
  (put 'with-case-folded
       'lisp-indent-function (get 'let 'lisp-indent-function))
  
  (defmacro dp-with-prefix-arg (arg &rest body)
    `(let ((current-prefix-arg ,arg))
      ,@body))
  (put 'dp-with-prefix-arg
       'lisp-indent-function (get 'let 'lisp-indent-function))

  (defmacro dp-car&cycle-list (list-name new-list)
    `(if (or ,list-name
             (setf ,list-name ,new-list)
             t)
      (prog1
          (car ,list-name)
        (setf ,list-name (cdr ,list-name)))))

  (defmacro dp-refvar (name init-val &optional docstring)
  "Force reevaluation of a defvar just like eval'ing in interactive lisp mode."
  (let ((expr `(defvar 
                ,name
                ,init-val)))
    (when docstring
      (setq expr `(,@expr ,docstring)))
    `(let ((eval-interactive-verbose nil))
      (eval-interactive (quote ,expr)))))
  (put 'dp-refvar 'lisp-indent-function
       (get 'defvar 'lisp-indent-function))


;;; // ///// <:macros new up there, above me:>

)  

(provide 'dp-macros)

(message "dp-macros.el loaded.")

