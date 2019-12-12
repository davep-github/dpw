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
Debugger entered--Lisp error: (error "Invalid use of in replacement text"q)
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

(defun dset2 (&optional file-name)
  (interactive "Gfile-name: ")
  (find-file file-name)
  (dset))

========================
Wednesday November 28 2018
--
;; (defun ispell--\\w-filter (char)
;;   "Return CHAR in a string when CHAR doesn't have \"word\" syntax,
;; nil otherwise.  CHAR must be a character."
;;   (let ((str (string char)))
;;     (and
;;      (not (string-match "\\w" str))
;;      str)))

(defcustom dp-preferred-filename-char-regexp "[0-9a-zA-Z_.,:%~=-]"
  "For general cleanup of file names.  A bit over-conservative.
A set of names should be checked for duplicates after filtering.")

(defun dp-preferred-filename-char (char)
  "Return CHAR in a string when CHAR doesn't have \"word\" syntax,
nil otherwise.  CHAR must be a character."
  (let ((str (string char)))
    (and
     (not (string-match "\\w" str))
     str)))

(defun dp-leftize (&optional movement-type frame-or-window)
  "Move buffer in the right window to the leftmost window.
MOVEMENT-TYPE is 'shift|'move|'rotate as per \\[dp-shift-windows]
or 'slide as per \\[dp-slide-window-left].
@todo XXX Fix me to use (frame-first-window) as the destination
      of the right hand buffer rather than just shiifting or sliding."
  (interactive "P")
  (setq movement-type (or movement-type
			  (and current-prefix-arg
			       'slide)
			  'shift))
  (cond
   ((memq movement-type '(shift move rotate))
    (dp-shift-windows))
   ((memq movement-type '(slide))
    (dp-slide-window-left))
   (t (dp-shift-windows)))
  (set-buffer (frame-first-window frame-or-window))
  (select-current-buffer))

========================
Monday February 11 2019
--
;installed (defun dp-ibuffer-current-filename (&optional must-be-live-p)
;installed   (interactive "P")
;installed   (if-let ((buf (ibuffer-current-buffer must-be-live-p)))
;installed       (buffer-file-name buf)
;installed     buf))

;installed (defun dp-ibuffer-current-filename-show (&optional must-be-live-p)
;installed   (interactive "P")
;installed   (message "%s" (dp-ibuffer-current-filename must-be-live-p)))

;installed (defun dp-ibuffer-current-buffer-name (&optional must-be-live-p)
;installed   (interactive "P")
;installed   (if-let ((buf (ibuffer-current-buffer must-be-live-p)))
;installed       (buffer-name buf)
;installed     buf))

;installed (defun dp-ibuffer-current-buffer-name-show (&optional must-be-live-p)
;installed   (interactive "P")
;installed   (message "%s" (dp-ibuffer-current-buffer-name must-be-live-p)))

========================
Friday February 15 2019
--
(set-face-background 'scroll-bar "red")
nil



========================
Saturday February 23 2019
--
(custom-set-variables
 '(ibuffer-default-sorting-mode (quote alphabetic))
 '(ibuffer-fontification-alist
   (quote
    ((10 buffer-read-only ibuffer-locked-buffer)
     (15
      (and buffer-file-name
	   (string-match ibuffer-compressed-file-name-regexp buffer-file-name))
      font-lock-function-name-face)
     (20
      (string-match "^*"
		    (buffer-name))
      font-lock-constant-face)
     (25
      (and
       (string-match "^ "
		     (buffer-name))
       (null buffer-file-name))
      italic)
     (30
      (memq major-mode ibuffer-help-buffer-modes)
      font-lock-doc-face)
     (35
      (derived-mode-p
       (quote dired-mode))
      font-lock-function-name-face)
     (40
      (and
       (boundp
	(quote emacs-lock-mode))
       emacs-lock-mode)
      ibuffer-locked-buffer)
     (55
      (string-match "<dse>\\(<[0-9]+>\\)*$"
		    (buffer-name))
      dp-sudo-edit-bg-face)
     (33
      (and buffer-file-name
	   (string-match "^/.[^:]+:\\([^@]+@\\)?[^:]+:" buffer-file-name))
      dp-remote-buffer-face))))
)
nil


========================
Tuesday February 26 2019
--
(cl-pp default-frame-alist)
((tool-bar-lines . 0)
 (menu-bar-lines . 1)
 (width . 180)
 (height . 66)
 (background-color . "#1b182c")
 (vertical-scroll-bars . right))

(cl-pp initial-frame-alist)
((width . 180)
 (height . 66)
 (vertical-scroll-bars . right))

(setq initial-frame-alist
      '((width . 180)
	(height . 66)
	(fullscreen . fullheight)
	(vertical-scroll-bars . right)))

(setq default-frame-alist
      '((tool-bar-lines . 0)
	(menu-bar-lines . 1)
	(width . 180)
	(height . 66)
	(background-color . "#1b182c")
	(vertical-scroll-bars . right)))
((tool-bar-lines . 0) (menu-bar-lines . 1) (width . 180) (height . 66) (background-color . "#808080") (vertical-scroll-bars . right))



(set-frame-parameter nil 'fullscreen 'fullheight)
nil
(frame-parameter nil 'fullscreen)
fullheight
(frame-parameter nil 'fullscreen-restore)
fullheight


(set-frame-parameter nil 'fullscreen nil)
nil


(progn
  (set-frame-parameter nil 'fullscreen 'fullheight)
  (sit-for 0.1)
  (let ((height (frame-height)))
    (set-frame-parameter nil 'fullscreen nil)
    (sit-for 0.1)
    (set-frame-height nil (/ height 1))))
nil


(dp-set-to-max-vert-frame-height)
nil

nil




(toggle-frame-maximized)
(toggle-frame-fullscreen)

nil

nil

nil

nil

nil


========================
Thursday February 28 2019
--
(require 'emms)
emms

(cl-pp ido-common-completion-map)

(keymap (4 . ido-magic-delete-char)
	(6 . ido-magic-forward-char)
	(2 . ido-magic-backward-char)
	(63 . ido-completion-help)
	(left . ido-prev-match)
	(right . ido-next-match)
	(0 . ido-restrict-to-matches)
	(27 keymap (32 . ido-take-first-match))
	(67108896 . ido-restrict-to-matches)
	(26 . ido-undo-merge-work-directory)
	(20 . ido-toggle-regexp)
	(67108908 . ido-prev-match)
	(67108910 . ido-next-match)
	(19 . ido-next-match)
	(18 . ido-prev-match)
	(16 . ido-toggle-prefix)
	(13 . ido-exit-minibuffer)
	(10 . ido-select-text)
	(32 . ido-complete-space)
	(9 . ido-complete)
	(5 . ido-edit-input)
	(3 . ido-toggle-case)
	(1 . ido-toggle-ignore)
	keymap
	(M-up . switch-to-completions)
	(tab . minibuffer-complete)
	(14 . next-complete-history-element)
	(16 . previous-complete-history-element)
	(C-space . dp-expand-abbrev)
	(menu-bar keymap
		  (minibuf "Minibuf"
			   keymap
			   (previous menu-item
				     "Previous History Item"
				     previous-history-element
				     :help
				     "Put previous minibuffer history element in the minibuffer")
			   (next menu-item
				 "Next History Item"
				 next-history-element
				 :help
				 "Put next minibuffer history element in the minibuffer")
			   (isearch-backward menu-item
					     "Isearch History Backward"
					     isearch-backward
					     :help
					     "Incrementally search minibuffer history backward")
			   (isearch-forward menu-item
					    "Isearch History Forward"
					    isearch-forward
					    :help
					    "Incrementally search minibuffer history forward")
			   (return menu-item
				   "Enter"
				   exit-minibuffer
				   :key-sequence
				   ""
				   :help
				   "Terminate input and exit minibuffer")
			   (quit menu-item
				 "Quit"
				 abort-recursive-edit
				 :help
				 "Abort input and exit minibuffer")
			   "Minibuf"))
	(10 . exit-minibuffer)
	(13 . exit-minibuffer)
	(7 . minibuffer-keyboard-quit)
	(C-tab . file-cache-minibuffer-complete)
	(9 . self-insert-command)
	(XF86Back . previous-history-element)
	(up . previous-history-element)
	(prior . previous-history-element)
	(XF86Forward . next-history-element)
	(down . next-history-element)
	(next . next-history-element)
	(27 keymap
	    (119 . dp-rsh-cwd-to-minibuffer)
	    (101 . dp-rsh-cwd-to-minibuffer)
	    (111 . dp-kill-ring-save)
	    (57 lambda
		(&optional arg arg1 arg2 arg3 arg4 arg5)
		""
		(interactive "P")
		(dp-insert-parentheses nil))
	    (61 lambda
		(&optional arg arg1 arg2 arg3 arg4 arg5)
		""
		(interactive "P")
		(enqueue-eval-event 'eval
				    (nth (1- (prefix-numeric-value arg))
					 command-history))
		(top-level))
	    (39 . dp-copy-char-to-minibuf)
	    (44 . minibuffer-keyboard-quit)
	    (96 . previous-complete-history-element)
	    (45 . minibuffer-keyboard-quit)
	    (114 . previous-matching-history-element)
	    (115 . next-matching-history-element)
	    (112 . dp-parenthesize-region)
	    (110 . next-history-element)))


========================
Tuesday March 05 2019
--
(cl-pe
'(mingus-define-mpd->mingus mingus-pause
                           (mingus-minibuffer-feedback 'state)
                           (mingus-set-NP-mark t)))

(defalias 'mingus-pause
  (function
   (lambda (&rest args)
     (interactive)
     (apply (function mpd-pause) mpd-inter-conn args)
     (mingus-minibuffer-feedback 'state)
     (mingus-set-NP-mark t))))nil




========================
Wednesday March 06 2019
--
(defun ist (x)
  (eq t x))
(defun isplay (x)
  (message "isplay: %s" x)
  (eq x 'play))

(isplay 'ksjd)
nil

(pcase 'jdkhfkjdhf ;; (getf (mpd-get-status mpd-inter-conn) 'state)
  (pred 'isplay (message "IS_PLAY!: %s" pred))
  ('play (message "PLAY!"))
  ('pause (message "PAUSE!"))
  ('stop (message "STOP!"))
  (none-above (message "NONE of the above: %s" none-above)))
"IS_PLAY!: jdkhfkjdhf"

"IS_PLAY!"


"IS_PLAY!"

"IS_PLAY!"

"NONE of the above: jdkhfkjdhf"

"PLAY!"

"NONE of the above: jdkhfkjdhf"

"IS_PLAY!"

"IS_PLAY!"

(isplay 'xplay)
nil

t

t

(pcase (getf (mpd-get-status mpd-inter-conn) 'state)
  (pred 'isplay (message "IS_PLAY!"))
  ('play (message "PLAY!"))
  ('pause (message "PAUSE!"))
  ('stop (message "STOP!")))
"IS_PLAY!"


"STOP!"
"PLAY!"
"PAUSE!"


(cl-pe
'(pcase 'jdkhfkjdhf ;; (getf (mpd-get-status mpd-inter-conn) 'state)
  ((pred isplay) (message "IS_PLAY!: %s" pred))
  ((or 'x 'play) (message "PLAY!"))
  ('pause (message "PAUSE!"))
  ('stop (message "STOP!"))
  (none-above (message "NONE of the above: %s" none-above)))
)

(cond ((isplay 'jdkhfkjdhf)
       (message "IS_PLAY!: %s" pred))
      ((memq 'jdkhfkjdhf '(play x))
       (message "PLAY!"))
      ((eq 'jdkhfkjdhf 'pause)
       (message "PAUSE!"))
      ((eq 'jdkhfkjdhf 'stop)
       (message "STOP!"))
      (t (let ((none-above 'jdkhfkjdhf))
	   (message "NONE of the above: %s" none-above))))nil



(cond ((isplay 'jdkhfkjdhf)
       (message "IS_PLAY!: %s" pred))
      ((eq 'jdkhfkjdhf 'play)
       (message "PLAY!"))
      ((eq 'jdkhfkjdhf 'pause)
       (message "PAUSE!"))
      ((eq 'jdkhfkjdhf 'stop)
       (message "STOP!"))
      (t (let ((none-above 'jdkhfkjdhf))
	   (message "NONE of the above: %s" none-above))))
"NONE of the above: jdkhfkjdhf"


(pcase 'x
  ((pred isplay) (message "IS_PLAY!"))
  ((or 'x 'play) (message "PLAY!"))
  ('pause (message "PAUSE!"))
  ('stop (message "STOP!"))
  (none-above (message "NONE of the above: %s" none-above)))
"PLAY!"

"PAUSE!"


(pcase 'pausex
  ((pred isplay) (message "IS_PLAY!: %s" pred))
  ((or 'x 'play) (message "PLAY!"))
  ('pause (message "PAUSE!"))
  ('stop (message "STOP!"))
  (none-above (message "NONE of the above: %s" none-above)))
"NONE of the above: pausex"

"PAUSE!"





(let ((pred 'jdkhfkjdhf))
  'isplay
  (message "IS_PLAY!: %s" pred))nil


(cond ((eq 'jdkhfkjdhf 'play)
       (message "PLAY!"))
      ((eq 'jdkhfkjdhf 'pause)
       (message "PAUSE!"))
      ((eq 'jdkhfkjdhf 'stop)
       (message "STOP!"))
      (t (let ((none-above 'jdkhfkjdhf))
	   (message "NONE of the above: %s" none-above))))

(cl-pe
'(defun grok/pcase (obj)
  (pcase obj
    ((or                                     ; line 1
      (and                                   ; line 2
       (pred stringp)                        ; line 3
       (pred (string-match                   ; line 4
	      "^key:\\([[:digit:]]+\\)$"))   ; line 5
       (app (match-string 1)                 ; line 6
	    val))                            ; line 7
      (let val (list "149" 'default)))       ; line 8
     val)))
)

(defalias 'grok/pcase
  (function
   (lambda (obj)
     (cond ((not (stringp obj))
	    (let* ((sym (list "149" 'default)))
	      (let ((val sym))
		val)))
	   ((string-match "^key:\\([[:digit:]]+\\)$" obj)
	    (let* ((x644 (match-string 1 obj)))
	      (let ((val x644))
		val)))
	   (t (let* ((sym (list "149" 'default))) (let ((val sym)) val)))))))

========================
Thursday March 21 2019
--
(defun dp-show-buffer-file-name (&optional kill-name-p buffer)
  (interactive "P")
  (let (name-name-type)
    (cond
     ((eq major-modw 'dired-mode)
      (save-excursion
	(goto-char (point-min))
	(dp-re-search-forward "\\(^\s-+\\)\\(\S-+\\)\\(:\\)"
			      (line-end-position))
	)
      (dp-get-buffer-file-name-info kill-name-p buffer))

      (if kill-name-p
	  ( (match-string-no-properties)))
      ))
    (message "%s%s: %s"
             (if kill-name-p
                 "Copied "
               "")
             (cdr name-name-type)
             (car name-name-type))))


========================
Tuesday March 26 2019
--

dp-fixed-corresponding-files
(("dp-fsf-fsf-compat.el" . "dp-xemacs-fsf-compat.el") ("dpmisc.el" . "dpmacs.el"))

;; To switch between dpmacs.el and dpmisc.el quickly, use
;; C-x M-b to run the command dp-edit-corresponding-file
;; Which the following sets up.
(dp-add-corresponding-file-pair "dpmisc.el" "dpmacs.el")

(dp-add-to-list 'dp-fixed-corresponding-files
		(cons "dp-fsf-fsf-compat.el" "dp-xemacs-fsf-compat.el"))
(("dp-bubba1.el" . "dp-bubba2.el") ("dp-fsf-fsf-compat.el" . "dp-xemacs-fsf-compat.el") ("dpmisc.el" . "dpmacs.el"))

(("dp-bubba1.el" . "dp-bubba2.el") ("dp-fsf-fsf-compat.el" . "dp-xemacs-fsf-compat.el") ("dpmisc.el" . "dpmacs.el"))

(("dp-fsf-fsf-compat.el" . "dp-xemacs-fsf-compat.el") ("dpmisc.el" . "dpmacs.el"))

(("dp-fsf-fsf-compat.el" . "dp-xemacs-fsf-compat.el"))

(("dp-fsf-fsf-compat.el" . "dp-xemacs-fsf-compat.el"))

(dp-add-corresponding-file-pair "dp-bubba1.el"
				"dp-bubba2.el")
(("dp-bubba1.el" . "dp-bubba2.el") ("dp-fsf-fsf-compat.el" . "dp-xemacs-fsf-compat.el") ("dpmisc.el" . "dpmacs.el"))

(("dp-fsf-fsf-compat.el" . "dp-xemacs-fsf-compat.el") ("dpmisc.el" . "dpmacs.el"))

(("dp-fsf-fsf-compat.el" . "dp-xemacs-fsf-compat.el") ("dpmisc.el" . "dpmacs.el"))


========================
Wednesday March 27 2019
--

(cl-pe
 '(with-eval-after-load "bubba" (yadda)))

(eval-after-load "bubba" (function (lambda nil (yadda))))nil



========================
Thursday March 28 2019
--
(cl-pe
'(define-transient-command magit-commit ()
  "Create a new commit or replace an existing commit."
  :info-manual "(magit)Initiating a Commit"
  :man-page "git-commit"
  ["Arguments"
   ("-a" "Stage all modified and deleted files"   ("-a" "--all"))
   ("-e" "Allow empty commit"                     "--allow-empty")
   ("-v" "Show diff of changes to be committed"   ("-v" "--verbose"))
   ("-n" "Disable hooks"                          ("-n" "--no-verify"))
   ("-R" "Claim authorship and reset author date" "--reset-author")
   (magit:--author :description "Override the author")
   (7 "-D" "Override the author date" "--date=" transient-read-date)
   ("-s" "Add Signed-off-by line"                 ("-s" "--signoff"))
   (5 magit:--gpg-sign)
   (magit-commit:--reuse-message)]
  [["Create"
    ("c" "Commit"         magit-commit-create)]
   ["Edit HEAD"
    ("e" "Extend"         magit-commit-extend)
    ("w" "Reword"         magit-commit-reword)
    ("a" "Amend"          magit-commit-amend)
    (6 "n" "Reshelve"     magit-commit-reshelve)]
   ["Edit"
    ("f" "Fixup"          magit-commit-fixup)
    ("s" "Squash"         magit-commit-squash)
    ("A" "Augment"        magit-commit-augment)
    (6 "x" "Absorb changes" magit-commit-absorb)]
   [""
    ("F" "Instant fixup"  magit-commit-instant-fixup)
    ("S" "Instant squash" magit-commit-instant-squash)]]
  (interactive)
  (if-let ((buffer (magit-commit-message-buffer)))
      (switch-to-buffer buffer)
    (transient-setup 'magit-commit)))
)

(progn
  (defalias 'magit-commit
    (function
     (lambda nil
       (interactive)
       (let* ((buffer (and t (magit-commit-message-buffer))))
	 (if buffer
	     (switch-to-buffer buffer)
	   (transient-setup 'magit-commit))))))
  (put 'magit-commit
       'function-documentation
       "Create a new commit or replace an existing commit.")
  (put 'magit-commit
       'transient--prefix
       (transient-prefix :command
			 'magit-commit
			 :info-manual
			 "(magit)Initiating a Commit"
			 :man-page
			 "git-commit"))
  (put 'magit-commit
       'transient--layout
       '([1 transient-column (:description "Arguments") ((1 transient-switch (:key "-a" :description "Stage all modified and deleted files" :shortarg "-a" :argument "--all" :command transient:magit-commit:--all)) (1 transient-switch (:key "-e" :description "Allow empty commit" :argument "--allow-empty" :command transient:magit-commit:--allow-empty)) (1 transient-switch (:key "-v" :description "Show diff of changes to be committed" :shortarg "-v" :argument "--verbose" :command transient:magit-commit:--verbose)) (1 transient-switch (:key "-n" :description "Disable hooks" :shortarg "-n" :argument "--no-verify" :command transient:magit-commit:--no-verify)) (1 transient-switch (:key "-R" :description "Claim authorship and reset author date" :argument "--reset-author" :command transient:magit-commit:--reset-author)) (1 transient-suffix (:command magit:--author :description "Override the author")) (7 transient-option (:key "-D" :description "Override the author date" :argument "--date=" :command transient:magit-commit:--date= :reader transient-read-date)) (1 transient-switch (:key "-s" :description "Add Signed-off-by line" :shortarg "-s" :argument "--signoff" :command transient:magit-commit:--signoff)) (5 transient-suffix (:command magit:--gpg-sign)) (1 transient-suffix (:command magit-commit:--reuse-message)))] [1 transient-columns nil ([1 transient-column (:description "Create") ((1 transient-suffix (:key "c" :description "Commit" :command magit-commit-create)))] [1 transient-column (:description "Edit HEAD") ((1 transient-suffix (:key "e" :description "Extend" :command magit-commit-extend)) (1 transient-suffix (:key "w" :description "Reword" :command magit-commit-reword)) (1 transient-suffix (:key "a" :description "Amend" :command magit-commit-amend)) (6 transient-suffix (:key "n" :description "Reshelve" :command magit-commit-reshelve)))] [1 transient-column (:description "Edit") ((1 transient-suffix (:key "f" :description "Fixup" :command magit-commit-fixup)) (1 transient-suffix (:key "s" :description "Squash" :command magit-commit-squash)) (1 transient-suffix (:key "A" :description "Augment" :command magit-commit-augment)) (6 transient-suffix (:key "x" :description "Absorb changes" :command magit-commit-absorb)))] [1 transient-column (:description "") ((1 transient-suffix (:key "F" :description "Instant fixup" :command magit-commit-instant-fixup)) (1 transient-suffix (:key "S" :description "Instant squash" :command magit-commit-instant-squash)))])])))nil



========================
Monday April 29 2019
--
        (when (string-match
	       (concat "^\\(" dp-ws+cr+newline-regexp+-not "\\)" s)
          ;; Just set it, no sense in comparing to see if it changed.
          (setq default-directory


"^\\([^

]+\\)"
"^\\([^

]+\\)"


(concat "^\\(" dp-ws+cr+newline-regexp+-not "\\)" s)


========================
Tuesday April 30 2019
--

(read-extended-command)
(defun qqq (&optional expr)
  (interactive "Xexpr: ")
  (princf "expr>%s<" expr)
  expr)

(setq qqqv (qqq))
expr>nil<
nil


(setq qqqv (qqq '(c . d)))
expr>(c . d)<
(c . d)

qqqv
(c . d)
(car qqqv)
c
(cdr qqqv)
d


(eval (qqq '(a . b)))
expr>(a . b)<


expr>(a . b)<

expr>(a . b)<

expr>(a . b)<
(a . b)

expr>(a . b)<
(a . b)

expr>(a . b)<
nil

expr>(a . b)<
nil




(let ((a1 '((a . 1) (b . 2) (c . 4)))
      (a2 '((aa . 11) (d . 4) (c . 3)))
      z)
  (princf "a1>%s<" a1)
  (princf "a2>%s<" a2)
  (setq z (dp-add-or-update-alist-with-alist 'a1 a2))
  (princf "z>%s<" z)
  (princf "a1>%s<" a1))
a1>((a . 1) (b . 2) (c . 4))<
a2>((aa . 11) (d . 4) (c . 3))<
z>((d . 4) (aa . 11) (a . 1) (b . 2) (c . 3))<
a1>((d . 4) (aa . 11) (a . 1) (b . 2) (c . 3))<
nil







========================
Monday December 09 2019
--


(defun dp-py-bound-arg-list ()
  (interactive)
  (save-excursion
    (python-nav-backward-statement)
    (python-nav-forward-statement)
    ;; Cannot be at start of keyword, e.g. `def'.
    (right-char 1)
    ;; Goto space after keyword.
    (python-nav-forward-sexp)
    ;; Move's us to open paren.
    (python-nav-forward-sexp)
    (let ((open-paren (point))
	  (close-paren (progn
			 (python-nav-forward-sexp)
			 (point))))
      (cons open-paren close-paren))))
