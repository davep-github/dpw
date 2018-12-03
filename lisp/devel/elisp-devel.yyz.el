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
