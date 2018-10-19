(defun magit-log-format-margin (author date)
  (-when-let (option (magit-margin-option))
    (-let [(_ style width details details-width)
           (or magit-buffer-margin
               (symbol-value option))]
      (magit-make-margin-overlay
       (concat (and details
                    (concat (propertize (truncate-string-to-width
                                         (or author "")
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
Tuesday July 17 2018
--
error: patch failed: lisp/dpmacs.el:62
error: lisp/dpmacs.el: patch does not apply

========================
Monday October 15 2018
--
(defvar dp-whitespace-violation-rulettes
  (list (cons dp-trailing-whitespace-regexp 'dp-t)
        (cons dp-space-before-tab-regexp 'dp-t)
        (cons dp-too-many-spaces-in-a-row-regexp (lambda ()
                                                   indent-tabs-mode))
        ))
dp-whitespace-violation-rulettes

(mapcar (lambda (z)
          (if (funcall (cdr z))
              (car z)
            "NONONONONONONO!"))
        dp-whitespace-violation-rulettes)
("\\s-+$" " +[	]" "NONONONONONONO!")


(mapconcat (lambda (z)
             (if (funcall (cdr z))
                 (car z)
               nil))
           dp-whitespace-violation-rulettes
           "\\|")
"\\s-+$\\| +[	]\\|"

"\\s-+$\\| +[	]\\|"

"\\s-+$\\ +[	]\\"

