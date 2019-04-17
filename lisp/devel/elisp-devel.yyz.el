(defun magit-log-format-margin (author date)
  (-when-let (option (magit-margin-option))
    (-let [(_ style width details details-width)
           (or magit-buffer-margin
               (symbol-value option))]
      (magit-make-margin-overlay
       (concat (and details
                    (concat (propertize (truncate-string-to-width
                                         (or AUTHOR "")
                                         details-width
                                         nil ?\s (make-string 1 magit-ellipsis))
                                        'face 'magit-log-author)
                            " "))
               (propertize
                (if (stringp style)
                    (format-time-string
                     style
                     (seconds-to-time (string-to-number date)))
                  (-let* ((abbr (eq style 'age-abbreviated))
                          ((cnt unit) (magit--age date abbr)))
                    (format (format (if abbr "%%2i%%-%ic" "%%2i %%-%is")
                                    (- (funcall width style details details-width)
				       (if details (1+ details-width) 0)))
                            cnt unit)))
                'face 'magit-log-date))))))


magit-log-margin-width
style details details-width

========================
Friday April 27 2018
--
(memq nil '(1 2 nil -))
(nil -)

(defvar redisplay-highlight-region-function
  (lambda (start end window rol)
    (if (not (overlayp rol))
        (let ((nrol (make-overlay start end)))
          (funcall redisplay-unhighlight-region-function rol)
          (overlay-put nrol 'window window)
          (overlay-put nrol 'face 'region)
          ;; Normal priority so that a large region doesn't hide all the
          ;; overlays within it, but high secondary priority so that if it
          ;; ends/starts in the middle of a small overlay, that small overlay
          ;; won't hide the region's boundaries.
          (overlay-put nrol 'priority '(999 . 10000))
          nrol)
      (unless (and (eq (overlay-buffer rol) (current-buffer))
                   (eq (overlay-start rol) start)
                   (eq (overlay-end rol) end))
        (move-overlay rol start end (current-buffer)))
      rol)))


========================
Wednesday May 09 2018
--
problem:
Debugger entered--Lisp error: (error "Invalid use of ‘\\’ in replacement text"q)
  replace-match("\\\"" nil nil "\"" nil)
  replace-regexp-in-string("\"" "\\\"" "aa\\bb\"cc" nil nil)
  replace-in-string("aa\\bb\"cc" "\"" "\\\"")
  (let ((s "aa\\bb\"cc")) (princf "s>%s<" s) (message "s>%s<" s) (replace-in-string s "\"" "\\\""))
  eval((let ((s "aa\\bb\"cc")) (princf "s>%s<" s) (message "s>%s<" s) (replace-in-string s "\"" "\\\"")) nil)
  elisp--eval-last-sexp(t)
  eval-last-sexp(t)
  eval-print-last-sexp(nil)
  funcall-interactively(eval-print-last-sexp nil)
  call-interactively(eval-print-last-sexp nil nil)
  command-execute(eval-print-last-sexp)


simplification:
(let ((s "aa\\bb\"cc")
      (r "\\\"")
      (z 2))
  (princf "s>%s<" s)
  (message "s>%s<" s)
  ;;(replace-in-string s "\"" "\\\\\"")
  (setq z (replace-in-string s "\"" "\\\"" t))
  (princf "z>%s<" z)
  )
s>aa\bb"cc<
z>aa\bb\"cc<
nil

s>aa\bb"cc<
z>aa\bb\"cc<
nil

s>aa\bb"cc<
z>aa\bb\"cc<
nil

s>aa\bb"cc<
t>aa\bb\"cc<
nil

s>aa\bb"cc<
t>2<
nil

s>aa\bb"cc<






s>aa\bb"cc<
"aa\\bb\\\"cc"


s>aa\bb"cc<

s>aa\bb"cc<
"
(princf "s1>%s< s2>%s<" "\"" "\\\"")
s1>"< s2>\"<
nil
"
", \"

nil


s>ab\cd<
"ab\\cd"

s>ab\cd<

s>ab\cd<
"s>ab\\cd<"

(princf "\"")
"
nil
"
(princf "aa\\bb\"cc")
aa\bb"cc
nil

(princf "\\\"")
\"
nil

"
nil

\
nil


s>ab\cd<
nil

"
(comint-quote-filename "aaa\"bbb")
"aaa\"bbb"
  
"aaa\"bbb"

(defun dpa (@begin @end)
  (interactive)
  )
dpa

========================
Saturday May 19 2018
--

(read-file-name PROMPT
		&optional DIR DEFAULT-FILENAME MUSTMATCH INITIAL PREDICATE)

(read-file-name "prompt: " dp-sudo-edit-tramp-local-prefix
		"DEFAULT-FILENAME"
		nil
		default-directory)
"/sudo:root@localhost:/etc/init.d"


"/sudo:root@localhost:/home/davep/flisp/ec"


"/sudo:root@localhost:/etc/default/"



========================
Wednesday June 13 2018
--
(defun ffap-other-window ()
  "Like `ffap', but put buffer in another window.
Only intended for interactive use."
  (interactive)
  (pcase (save-window-excursion (call-interactively 'ffap))
    ((or (and (pred bufferp) b) `(,(and (pred bufferp) b) . ,_))
     (switch-to-buffer-other-window b))))
ffap-other-window


(cl-pe
'(pcase (save-window-excursion (call-interactively 'ffap))
    ((or (and (pred bufferp) b) `(,(and (pred bufferp) b) . ,_))
     (switch-to-buffer-other-window b)))
)

(let* ((val (let ((wconfig (current-window-configuration)))
	      (unwind-protect
		  (progn
		    (call-interactively 'ffap))
		(set-window-configuration wconfig)))))
  (cond ((bufferp val)
	 (let ((b val))
	   (switch-to-buffer-other-window b)))
	((consp val)
	 (let* ((x (car val)))
	   (if (bufferp x)
	       (let ((b x))
		 (switch-to-buffer-other-window b))
	     nil)))
	(t nil)))nil


(cl-pe '(pcase (save-window-excursion (call-interactively 'ffap))
	  ((or (and (pred bufferp) b) `(,(and (pred bufferp) b) . ,_))
	   (switch-to-buffer-other-window b)))
       )

(defun blah ()
  (interactive)
  (let* ((val (let ((wconfig (current-window-configuration)))
		(unwind-protect
		    (progn
		      (call-interactively 'ffap))
		  (set-window-configuration wconfig)))))
    (cond ((bufferp val)
	   (let ((b val))
	     (switch-to-buffer-other-window b)))
	  ((consp val)
	   (let* ((x (car val)))
	     (if (bufferp x)
		 (let ((b x))
		   (switch-to-buffer-other-window b))
	       nil)))
	  (t nil))))

(pred nil)

========================
Tuesday June 19 2018
--


(defun dp-add-font-patterns (list-o-modes buffer-local-p list-o-keys)
  "Add the keyword patterns in LIST-O-KEYS to each mode in LIST-O-MODES.
This function is different from the XEmacs version which uses a
mechanism which restores a variable to its original state and
then applies changes."
  (setq list-o-modes (dp-listify-thing list-o-modes)
	list-o-keys (dp-listify-thing list-o-keys))
  (loop for mode in list-o-modes do
	(progn
	  (when buffer-local-p
	    (make-variable-buffer-local mode))
	  (font-lock-add-keywords mode list-o-keys 'append))))

(defun dp-add-to-font-patterns (list-o-modes &rest list-o-keys)
  "Add the keyword patterns in LIST-O-KEYS to each mode in LIST-O-MODES.
This function uses a mechanism which restores a variable to its original
state and then applies changes. This is good... sometimes."
  ;; Icky... the lambda uses variables from the current environment.
  (loop for mode in list-o-modes do
    (loop for key in list-o-keys do
      (font-lock-add-keywords mode key t))))

;; (defun* dp-add-line-too-long-font (font-lock-var-syms
;;                                    &key (buffer-local-p t))
;;   "WARNING: This function uses `dp-add-font-patterns' which resets the fonts.
;; `dp-add-font-patterns' uses a mechanism which restores a variable to its
;; original state and then applies changes. This is good... sometimes."
;;   (interactive "Smode's font lock var? ")
;;   (dp-add-font-patterns font-lock-var-syms
;;                         buffer-local-p
;;                         (list dp-font-lock-line-too-long-error-element
;;                               dp-font-lock-line-too-long-warning-element)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

nil


(defface dp-default-line-too-long-error-face
  '(
    (((class color) (background light)) (:background "gainsboro"))
    (((class color) (background dark)) (:foreground "green")))
  "Face for buffer lines which have gotten too long."
  :group 'faces
  :group 'dp-faces)

(setq dp-font-lock-line-too-long-error-element-for-tabs 'FOAD222)

(defvar dp-font-lock-line-too-long-error-element-for-tabs
  `( ;;list
   ,(format
    "^\\([^\t\n]\\{%s\\}\\|[^\t\n]\\{0,%s\\}\t\\)\\{%d\\}%s\\(.+\\)$"
    tab-width
    (1- tab-width)
    (/ dp-line-too-long-error-column tab-width)
    (let ((rem (% dp-line-too-long-error-column tab-width)))
      (if (zerop rem)
	  ""
	(format ".\\{%d\\}" rem))))
   (
     2					; line tail
     'dp-default-line-too-long-error-face))
  "As above, but works with tabs.
@todo XXX Seems to work with spaces, too.  \"But make sure, sure, sure\".")

(defvar dp-font-lock-line-too-long-error-element
  dp-font-lock-line-too-long-error-element-for-tabs
  "NB: Add mechanism for selecting (tabs or no), or make one element that
  works for both.")

(cl-pp (list dp-font-lock-line-too-long-error-element))

(("^\\([^	
]\\{8\\}\\|[^	
]\\{0,7\\}	\\)\\{10\\}\\(.+\\)$" (2 dp-default-line-too-long-error-face)))nil




(progn
  (font-lock-add-keywords
   nil
   (list dp-font-lock-line-too-long-error-element-for-tabs)
   t)
  (font-lock-flush)
)
nil


(cl-pp font-lock-keywords)

(t (("(\\(cl-def\\(?:generic\\|m\\(?:acro\\|ethod\\)\\|s\\(?:\\(?:truc\\|ubs\\)t\\)\\|type\\|un\\)\\|def\\(?:a\\(?:dvice\\|lias\\)\\|c\\(?:lass\\|onst\\|ustom\\)\\|face\\|g\\(?:eneric\\|roup\\)\\|ine-\\(?:advice\\|derived-mode\\|g\\(?:\\(?:eneric\\|lobal\\(?:\\(?:ized\\)?-minor\\)\\)-mode\\)\\|inline\\|minor-mode\\|skeleton\\|widget\\)\\|m\\(?:acro\\|ethod\\)\\|subst\\|theme\\|un\\|var\\(?:-local\\|alias\\)?\\)\\|ert-deftest\\)\\_>[ 	']*\\(([ 	']*\\)?\\(\\(setf\\)[ 	]+\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\|\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)?" (1 font-lock-keyword-face)
     (3 (let ((type (get (intern-soft (match-string 1)) 'lisp-define-type)))
	  (cond ((eq type 'var)
		 font-lock-variable-name-face)
		((eq type 'type)
		 font-lock-type-face)
		((or (not (match-string 2))
		     (and (match-string 2) (match-string 4)))
		 font-lock-function-name-face)))
	nil
	t))
    ("^;;;###\\([-a-z]*autoload\\)" 1 font-lock-warning-face prepend)
    ("\\[\\(\\^\\)" 1 font-lock-negation-char-face prepend)
    ("(\\(cl-\\(?:assert\\|check-type\\)\\|error\\|signal\\|user-error\\|warn\\)\\_>" (1 font-lock-warning-face))
    (lisp--el-match-keyword . 1)
    ("(\\(catch\\|throw\\|featurep\\|provide\\|require\\)\\_>[ 	']*\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)?" (1 font-lock-keyword-face)
     (2 font-lock-constant-face nil t))
    ("\\\\\\\\\\[\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)\\]" (1 font-lock-constant-face
							   prepend))
    ("[`‘]\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)['’]" (1 font-lock-constant-face
										prepend))
    ("\\_<:\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\_>" (0 font-lock-builtin-face))
    ("\\_<\\&\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\_>" . font-lock-type-face)
    (#[257 "\30021 \301\302\303#\2050 \304\224\204 \305`S\306\"\211<\203! \307>\204' \211\307=\203, \310\300\303\"\210\210\202 0\207" [found re-search-forward "\\(\\\\\\\\\\)\\(?:\\(\\\\\\\\\\)\\|\\((\\(?:\\?[0-9]*:\\)?\\|[|)]\\)\\)" t 2 get-text-property face font-lock-string-face throw] 5 "

(fn BOUND)"] (1 'font-lock-regexp-grouping-backslash prepend)
 (3 'font-lock-regexp-grouping-construct prepend))
 (lisp--match-hidden-arg (0 '(face font-lock-warning-face help-echo "Hidden behind deeper element; move to another line?")))
("^\\([^	
]\\{8\\}\\|[^	
]\\{0,7\\}	\\)\\{10\\}\\(.+\\)$" (2 dp-default-line-too-long-error-face)))
("(\\(cl-def\\(?:generic\\|m\\(?:acro\\|ethod\\)\\|s\\(?:\\(?:truc\\|ubs\\)t\\)\\|type\\|un\\)\\|def\\(?:a\\(?:dvice\\|lias\\)\\|c\\(?:lass\\|onst\\|ustom\\)\\|face\\|g\\(?:eneric\\|roup\\)\\|ine-\\(?:advice\\|derived-mode\\|g\\(?:\\(?:eneric\\|lobal\\(?:\\(?:ized\\)?-minor\\)\\)-mode\\)\\|inline\\|minor-mode\\|skeleton\\|widget\\)\\|m\\(?:acro\\|ethod\\)\\|subst\\|theme\\|un\\|var\\(?:-local\\|alias\\)?\\)\\|ert-deftest\\)\\_>[ 	']*\\(([ 	']*\\)?\\(\\(setf\\)[ 	]+\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\|\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)?" (1 font-lock-keyword-face)
 (3 (let ((type (get (intern-soft (match-string 1)) 'lisp-define-type)))
      (cond ((eq type 'var)
	     font-lock-variable-name-face)
	    ((eq type 'type)
	     font-lock-type-face)
	    ((or (not (match-string 2))
		 (and (match-string 2) (match-string 4)))
	     font-lock-function-name-face)))
    nil
    t))
("^;;;###\\([-a-z]*autoload\\)" (1 font-lock-warning-face prepend))
("\\[\\(\\^\\)" (1 font-lock-negation-char-face prepend))
("(\\(cl-\\(?:assert\\|check-type\\)\\|error\\|signal\\|user-error\\|warn\\)\\_>" (1 font-lock-warning-face))
(lisp--el-match-keyword (1 font-lock-keyword-face))
("(\\(catch\\|throw\\|featurep\\|provide\\|require\\)\\_>[ 	']*\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)?" (1 font-lock-keyword-face)
 (2 font-lock-constant-face nil t))
("\\\\\\\\\\[\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)\\]" (1 font-lock-constant-face
						       prepend))
("[`‘]\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)['’]" (1 font-lock-constant-face
									    prepend))
("\\_<:\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\_>" (0 font-lock-builtin-face))
("\\_<\\&\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\_>" (0 font-lock-type-face))
(#[257 "\30021 \301\302\303#\2050 \304\224\204 \305`S\306\"\211<\203! \307>\204' \211\307=\203, \310\300\303\"\210\210\202 0\207" [found re-search-forward "\\(\\\\\\\\\\)\\(?:\\(\\\\\\\\\\)\\|\\((\\(?:\\?[0-9]*:\\)?\\|[|)]\\)\\)" t 2 get-text-property face font-lock-string-face throw] 5 "

(fn BOUND)"] (1 'font-lock-regexp-grouping-backslash prepend)
 (3 'font-lock-regexp-grouping-construct prepend))
 (lisp--match-hidden-arg (0 '(face font-lock-warning-face help-echo "Hidden behind deeper element; move to another line?")))
("^\\([^	
]\\{8\\}\\|[^	
]\\{0,7\\}	\\)\\{10\\}\\(.+\\)$" (2 dp-default-line-too-long-error-face)))nil




(t (("(\\(cl-def\\(?:generic\\|m\\(?:acro\\|ethod\\)\\|s\\(?:\\(?:truc\\|ubs\\)t\\)\\|type\\|un\\)\\|def\\(?:a\\(?:dvice\\|lias\\)\\|c\\(?:lass\\|onst\\|ustom\\)\\|face\\|g\\(?:eneric\\|roup\\)\\|ine-\\(?:advice\\|derived-mode\\|g\\(?:\\(?:eneric\\|lobal\\(?:\\(?:ized\\)?-minor\\)\\)-mode\\)\\|inline\\|minor-mode\\|skeleton\\|widget\\)\\|m\\(?:acro\\|ethod\\)\\|subst\\|theme\\|un\\|var\\(?:-local\\|alias\\)?\\)\\|ert-deftest\\)\\_>[ 	']*\\(([ 	']*\\)?\\(\\(setf\\)[ 	]+\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\|\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)?" (1 font-lock-keyword-face)
     (3 (let ((type (get (intern-soft (match-string 1)) 'lisp-define-type)))
	  (cond ((eq type 'var)
		 font-lock-variable-name-face)
		((eq type 'type)
		 font-lock-type-face)
		((or (not (match-string 2))
		     (and (match-string 2) (match-string 4)))
		 font-lock-function-name-face)))
	nil
	t))
    ("^;;;###\\([-a-z]*autoload\\)" 1 font-lock-warning-face prepend)
    ("\\[\\(\\^\\)" 1 font-lock-negation-char-face prepend)
    ("(\\(cl-\\(?:assert\\|check-type\\)\\|error\\|signal\\|user-error\\|warn\\)\\_>" (1 font-lock-warning-face))
    (lisp--el-match-keyword . 1)
    ("(\\(catch\\|throw\\|featurep\\|provide\\|require\\)\\_>[ 	']*\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)?" (1 font-lock-keyword-face)
     (2 font-lock-constant-face nil t))
    ("\\\\\\\\\\[\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)\\]" (1 font-lock-constant-face
							   prepend))
    ("[`‘]\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)['’]" (1 font-lock-constant-face
										prepend))
    ("\\_<:\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\_>" (0 font-lock-builtin-face))
    ("\\_<\\&\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\_>" . font-lock-type-face)
    (#[257 "\30021 \301\302\303#\2050 \304\224\204 \305`S\306\"\211<\203! \307>\204' \211\307=\203, \310\300\303\"\210\210\202 0\207" [found re-search-forward "\\(\\\\\\\\\\)\\(?:\\(\\\\\\\\\\)\\|\\((\\(?:\\?[0-9]*:\\)?\\|[|)]\\)\\)" t 2 get-text-property face font-lock-string-face throw] 5 "

(fn BOUND)"] (1 'font-lock-regexp-grouping-backslash prepend)
 (3 'font-lock-regexp-grouping-construct prepend))
 (lisp--match-hidden-arg (0 '(face font-lock-warning-face help-echo "Hidden behind deeper element; move to another line?"))))
("(\\(cl-def\\(?:generic\\|m\\(?:acro\\|ethod\\)\\|s\\(?:\\(?:truc\\|ubs\\)t\\)\\|type\\|un\\)\\|def\\(?:a\\(?:dvice\\|lias\\)\\|c\\(?:lass\\|onst\\|ustom\\)\\|face\\|g\\(?:eneric\\|roup\\)\\|ine-\\(?:advice\\|derived-mode\\|g\\(?:\\(?:eneric\\|lobal\\(?:\\(?:ized\\)?-minor\\)\\)-mode\\)\\|inline\\|minor-mode\\|skeleton\\|widget\\)\\|m\\(?:acro\\|ethod\\)\\|subst\\|theme\\|un\\|var\\(?:-local\\|alias\\)?\\)\\|ert-deftest\\)\\_>[ 	']*\\(([ 	']*\\)?\\(\\(setf\\)[ 	]+\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\|\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)?" (1 font-lock-keyword-face)
 (3 (let ((type (get (intern-soft (match-string 1)) 'lisp-define-type)))
      (cond ((eq type 'var)
	     font-lock-variable-name-face)
	    ((eq type 'type)
	     font-lock-type-face)
	    ((or (not (match-string 2))
		 (and (match-string 2) (match-string 4)))
	     font-lock-function-name-face)))
    nil
    t))
("^;;;###\\([-a-z]*autoload\\)" (1 font-lock-warning-face prepend))
("\\[\\(\\^\\)" (1 font-lock-negation-char-face prepend))
("(\\(cl-\\(?:assert\\|check-type\\)\\|error\\|signal\\|user-error\\|warn\\)\\_>" (1 font-lock-warning-face))
(lisp--el-match-keyword (1 font-lock-keyword-face))
("(\\(catch\\|throw\\|featurep\\|provide\\|require\\)\\_>[ 	']*\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)?" (1 font-lock-keyword-face)
 (2 font-lock-constant-face nil t))
("\\\\\\\\\\[\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)\\]" (1 font-lock-constant-face
						       prepend))
("[`‘]\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)['’]" (1 font-lock-constant-face
									    prepend))
("\\_<:\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\_>" (0 font-lock-builtin-face))
("\\_<\\&\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\_>" (0 font-lock-type-face))
(#[257 "\30021 \301\302\303#\2050 \304\224\204 \305`S\306\"\211<\203! \307>\204' \211\307=\203, \310\300\303\"\210\210\202 0\207" [found re-search-forward "\\(\\\\\\\\\\)\\(?:\\(\\\\\\\\\\)\\|\\((\\(?:\\?[0-9]*:\\)?\\|[|)]\\)\\)" t 2 get-text-property face font-lock-string-face throw] 5 "

(fn BOUND)"] (1 'font-lock-regexp-grouping-backslash prepend)
 (3 'font-lock-regexp-grouping-construct prepend))
 (lisp--match-hidden-arg (0 '(face font-lock-warning-face help-echo "Hidden behind deeper element; move to another line?"))))nil






(cl-assert 'zuzz)
(cl-signal
;;;###autoload




(re-search-forward "^\\([^	
]\\{8\\}\\|[^	
]\\{0,7\\}	\\)\\{10\\}\\(.+\\)$")


(re-search-forward "^\\([^	
]\\{8\\}\\|[^	
]\\{0,7\\}	\\)\\{10\\}")



	xxxxxxxxxxxxxxx	xx  x x  x x   xxxxxxxx		xxxxx	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

========================
Wednesday June 20 2018
--
(defface whitespace-line
  '((((class mono)) :inverse-video t :weight bold :underline t)
    (t :background "gray20" :foreground "violet"))
  "Face used to visualize \"long\" lines.

See `whitespace-line-column'."
  :group 'whitespace)

(defvar bline-minor-mode-font-lock-keywords
  ;; cf. `whitespace-color-on'
  (list
   (list
    (let ((line-column (or 72 fill-column)))
      (format
       "^\\([^\t\n]\\{%s\\}\\|[^\t\n]\\{0,%s\\}\t\\)\\{%d\\}%s\\(.+\\)$"
       8
       (1- 8)
       (/ line-column 8)
       (let ((rem (% line-column 8)))
         (if (zerop rem)
             ""
           (format ".\\{%d\\}" rem)))))
    (if t   ; was: (memq 'lines whitespace-active-style)
        0   ; whole line
      2)    ; line tail
    'whitespace-line t)))
(font-lock-add-keywords nil bline-minor-mode-font-lock-keywords t)
(font-lock-mode 1)
(font-lock-flush)

xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

(cl-pp font-lock-keywords)

(t (("(\\(cl-def\\(?:generic\\|m\\(?:acro\\|ethod\\)\\|s\\(?:\\(?:truc\\|ubs\\)t\\)\\|type\\|un\\)\\|def\\(?:a\\(?:dvice\\|lias\\)\\|c\\(?:lass\\|onst\\|ustom\\)\\|face\\|g\\(?:eneric\\|roup\\)\\|ine-\\(?:advice\\|derived-mode\\|g\\(?:\\(?:eneric\\|lobal\\(?:\\(?:ized\\)?-minor\\)\\)-mode\\)\\|inline\\|minor-mode\\|skeleton\\|widget\\)\\|m\\(?:acro\\|ethod\\)\\|subst\\|theme\\|un\\|var\\(?:-local\\|alias\\)?\\)\\|ert-deftest\\)\\_>[ 	']*\\(([ 	']*\\)?\\(\\(setf\\)[ 	]+\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\|\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)?" (1 font-lock-keyword-face) (3 (let ((type (get (intern-soft (match-string 1)) 'lisp-define-type))) (cond ((eq type 'var) font-lock-variable-name-face) ((eq type 'type) font-lock-type-face) ((or (not (match-string 2)) (and (match-string 2) (match-string 4))) font-lock-function-name-face))) nil t)) ("^;;;###\\([-a-z]*autoload\\)" 1 font-lock-warning-face prepend) ("\\[\\(\\^\\)" 1 font-lock-negation-char-face prepend) ("(\\(cl-\\(?:assert\\|check-type\\)\\|error\\|signal\\|user-error\\|warn\\)\\_>" (1 font-lock-warning-face)) (lisp--el-match-keyword . 1) ("(\\(catch\\|throw\\|featurep\\|provide\\|require\\)\\_>[ 	']*\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)?" (1 font-lock-keyword-face) (2 font-lock-constant-face nil t)) ("\\\\\\\\\\[\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)\\]" (1 font-lock-constant-face prepend)) ("[`‘]\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)['’]" (1 font-lock-constant-face prepend)) ("\\_<:\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\_>" (0 font-lock-builtin-face)) ("\\_<\\&\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\_>" . font-lock-type-face) (#[257 "\30021 \301\302\303#\2050 \304\224\204 \305`S\306\"\211<\203! \307>\204' \211\307=\203, \310\300\303\"\210\210\202 0\207" [found re-search-forward "\\(\\\\\\\\\\)\\(?:\\(\\\\\\\\\\)\\|\\((\\(?:\\?[0-9]*:\\)?\\|[|)]\\)\\)" t 2 get-text-property face font-lock-string-face throw] 5 "

(fn BOUND)"] (1 'font-lock-regexp-grouping-backslash prepend) (3 'font-lock-regexp-grouping-construct prepend)) (lisp--match-hidden-arg (0 '(face font-lock-warning-face help-echo "Hidden behind deeper element; move to another line?"))) ("^\\([^	
]\\{8\\}\\|[^	
]\\{0,7\\}	\\)\\{9\\}\\(.+\\)$" 0 whitespace-line t)) ("(\\(cl-def\\(?:generic\\|m\\(?:acro\\|ethod\\)\\|s\\(?:\\(?:truc\\|ubs\\)t\\)\\|type\\|un\\)\\|def\\(?:a\\(?:dvice\\|lias\\)\\|c\\(?:lass\\|onst\\|ustom\\)\\|face\\|g\\(?:eneric\\|roup\\)\\|ine-\\(?:advice\\|derived-mode\\|g\\(?:\\(?:eneric\\|lobal\\(?:\\(?:ized\\)?-minor\\)\\)-mode\\)\\|inline\\|minor-mode\\|skeleton\\|widget\\)\\|m\\(?:acro\\|ethod\\)\\|subst\\|theme\\|un\\|var\\(?:-local\\|alias\\)?\\)\\|ert-deftest\\)\\_>[ 	']*\\(([ 	']*\\)?\\(\\(setf\\)[ 	]+\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\|\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)?" (1 font-lock-keyword-face) (3 (let ((type (get (intern-soft (match-string 1)) 'lisp-define-type))) (cond ((eq type 'var) font-lock-variable-name-face) ((eq type 'type) font-lock-type-face) ((or (not (match-string 2)) (and (match-string 2) (match-string 4))) font-lock-function-name-face))) nil t)) ("^;;;###\\([-a-z]*autoload\\)" (1 font-lock-warning-face prepend)) ("\\[\\(\\^\\)" (1 font-lock-negation-char-face prepend)) ("(\\(cl-\\(?:assert\\|check-type\\)\\|error\\|signal\\|user-error\\|warn\\)\\_>" (1 font-lock-warning-face)) (lisp--el-match-keyword (1 font-lock-keyword-face)) ("(\\(catch\\|throw\\|featurep\\|provide\\|require\\)\\_>[ 	']*\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)?" (1 font-lock-keyword-face) (2 font-lock-constant-face nil t)) ("\\\\\\\\\\[\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)\\]" (1 font-lock-constant-face prepend)) ("[`‘]\\(\\(?:\\sw\\|\\s_\\|\\\\.\\)\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\)['’]" (1 font-lock-constant-face prepend)) ("\\_<:\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\_>" (0 font-lock-builtin-face)) ("\\_<\\&\\(?:\\sw\\|\\s_\\|\\\\.\\)+\\_>" (0 font-lock-type-face)) (#[257 "\30021 \301\302\303#\2050 \304\224\204 \305`S\306\"\211<\203! \307>\204' \211\307=\203, \310\300\303\"\210\210\202 0\207" [found re-search-forward "\\(\\\\\\\\\\)\\(?:\\(\\\\\\\\\\)\\|\\((\\(?:\\?[0-9]*:\\)?\\|[|)]\\)\\)" t 2 get-text-property face font-lock-string-face throw] 5 "

(fn BOUND)"] (1 'font-lock-regexp-grouping-backslash prepend) (3 'font-lock-regexp-grouping-construct prepend)) (lisp--match-hidden-arg (0 '(face font-lock-warning-face help-echo "Hidden behind deeper element; move to another line?"))) ("^\\([^	
]\\{8\\}\\|[^	
]\\{0,7\\}	\\)\\{9\\}\\(.+\\)$" (0 whitespace-line t)))nil

jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj

(git-commit-summary-regexp)
"\\`\\(?:^\\(?:\\s-*\\|;.*\\)
\\)*\\(.\\{0,68\\}\\)\\(.*\\)\\(?:
;\\|
\\(.+\\)\\)?"

========================
Thursday October 18 2018
--
(defun check-prop (prop pval)
  (princf "prop>%s<, pval>%s<"
	  prop pval)
  (eq prop pval))


(defun map-extents (function
		    &optional object from to maparg flags property value)
  (setq-ifnil object (current-buffer)
	      from (cond
		    ((overlayp object) (overlay-start))
		    ((stringp object) 0)
		    ((bufferp object)
		     (with-current-buffer object
		       (point-min)))
		    (t (error "Unsupported object type: %s" object)))
	      to (cond
		    ((overlayp object) (overlay-end))
		    ((stringp object) (1- (length object)))
		    ((bufferp object)
		     (with-current-buffer object
		       (point-max)))
		    (t (error "Unsupported object type: %s" object))))
  (with-current-buffer (or object (current-buffer))
    (auto-overlays-in from to
		      (when property
			(list 'eq property value)
			))))

dp-extent-id         dp-colorized-region-p
(map-extents nil (dp-get-buffer "daily-2018-10.jxt")
	     nil nil nil nil 'dp-extent-id 'dp-colorized-region-p)
(#<overlay from 1684 to 1824 in daily-2018-10.jxt>
	   #<overlay from 2398 to 2474 in daily-2018-10.jxt>
	   #<overlay from 2632 to 2658 in daily-2018-10.jxt>
	   #<overlay from 2715 to 2720 in daily-2018-10.jxt>)

(#<overlay from 1684 to 1824 in daily-2018-10.jxt>
 #<overlay from 2715 to 2720 in daily-2018-10.jxt>)

(#<overlay from 1684 to 1824 in daily-2018-10.jxt>
	   #<overlay from 1961 to 2183 in daily-2018-10.jxt>
	   #<overlay from 2715 to 2720 in daily-2018-10.jxt>)



prop>dp-journal-medium-example-face<, pval>t<
prop>dp-cifdef-face5<, pval>t<


========================
Friday October 19 2018
--

(truncate-string-to-width
 "YAYAYAYAYAYAYAYAYAYYA" 19 nil nil
 "<<truncated>>")
"YAYAYA<<truncated>>"

"YAYAYAYAYAYAYAYAYAYYA"

"YAYAYAYAYAYAYAYAYAYYA"

"YAYAYAYAYAYAYAYAYAYYA"

"YAYAYAYAYAY…"

(decode-char 'ucs #x0020)
32
(make-string 1 (decode-char 'ucs #x25a1))
"□"

(make-string 1 (decode-char 'ucs #x21b5))
"↵"

(make-stringw3m
links
lynx
elinks
links2
 1 (decode-char 'ucs #x25ab))
"▫"



" "

(make-string 1 dp-sel2:white-square)
"□"

"□"


x21b5
(bound-and-true-p unicode-category-table)

	      from (cond
		    ((overlayp object) (overlay-start))
		    ((stringp object) 0)
		    (t (error "Unsupported object type: %s" object)))

========================
Friday November 02 2018
--

;shipped (defun dp-tag-find-other-window (&rest r)
;shipped   (interactive)
;shipped   (cond
;shipped    ((dp-xgtags-p)
;shipped     (call-interactively 'dp-xgtags-find-tag-other-window))
;shipped    ((dp-gtags-p)
;shipped     (call-interactively 'gtags-find-tag-other-window))
;shipped    (t
;shipped     (error "No find tag other window."))))

;shipped (defun dp-xgtags-find-tag-other-window (&optional num-windows-next)
;shipped   (interactive "p")
;shipped   (let ((xgtags-goto-tag 'always)
;shipped 	(start-buffer (current-buffer))
;shipped 	(tag-buffer (progn
;shipped 		      (xgtags-find-tag)
;shipped 		      (current-buffer))))
;shipped     ;; for some reason (probably due to my misunderstanding of the
;shipped     ;; function) `save-excursion' doesn't save the buffer, and we're
;shipped     ;; left in the buffer containing the tag.  So we go back here.
;shipped     ;; I'm sure this is over complicated and inefficient, but it works.
;shipped     ;; So there.
;shipped     (switch-to-buffer start-buffer)
;shipped     (when (not (equal tag-buffer (current-buffer)))
;shipped       (switch-to-buffer-other-window tag-buffer))))


========================
Tuesday November 06 2018
--
(progn
  (add-hook 'python-mode-hook 'jedi:setup)
  (setq jedi:complete-on-dot t)                 ; optional
  (jedi:install-server))

========================
Tuesday November 06 2018
--
(defun dp-setup-jedi ()
  (interactive)
  ;; Standard Jedi.el setting
  ;; (add-hook 'python-mode-hook 'jedi:setup)
  ;; If auto-completion is all you need, you can call this function
  ;; instead of `jedi:setup'
  (add-hook 'python-mode-hook 'jedi:ac-setup)
  (setq jedi:complete-on-dot t)
  (autoload 'jedi:setup "jedi" nil t))


;; Type:
;;     M-x package-install RET jedi RET
;;     M-x jedi:install-server RET
;; Then open Python file.

========================
Monday November 12 2018
--
(defun gtags-auto-update ()
  (when (and xgtags-mode gtags-auto-update buffer-file-name)
    (if (not (dp-in-exe-path-p xgtags-global-program))
        (dmessage "gtags-auto-update: cannot find tag updater: %s"
                 xgtags-global-program)
      (dmessage "Updating tags(%s)..." dp-gtags-auto-update-db-flag)
      (call-process xgtags-global-program
                    nil nil nil
                    dp-gtags-auto-update-db-flag
                    (if dp-gtags-auto-update-db-flag
                        "-L"
                      "--rgg-nop")
                    (if dp-gtags-auto-update-db-flag
                        "cscope.files"
                      "--rgg-nop")
                    "-u" (concat "--single-update="
				 (expand-file-name (gtags-buffer-file-name))))
      (dmessage "Updating tags(%s)...done" dp-gtags-auto-update-db-flag))))

(cl-pe '(defvar-local bubba 'aa))

(progn
  (defvar bubba 'aa nil)
  (make-variable-buffer-local 'bubba))

(cl-pe '(dp-deflocal bubba 'aa))

(progn
  (defvar bubba 'aa "Undocumented. (dp-deflocal)")
  (make-variable-buffer-local 'bubba)
  (setq-default bubba 'aa))nil



========================
Tuesday November 20 2018
--
(defun lsrc (dirname &optional switches)
  (interactive (dired-read-dir-and-switches ""))
  (pop-to-buffer-same-window
   (dired-noselect (paths-construct-path (list dirname "*.[ch]"))
		   switches)))
lsrc

lsrc




========================
Wednesday November 21 2018
--

1 2 3 ++p = 6


6
========================
Monday November 26 2018
--

(frame-parameter nil 'name)
"Serv/Emacs@yyz:/home/dpanarit/dpw/dpw/lisp/devel/elisp-devel.yyz.el"
(princf "%s" (selected-frame))
#<frame Serv/Emacs@yyz:/home/dpanarit/dpw/dpw/lisp/devel/elisp-devel.yyz.el 0x13651f0>
nil
(dp-get-orig-value 'appt-disp-window-function)
appt-disp-window

(dp-get-orig-value 'appt-delete-window-function)

(setq keep-appt-disp-window-function appt-disp-window-function)


(dp-fsf-appt-disp-frame 3 "Date" "Howdy, frame2.")
(funcall appt-disp-window-function 3 "Date" "Howdy, frame3.")


 
========================
Tuesday November 27 2018
--

(cl-pe '(defun pcomplete/git ()
  "Completion for `git'"
  ;; Completion for the command argument.
  (pcomplete-here* pcmpl-git-commands)
  ;; complete files/dirs forever if the command is `add' or `rm'
  (cond
   ((pcomplete-match (regexp-opt '("add" "rm")) 1)
    (while (pcomplete-here (pcomplete-entries))))
   ;; provide branch completion for the command `checkout'.
   ((pcomplete-match (regexp-opt '("checkout" "co") 1))
    (pcomplete-here* (pcmpl-git-get-refs "heads")))))
)

;; (defalias 'pcomplete/git
;;   (function
;;    (lambda nil

(defun pcomplete/git ()
    "Completion for `git'"
  (pcomplete--here (function (lambda nil pcmpl-git-commands)) nil t nil)
  (cond ((pcomplete-match (regexp-opt '("add" "rm")) 1)
	 (while (pcomplete--here (function
				  (lambda nil (pcomplete-entries)))
				 nil
				 nil
				 nil)))
	((pcomplete-match (regexp-opt '("checkout" "co") 1))
	 (pcomplete--here (function
			   (lambda nil (pcmpl-git-get-refs "heads")))
			  nil
			  t
			  nil))))))




========================
Thursday November 29 2018
--

;olde orig. (defun dp-delete-word-forward (arg)
;olde orig.   "Delete characters forward until encountering the end of a word.
;olde orig. With argument, do this that many times.  Main change is to allow a
;olde orig. sequence of white-space at point to be deleted with this command.
;olde orig. Based (now, loosely) on kill-word from simple.el"
;olde orig.   (interactive "*p")
;olde orig.   ;; XXX look at skip-chars-forward/backward
;olde orig.   (let ((ws "\\(\\s-\\|\n\\)+")
;olde orig. 	(opoint (point)))
;olde orig.     (if (or
;olde orig. 	 ;; kill forward, sitting on white space.  kill using match
;olde orig. 	 ;; data from looking-at
;olde orig. 	 (and (> arg 0)
;olde orig. 	      (looking-at ws))
;olde orig. 	 ;; kill backwards.
;olde orig. 	 ;; move back a char (if possible).
;olde orig. 	 ;; if on whitespace, continue
;olde orig. 	 ;;  else return to where we were
;olde orig. 	 ;; go back to non-whitespace
;olde orig. 	 ;; match ws up to where we started
					;olde orig. 	 ;; use that match data to delete.
;olde orig. 	 (and (< arg 0)
;olde orig. 	      (not (dp-bobp))
;olde orig. 	      (not (backward-char 1))	; return nil when successful (always?)
;olde orig. 	      (if (looking-at ws)
;olde orig. 		  t
;olde orig. 		(forward-char 1))
;olde orig. 	      (re-search-backward "[^ 	\n]" nil t)
;olde orig. 	      (not (forward-char 1))
;olde orig. 	      (dp-re-search-forward ws opoint t)))
;olde orig. 	(delete-region (match-beginning 0) (match-end 0))
;olde orig.       ;; if we're not killing white space, kill a word in
;olde orig.       ;; the requested direction.
;olde orig.       (delete-region (point) (progn (forward-word arg) (point))))))




========================
Friday November 30 2018
--
(defun dp-delete-word-forward (arg)
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
	      (dp-looking-at ws))
	 ;; kill backwards.
	 ;; move back a char (if possible).
	 ;; if on whitespace, continue
	 ;;  else return to where we were
	 ;; go back to non-whitespace
	 ;; match ws up to where we started
	 ;; use that match data to delete.
	 (and (< arg 0)
	      (not (dp-bobp))
	      (not (backward-char 1)) ; return nil when successful (always?)
	      (if (dp-looking-at ws)
		  t
		(forward-char 1))
	      (re-search-backward "[^ 	\n]" nil t)
	      (not (forward-char 1))
	      (dp-re-search-forward ws opoint t)))
	(delete-region (match-beginning 0) (match-end 0))
      ;; if we're not killing white space, kill a word in
      ;; the requested direction.
      (delete-region (point) (progn (forward-word arg) (point))))))

========================
Monday December 10 2018
--
(cl-pe
    '(dp-current-next-error-function-advisor
     'dp-gtags-select-tag-one-window
     'dp-gtags-next-thing)
)

ad-add-advice is an autoloaded compiled Lisp function in ‘advice.el’.

(ad-add-advice FUNCTION ADVICE CLASS POSITION)

Add a piece of ADVICE to FUNCTION’s list of advices in CLASS.

ADVICE has the form (NAME PROTECTED ENABLED DEFINITION), where
NAME is the advice name; PROTECTED is a flag specifying whether
to protect against non-local exits; ENABLED is a flag specifying
whether to initially enable the advice; and DEFINITION has the
form (advice . LAMBDA), where LAMBDA is a lambda expression.

If FUNCTION already has a piece of advice with the same name,
then POSITION is ignored, and the old advice is overwritten with
the new one.

If FUNCTION already has one or more pieces of advice of the
specified CLASS, then POSITION determines where the new piece
goes.  POSITION can either be ‘first’, ‘last’ or a number (where
0 corresponds to ‘first’, and numbers outside the valid range are
mapped to the closest extremal position).

If FUNCTION was not advised already, its advice info will be
initialized.  Redefining a piece of advice whose name is part of
the cache-id will clear the cache.

(defun dp-dummy-to-be-advised ()
)
dp-dummy-to-be-advised

;;; (defadvice FUNCTION ARGS &rest BODY)
(cl-pe
'(defadvice dp-dummy-to-be-advised (around dp-test-crap activate)
  (fun1 a1)
  )
)


(progn
(ad-add-advice 'dp-dummy-to-be-advised
	       '(dp-test-crap nil t (advice lambda nil (fun1 a1)))
	       'around
	       'nil)
(ad-activate 'dp-dummy-to-be-advised nil)
'dp-dummy-to-be-advised)nil



  ;; (defmacro dp-current-next-error-function-advisor (fun next-thing
  ;; 							&optional next-thing-arg)
  ;;   (let* ((efunc (eval fun))
  ;;          (next-thing-arg (or (eval next-thing-arg) efunc))
  ;;          (enext-thing (eval next-thing)))
  ;;     `(defadvice ,efunc
  ;;       (before next-error-function-stuff activate)
  ;;       (dp-set-current-error-function ,next-thing
  ;;                                      nil
  ;;                                      (quote ,next-thing-arg)))))


;advisor (dp-current-next-error-function-advisor
;advisor  'dp-gtags-select-tag-one-window
;advisor  'dp-gtags-next-thing)

(cl-pe
    '(dp-current-next-error-function-advisor
     'dp-gtags-select-tag-one-window
     'dp-gtags-next-thing)
)

(progn
  (ad-add-advice 'dp-gtags-select-tag-one-window
		 '(next-error-function-stuff nil t (advice lambda nil (dp-set-current-error-function (quote dp-gtags-next-thing) nil (quote dp-gtags-select-tag-one-window))))
		 'before
		 'nil)
  (ad-activate 'dp-gtags-select-tag-one-window nil)
  'dp-gtags-select-tag-one-window)



;;; (ad-add-advice FUNCTION ADVICE CLASS POSITION)
(progn
  (ad-add-advice 'dp-gtags-select-tag-one-window
		 '(next-error-function-stuff nil t (advice lambda nil (dp-set-current-error-function (quote dp-gtags-next-thing) nil (quote dp-gtags-select-tag-one-window))))
		 'before
		 'nil)
  (ad-activate 'dp-gtags-select-tag-one-window nil)
  'dp-gtags-select-tag-one-window)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmacro dp-current-error-functions-advisor (before/after
					      next-fun
					      next-thing
					      prev-fun
					      prev-thing
					      &optional
					      next-thing-arg
					      prev-thing-arg)
  (let* ((next-efunc (eval next-fun))
	 (next-thing-arg (or (eval next-thing-arg) next-efunc))
	 (enext-thing (eval next-thing))
	 (prev-efunc (eval prev-fun))
	 (prev-thing-arg (or (eval prev-thing-arg) prev-efunc))
	 (eprev-thing (eval prev-thing)))
    `(defadvice ,next-efunc
	 (,before/after next/prev-error-function-stuff activate)
       (dp-set-current-next-error-function ,next-thing
					   nil
					   (quote ,next-thing-arg)))
    `(defadvice ,prev-efunc
	 (,before/after next/prev-error-function-stuff activate)
       (dp-set-current-prev-error-function ,prev-thing
					   nil
					   (quote ,prev-thing-arg)))))



(defmacro dp-current-error-functions-advisor (before/after
					      next-fun
					      next-thing
					      prev-fun
					      prev-thing
					      &optional
					      next-thing-arg
					      prev-thing-arg)
  `(progn
    (dp-current-next-error-function-advisor
     ,next-fun
     ,next-thing
     ,next-thing-arg)

    (dmessage "pooh-bah")

    (dp-current-prev-error-function-advisor
      ,prev-fun
      ,prev-thing
      ,prev-thing-arg)
    ))



(cl-pe
    '(dp-current-next-error-function-advisor
     'dp-gtags-select-tag-one-window
     'dp-gtags-next-thing)
)

(cl-pe
'(dp-current-error-functions-advisor
  before
  'dp-gtags-select-tag-one-window
  'dp-gtags-next-thing
  'dp-gtags-select-tag-one-window
  'dp-gtags-prev-thing)
)


(progn
  (progn
    (ad-add-advice 'dp-gtags-select-tag-one-window
		   '(next/prev-error-function-stuff nil t (advice lambda nil (dp-set-current-next-error-function (quote dp-gtags-next-thing) nil (quote dp-gtags-select-tag-one-window))))
		   'before
		   'nil)
    (ad-activate 'dp-gtags-select-tag-one-window nil)
    'dp-gtags-select-tag-one-window)
  (dmessage "pooh-bah")
  (progn
    (ad-add-advice 'dp-gtags-select-tag-one-window
		   '(next/prev-error-function-stuff nil t (advice lambda nil (dp-set-current-prev-error-function (quote dp-gtags-prev-thing) nil (quote dp-gtags-select-tag-one-window))))
		   'before
		   'nil)
    (ad-activate 'dp-gtags-select-tag-one-window nil)
    'dp-gtags-select-tag-one-window))nil
(
(defun ldkjfldkjf()
  (uaua)
  )

"pooh-bah"nil
))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq ibuffer-saved-filter-groups
      (quote (("wtfu"
	       ("source" (mode . c-mode))
	       ("dired" (mode . dired-mode))
	       ("perl" (mode . cperl-mode))
	       ("Python" (mode . python-mode))
	       ("erc" (mode . erc-mode))
	       ("planner" (or
			   (name . "^\\*Calendar\\*$")
			   (name . "^diary$")
			   (mode . muse-mode)))
	       ("emacs" (or
			 (name . "^\\*scratch\\*$")
			 (name . "^\\*Messages\\*$")
			 (name . "/.*\\.el")))
	       ("gnus" (or
			(mode . message-mode)
			(mode . bbdb-mode)
			(mode . mail-mode)
			(mode . gnus-group-mode)
			(mode . gnus-summary-mode)
			(mode . gnus-article-mode)
			(name . "^\\.bbdb$")
			(name . "^\\.newsrc-dribble")))))))

(cl-pp ibuffer-saved-filter-groups)

(("dp-ibuffer-saved-filter[0]" ("source" (mode . c-mode))
("dired" (mode . dired-mode))
("perl" (mode . cperl-mode))
("Python" (mode . python-mode))
("erc" (mode . erc-mode))
("planner" (or (name . "^\\*Calendar\\*$")
	       (name . "^diary$")
	       (mode . muse-mode)))
("emacs" (or (name . "^\\*scratch\\*$")
	     (name . "^\\*Messages\\*$")
	     (name . "/.*\\.el")))
("gnus" (or (mode . message-mode)
	    (mode . bbdb-mode)
	    (mode . mail-mode)
	    (mode . gnus-group-mode)
	    (mode . gnus-summary-mode)
	    (mode . gnus-article-mode)
	    (name . "^\\.bbdb$")
	    (name . "^\\.newsrc-dribble")))))nil



((("dp-ibuffer-saved-filter[0]" ("dired" (mode . dired-mode))
   ("source" (mode . c-mode))
   ("emacs" (or (name . "^\\*scratch\\*$")
		(name . "^\\*Messages\\*$")
		(name . "/.*\\.el")))
   ("Python" (mode . python-mode)))))nil



(defun ccccjdkljflj()
)
(

(assoc "dp-ibuffer-saved-filter[0]" ibuffer-saved-filter-groups)
nil


'(("dp-ibuffer-saved-filter[0]"
   ("dired" (mode . dired-mode))
   ("source" (mode . c-mode))
   ("emacs" (or (name . "^\\*scratch\\*$")
		(name . "^\\*Messages\\*$")
		(name . "/.*\\.el")))
   ("Python" (mode . python-mode))))


========================
Wednesday December 12 2018
--
(defun dp-read-number (prompt &optional integers-only default-value)
  "Read a number from the minibuffer, prompting with PROMPT.
If optional second argument INTEGERS-ONLY is non-nil, accept
 only integer input.
If DEFAULT-VALUE is non-nil, return that if user enters an empty
 line."
  (let ((pred (if integers-only 'integerp 'numberp))
	num)
    (while (not (funcall pred num))
      (setq num (let ((minibuffer-completion-table nil))
		  (read-from-minibuffer
		   prompt
		   nil
		   nil
		   t			; READ arg.
		   nil nil default-value)))
      (or (funcall pred num) (beep)))
    num))

========================
Thursday December 13 2018
--
(string-match "<dse>\\(<[0-9]+>\\)*" "rpc<dse><2>" )
3

(setq ibuffer-saved-filter-groups
      (quote
       (("dp-ibuffer-saved-filter[0]"
	 ("dse"
	  (name . "<dse>\\(<[0-9]+>\\)*"))
	 ("dired"
	  (mode . dired-mode))
	 ("source"
	  (mode . c-mode))
	 ("Python!"
	  (mode . python-mode))
	 ("Remote"
	  (name . "^/.[^:]+:[^@]+@[^:]+:"))
	 ("emacs"
	  (or
	   (name . "^\\*scratch\\*$")
	   (name . "^\\*Messages\\*$")
	   (name . "^.*\\.el")))))))


(case dp-mailer
    ('mu4e
     (require 'dp-mu4e)
     (dp-setup-mu4e)
     )
    ('mew
     ;; try for mew mailer package.  An error will
     ;; cause condition-case to yield nil, causing a
     ;; load of mhe.
     (setq dp-require-mew-done 'notyet)
     (require 'dp-mew)
     (setq dp-require-mew-done t)
     )
    ;; for now, only other mailer is mhe and that is the
    ;; default, too, so return nil which causes the
    ;; default to be loaded.
    ('gnus
     ;; This is a pretty safe default... it's quite popular... despite great
     ;; suckage as a mailer.
     (global-set-key [(control ?c) ?r] 'gnus)
     (global-set-key [(control ?x) ?m] 'gnus-msg-mail)
     ;; This works better if called before gnus is started.  Need to fix that.
     ;;(require 'dp-dot-gnus)
     )
    ('vm
     (require 'vm)
     (setq dp-current-mailer-config-file (dp-lisp-subdir "dp-dot-vm.el"))
     (global-set-key [(control ?c) ?r] 'vm)
     (global-set-key [(control ?x) ?m] 'vm-mail))
    )

========================
Tuesday January 15 2019
--
Debugger entered--Lisp error: (error "Invalid time specification")
  time-less-p("9feca494c3c7c1203d08fdf4b748482a" (23323 15756 447945 551000))
  update-directory-autoloads("/home/dpanarit/flisp/")
  dp-update-autoloads()
  funcall-interactively(dp-update-autoloads)
  call-interactively(dp-update-autoloads record nil)
  command-execute(dp-update-autoloads record)
  execute-extended-command(nil "dp-update-autoloads" nil)
  funcall-interactively(execute-extended-command nil "dp-update-autoloads" nil)
  call-interactively(execute-extended-command nil nil)
  command-execute(execute-extended-command)

bubba-theme.el:
Result: (nil 1 54930 30101 (23614 5011 111807 308000) (23323 15756 407942 250000) (23323 15756 407942 250000) 4742 "-rw-r--r--" t 29419968 2065)

(nth 5 ' (nil 1 54930 30101 (23614 5011 111807 308000) (23323 15756 407942 250000) (23323 15756 407942 250000) 4742 "-rw-r--r--" t 29419968 2065))
(23323 15756 407942 250000)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
error: "Invalid time specification"

dp-colorize-ifdefs.el:
  (nil 1 54930 30101 (23614 4287 910078 484000) (23323 15756 447945 551000) (23323 15756 447945 551000) 4775 "-rw-r--r--" t 29360364 2065)
(nth 5 '  (nil 1 54930 30101 (23614 4287 910078 484000) (23323 15756 447945 551000) (23323 15756 447945 551000) 4775 "-rw-r--r--" t 29360364 2065)
)
(23323 15756 447945 551000)

  (nth 5 '(nil 1 54930 30101 (23614 4287 910078 484000) (23323 15756 447945 551000) (23323 15756 447945 551000) 4775 "-rw-r--r--" t 29360364 2065))
(23323 15756 447945 551000)

========================
Thursday January 17 2019
--
(cl-pe '(define-derived-mode
  edebug-x-instrumented-function-list-mode tabulated-list-mode "Edebug Instrumented functions"
  "Major mode for listing instrumented functions"
  (setq tabulated-list-entries 'edebug-x-list-instrumented-functions)
  (setq tabulated-list-format
        [("Instrumented Functions" 50 nil)
         ("File" 150 nil)])
  (tabulated-list-init-header))
)

(progn
  (defvar edebug-x-instrumented-function-list-mode-hook nil)
  (if (get 'edebug-x-instrumented-function-list-mode-hook
	   'variable-documentation)
      nil
    (put 'edebug-x-instrumented-function-list-mode-hook
	 'variable-documentation
	 "Hook run after entering Edebug Instrumented functions mode.\nNo problems result if this variable is not bound.\n`add-hook' automatically binds it.  (This is true for all hook variables.)"))
  (if (boundp 'edebug-x-instrumented-function-list-mode-map)
      nil
    (put 'edebug-x-instrumented-function-list-mode-map
	 'definition-name
	 'edebug-x-instrumented-function-list-mode))
  (with-no-warnings (defvar edebug-x-instrumented-function-list-mode-map
		      (make-sparse-keymap)))
  (if (get 'edebug-x-instrumented-function-list-mode-map
	   'variable-documentation)
      nil
    (put 'edebug-x-instrumented-function-list-mode-map
	 'variable-documentation
	 (purecopy "Keymap for `edebug-x-instrumented-function-list-mode'.")))
  (progn
    (defvar edebug-x-instrumented-function-list-mode-syntax-table)
    (if (boundp 'edebug-x-instrumented-function-list-mode-syntax-table)
	nil
      (put 'edebug-x-instrumented-function-list-mode-syntax-table
	   'definition-name
	   'edebug-x-instrumented-function-list-mode)
      (defvar edebug-x-instrumented-function-list-mode-syntax-table
	(make-syntax-table)))
    (if (get 'edebug-x-instrumented-function-list-mode-syntax-table
	     'variable-documentation)
	nil
      (put 'edebug-x-instrumented-function-list-mode-syntax-table
	   'variable-documentation
	   (purecopy "Syntax table for `edebug-x-instrumented-function-list-mode'."))))
  (progn
    (defvar edebug-x-instrumented-function-list-mode-abbrev-table)
    (if (boundp 'edebug-x-instrumented-function-list-mode-abbrev-table)
	nil
      (put 'edebug-x-instrumented-function-list-mode-abbrev-table
	   'definition-name
	   'edebug-x-instrumented-function-list-mode)
      (defvar edebug-x-instrumented-function-list-mode-abbrev-table
	(progn
	  (define-abbrev-table 'edebug-x-instrumented-function-list-mode-abbrev-table
	    nil)
	  edebug-x-instrumented-function-list-mode-abbrev-table)))
    (if (get 'edebug-x-instrumented-function-list-mode-abbrev-table
	     'variable-documentation)
	nil
      (put 'edebug-x-instrumented-function-list-mode-abbrev-table
	   'variable-documentation
	   (purecopy "Abbrev table for `edebug-x-instrumented-function-list-mode'."))))
  (put 'edebug-x-instrumented-function-list-mode
       'derived-mode-parent
       'tabulated-list-mode)
  nil
  (defalias 'edebug-x-instrumented-function-list-mode
    (function
     (lambda nil
       "Major mode for listing instrumented functions\n\nIn addition to any hooks its parent mode `tabulated-list-mode' might have run,\nthis mode runs the hook `edebug-x-instrumented-function-list-mode-hook', as the final or penultimate step\nduring initialization.\n\n\\{edebug-x-instrumented-function-list-mode-map}"
       (interactive)
       (progn
	 (make-local-variable 'delay-mode-hooks)
	 (let ((delay-mode-hooks t))
	   (tabulated-list-mode)
	   (setq major-mode 'edebug-x-instrumented-function-list-mode)
	   (setq mode-name "Edebug Instrumented functions")
	   (progn
	     (if (get 'tabulated-list-mode 'mode-class)
		 (put 'edebug-x-instrumented-function-list-mode
		      'mode-class
		      (get 'tabulated-list-mode 'mode-class)))
	     (if (keymap-parent edebug-x-instrumented-function-list-mode-map)
		 nil
	       (set-keymap-parent edebug-x-instrumented-function-list-mode-map
				  (current-local-map)))
	     (let ((parent (char-table-parent edebug-x-instrumented-function-list-mode-syntax-table)))
	       (if (and parent (not (eq parent (standard-syntax-table))))
		   nil
		 (set-char-table-parent edebug-x-instrumented-function-list-mode-syntax-table
					(syntax-table))))
	     (if (or (abbrev-table-get edebug-x-instrumented-function-list-mode-abbrev-table
				       :parents)
		     (eq edebug-x-instrumented-function-list-mode-abbrev-table
			 local-abbrev-table))
		 nil
	       (abbrev-table-put edebug-x-instrumented-function-list-mode-abbrev-table
				 :parents
				 (list local-abbrev-table))))
	   (use-local-map edebug-x-instrumented-function-list-mode-map)
	   (set-syntax-table edebug-x-instrumented-function-list-mode-syntax-table)
	   (setq local-abbrev-table edebug-x-instrumented-function-list-mode-abbrev-table)
	   (setq tabulated-list-entries 'edebug-x-list-instrumented-functions)
	   (setq tabulated-list-format [("Instrumented Functions" 50 nil) ("File" 150 nil)])
	   (tabulated-list-init-header)))
       (run-mode-hooks 'edebug-x-instrumented-function-list-mode-hook)))))nil


========================
Wednesday January 23 2019
--

(defun

(defmacro dp-loading (&rest body)
  `(progn
    (message "loading %s..." (buffer-file-name))
    ,@body
    (message "loaded  %s..." (buffer-file-name))))
(put 'dp-loading 'lisp-indent-function 'dp-loading-indent-function)
dp-loading-indent-function

22

0

0

(symbol-plist 'cond)
(byte-compile byte-compile-cond gv-expander #[385 "\203 \301\302\303\"!\203  \304\305\306\307\310\311\312!\313\"\314\315%\"B\207\316\317!\304\305\306\307\320\311\312!\321\"\322\315%\"B\323!\203? \211\202B \324\325!\326\327DD\306\307\330\311\312!\331\"\332\333%\"=\203` \211\202g \334DC\"\266\203\207" [lexical-binding macroexp-small-p dummy #[257 "\300\207" [dummy] 2 "\n\n(fn _)"] cond mapcar make-byte-code 257 "\211A\203 \211@\301\302\303A!\300\"!B\207\302@\300\"\207" vconcat vector [macroexp-unprogn gv-get macroexp-progn] ...] 13 "\n\n(fn DO &rest BRANCHES)"] byte-optimizer byte-optimize-cond edebug-form-spec (&rest (&rest form)))

(symbol-plist 'dp-loading)
(edebug #<marker at 51041 in elisp-devel.yyz.el> lisp-indent-function 0)
(defun dp-loading-indent-function (&rest ignored)
  0)
dp-loading-indent-function

(dp-loading
(message "a")
(defun yagga ()
  (blah))
(message "b")
(message "b")))

(defun)
(cl-pe
'(progn
  (message "loading %s..." (buffer-file-name))
  (message "a")
  (message "b")
  (message "b")
  (message "loaded  %s..." (buffer-file-name)))nil
)

(progn
  (message "loading %s..." (buffer-file-name))
  (message "a")
  (message "b")
  (message "b")
  (message "loaded  %s..." (buffer-file-name)))nil




(progn
  (message "loading %s..." (buffer-file-name))
  (message "a")
  (message "b")
  (message "c")
  (message "loaded  %s..." (buffer-file-name)))
"loaded  /home/dpanarit/dpw/dpw/lisp/devel/elisp-devel.yyz.el..."



  





    
  
	    
  
  )

(message "poit2!")
"poit2!"


(defconst dp-original-isearch-string-out-of-window-function
  (symbol-function 'isearch-string-out-of-window)
  "Save this so we can still use it in our hack.")

;; (defun isearch-string-out-of-window (isearch-point)
;;   (message "poit! isearch-point: %s" isearch-point)
;;   (case (funcall dp-original-isearch-string-out-of-window-function
;; 		 isearch-point)
;;     ('above 'below)
;;     ('below 'above)))

(defun isearch-string-out-of-window (isearch-point)
  (funcall dp-original-isearch-string-out-of-window-function
		 isearch-point)
  (message "poit! isearch-point: %s, isearch-pre-scroll-point: %s"
	   isearch-point isearch-pre-scroll-point)
  (message "isearch-overlay: %s" isearch-overlay)
  (message "isearch-other-end: %s" isearch-other-end)
  (isearch-dehighlight)
  nil
  )

(dp-restore-orig-value 'isearch-string-out-of-window)
"isearch-string-out-of-window was unbound."

"isearch-string-out-of-window was unbound."

(dp-get-orig-value 'isearch-string-out-of-window)
"isearch-string-out-of-window was unbound."

"isearch-string-out-of-window was unbound."


(dp-remove-orig-n-unbind-new 'isearch-string-out-of-window)
dp-save-orig-n-set-new>isearch-string-out-of-window

dp-save-orig-n-set-new>isearch-string-out-of-window

dp-save-orig-n-set-new>isearch-string-out-of-window

(isearch-string-out-of-window 99)
nil

nil

nil

nil


========================
Friday January 25 2019
--
;;;;;;;;;;;;;


========================
Monday February 11 2019
--
;; This buffer is for text that is not saved, and for Lisp evaluation.
;; To create a file, visit it with <open> and enter text in its buffer.

(defun isearch-string-out-of-window (isearch-point)
  ;; @todo XXX As a less terrible hack, when we move out of the window,
  ;; exit `isearch-mode'.
(message "isearch-point: %s" isearch-point)

  (message))
  ;FIXME (let ((ab-bel (funcall dp-original-isearch-string-out-of-window-function
  ;FIXME 			 isearch-point)))
  ;FIXME   (if ab-bel
  ;FIXME 	;; We left the window.
  ;FIXME 	;; exit isearch mode.
  ;FIXME 	;; Works much better, but the cursor goes to the beginning of the
  ;FIXME 	;; line.  However, unexpectedly and quite happily, the searched for
  ;FIXME 	;; string remains highlighted.  I have no idea why, since the
  ;FIXME 	;; `isearch-exit' should, well, exit the search.
  ;FIXME 	(progn
  ;FIXME 	  (message "exiting, point: %s" (point))
  ;FIXME 	  (isearch-exit))
  ;FIXME     (message "NOT exiting, point: %s" (point)))
  ;FIXME   ab-bel))

========================
Wednesday March 27 2019
--
(cl-pe
 '(with-eval-after-load "bubba"
    (bubba-hook))
 )

(eval-after-load "text-mode" 
  (progn (dp-setup-indentation-colorization 'text-mode)))

(eval-after-load "bubba"
  (function (lambda nil (bubba-hook))))nil

========================
Tuesday April 16 2019
--
dp-get-n-set

(let* ((v "aaa")
       (vc v)
       (v2 (dp-get-n-set 'v 'qqq)))
  (princf "v>%s<. vc>%s<, v2>%s<" v vc v2))
v>qqq<. vc>aaa<, v2>aaa<
nil

