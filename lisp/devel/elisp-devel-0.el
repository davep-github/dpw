
                 xxx


from: /a/b/c/xxx
  to: /a/1/2/3/4/5/yyy
../../1/2/3/4/5/yyy
common sub: /a
delta from from to common: -2
from + (abs(delta) * ../) + (to - common)

to: /r/ppp

from: /a/b/c/xxx
  to: /a/b/c/d/e/zzz
d/e/zzz
common sub: /a/b/c
delta from from to common: 0
from + (abs(delta) * ../) + (to - common)

make 'em absolute.
flist "/" + split
tlist "/" + split

(setq common nil)
(while flist

>>>>>>>>>>file-relative-name<<<<<<<<<<<<<<<<<<<<

(defmacro em2 (a b)
  `(progn
     (message ,a)
     (message ,b)))
em2

?\C-1
67108913

67108912

0

1

1

(defmacro em3 (x)
  `[?\e ?\C-,x])
em3
(macroexpand '(em3 ?1))
[27 67108908 x]

[27 C- 49]


(macroexpand '(em2 "a" "b"))
(progn (message "a") (message "b"))


(em2 "one" "too")
"too"

[?\e?3]
[?\e?\C-3]


(defmacro em1 (num num2)
  `(progn
     (global-set-key [?\e ,num2] (function (lambda () (interactive)
					(dp-set-or-goto-bm ,num nil))))
     (global-set-key [?\e ,num2] (function (lambda () (interactive)
					     (dp-set-or-goto-bm ,num nil))))))

em1

em1

em1


em1

[?\e ?1]
[27 49]

(em1 1)
(macroexpand '(em1 1 ?1))
(global-set-key [27 49] (function (lambda nil (interactive) (dp-set-or-goto-bm 1 nil))))

(em1 1 ?1)
(lambda nil (interactive) (dp-set-or-goto-bm 1 nil))

(lambda nil (interactive) (dp-set-or-goto-bm 1 nil))

(global-set-key "\e1" 'nil)
nil

(lambda nil (interactive) (dp-set-or-goto-bm 1 nil))

(global-set-key (format "\\e%d:" 1) (function (lambda nil (interactive) 
 (dp-set-or-goto-bm 1 nil))))



`[a b]
[a b]



(setq num 1)
`(global-set-key (format "\\e%d:" ,num) (function (lambda () (interactive)
					  (dp-set-or-goto-bm ,num nil))))
(global-set-key (format "\\e%d:" 1) (function (lambda nil (interactive) (dp-set-or-goto-bm 1 nil))))

`("a,num")
("a,num")



em1

(em1 1)



(eval (format "(global-set-key \"\\e%d\" (function (lambda () 
				  (interactive) (dp-set-or-goto-bm %d nil))))" 1))


"(global-set-key \"\\e1\" (function (lambda () 
				  (interactive) (dp-set-or-goto-bm 1 nil))))"

(princ (format "[?\\e?\\C-%d]" 9))
[?\e?\C-9]"[?\\e?\\C-9]"

[?\e?\C-1]"[?\\e?\\C-1]"

[?\e?\C-3]

(global-set-key "\e1" (function (lambda () 
				  (interactive) (dp-set-or-goto-bm 1 nil))))
(global-set-key "\e2" (function (lambda () 
				  (interactive) (dp-set-or-goto-bm 2 nil))))
(global-set-key "\e3" (function (lambda () 
				  (interactive) (dp-set-or-goto-bm 3 nil))))
(global-set-key "\e4" (function (lambda () 
				  (interactive) (dp-set-or-goto-bm 4 nil))))
(global-set-key "\e5" (function (lambda () 
				  (interactive) (dp-set-or-goto-bm 5 nil))))
(global-set-key "\e6" (function (lambda () 
				  (interactive) (dp-set-or-goto-bm 6 nil))))
(global-set-key "\e7" (function (lambda () 
				  (interactive) (dp-set-or-goto-bm 7 nil))))
(global-set-key "\e8" (function (lambda () 
				  (interactive) (dp-set-or-goto-bm 8 nil))))
(global-set-key "\e9" (function (lambda () 
				  (interactive) (dp-set-or-goto-bm 9 nil))))
(global-set-key "\e0" (function (lambda () 
				  (interactive) (dp-set-or-goto-bm 0 nil))))

(global-set-key [?\e?\C-1] (function (lambda () 
				  (interactive) (dp-set-or-goto-bm 1 1))))
(global-set-key [?\e?\C-2] (function (lambda () 
				  (interactive) (dp-set-or-goto-bm 2 1))))
(global-set-key [?\e?\C-3] (function (lambda () 
				  (interactive) (dp-set-or-goto-bm 3 1))))
(global-set-key [?\e?\C-4] (function (lambda () 
				  (interactive) (dp-set-or-goto-bm 4 1))))
(global-set-key [?\e?\C-5] (function (lambda () 
				  (interactive) (dp-set-or-goto-bm 5 1))))
(global-set-key [?\e?\C-6] (function (lambda () 
				  (interactive) (dp-set-or-goto-bm 6 1))))
(global-set-key [?\e?\C-7] (function (lambda () 
				  (interactive) (dp-set-or-goto-bm 7 1))))
(global-set-key [?\e?\C-8] (function (lambda () 
				  (interactive) (dp-set-or-goto-bm 8 1))))
(global-set-key [?\e?\C-9] (function (lambda () 
				  (interactive) (dp-set-or-goto-bm 9 1))))
(global-set-key [?\e?\C-0] (function (lambda () 
				  (interactive) (dp-set-or-goto-bm 9 1))))



(let ((i 0)
      s)
  (while (< i 10)
    (eval (global-set-key (format "\\e%d" i) (function (lambda () 
	       (interactive) (dp-set-or-goto-bm i nil)))))
    (message "%s" s)
    (eval s)
    (setq s (format "(global-set-key [?\\e?\\C-%d] (function (lambda () 
	       (interactive) (dp-set-or-goto-bm %d 1))))" i i))
    (message "%s" s)
    (eval s)
    (setq i (1+ i))))

(setq i 3)
3

(eval (global-set-key "\e3"
		      (function (lambda () 
				  (interactive) (dp-set-or-goto-bm i nil)))))
(lambda nil (interactive) (dp-set-or-goto-bm i nil))



(format "\"\\e%d\"" i) 
"\"\\e3\""

[?\e ?\C-1]
[27 67108913]

[27 67108913]

(global-set-key [?\C-x ?\C-\\] 'next-line)
next-line
(global-set-key [(control ?x) (control ?\\)] 'next-line)
next-line

(control ?a)

[(control ?x) (control ?\\)]
[(control 120) (control 92)]

(setq mew-icon-directory "a directory where Mew's image files are installed.")

(defun mewon ()
  (interactive)
  (autoload 'mew "mew" nil t)
  (autoload 'mew-send "mew" nil t)
  (setq mew-mail-domain-list '("who.net"))
  (autoload 'mew-user-agent-compose "mew" nil t)
  (if (boundp 'mail-user-agent)
      (setq mail-user-agent 'mew-user-agent))
  (setq  mew-refile-guess-alist
	 '(("^(To:|Cc:)"
	    ("@handlelds.org" . "+ipaq"))))
  (if (fboundp 'define-mail-user-agent)
      (define-mail-user-agent
	'mew-user-agent
	'mew-user-agent-compose
	'mew-draft-send-letter
	'mew-draft-kill
	'mew-send-hook)))
mewon

(defun mew-refile-guess-by-alist1 (alist)
  (let (name header sublist key val ent ret)
    (while alist
      (setq name (car (car alist)))
      (setq sublist (cdr (car alist)))
      (message "name>%s<, sublist>%s<" name sublist)
      (cond
       ((eq name t)
	(setq ret (cons sublist ret)))
       ((eq name nil)
	(or ret (setq ret (cons sublist ret))))
       (t
	(setq header (mew-header-get-value name))
	(message "header>%s<" header)
	(if header
	    (while sublist
	      (setq key (car (car sublist)))
	      (setq val (cdr (car sublist)))
	      (message "key>%s<, val>%s<" key val)
	      (if (and (stringp key) (string-match key header))
		  (cond
		   ((stringp val)
		    (setq ent (mew-refile-guess-by-alist2 key header val)))
		   ((listp val)
		    (setq ent (mew-refile-guess-by-alist1 val)))))
	      (if ent
		  (if (listp ent)
		      (setq ret (nconc ent ret) ent nil)
		    (setq ret (cons ent ret))))
	      (setq sublist (cdr sublist))))))
      (setq alist (cdr alist)))
    (mew-uniq-list (nreverse ret))))
mew-refile-guess-by-alist1

mew-refile-guess-by-alist1




(setq dp-mailer 'mew)
(unless (condition-case nil
	    (cond
	     ((and (eq dp-mailer 'mew)
		   (not (string< emacs-version "20.7.1"))) 
	      (load "dp-mew"))
	     (t nil))
	  (error nil))
  (message "blah")
  (load "dp-mhe"))
nil


(setq dp-oo-browser-dir "/usr/yokel/share/emacs/site-lisp/oo-browser")
"/usr/yokel/share/emacs/site-lisp/oo-browser"
(defvar dp-oo-browser-dir "/usr/yokel/share/emacs/site-lisp/oo-browser")
dp-oo-browser-dir


(defvar dp-oo-browser-dir "/usr/yokel/share/emacs/site-lisp/oo-browser")
(defun dp-setup-ootags ()
  "Set up ootags source browsing system."
  (interactive)
  (add-to-list 'load-path dp-oo-browser-dir) 
  (add-to-list 'load-path (concat dp-oo-browser-dir "/hypb"))
  (load "br-start")
  (global-set-key "\C-c\C-o" 'oo-browser))

dp-setup-ootags
(dp-setup-ootags)
oo-browser


(defvar dp-hyperbole-dir "/usr/yokel/share/emacs/site-lisp/hyperbole")
(defvar hyperb:dir (concat dp-hyperbole-dir "/"))
(defun dp-setup-hyperbole ()
  "Set up hyperbole info system."
  (interactive)
   (setq hyperb:dir (concat dp-hyperbole-dir "/"))
   (load (expand-file-name "hversion" hyperb:dir))
   (load (expand-file-name "hyperbole" hyperb:dir)))
dp-setup-hyperbole
(dp-setup-hyperbole)





--------

(setq message-log-max 500)
500


(setq br-inherited-features-flag nil)
(defun br-feature-list-routines (class)
  "Return sorted list of routine tags lexically defined in CLASS."
  (message "class>%s<" class)
  (delq nil
	(mapcar
	 (function (lambda (tag)
		     (if (string-match (concat "\\`" br-routine-type-regexp)
				       (br-feature-tag-name tag nil t))
			 tag)))
	 (hash-get class br-features-htable))))

Channel<T1,T2>
(hash-get "Channel<T1,T2>" br-features-htable)
(["Channel<T1,T2>" "% CompGraph" "friend class CompGraph;" "3"] ["Channel<T1,T2>" "= iItems" "ItemsType iItems;" "3"] ["Channel<T1,T2>" "= iOutputs" "OutputsType iOutputs;" "3"])


(defun br-env-load (&optional env-file env-name prompt no-build)
  "Load an OO-Browser Environment or specification from optional ENV-FILE, ENV-NAME or `br-env-file'.
Non-nil PROMPT means prompt user before building the Environment.
Non-nil NO-BUILD means skip the build of the Environment entirely.
Return t if the load is successful, else nil."
  (interactive
   (message "yop")
   (progn (br-names-initialize)
	  (setq env-name
		(br-name-read "Load OO-Browser Env named: " t))
	  (setq env-file (or (br-name-get-env-file env-name)
			     (br-env-read-file-name
			      (if (or (eq env-name t) (equal env-name ""))
				  "Load Environment from file: "
				(format "Load `%s' from file: " env-name))
			      default-directory
			      (expand-file-name br-env-default-file)
			      t)))
	  (list env-file env-name nil nil)))
  (let ((file-name-cons (br-env-validate-arg-strings
			 "br-env-load" env-file env-name)))
    (setq env-file (car file-name-cons)
	  env-name (cdr file-name-cons)))
  (setq env-file (or (and (not (equal env-file "")) env-file)
		     (br-env-default-file))
	env-file (expand-file-name env-file))
  (let ((buf (get-file-buffer env-file)))
    (and buf (kill-buffer buf)))
  (let ((br-loaded))
    (if (file-readable-p env-file)
	(unwind-protect
	    (progn
	      (message "Loading Environment...")
	      (sit-for 1)
	      ;; Ensure spec, version, time and feature values are nil for
	      ;; old Environment files that do not contain a setting for
	      ;; these variables.
	      (setq br-env-spec nil br-env-version nil
		    br-env-start-build-time nil
		    br-env-end-build-time nil
		    br-features-alist nil
		    br-feature-paths-alist nil)

	      ;; Ensure that OO-Browser support libraries for the current
	      ;; language are loaded, since this function may be called
	      ;; without invoking the OO-Browser user interface.
	      ;; This must be called before the Env is loaded
	      ;; and before br-env-file is set or it may
	      ;; overwrite Env variable settings improperly.
	      (setq br-lang-prefix
		   (br-env-read-language-prefix env-file))
	      (let ((lang-symbol
		     (intern-soft (concat br-lang-prefix "browse")))
		    lang-function)
		(if lang-symbol
		    (progn (setq lang-function (symbol-function lang-symbol))
			   (if (and (listp lang-function)
				    (eq (car lang-function) 'autoload))
			       (load (car (cdr lang-function))))
			   ;; Initialize language-specific browser variables.
			   (funcall (intern-soft
				     (concat br-lang-prefix "browse-setup"))
				    env-file))))

	      (load-file env-file)
	      (setq br-env-file env-file
		    br-env-name env-name)
	      (br-init env-file) ;; initializes auxiliary Env file variables

	      ;; Prevent rebuilding of Environment
	      (setq br-lib-prev-search-dirs br-lib-search-dirs
		    br-sys-prev-search-dirs br-sys-search-dirs)

	      (cond
	       ((and br-env-spec (not no-build))
		(setq br-loaded
		      (br-env-cond-build
		       env-file env-name
		       (if prompt "Build Environment `%s' now? "))))
	       ;; Feature storage formats changed in V4.00, so all prior
	       ;; Environments are obsolete.
	       ((and (not no-build)
		     (or (null br-env-version)
			 (and (stringp br-env-version)
			      (string-lessp br-env-version "04.00"))))
		(setq br-loaded
		      (br-env-cond-build
		       env-file env-name
		       (if prompt
			   "Env `%s' format is obsolete, rebuild it now? ")))
		(if (not br-loaded)
		    (error "(OO-Browser): The Environment must be rebuilt before use.")))))
	  ;;
	  ;; Initialize OO-Browser Environment data structures in cases where
	  ;; the Environment was not just built.
	  (if (or br-env-spec br-loaded)
	      nil
	    (setq br-children-htable (hash-make br-children-alist)
		  br-features-htable (hash-make br-features-alist)
		  br-feature-paths-htable (hash-make br-feature-paths-alist)
		  br-sys-paths-htable (hash-make br-sys-paths-alist)
		  br-lib-paths-htable (hash-make br-lib-paths-alist)
		  br-sys-parents-htable
		  (hash-make br-sys-parents-alist)
		  br-lib-parents-htable
		  (hash-make br-lib-parents-alist)
		  )
	    (br-env-set-htables t)
	    (setq br-loaded t))
	  (if (and (fboundp 'br-in-browser) (br-in-browser))
	      (br-refresh))
	  (message "Loading Environment...Done"))
      (if (file-exists-p env-file)
	  (progn (beep)
		 (message "No read rights for Environment file, \"%s\"" env-file)
		 (sit-for 4))
	(setq br-loaded (br-env-load
			 (br-env-create env-file br-lang-prefix)
			 env-name t no-build))))
    br-loaded))
br-env-load

br-env-load

----------
add ifdef matching to M-[ paren-matching.

(defvar dp-ifx-re-alist 
  '((dp-if . "#[ 	]*if")
    (dp-else . "#[ 	]*else")
    (dp-elif . "#[ 	]*elif")
    (dp-endif . "#[ 	]*endif")))
(setq dp-ifx-re-alist 
  '((dp-if . "#[ 	]*if")
    (dp-else . "#[ 	]*else")
    (dp-elif . "#[ 	]*elif")
    (dp-endif . "#[ 	]*endif")))

(defun dp-get-ifdef-item ()
  (interactive)
  (catch 'found
    (save-excursion
      (beginning-of-line)
      (let ((l dp-ifx-re-alist)
	    el)
	(while l
	  (setq el (car l))
	  (setq l (cdr l))

	  (when (looking-at (cdr el))
	    ;;(message "found>%s<" (car el))
	    (throw 'found (car el))))
	;;(message "nada")
	(throw 'found nil)))))

(dp-get-ifdef-item)
nil



#if
#else
#elif
#endif
#boo
xxx

(defun dp-copied-from-vi-find-matching-paren ()
  "\"Locate the matching paren.  It's a hack right now.\""
  (interactive)
  (let (ifdef-item)
    (cond 
     ((looking-at "[[({]") (forward-sexp 1) (backward-char 1))
     ((looking-at "[])}]") (forward-char 1) (backward-sexp 1))
     ((and (eq major-mode 'c-mode)
	   (setq ifdef-item (dp-get-ifdef-item)))
      (cond
       ((or (eq ifdef-item 'dp-if)
	    (eq ifdef-item 'dp-else)
	    (eq ifdef-item 'dp-elif)) (hif-ifdef-to-endif))
       ((eq ifdef-item 'dp-endif) (hif-endif-to-ifdef))
       (t (ding))))
      (t (ding)))))
dp-copied-from-vi-find-matching-paren


(defun dp-delete-word (arg)
  "Delete characters forward until encountering the end of a word.
With argument, do this that many times.
Main change is to allow a sequence of white-space at point to be deleted
with this command.
Based on kill-word from simple.el"
  (interactive "p")
  (let ((ws "\\(\\s-\\|\n\\)+"))
    (if (and (looking-at ws)
	     (or (> arg 0)	; we'll use the match info from looking at
		 (when (re-search-backward "[^ 	\n]" nil t)
		   (forward-char)
		   (looking-at ws))))
	(progn
	  (message "p>%s<, me>%s<" (point) (match-end 0))
	  (delete-region (point) (match-end 0)))
      (delete-region (point) (progn (forward-word arg) (point))))))




---------------------------------+15053
aaa bbbb               ccccc       dddddd


(defun dp-delete-word (arg)
  "Delete characters forward until encountering the end of a word.
With argument, do this that many times.
Main change is to allow a sequence of white-space at point to be deleted
with this command.
Based on kill-word from simple.el"
  (interactive "p")
  (let ((ws "\\(\\s-\\|\n\\)+")
	(opoint (point)))
    (if (or
	 (and (> arg 0)
	      (looking-at ws))
	 (and (< arg 0)
	      (not (bobp))
	      (not (backward-char 1))
	      (if (looking-at ws)
		  t
		(forward-char 1))
	      (re-search-backward "[^ 	\n]" nil t)
	      (not (forward-char 1))
	      (re-search-forward ws opoint t)))
	  (delete-region (match-beginning 0) (match-end 0))
      (delete-region (point) (progn (forward-word arg) (point))))))
dp-delete-word

.................v..............x.....................
aaa     bbbbb         cccccccccccc        dddddd eeeeeeeee
                                xxxxx 
(backward-char 99)

16179
(setq ws "\\(\\s-\\|\n\\)+")
"\\(\\s-\\|
\\)+"


(defun t1 ()
  (interactive)
  (re-search-forward "^\\s-*\\(.*[^ 	\n]\\)\\s-*$" nil t)
  (message ">%s<" (buffer-substring (match-beginning 1) (match-end 1))))
t1
                 

(defun xx-mark-line (&optional text-only)
  "Mark the line point is on.
If text-only is non-nil, then shrink-wrap the mark aound just the non-white
space on the line."
  (interactive "P")
  
  (beginning-of-line)
  (let ((re (if text-only "^\\s-*\\(.*[^ 	\n]\\)\\s-*$" "\\(.*\\)"))
	(eol (line-end-position))
	bol)
    (if (re-search-forward re eol t)
	(setq eol (match-end 1)
	      bol (match-beginning 1))
      (setq bol (line-beginning-position)))
    
    (unless text-only
      (if (< eol (point-max))
	  (setq eol (1+ eol))		;include the newline if not at eob
	;; if we're deleting the last line in the file, we want to delete
	;; the newline from the preceeding line, otherwise we leave an
	;; empty line at the end of the file.
	(if (> bol (point-min))
	  (setq bol (1- bol)))))
    (set-mark bol)			; set mark
    (goto-char eol)))			; set point


(defun transient-mark-mode (arg)
  (setq zmacs (/= arg 0)))

(defmacro transient-mark-mode (arg)
  `(setq zmacs (/= ,arg 0)))
transient-mark-mode


(macroexpand '(transient-mark-mode 1))
(setq zmacs (/= 1 0))

(defmacro dp-mark-active-p ()
  `zmacs-region-active-p)
dp-mark-active-p

(macroexpand '(dp-mark-active-p))
zmacs-region-active-p

(defvar dp-keysyms '((dpk-c-tab . (control tab)))
  "Keys for binding in both emacs and xemacs.  There is one of
these maps defined for emacs and xemacs")
dp-keysyms

(defmacro dpk (sym)
  `(or (cdr (assoc ,sym dp-keysyms))
       sym))
dpk

dpk
(dpk 'dpk-c-tab)
(control tab)

(local-set-key (dpk 'dpk-c-tab) 'foofoo)
nil


c-tab

(setq x (car dp-keysyms))
(c-tab control tab)
(car x)
c-tab
(equal (car x) 'c-tab)
t


(defvar dp-keysyms '((dpk-c-left . [C-left]))
  "Keys for binding in both emacs and xemacs.  There is one of
these maps defined for emacs and xemacs")
dp-keysyms

(local-set-key (dpk 'dpk-c-left) 'backward-word)

;;;;;;;;;;;;;;;;;;;;;;;
;; wrapping/stacking functions
;;;;;;;;;;;;;;;;;;;;;;;
(defmacro fwrap (oldf newf)
  `(lambda ()
     (if ,newf
	 (funcall ,newf))
     (if ,oldf
	 (funcall ,oldf))))
(defun fwrapper (oldf newf)
  (let ((f (fwrap oldf newf)))
    (put 'f 'dp-fwrapper t)
    f))
(defun dp-fwrapper-p (sym)
  (get sym 'dp-fwrapper))
dp-fwrapper-p

(defun efold ()
  (message "efold"))
(defun efnew ()
  (message "efnew"))

(setq f (fwrapper 'efold 'efnew))
(lambda nil (if newf (funcall newf)) (if oldf (funcall oldf)))

(setq f2 f)
(lambda nil (if newf (funcall newf)) (if oldf (funcall oldf)))

(symbol-value 'f)
(lambda nil (if newf (funcall newf)) (if oldf (funcall oldf)))

(dp-fwrapper-p f2)

nil

nil

t


(symbol-plist 'f)
(dp-fwrapper t dp-wrapper "wrapper")



(get 'f 'blah)
nil

nil
(get 'f 'dp-fwrapper)
t




f
(lambda nil (if (quote efnew) (funcall (quote efnew))) (if (quote efold) (funcall (quote efold))))

(symbol-plist 'f)
nil

(boundp 'f)
t
(append '(a b c) '(d e f))
(a b c d e f)


(defun dp-modify-alist (in-alist mod-alist &optional replace-only)
  "Modify alist IN-LIST with matching 
elements from alist MOD-LIST."
  (let ((ret-val
	 (append
	  (mapcar (function
		   (lambda (el)
		     ;; if the key is in the mod-list
		     (let ((mod-el (assoc (car el) mod-alist)))
		       (if mod-el
			   ;; use it
			   mod-el
			 ;; otherwise use the original element
			 el))))
		  in-alist)
	  (unless replace only
		  ;; add in any elements in mod-alist that aren't in in-alist
		  (mapcar (function
			   (lambda (el)
			     (unless (assoc (car el) in-alist)
			       el)))
			  mod-alist)))))
    ;; nuke all of the nils left over from the second mapcar
    (delq nil ret-val)))

dp-modify-alist
(dp-modify-alist '((a . aval) (b . bval) (c . cval))
		 '((b . newb) (c . newc) (e . newe)))

(setq l2 '(a nil b nil nil c d e))
(a nil b nil nil c d e)
l2
(a b c d e)

(delq nil l2)
(a b c d e)


((a . aval) (b . newb) (c . cval) nil)



((a . aval) (b . newb) (c . cval))

((a . aval) (b . newb) (c . cval))

(dp-modify-alist '((a . aval) (b . bval) (c . cval))
		 '((d . newd)))
((a . aval) (b . bval) (c . cval) (d . newd))

((a . aval) (b . bval) (c . cval))


========================
2001-09-09T13:41:59
--
fix ld to take an optional file name.
(defun ld (&optional file-name)
  "Open the elisp devel buffer in lisp interaction mode.
This buffer is attached to a file so that we don't inadvertently exit.
Developing in `*scratch*' can result in lost work."
  (interactive (format "fdev file (%s/%s): " 
		       dp-default-elisp-devel-dir
		       dp-default-elisp-devel-file))
  (unless file-name
    (setq file-name (format "%s/%s" 
			    dp-default-elisp-devel-dir
			    dp-default-elisp-devel-file)))
		       
  (find-file file-name)
  (unless (eq major-mode 'lisp-interaction-mode)
    (lisp-interaction-mode)))

Make a less like viewer, where file-type causes an interpreted
versio of the file to be displayed.  then display with view-file,
or pu into view-file-mode.

(call-process PROGRAM &optional INFILE BUFFER DISPLAYP &rest ARGS)

(defvar dp-less-program "lesspipe.sh"
  "Program to interpret files into ASCII.")

(defun less (file-name &optional buffer-name q-key-command)
  "Less a file.  Interpret and display file contents by 
executing dp-less-program (e.g. lesspipe.sh)"
  (interactive "ffile: \nP")
  (when file-name
    (setq file-name (expand-file-name file-name))
    (setq buffer-name
	  (cond
	   ((eq buffer-name t)
	    (read-from-minibuffer "buf name: " "*less*"))
	   ((eq buffer-name nil)
	    (generate-new-buffer-name 
	     (format "*less(%s)*" 
		     (file-name-nondirectory file-name))))
	   (t
	    buffer-name)))
    (message "buffer-name>%s<" (buffer-name))
    (switch-to-buffer buffer-name)
    (let ((inhibit-read-only t))
      (delete-region (point-min) (point-max))
      (goto-char (point-min))
      (message "file-name>%s<" file-name)
      (call-process dp-less-program nil t nil file-name)
      (goto-char (point-min))
      (if (fboundp 'ununderline-and-unoverstrike-region)
	    (ununderline-and-unoverstrike-region (point-min) (point-max))
	(message "Cannot remove underlines and overstrikes inside emacs.")))
    (set-buffer-modified-p nil)
    (setq buffer-read-only t)
    (let* ((orig-map (car (current-keymaps)))
	   (kmap (copy-keymap orig-map)))
      (mapcar (lambda (key)
		(define-key kmap key  (or q-key-command 'kill-this-buffer)))
	      (split-string "q Q x X"))
      (use-local-map kmap))))

(defun unlessl ()
  "Restore original contents of lessl'd file."
  (interactive)
  (revert-buffer nil t))

(defun lessl ()
  "Lessify a buffer.  Interpret buffer contents by 
calling `less' on the buffer's file."
  (interactive)
  (if (buffer-modified-p)
      (error "Buffer is modified: please save or revert the buffer first."))
  (less (buffer-file-name) (buffer-name) 'unless1))



;# a family type template
;e(
;    kef='family',			# fixed for this type
;    dat={
;    'family': 'crl-linux',              # required, prompt for
;    'family_zone': 'crl',               # required, prompt for
;    'rinc_host': 'goliath'
;    'X': 'xf86',
;    'shell': 'bash',
;    'window_manager': 'sawfish',
;    # 'xterm_bin': 'xterm',		# obtained from default, usually
;    # try to pick unique color schemes per family
;    # to allow visual differentiation of families.
;    'xterm_bg': 'BlanchedAlmond',
;    'xterm_fg': 'black',
;    'xterm_font': '9x15',
;    'xterm_opts': """'-sb -sl 1024 -ls'""",
;    },
;    ref=default
;)

(setq elements '("
# family item template inserted/edited by tempo.el
e(
    kef='family',
    dat={
    'family': '" (P "fam name: " fam-name nil) "',
    'family_zone': '"(P "fam zone: " fam-zone nil)"',
    'rinc_host': '"(P "mh inc host: " inc-host nil) "',
    # change or delete the rest by hand.
    'X': 'xf86',
    'shell': 'bash',
    'window_manager': 'sawfish',
    # 'xterm_bin': 'xterm',		# obtained from default, usually
    # try to pick unique color schemes per family
    # to allow visual differentiation of families.
    'xterm_bg': 'BlanchedAlmond',
    'xterm_fg': 'black',
    'xterm_font': '9x15',
    'xterm_opts': \"\"\"'-sb -sl 1024 -ls'\"\"\",
    },
    ref=default
)
"))


;tempo-define-template (name elements &optional tag documentation taglist
(require 'tempo)
tempo

(tempo-define-template "dppydb-fam"
		        elements )
tempo-template-dppydb-fam

e(
    kef='family',
    dat={
    'family': 'fname',
    'family_zone': 'zname',
    'rinc_host': 'rhost',
    # change or delete the rest by hand.
    'X': 'xf86',
    'shell': 'bash',
    'window_manager': 'sawfish',
    # 'xterm_bin': 'xterm',		# obtained from default, usually
    # try to pick unique color schemes per family
    # to allow visual differentiation of families.
    'xterm_bg': 'BlanchedAlmond',
    'xterm_fg': 'black',
    'xterm_font': '9x15',
    'xterm_opts': '''"-sb -sl 1024 -ls"''',
    },
    ref=default
)


(setq dp-host-elements '("
# host item template inserted/edited by tempo.el
e(
    kef='host',
    dat={
    'host': '" (P "host name: " host-name nil) "',
    'description': '" (P "descr: " host-descr nil) "',
    'nick': '" (P "nickname: " host-nick nil) "',
    
    # some likely  defaults
    'xem_bin': 'xemacs',
    'ctl': 'rx',               # r --> inc in .rhosts, x -> inc in xhosts

    # Some examples of host info
    # 'xem_font': '''-font -*-courier-medium-r-*-*-*-140-*-*-*-*-iso8859-*''',
    # 'xem_opts': '''-geometry 80x60+456+0''',
    # 'tunnel-ip': '16.11.64.97',
    },
    ref=famDB['" (P "fam name: " fam-name nil) "'])"
))
(tempo-define-template "dppydb-host"
		        dp-host-elements )
(tempo-template-dppydb-host)

# host item template inserted/edited by tempo.el
e(
    kef='host',
    dat={
    'host': 'newhost',
    'description': 'a test host for templates',
    'nick': 'th',
    
    # some likely  defaults
    'xem_bin': 'xemacs',
    'ctl': 'rx',               # r --> inc in .rhosts, x -> inc in xhosts

    # Some examples of host info
    # 'xem_font': '''-font -*-courier-medium-r-*-*-*-140-*-*-*-*-iso8859-*''',
    # 'xem_opts': '''-geometry 80x60+456+0''',
    # 'tunnel-ip': '16.11.64.97',
    },
    ref=famDB['home-freebsd'])

(defun dp-eldoc ()
  "Display simple help summary in message area.
XXX figure out how to call eldoc entrypoint
eldoc-print-current-symbol-info rather than duping code here.
The code is anded with (eldoc-display-message-p).  Perhaps
a flet?"
  (interactive)
  (let* ((current-symbol (eldoc-current-symbol))
	 (current-fnsym  (eldoc-fnsym-in-current-sexp))
	 (doc (cond ((eq current-symbol current-fnsym)
		     (or (eldoc-get-fnsym-args-string current-fnsym)
			 (eldoc-get-var-docstring current-symbol)))
		    (t
		     (or (eldoc-get-var-docstring current-symbol)
			 (eldoc-get-fnsym-args-string current-fnsym))))))
    (eldoc-message doc)))


(defun dp-eldoc-get-help-str ()
  "Get help string eldoc would print."
  (interactive)
  (autoload 'eldoc-print-current-symbol-info "eldoc" "name says it all...")
  (autoload 'eldoc-display-message-p "eldoc")
  (eldoc-display-message-p)		;force the autoload
  (let (dpe-message)
    (flet ((eldoc-display-message-p () t)
	   (eldoc-message (&rest args) (setq dpe-message args)))
      (eldoc-print-current-symbol-info))
    dpe-message))

(defun dp-eldoc ()
  "Display simple help summary in echo area, ala eldoc, except only on demand.
XXX can we add possibility of specifying what to get help on?"
  (interactive)
  (message "%s" (dp-eldoc-get-help-str)))

(defun dp-insert-elisp-func-template ()
  "Insert function template extracted from an eldoc help message."
  (interactive "*")
  (let ((msg (dp-eldoc-get-help-str)))
    (message "msg>%s<" msg)
    (setq msg (car msg))
    (if (string-match "[^(]*(\\(.*\\))[^)]*" msg)
	(save-excursion
	  (insert (substring msg (match-beginning 1) (match-end 1)) ")"))
      (error "Improperly formatted eldoc help msg."))))

(defun blah ()
  "?"
  (interactive)
  (re-search-forward REGEXP &optional BOUND NO-ERROR COUNT BUFFER)

(setq dp-sig-source '(cmd "fortune" "-s"))
(cmd "fortune" "-s")

(setq dp-sig-source "pithiness is next to godliness")
"pithiness is next to godliness"

(setq dp-sig-source '(file . "~/.signature"))
(file . "~/.signature")

(file "~/.signature")

(setq dp-sig-source '(func dp-insert-cmd-sig "fortune" "-s"))
(func dp-insert-cmd-sig "fortune" "-s")

(func dp-insert-cmd-sig "fortune" "-s")
(setq dp-sig-source '(func dp-insert-yadda-sig))
(func dp-insert-yadda-sig)

(apply (nth 1 dp-sig-source) (cdr (cdr dp-sig-source))))
(nth 1 dp-sig-source)
dp-insert-cmd-sig
(cdr (cdr dp-sig-source))
("fortune" "-s")

(defun dp-insert-yadda-sig (args)
  (insert "yadda"))

(defun dp-insert-cmd-sig (args)
  "Insert the output of a command as a signature."
  (interactive)
  (insert (shell-command-to-string (dp-string-join args " "))))

(defun dp-insert-sig ()
  "Insert sig according to dp-sig-source."
  (interactive)
   (save-excursion
     ;; delete any existing sig
     (delete-region (marker-position dp-sig-start-marker) (point-max))
     (goto-char (marker-position dp-sig-start-marker))
     (let (sig-type) 
       (cond 
	((stringp dp-sig-source) (insert dp-sig-source))
	((setq sig-type (car-safe dp-sig-source))
	 (cond 
	  ((eq sig-type 'file)		; '(file . "file-name")
	   (let ((fname (cdr dp-sig-source)))
	     (if (file-readable-p fname)
		 (insert-file fname))))
	  ((eq sig-type 'func)		; '(func func-to-call &rest args)
	   (apply (nth 1 dp-sig-source) (list (cdr (cdr dp-sig-source)))))
	  ))
	((stringp mail-signature) (insert mail-signature)) ;historical
	(t (message "Unsupported type in dp-sig-source")
	 (ding))))))

(defun dp-maybe-insert-sig ()
  "Insert a sig of the desired type."
  (interactive)
  (if (and dp-mail-sig dp-sig-source)
      (save-excursion
	(goto-char (point-max))
	(setq dp-sig-orig-point-max (point-marker))
	(insert "\n--\n")
	(setq dp-sig-start-marker (point-marker))
	(dp-insert-sig))
    (setq dp-sig-orig-point-max nil)))



========================
2001-09-20T21:46:22
--
(defun dp-insert-cmd-sig (cmd &rest args)
  "Insert the output of a command as a signature."
  (interactive)
  (insert (shell-command-to-string (format "%s %s"
					   cmd
					   (dp-string-join args " ")))))

(defun dp-insert-file-sig (fname)
  "Insert FNAME as signature."
  (condition-case err
      (insert-file fname)
    (error (message "Error reading: %s: %s" fname err))))

(defun dp-insert-sig ()
  "Insert sig according to dp-sig-source."
  (interactive)
   (save-excursion
     ;; delete any existing sig
     (delete-region (marker-position dp-sig-start-marker) (point-max))
     (goto-char (marker-position dp-sig-start-marker))
     (cond 
      ((stringp dp-sig-source) (insert dp-sig-source))
      ((listp dp-sig-source) (eval dp-sig-source))
      ((stringp mail-signature) (insert mail-signature)) ;historical
	(t (message "Unsupported type in dp-sig-source")
	 (ding)))))

(setq dp-sig-source '(dp-insert-cmd-sig "fortune" "-s"))
(dp-insert-cmd-sig "fortune" "-s")

(dp-insert-cmd-sig "fortune")

(dp-insert-cmd-sig "fortune" "-s")

(dp-insert-cmd-sig "fortunex" "-s")

(dp-insert-cmd-sig "fortune" "-s")

(dp-insert-cmd-sig (quote ("fortune" "-s")))
(setq dp-sig-source '(dp-insert-file-sig "~/.signature"))
(dp-insert-file-sig "~/.signature")


(defun dp-mark-line2 (&optional text-only)
  "Mark the line point is on.
If text-only is non-nil, then shrink-wrap the mark aound just the non-white
space on the line."
  (interactive "P")
  (let (bol)
    (beginning-of-line)
    (if (and text-only (re-search-forward "\\S-" nil t))
	(backward-char 1))

    (setq bol (point))
    (end-of-line)
    (if text-only
	(if (re-search-backward "\\S-" nil t)
	    (forward-char 1))
      (if (not (eobp))
	  (forward-char 1)
	;; if we're deleting the last line in the file, we want to delete
	;; the newline from the preceeding line, otherwise we leave an
	;; empty line at the end of the file.
	(if (> bol (point-min))
	    (1- bol))))
    (dp-set-mark bol)))
	


                

aaa     aaaa    aaaa    aa

         aaaaaaaaaa            

(defun dp-add-buffer-endicator (&optional file)
  "Add a glyph to denote EOF.
Copped from the XEmacs FAQ."
  (interactive)
  (let ((ext (make-extent (point-min) (point-max)))
	(graphic (if file
		     `[xpm :file ,file]
		   '[xpm :data "\
     /* XPM */
     static char* eye = {
     \"20 11 7 2\",
     \"__ c None\"
     \"_` c #7f7f7f\",
     \"_a c #fefefe\",
     \"_b c #7f0000\",
     \"_c c #fefe00\",
     \"_d c #fe0000\",
     \"_e c #bfbfbf\",
     \"___________`_`_`___b_b_b_b_________`____\",
     \"_________`_`_`___b_c_c_c_b_b____________\",
     \"_____`_`_`_e___b_b_c_c_c___b___b_______`\",
     \"___`_`_e_a___b_b_d___b___b___b___b______\",
     \"_`_`_e_a_e___b_b_d_b___b___b___b___b____\",
     \"_`_`_a_e_a___b_b_d___b___b___b___b___b__\",
     \"_`_`_e_a_e___b_b_d_b___b___b___b___b_b__\",
     \"___`_`_e_a___b_b_b_d_c___b___b___d_b____\",
     \"_____`_`_e_e___b_b_b_d_c___b_b_d_b______\",
     \"_`_____`_`_`_`___b_b_b_d_d_d_d_b________\",
     \"___`_____`_`_`_`___b_b_b_b_b_b__________\",
     } ;"])))

    (set-extent-property ext 'start-closed t)
    (set-extent-property ext 'end-closed t)
    (set-extent-property ext 'detachable nil)
    (set-extent-end-glyph ext (make-glyph `( ,graphic
					    [string :data "[END]"])))))

(defun dp-add-buffer-endicator2 (&optional file)
  "Add a glyph to denote EOF.
Copped from the XEmacs FAQ."
  (interactive)
  (let ((ext (make-extent (point-min) (point-max))))
    (set-extent-property ext 'start-closed t)
    (set-extent-property ext 'end-closed t)
    (set-extent-property ext 'detachable nil)
    (set-extent-end-glyph ext (make-glyph '([string :data "[END]"])))))


RFC-2229
(setq ffap-rfc-path
      (concat (ffap-host-to-path "ftp.isi.edu") "/in-notes/rfc%s.txt"))
"/ftp.isi.edu:/in-notes/rfc%s.txt"

(setq ffap-rfc-path
      (concat (ffap-host-to-path "ftp.rfc-editor.org") "/in-notes/rfc%s.txt"))
"/ftp.rfc-editor.org:/in-notes/rfc%s.txt"

(defun dp-mark-line2 (&optional text-only)
  "Mark the line point is on.
If text-only is non-nil, then shrink-wrap the mark aound just the non-white
space on the line."
  (interactive "P")
  (let (bol)
    (beginning-of-line)
    (if text-only 
	(skip-chars-forward " 	" (line-end-position)))
    (setq bol (point))
    (end-of-line)
    (if text-only
	(skip-chars-backward " 	" bol)
      (if (not (eobp))
	  (forward-char 1)
	;; if we're deleting the last line in the file, we want to delete
	;; the newline from the preceeding line, otherwise we leave an
	;; empty line at the end of the file.
	(if (> bol (point-min))
	    (setq bol (1- bol)))))
    (dp-set-mark bol)))


(defun man2 ()
  (interactive)
  (split-window-vertically)
  (call-interactively 'manual-entry))


(defun auctex-setup ()
  (interactive)
  (require 'tex-site)
  (add-to-list 'auto-mode-alist '("\\.latex$" . latex-mode))
  (if window-system
      (progn
	(require 'font-latex)
	(add-hook 'latex-mode-hook 'turn-on-font-lock 'append)
	(add-hook 'LaTeX-mode-hook 'turn-on-font-lock 'append))))


(defun dp-file-link-at-point ()
  (interactive)
  (save-excursion
    (let (str str-end)
      (if (looking-at "\\s-\\|\n")
	  (skip-chars-backward " 	")
	(skip-chars-forward "^ 	\n"))
      (setq str-end (point))
      (skip-chars-backward "^ 	\n")
      (setq str (buffer-substring (point) str-end))
      (message "str>%s<" str)
      str)))

(defun dp-goto-file+re (&optional str)
  (interactive)
  (unless str
    (setq str (dp-file-link-at-point)))
  (message "str>%s<" str)
  (let* ((nlist (split-string str "#"))
	 (fname (car nlist))
	 (pat (car (cdr nlist))))
    (message "fname>%s<, pat>%s<" fname pat)
    (find-file fname)
    (goto-char (point-min))
    (if (re-search-forward (concat "^" pat) nil t)
	(beginning-of-line)
      (message "Cannot find definition of `%s'" pat)))) 
    
dp-goto-file+re#blah 


(defun dp-fap (&optional pos)
  (interactive)
  (let ((loc (thing-filename (or pos (point)))))
    (buffer-substring (car loc) (cdr loc))))

(dp-fap 36089)
"blah"

"dp-goto-file+re#blah"

"file+re#blah"


	      (dp-error-parse-region (dp-comint-last-cmd-pos) (point-max))

(defun dp-error-parse-point-to-end ()
  "Parse errors from point to end of buffer.  We narrow the buf to be
point to EOB to reduce the amount of parsing that is needed."
  (dp-error-parse-region (save-excursion
			   (forward-line -2)
			   (line-beginning-position))
			 (point-max)))
  

(defun dp-shell-goto-this-error ()
 "Goto the error at point in the shell buffer.  
This has the fortunate side effect of setting 
things up so that dp-next-error (\\[dp-next-error]) 
picks up right after the error we just visited."
 (interactive)
 (when (dp-maybe-add-compilation-minor-mode)
   (dp-error-parse-point-to-end)
   (compile-goto-error)))


;; grab conditional off current line, jump fwd to #endif and insert
;; as comment

(defun dp-comment-endif ()
  "Grab conditional off current line, jump fwd to #endif and insert as comment"
  (interactive)
  (let (line)
    (save-excursion
      (beginning-of-line)
      (dp-mark-line)
      (setq line (buffer-substring (mark) (1- (point))))
      (hif-ifdef-to-endif)
      (beginning-of-line)
      (re-search-forward "#\\s-*endif\\(.*\\)$" nil t)
      (delete-region (match-beginning 1) (match-end 1))
      (end-of-line)
      (insert " /* " line " */"))))
  
#if defined(aaaaa)

blah

#endif /* #if defined(aaaaa) */


(defun dp-insert-diary-appt		  


>(point-max) 888

-1          0   1   2   3
(point-min) 199 300 457 (point-max)
                                     .

index = -1
while more items
 if item position > cursor position
    done

index is item we are in.

if going backwards
   if point == pos[index]
      index-- with wrap
   else
      index = index
else
   index ++ with wrap

goto pos[index]


(defun dp-move-to-cmd-start (direction &optional current-pos)
  "Move to the place where a command started."
  (interactive)
  (let ((index 0)
	(loopf t)
	stop-index)
    (unless current-pos
      (setq current-pos (point)))
    (setq index (ring-minus1 dp-comint-last-cmd-ring
			     (ring-length dp-comint-last-cmd-ring)))
    (setq stop-index index)
    (message "yopp")
    (while loopf
      (message "ring-pos: %s, current-pos: %s" 
	       (ring-ref dp-comint-last-cmd-ring index)
	       current-pos)
      (if (> (ring-ref dp-comint-last-cmd-ring index)
	     current-pos)
	  (setq loopf nil)
	(setq index (ring-minus1 dp-comint-last-cmd-ring
				 (ring-length dp-comint-last-cmd-ring)))
	(setq loopf (= index stop-index))))
    (message "index: %s, pos: %s" 
	     index (ring-ref 
		    dp-comint-last-cmd-ring index))
    (setq index (ring-plus1 dp-comint-last-cmd-ring
				 (ring-length dp-comint-last-cmd-ring)))
    (message "index: %s, pos: %s" 
	     index (ring-ref 
		    dp-comint-last-cmd-ring index))))




(setq lll nil)
nil
(setq lll (append lll 123))
(cons '(1 2 3) 4)
((1 2 3) . 4)
(list '(1 2 3) 4)
((1 2 3) 4)

(setq lll nil)
nil
(setq lll (append lll  (list 187)))
(99 187)

(99)


97
lll
97
      


((eval cons (if shell-prompt-pattern-for-font-lock shell-prompt-pattern-for-font-lock shell-prompt-pattern) shell-prompt-face) ("[ 	]\\([+-][^ 	
>]+\\)" 1 shell-option-face) ("^[^ 	
]+:.*" . shell-output-2-face) ("^\\[[1-9][0-9]*\\]" . shell-output-3-face) ("^[^
]+.*$" . shell-output-face))

(setq shell-font-lock-keywords
'(
  ("^[^~\n]*~:[0-9]+:.*$" . shell-uninteresting-face)
  (eval cons (if shell-prompt-pattern-for-font-lock shell-prompt-pattern-for-font-lock shell-prompt-pattern) shell-prompt-face) 
  ("[ 	]\\([+-][^ 	
>]+\\)" 1 shell-option-face) 
  ("^[^ 	
]+:.*" . shell-output-2-face) 
  ("^\\[[1-9][0-9]*\\]" . shell-output-3-face) 
  ("^[^
]+.*$" . shell-output-face)
  ))


Value: (("^[^~\n]*~:[0-9]+:.*$" . shell-uninteresting-face) (eval cons (if shell-prompt-pattern-for-font-lock shell-prompt-pattern-for-font-lock shell-prompt-pattern) shell-prompt-face) ("[ 	]\\([+-][^ 	\n>]+\\)" 1 shell-option-face) ("^[^ 	\n]+:.*" . shell-output-2-face) ("^\\[[1-9][0-9]*\\]" . shell-output-3-face) ("^[^\n]+.*$" . shell-output-face))

(defcustom shell-uninteresting-face 'shell-uninteresting-face
  "Face for shell output which is uninteresting."
  :type 'face
  :group 'shell-faces)

(make-face shell-uninteresting-face)
#<face shell-uninteresting-face>


(setq l2 '( ("p1" f1) ("p2" f2)))
(("p1" f1) ("p2" f2))

(append (list '("p3" f3)) l2)
(("p3" f3) ("p1" f1) ("p2" f2))

("p3" f3 ("p1" f1) ("p2" f2))

shell-font-lock-keywords
'(
  ("^[^~
]*~:[0-9]+:.*$" . shell-uninteresting-face) 
  (eval cons (if shell-prompt-pattern-for-font-lock shell-prompt-pattern-for-font-lock shell-prompt-pattern) shell-prompt-face) ("[ 	]\\([+-][^ 	
>]+\\)" 1 shell-option-face) ("^[^ 	
]+:.*" . shell-output-2-face) ("^\\[[1-9][0-9]*\\]" . shell-output-3-face) ("^[^
]+.*$" . shell-output-face))



(setq shell-font-lock-keywords
  (list '(eval . (cons (if shell-prompt-pattern-for-font-lock
			   shell-prompt-pattern-for-font-lock
			 shell-prompt-pattern)
		       shell-prompt-face))
	'("^[^~\n]*~:[0-9]+:.*$" . shell-uninteresting-face)
	'("^[-_.\"A-Za-z0-9/+]+\\(:\\|, line \\)[0-9]+: \\([wW]arning:\\).*$" .
	  font-lock-keyword-face)
	'("^[-_.\"A-Za-z0-9/+]+\\(: *\\|, line \\)[0-9]+:.*$" . font-lock-function-name-face)
	'("\\(^[-_.\"A-Za-z0-9/+]+\\)\\(: *\\|, line \\)[0-9]+" 1 font-lock-string-face t)
	'("^[-_.\"A-Za-z0-9/+]+\\(: *[0-9]+\\|, line [0-9]+\\)" 1 bold t)
	'("^[^\n]+.*$" . shell-output-face)))

(defvar compilation-font-lock-keywords (purecopy
  (list
   '("^[-_.\"A-Za-z0-9/+]+\\(:\\|, line \\)[0-9]+: \\([wW]arning:\\).*$" .
     font-lock-keyword-face) ;; red4
   '("^[-_.\"A-Za-z0-9/+]+\\(: *\\|, line \\)[0-9]+:.*$" . font-lock-function-name-face) ;; brown4 (looks like red4)
   '("^[^:\n]+-[a-zA-Z][^:\n]+$" . font-lock-doc-string-face) ;; green4
   '("\\(^[-_.\"A-Za-z0-9/+]+\\)\\(: *\\|, line \\)[0-9]+" 1 font-lock-string-face t) ;; green4
   '("^[-_.\"A-Za-z0-9/+]+\\(: *[0-9]+\\|, line [0-9]+\\)" 1 bold t)
   ))
  "Additional expressions to highlight in Compilation mode.")

grep stuff looks:
green.file.name:bold_number:red_match

(car compilation-font-lock-keywords)
("^[-_.\"A-Za-z0-9/+]+\\(:\\|, line \\)[0-9]+: \\([wW]arning:\\).*$" . font-lock-keyword-face)

(("^[-_.\"A-Za-z0-9/+]+\\(:\\|, line \\)[0-9]+: \\([wW]arning:\\).*$" . font-lock-keyword-face) ("^[-_.\"A-Za-z0-9/+]+\\(: *\\|, line \\)[0-9]+:.*$" . font-lock-function-name-face) ("^[^:
]+-[a-zA-Z][^:
]+$" . font-lock-doc-string-face) ("\\(^[-_.\"A-Za-z0-9/+]+\\)\\(: *\\|, line \\)[0-9]+" 1 font-lock-string-face t) ("^[-_.\"A-Za-z0-9/+]+\\(: *[0-9]+\\|, line [0-9]+\\)" 1 bold t))

(list "a" '(a b) "c")
("a" (a b) "c")

(defun dp-hif-find-next-relevant ()
  (interactive)
  (let* ((hif-else-regexp (concat hif-cpp-prefix "el\\(se\\|if\\)"))
	 (hif-ifx-else-endif-regexp (concat 
				     hif-ifx-regexp "\\|" 
				     hif-else-regexp "\\|" hif-endif-regexp)))
    (hif-find-next-relevant)))

(defun dp-find-ifdef-clause ()
  (interactive)
  (let (ifdef-item
	status)
    (setq status 
	  (catch 'status
	    (while t
	      (dp-hif-find-next-relevant)
	      (setq ifdef-item (dp-get-ifdef-item))
	      (if (not (eq ifdef-item 'dp-if))
		  (throw 'status 'found)
		(hif-ifdef-to-endif)
		(forward-line 1)))))))


;:*=======================
;:* Put the mouse selection in the kill buffer
;: Jan Vroonhof <vroonhof @ frege.math.ethz.ch>
(defun mouse-track-drag-copy-to-kill (event count)
  "Copy the dragged region to the kill ring"
  (let ((region (default-mouse-track-return-dragged-selection event)))
    (when region
      (copy-region-as-kill (car region)
			   (cdr region)))
    nil))
(add-hook 'mouse-track-drag-up-hook 'mouse-track-drag-copy-to-kill)  


;:*=======================
;:* create a Kill-Ring menu
(defvar yank-menu-length 40
  "*Maximum length of an item in the menu for select-and-yank.")
(defun select-and-yank-filter (menu)
  (message "menu>%s<" menu)
  (let* ((count 0))
    (append menu
	    (mapcar
	     #'(lambda (str)
		 (if (> (length str) yank-menu-length)
		     (setq str (substring str 0 yank-menu-length)))
		 (prog1
		     (vector
		      str
		      (list
		       'progn
		       '(push-mark (point))
		       (list 'insert (list 'current-kill count t)))
		      t)
		   (setq count (1+ count))))
	     kill-ring))))

(add-submenu nil '("Kill-Ring"
		   :included kill-ring
		   :filter select-and-yank-filter))


;:* describe-face-at-point, a function to find out which face is which
(defun describe-face-at-point ()
  "Return face used at point."
  (interactive)
  (hyper-describe-face (get-char-property (point) 'face)))

(add-hook 'font-lock-mode-hook 'turn-on-lazy-shot)
(turn-on-lazy-shot)

font-lock-mode-hook
nil

(turn-on-lazy-lock)

(remove-hook 'font-lock-mode-hook 'turn-on-lazy-lock)
nil
[ 1 2 3]
[1 2 3]


;; no keyboard selection :-<
(popup-menu (append `("Kills"
		      "Do nothing text"
		      "-")
		    (select-and-yank-filter nil)))
nil

nil





(append `("Kills"
	  "Do nothing text"
	  "-")
	(select-and-yank-filter nil))

(append '(1 2 3) '(a b c))
(1 2 3 a b c)

((1 2 3) a b c)

'(lambda () (message "hi"))
(lambda nil (message "hi"))

(lambda nil (message "hi"))


(defun dp-customize ()
  "Customize my variables."
  (let ((custom-file "~/lisp/dp-custom-vars.el"))
    (customize


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

(setq olist '((1 . "one") (2 . "too")))
((1 . "one") (2 . "too"))

((1 . "one") (2 . "too"))

(assoc 3 olist)
nil

(2 . "too")

(1 . "one")

(dp-update-alist 'olist '((2 . "two") (4 . "four")))
((4 . "four") (1 . "one") (2 . "two"))


c-hanging-braces-alist
set-from-style
dp-hb-alist
((brace-list-close after))

((brace-list-close after) (brace-list-open) (brace-entry-open) (substatement-open after) (block-close . c-snug-do-while) (extern-lang-open after) (inexpr-class-open after) (inexpr-class-close before))

((brace-list-close after) (brace-list-open) (brace-entry-open) (substatement-open after) (block-close . c-snug-do-while) (extern-lang-open after) (inexpr-class-open after) (inexpr-class-close before))

((brace-list-open) (brace-entry-open) (substatement-open after) (block-close . c-snug-do-while) (extern-lang-open after) (inexpr-class-open after) (inexpr-class-close before))


(defun dp-insert-fc (fc-file)
  "Read a function comment header block after point.
XXX: use tempo for this?"
  (interactive "*")
  (beginning-of-line)
  (let ((rc (insert-file-contents fc-file))
	p m)
    ;; indent the inserted text.  this makes it work inside
    ;; class defs, too.
    (setq p (point))
    (setq m (+ p (car (cdr rc))))
    (message "p>%s<, m>%d<" p m)
    (indent-region p m nil)
    ;; goto cursor position if specified...
    (when (re-search-forward "<cursor>" nil t)
      (replace-match "" nil nil)
      (message "done with %s" fc-file ))))

;;
;; FE: Make these detect whether we are in a class def or not and insert 
;; proper header
;; in c++ && syntax is inclass --> cfc else fc
;;
(defun fc ()
  "Read the function definition comment header block after point."
  (interactive "*")
  (dp-insert-fc function-comment-file))


(defun dp-face-at (&optional pos)
  "Print name of face at POS.  Use (point) if nil."
  (interactive)
  (unless pos
    (setq pos (point)))
  (message "%s"
	   (extent-face (extent-at (point)))))


;;; ********************
;;; Filladapt is a syntax-highlighting package.  When it is enabled it
;;; makes filling (e.g. using M-q) much much smarter about paragraphs
;;; that are indented and/or are set off with semicolons, dashes, etc.

(dp-optionally-require 'filladapt)
(setq-default filladapt-mode t)
(when (fboundp 'turn-off-filladapt-mode)
  (add-hook 'c-mode-hook 'turn-off-filladapt-mode)
  (add-hook 'outline-mode-hook 'turn-off-filladapt-mode)
  (setq filladapt-mode-line-string " FA"))


minor-mode-alist
(defun dp-set-minor-mode-modeline-id (minor-mode &optional id)
  (interactive)
  (and (assoc minor-mode minor-mode-alist)
       (setcdr (cdr (cadr (assoc minor-mode minor-mode-alist))) 
	       (or id ""))))

(dp-nuke-minor-mode-modeline-id 'font-lock-mode)
""

;; this is a bunch of text in lisp comments.  in order to test
;; filladapt mode i've had to type a whole bunch of bogus stuff to
;; make the test interesting.


(if (featurep 'xpm)
    (let ((file (expand-file-name "recycle.xpm" data-directory)))
      (if (condition-case nil
	      ;; check to make sure we can use the pointer.
	      (make-image-instance file nil
				   '(pointer))
	    (error nil))		; returns nil if an error occurred.
	  (set-glyph-image gc-pointer-glyph file))))


(global-set-key "\e1" (function (lambda () 
				  (interactive) (dp-set-or-goto-bm 1 nil))))

(global-set-key [(control meta ?9)] (function (lambda () 
				  (interactive) (message "yopp!"))))
(defmacro def-bm-key (digit)
  `(progn
     ;; M-<digit> set bm if unset, goto otherwise
     (global-set-key (format "\e%d" ,digit)
       (function (lambda () 
		   (interactive) (dp-set-or-goto-bm ,digit nil))))
     ;; unconditionally set bm
     (global-set-key (read-kbd-macro (format "C-M-%d" ,digit))
       (function (lambda () 
		   (interactive) (dp-set-or-goto-bm ,digit t))))))

(defun def-bm-key (digit)
  ;; M-<digit> set bm if unset, goto bm otherwise
  (global-set-key (format "\e%d" digit)
    `(lambda () 
       (interactive) (dp-set-or-goto-bm ,digit nil)))
     ;; unconditionally set bm
     (global-set-key (read-kbd-macro (format "C-M-%d" digit))
       `(lambda () 
	  (interactive) (dp-set-or-goto-bm ,digit t))))

(mapc (function (lambda (key)
		  (message "%s" key)
		  (eval (def-bm-key key))))
      '(0 1 2 3 4 5 6 7 8 9))



(setq k 9)
9

(macroexpand '(def-bm-key k))
(progn (global-set-key (format "%d" k) (function (lambda nil (interactive) (dp-set-or-goto-bm k nil)))) (global-set-key (read-kbd-macro (format "C-M-%d" k)) (function (lambda nil (interactive) (dp-set-or-goto-bm k t)))))





(read-kbd-macro (format "C-M-%d" 9))
[(control meta ?9)]

[(control meta ?9)]


(defun (dp-init-require feature &optional file-name noerror)
  "Load an init file, recording the name."
  (let ((load-name (or file-name (prin1-to-string feature))))
    (eval-after-load load-name 
      `(progn
	 (dp-add-file-to-init-list ,load-name)))
    (condition-case error-info
	(progn
	  (require feature file-name noerror)
	  (
      
      
      (error 
       (error "**** Problem in (dp-init-require %s %s): %s" 
	      feature file-name error-info))))


========================
2001-12-28T12:49:41
--

(defvar dp-src-glob 
  "*.[Cc] *.cxx *.c++ *.cc *.py *.pl *.sh"
  "Src file types.")

(defvar dp-h-glob
  "*.[Hh] *.hxx *.h++ *.hh *.inl *.inc"
  "Include file types.")

(defvar dp-mgmt-glob
  "[Mm]akefile *.mak *.mk"
  "Code management file")


(defvar dp-code-glob (concat dp-src-glob " " dp-h-glob " " dp-mgmt-glob)
  "All code type files type.")
  
cgrep - code grep
sgrep - src grep
hgrep - header grep
mgrep - mgmt grep
each of these will make the corresponding glob type the default.

(grep (concat "grep " dp-code-glob))
#<compiled-function (proc msg) "...(53)" [msg proc code process-exit-status process-status exit 0 format "finished (%d matches found)
" count-lines 2 "matched" 1 ("finished with no matches found
" . "no match")] 5>

(defun dp-term-mode-key (&optional keys)
  (interactive)
  (setq keys last-input-event)
  (message "%s" keys)
  (let ((saved-map (current-local-map))
	cmd
	(keymap (if (>= (point) (dp-current-pmark-pos))
		    term-raw-map
		  term-old-mode-map)))
    (unwind-protect
	(progn
	  (message "%s" keymap)
	  (use-local-map keymap)
	  (setq cmd (key-binding keys))
	  (message "%s" cmd)
	  (command-execute cmd)
	  (message "cmd done.")
	  )
      
      (use-local-map saved-map))))
    
(defun dp-term-setup ()
  (interactive)
  (let ((map (make-keymap)))
    (set-keymap-default-binding map 'dp-term-mode-key)
    (use-local-map map)))


(directory-files )

(car (read-from-string (format "'%s-%s" "term" "previous-input")))
(quote term-previous-input)
term-previous-input

(format "%s" nil)
"nil"

"booger"


'term-previous-input
term-previous-input

((quote term-previous-input) . 20)

(defun dp-sl-sym (variant sym)
  (car (read-from-string (format "'%s%s" variant sym))))
dp-sl-sym

(dp-sl-sym 'term '-next-input)
(quote term-next-input)
term-next-input

(local-set-key [up] (function (lambda ()
				(interactive)
				(dp-shell-previous-input
				 'term-after-pmark-p 
				 'term-previous-input))))




(dp-sl-fun 'term 



(defun dp-shell-like-mode-hook (variant)
  "Sets up personal comint mode options.
Called when shell, inferior-lisp-process, etc. are entered."
  (local-set-key [up] 'dp-comint-previous-input)
  (local-set-key [down] 'dp-comint-next-input)
  (local-set-key "\en" 'bury-buffer)
  (local-set-key [home] 'comint-bol)
  (local-set-key (kbd "<C-up>") 'dp-scroll-down)
  (local-set-key (kbd "<C-down>") 'dp-scroll-up)
  (local-set-key (kbd "<M-left>") 'dp-comint-goto-prev-cmd-pos)
  (local-set-key (kbd "<M-right>") 'dp-comint-goto-next-cmd-pos)
  (local-set-key (kbd "<C-M-l>") 'dp-clr-shell)
  (local-set-key "\C-z" 'dp-comint-init-last-cmds)
  (local-set-key "\e`" 'comint-previous-matching-input-from-input)

  (message "dp-comint-mode-hook, mode-name>%s<, bn>%s<" 
	   mode-name (buffer-name))
)


(add-hook 'post-command-hook 'dp-term-set-mode-from-pos)
(dp-term-set-mode-from-pos lazy-lock-post-command-fontify-stealthily)

(defvar dp-cleanup-buffers-list
  '(("^\\*Help:" . help-mode)
    ("^\\*Completions" . completion-list-mode)
    ("^Man" . Manual-mode)
    ("^\\*Hyper Apropos\\*" . hyper-apropos-mode)
    ("^\\*Hyper Help\\*" . hyper-apropos-help-mode)
    ))

(defun dp-name-and-mode-match (buf match-list)
  (let (buf-name
	buf-mode)
    (with-current-buffer buf
      (setq buf-name (buffer-name))
      (setq buf-mode major-mode))
    
    (catch 'killit
      (while match-list
	(let* ((el (car match-list))
	       (kill-re (car el))
	       (kill-mode (cdr el)))
	  (setq match-list (cdr match-list))
	  ;;(message "kill-re>%s<, kill-mode>%s<" kill-re kill-mode)
	  ;;(message "buf-mode>%s<" buf-mode)
	  (if (and (string-match kill-re buf-name)
		   (eq buf-mode kill-mode))
	      (throw 'killit t))))
      nil)))

(defvar dp-cleanup-buffers-mode-list
  '(help-mode
    completion-list-mode
    Manual-mode
    hyper-apropos-mode
    hyper-apropos-help-mode)
  "List of major modes to be automatically deleted in a cleanup)

(defun dp-cleanup-buffers (&optional list)
  "For each buffer in LIST, compare to kill regexp and
kill if matches."
  (interactive)
  (if (null list)
      (setq list (buffer-list)))
  (while list
    (let* ((buf (car list))
	   (name (buffer-name buf)))
      (setq list (cdr list))
      ;;(message "look at>%s<" (buffer-name buf))
      (and (or (not (buffer-modified-p buf))
	       (not (buffer-file-name buf)))
	   ;;(dp-name-and-mode-match buf dp-cleanup-buffers-list)
	   (memq (with-current-buffer buf
		   major-mode)
		 dp-cleanup-buffers-mode-list)
	   (message "ta-ta>%s<" (buffer-name buf))
	   (kill-buffer buf)
	   ))))


(defun ediff-exec-process (program buffer synch options &rest files)
  (let ((data (match-data))
	(coding-system-for-read ediff-coding-system-for-read)
	args)
    (message "0, p>%s<, o>%s<" program options)
    (setq args (append (split-string options) files))
    (setq args (delete "" (delq nil args))) ; delete nil and "" from arguments
    ;; the --binary option, if present, should be used only for buffer jobs
    ;; or for refining the differences
    (or (string-match "buffer" (symbol-name ediff-job-name))
	(eq buffer ediff-fine-diff-buffer)
	(setq args (delete "--binary" args)))
    (unwind-protect
	(let ((directory default-directory)
	      proc)
	  (save-excursion
	    (set-buffer buffer)
	    (erase-buffer)
	    (setq default-directory directory)
	    (message "1, p>%s<, a>%s<, bn>%s<" program args (buffer-name))

	    (if (or (memq system-type '(emx ms-dos windows-nt windows-95))
		    synch)
		;; In OS/2 (emx) do it synchronously, since OS/2 doesn't let us
		;; delete files used by other processes. Thus, in ediff-buffers
		;; and similar functions, we can't delete temp files because
		;; they might be used by the asynch process that computes
		;; custom diffs. So, we have to wait till custom diff
		;; subprocess is done.
		;; Similarly for Windows-*
		;; In DOS, must synchronize because DOS doesn't have
		;; asynchronous processes.
		(progn
		  (message "2, p>%s<, o>%s<, bn>%s<" program args
			   (buffer-name))
		  (apply 'call-process program nil buffer nil args))
	      ;; On other systems, do it asynchronously.
	      (setq proc (get-buffer-process buffer))
	      (if proc (kill-process proc))
	      (setq proc
		    (apply 'start-process "Custom Diff" buffer program args))
	      (setq mode-line-process '(":%s"))
	      (set-process-sentinel proc 'ediff-process-sentinel)
	      (set-process-filter proc 'ediff-process-filter)
	      )))
      (store-match-data data))))



(defun dp-ediff-after-setup-windows-hook ()
  (remove-hook 'ediff-after-setup-windows-hook 
	       'dp-ediff-after-setup-windows-hook)
  (ediff-toggle-split))

(defun dp-ediff-before-setup-hook ()
  (add-hook 'ediff-after-setup-windows-hook 
	    'dp-ediff-after-setup-windows-hook))

(add-hook 'ediff-before-setup-hook 'dp-ediff-before-setup-hook)


(defun dp-insert-glyph (&optional glyph)
  "Add a glyph to denote EOF.
Copped from the XEmacs FAQ."
  (interactive)
  (let ((ext (make-extent (point) (point))))

    (set-extent-property ext 'start-closed t)
    (set-extent-property ext 'end-closed t)
    (set-extent-property ext 'detachable t)
    (set-extent-property ext 'dp-glyph t) ; tag for identification
    (set-extent-end-glyph ext glyph)
    ))

(defun dp-insert-invis-glyph ()
  (interactive)
  (dp-insert-glyph invisible-text-glyph))
		       
(mapcar (lambda (ext)
	  (extent-properties ext))
	(extent-list (get-buffer "x.jxt")))
((end-glyph #<glyph (buffer) #<image-specifier global=(((x) . [xpm :color-symbols (("foregroundToolBarColor" . #<color-specifier global=<unspecified> fallback=#<color-specifier global=<unspecified> fallback=(((tty) . []) ((x) . "black")) 0x1dc> 0x20c>) ("backgroundToolBarColor" . #<color-specifier global=<unspecified> fallback=#<color-specifier global=((x) . "#d3d3da") fallback=(((tty) . []) ((x) . "Gray80")) 0x1de> 0x20e>) ("background" . #<color-specifier global=((x) . "#d3d3da") fallback=(((tty) . []) ((x) . "white")) 0x1c5>) ("foreground" . #<color-specifier global=((default x) . "black") fallback=(((tty) . []) ((x) . "black")) 0x1c3>)) :data "/* XPM */
static char * chuck_xpm[] = {
\"25 28 12 1\",
\" 	s None	c None\",
\".	c #FFFF65956595\",
\"X	c # ..."]) ((tty) . [xpm :color-symbols (("foregroundToolBarColor" . #<color-specifier global=<unspecified> fallback=#<color-specifier global=<unspecified> fallback=(((tty) . []) ((x) . "black")) 0x1dc> 0x20c>) ("backgroundToolBarColor" . #<color-specifier global=<unspecified> fallback=#<color-specifier global=((x) . "#d3d3da") fallback=(((tty) . []) ((x) . "Gray80")) 0x1de> 0x20e>) ("background" . #<color-specifier global=((x) . "#d3d3da") fallback=(((tty) . []) ((x) . "white")) 0x1c5>) ("foreground" . #<color-specifier global=((default x) . "black") fallback=(((tty) . []) ((x) . "black")) 0x1c3>)) :data "/* XPM */
static char * chuck_xpm[] = {
\"25 28 12 1\",
\" 	s None	c None\",
\".	c #FFFF65956595\",
\"X	c # ..."]) ((stream) . [xpm :color-symbols (("foregroundToolBarColor" . #<color-specifier global=<unspecified> fallback=#<color-specifier global=<unspecified> fallback=(((tty) . []) ((x) . "black")) 0x1dc> 0x20c>) ("backgroundToolBarColor" . #<color-specifier global=<unspecified> fallback=#<color-specifier global=((x) . "#d3d3da") fallback=(((tty) . []) ((x) . "Gray80")) 0x1de> 0x20e>) ("background" . #<color-specifier global=((x) . "#d3d3da") fallback=(((tty) . []) ((x) . "white")) 0x1c5>) ("foreground" . #<color-specifier global=((default x) . "black") fallback=(((tty) . []) ((x) . "black")) 0x1c3>)) :data "/* XPM */
static char * chuck_xpm[] = {
\"25 28 12 1\",
\" 	s None	c None\",
\".	c #FFFF65956595\",
\"X	c # ..."]) ((x) . [string :data "[END]"]) ((tty) . [string :data "[END]"]) ((stream) . [string :data "[END]"])) fallback=((nil . [nothing])) 0xb214>0xb213> dp-buffer-endicator t) 
(detachable t end-open t invisible t dpj-extent t) 
(detachable t end-open t invisible t dpj-extent t) 
(detachable t end-open t invisible t dpj-extent t) 
(detachable t end-open t invisible t dpj-extent t) 
(detachable t end-open t invisible t dpj-extent t) 
(detachable t end-open t invisible t dpj-extent t) 
(detachable t end-open t invisible t dpj-extent t))

(defmacro def-fmessage2 (&rest rest)
  (defmacro fmessage 



(defmacro def-fmessage (&optional name name2 name3)
  `(progn
     (setq name (or ,name
		    (file-relative-name (buffer-file-name))))
     (set (intern (concat ,name "-debug")) nil)
     (defmacro fmessage (&rest rest)
       '(if (symbol-value (intern (concat ,name "-debug")))
	   (message (concat ,name ": " 
			    (apply 'format (quote (backquote ,rest)))))))))
def-fmessage

(eval '(list 'a 'b `,xx))
(a b "xxyyzztt")


(list 'a 'b '(backquote (\, xx)))
(a b (backquote (\, xx)))

(a b "xxyyzztt")



(a b (backquote (\, xx)))

(a b xx)


`( 1 2 (a b) '(backquote c d))
(1 2 (a b) (quote (quote c)))

(1 2 (a b) (quote c))

(1 2 (a b) (quote (c d)))

(1 2 (a b))


(defmacro def-fmessage (&optional name on-off)
  (list 'progn
     `(setq name (or ,name
		    (file-relative-name (buffer-file-name))))
     `(set (intern (concat ,name "-debug")) ,on-off)
     (list 'defmacro 'fmessage '(&rest rest)
	   '(list 'if (list 'symbol-value 
			   (list 'intern `(concat ,name "-debug")))
		 (quote (message (apply 'format '`( ,@ rest))))))))
def-fmessage

(defmacro def-fmessage (&optional name on-off)
  (list 'progn
     `(setq name (or ,name
		    (file-relative-name (buffer-file-name))))
     `(set (intern (concat ,name "-debug")) ,on-off)
     (list 'defmacro 'fmessage '(&rest rest)
	   (list 'if (list 'symbol-value 
			   (list 'intern `(concat ,name "-debug")))
		 (list 'message '(apply 'format '(list ,@ rest)))))))
def-fmessage

def-fmessage

(list 'message (list 'apply ''format `(list ,@ rest))))
(progn 
  (def-fmessage "bubba" nil)
  (setq bubba-debug t))
t



(macroexpand '(def-fmessage "bubba" ))
(progn (setq name (or "bubba" (file-relative-name (buffer-file-name)))) (set (intern (concat "bubba" "-debug")) nil) (defmacro fmessage (&rest rest) (list (quote if) (list (quote symbol-value) (list (quote intern) (backquote (concat (\, name) "-debug")))) (quote (message (apply (quote format) (quote (backquote ((\,@ rest))))))))))



(macroexpand '(fmessage "oops, x>%s<" xx))
(if (symbol-value (intern (concat "bubba" "-debug"))) (message (apply (quote format) (quote (backquote ((\,@ rest)))))))

(fmessage "oops, x>%s<" xx)






(symbol-function 'def-fmessage)

(symbol-function 'fmessage)
(macro lambda (&rest rest) (if (symbol-value (intern (concat "bubba" "-debug"))) (message (apply (quote format) (backquote (list (\,@ rest)))))))







(symbol-function 'pmsg)
(macro lambda (&rest rest) (list (quote message) (list (quote apply) (quote (quote format)) (backquote (list (\,@ rest))))))






(defmacro pmsg (&rest rest)
  (list 'apply ''message ,rest))

(defmacro pmsg (&rest rest)
  (list 'message (list 'apply ''format `(list ,@ rest))))
pmsg

(symbol-function 'pmsg)
(macro lambda (&rest rest) (list (quote message) (list (quote apply) (quote (quote format)) (backquote (list (\,@ rest))))))




(macroexpand '(pmsg "%s" xx))
(message (apply (quote format) (list "%s" xx)))


(pmsg "%s" xx)
"xxyyzztt"




(message (apply (quote format) (list "%s" xx)))
"xxyyzztt"

(setq  aaa `xx)
xx

"xxyyzztt"


(fmessage "foo:%s" xx)
"bubba: foo:xx"


(unless keep-others
  (let ((start nil)
	(end nil)
	tstart tend)
    (mapc (function
	   (lambda (topic-info)
	     (setq tstart (dpj-topic-info-start topic-info))
	     (setq tend   (dpj-topic-info-end   topic-info))
	     (if (null start)
		 (progn
		   (setq start tstart
			 end tend))

	       ;; start is not nil, see if current is contig w/last
	       ;; if so, move end to end of current
	       (if (= (1+ start) tstart)
		   (setq end tend)
		 ;; otherwise, process previous contig block
		 ;;(dmessage "show, topic-info>%s<" topic-info)
		 (dpj-highlight-region start end others-op)
		 (setq start tstart
		       end tend)))))
	  other-list)
    (if start
	(dpj-highlight-region start end others-op)

)

(require 'tempo)
(defvar doxy-class-function-comment-elements '("
  /*********************************************************************/
  /*!
   * @brief " (P "brief desc: " desc nil) "
   */")
  "Elements of a class function comment template")

(defvar doxy-function-comment-elements '("
/*********************************************************************/
/*!
 * @brief " (P "brief desc: " desc nil) "
 */")
  "Elements of a class function comment template")

          
(tempo-define-template "doxy-class-function-comment"
		        doxy-class-function-comment-elements)
(tempo-define-template "doxy-function-comment"
		        doxy-function-comment-elements)

(defun tempo-fc (template-func &optional no-indent)
  "Add a comment using a tempo template.
Please enter a brief description of the function at the prompt.
If NO-INDENT is non-nil (interactively with prefix arg) then
do not indent the newly inserted comment block."
  (beginning-of-line)
  (if (not (looking-at "^\\s-*$"))
      (save-excursion (insert "\n")))
  (let ((pt (point)))
    (funcall template-func)
    (if (and (not no-indent)
	     (fboundp 'c-indent-region))
	(c-indent-region pt (point)))))

(defun tcfc (&optional no-indent)
  "Add a tempo class function."
  (interactive)
  (tempo-fc 'tempo-template-doxy-class-function-comment no-indent))

(defun tfc (&optional no-indent)
  (interactive)
  "Add a tempo class function."
  (tempo-fc 'tempo-template-doxy-function-comment no-indent))

(defun dp-c-indent-for-comment ()
  (interactive)
  (indent-for-comment)
  (when (and (looking-at (concat (regexp-quote comment-end) "\n"))
	     (dp-in-c-arglist))
    (backward-char)
    (insert "!< ")))

(defun dpj-insert-topic-sorted (new)
  "Insert NEW into the current buffer in the properly sorted location."
  ;; get all of the topic
  (let ((topics (dpj-find-topics))
	(insert-point (point-min)))
    (catch 'done
      (while topics
	(when (dpj-topic-date-less new (dpj-get-timestamp (car topic)))
	  (goto-char insert-point)
	  (insert new "\n")
	  (throw 'done))
	(setq topics (cdr topics))))))


(defun dp-indent-for-comment

(defun comint-strip-ctrl-m (&optional string)
  "Strip trailing `^M' characters from the current output group.
This function could be on `comint-output-filter-functions' or bound to a key."
  (interactive)
  (let ((pmark (process-mark (get-buffer-process (current-buffer))))
	(pos (if (interactive-p) 
		  comint-last-input-end 
		comint-last-output-start)))
    (if (marker-position pos)
	(save-excursion
	  (goto-char pos)
	  (while (re-search-forward "\r+$" pmark t)
	    (replace-match "" t t))))))


(defun dp-maybe-add-c++-namespace (&optional namespace)
  "Expand a C++ abbrev unless we're in a comment."
  (interactive)
  (let ((namespace (concat (or namespace "std") "::")))
    (unless (dp-in-a-c-comment)
      (save-excursion
	(backward-word)
	(unless (save-excursion
		  (skip-chars-backward "[a-zA-Z_:]")
		  (looking-at namespace))
	  (insert namespace))))))

(defvar dp-c-type-list '("auto"
		 "char" "const" "double" "float" "int" "long" "register" 
		 "short" "signed" "struct" "union" "unsigned" "void" 
		 "volatile" "mutable"))
dp-c-type-list
("auto" "char" "const" "double" "float" "int" "long" "register" "short" "signed" "struct" "union" "unsigned" "void" "volatile" "mutable")

(defvar dp-c-types-re 
  (concat
   "\\<"
   "\\(static\\<\\S_+\\)?"
   "\\("
   (regexp-opt dp-c-type-list
	       'paren)
   "\\|"
   "\\(\\sw\\|\\s_\\)+_t"
   "\\)"
   "\\>"))
dp-c-types-re
"\\<\\(static\\<\\S_+\\)?\\(\\(?:auto\\|c\\(?:har\\|onst\\)\\|double\\|float\\|int\\|long\\|mutable\\|register\\|s\\(?:hort\\|igned\\|truct\\)\\|un\\(?:ion\\|signed\\)\\|vo\\(?:id\\|latile\\)\\)\\|\\(\\s_+_t\\)\\)\\>"


  size_t  max_elements;
  int  max_elements;

(string-match dp-c-type-decl-re "  size_t  max_elements;
")
2

2

2

7

nil

0


0

nil

nil


nil

nil










static

"auto"
"char"
"const"
"double"
"float"
"int"
"long"
"register"
"short"
"signed"
"struct"
"union"
"unsigned"
"void"
"volatile"
"mutable"  

(defun dpj-get-journal-file-interactive ()
  "Prompt for the file's month any year."
  (let* ((dlist (decode-time (current-time)))
	 (month (nth 4 dlist))
	 (year  (nth 5 dlist)))
    (setq month (read-from-minibuffer "month: " (format "%s" month)))
    (setq year  (read-from-minibuffer "year: " (format "%s" year)))
    (list month year)))

(defun dpj-edit-journal-file (month year)
  "Edit the journal file indicated by month and year."
  (interactive (dpj-get-journal-file-interactive))
  (find-file (dp-make-dated-note-file "daily" ".jxt" 'year-first
				      month year)))

(defun dpj-next-journal-file (incr)
  "Move to the next journal file, timewise.
INCR should be 1 or -1."
  (interactive)
  (let* ((jfile (file-name-sans-extension 
		 (file-name-nondirectory (buffer-file-name))))
	 (parts (split-string jfile "-"))
	 (year  (string-to-int (nth 1 parts)))
	 (month (string-to-int (nth 2 parts))))
    (if (> (setq month (+ month incr))
	   12)
	(progn
	  (setq month 12)
	  (setq year (+ year incr)))
      (if (< month 1)
	  (progn
	    (setq month 1)
	    (setq year (+ year incr)))))
    ;; should break out the dnf formatting function for consistency
    (list month year)))


    